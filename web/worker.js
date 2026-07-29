// nebelhaus.com — one Worker serves the whole site.
//
//   /init.sh            → PROXIES the rice's bootstrap.sh as text/plain, so the
//                         install one-liner is exactly:
//                             curl -fsSL https://nebelhaus.com/init.sh | bash
//   /download/<app>     → 302 to the latest GitHub release's macOS artifact,
//                         so landing pages (and curl) get a stable URL while
//                         GitHub keeps hosting bytes and counting downloads
//   /api/release/<app>  → tiny JSON (tag, asset, size, publishedAt) the landing
//                         pages use to label the download button with the real
//                         version — nothing hardcoded to go stale between deploys
//   everything else     → the static Astro/Starlight site (the [assets] binding)
//
// We PROXY (fetch), not redirect, so the pretty URL is what curl sees and there's
// no hop to a raw.githubusercontent.com link. By default /init.sh serves the
// latest GitHub *release* tag of nebelhaus/nebelhaus (cached ~1h to stay well
// under GitHub's unauthenticated API limit), falling back to `main` before the
// first release. `?ref=v2026.07.18` pins an exact ref; a REF wrangler var hard-pins one.

const REPO = "nebelhaus/nebelhaus";
const SAFE_REF = /^[A-Za-z0-9._-]+$/; // no slashes / dots-dots -> no path traversal

// The apps with signed + notarized release artifacts on GitHub. Keys are the
// URL slugs; each repo lives at github.com/nebelhaus/<app>.
const DOWNLOADABLE = new Set(["pounce", "trill", "perch"]);
const MACOS_ASSET = /-macos\.(zip|tar\.gz)$/;

const text = (body, status = 200, extra = {}) =>
  new Response(body, {
    status,
    headers: { "content-type": "text/plain; charset=utf-8", ...extra },
  });

async function latestRef(env) {
  if (env.REF) return env.REF; // deploy-time hard pin wins
  const cache = caches.default;
  const key = new Request("https://nebelhaus.com/__latest_release");
  const cached = await cache.match(key);
  if (cached) return (await cached.text()).trim();
  try {
    const r = await fetch(`https://api.github.com/repos/${REPO}/releases/latest`, {
      headers: { "user-agent": "nebelhaus-init", accept: "application/vnd.github+json" },
    });
    if (r.ok) {
      const tag = (await r.json()).tag_name;
      if (tag && SAFE_REF.test(tag)) {
        // Cache for an hour so we make ~1 API call per colo per hour.
        await cache.put(key, new Response(tag, { headers: { "cache-control": "max-age=3600" } }));
        return tag;
      }
    }
  } catch (_) {
    /* network / API hiccup — fall through to main */
  }
  return "main";
}

// Latest-release lookup for a family app, cached ~1h per colo like latestRef —
// one shape serves both the redirect and the JSON endpoint.
async function latestAppRelease(app) {
  const cache = caches.default;
  const key = new Request(`https://nebelhaus.com/__release/${app}`);
  const cached = await cache.match(key);
  if (cached) return cached.json();
  try {
    const r = await fetch(`https://api.github.com/repos/nebelhaus/${app}/releases/latest`, {
      headers: { "user-agent": "nebelhaus-download", accept: "application/vnd.github+json" },
    });
    if (r.ok) {
      const release = await r.json();
      const asset = release.assets?.find((a) => MACOS_ASSET.test(a.name)) ?? release.assets?.[0];
      if (release.tag_name && asset) {
        const meta = {
          tag: release.tag_name,
          asset: asset.name,
          size: asset.size,
          url: asset.browser_download_url,
          publishedAt: release.published_at,
        };
        await cache.put(
          key,
          new Response(JSON.stringify(meta), {
            headers: { "content-type": "application/json", "cache-control": "max-age=3600" },
          }),
        );
        return meta;
      }
    }
  } catch (_) {
    /* network / API hiccup — caller falls back to the releases page */
  }
  return null;
}

async function serveDownload(app) {
  const release = await latestAppRelease(app);
  // Even on an API hiccup the user still lands somewhere useful.
  const target = release?.url ?? `https://github.com/nebelhaus/${app}/releases/latest`;
  return new Response(null, {
    status: 302,
    headers: { location: target, "cache-control": "public, max-age=300" },
  });
}

async function serveReleaseMeta(app) {
  const release = await latestAppRelease(app);
  if (!release) return text("{}", 502, { "content-type": "application/json" });
  return new Response(JSON.stringify(release), {
    headers: {
      "content-type": "application/json",
      "cache-control": "public, max-age=300",
    },
  });
}

async function serveInitScript(url, env) {
  const ref = url.searchParams.get("ref") || (await latestRef(env));
  if (!SAFE_REF.test(ref) || ref.includes("..")) {
    return text("# invalid ref\n", 400);
  }
  const raw = `https://raw.githubusercontent.com/${REPO}/${ref}/bootstrap.sh`;
  const up = await fetch(raw, { cf: { cacheTtl: 300, cacheEverything: true } });
  if (!up.ok) {
    return text(`# could not fetch bootstrap.sh at '${ref}' (HTTP ${up.status})\n`, 502);
  }
  return text(await up.text(), 200, {
    "cache-control": "public, max-age=300",
    "x-nebelhaus-ref": ref,
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname === "/init.sh") {
      return serveInitScript(url, env);
    }
    const appRoute = url.pathname.match(/^\/(download|api\/release)\/([a-z]+)$/);
    if (appRoute && DOWNLOADABLE.has(appRoute[2])) {
      return appRoute[1] === "download" ? serveDownload(appRoute[2]) : serveReleaseMeta(appRoute[2]);
    }
    // Everything else is the static site. With the [assets] binding present,
    // matching assets are served automatically before the Worker even runs;
    // this fallback covers requests that reach the Worker anyway.
    if (env.ASSETS) return env.ASSETS.fetch(request);
    return text("nebelhaus — https://github.com/nebelhaus/nebelhaus\n", 404);
  },
};

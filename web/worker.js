// nebelhaus.com — the 301 map. This zone no longer serves a site.
//
// Every page that lived here was rebuilt on hausfold.co (rename plan §5.2), and
// two live copies of one docs tree is how a fact gets fixed in one and not the
// other. So the Astro/Starlight build is gone, the [assets] binding with it, and
// this Worker answers the whole zone with permanent redirects:
//
//   /guides/pounce      → https://hausfold.co/docs/haus/rooms/launcher/
//   /init.sh            → https://hausfold.co/nebelhaus.sh   (one hop, not two)
//   /download/<app>     → the same route on hausfold.co, which still 302s to
//   /api/release/<app>     the latest notarized GitHub artifact
//   anything else       → 404, honestly
//
// 🚨 This is also what closes the `?ref=` hole the assurance pass found on
// hausfold.co's copy: a 40-hex commit SHA passes the old `SAFE_REF`, and
// raw.githubusercontent.com serves any object in a public repo's FORK network,
// so a stranger's fork commit could be handed out as
// `nebelhaus.com/init.sh?ref=<sha>` — our domain, our TLS, their script. This
// Worker fetches nothing, so the hole closes by deletion rather than by a
// narrower regex. `?ref=` is preserved on the redirect: hausfold.co's own
// handler holds it to the release-tag shape, which is where that check belongs.
//
// ⚠️ That was true of this file before it was true of the zone. `/init.sh` did
// not reach this Worker at all until 2026-08-14: `nebelhaus-init`, the
// installer's first Worker, still held the more specific route
// `nebelhaus.com/init.sh*`, because a route belongs to the script that declared
// it and no deploy under a new name reclaims one. Deleting that script is what
// made this comment true — rename plan §5.3. Measured after: `/init.sh` 301s,
// `?ref=<tag>` still resolves, `?ref=<40-hex sha>` is refused with a 400 on the
// other side.

// The one destination. Every value below is a path on this origin.
const SITE = "https://hausfold.co";

// Old URL → new URL, one row per page the old site published, and it can never
// grow: the site that served these is deleted, so this table is closed.
//
// Keys are normalized — lowercased, no trailing slash, `/` written as "". Both
// spellings resolve because of that normalization, which matters more than it
// used to: the no-slash form only 307'd to the slash form while an index.html
// existed at that path, and the [assets] binding that did it is gone.
//
// Destinations carry hausfold.co's trailing slash (`trailingSlash: true` in its
// Next config) so a visitor lands in one hop rather than two. The exceptions are
// the two `worker.js` routes there and the generated text files, none of which
// are pages.
//
// Composed from two records rather than derived from an old build: the rename
// plan's source ledger (§5.2) says which source became which page, and
// hausfold.co's `public/_redirects` says where the rooms reorganisation moved it
// on 2026-08-14. Where a row disagrees with the ledger it is because it follows
// the *current* URL — `guides/theming` became `guides/theming` and then
// `rooms/appearance`, and a visitor should not pay for that history.
export const REDIRECTS = {
  // The landing page and the two products. ⚠️ They land in different *kinds*
  // of page, and that is not a mistake to tidy: hausfold.co retired its
  // `/pounce` sheet into a docs tree on 2026-08-14 (pounce installs from
  // Homebrew with no Nix and is read about more than it is pitched), while
  // perch keeps a sheet because it is an App Store app with a policy URL and,
  // later, a price.
  "": `${SITE}/`,
  "/pounce": `${SITE}/docs/pounce/`,
  "/perch": `${SITE}/perch/`,

  // Generated routes, same names on the other side.
  "/llms.txt": `${SITE}/llms.txt`,
  "/llms-full.txt": `${SITE}/llms-full.txt`,

  // Start here. `what-is-nebelhaus` and `first-run` were the desktop tree's
  // pages; that tree was retired into the desktop's own sheet on 2026-08-14,
  // so both land outside `/docs` now. The fragments are real ids on that page
  // — see `public/hausfold.css`'s scroll-margin rule — and a fragment in a
  // Location header costs nothing, because the browser applies it after the
  // hop rather than sending it.
  "/start/what-is-nebelhaus": `${SITE}/desktops/nebelhaus/`,
  "/start/install": `${SITE}/docs/haus/install/`,
  "/start/first-run": `${SITE}/desktops/nebelhaus/#first-moves`,
  // `start/the-family` was deliberately retired rather than ported (§5.2,
  // 2026-08-12) — three pieces of it moved into `internals/contributing` and
  // the rest was about a family the docs index now shows. The index is the
  // honest destination.
  "/start/the-family": `${SITE}/docs/`,

  // Guides. Most became rooms; the two that didn't became desktop pages.
  "/guides/making-it-yours": `${SITE}/docs/haus/desktops/customizing/`,
  "/guides/sharing-a-rice": `${SITE}/docs/haus/desktops/creating/`,
  // ⚠️ These two are easy to swap. `ai-agent` was "Changing your Mac with an
  // agent" (rebuilds) and `claude-agents` was "Coding agents (holt)" (the room).
  "/guides/ai-agent": `${SITE}/docs/haus/rooms/agent-rebuilds/`,
  "/guides/claude-agents": `${SITE}/docs/haus/rooms/ai/`,
  "/guides/adding-apps": `${SITE}/docs/haus/rooms/apps/`,
  "/guides/window-management": `${SITE}/docs/haus/rooms/windows/`,
  "/guides/the-bar": `${SITE}/docs/haus/rooms/bar/`,
  "/guides/the-shell": `${SITE}/docs/haus/rooms/development/`,
  "/guides/touch-id": `${SITE}/docs/haus/rooms/security/`,
  "/guides/hush": `${SITE}/docs/haus/rooms/focus/`,
  // ⚠️ These two land in different trees on purpose. `rooms/launcher` is the
  // haus *room* — the module, the options, the ⌘Space hand-off from Spotlight
  // — and everything about the app itself moved into pounce's own tree on
  // 2026-08-14, writing a command included.
  "/guides/pounce": `${SITE}/docs/haus/rooms/launcher/`,
  "/guides/pounce-commands": `${SITE}/docs/pounce/writing-commands/`,
  "/guides/theming": `${SITE}/docs/haus/rooms/appearance/`,
  // `staying-in-sync` + `new-mac` were consolidated into one page.
  "/guides/staying-in-sync": `${SITE}/docs/haus/keeping-it-current/`,
  "/guides/new-mac": `${SITE}/docs/haus/keeping-it-current/`,
  "/guides/leaving": `${SITE}/docs/haus/leaving/`,

  // Reference.
  "/reference/options": `${SITE}/docs/haus/reference/options/`,
  // The cheatsheet is a desktop's muscle memory, so it went where that
  // desktop's pages did.
  "/reference/keybindings": `${SITE}/desktops/nebelhaus/#keys`,
  "/reference/pounce": `${SITE}/docs/pounce/config/`,
  // The palette page was folded into theming, which is now the appearance room.
  "/reference/palette": `${SITE}/docs/haus/rooms/appearance/`,
  "/reference/haus": `${SITE}/docs/haus/reference/haus/`,
  "/reference/troubleshooting": `${SITE}/docs/haus/reference/troubleshooting/`,

  // Under the hood.
  "/internals/flakes": `${SITE}/docs/haus/internals/flakes/`,
  "/internals/contributing": `${SITE}/docs/haus/internals/contributing/`,

  // The one essay. Its subject — never `git stash` in a worktree, park instead —
  // is a section of the AI room now.
  "/writing/park-not-stash": `${SITE}/docs/haus/rooms/ai/`,

  // The install one-liner, in shell histories and in every README written before
  // 2026-08-14. It lands on `/nebelhaus.sh` directly: hausfold.co deliberately
  // has no `/init.sh`, precisely so this costs one hop instead of two.
  "/init.sh": `${SITE}/nebelhaus.sh`,
};

// The two Worker routes that exist on both sides, so they pass straight through
// with their slug. hausfold.co gates the app names itself; an unknown one 404s
// there rather than here, which keeps one list authoritative instead of two.
const PASSTHROUGH = /^\/(?:download|api\/release)\/[a-z]+$/;

// A year. These are permanent and the origin is going away, so there is nothing
// to re-check — but a finite max-age still beats `immutable` if a destination
// ever has to move again.
const CACHE = "public, max-age=31536000";

const redirect = (location) =>
  new Response(null, { status: 301, headers: { location, "cache-control": CACHE } });

// Lowercase, drop the trailing slash, drop `index.html` — the three shapes the
// old static site answered for one page.
export function normalize(pathname) {
  let p = pathname.toLowerCase();
  if (p.endsWith("/index.html")) p = p.slice(0, -"index.html".length);
  if (p.length > 1 && p.endsWith("/")) p = p.slice(0, -1);
  return p === "/" ? "" : p;
}

export default {
  async fetch(request) {
    const url = new URL(request.url);
    const path = normalize(url.pathname);

    const target = REDIRECTS[path];
    if (target) {
      // Carry the query string through. It matters for exactly one row —
      // `/init.sh?ref=<tag>`, the pin the docs showed for months — and costs
      // nothing on the rest. (The tag those docs printed, `v2026.07.18`, was
      // never a real haus release; the test below asserts the redirect target,
      // which is true of any ref, real or not.)
      return redirect(url.search ? `${target}${url.search}` : target);
    }

    // Query carried here too, for the same reason and none of its own: nothing
    // reads a query on these two today, and an asymmetry between the branches is
    // the kind of thing a later reader has to test to believe.
    if (PASSTHROUGH.test(path)) return redirect(`${SITE}${path}${url.search}`);

    // Everything else — the old build's hashed CSS, the stills, the social card,
    // a typo — 404s honestly rather than being swept to the homepage.
    //
    // ⚠️ Deliberately NOT cached for a year like the redirects: Cloudflare
    // edge-caches 404s, and a missing row found after the fact would then be
    // unfixable for that long at whichever colo saw it first.
    return new Response(`moved — https://hausfold.co\n`, {
      status: 404,
      headers: { "content-type": "text/plain; charset=utf-8", "cache-control": "public, max-age=300" },
    });
  },
};

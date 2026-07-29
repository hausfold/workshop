// Unit tests for worker.js — the nebelhaus.com Worker, which is the `curl | bash`
// install front door. The security-critical surface is ref validation (no path
// traversal into raw.githubusercontent.com) and the latestRef() fallback chain,
// so those get the most attention here.
//
// The worker only touches two globals we don't get for free in Node: `fetch`
// (GitHub API + raw content) and `caches` (the ~1h latest-release cache). We
// stub both per-test so the suite is fast and offline.

import { describe, it, expect, beforeEach, vi } from 'vitest';
import worker from '../worker.js';

const RELEASE_KEY = 'https://nebelhaus.com/__latest_release';

// A minimal stand-in for Cloudflare's `caches.default`. Stores the cached ref
// as a string and hands back a fresh Response each match (Response bodies are
// single-use, so we can't stash the Response object itself).
function makeCaches() {
  const store = new Map();
  return {
    _store: store,
    default: {
      async match(req) {
        const url = typeof req === 'string' ? req : req.url;
        return store.has(url) ? new Response(store.get(url)) : undefined;
      },
      async put(req, res) {
        const url = typeof req === 'string' ? req : req.url;
        store.set(url, await res.text());
      },
    },
  };
}

// Build a fetch stub from a list of { match, ... } routes. First substring hit
// wins; an unmatched URL throws so tests can't silently pass on a stray fetch.
function makeFetch(routes) {
  return vi.fn(async (input) => {
    const url = typeof input === 'string' ? input : input.url;
    const route = routes.find((r) => url.includes(r.match));
    if (!route) throw new Error(`unexpected fetch: ${url}`);
    if (route.throws) throw new Error('network down');
    const body = route.json !== undefined ? JSON.stringify(route.json) : route.body ?? '';
    return new Response(body, { status: route.status ?? 200 });
  });
}

const req = (path) => new Request(`https://nebelhaus.com${path}`);

beforeEach(() => {
  globalThis.caches = makeCaches();
  vi.restoreAllMocks();
});

describe('/init.sh ref validation (path-traversal guard)', () => {
  // These are the guards that keep a curl|bash endpoint from being pointed at
  // an arbitrary path. Each must yield a 400 and must NOT fetch bootstrap.sh.
  const BAD_REFS = [
    ['dot-dot traversal', '..'],
    ['embedded traversal', 'v1..2'],
    ['slash / nested path', 'a/b'],
    ['leading slash', '/etc/passwd'],
    ['space', 'v1 0'],
    ['shell metachars', 'v1;rm'],
  ];

  for (const [label, ref] of BAD_REFS) {
    it(`rejects ${label} with 400`, async () => {
      globalThis.fetch = makeFetch([{ match: 'raw.githubusercontent.com', body: 'BOOT' }]);
      const res = await worker.fetch(req(`/init.sh?ref=${encodeURIComponent(ref)}`), {});
      expect(res.status).toBe(400);
      expect(globalThis.fetch).not.toHaveBeenCalled();
    });
  }

  it('accepts a well-formed tag and proxies bootstrap.sh', async () => {
    globalThis.fetch = makeFetch([
      { match: 'raw.githubusercontent.com/nebelhaus/nebelhaus/v1.2.3/bootstrap.sh', body: '#!/bin/bash\n' },
    ]);
    const res = await worker.fetch(req('/init.sh?ref=v1.2.3'), {});
    expect(res.status).toBe(200);
    expect(res.headers.get('x-nebelhaus-ref')).toBe('v1.2.3');
    expect(await res.text()).toBe('#!/bin/bash\n');
  });
});

describe('latestRef() fallback chain', () => {
  it('env.REF hard-pin wins without any fetch or cache read', async () => {
    globalThis.fetch = makeFetch([
      { match: 'raw.githubusercontent.com/nebelhaus/nebelhaus/v9.9.9/bootstrap.sh', body: 'PINNED' },
    ]);
    const res = await worker.fetch(req('/init.sh'), { REF: 'v9.9.9' });
    expect(res.headers.get('x-nebelhaus-ref')).toBe('v9.9.9');
    // API was never consulted.
    expect(globalThis.fetch.mock.calls.every(([u]) => !String(u).includes('api.github.com'))).toBe(true);
  });

  it('resolves and caches the latest release tag from the GitHub API', async () => {
    globalThis.fetch = makeFetch([
      { match: 'api.github.com', json: { tag_name: 'v2.0.0' } },
      { match: 'raw.githubusercontent.com/nebelhaus/nebelhaus/v2.0.0/bootstrap.sh', body: 'LATEST' },
    ]);
    const res = await worker.fetch(req('/init.sh'), {});
    expect(res.headers.get('x-nebelhaus-ref')).toBe('v2.0.0');
    expect(globalThis.caches._store.get(RELEASE_KEY)).toBe('v2.0.0');
  });

  it('serves a cached ref without hitting the API', async () => {
    globalThis.caches._store.set(RELEASE_KEY, 'v1.5.0');
    globalThis.fetch = makeFetch([
      { match: 'raw.githubusercontent.com/nebelhaus/nebelhaus/v1.5.0/bootstrap.sh', body: 'CACHED' },
    ]);
    const res = await worker.fetch(req('/init.sh'), {});
    expect(res.headers.get('x-nebelhaus-ref')).toBe('v1.5.0');
    expect(globalThis.fetch.mock.calls.some(([u]) => String(u).includes('api.github.com'))).toBe(false);
  });

  it('falls back to main when the API returns a non-2xx', async () => {
    globalThis.fetch = makeFetch([
      { match: 'api.github.com', status: 403, body: 'rate limited' },
      { match: 'raw.githubusercontent.com/nebelhaus/nebelhaus/main/bootstrap.sh', body: 'MAIN' },
    ]);
    const res = await worker.fetch(req('/init.sh'), {});
    expect(res.headers.get('x-nebelhaus-ref')).toBe('main');
  });

  it('falls back to main when the API throws (network hiccup)', async () => {
    globalThis.fetch = makeFetch([
      { match: 'api.github.com', throws: true },
      { match: 'raw.githubusercontent.com/nebelhaus/nebelhaus/main/bootstrap.sh', body: 'MAIN' },
    ]);
    const res = await worker.fetch(req('/init.sh'), {});
    expect(res.headers.get('x-nebelhaus-ref')).toBe('main');
  });

  it('falls back to main when the API returns an unsafe tag_name', async () => {
    // A compromised/garbage release tag must not become a fetch path.
    globalThis.fetch = makeFetch([
      { match: 'api.github.com', json: { tag_name: '../../evil' } },
      { match: 'raw.githubusercontent.com/nebelhaus/nebelhaus/main/bootstrap.sh', body: 'MAIN' },
    ]);
    const res = await worker.fetch(req('/init.sh'), {});
    expect(res.headers.get('x-nebelhaus-ref')).toBe('main');
    expect(globalThis.caches._store.has(RELEASE_KEY)).toBe(false);
  });
});

describe('serveInitScript upstream handling', () => {
  it('returns 502 when bootstrap.sh cannot be fetched', async () => {
    globalThis.fetch = makeFetch([
      { match: 'raw.githubusercontent.com', status: 404, body: 'not found' },
    ]);
    const res = await worker.fetch(req('/init.sh?ref=v1.0.0'), {});
    expect(res.status).toBe(502);
    expect(await res.text()).toContain('v1.0.0');
  });

  it('sets caching headers on a successful proxy', async () => {
    globalThis.fetch = makeFetch([{ match: 'raw.githubusercontent.com', body: 'OK' }]);
    const res = await worker.fetch(req('/init.sh?ref=v1.0.0'), {});
    expect(res.headers.get('cache-control')).toBe('public, max-age=300');
    expect(res.headers.get('content-type')).toContain('text/plain');
  });
});

describe('/download and /api/release', () => {
  const PONCE_RELEASE = {
    tag_name: 'v2026.07.29',
    published_at: '2026-07-29T00:00:00Z',
    assets: [
      { name: 'pounce-v2026.07.29-macos.tar.gz', size: 701478, browser_download_url: 'https://github.com/nebelhaus/pounce/releases/download/v2026.07.29/pounce-v2026.07.29-macos.tar.gz' },
    ],
  };

  it('302s /download/<app> to the latest macOS asset', async () => {
    globalThis.fetch = makeFetch([
      { match: 'api.github.com/repos/nebelhaus/pounce/releases/latest', json: PONCE_RELEASE },
    ]);
    const res = await worker.fetch(req('/download/pounce'), {});
    expect(res.status).toBe(302);
    expect(res.headers.get('location')).toBe(PONCE_RELEASE.assets[0].browser_download_url);
  });

  it('picks the -macos asset over other assets', async () => {
    globalThis.fetch = makeFetch([
      {
        match: 'api.github.com/repos/nebelhaus/trill/releases/latest',
        json: {
          tag_name: 'v1',
          assets: [
            { name: 'checksums.txt', size: 10, browser_download_url: 'https://example.com/checksums.txt' },
            { name: 'trill-v1-macos.zip', size: 99, browser_download_url: 'https://example.com/trill-v1-macos.zip' },
          ],
        },
      },
    ]);
    const res = await worker.fetch(req('/download/trill'), {});
    expect(res.headers.get('location')).toBe('https://example.com/trill-v1-macos.zip');
  });

  it('falls back to the releases page when the API is down', async () => {
    globalThis.fetch = makeFetch([{ match: 'api.github.com', throws: true }]);
    const res = await worker.fetch(req('/download/perch'), {});
    expect(res.status).toBe(302);
    expect(res.headers.get('location')).toBe('https://github.com/nebelhaus/perch/releases/latest');
  });

  it('serves release metadata as JSON and caches it', async () => {
    globalThis.fetch = makeFetch([
      { match: 'api.github.com/repos/nebelhaus/pounce/releases/latest', json: PONCE_RELEASE },
    ]);
    const res = await worker.fetch(req('/api/release/pounce'), {});
    expect(res.status).toBe(200);
    const meta = await res.json();
    expect(meta.tag).toBe('v2026.07.29');
    expect(meta.size).toBe(701478);
    expect(globalThis.caches._store.has('https://nebelhaus.com/__release/pounce')).toBe(true);

    // Second hit is served from cache — no API call.
    globalThis.fetch = makeFetch([]);
    const cached = await worker.fetch(req('/api/release/pounce'), {});
    expect((await cached.json()).tag).toBe('v2026.07.29');
  });

  it('returns 502 JSON when metadata is unavailable', async () => {
    globalThis.fetch = makeFetch([{ match: 'api.github.com', status: 403, body: 'rate limited' }]);
    const res = await worker.fetch(req('/api/release/pounce'), {});
    expect(res.status).toBe(502);
  });

  it('does not treat unknown apps as downloadable', async () => {
    globalThis.fetch = makeFetch([]);
    const res = await worker.fetch(req('/download/nebelhaus'), {});
    expect(res.status).toBe(404); // falls through to the assets/404 path
    expect(globalThis.fetch).not.toHaveBeenCalled();
  });
});

describe('router', () => {
  it('delegates non-init requests to the ASSETS binding', async () => {
    const assets = { fetch: vi.fn(async () => new Response('site', { status: 200 })) };
    const res = await worker.fetch(req('/guides/theming'), { ASSETS: assets });
    expect(assets.fetch).toHaveBeenCalledOnce();
    expect(await res.text()).toBe('site');
  });

  it('returns a 404 text fallback when ASSETS is absent', async () => {
    const res = await worker.fetch(req('/whatever'), {});
    expect(res.status).toBe(404);
    expect(await res.text()).toContain('github.com/nebelhaus');
  });
});

// Unit tests for worker.js — the nebelhaus.com 301 map.
//
// The suite that used to live here tested a Worker that fetched things: the
// `curl | bash` proxy, the release lookups, their caches. None of that survives
// the retirement (rename plan §5.2) — this Worker fetches nothing, so what's
// worth testing is the table itself.
//
// The load-bearing test is `OLD_URLS`: the frozen list of every URL
// nebelhaus.com ever published, derived from the old Starlight sidebar plus the
// three non-docs routes. The site that served them is deleted, so that list can
// never grow — which makes it a real completeness gate rather than a copy of the
// map. A row dropped by accident fails here.

import { describe, it, expect } from 'vitest';
import worker, { REDIRECTS, normalize } from '../worker.js';

const req = (path) => new Request(`https://nebelhaus.com${path}`);
const loc = async (path) => (await worker.fetch(req(path))).headers.get('location');

// Every page the old site published. Order follows the old sidebar so a human
// can diff it against `src/lib/sidebar.js` in the history if they ever need to.
const OLD_URLS = [
  '/',
  '/pounce',
  '/perch',
  '/llms.txt',
  '/llms-full.txt',
  '/start/what-is-nebelhaus',
  '/start/install',
  '/start/first-run',
  '/start/the-family',
  '/guides/making-it-yours',
  '/guides/sharing-a-rice',
  '/guides/ai-agent',
  '/guides/adding-apps',
  '/guides/window-management',
  '/guides/the-bar',
  '/guides/the-shell',
  '/guides/claude-agents',
  '/guides/touch-id',
  '/guides/hush',
  '/guides/pounce',
  '/guides/pounce-commands',
  '/guides/theming',
  '/guides/staying-in-sync',
  '/guides/new-mac',
  '/guides/leaving',
  '/reference/options',
  '/reference/keybindings',
  '/reference/pounce',
  '/reference/palette',
  '/reference/haus',
  '/reference/troubleshooting',
  '/internals/flakes',
  '/internals/contributing',
  '/writing/park-not-stash',
  '/init.sh',
];

describe('the map covers the old site, exactly', () => {
  it('has a row for every URL nebelhaus.com published', () => {
    const missing = OLD_URLS.filter((u) => !(normalize(u) in REDIRECTS));
    expect(missing).toEqual([]);
  });

  it('has no row the old site never published', () => {
    const extra = Object.keys(REDIRECTS).filter((k) => !OLD_URLS.map(normalize).includes(k));
    expect(extra).toEqual([]);
  });

  it('sends everything to hausfold.co and nothing back here', () => {
    for (const [from, to] of Object.entries(REDIRECTS)) {
      expect(to, from).toMatch(/^https:\/\/hausfold\.co\//);
      expect(to, from).not.toMatch(/nebelhaus\.com/);
    }
  });

  it('keeps hausfold.co\'s trailing slash on pages, and omits it where there is no page', () => {
    const noSlash = Object.entries(REDIRECTS).filter(([, to]) => !to.endsWith('/'));
    expect(noSlash.map(([from]) => from).sort()).toEqual(
      ['/init.sh', '/llms-full.txt', '/llms.txt'].sort(),
    );
  });
});

describe('redirecting', () => {
  it('301s a docs page to its rebuilt equivalent', async () => {
    const res = await worker.fetch(req('/guides/pounce'));
    expect(res.status).toBe(301);
    expect(res.headers.get('location')).toBe('https://hausfold.co/docs/haus/rooms/launcher/');
  });

  // The [assets] binding used to 307 the no-slash form onto the slash form. It
  // is gone, so both spellings have to land here — the same lesson
  // hausfold.co's `_redirects` learned on 2026-08-14.
  it('answers both spellings, and index.html', async () => {
    const want = 'https://hausfold.co/docs/haus/rooms/bar/';
    expect(await loc('/guides/the-bar')).toBe(want);
    expect(await loc('/guides/the-bar/')).toBe(want);
    expect(await loc('/guides/the-bar/index.html')).toBe(want);
    expect(await loc('/GUIDES/The-Bar/')).toBe(want);
  });

  it('sends the root to the root', async () => {
    expect(await loc('/')).toBe('https://hausfold.co/');
  });

  // The whole point of hausfold.co having no /init.sh: one hop, not two.
  it('lands /init.sh on /nebelhaus.sh directly', async () => {
    expect(await loc('/init.sh')).toBe('https://hausfold.co/nebelhaus.sh');
  });

  it('carries ?ref= through, which is the one query the docs ever showed', async () => {
    expect(await loc('/init.sh?ref=v2026.07.18')).toBe(
      'https://hausfold.co/nebelhaus.sh?ref=v2026.07.18',
    );
  });

  it('passes the two Worker routes through with their slug', async () => {
    expect(await loc('/download/perch')).toBe('https://hausfold.co/download/perch');
    expect(await loc('/api/release/pounce')).toBe('https://hausfold.co/api/release/pounce');
  });

  it('caches the redirects hard', async () => {
    const res = await worker.fetch(req('/reference/options'));
    expect(res.headers.get('cache-control')).toContain('max-age=31536000');
  });
});

describe('everything else', () => {
  it('404s an old asset rather than sweeping it to the homepage', async () => {
    for (const path of ['/social/og.png', '/media/stills/S3.png', '/_astro/index.abc123.css']) {
      const res = await worker.fetch(req(path));
      expect(res.status, path).toBe(404);
      expect(res.headers.get('location'), path).toBeNull();
    }
  });

  it('404s a path that was never a page', async () => {
    expect((await worker.fetch(req('/guides/'))).status).toBe(404);
    expect((await worker.fetch(req('/nope'))).status).toBe(404);
  });

  // A year-long 404 at an edge colo is how a missing row becomes unfixable.
  it('does not cache a 404 for a year', async () => {
    const res = await worker.fetch(req('/nope'));
    expect(res.headers.get('cache-control')).not.toContain('31536000');
  });

  it('does not proxy anything — the ?ref= hole closes by deletion', async () => {
    const fetchSpy = () => {
      throw new Error('the redirect map must not fetch');
    };
    const original = globalThis.fetch;
    globalThis.fetch = fetchSpy;
    try {
      const res = await worker.fetch(req('/init.sh?ref=deadbeefdeadbeefdeadbeefdeadbeefdeadbeef'));
      expect(res.status).toBe(301);
    } finally {
      globalThis.fetch = original;
    }
  });
});

// /llms.txt — this site's table of contents, written for a model.
//
// The convention (llmstxt.org): an H1, a one-line blockquote summary, then link
// lists with a short description each, so a model can decide what to fetch
// instead of scraping the whole site. The rice's own Claude skill doesn't need
// this — it ships the option reference on disk, generated from the revision the
// machine pinned. This is for everything that skill can't reach: any other AI
// tool, and anyone asking about nebelhaus BEFORE they've installed it (no rice,
// no skill).
//
// Order and grouping come from src/lib/sidebar.js, the same array the human
// sidebar renders from — and a docs page missing from that array fails this
// build rather than silently vanishing from the index.
import { getCollection } from 'astro:content';
import { sidebar } from '../lib/sidebar.js';

const SITE = 'https://nebelhaus.com';

// Pages outside the docs collection — the landing page and the per-product
// pages, which a model asking "what is trill" should still be able to find.
const EXTRA = [
  { label: 'nebelhaus', path: '/', description: 'The project landing page.' },
  { label: 'pounce', path: '/pounce/', description: 'The command palette — product page.' },
  { label: 'trill', path: '/guides/trill/', description: 'The Messages client — archived, no longer developed. Guide kept for anyone still running it.' },
  { label: 'perch', path: '/perch/', description: 'The notch file shelf — product page.' },
];

export async function GET() {
  const docs = await getCollection('docs');
  const byId = new Map(docs.map((d) => [d.id, d]));

  // Every docs page must be reachable from the sidebar. If one isn't, that's a
  // page nobody links to — surface it at build time instead of shipping an
  // index that quietly omits it.
  const listed = new Set(sidebar.flatMap((g) => g.items.map((i) => i.slug)));
  const orphans = docs.map((d) => d.id).filter((id) => !listed.has(id));
  if (orphans.length) {
    throw new Error(
      `llms.txt: these docs pages are missing from src/lib/sidebar.js, so they'd be ` +
        `absent from both the sidebar and the index: ${orphans.join(', ')}`,
    );
  }

  const line = (label: string, path: string, description?: string) =>
    `- [${label}](${SITE}${path})${description ? `: ${description}` : ''}`;

  const sections = sidebar
    .map((group) => {
      const items = group.items
        .map((item) => {
          const entry = byId.get(item.slug);
          return line(item.label, `/${item.slug}/`, entry?.data.description);
        })
        .join('\n');
      return `## ${group.label}\n\n${items}`;
    })
    .join('\n\n');

  const body = `# nebelhaus

> An opinionated macOS rice, raised in the fog: silver-grey, keyboard-first, and reproducible. The whole machine — system settings, window tiling, menu bar, shell, launcher — is declarative Nix (nix-darwin), consumed as a pinned flake input. One \`curl\` scaffolds a personal config; one \`haus rebuild\` applies it; \`haus rollback\` undoes it atomically.

Orienting facts, so you don't have to infer them:

- A user's own config is a thin flake at \`~/.config/nix\` that pins the rice. The only file they edit is \`hosts/<hostname>/default.nix\`, where they set \`nebelhaus.*\` options. They never edit the rice itself.
- \`haus\` is the end-user CLI: \`rebuild\`, \`update\`, \`rollback\`, \`generations\`, \`status\`, \`edit\`, \`doctor\`. It always builds before it switches, so a broken config never reaches the running system.
- The options reference below is generated from the rice's module system, so it is authoritative — but it documents the LATEST rice. A given machine is pinned to a revision and may not have the newest options; \`haus status\` says how far behind it is.
- On an installed machine the rice ships a Claude Code skill at \`~/.claude/skills/nebelhaus\` whose option reference is generated from that machine's own pinned revision. Prefer it over this site when advising on a specific machine.
- macOS only, Apple Silicon only.

${sections}

## Other pages

${EXTRA.map((e) => line(e.label, e.path, e.description)).join('\n')}

## Optional

- [llms-full.txt](${SITE}/llms-full.txt): every page above, inlined as one document.
- [The rice itself](https://github.com/nebelhaus/nebelhaus): the source of every option on this site.
`;

  return new Response(body, {
    headers: { 'content-type': 'text/plain; charset=utf-8' },
  });
}

// /llms-full.txt — every documentation page, inlined as one plain-text document.
//
// The companion to /llms.txt: that one is an index to fetch selectively from,
// this one is the whole corpus for a tool that would rather read once. Same
// order, same source, so the two can't describe different sites.
//
// The pages are MDX. Rather than render them to HTML and strip tags back off, we
// serve the source with the Starlight component scaffolding removed — imports
// dropped, standalone component tags unwrapped to their content, with any title
// or label attribute promoted to a bold line so the framing survives. What's
// left is the markdown the author actually wrote.
import { getCollection } from 'astro:content';
import { sidebar } from '../lib/sidebar.js';

const SITE = 'https://nebelhaus.com';

// Starlight components used across these pages. Their tags carry no meaning a
// reader needs; their `title`/`label` attributes do.
const COMPONENTS = 'Aside|Steps|Tabs|TabItem|Card|CardGrid|LinkCard|Badge|Icon|FileTree';

function demdx(source: string): string {
  return (
    source
      // `import { Aside } from '@astrojs/starlight/components';`
      .replace(/^import\s.+?from\s+['"].+?['"];?\s*$/gm, '')
      // A component tag alone on its line: keep the human-readable attribute.
      .replace(
        new RegExp(`^\\s*<(?:${COMPONENTS})\\b([^>]*)>\\s*$`, 'gm'),
        (_m, attrs: string) => {
          const named = /(?:title|label)=["']([^"']+)["']/.exec(attrs);
          return named ? `**${named[1]}**\n` : '';
        },
      )
      .replace(new RegExp(`^\\s*</(?:${COMPONENTS})>\\s*$`, 'gm'), '')
      // Self-closing ones carry their whole payload in attributes.
      .replace(
        new RegExp(`^\\s*<(?:${COMPONENTS})\\b([^>]*)/>\\s*$`, 'gm'),
        (_m, attrs: string) => {
          const named = /(?:title|label)=["']([^"']+)["']/.exec(attrs);
          return named ? `**${named[1]}**\n` : '';
        },
      )
      // Collapse the blank runs those removals leave behind.
      .replace(/\n{3,}/g, '\n\n')
      .trim()
  );
}

export async function GET() {
  const docs = await getCollection('docs');
  const byId = new Map(docs.map((d) => [d.id, d]));

  const pages = sidebar.flatMap((group) =>
    group.items.flatMap((item) => {
      const entry = byId.get(item.slug);
      if (!entry) return [];
      const { title, description } = entry.data;
      return [
        [
          `# ${title}`,
          '',
          `Source: ${SITE}/${item.slug}/`,
          description ? `\n${description}` : '',
          '',
          demdx(entry.body ?? ''),
        ].join('\n'),
      ];
    }),
  );

  const body = `# nebelhaus — complete documentation

Every page of https://nebelhaus.com, in sidebar order. The index with
per-page descriptions is at ${SITE}/llms.txt.

This documents the LATEST rice. A machine is pinned to a revision and may not
have the newest options — \`haus status\` says how far behind it is, and an
installed machine carries its own generated reference at
~/.claude/skills/haus/references/options.md.

---

${pages.join('\n\n---\n\n')}
`;

  return new Response(body, {
    headers: { 'content-type': 'text/plain; charset=utf-8' },
  });
}

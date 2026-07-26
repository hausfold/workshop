#!/usr/bin/env node
// Renders reference/options.md from the rice's own module system.
//
// This page used to be 389 hand-written lines, and hand-maintenance showed:
// `nebelhaus.git.shellAliases` was documented TWICE with two different
// descriptions, and only 33 of the rice's 71 options appeared at all. Then the
// options.nix split took the source from one file to eleven, which would have
// made honest hand-maintenance hopeless.
//
// So the rice exposes `nix build .#options-json` (nixosOptionsDoc over the
// per-room options files — pure evaluation, no darwin system, runs on Linux CI)
// and this script renders it. The module system is the single source of truth;
// a description edit lands in the rice and the page follows.
//
// Narrative guides stay hand-written. This is the REFERENCE only.
//
// Usage:
//   node web/scripts/gen-options.mjs --rice <nebelhaus-checkout>
//   node web/scripts/gen-options.mjs --rice <nebelhaus-checkout> --check
//
// Needs `nix` on PATH.

import { execFileSync } from 'node:child_process';
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const PAGE = join(here, '../src/content/docs/reference/options.md');
const REPO = 'https://github.com/nebelhaus/nebelhaus/blob/main';

const args = process.argv.slice(2);
const check = args.includes('--check');
const riceIdx = args.indexOf('--rice');
const rice = riceIdx >= 0 ? args[riceIdx + 1] : process.env.RICE_DIR;
if (!rice || !existsSync(rice)) {
  console.error('usage: gen-options.mjs --rice <nebelhaus-checkout> [--check]');
  process.exit(2);
}

// ---- pull the option metadata out of the rice -------------------------------
const outPath = execFileSync(
  'nix',
  ['build', '--no-link', '--print-out-paths', `${resolve(rice)}#options-json`],
  { encoding: 'utf8' },
).trim();
const raw = JSON.parse(readFileSync(join(outPath, 'share/doc/nixos/options.json'), 'utf8'));

const options = Object.entries(raw)
  .filter(([name]) => name.startsWith('nebelhaus.'))
  .map(([name, o]) => ({ name, ...o }));

// ---- grouping ---------------------------------------------------------------
// Second path segment is the room/feature: nebelhaus.git.name -> "git".
const groupOf = (name) => name.split('.')[1];

// Reading order, roughly "identity → look → rooms → policy". Anything new that
// isn't listed lands alphabetically at the end rather than vanishing, so a
// freshly added option is never silently dropped from the page.
const ORDER = [
  'git', 'apps', 'theme', 'fonts', 'hearth', 'claude', 'accessibility',
  'prowl', 'sill', 'tour', 'pounce', 'trill', 'hush', 'snippets',
  'secrets', 'homebrew',
];
const BLURB = {
  git: 'Your commit identity — set your own. It stays in [your host file](/internals/flakes/#your-config-is-a-thin-consumer).',
  apps: 'The shared app roster: one entry per app, driving the launcher key, its workspace, the bar pill, the cheatsheet, and optionally its Homebrew cask.',
  theme: 'Colour and wallpaper.',
  fonts: 'The terminal font. The bar keeps its own font at its own tuned sizes.',
  hearth: 'The shell and terminal experience.',
  claude: 'Claude Code integration.',
  accessibility:
    'macOS accessibility keys the rice can actually apply. These write to a TCC-protected domain, so they take effect only when the app you run the rebuild from holds Full Disk Access — otherwise the rice warns and moves on.',
  prowl: 'Tiling window management and the Caps-Lock leader launcher.',
  sill: 'The menu bar, and which pills it draws.',
  tour: 'The first-run tutor.',
  pounce: 'The ⌘Space command palette.',
  trill: 'The Messages client.',
  hush: 'One quiet switch: Do Not Disturb, optional Slack status, and your hooks.',
  snippets: 'Text expansion via espanso.',
  secrets: 'Where secret values come from on this machine.',
  homebrew: 'How rebuilds treat Homebrew packages you did not declare.',
};

const groups = new Map();
for (const opt of options) {
  const g = groupOf(opt.name);
  if (!groups.has(g)) groups.set(g, []);
  groups.get(g).push(opt);
}
const ordered = [
  ...ORDER.filter((g) => groups.has(g)),
  ...[...groups.keys()].filter((g) => !ORDER.includes(g)).sort(),
];

// ---- rendering --------------------------------------------------------------
const literal = (v) => (v && typeof v === 'object' && 'text' in v ? v.text : undefined);

function renderDefault(opt) {
  const d = literal(opt.default);
  if (d === undefined) return 'no default';
  const oneLine = d.replace(/\s+/g, ' ').trim();
  return oneLine.length > 60 ? 'see below' : `default \`${oneLine}\``;
}

function renderOption(opt) {
  const lines = [`### \`${opt.name}\``, '', `\`${opt.type}\` · ${renderDefault(opt)}`, ''];
  // Descriptions are authored as Nix multi-line strings; their hard wrapping is
  // already sensible prose, so pass it through untouched.
  lines.push((opt.description ?? '').trimEnd(), '');
  const ex = literal(opt.example);
  if (ex !== undefined) {
    lines.push('Example:', '', '```nix', ex.trimEnd(), '```', '');
  }
  const decl = opt.declarations?.[0];
  if (decl) lines.push(`<small>Declared in [\`${decl}\`](${REPO}/${decl}).</small>`, '');
  return lines.join('\n');
}

const body = ordered
  .map((g) => {
    const head = [`## nebelhaus.${g}`, ''];
    if (BLURB[g]) head.push(BLURB[g], '', '');
    const opts = groups.get(g).sort((a, b) => a.name.localeCompare(b.name));
    return head.join('\n') + opts.map(renderOption).join('\n');
  })
  .join('\n');

const page = `---
title: nebelhaus.* options
description: Every option you can set in your host file — types, defaults, and what each one changes.
tableOfContents:
  maxHeadingLevel: 2
---

<!-- GENERATED FILE — do not edit by hand.

     Rendered from the rice's own module system by web/scripts/gen-options.mjs.
     To change an option's description, edit its declaration in the rice
     (modules/<room>/options.nix) and regenerate:

         node web/scripts/gen-options.mjs --rice ../nebelhaus

     CI re-renders this and fails if it differs, so a hand edit here is
     guaranteed to be reverted. -->

These are the \`nebelhaus.*\` options you set in your host file at
\`~/.config/nix/hosts/<hostname>/default.nix\`. Everything here is optional
unless noted; the defaults are a complete, working system.

Apply changes with \`haus rebuild\`. Each option lists its **type** and
**default** under its name, and links to the file that declares it.

${body}`;

// ---- write or check ---------------------------------------------------------
const current = existsSync(PAGE) ? readFileSync(PAGE, 'utf8') : '';
if (check) {
  if (current === page) {
    console.log(`options reference is current (${options.length} options).`);
    process.exit(0);
  }
  console.error(
    'options reference is STALE.\n\n' +
      'The rice\'s options changed and this page was not regenerated. Run:\n' +
      '  node web/scripts/gen-options.mjs --rice <nebelhaus-checkout>\n' +
      'and commit the result. Do not edit the page by hand.\n',
  );
  process.exit(1);
}
writeFileSync(PAGE, page);
console.log(`wrote ${PAGE} (${options.length} options, ${ordered.length} groups).`);

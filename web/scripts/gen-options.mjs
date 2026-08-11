#!/usr/bin/env node
// Renders reference/options.md from the rice's own module system.
//
// This page used to be 389 hand-written lines, and hand-maintenance showed:
// `nebelhaus.git.shellAliases` was documented TWICE with two different
// descriptions, and only 33 of the rice's 71 options appeared at all. Then the
// options.nix split took the source from one file to eleven, which would have
// made honest hand-maintenance hopeless.
//
// So the rice renders its own module system to JSON (nixosOptionsDoc over the
// per-room options files) and COMMITS it at `docs/site-data/`, and this script
// reads those files. The module system is the single source of truth; a
// description edit lands in the rice and the page follows.
//
// Narrative guides stay hand-written. This is the REFERENCE only.
//
// Usage:
//   node web/scripts/gen-options.mjs --rice <rice-checkout>
//   node web/scripts/gen-options.mjs --rice <rice-checkout> --check
//
// Needs a rice CHECKOUT and nothing else — no Nix, no flake pin, no nixpkgs
// fetch. It used to shell out to `nix build .#options-json`, which meant this
// repo's CI installed Nix to check a Markdown page; that stops being acceptable
// when the docs move to their own repo (notes/hausfold-rename.md §5.1). The
// rice's `site-data-current` flake check is what keeps the committed copy
// honest, on the side of the boundary that owns the derivation.

import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const PAGE = join(here, '../src/content/docs/reference/options.md');
const REPO = 'https://github.com/hausfold/haus/blob/main';

const args = process.argv.slice(2);
const check = args.includes('--check');
const riceIdx = args.indexOf('--rice');
const rice = riceIdx >= 0 ? args[riceIdx + 1] : process.env.RICE_DIR;
if (!rice || !existsSync(rice)) {
  console.error('usage: gen-options.mjs --rice <rice-checkout> [--check]');
  process.exit(2);
}

// ---- pull the option metadata out of the rice -------------------------------
// `docs/site-data/` is the rice's published surface: generated from its module
// system, committed, and pinned by its own `site-data-current` flake check. A
// checkout is all we need.
//
// Absence is a hard failure, deliberately, with no `nix build` fallback. The
// only way to be here is a rice older than nebelhaus#268 — and a fallback for
// that would be a code path CI can never exercise, kept alive against a
// checkout nobody has. The message says which side to fix.
const SITE_DATA = join(rice, 'docs/site-data');
function riceFile(name, why) {
  const path = join(SITE_DATA, name);
  if (!existsSync(path)) {
    console.error(
      `The rice checkout at ${rice} has no \`docs/site-data/${name}\`.\n\n` +
        `${why}\n\n` +
        'That directory is generated and committed by the rice (`nix build .#site-data`).\n' +
        'The checkout predates nebelhaus#268 — update it (CI pulls\n' +
        'hausfold/haus main) and re-run.\n',
    );
    process.exit(1);
  }
  return JSON.parse(readFileSync(path, 'utf8'));
}

const raw = riceFile('options.json', 'That file is what this page is rendered from.');

// Reading order and a one-line blurb per room. The module system can't produce
// these — it has no notion of "identity first, policy last", and nowhere to hang
// a sentence about a whole namespace — so the rice carries them as data
// (modules/options-groups.nix) and publishes them beside options.json.
//
// They used to live in this file, where they covered 16 of the rice's 23 rooms:
// agents, collar, developer, displays, keys, perch and ui fell off the end of
// the page alphabetically, blurbless, and nobody noticed because a missing blurb
// looks exactly like a blurb nobody wrote. The rice's own host template renders
// from the same file, so the two orderings can't disagree either.
const GROUPS = riceFile(
  'groups.json',
  'That file carries the per-room order and blurbs this page is laid out with.',
);

// The option namespace is `haus.*`. This used to also detect the pre-rename
// `nebelhaus.*`, for the window where the two repos hadn't landed the rename in
// the same commit; that window closed, and `docs/site-data/` filters on `haus.`
// at the source, so a rice that spelled it the old way would ship no site-data
// at all and never reach this line.
//
// The floor stays anyway. A generated cross-repo artifact fails by EMPTYING,
// not by erroring (workshop#266: an options page with a title, an intro and
// zero options, which the Monday cron would have opened as a routine PR). The
// rice carries the same floor in modules/site-data.nix; this is the other side
// of the boundary, where an empty page would actually be committed.
const NS = 'haus.';
const PREFIX = 'haus';
if (!Object.keys(raw).some((name) => name.startsWith(NS))) {
  console.error(
    'options.json carries no `haus.*` keys.\n\n' +
      'That is a broken render, not a rice with no options — most likely this\n' +
      'script and the rice disagree about the option namespace. Fix the prefix\n' +
      'here rather than committing an empty page.\n',
  );
  process.exit(1);
}

const options = Object.entries(raw)
  .filter(([name]) => name.startsWith(NS))
  .map(([name, o]) => ({ name, ...o }));

// ---- grouping ---------------------------------------------------------------
// Second path segment is the room/feature: haus.git.name -> "git".
const groupOf = (name) => name.split('.')[1];

const groups = new Map();
for (const opt of options) {
  const g = groupOf(opt.name);
  if (!groups.has(g)) groups.set(g, []);
  groups.get(g).push(opt);
}
// A room the rice hasn't given an order lands alphabetically after the ones it
// has, rather than vanishing — a freshly added room is on the page the day it
// exists, and gets its blurb whenever someone writes one.
const orderOf = (g) => GROUPS[g]?.order ?? Number.MAX_SAFE_INTEGER;
const ordered = [...groups.keys()].sort(
  (a, b) => orderOf(a) - orderOf(b) || a.localeCompare(b),
);

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
    const head = [`## ${PREFIX}.${g}`, ''];
    const blurb = GROUPS[g]?.blurb;
    if (blurb) head.push(blurb, '', '');
    const opts = groups.get(g).sort((a, b) => a.name.localeCompare(b.name));
    return head.join('\n') + opts.map(renderOption).join('\n');
  })
  .join('\n');

const page = `---
title: ${PREFIX}.* options
description: Every option you can set in your host file — types, defaults, and what each one changes.
tableOfContents:
  maxHeadingLevel: 2
---

<!-- GENERATED FILE — do not edit by hand.

     Rendered from the rice's own module system by web/scripts/gen-options.mjs.
     To change an option's description, edit its declaration in the rice
     (modules/<room>/options.nix) and regenerate:

         node web/scripts/gen-options.mjs --rice ../haus

     CI re-renders this and fails if it differs, so a hand edit here is
     guaranteed to be reverted. -->

These are the \`${PREFIX}.*\` options you set in your host file at
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
      '  node web/scripts/gen-options.mjs --rice <rice-checkout>\n' +
      'and commit the result. Do not edit the page by hand.\n',
  );
  process.exit(1);
}
writeFileSync(PAGE, page);
console.log(`wrote ${PAGE} (${options.length} options, ${ordered.length} groups).`);

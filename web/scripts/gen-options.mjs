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
// The rice must expose `options-json` (nebelhaus#93). It won't on an older
// checkout, and nix's own error for that is a wall of attribute-path guesses
// wrapped in a Node stack trace — so translate it into the one sentence that
// actually helps. This fired for real the first time CI ran, when the rice's
// main hadn't landed the output yet.
let outPath;
try {
  outPath = execFileSync(
    'nix',
    ['build', '--no-link', '--print-out-paths', `${resolve(rice)}#options-json`],
    { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] },
  ).trim();
} catch (err) {
  const stderr = err.stderr?.toString() ?? '';
  if (stderr.includes('does not provide attribute')) {
    console.error(
      `The rice checkout at ${rice} has no \`options-json\` flake output.\n\n` +
        'That output is what this page is rendered from. Either the checkout predates\n' +
        'nebelhaus#93, or it is not the nebelhaus rice at all. Update it (CI pulls\n' +
        "nebelhaus/nebelhaus main) and re-run.\n",
    );
  } else {
    console.error(`\`nix build ${rice}#options-json\` failed:\n\n${stderr}`);
  }
  process.exit(1);
}
const raw = JSON.parse(readFileSync(join(outPath, 'share/doc/nixos/options.json'), 'utf8'));

// Reading order and a one-line blurb per room. The module system can't produce
// these — it has no notion of "identity first, policy last", and nowhere to hang
// a sentence about a whole namespace — so the rice carries them as data
// (modules/options-groups.nix) and ships them beside options.json.
//
// They used to live in this file, where they covered 16 of the rice's 23 rooms:
// agents, collar, developer, displays, keys, perch and ui fell off the end of
// the page alphabetically, blurbless, and nobody noticed because a missing blurb
// looks exactly like a blurb nobody wrote. The rice's own host template renders
// from the same file, so the two orderings can't disagree either.
const GROUPS_PATH = join(outPath, 'share/doc/nixos/groups.json');
if (!existsSync(GROUPS_PATH)) {
  console.error(
    `The rice checkout at ${rice} builds no groups.json beside options.json.\n\n` +
      'That file carries the per-room order and blurbs this page is laid out\n' +
      'with. The checkout predates nebelhaus#184 — update it (CI pulls\n' +
      'nebelhaus/nebelhaus main) and re-run.\n',
  );
  process.exit(1);
}
const GROUPS = JSON.parse(readFileSync(GROUPS_PATH, 'utf8'));

// The option namespace is `haus.*`; `nebelhaus.*` is the pre-rename spelling
// the rice still aliases (nebelhaus/nebelhaus modules/renamed.nix). Detect it
// rather than hardcode it, so this script renders correctly whichever side of
// that rename the pinned rice is on — CI pulls the rice's main, and the two
// repos do not land in the same commit.
//
// The aliases are `visible = false`, so options.json only ever carries ONE of
// the two prefixes; there is no double-count to worry about.
const NS = ['haus.', 'nebelhaus.'].find((p) =>
  Object.keys(raw).some((name) => name.startsWith(p)),
);
if (!NS) {
  console.error(
    'options.json carries no `haus.*` or `nebelhaus.*` keys.\n\n' +
      'That is a broken render, not a rice with no options — most likely this\n' +
      'script and the rice disagree about the option namespace. Fix the prefix\n' +
      'here rather than committing an empty page.\n',
  );
  process.exit(1);
}
const PREFIX = NS.slice(0, -1); // "haus"

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

         node web/scripts/gen-options.mjs --rice ../nebelhaus

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
      '  node web/scripts/gen-options.mjs --rice <nebelhaus-checkout>\n' +
      'and commit the result. Do not edit the page by hand.\n',
  );
  process.exit(1);
}
writeFileSync(PAGE, page);
console.log(`wrote ${PAGE} (${options.length} options, ${ordered.length} groups).`);

/* palette.js — read the palette out of palette.css at build time.
 *
 * The palette reference page used to hardcode every hex in a <Swatch hex="…" />
 * prop, which made it the one surface that could disagree with the CSS actually
 * styling the site. This parses palette.css instead, so the documented value and
 * the rendered value come from the same line of the same file.
 *
 * `?raw` hands us the file's text without also injecting it as a stylesheet —
 * palette.css is imported normally elsewhere (nebelung.css, landing-tokens.css),
 * and that's what does the styling. This is a read, not a second copy.
 *
 * Runs at build time: Astro renders these pages on the server, so nothing here
 * reaches the browser.
 */

import paletteCss from '../styles/palette.css?raw';

/** Every `--neb-<name>: #hex;` declaration, in file order. */
function parseHexVars(css) {
  const found = new Map();
  const pattern = /--neb-([a-z0-9-]+)\s*:\s*(#[0-9a-fA-F]{3,8})\s*;/g;
  for (const [, name, hex] of css.matchAll(pattern)) {
    found.set(name, hex.toLowerCase());
  }
  return found;
}

const VALUES = parseHexVars(paletteCss);

/* The neutral ramp, light → dark. Twelve steps. */
export const RAMP = [
  'text',
  'subtext1',
  'subtext0',
  'overlay2',
  'overlay1',
  'overlay0',
  'surface2',
  'surface1',
  'surface0',
  'base',
  'mantle',
  'crust',
];

/* The fourteen calmed accents, in palette order. */
export const ACCENTS = [
  'rosewater',
  'flamingo',
  'pink',
  'mauve',
  'red',
  'maroon',
  'peach',
  'yellow',
  'green',
  'teal',
  'sky',
  'sapphire',
  'blue',
  'lavender',
];

/**
 * The hex for a palette name, straight from palette.css.
 * Throws at build time rather than rendering a blank chip.
 */
export function hex(name) {
  const value = VALUES.get(name);
  if (!value) {
    throw new Error(
      `palette.js: palette.css declares no --neb-${name}. ` +
        `Known: ${[...VALUES.keys()].join(', ')}`,
    );
  }
  return value;
}

/* Both directions are checked here, at module load, so the docs and the
 * stylesheet cannot drift apart silently. Both run at load rather than at render
 * on purpose: a throw from inside a component comes back as Astro's opaque
 * "[NoMatchingRenderer] Unable to render `Swatch`", which tells you nothing about
 * the actual cause. Thrown here, the message reaches the terminal intact.
 *
 * Per-product identity vars are excluded: --neb-product-* either alias an accent
 * (so they'd be duplicates on the page) or are hand-picked hover tints, which are
 * deliberately not palette members. */
const DOCUMENTED = [...RAMP, ...ACCENTS];

const missing = DOCUMENTED.filter((name) => !VALUES.has(name));
if (missing.length > 0) {
  throw new Error(
    `palette.js: the reference page lists colours palette.css doesn't declare: ` +
      `${missing.join(', ')}. Either restore --neb-<name> in palette.css, or drop ` +
      `it from RAMP/ACCENTS in this file.`,
  );
}

const documented = new Set(DOCUMENTED);
const undocumented = [...VALUES.keys()].filter(
  (name) => !name.startsWith('product-') && !documented.has(name),
);
if (undocumented.length > 0) {
  throw new Error(
    `palette.js: palette.css declares colours the reference page doesn't show: ` +
      `${undocumented.join(', ')}. Add them to RAMP or ACCENTS in this file.`,
  );
}

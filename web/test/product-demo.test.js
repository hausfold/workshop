import { describe, it, expect } from 'vitest';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const component = readFileSync(join(here, '../src/components/ProductDemo.astro'), 'utf8');
const layout = readFileSync(join(here, '../src/layouts/ProductLanding.astro'), 'utf8');
const frame = readFileSync(join(here, '../public/media/macbook-pro-orthographic.svg'), 'utf8');

describe('product landing demos', () => {
  it('renders the shared showcase on every child-product page', () => {
    expect(layout).toContain('<ProductDemo product={product} />');
  });

  it('stays code-native — no image, video, or gif payload', () => {
    expect(component).not.toMatch(/<video|<source|\.webp|\.mp4|\.gif/i);
    expect(component).not.toContain('demoMedia');
    expect(component).toContain('class="pounce-demo"');
    expect(component).toContain('class="perch-demo"');
  });

  it('has no full-screen focus mode and ships no client script', () => {
    expect(component).not.toContain('<script>');
    expect(component).not.toContain('showModal');
    expect(component).not.toContain('Focus the demo');
    expect(component).not.toContain('<dialog');
  });

  it('uses the flat orthographic frame and matches its screen geometry', () => {
    expect(component).toContain('src="/media/macbook-pro-orthographic.svg"');
    expect(component).toContain('aspect-ratio: 1648 / 1128');
    expect(frame).toContain('viewBox="0 0 1648 1128"');
  });

  it('draws the notch in bezel grey rather than as a black hole', () => {
    const notch = frame.match(/<path\s+d="M701 29H947[\s\S]*?\/>/);
    expect(notch).not.toBeNull();
    expect(notch[0]).toContain('fill="#343434"');
  });

  it('reads as a laptop base, not a keyboard deck or a tablet', () => {
    expect(frame).not.toMatch(/stroke-dasharray/);
    expect(frame).toContain('M700 1057Q824 1093 948 1057');
  });

  it('keeps every preview animated and reduced-motion safe', () => {
    expect(component).toContain('animation: palette-summons');
    expect(component).toContain('animation: message-arrives');
    expect(component).toContain('animation: shelf-opens');
    expect(component).toContain('@media (prefers-reduced-motion: reduce)');
  });

  // Matches on real usage, not prose — the earlier version of this test read
  // the word "three" in a comment as a Three.js import.
  it('does not pull in a 3D or animation runtime', () => {
    expect(component).not.toMatch(/from ['"]three|require\(['"]three|webglrenderingcontext|getcontext\(|<canvas/i);
    expect(component).not.toMatch(/perspective\s*[:(]|rotateX\(|rotateY\(|preserve-3d/i);
  });
});

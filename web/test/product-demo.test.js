import { describe, it, expect } from 'vitest';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const component = readFileSync(join(here, '../src/components/ProductDemo.astro'), 'utf8');
const layout = readFileSync(join(here, '../src/layouts/ProductLanding.astro'), 'utf8');
const pounce = readFileSync(join(here, '../src/pages/pounce.astro'), 'utf8');

describe('product landing demos', () => {
  it('renders the shared showcase on every child-product page', () => {
    expect(layout).toContain('<ProductDemo product={product} media={demoMedia} />');
  });

  it('keeps the real Pounce capture lazy and locally hosted', () => {
    expect(pounce).toContain("src: '/media/pounce-demo.webp'");
    expect(component).toMatch(/loading="lazy"/);
    expect(component).toMatch(/decoding="async"/);
  });

  it('loads future video media conservatively and only plays it near the viewport', () => {
    expect(component).toMatch(/preload="metadata"/);
    expect(component).toContain('IntersectionObserver');
    expect(component).toContain('video.pause()');
  });

  it('has a native focus dialog, mobile fit toggle, and reduced-motion state', () => {
    expect(component).toContain('dialog.showModal()');
    expect(component).toContain('Fit whole demo');
    expect(component).toContain('@media (prefers-reduced-motion: reduce)');
  });

  it('uses a flat screen-only Pro frame without boxing the showcase in', () => {
    expect(component).toContain('src="/media/macbook-pro-screen.svg"');
    expect(component).not.toContain('src="/media/macbook-pro-frame.webp"');
    expect(component).not.toContain('class="macbook-notch"');
    expect(component).toContain('{product}.app / performance');
    expect(component).not.toContain('{product}.app / performance preview');
    expect(component).not.toMatch(/background-size:\s*32px 32px/);
  });

  it('does not pull in a 3D or animation runtime', () => {
    expect(component).not.toMatch(/three(?:\.js)?|webgl|canvas/i);
  });
});

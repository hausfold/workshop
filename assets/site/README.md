# Salvage from `web/public/`

These are the images the old hausfold.co Astro site served, kept when that
site became the 301 map (rename plan §5.2) and its `public/` tree was deleted.
Nothing renders them today: **hausfold.co ships no images at all** — no
`og:image`, deliberately (see its `src/app/layout.tsx`) — so this is a
holding pen, not a live asset root.

They are here rather than in the history because [`../SHOTLIST.md`](../SHOTLIST.md)
exempts exactly this class from its one-hero-per-surface rule: *"wordmark
banners/logos, the OG social card, and the ripple chain diagram… keep those
anywhere."* Everything the old tree held that already had a copy in `../` —
`media/stills/*`, `ripple.webp`, the favicon — was dropped instead of moved.

| Path | What it was |
|---|---|
| `logos/` | the Starlight sidebar mark and the per-product wordmarks the landing page indexed |
| `app-icons/` | the app tiles on the landing page's "your apps, declared" strip |
| `social/og.png` | the site-wide OG card (`og:image` on every Astro page) |
| `social/perch-og.png` | perch's own card, for links to `/perch` |
| `macbook-pro-orthographic.svg` | the laptop frame the product demos sat in |
| `tap-caps.webp`, `theming.webp` | the two inline demo clips on the product pages |

If a hausfold.co page ever wants one, copy it there — don't link it from here.

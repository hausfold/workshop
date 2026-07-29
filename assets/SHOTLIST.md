# 🌫 nebelhaus — media policy & hero shot list

## The policy: media is marketing, not documentation

This project moves fast. Every rice tweak, palette nudge, or bar rework dates a
screenshot — so illustrated docs rot faster than the prose they sit next to. The
rule that keeps them honest:

- **How-to docs carry no UI media.** Guides and reference pages are text + code
  only. They never go stale because the config *is* the truth. (This is why the
  guide pages on nebelhaus.com have no screenshots.)
- **Media exists to sell, not to explain.** It lives on marketing surfaces only:
  each repo README's single hero, the product landing pages, and the social pool.
- **One hero per surface, max** — chosen by payoff × reach × virality, not by
  "this feature deserves a picture too."
- **Evergreen graphics are exempt** because they don't depict a UI that can
  drift: wordmark **banners/logos**, the **OG social card**, and the **`ripple`
  chain diagram** (a concept sketch, not a screenshot). Keep those anywhere.

If a shot isn't in the survivor table below, it isn't wired into anything.

## The survivor set (this is the whole list)

Six assets carry the family. Each earns its slot by what it's worth to a
stranger seeing it cold — the highest-reach, most-shareable moment of its repo.

| # | Asset | File | The one surface it serves | Why it earns the slot |
|---|---|---|---|---|
| 1 | **Pounce demo** | `pounce/assets/demo.webp` · mirrored to `web/public/media/pounce-demo.webp` | pounce README · `pounce.astro` landing | ⌘Space launcher in motion — the "wait, that's *native*?" clip. Most viral single asset in the family. |
| 2 | **Rice hero desktop** | `nebelhaus/assets/hero.png` | rice README · org README · landing poster | For a rice, the screenshot *is* the pitch — one clean tiled desktop + bar. *(Still a placeholder — the one shot genuinely worth capturing.)* |
| 3 | **OG social card** | `web/public/social/og.png` | share-link thumbnail (meta tags) | Every link anyone posts renders this. Evergreen wordmark, already wired. |
| 4 | **Landing reel** *(optional)* | *unshot* | nebelhaus.com hero background | At most ONE muted ~30–60s stitch, poster = the rice hero. A single film, never a menu of clips. |
| 5 | **Trill live sketch** | `web/src/components/ProductDemo.astro` | `trill.astro` landing | A code-native, synthetic inbox loop communicates the real triage shape without message privacy risk or a screenshot that rots. |
| 6 | **Perch live sketch** | `web/src/components/ProductDemo.astro` | `perch.astro` landing | A code-native shelf loop shows the notch interaction without adding a video payload; it can later yield to one real capture in the same slot. |

*(Nebelung's README now leads with its evergreen wordmark banner — an exempt
graphic per the policy above, not a survivor-table hero; the old
`swatch-cascade.webp` marketing loop was retired.)*

## Everything else is delisted

The earlier plan chased a menu — stills **S2–S16**, videos **V1–V10**,
composites (`S2-trio`, `S16-gallery`), the ports gallery. That menu is retired.
The raw frames still sit on disk as **source material only** — referenced by
nothing, owed to no one:

- `assets/stills/S2*–S16*` and the composites (workshop, source frames)
- `web/public/media/stills/*`, `web/src/assets/stills/*` (mirror copies)
- `web/public/media/theming.webp`, `web/public/media/tap-caps.webp` (retired demo loops)

Nothing here is deleted — but nothing here is an obligation either. Don't reshoot
to "fill in" the set; the set is the six above.

## If you ever shoot a new marketing asset

1. It has to displace something, or it's a seventh hero — and there is no seventh.
2. Host it under `web/public/media/<name>` (the one stable public URL, so any
   README *or* the docs site can hotlink the same file).
3. Add a row here and name the single surface it serves. If you can't name one, don't shoot it.

**Staging still matters for the shots that survive** — consistency is what makes
a rice read as *designed*, not *dumped*. Before capturing #1–#5:

- Flat fog-grey wallpaper near `base #202020`; default `mauve #c9a8f1` accent.
- Clean clock (**9:41**), a fog-appropriate weather city, neutral clipboard/tabs, fresh git state.
- Default gaps (inner `10px` / outer `20px`); keep any necessary KeyCastr cue small and bottom-center.
- Record on the retina display, 60fps, export @2x; bump Ghostty to ~22px for video legibility.

## Child-product performance capture brief

Each product landing gets one **8–10 second seamless loop**, not a feature tour.
Record the 14-inch panel at `3024×1964`, then export a silent `1512×982` H.264
MP4 with `faststart` and a WebP poster. Aim for **1.5–2.5 MB** per loop. Keep the
payoff inside the center 70% of the frame so the inline mobile crop still tells
the story; the focus view can reveal the whole screen.

- **Pounce — command to useful result.** Idle desktop; `⌘Space`; type `ports`;
  choose the local `:3000` process; run “open localhost”; land on a tiny local
  health page; return to the identical idle frame. This sells native speed and
  the backend bias in one move.
- **Trill — triage without dashboarding.** Start in a synthetic “needs reply”
  inbox; `⌘K`; search `alex build`; open the result; send
  `Shipped — v0.4.2.`; return to the original inbox. Use fictional names and
  content only.
- **Perch — collect, carry, disappear.** Start with three files centered in
  Finder; drag them to the notch; let the shelf bloom; drag the stack into a
  project folder; show the originals still in place; let the shelf close back
  into the notch.

Use one clean cursor and no permanent keystroke overlay—the interaction should
explain itself. Hold the first and last idle frame for roughly 0.4 seconds so
the loop has no visible jump.

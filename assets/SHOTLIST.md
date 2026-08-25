# 🌫 haus — media policy & hero shot list

## The policy: media is marketing, not documentation

This project moves fast. Every rice tweak, palette nudge, or bar rework dates a
screenshot — so illustrated docs rot faster than the prose they sit next to. The
rule that keeps them honest:

- **How-to docs carry no UI media.** Guides and reference pages are text + code
  only. They never go stale because the config *is* the truth. (This is why the
  guide pages on hausfold.co have no screenshots.)
- **Media exists to sell, not to explain.** It lives on marketing surfaces only:
  each repo README's single hero, the product landing pages, and the social pool.
- **One hero per surface, max** — chosen by payoff × reach × virality, not by
  "this feature deserves a picture too."
- **Evergreen graphics are exempt** because they don't depict a UI that can
  drift: wordmark **banners/logos**, the **OG social card**, and the **`ripple`
  chain diagram** (a concept sketch, not a screenshot). Keep those anywhere.

If a shot isn't in the survivor table below, it isn't wired into anything.

## The survivor set (this is the whole list)

Four assets carry the family. Each earns its slot by what it's worth to a
stranger seeing it cold — the highest-reach, most-shareable moment of its repo.

| # | Asset | File | The one surface it serves | Why it earns the slot |
|---|---|---|---|---|
| 1 | **Pounce demo** | *unshot* (`pounce/assets/demo.webp` is the slot, and is empty) | pounce README | ⌘Space launcher in motion — the "wait, that's *native*?" clip. Most viral single asset in the family. ⚠️ **Nothing is wired**: that README is text + badges, and the file has never existed. |
| 2 | **Desktop hero** | `haus/assets/hero.png` | haus README — **when it takes one; it carries no capture today** | For a rice, the screenshot *is* the pitch — one clean tiled desktop + bar. *(⚠️ **It is not a placeholder — corrected 2026-08-25.** The shipped file already matches the scene; what dates it is the retired **nebelhaus** wordmark in frame, plus a personal hostname, an 8-day uptime and a 36% battery. That makes it *wrong under the current naming rules* rather than *unfinished*, which is a stronger reason to reshoot and the reason not to tweak it instead. `launch-phase-1.md` §0 carries the measurement; the capture route that fixes the personal-data half is a VM rather than this Mac. Nothing links it. A 450-line shot sheet for the replacement — scene, pre-capture checklist, export sizes — lived at `SHOT-hacker-desktop.md` and was deleted on 2026-08-20 along with its `desktops-hero.patch`: both were written for `hausfold.co/desktops/`, and **that surface no longer exists**. **The scene, in one line, is all of it that was ever load-bearing: one clean tiled desktop — bar at the top, two windows tiled, Pounce open mid-search, nebelung grey across everything.** Reshoot from that, not from a checklist.)* ⚠️ **The `hausfold.co/desktops/` half of this slot is gone**: those three pages were deleted on 2026-08-14 into `content/docs/haus/desktops/`, and the docs deliberately carry no frames. |
| 3 | ~~**OG social card**~~ | `assets/site/social/og.png` | ~~share-link thumbnail~~ — **nothing, since 2026-08-14** | It was wired into every Astro page's `og:image`; that site is deleted and hausfold.co ships **no** `og:image`, deliberately. The file is kept (evergreen wordmark), the slot is not. Re-earning it means hausfold.co deciding it wants social cards. |
| 4 | **Landing reel** *(optional)* | *unshot* | the hausfold.co landing page | At most ONE muted ~30–60s stitch, poster = the desktop hero. A single film, never a menu of clips. ⚠️ Its old surface was hausfold.co's hero background, which no longer exists. |

*(Nebelung's README now leads with its evergreen wordmark banner — an exempt
graphic per the policy above, not a survivor-table hero; the old
`swatch-cascade.webp` marketing loop was retired.)*

*(The pounce/perch landings showed the app **in code**, not in a capture:
`web/src/components/ProductDemo.astro` drew each UI in HTML/CSS inside an SVG
MacBook. Both that component and its Astro pages died with hausfold.co on
2026-08-14 — hausfold.co's `/pounce` and `/perch` are Next routes now. The
principle is what carries: those weren't survivor-table assets, nothing was
shot, nothing rots, no byte ships. Don't "fix" a landing by pointing it at a
video. The MacBook frame survives at `assets/site/macbook-pro-orthographic.svg`
if the drawn-UI idea is ever rebuilt there.)*

## Everything else is delisted

The earlier plan chased a menu — stills **S2–S16**, videos **V1–V10**,
composites (`S2-trio`, `S16-gallery`), the ports gallery. That menu is retired.
The raw frames still sit on disk as **source material only** — referenced by
nothing, owed to no one:

- `assets/stills/S2*–S16*` and the composites (workshop, source frames) — **the
  only copies now**; the two `web/` mirror trees went with the site on 2026-08-14
  (hash-compared first, so nothing unique was dropped)
- `assets/site/theming.webp`, `assets/site/tap-caps.webp` (retired demo loops,
  moved out of `web/public/media/` in the same change)

Nothing here is deleted — but nothing here is an obligation either. Don't reshoot
to "fill in" the set; the set is the four above.

## If you ever shoot a new marketing asset

1. It has to displace something, or it's a fifth hero — and there is no fifth.
2. Host it in the repo whose surface it serves — a README's hero lives beside
   that README, a site image lives in `hausfold.co`. ⚠️ **`web/public/media/<name>`
   was the answer here until 2026-08-14 and is now a permanent 404**: that site
   is deleted and hausfold.co only 301s the pages it used to have, so there is
   no one-stable-public-URL to hotlink from two places any more. If two surfaces
   genuinely need one file, `raw.githubusercontent.com` is the shared URL (it is
   what `org-profile`'s README already uses).
3. Add a row here and name the single surface it serves. If you can't name one, don't shoot it.

**Staging still matters for the shots that survive** — consistency is what makes
a rice read as *designed*, not *dumped*. Before capturing #1, #2 or #4:

- A Nebelung wallpaper on `base #202020`; accent **`pink`**, not the option's
  default mauve — `hausfold.co` sets `--a-haus: var(--nebelung-pink)` and
  the logo's ears are pink, so a mauve capture is the odd one out on every
  surface it lands on.
- Clean clock (**9:41**), a fog-appropriate weather city, neutral clipboard/tabs, fresh git state.
- Personal pills off (`aiUsage`, `elgato`, `harvest`); no username, battery
  percentage or uptime anywhere in frame.
- Default gaps (inner `10px` / outer `20px`); KeyCastr bottom-center for any video.
- Record on the retina display, 60fps, export @2x; bump Ghostty to ~22px for video legibility.

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
| 2 | **Desktop hero** | `haus/assets/hero.png` | the launch posts — r/unixporn, Show HN, the one-pager, the reel's poster; **the haus README carries no capture today** | For a rice, the screenshot *is* the pitch — one clean tiled desktop + bar. ⚠️ **A frame that carries a wordmark, an org name, a username, an uptime or a battery percentage is disqualified** — the brand moves and the rest names the shooter. ⚠️ **A Ghostty window IS a pane**, with no tab bar or keybind hint strip of its own, so a bare shell photographs as an empty rectangle and the window needs a TUI in it. The shipped frame: Zen on `github.com/hausfold` (grey and pink via the `github` entry in `haus.zen.userStyles`) beside Ghostty running lazygit over an unstaged `haus.focus.scenes` tree, Pounce mid-search on **Spawn Agent**, both bars on. Two costs to respect — lazygit's **Log/Commits** panel renders `Author: … <email>` and is disqualifying for a public asset (**Files** is not), and a ~34-column pane wraps past ~40 characters, so config being shown off must be written short. ⚠️ **Two things in the frame are the shooter's host, not the desktop** — `haus.zen.userStyles` defaults to `[ ]` and `haus.bar.bottom.enable` to `false`, and `desktops/hacker.nix` sets neither, so a fresh install has an unthemed browser and one bar. Launch-post copy that leads with this image has to say so. `hausfold/ops`'s `todo/launch-phase-1.md` carries the full measurement. Nothing in the family renders it; the consumers are r/unixporn, the Show HN, the creator one-pager and the reel's poster frame. |
| 3 | ~~**OG social card**~~ | `assets/site/social/og.png` | ~~share-link thumbnail~~ — **nothing** | hausfold.co ships **no** `og:image`, deliberately. The file is kept (evergreen wordmark), the slot is not. Re-earning it means hausfold.co deciding it wants social cards. |
| 4 | **Landing reel** *(optional)* | *unshot* | the hausfold.co landing page | At most ONE muted ~30–60s stitch, poster = the desktop hero. A single film, never a menu of clips. ⚠️ hausfold.co's landing page carries no hero background, so nothing is waiting on it. |

*(Nebelung's README leads with its evergreen wordmark banner — an exempt
graphic per the policy above, not a survivor-table hero.)*

*(A landing may show the app **in code** rather than in a capture — the UI drawn
in HTML/CSS inside an SVG MacBook. That is not a survivor-table asset: nothing is
shot, nothing rots, no byte ships. Don't "fix" a landing by pointing it at a
video instead. The MacBook frame is at
`assets/site/macbook-pro-orthographic.svg`.)*

## Everything else is delisted

Stills **S2–S16**, videos **V1–V10**, the composites (`S2-trio`,
`S16-gallery`) and the ports gallery are not a set anyone owes. None of it is
wired to anything. The frames do sit on disk, as **source material only** —
referenced by nothing, owed to no one:

- `assets/stills/S2*–S16*` and the composites (workshop, source frames) — **the
  only copies anywhere**, so don't prune them for tidiness
- `assets/site/theming.webp`, `assets/site/tap-caps.webp` — delisted demo loops

Nothing here is deleted — but nothing here is an obligation either. Don't reshoot
to "fill in" the set; the set is the four above.

## If you ever shoot a new marketing asset

1. It has to displace something, or it's a fifth hero — and there is no fifth.
2. Host it in the repo whose surface it serves — a README's hero lives beside
   that README, a site image lives in `hausfold.co`. ⚠️ **There is no one stable
   public URL to hotlink a file from two places** — hausfold.co's static export
   serves no shared media path. If two surfaces genuinely need one file,
   `raw.githubusercontent.com` is the shared URL (it is what `org-profile`'s
   README already uses).
3. Add a row here and name the single surface it serves. If you can't name one, don't shoot it.

**Staging still matters for the shots that survive** — consistency is what makes
a rice read as *designed*, not *dumped*. Before capturing #1, #2 or #4:

- A Nebelung wallpaper on `base #202020`; accent **`pink`**, not the option's
  default mauve — `hausfold.co` sets `--a-haus: var(--nebelung-pink)` and
  the logo's ears are pink, so a mauve capture is the odd one out on every
  surface it lands on.
- Clean clock (**9:41**), a fog-appropriate weather city, neutral clipboard/tabs, fresh git state.
- Personal pills off (`aiUsage`, `elgato`, `harvest`); no username, battery
  percentage or uptime anywhere in frame. ⚠️ **`haus set bar.bottom.enable false`
  does not remove the pills that live down there** — `haus/modules/bar/default.nix:1254`
  wraps `bottomGroup` in `lib.optionals cfg.bottom.enable`, so `bottomItems` goes
  empty and every one of them falls back onto the menu bar. Turning the second bar
  off collapses two bars into one crowded one; thin the frame with `haus.bar.items`
  as well, and `haus reset` to undo. The shipped hero deliberately runs none of
  this — a desktop visibly doing work sells better than a staged one, so the
  `agents` and `github` pills stay in shot.
- Default gaps (inner `10px` / outer `20px`); KeyCastr bottom-center for any video.
- Record on the retina display, 60fps, export @2x; bump Ghostty to ~22px for video legibility.

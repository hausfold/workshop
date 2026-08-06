# Go to market — the portfolio, the doors, the order

Working doc, written 2026-08-04 from the launch-strategy research plus the
monetization decisions in [`perch-monetization.md`](./perch-monetization.md).
That file owns **how perch charges**. This one owns **what's free, what's paid,
which audience each piece is for, and in what order any of it goes public.**

**The one principle: the free family builds the audience, perch cashes it, and
they are not the same event.** Every free repo exists to put a stranger in front
of the house at zero risk. Perch is the only thing anyone pays for, and it should
launch into an audience that already exists — not manufacture one at $19 a head.

---

## 1. The portfolio (as of 2026-08-04)

| Piece | Price | License | Job in the funnel |
|---|---|---|---|
| **nebelung** | free | MIT | Taste door. Palette people meet the visual language before they meet Nix. |
| **pounce** | free, **no paid tier ever** | MIT | Utility door. A native launcher installable without adopting anything. The site already promises "no paid tier" — that promise is load-bearing, don't reopen it. |
| **holt** | free | MIT | Dev-tool door. The only piece whose audience isn't macOS ricers. |
| **nebelhaus** (rice) | free | MIT | The destination. What the other doors convert into. |
| **perch** | **$19 one-time**, +1 yr updates, $9 renewal | **FSL-1.1-Apache-2.0** | The only revenue line. Free tier = a working shelf capped at 3 tiles. |
| **trill** | not monetized | MIT | Frozen. Archive decision still open — [`perch-monetization.md` §5.5](./perch-monetization.md#55-open-archive-trill). |
| **hausfold** | — | — | The umbrella — commercial identity only, no product and no code. It's the seller, nebelhaus is the brand. See §6. |

The original launch thesis said *three doors*. It predates holt's ejection and
perch's positioning, so it's now **five**, and one of them is paid:

1. **nebelung** → taste (Catppuccin, theming communities)
2. **pounce** → utility (r/MacApps, Mac utility enthusiasts)
3. **holt** → developer pain (HN, agent-coding discourse, any-repo, any-OS-with-git)
4. **nebelhaus** → the committed (NixOS Discourse, r/unixporn)
5. **perch** → the wallet (Mac press that covered NotchNook, r/MacApps round two)

Doors 1–4 all terminate at nebelhaus.com. Door 5 terminates at a checkout.

**Holt is probably the strongest cold-traffic door and the strategy hasn't
caught up with that.** "Run parallel coding agents in any repo without them
clobbering each other" has vastly more searchers in 2026 than "macOS rice", and
it costs a reader nothing — no Mac, no Nix, no opinions. It is also the only
piece with zero brand-loyalty prerequisite. Treat it as a first-class door, not
a footnote of the rice.

## 2. Order of operations

The two plans in flight compete for the same window if you let them. This is the
resolution:

```
Phase 0 (perch FSL relicense)   ← NOW, before any public perch install base grows
        ↓
House inspection (private testers)   ← notes/launch-phase-1.md
        ↓
Free launches: nebelung → pounce/holt → the house
        ↓
4–8 weeks of real usage + public proof
        ↓
Perch Phases 1–3 (license layer, Paddle, storefront)
        ↓
Perch paid launch, into an audience that already exists
```

**Why Phase 0 goes first, before any launch.** Relicensing is a commit today
(authorship is verified solo) and it only ever gets harder. More importantly:
every free-launch install of perch between now and the flip is an MIT build in
someone's hands, and a big MIT install base turns "the next version is fair
source" into "it was free and now it isn't". Do it while the install base is
approximately you. `bench release` and the four distribution doors are unchanged
by it.

**Why perch's paid launch is not launch day.** At launch day there is no social
proof, no press contact who has used it, and no answer to "who else paid for
this". Selling into that costs more than waiting six weeks. Perch can absolutely
be *visible* on launch day — free tier, shipping, on the site — it just isn't
asking for money yet.

## 3. Channels, and the rules that actually bite

Ranked by expected conversion, not reach. A hundred nix-darwin users beat twenty
thousand Product Hunt impressions.

| Avenue | Lead with | The rule that bites |
|---|---|---|
| Catppuccin Discord/community | nebelung | Enter as a palette contribution, never as "please promote my fork". |
| NixOS Discourse | the house | Announcements are explicitly welcome. Lead with architecture, not the desktop shot. End on two real technical questions. |
| Hacker News (Show HN) | holt, then the house | **Never solicit votes** — not from testers, not from Discord. Write the post in your own voice; HN asks for no generated text. |
| r/MacApps | pounce, later perch | Needs local karma, `[OS]` prefix for open source, ~1 promo per dev per 30 days. **Start participating before you need it.** |
| Personal X + Bluesky | the whole experience | Post from the human account. The org account reposts. |
| r/unixporn | the desktop | Post it as a rice post that happens to be installable. Don't put "LAUNCHING" on the image. |
| Creator/maintainer seeding | the one relevant piece | "I built something adjacent to your work, I'd value your opinion on one decision" — never a press release. |
| Awesome-lists / directories | pounce, holt | No spike, durable long tail. Do it once, after launch. |
| Product Hunt | perch, maybe | Decorative for this audience. Low priority. |

## 4. The finite asset list

Everything the launch needs, and nothing else. Media policy is
[`assets/SHOTLIST.md`](../assets/SHOTLIST.md) — docs stay text, media is
marketing-only.

- [ ] **The rice hero shot** — `nebelhaus/assets/hero.png` is still a
      placeholder, and for a rice that one clean desktop *is* the pitch. This is
      the single highest-leverage unfinished asset in the family.
- [ ] **A 20-second silent workflow loop** — desktop → app hints → launch+tile →
      pounce command → `haus rebuild` → composed desktop. No voiceover, no
      soundtrack. Cut variants for pounce and for nebelung.
- [ ] **The fog slider** — one interactive page, Catppuccin Mocha → nebelung on
      the same screenshot. This becomes nebelung's canonical share link.
- [ ] **"Steal one room" cards** — one per room (den, prowl, sill, hearth,
      collar, secrets, pounce): purpose, tiny shot, the minimal Nix import.
      Converts people who like the project but refuse all-or-nothing.
- [ ] **A creator one-pager** — paragraph, three shots, video, install command,
      compatibility, license, contact. No press release.

## 5. The gallery / marketplace question — answered

**Don't build it first, and don't put it on hausfold.co.**

Three reasons it isn't first:

- **A gallery's value is the number of rices in it, and there is currently one.**
  Launching an empty store is worse than launching no store — it reads as
  abandoned, which is exactly the failure mode `hausfold/PRESENCE.md` warns
  about for dormant channels.
- **The supply comes from the testers.** The format already exists and is
  documented ([Sharing a rice](../web/src/content/docs/guides/sharing-a-rice.mdx)
  — a data-only `.nix` file touching only `nebelhaus.*`). Phase 1 testers are
  the first people who will ever author one. Collect what they write; *that's*
  the gallery's seed content, and it doesn't exist yet.
- **It isn't a revenue path.** A directory of free `.nix` files has no plausible
  take rate. Perch is the decided revenue line; the gallery is retention and
  social proof, which is real value but not money.

Where it belongs: **nebelhaus.com/rices**, submissions by PR to a
`nebelhaus/rices` repo (CI validates that a submission only sets `nebelhaus.*`
and evaluates). A nebelhaus rice reached through a *different domain* puts an
extra hop between "I like that" and `haus rebuild`, and funnels die at extra
hops.

When to build it: as the **housewarming release** — the second event, ~4 weeks
after launch, carrying the first external rices, the first contributed pounce
commands, and the first contributors' names by name. That turns launch attention
into a second wave instead of letting it evaporate.

The same logic applies to the pounce command exchange ("things people taught the
cat") — same event, same mechanism, zero extra infrastructure.

## 6. What hausfold is for

**Decided 2026-08-04: hausfold is the umbrella — the commercial identity, not a
product brand.** It fits what was already true: `hausfold/PRESENCE.md` says the
`hausfold` GitHub org is deliberately separate and *nothing in the nebelhaus
family belongs there*.

The split that falls out of it:

| | **nebelhaus** | **hausfold** |
|---|---|---|
| Is | the brand people love | the entity that sells |
| Carries | products, docs, the family, the gallery | billing, terms, refunds, press, future non-rice products |
| Customer sees it | constantly | on a receipt |

Consequences to honor:

- **Product support stays `support@nebelhaus.com`.** People bought *perch*, a
  nebelhaus product; routing them to a name they've never seen is friction for
  no gain. hausfold owns the *commercial* surface — the seller name on perch's
  terms/refund page, press contact, and whatever isn't macOS ricing later.
  ([`perch-monetization.md` Phase 3](./perch-monetization.md#3-phases) already
  says nebelhaus for support — that stays correct.)
- **Nothing in the family migrates to the hausfold org.** Not the gallery (§5),
  not holt, not a repo, ever. The register already says this; the decision makes
  it load-bearing rather than incidental.
- **Paddle will ask who the seller is, and "hausfold" is a name, not an
  entity.** No incorporation and no trademark work exists. Selling as an
  individual with hausfold as a trading name is the low-friction path; that's a
  real decision but it belongs to the Paddle application, not here.
- **It is not the gallery** (§5). ~~And it stays a placeholder page until it has
  something to say.~~ **Reversed 2026-08-06:** hausfold.co is now a one-sheet
  index of the five products plus revena, in a maker's voice. The dormant-channel
  logic still holds for the *social* accounts — it was the page it stopped
  applying to, because a domain that says one word says nothing, while a page
  that links straight out to nebelhaus.com and GitHub adds no hop to any funnel.
  Everything else in this section stands: support at nebelhaus.com, nothing in
  the family migrating to the hausfold org, hausfold as the seller on the
  receipt. The page and the register now live in
  [hausfold/website](https://github.com/hausfold/website), split out of this
  repo the same day.

One known exposure: `hausfold.com` isn't held, and an entity name gets spoken
aloud in receipts and terms — see §9.

## 7. Measurement without adding telemetry

No product telemetry, ever — the privacy sentence is a contract. Use what's
already observable: per-campaign links, GitHub traffic referrers, release
download counts, Homebrew analytics, docs page traffic, stars/forks, issues,
contributed rices and ports, and voluntarily reported installs.

Score each channel as **meaningful actions per 100 visitors**, where meaningful
means: copied the installer, installed pounce or holt, opened a substantive
issue, contributed a rice/port/command. Not stars. A star means "maybe someday".

## 8. What not to do

- Don't launch six repos on the same day — it makes the ecosystem look smaller,
  not larger.
- Don't lead with the cat metaphor. It makes a technical project memorable; it
  can't substitute for one.
- Don't call pounce a Raycast killer. Its point is refusing the plugin-platform
  model.
- Don't say "macOS rice" outside ricing communities. Say "a reproducible,
  keyboard-first macOS workstation".
- Don't buy ads before you know which message produces installs.
- Don't open a Discord yet. GitHub Discussions until recurring conversation
  needs a home.
- Don't gate perch's *downloads*. The paywall lives in the binary — that
  principle is [`perch-monetization.md`](./perch-monetization.md)'s and it
  survives everything here.

## 9. Open decisions

| # | Decision | Status |
|---|---|---|
| 1 | Is hausfold the umbrella/commercial identity, or a future product brand? | **Decided 2026-08-04: umbrella** — §6. Successor question: does the seller incorporate, or sell as an individual trading as hausfold? That one is the Paddle application's. |
| 2 | Archive trill? | Open since 2026-08-04 — [`perch-monetization.md` §5.5](./perch-monetization.md#55-open-archive-trill). Leaning yes. Blocks the free launch: an unmaintained app shipped by default sets the family's quality bar in front of every new tester. |
| 3 | Does holt get its own launch moment or ride the house's? | Open. Its own — its audience shares almost nothing with the rice's. |
| 4 | `hausfold.com` — buy it or accept the `.co`? | Open, cheap, gets more expensive with brand value. |

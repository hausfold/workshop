# Go to market — the portfolio, the doors, the order

Working doc, written 2026-08-04 from the launch-strategy research. It owns
**which audience each piece is for, and in what order any of it goes public.**

> ⚠️ **The monetization half of this document is dead, 2026-08-15.** It was
> written around a paid, fair-source perch — `$19` one-time, an FSL relicense,
> a capped free tier — and **perch is free of charge and MIT**, retroactively.
> The FSL experiment covered `v2026.08.04` through `v2026.08.14-1` and was
> reversed; the licence subsystem, the capacity cap and the purchase strip were
> never shipped to anyone (the production key was never minted). The companion
> `perch-monetization.md`, which owned that plan, is **deleted** — perch's own
> `README.md` licence section is the record of what happened. Rows and phases
> below that assumed a paid perch are corrected in place; **"selling perch stays
> possible later"** is the whole of what survives.

**The one principle: every door is free, and the family's job is to put a
stranger in front of the house at zero risk.** There is no revenue line yet, so
nothing here trades reach for conversion.

---

## 1. The portfolio (as of 2026-08-04)

> **★ Superseded in part, 2026-08-08 — read this first.** This file was written
> when hausfold was an umbrella and haus was the brand. That is reversed:
> **hausfold is the org, the maker and the seller; `haus` is the nix-darwin
> layer it makes; haus is one rice built on that** — the developer-focused
> one, and the first. *(The hausfold/haus split is decision 8, 2026-08-10; §6
> has it in full.)* The rename plan and its
> ordering are done and its record is gone; this file keeps the
> *funnel* thinking, which mostly survives, and each section below carries a
> note where it doesn't. The three reversals: hausfold is a product surface now,
> the whole family migrates to the `hausfold` org, and the gallery is
> `hausfold.co/desktops`.

| Piece | Price | License | Job in the funnel |
|---|---|---|---|
| **nebelung** | free | MIT | Taste door. Palette people meet the visual language before they meet Nix. |
| **pounce** | free, **no paid tier ever** | MIT | Utility door. A native launcher installable without adopting anything. The site already promises "no paid tier" — that promise is load-bearing, don't reopen it. |
| **holt** | free | MIT | Dev-tool door. The only piece whose audience isn't macOS ricers. |
| **haus** (rice) | free | MIT | ~~The destination.~~ **One rice on `haus`** — the developer-focused one, and the first. Still what the other doors convert into, but it converts them into the *platform*, and it lives on a page inside `/desktops` rather than owning a domain. |
| **haus** (the layer) / **hausfold** (the house) | free | MIT | **The destination.** `haus` is the nix-darwin layer every rice sets options on; `hausfold` is the org it ships under and the name on the receipt. Was the umbrella; became the product on 2026-08-08; got the two-word split on 2026-08-10 (decision 8). |
| **perch** | free | MIT | Shelf door. Was the only revenue line — `$19` one-time on an FSL relicense — until 2026-08-15, when perch went free and MIT retroactively. No paid tier, no licence file, no tile cap. |
| ~~**trill**~~ (the Messages client; the repo is `hausfold/messages` since 2026-08-08, and the *name* now belongs to the notification compositor) | not monetized | MIT | **Archived on GitHub** — settled by removal, not by a note. rice#212/#213 removed the module and the flake input; no tester is handed it at all. |
| ~~**hausfold** (umbrella)~~ | — | — | ~~The umbrella — commercial identity, not a product. It's the seller, haus is the brand.~~ **Reversed 2026-08-08 — see the row above and §6.** hausfold is the platform *and* still the seller; the two roles turned out not to conflict. |

The original launch thesis said *three doors*. It predates holt's ejection and
perch's positioning, so it's now **five**, all of them free:

1. **nebelung** → taste (Catppuccin, theming communities)
2. **pounce** → utility (r/MacApps, Mac utility enthusiasts)
3. **holt** → developer pain (HN, agent-coding discourse, any-repo, any-OS-with-git)
4. **haus** → the committed (NixOS Discourse, r/unixporn)
5. **perch** → the shelf (Mac press that covered NotchNook, r/MacApps round two)

All five doors terminate at **hausfold.co** (was hausfold.co, which 301s).

**The rename sharpens door 4 rather than blunting it.** A rice post lands better
as "here's my desktop, and here's the platform it's a config of" than as "here's
my desktop, which is also the product" — the second invites *use mine*, the first
invites *build yours*. r/unixporn still meets haus; NixOS Discourse now
meets hausfold, which is the audience that actually wanted the platform framing.

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
House inspection (private testers)   ← notes/launch-phase-1.md
        ↓
Free launches: nebelung → pounce/holt → the house
        ↓
4–8 weeks of real usage + public proof
```

**What used to be here, and why it's gone.** This block opened with a *Phase 0
(perch FSL relicense)*, gated ahead of every launch on the argument that a big
MIT install base turns "the next version is fair source" into "it was free and
now it isn't". The relicense happened, ran for ten days, and was reversed on
2026-08-15 — perch is MIT again, retroactively over those tags. The two phases
that followed it (licence layer / Paddle / storefront, then a paid launch) are
**not scheduled**. Nothing in the launch order competes for a window any more:
the free launches are the whole sequence.

**If perch is ever sold, the one finding worth keeping** is that a paid launch
should not be launch day — at launch day there is no social proof, no press
contact who has used it, and no answer to "who else paid for this", so selling
into that costs more than waiting six weeks.

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

- [ ] **The rice hero shot** — `haus/assets/hero.png` is still a
      placeholder, and for a rice that one clean desktop *is* the pitch. This is
      the single highest-leverage unfinished asset in the family.
- [ ] **A 20-second silent workflow loop** — desktop → app hints → launch+tile →
      pounce command → `haus rebuild` → composed desktop. No voiceover, no
      soundtrack. Cut variants for pounce and for nebelung.
- [ ] **The fog slider** — one interactive page, Catppuccin Mocha → nebelung on
      the same screenshot. This becomes nebelung's canonical share link.
- [ ] **"Steal one room" cards** — one per room (core, windows, bar, terminal,
      security, secrets, launcher): purpose, tiny shot, the minimal Nix import.
      Converts people who like the project but refuse all-or-nothing.
- [ ] **A creator one-pager** — paragraph, three shots, video, install command,
      compatibility, license, contact. No press release.

### 4.1 Copy bank — lines that are already good

Keep them here so they survive the sessions that wrote them, and so the
hausfold.co redesign has sentences to reach for (the port keeps the copy that
took work — this is that copy).

| line | where it lives | notes |
|---|---|---|
| **make a haus a home** | **unplaced, on purpose** (2026-08-11) | ⚠️ **A tagline, never a taxonomy.** It arrived as a proposal to rename `desktop(s)` → `home(s)` — the gallery at `/desktops`, decision 7. That rename is **rejected**: `home` collides with home-manager's live `home.*` namespace sitting right beside `haus.*`, with `home.file`, with `$HOME`/`~`, and with the site's own home page; `hausfold.co/homes` reads as real estate under a brand that already means *house*; and nobody searches for "home" when they mean a rice. The verb is the value — *make it yours* is exactly the `/desktops` pitch — so it survives as a sentence and `desktop` stays the noun. **It went onto hausfold.co's landing page and came straight back off**: `web/` is mid-move to hausfold.co (§5.1), so copy landed there now is copy the port has to carry, and this is a *platform* line with no reason to debut on the rice's site. Place it when the destination exists — the `/haus` hero is the obvious slot. |
| An opinionated macOS, raised in the fog. | hausfold.co hero `<h1>` | The rice's line, not the platform's. Doesn't transfer to hausfold.co. |
| One command. Your Mac, already sorted. | hausfold.co hero lede | Survives the port with the install one-liner. |
| Four rooms, one house. | hausfold.co family section | The house metaphor the kicker above hangs off. |
| The whole machine is the config. | hausfold.co closer | The most portable line on the page — it's a *platform* claim wearing a rice's clothes. Strong candidate for `/haus`. |

An unused idea kept on purpose: if `home` ever earns a place in the vocabulary,
the split that survives the collisions is **a `desktop` is what you install, a
`home` is what it becomes once you've set your own options** — you install a
desktop, you make it your home. Cheap to adopt today; expensive after "home"
is in the guides and has to be disambiguated from home-manager on every page.

## 5. The gallery / marketplace question — answered

> **★ Half-reversed 2026-08-08.** *Don't build it first* **stands**, and now has
> a second, harder reason: [`options-roadmap.md`](./options-roadmap.md) §6's
> Limit 3. Stated as that file *measured* it rather than as it first asserted —
> the plain conflict error is actually decent, naming the option, both files and
> `lib.mkForce` (§6(b) retracted the "they see nothing we wrote" claim). The
> unfixed part is **rice-vs-rice**, which is exactly what a gallery creates:
> §6(d) measured that `mkDefault` "can never be" a fix for it, `checkRice` can't
> catch it (the module system stops before assertions run), and a transforming
> seam prints `<unknown-file>` twice — loud and anonymous. So the gallery can't
> open properly until §6(e)'s *priority by list position* (`compose`) lands.
>
> *Don't put it on hausfold.co* is **reversed**: the gallery is
> **`hausfold.co/desktops`**. The "extra hop" argument below was right about hops
> and wrong about which domain is home — hausfold.co *is* the destination now,
> so `/desktops` is zero hops from the platform and hausfold.co is the one that
> 301s. Everything else in this section survives intact.
>
> **Two amendments, both 2026-08-08, both after the page shipped.** The path was
> written here as `/market`; it is now **`/desktops`** — a session building the
> page put four names to the user and was told `/desktops`, and when the two
> collided the user amended the plan rather than the page
>. And the Limit 3
> gate binds the **second entry**, not the page: `/desktops` is live with a real
> install command, which is safe only because rice-vs-rice needs two rices and
> there is one. *Don't build it first* survives both — one rice, listed
> honestly, is not a store.
>
> **★ Gate lifted 2026-08-14 — the rooms model repealed it, and the catalogue
> passed it three times on the way.** Everything above is written about
> *rice-vs-rice*: two whole configurations composed onto one host, colliding on
> a shared option. haus's **desktop seam** ([`rooms-desktops.md`](./rooms-desktops.md),
> step 3, shipped) makes that composition **impossible rather than dangerous** —
> a host selects exactly one desktop and a second fails an assertion on
> `haus._desktop.sources` in the evaluated system, so "whole desktops do not
> stack" is enforced, not advised. (The check sits there, not at either entry
> point, because two desktops can arrive from two places and neither seam sees
> the other.) Both halves of the
> gate fall with it: the loud conflict needs two desktops, and so does §6(f)'s
> *silent blend* on list- and attrs-valued options, which the same seam answers
> directly — a desktop's leaves land at priority 900, and "when the host names
> that list, its list **replaces** the desktop's rather than appending to it".
> Overriding your desktop never needs `lib.mkForce`.
>
> **What the gate still covers, unchanged: packs and raw `extraModules`.** Two
> packs naming one app still collide, and two list-valued fragments still blend
> silently — those rows outlived `preset-composition` on purpose and moved into
> `fragment-compat` intact. A `/desktops` entry is not either of those things.
>
> Events had already overtaken it: `/desktops/everyday` and `/desktops/minimal`
> shipped 2026-08-14 beside `/desktops/hacker`. **hausfold.co's `AGENTS.md`
> closed the rule in place the same day** — it is the repo that carries it, since
> adding a row *is* a site change — and its 🚨 is the sentence to keep: **that
> closes this gate and nothing else.** The bar above it is untouched: a row must
> *exist and be installable by a stranger*, which today means four things in
> step: `hausfold/haus`'s `desktops/<name>.nix`; a row in `worker.js`'s
> `DESKTOPS`, which is the **installer** map only — it is what makes
> `hausfold.co/<name>.sh` work, not what makes a catalogue URL resolve; a page
> at `src/app/desktops/<name>/`, which is that URL and reads every fact off the
> `.nix` file; and a catalogue row on `/`. `blank` deliberately has none of
> them — it is a real desktop and the null selection, so a row would promise a
> machine it doesn't produce.
>
> **So what stands between here and a *third-party* entry is acquisition and
> trust, not composition:** where a stranger's desktop is fetched from, who
> vouched for it, and whether a row can point outside `hausfold/haus` at all —
> every desktop listed today ships inside our own repo.
> `haus.lib.checkDesktop` / `haus.lib.desktopFailures` are public so an author
> can self-test one, which is the piece that exists. That is the open item this
> gate was standing in front of, and it is a different item.
>
> ★ **Designed 2026-08-16, still unbuilt:**
> [`rooms-desktops.md` § Acquisition](./rooms-desktops.md#acquisition--how-a-desktop-or-room-reaches-a-machine).
> The short version, because it changes what a `/desktops` row could point at:
> a third-party desktop rides as a **non-flake input** (`flake = false`), so
> `flake.lock` already carries the origin, the revision and — in the
> `"flake": false` field itself — whether the source was data or code. No
> manifest and no gallery API are needed for a row to point outside
> `hausfold/haus`; what is still missing is the `haus show` / `haus add`
> commands, and the "who vouched for it" half is unanswered and stays a
> submissions-by-PR question.

**Don't build it first**, ~~and don't put it on hausfold.co.~~

Three reasons it isn't first:

- **A gallery's value is the number of rices in it, and there is currently one.**
  Launching an empty store is worse than launching no store — it reads as
  abandoned, which is exactly the failure mode hausfold's `PRESENCE.md` warns
  about for dormant channels. ⚠️ **Three since 2026-08-14** — `haus`,
  `everyday`, `minimal` — and all three are ours, so the reason survives its
  number: the count that makes a gallery is *other people's* desktops, which is
  still zero. hausfold.co's closing line says exactly that out loud ("Three
  today, and that's the honest number").
- **The supply comes from the testers.** The format already exists and is
  documented — a data-only `{ haus = { … }; }` file:
  [Creating a desktop](https://hausfold.co/docs/haus/desktops/creating), where
  the deleted `web/` guide's `/guides/sharing-a-rice/` URL now 301s, plus
  [Sharing one](https://hausfold.co/docs/haus/desktops/sharing) for the
  publishing half. Phase 1 testers are
  the first people who will ever author one. Collect what they write; *that's*
  the gallery's seed content, and it doesn't exist yet.
- **It isn't a revenue path.** A directory of free `.nix` files has no plausible
  take rate. Nothing in the family is a revenue line today; the gallery is retention and
  social proof, which is real value but not money.

Where it belongs: ~~hausfold.co/rices~~ → **`hausfold.co/#desktops`** (its own
page from 2026-08-08 until 2026-08-12, when it became the landing page's first
section and `/desktops` began 301ing there; `/desktops/<name>` stayed), submissions
by PR to a `hausfold/rices` repo (CI validates that a submission only sets
`haus.*` and evaluates — still unbuilt, and `haus.lib.checkDesktop` is now what
it would call). The hop argument is unchanged and now points the other
way: a rice reached through a *different domain* puts an extra hop between "I
like that" and `haus rebuild`, and hausfold.co is where the platform, the docs
and the installer live.

When to build it: as the **housewarming release** — the second event, ~4 weeks
after launch, carrying the first external rices, the first contributed pounce
commands, and the first contributors' names by name. That turns launch attention
into a second wave instead of letting it evaporate.

The same logic applies to the pounce command exchange ("things people taught the
cat") — same event, same mechanism, zero extra infrastructure.

## 6. What hausfold is for

> **★ Rewritten 2026-08-08. The 2026-08-04 decision — "hausfold is the umbrella,
> not a product brand" — is reversed.** The struck text is kept below because the
> *reasoning* still explains why the split was drawn, and one half of it survived.

**hausfold is the platform, the org, and the seller. haus is one rice built
on it.**

> **★ Refined 2026-08-10 — the layer is called `haus`.** Decision 8 splits the
> two jobs this sentence gives one word: **`haus`** is the nix-darwin layer a user installs and writes
> options for, **`hausfold`** is the org, the maker and the entity on the
> receipt. It is not a fourth position — hausfold still *makes* the platform,
> the org migration and the domain are untouched, and nothing in code moves.
> Read every "hausfold" below that means the layer as "haus"; the ones that mean
> the seller, the org or the domain are still right as written. That includes
> §1's "read this first" box at the top of this file and the portfolio table's
> hausfold row — both 180 lines above this one, and both out of reach of the
> word "below".

The nix-darwin ricing platform is **haus**; the mac apps, the open-source tools
and the entity on the receipt are hausfold; `haus.*` is the option namespace
every rice sets, and haus is the developer-focused rice that ships first.

What actually changed, and what didn't:

| | **haus** | **hausfold** |
|---|---|---|
| Was | the brand people love | the entity that sells |
| **Is now** | **one rice, the first one, on a page inside `/desktops`** | **the platform people install, the org it ships from — and still the entity that sells** |
| Customer sees it | when choosing a rice | constantly, and on the receipt |

**Why the reversal, in one line:** the umbrella framing made the *platform*
nameless. Every option was `haus.*`, so a stranger publishing a large-print
rice for their parent was publishing it into a namespace named after somebody
else's desktop — which is the exact confusion `options-roadmap.md` exists to
remove.

Consequences, revised:

- ~~**Product support stays `support@hausfold.co`.**~~ **Reversed** — people
  now buy a *hausfold* product, so support moves to the hausfold.co domain. The
  original reasoning ("routing them to a name they've never seen is friction")
  is exactly why it moves: hausfold is the name they *will* have seen.
  **The address is `hi@hausfold.co`** — settled 2026-08-09. This bullet said
  `support@hausfold.co` for a day; that mailbox was never created and isn't
  going to be.
- ~~**Nothing in the family migrates to the hausfold org.** Not the gallery, not
  holt, not a repo, ever.~~ **Reversed — everything migrates**, all ten repos.
  `PRESENCE.md`'s GitHub row and hausfold's `AGENTS.md` both
  carried this as a hard rule and are updated in the same change.
- **"hausfold" is a name, not an entity.** ✅ **Unchanged, and now more
  load-bearing** — the name is on more surfaces than a receipt, and it is on
  them whether or not anything is ever sold. No incorporation exists, and no
  trademark *filing*; the register **has** been searched (2026-08-10 —
  `hausfold` returns zero records worldwide), which is a screening, not a
  clearance opinion. Nothing forces the question now that perch is free, so it
  stays open rather than pending: whoever reopens selling picks up an
  individual-trading-as at that point, or incorporates.
- **It is not the gallery** → **it hosts the gallery**, at `/desktops` (§5).
  The 2026-08-06 amendment that made hausfold.co a real page rather than a
  placeholder was the first step of this reversal; this finishes it.

One known exposure, now larger: **`hausfold.com` isn't held**, and the name is
about to be the platform, the docs domain, *and* the seller spoken aloud in
receipts and terms. Accepted as `.co` on 2026-08-08 — see §9.

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
- Don't gate perch's *downloads*, and don't reintroduce a gate inside the
  binary either. Perch is free and MIT as of 2026-08-15; there is nothing to
  paywall.

## 9. Open decisions

| # | Decision | Status |
|---|---|---|
| 1 | Is hausfold the umbrella/commercial identity, or a future product brand? | ~~Decided 2026-08-04: umbrella~~ → **Reversed 2026-08-08: hausfold makes the platform** (and is still the seller) → **refined 2026-08-10: the layer is `haus`, hausfold is the org/maker/seller** (decision 8) — §6. Successor question unchanged, and no longer forced by anything on the calendar: if the family ever sells, does the seller incorporate, or sell as an individual trading as hausfold? |
| 2 | Archive trill? | **Closed** — archived on GitHub, module and flake input deleted (rice#212/#213), taken out of every family list. The launch-blocking version of this question is gone. |
| 3 | Does holt get its own launch moment or ride the house's? | Open. Its own — its audience shares almost nothing with the rice's. |
| 4 | `hausfold.com` — buy it or accept the `.co`? | **Closed 2026-08-08: accept the `.co`, because there is nothing to buy.** ~~Still cheap to reverse; still gets more expensive with brand value.~~ Checked the same day: the `.com` has been registered since 2025-04 and serves **HAUS FOLD**, an operating in-home laundry service in South Carolina. Not parked, not for sale. The `.co`-beside-someone-else's-`.com` tax is real and permanent — the name is the platform, the docs domain *and* the seller on a receipt — but it was never avoidable. Promotes the trademark question: same word, first in time, US commercial use, plausibly different Nice classes. ~~**Get a real USPTO search before filing, marketing spend, or incorporation.**~~ ✅ **Searched 2026-08-10** (USPTO + EUIPO + ~73 offices via TMview): `hausfold` returns **zero records worldwide**, and this business has **never filed** — a common-law user, not a registrant. The trigger now reads: get a clearance **opinion** before filing, marketing spend, or incorporation, since common-law rights survive an empty register. |
| 5 | Does the site repo go public? | **Closed 2026-08-08 — yes, but as a new repo.** `hausfold/website` was never flipped: it has pull requests, GitHub keeps `refs/pull/N/head` forever, and `git filter-repo` doesn't GC them — so a scrub-and-flip would have removed nothing that mattered. ~~Price: scrub the cached account blob before flipping.~~ That price didn't buy anything. The site is now **[`hausfold/hausfold.co`](https://github.com/hausfold/hausfold.co)**, public, one commit; `hausfold/website` is archived and **stays private permanently**. The specifics stay in the private repo, since this one is public. |
| 6 | Where does `PRESENCE.md` live once the site repo is public? | **Closed 2026-08-08 — [`hausfold/ops`](https://github.com/hausfold/ops), private, created and populated.** Its eleven revisions were replayed rather than `git mv`'d, because a move leaves every past revision in the source repo's history. The rest of the ops surface goes there too — where credentials live (not the credentials), account facts, the annual re-check. ⚠️ The wrong answer, recorded so it isn't re-derived: **not** `notes/` in this repo — **the workshop is public**, so that move publishes the gap list rather than protecting it. |

# Perch monetization — the plan

Working doc. Decided 2026-08-03 after the comparables research (Screen Studio /
MacWhisper / NotchNook / ONCE / Beeper — see the PR that added this file for
sources). Perch goes first because its category has an existence proof
(NotchNook, ~$100k on $25 one-time) and because every rail built here is
trill's for free — `UpdateCheck` was ported trill→perch, and the license layer
rides the same seam back. Perch is now the *whole* bet, not the warm-up:
**[§5](#5-trill--why-it-isnt-the-bet) records why trill isn't monetized**, since
that was the original flagship and the reasoning is worth not re-deriving.
⚠️ **"trill" in this file — not only in §5 — is the archived Messages client**
(`hausfold/messages` since 2026-08-08). The notification compositor took the
name that day; it is a
different product and its monetization question is unasked.

This file owns **how perch charges**. *When* it launches relative to the free
family — and what every other repo is for — is
[`go-to-market.md`](./go-to-market.md). One thing that file asks of this one:
**Phase 0 runs before the free launch, not after it**, so the MIT install base
never grows past you.

**The one principle: the paywall lives in the binary, never in the
distribution.** Perch ships through four doors (cask, direct ZIP, rice copy,
bare nix), all fed by public GitHub release artifacts, with a CI-owned tap bump
and `bench release`'s blocking CI watch. Gating downloads would break all of it
at once — cask URL, `/download/perch`, the rice's ZIP wrap, the update nudge's
cohort hints. So: **releases stay public, all four doors stay open, the app
itself carries the gate.**

---

## 1. Decisions (locked)

| Decision | Choice | Why |
|---|---|---|
| License | **FSL-1.1-Apache-2.0** (perch only) | Source stays on GitHub, competitors can't redistribute builds, each release auto-converts to Apache-2.0 after 2 years — the honest version of "stay largely OSS". MIT can't forbid ungated binary mirrors. haus / nebelung / pounce stay MIT. |
| Model | One-time purchase, **1 year of updates**, license works forever on covered builds | The model every winner in the cohort converged on (CleanShot, MacWhisper, Dropover). ONCE's purer version is the documented failure; subscriptions need a service perch doesn't have. |
| Update-year enforcement | **CalVer IS the entitlement** | A license covers builds dated ≤ purchase + 1 yr. The app compares its own `VERSION` date to the license date. No version bookkeeping, transparent to users, `bench release` unchanged. |
| Gate shape | **Capacity cap, not a trial timer** — free tier is a working shelf capped at 3 tiles | Perch's value is habitual; a cap lets light use stay free forever (goodwill + funnel) and converts exactly the people who feel the value. Trial timers need tamper-resistant state, and the sandbox container is trivially resettable — a cap is stateless and honest. |
| License validation | **Offline** — Ed25519-signed license file, public key baked into the app | The README's load-bearing sentence — "the only network call is the hourly release check" — survives. No activation server, no phone-home, works on an air-gapped Mac. Paddle/LS built-in key activation is exactly the call we refuse to add. |
| Price | **$19**, renewal $9 for another update year | NotchNook $25 / Yoink $9 / Dropover $5; perch's "dependability and restraint" positioning sits above the impulse tier, below the category king. |
| Rice door | **No special-casing** — rice installs hit the same in-app gate | One code path, and no "why do nix users get it free" resentment. FSL permits personal builds from source (non-compete use), so the bare-nix door stays legal too — someone determined to not pay $19 was never a customer. |
| Merchant of record | **Paddle** (re-confirmed 2026-08-04) | 5% + 50¢ = $1.45 on $19, MoR handles VAT/GST, mature enough to outlive an update year, and its overlay checkout is the one Phase 3 wants. Fallback is **Polar** — see [§2.1](#21-why-paddle-and-not-the-other-four). |

## 2. The license file format — design it once, for both apps

`.perchlicense` — a signed JSON blob. The filename is Perch-specific; the
payload remains product-scoped so trill can reuse the format, signer, and mail
template under its own extension:

```json
{
  "product": "perch",
  "email": "buyer@example.com",
  "purchased": "2026-08-03",
  "seats": 3,
  "sig": "<Ed25519 over the canonical payload>"
}
```

- Verify in Swift with CryptoKit (`Curve25519.Signing`) — ~40 lines, no deps.
- Import via the standard file picker **or by dropping the file on the shelf**
  (sandbox-legal, and the most perch way imaginable to activate perch).
- Licensed iff `product == "perch"` && sig verifies. Covered iff
  `VERSION`-date ≤ `purchased` + 1 yr; an uncovered build runs the free tier
  with a strip that says which builds the license does cover.
- Private key: a Cloudflare Worker secret + one offline backup. Public key:
  a constant in the app. A keygen/sign script lives in `hausfold.co/scripts/`.
  ⚠️ This said `web/scripts/` when it was written; the workshop's `web/` became
  hausfold.co's 301 map on 2026-08-14 and has no scripts dir. The Worker that
  would sign a licence is hausfold.co's, so the script belongs beside it.

### 2.1 Why Paddle, and not the other four

Because the Worker signs its own licenses, **every provider's license-key and
entitlement system is dead weight** — the only surface that matters is a signed
webhook carrying buyer email, product id and date, which all five have. That
collapses the comparison to fee, vendor survival, and approval friction:

| Provider | Fee on $19 | Why not |
|---|---|---|
| **Paddle** | 5% + 50¢ = **$1.45** (7.6%) | — the pick. |
| Polar | 5% + 50¢ = $1.45 | Best DX (open source, API-first), same fee — but a startup that raised prices 25% in May 2026 (4%+40¢ → 5%+50¢, old rate grandfathered only for pre-2026-05-27 accounts). Fine as the fallback; reversal is cheap until launch. |
| Lemon Squeezy | 5% + 50¢ = $1.45 | **Not dead, but stagnant.** Signups open and pricing unchanged, yet Stripe (which acquired it) is steering users to Stripe Managed Payments and its own founders promise "less frequent product updates". Don't build a new rail on a product whose roadmap is a migration path. |
| Stripe Managed Payments | 6.4% + 30¢ domestic, 8%+ international | LS's actual successor and the likely long-term default, but still rolling out and US-business-gated in 2026. Too early; revisit at renewal time. |
| Gumroad | 10% + 50¢ **plus** 2.9% + 30¢ processing ≈ **$2.75** (14.5%) | ~2× Paddle's take, ~$1.30/sale — more than the license layer costs to build, at any volume worth having. |

The one operational catch: **Paddle reviews an account before it can take live
payments**, and that gate sits in front of Phase 2. Sandbox works immediately,
so the application runs in parallel with Phase 1, not after it.

## 3. Phases

**Phase 0 — relicense, before any paid build exists** *(one session; do first —
it's the only step that gets harder after revenue)*
✅ **Phase 0 is DONE — perch#26, 2026-08-03.** It was the gate on the tester
round ([`launch-phase-1.md` §0](./launch-phase-1.md)), so everyone invited now
installs a fair-source perch rather than an MIT one.
- [x] Authorship verified 2026-08-03: `git shortlog -sne` shows only Julien
      (both identities) + haus-release[bot] — relicense is a commit, not a CLA hunt.
- [x] `LICENSE` → FSL-1.1-ALv2 (text from fsl.software), README badge +
      "why fair source" paragraph.
      ⚠️ **The docs-site half was missed for two days**: hausfold.co's
      `start/the-family.md` still read *"All of haus is MIT-licensed"*
      after org-profile#14 had already corrected the identical sentence in the
      GitHub footer. Fixed 2026-08-05. **A relicense is a claim to grep for,
      not a file to edit** — it appears wherever anyone once summarised the
      family, which is more places than the repo that changed.
- [x] Leave every shipped MIT release alone — FSL applies from the next tag,
      and 2026.08.04 is the first one.

**Phase 1 — the license layer in the app** ✅ **shipped in perch#27, and
deliberately INERT** *(~2–3 sessions; the big one)*
- [x] `Perch/Platform/License.swift` + `LicenseStore.swift`: parse + verify +
      covered-date logic against a baked-in Ed25519 key, no server, no sign-in,
      no network call. `PerchTests/LicenseTests.swift`, 20 tests.
- [x] Free-tier cap — **2 tiles, not 3.** Admission is decided in `ShelfStore`
      *before* staging, so a refused item is never copied and no drag is
      interrupted. The arithmetic test pins the SHAPE of the rule against
      `freeTierCapacity` rather than literals, plus a guard that it can never
      reach zero (a free tier of zero is a hard paywall in a free tier's
      clothes).
- [x] Settings → License pane, gated on `LicenseStore.canSell` — which is
      `false` until the public key constant lands in Phase 2. **The cap and the
      ability to honour a license are ONE switch**: a paywall with no
      purchasable door is worse than no paywall.
- [x] `DEBUG` builds: always licensed, same as the update check's guard.
- [ ] Still Phase 2's, and the reason none of the above is visible to a user
      yet: mint the keypair, bake the public key, and flip `canSell`.
      `perch/docs/going-paid.md` is the runbook for that day.

**Phase 2 — commerce rails** *(~1 session of work, but see the approval wait)*
- [ ] **Apply to Paddle during Phase 1, not after it.** Approval is days, not
      minutes, and it wants a live hausfold.co/perch page (even pre-rewrite)
      with refund + terms links. MoR also insulates from the exact
      Stripe-withholding story that hit NotchNook. Rationale + the rejected
      alternatives: [§2.1](#21-why-paddle-and-not-the-other-four).
- [ ] Worker webhook `/api/license/issue`: verify Paddle's HMAC signature
      *first*, then `transaction.completed` → sign license → email the file
      (the Worker already owns `/download/*` + `/api/release/*`; this is a
      third route, not a new service).
- [ ] Renewal SKU = same product, re-issues the file with a new `purchased`.
      Two Paddle products, one route: `perch` $19, `perch-renewal` $9.
- [ ] Build and test against the **sandbox** while approval runs; a real
      purchase end-to-end before touching copy.
- [ ] Payout minimum is $100 by default — ≈6 sales before the first wire.
      Silence early on is the threshold, not a broken webhook.

**Phase 3 — the storefront** *(~1–2 sessions)*
- [ ] hausfold.co/perch rewritten in consumer voice — outcomes, not lingo:
      no "rice", no "nix", no "sandbox-friendly menu-bar app". The pitch is
      the README's opening dance ("drag, realise the window is buried…"),
      the privacy restraint, and the price. Dev detail moves below the fold.
- [ ] Paddle overlay checkout on that page; FAQ covers fair-source, the
      update-year, seats, refunds (MoR handles the mechanics).
- [ ] An SLA for **`hi@hausfold.co`** that you'll actually honor — paying
      customers change the tone of the issue tracker. ✅ The *mailbox* half of
      this box is closed: `hi@` already routes and is already the contact on
      `/terms` and `/refunds`, so nothing has to be created before the first
      receipt. What's left is the promise, not the address.
      *(Was `support@hausfold.co`, on the reasoning that people bought a
      haus product. Reversed 2026-08-08 with [`go-to-market.md`](./go-to-market.md)
      §6: they buy a hausfold product now, and hausfold is the name on the
      receipt they'll already have seen. Then briefly `support@hausfold.co` —
      settled to `hi@` 2026-08-09.)*

**Phase 4 — launch** *(gated on me, like any release)*
- [ ] First FSL + gated build ships via the normal `bench release perch`.
- [ ] Announce: the fair-source angle is itself the story for HN/lobste.rs;
      the notch angle is the story for the Mac press that covered NotchNook.
- [ ] Later, not launch: Setapp application as channel #2. (A whole-house
      bundle needs a second paid app, which trill is not — see §5.)

## 4. Watch-outs

- **The privacy sentence is a contract.** Any future licensing feature that
  wants a network call loses to the sentence. Offline-only, forever.
- **Free-tier calibration is a product knob, not a code knob** — 3 tiles is a
  guess; watch conversion before moving it, and only ever move it *looser*
  (tightening reads as a rug-pull).
- **Old builds keep working forever.** The gate never expires a build someone's
  license covered — CalVer makes "covered" a fact about dates, not a server's
  opinion.
- **Trill is not a second product** — the format, signer and Worker route are
  still built so a second product is cheap, but trill isn't it. See
  [§5](#5-trill--why-it-isnt-the-bet).
- **`bench release` stays untouched end-to-end.** If any phase finds itself
  editing the release pipeline, the paywall is leaking out of the binary —
  stop and re-read the principle at the top.
## 5. Trill — why it isn't the bet

> ⚠️ **"Trill" throughout this section is the archived Messages client**, now
> `hausfold/messages`. The name was reused on 2026-08-08 by the notification
> compositor, which is a different product
> and has its own monetization question, unasked. Kept as written — this is a
> historical record of a decision, not a description of anything live.

**Decided 2026-08-04.** Trill was the intended flagship: highest potential in
the family eval, ~$39 one-time, positioned as "your local, private aggregator".
It is now **not a monetized product**, and its Beeper track is frozen
(`trill/docs/beeper-client-refactor.md`). Perch is the whole bet, not the
warm-up.

This section is kept, rather than deleted, so the reasoning doesn't have to be
re-derived the next time trill looks tempting.

### 5.1 What changed

Nothing about trill's code. What changed is understanding what it offers.

- **The aggregation is Beeper's.** It needs their app installed, signed in and
  running; its networks route through their *cloud* bridges; the API is an
  experimental public beta owned by Automattic, who also own the aggregator
  client we'd compete with. "Local, private aggregator" was three claims and
  only "local" was fully ours.
- **"Why not just use Beeper Desktop?" has no good answer.** For anyone who
  already runs Beeper, trill is a nicer face on their free product. That is not
  a $39 pitch.
- **The native half is structurally limited.** Read and send, and that's it —
  no tapbacks, no threaded replies, no upstream mark-read, no edits, ever, from
  the native path. AppleScript is the only send surface Messages.app exposes. A
  paying customer hits that wall in week one.
- **Highest dependency surface in the family, lowest control.** Apple's private
  `chat.db` schema, three TCC permissions, AppleScript, and a third party's
  beta API. Perch depends on nothing but AppKit.
- **The author doesn't use it daily.** An app its own maker reaches past is not
  the one to ask strangers to pay for.

### 5.2 The gate design is what killed it

Worth recording, because the exercise did its job: designing the paywall is
what made the value legible.

The gate landed on the overlay database (`Persistence/AppDatabase`) — free =
read, reply, search; paid = folders and tags, VIP, snooze/archive/mute, saved
messages, multi-tab, library, exports and stats. Elegant seam, honest split.
Then read it back in plain words: **$39 for a nicer inbox on top of a free
app.** No amount of positioning fixes that sentence, and writing it down is
what surfaced it — before a lifetime license was sold against a third party's
beta, which is the point at which this becomes expensive rather than merely
disappointing.

### 5.3 Consequences

- **No FSL relicense for trill.** It stays MIT — Phase 0 exists to protect
  revenue, and there is none. One session saved.
- **No license layer, no landing page, no $39.** §1–§4 remain perch-only.
- **The Beeper track is frozen**, not deleted: shipped code stays and is inert
  (no token ⇒ the provider isn't constructed). Reversing a decision is cheaper
  than rebuilding an adapter.
- **Trill is a free MIT rice app** for now. Whether it stays in the rice by
  default, in the marketing copy, and unarchived on GitHub is the open call in
  §5.5.

### 5.4 The lesson that generalizes

Add a column to the next family eval: **what does this depend on that I don't
control?** Trill scores worst (Apple's private schema, TCC, AppleScript, a
third party's beta). Perch scores best (self-contained, no permissions, no
network beyond its own release check). The old eval ranked by market size and
put trill first; ranking by controllable surface inverts it — and the second
ranking is the one that predicts whether the work is finishable by one person.

Run perch first regardless. One shipped product teaches more about whether
people pay than another eval will, and the eval keeps.

### 5.5 ✅ Settled: trill is archived

Decided the day after this section was written, and decided by **removal rather
than by the note** it proposed — which turned out to be the better answer, since
nothing now hands a tester an unmaintained app in the first place.

- [x] The rice: **rice#212** made it opt-in, **rice#213** deleted the module and
      the flake input a day later. The sentence worth reusing is #213's — *a
      supported option nobody should turn on is a lie in the option reference.*
- [x] Marketing copy: workshop#204 (hausfold.co + the family lists),
      org-profile#14 (the GitHub front page).
- [x] `homebrew-tap`'s `Casks/trill.rb` — **tap#10** deprecated the cask,
      **tap#11** stopped naming the final version in prose. Existing installs
      keep working, as predicted.
- [x] A final release: 2026.08.04 / 2026.08.04-1 shipped through the tap with
      the deprecation, so anyone who installed it learns the status from
      `brew`.
- [x] Archived on GitHub. The read-only `chat.db` reader and the typedstream
      decoder stay readable, which was the point of archiving rather than
      deleting.

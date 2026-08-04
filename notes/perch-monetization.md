# Perch monetization — the plan

Working doc. Decided 2026-08-03 after the comparables research (Screen Studio /
MacWhisper / NotchNook / ONCE / Beeper — see the PR that added this file for
sources). Perch goes first because its category has an existence proof
(NotchNook, ~$100k on $25 one-time) and because every rail built here is
trill's for free — `UpdateCheck` was ported trill→perch, and the license layer
rides the same seam back. **[§5](#5-trill--the-second-product) carries trill's
own plan**: it inherits everything here except its positioning, its gate shape
and its price, and it has one dependency perch doesn't.

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
| License | **FSL-1.1-Apache-2.0** (perch only) | Source stays on GitHub, competitors can't redistribute builds, each release auto-converts to Apache-2.0 after 2 years — the honest version of "stay largely OSS". MIT can't forbid ungated binary mirrors. nebelhaus / nebelung / pounce stay MIT. |
| Model | One-time purchase, **1 year of updates**, license works forever on covered builds | The model every winner in the cohort converged on (CleanShot, MacWhisper, Dropover). ONCE's purer version is the documented failure; subscriptions need a service perch doesn't have. |
| Update-year enforcement | **CalVer IS the entitlement** | A license covers builds dated ≤ purchase + 1 yr. The app compares its own `VERSION` date to the license date. No version bookkeeping, transparent to users, `bench release` unchanged. |
| Gate shape | **Capacity cap, not a trial timer** — free tier is a working shelf capped at 3 tiles | Perch's value is habitual; a cap lets light use stay free forever (goodwill + funnel) and converts exactly the people who feel the value. Trial timers need tamper-resistant state, and the sandbox container is trivially resettable — a cap is stateless and honest. |
| License validation | **Offline** — Ed25519-signed license file, public key baked into the app | The README's load-bearing sentence — "the only network call is the hourly release check" — survives. No activation server, no phone-home, works on an air-gapped Mac. Paddle/LS built-in key activation is exactly the call we refuse to add. |
| Price | **$19**, renewal $9 for another update year | NotchNook $25 / Yoink $9 / Dropover $5; perch's "dependability and restraint" positioning sits above the impulse tier, below the category king. |
| Rice door | **No special-casing** — rice installs hit the same in-app gate | One code path, and no "why do nix users get it free" resentment. FSL permits personal builds from source (non-compete use), so the bare-nix door stays legal too — someone determined to not pay $19 was never a customer. |

## 2. The license file format — design it once, for both apps

`.nebelhauslicense` — a signed JSON blob, product-scoped so trill reuses the
format, the signer, and the mail template untouched:

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
  a constant in the app. A keygen/sign script lives in `web/scripts/`.

## 3. Phases

**Phase 0 — relicense, before any paid build exists** *(one session; do first —
it's the only step that gets harder after revenue)*
- [ ] Authorship verified 2026-08-03: `git shortlog -sne` shows only Julien
      (both identities) + haus-release[bot] — relicense is a commit, not a CLA hunt.
- [ ] `LICENSE` → FSL-1.1-Apache-2.0 (text from fsl.software), README badge +
      "why fair source" paragraph, `docs/` + nebelhaus.com/perch note.
- [ ] Leave every shipped MIT release alone — FSL applies from the next tag.

**Phase 1 — the license layer in the app** *(~2–3 sessions; the big one)*
- [ ] `Perch/Platform/License.swift`: parse + verify + covered-date logic,
      unit-tested against known-good/known-bad fixtures (mirror
      `UpdateCheckTests` style).
- [ ] Free-tier cap: shelf accepts 3 tiles unlicensed; the 4th slides in a
      strip (reuse the update-strip surface) — never block a drag mid-flight,
      never lose a drop. The cap message is the whole marketing funnel; write
      it kindly.
- [ ] Settings → License pane: state, seat count, covered-through date, import
      button. Update nudge grows one line when the newer build is outside
      coverage ("covered through 2027.08 — renew to update").
- [ ] `DEBUG` builds: always licensed, same as the update check's guard.

**Phase 2 — commerce rails** *(~1 session)*
- [ ] Merchant of record: **Paddle** (recommended — mature, MoR insulates from
      the exact Stripe-withholding story that hit NotchNook; LemonSqueezy is
      the fallback, reversal is cheap until launch).
- [ ] Worker webhook `/api/license/issue`: Paddle event → sign license → email
      the file (the Worker already owns `/download/*` + `/api/release/*`;
      this is a third route, not a new service).
- [ ] Renewal SKU = same product, re-issues the file with a new `purchased`.
- [ ] Test-mode purchase end-to-end before touching copy.

**Phase 3 — the storefront** *(~1–2 sessions)*
- [ ] nebelhaus.com/perch rewritten in consumer voice — outcomes, not lingo:
      no "rice", no "nix", no "sandbox-friendly menu-bar app". The pitch is
      the README's opening dance ("drag, realise the window is buried…"),
      the privacy restraint, and the price. Dev detail moves below the fold.
- [ ] Paddle overlay checkout on that page; FAQ covers fair-source, the
      update-year, seats, refunds (MoR handles the mechanics).
- [ ] `support@nebelhaus.com` (or alias) with an SLA you'll actually honor —
      paying customers change the tone of the issue tracker.

**Phase 4 — launch** *(gated on me, like any release)*
- [ ] First FSL + gated build ships via the normal `bench release perch`.
- [ ] Announce: the fair-source angle is itself the story for HN/lobste.rs;
      the notch angle is the story for the Mac press that covered NotchNook.
- [ ] Later, not launch: Setapp application as channel #2; the $49
      whole-house bundle once trill is paid too.

## 4. Watch-outs

- **The privacy sentence is a contract.** Any future licensing feature that
  wants a network call loses to the sentence. Offline-only, forever.
- **Free-tier calibration is a product knob, not a code knob** — 3 tiles is a
  guess; watch conversion before moving it, and only ever move it *looser*
  (tightening reads as a rug-pull).
- **Old builds keep working forever.** The gate never expires a build someone's
  license covered — CalVer makes "covered" a fact about dates, not a server's
  opinion.
- **Trill inherits everything** — format, signer, Worker route, Settings pane
  shape. Its own work is positioning, gate shape and price: see [§5](#5-trill--the-second-product).
- **`bench release` stays untouched end-to-end.** If any phase finds itself
  editing the release pipeline, the paywall is leaking out of the binary —
  stop and re-read the principle at the top.

## 5. Trill — the second product

Everything in §1–§4 applies unchanged unless contradicted here. Perch still
ships first; this section exists so the decisions taken while trill's Beeper
work was fresh don't have to be re-derived later.

### 5.1 Positioning — decided 2026-08-04

**The headline is the native client. Beeper is a bullet below the fold.**

The earlier pitch was "your local, private aggregator". Building the Beeper
adapter established that this is two claims and only one of them is fully ours:

| Claim | Reality |
|---|---|
| **Local** | True, strongly. iMessage/SMS/RCS is read-only `chat.db`, in-process, no account, no server, no network call to read a message. |
| **Private** | True for the native half. Beeper networks route through Beeper's **cloud** bridges — not our architecture, and not something we can fix. |
| **Aggregator** | The aggregation is *Beeper's*. It needs their app installed, signed in, running, with the dev API enabled. |

So the promise we can keep is "the fast, flat, keyboard-first Messages client
for macOS" — finished, ours, owes nothing to anyone. "Works with your Beeper
networks too" sits underneath it. This is not modesty; it is what keeps a
**lifetime** license honest when the thing underneath it is a third party's
public beta (§5.4).

### 5.2 Price and gate shape

| Decision | Choice | Why |
|---|---|---|
| Price | **$39**, renewal $19 for another update year | Working number from the market eval. A daily-driver comms app sits above perch's $19 utility tier. Same one-time + 1-year-of-updates model, same CalVer entitlement — nothing new to build. |
| License file | Identical, `"product": "trill"` | The format is already product-scoped. Signer, Worker route, mail template, Settings pane shape all reused verbatim. |
| Gate shape | **Feature tier, not a cap and not a trial timer** — *proposed, needs a call* | A conversation cap is unusable (people would just reopen Messages.app) and a timer is resettable state. The honest split is **free = read, reply, search, one window** and **paid = the organizer layer**: folders/tags, VIP, snooze/archive/mute, saved messages, multi-tab, exports, stats. Light users stay free forever; the people who make trill their inbox convert. |
| What is **never** behind the gate | Beeper aggregation | Gating it would make the paid tier depend on someone else's beta API. It is a bullet, not a SKU. |
| Rice door | No special-casing, same as perch | But see §5.4 — trill ships by default in the rice, so this one is felt harder. |

### 5.3 Phase 0 for trill — do it now

Same reasoning as perch's: it is the only step that gets harder after revenue,
and it is independent of everything Beeper.

- [ ] Verify authorship with `git shortlog -sne` (expected: Julien's two
      identities + `haus-release[bot]`, same as perch).
- [ ] `LICENSE` MIT → FSL-1.1-Apache-2.0. Every shipped MIT release stays MIT;
      FSL applies from the next tag.
- [ ] README badge + "why fair source" paragraph; note it on nebelhaus.com.
- [ ] `AGENTS.md`'s conventions line says "MIT, public" — update it in the same
      commit or the next agent will re-assert MIT.

Public artifacts stay public, so the cask and `nix/release.nix` are unaffected:
FSL forbids redistributing *competing builds*, not downloading ours.

### 5.4 Watch-outs specific to trill

- **The Beeper Desktop API is an experimental public beta, and Automattic owns
  it.** They also own Texts.app — the aggregator client is *their* product. A
  lifetime license must never promise a feature they can withdraw. This is the
  single strongest reason §5.1 went the way it did.
- **Disclose the Beeper dependency on the storefront, above the fold of the
  FAQ.** It is free for up to 5 networks and $9.99/mo beyond that (Beeper
  Plus), and it requires *their* app running. A customer who buys "one inbox"
  and discovers a second app to install is a refund, and with a merchant of
  record that is a chargeback.
- **Perch's privacy sentence does not port.** "The only network call is the
  hourly release check" is false for trill — update check, link previews, and
  Beeper when configured. Write trill's own sentence and make it equally
  load-bearing: *reads your Messages database read-only, never writes to it,
  and sends nothing anywhere you didn't configure.*
- **One binary, one signing identity, forever.** macOS keys Full Disk Access to
  the signature, and `UpdateCheck` already refuses a download whose identity
  differs from the running app. A separate "paid build" or a changed bundle id
  would silently cost every user their FDA grant. The gate goes *inside* the
  same bundle — which is the top-of-document principle, with teeth.
- **The rice ships trill by default** (`nebelhaus.trill.enable`), so unlike
  perch the gate lands on rice users at their next rebuild without them having
  chosen to install anything. Same code path — but the free tier has to be
  genuinely usable, or a rebuild feels like a downgrade.
- **Don't sell the aggregation until §5's ship gate closes.** It is still
  unvalidated against a live Beeper Server — see
  `trill/docs/beeper-client-refactor.md` §5 and
  `scripts/beeper-contract-check.sh`. Closing it is free: install Beeper
  Desktop, enable Settings → Developers, run the script.

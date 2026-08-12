# The hausfold rename — a walkthrough

Working doc, written 2026-08-08. **Separates `hausfold` (the org, the maker,
the seller) from `nebelhaus` (one rice — the developer-focused one, and the
first).** The nix-darwin layer between them is **`haus`**, which is also its
CLI and its option namespace — amended 2026-08-10, decision 8 below, and it is
a naming refinement rather than a fourth position: nothing in code moves.

This is the walkable version: every step is tagged 👤 (you, at a keyboard or a
web console) or 🤖 (an agent, unattended), in dependency order, with a gate at
the end of each phase. Work it top to bottom. A phase that isn't gated green
does not unblock the next one.

**Read §0 before starting anything.** It contains the one deadline and the one
irreversible step.

---

## The decisions, already made

Taken 2026-08-08, in conversation. Recorded here so no later session re-opens
them:

| # | Decision | |
|---|---|---|
| 1 | Option namespace becomes **`haus.*`** | brand ≠ namespace, the nixos/nixpkgs pattern. `haus` is already the verb (`haus rebuild`/`set`/`doctor`/`rollback`). |
| 2 | **Transfer + rename in place** — `nebelhaus/nebelhaus` → `hausfold/hausfold` | keeps history, issues, PR links, git redirects. |
| 3 | **`hausfold.co`**, accept the `.co` | `hausfold.com` isn't unbought, it's **unbuyable** — an operating laundry business holds it, checked 2026-08-08. §0.4. |
| 4 | **Rename now, neutralize defaults later** | the sweep is mechanical and provable; the rice carve-out is design work (§7). |
| 5 | **All Apple bundle IDs move to `com.hausfold.*`** | free today, impossible after an App Store record exists. |
| 6 | **All 8 repos transfer to the `hausfold` org** | plus the `holt-swift` mirror. ⚠️ **Amended 2026-08-08 — the archived `trill` does NOT transfer.** It is renamed in place and stays in `nebelhaus`, because the notification compositor claims `hausfold/trill`. See §3.4. |
| 7 | **One site repo: `hausfold/hausfold.co`** | `/`, `/haus`, `/docs`, `/desktops`, `/holt`, `/pounce`, `/perch` (`/haus` added 2026-08-10 with decision 8). `workshop/web` folds into it and the landing pages are redesigned, not ported — see §5.1. *(Was `hausfold/website`, which is archived and private; the new repo was created 2026-08-08.)* |
| 8 | **The layer's public name is `haus`; `hausfold` is the org, the maker and the seller** | added 2026-08-10, in conversation, after looking at the page. **This refines decision 1, it does not reverse it** — see the box below. |
| 9 | **The layer's repo is `hausfold/haus`, its checkout `./haus`** | added 2026-08-11, in conversation. Decision 8 said hausfold is never the layer; `hausfold/hausfold` said it was. **§10** is the walkthrough. |

#### Decision 8, spelled out — because it looks like a third flip and isn't

**Say `haus` when you mean the nix-darwin layer. Say `hausfold` when you mean
who makes it, sells it, and owns the org.** So: *haus* is the platform, *nebelhaus*
is one rice on it, *pounce/perch/holt/trill* are the apps, and *hausfold* is the
house all of that ships from and the name on the receipt.

Why this isn't a re-reversal of 2026-08-08. That reversal answered **"is hausfold
merely a holding company?"** — no: it makes the platform, and the org and the
repos move to it. All of that **stands**. Decision 8 answers a different and
narrower question the reversal never asked: **which word do we put in front of a
user for the layer itself?** And the answer was already sitting in decision 1 —
`haus` is the verb they type (`haus rebuild`) *and* the namespace they write
(`haus.*`), so they will call it haus no matter what the site says. Naming it
hausfold makes the copy fight the muscle memory.

Read decision 1's *brand ≠ namespace* as what it was defending: **the namespace
must not be named after one desktop.** It isn't. That the namespace and the
layer's name now coincide is the ordinary nix shape, not a collision — nobody
is confused that home-manager's options live under `home.*`, or that
`nix-darwin`'s CLI is `darwin-rebuild`.

What this costs, and doesn't:

- **Nothing in code.** The namespace was already `haus.*` (§1.1a, landed), the
  org already `hausfold` (§3.2, transferred), the domain already `hausfold.co`.
  This is a **copy** decision. It renames no option and no bundle id.
  ⚠️ **Amended 2026-08-11 — it did, in the end, rename one repo.** Decision 9
  took the sentence "hausfold is never the layer" literally and applied it to
  the one identifier decision 8 had left standing: `hausfold/hausfold` became
  **`hausfold/haus`**, checkout `./haus`. That is a slug and a directory, not a
  namespace or an id; **§10** is the walkthrough and the blast radius. The rest
  of this box stands exactly as written.
- **§3 and §4 are untouched.** Don't re-open the org migration or the bundle
  ids over this. **§5 gains exactly one thing**: the route `/haus`, added to
  decision 7's list and §5.1's, and nothing else about the domain moves.
- 🚨 **Do NOT sweep `hausfold` → `haus`, and do not let §2 sweep the other
  way either.** Every remaining spelling still names the thing it always named,
  and `hausfold` is a live *identifier* — `bench`'s `GH_ORG`, the whole
  `com.hausfold.*` bundle-id family, `hausfold.co`, the `hausfold/tap` Homebrew
  taps and every `github.com/hausfold/<repo>` URL — so a sweep breaks the build,
  not just the copy. The word changes only where **prose** meant the layer.
  §2's class table (in §2, not at the top of this file) has been amended to
  match; the `nebelhaus` reading table at the top of `AGENTS.md` is the rule for
  reading a `nebelhaus` hit, and is unaffected.
  ⚠️ **Amended 2026-08-11 — the identifier list above USED to name `FAMILY`,
  `OVERRIDABLE`, `$ROOT/hausfold`, the release arms, `test/bench.bats`'s
  fixtures and `keybindings-drift.yml`'s `repository:`. §10 renamed exactly
  those, deliberately and together, because every one of them names the layer's
  *repo* rather than the org.** That is a decided, one-shot move with tests
  behind it — it is **not** licence to reopen the sweep. A `hausfold` hit today
  is the org, the brand, a bundle id, or the site; if you think you've found a
  repo-sense one that §10 missed, it's a bug, and it is still not a find-replace.
- ✅ **The prose surfaces that say "hausfold" and mean the layer — swept
  2026-08-10, workshop#313.** §0.1's precedent applied here, because a decision
  left unwritten gets "corrected" back by the next session. Landed in one PR:
  `.agents/skills/docs-sync/SKILL.md` (the daily sweep *writes* its wording into
  other repos, so a stale line there propagates), then this repo's `AGENTS.md`
  and `README.md`. Then, when convenient: `notes/options-roadmap.md`'s naming
  banner, `notes/go-to-market.md`'s "read this first" box and its portfolio
  table, and `bench`'s ripple-diagram comment (`bench:6` now reads *hausfold
  (the haus layer)*). In the **rice repo** (a separate
  checkout): `hausfold/AGENTS.md` and `hausfold/README.md` — ✅ **done
  2026-08-10, [hausfold#305](https://github.com/hausfold/hausfold/pull/305)**;
  the gap there turned out not to be a wrong platform claim (neither file had
  one) but the missing layer-vs-rice distinction. Untouched on
  purpose: `notes/perch-monetization.md` (receipt/seller sense — correct as
  written) and every repo-name or workflow reference.
  ⚠️ **Neither file ever called the layer "hausfold" — measured, not assumed**,
  and worth keeping because the *shape* of that gap is the reusable part. A
  grep of the rice's `AGENTS.md`, `README.md`, `docs/` and `.agents/`, excluding
  the domain, the org, the repo slug, the checkout path and PR refs, returns
  **zero layer-sense hits**. So there was never a wrong word to replace; what
  #305 added was a distinction those files had never drawn. Don't read "the rice
  repo is behind" as licence to sweep `hausfold` → `haus` there — the sweep
  would have found nothing and broken identifiers looking.
- ✅ **`PRESENCE.md` in `hausfold/ops` needed the same header amendment**, and
  was the one place to check whether a public-facing `haus` wants a register row
  of its own. **Both done 2026-08-10, in that repo.** The answer and its
  reasoning stay there and are deliberately not restated here — the workshop is
  public, and it is the *shape* of the reasoning, not just the gaps, that has to
  stay private. If a later session finds itself about to fill in §0.2's matrix
  for `haus` in *this* repo, that's the mistake: it belongs in `ops`.
- ✅ **§0.2's *register* half has now been run for `haus` too — 2026-08-10, and
  it does not disturb this decision.** This bullet used to predict "expect it
  taken on npm/PyPI and weak as a mark." The trademark register says: weak as
  predicted, but **not blocked** — one *pending* US class-42 application and no
  live registration in the software classes. **Don't file `haus`; the mark is
  `hausfold`**, which is what decision 8 already says. §0.2 has the numbers.
  ⚠️ **The namespace-availability half of that matrix is deliberately NOT here** —
  see the `PRESENCE.md` bullet above. Which handles and package names are free
  is register-of-gaps material and belongs in the private repo.

### And these three reverse earlier written decisions

`go-to-market.md` §6 (decided 2026-08-04) and `hausfold/ops`'s `PRESENCE.md` currently
say the opposite. **They are read by every agent session**, so if they aren't
rewritten first, a future session will "correct" this work back:

- ~~"hausfold is the umbrella, not a product brand"~~ → hausfold **is** the
  platform (and still the seller).
- ~~"nothing in the nebelhaus family migrates to the hausfold org, ever"~~ →
  everything does.
- ~~"the gallery lives at nebelhaus.com/rices, not hausfold.co"~~ →
  `hausfold.co/desktops`.

> **The gallery's path was `/market` throughout this document until
> 2026-08-08.** It was amended to **`/desktops`** the same day, after the page
> shipped under that name: a parallel session building it put `/market`,
> `/gallery`, `/rices` and `/desktops` to the user and was told `/desktops` —
> plainer English, a generic noun rather than a name, and therefore no row
> needed in `hausfold/ops`'s `PRESENCE.md`. Told the two had collided, the user chose to
> amend the plan rather than rename the live page.
>
> Two things the swap is **not**. It isn't a retreat from commerce — nothing
> about the word `market` was load-bearing for perch's paid line, which lives at
> `/perch`. And it doesn't reopen §5: *the gallery is on hausfold.co, not
> nebelhaus.com* is the decision and it stands. Only the noun moved.

One thing from §6 that survives and one that doesn't:

- ✅ *"funnels die at extra hops"* still holds — which is why nebelhaus.com
  **301s** to hausfold.co rather than merely coexisting.
- ❌ *"support stays support@nebelhaus.com, because people bought a nebelhaus
  product"* is now wrong: they buy a hausfold product. Support moves.

### Current handoff — 2026-08-12

**§5.2's first landing is in: `hausfold.co/docs` exists**, and four merged
batches take it to **eighteen of the twenty-nine pages**. The
Fumadocs build, the theme and the CI came with the first
([hausfold.co#12](https://github.com/hausfold/hausfold.co/pull/12), with #15
following as the colour pass); the daily-driver
guides — windows, apps, the terminal, theming, keybindings — came with the second
([hausfold.co#17](https://github.com/hausfold/hausfold.co/pull/17)); the launcher
pair, Touch ID and hush with the third
([hausfold.co#18](https://github.com/hausfold/hausfold.co/pull/18)); and the
coding-agents consolidation with the fourth. §5.2's
status box carries what each proved, what it changed and what is left — read that
before assuming any bullet further down this section is still the plan. The
three headlines: the docs are **two trees behind a sidebar switcher**
(`/docs/haus/*`, `/docs/nebelhaus/*`), which spends "preserve slugs"; porting a
page is a **rewrite to about half its length**, not a move; and the landing
pages **will** become Next routes (👤, 2026-08-12), which settles the one fork
§5.2 had left open.

⚠️ **The rewrite is finding real bugs in the old pages, which is an argument for
doing it rather than a cost of it.** Batch two's fact-check against the rice
turned up a roster example whose launcher key an assertion refuses outright
(`key = "e"` collides with launch mode's emoji key), and a palette binding that
does not exist. Both were fixed in `web/` too, in the same change as this note —
29 pages written against a moving target are 29 pages nobody has re-read since.

§5.2 is still the whole of the 🤖 work left on the rename proper — it is just no
longer untouched.

### Current handoff — 2026-08-11

**Decision 9 landed the layer's repo rename: `hausfold/hausfold` →
`hausfold/haus`, checkout `./hausfold` → `./haus`.** The slug moved on GitHub
first (redirects keep every old URL, clone, `raw.githubusercontent` fetch and
API call resolving), then one PR per repo rewrote the edges. **§10** is the
walkthrough, the blast radius and the one 👤 step: the *local checkout* is
machine state, not a diff, so it moves with `bench relocate-haus` when no agent
lane is standing in it.

Everything in the 2026-08-10 handoff below still holds — §5.2 is still the whole
of the 🤖 work left on the rename proper. §10 is a decision that arrived after
the plan was written, not a phase of it.

### Handoff — 2026-08-10 (morning)

**The rename is green through §4, and §5.2 is now the *whole* of the 🤖 work
left.** The option namespace, in-repo brand surface, GitHub transfers, checkout
rename, lock ripple, clean-clone gate **and** the Apple identity migration are
done. `bench try` builds the current local family, and the private consumer
uses canonical `haus.*` with no obsolete-option traces (`nix-config`
`452b9b8`).

**§5.2** is the docs/Worker consolidation into `hausfold/hausfold.co`, the
per-rice installer, and the `nebelhaus.com` 301s. 🚨 **It is a rebuild on
Fumadocs, not a port of the Astro/Starlight tree** (👤's call, 2026-08-09 — see
§5.2's decision box before reading anything below it as a move); its stack,
deployment shape and search are all decided and spiked, so what remains is
build work, not design work. **Every other open *step* in this document is 👤**
— audited 2026-08-10: all six unchecked boxes in the file carry 👤, and no 🤖
section outside §5.2 is unfinished. (The one exception is not a step: §9's
carry-over about a `.bak` sentence in `notes/launch-phase-1.md` is untagged and
belongs to that note, not to this one.)

What changed on 2026-08-10:

- **Decision 8 recorded and swept** — the layer's public name is `haus`,
  `hausfold` is the org/maker/seller (workshop#313). Its prose surfaces are
  done; the rice repo turned out to need nothing (grep-measured — see the ✅ in
  decision 8's box). ⚠️ It is **not** a licence to sweep `hausfold` → `haus`:
  the word is a live identifier in `bench` and in two workflows.
- **§4.2's association cleanup landed** — `com.local.pounce` is out of the
  rice's `AssociatedBundleIdentifiers` (hausfold#282, merged 06:24). §4 now has
  **no 🤖 work at all**; what's left there is the 👤 attribution re-check after
  activation and §4.4's TCC feel-test.
- **§0.2's register search ran**, for `hausfold` and (new, per decision 8)
  `haus`. It had been 👤 because "the USPTO search API needs a key" —
  **TMview's does not**, and it aggregates USPTO + EUIPO + ~73 more offices.
  Headline: `hausfold` is **clear worldwide, zero records**, and the Charleston
  laundry business never filed anywhere, so §0.4's coexistence is with a
  common-law user rather than a registrant. `haus` on the register is
  weak-but-unblocked, with **one pending US class-42 application** —
  `Haus Analytics, Inc.`, US 99283190 — as the single thing to watch. Its
  package/handle availability ran the same day and lives in `hausfold/ops`, not
  here (§0.2's 🔒 box says why). Nothing asks for a naming change.

What changed on 2026-08-09 (kept — the evening handoff):

- **§4 landed and shipped.** perch#51, pounce#72 and hausfold#275 all merged
  2026-08-09 13:39–13:40; pounce released `v2026.08.09-3` and perch
  `v2026.08.09-1` at 14:00, both after the merges. The morning handoff's *"do
  not run `bench release pounce`"* hold is **spent** — the release happened with
  approval; don't read that line as still standing.
  Verified live on this machine: `launchctl list | grep -i pounce` shows exactly
  one job, `com.hausfold.pounce`, and `~/Library/LaunchAgents/` holds exactly one
  *pounce* plist, `com.hausfold.pounce.plist` (it holds eleven plists in total —
  don't read that `ls` as a clean sheet). The old `org.nixos.pounce` label is
  gone, which is §4.2's riskiest step confirmed rather than assumed.
  ✅ **The closeout's second half has now run too** — `com.local.pounce` is out
  of the rice's `AssociatedBundleIdentifiers` (hausfold#282). One 👤 check rides
  on activating it; see §4.2.
- **§5.4 is done** — no `support@nebelhaus.com` survives anywhere in the family
  except as struck-through history, **and the address is settled: `hi@hausfold.co`**,
  not `support@hausfold.co`. The sweep exposed that both were in play; `hi@` won
  because it is the one that exists and is already on `/terms`. Three perch
  pre-flight boxes that were *create a mailbox* tasks are now *decide an SLA*
  tasks, and an SLA doesn't gate a receipt.
- **§9's `options-modules.nix` duplication is closed** — `modules/default.nix`
  imports the list now.

Still 👤, none of it blocking the repo work at today's exposure level:

- ~~§0.2's USPTO/EUIPO trademark search.~~ ✅ **Run 2026-08-10** — via TMview
  rather than TESS, for `hausfold` *and* `haus`. `hausfold` is clear worldwide
  and the Charleston laundry business holds no registration; `haus` is weak but
  unblocked, with one pending US class-42 application to watch. §0.2 carries the
  numbers and the API recipe. What remains 👤 is the clearance *opinion*, which
  keeps its original trigger (filing / paid marketing / incorporation).
- §4.4's TCC re-grant feel-test — specifically the **palette** running a plugin
  command, which no agent can press. An agent can confirm the label; it cannot
  confirm the grant.
- §4.1's deletion of the old `Perch for Mac` record and its two identifiers,
  gated on `Perch Companion` being **approved** (still Waiting for Review).
- §5.3's DNS/`wrangler deploy`, which §5.2 hands off to.

**Compatibility cleanup, later:** `modules/renamed.nix` stays while external
configs may still use `nebelhaus.*`; narrowing `checkRice` and deleting the
aliases is not part of the first rename landing.

---

## §0 — Before anything moves

### 0.1 ✅ Rewrite the reversed decisions *first* — done, gate green 2026-08-08

Before a single line of code. Otherwise every subsequent agent reads a note
that contradicts the work in front of it.

- `notes/go-to-market.md` — §1 portfolio table (hausfold row), §5 (the gallery
  question — where it lives), §6 (the whole section), §9 (open decisions 1 and 4).
- `hausfold/ops`'s `PRESENCE.md` — the "deliberately separate, nothing belongs
  here" rule. ⚠️ It was `hausfold/PRESENCE.md` when this list was written, and
  that path now means a file in the **rice** checkout (the dir was renamed
  2026-08-09). The register never lived there; it moved to its own private repo
  on 2026-08-08.
- **`hausfold/AGENTS.md` and `hausfold/README.md`** — both quote that rule, and
  AGENTS.md's pre-PR checklist *instructs future reviewers to enforce it*. A
  repeal hides in the checklist that quotes the rule, not in the paragraph you
  rewrite. Missing these was this doc's own bug.
- **`README.md` and `AGENTS.md` here** — the workshop's own routing table calls
  hausfold "the umbrella" and says hausfold is "the only one outside the
  `nebelhaus` org". Both are *decisions*, so they belong in §0.1, not in §2's
  naming sweep — otherwise every session between §0 and §2 reads the
  contradiction §0.1 exists to prevent.
- `notes/options-roadmap.md` — §7 repo routing, and a header note that
  `nebelhaus.*` is now `haus.*` throughout. **Don't rewrite the body**; it's a
  historical record and §5.14 is explicit about that. One banner at the top.
- `notes/perch-monetization.md` — the support-address line.

**Gate: ✅ returns nothing, verified 2026-08-08, re-run green 2026-08-12** (run
from the workshop's *main*
checkout — a workshop worktree has no rice checkout in it at all, so a green run
there proves nothing). It used to hit `go-to-market.md:117,171` and
`hausfold/PRESENCE.md:52` — the `--exclude` is load-bearing, or this doc
matches itself forever:

```sh
grep -rniE "nothing in th(e|at) (nebelhaus )?family (migrates|belongs|may move)|commercial umbrella|don't put it on hausfold\.co|nebelhaus\.com/rices" \
  notes/ haus/ README.md AGENTS.md --exclude=hausfold-rename.md \
  | grep -v '~~' | grep -vE ':[0-9]+:> '
```

⚠️ **The rice's directory in that command was `hausfold/` until 2026-08-12.**
§10 renamed the checkout to `haus/` and this gate was not updated with it, so
for two days it emitted a `No such file or directory` warning, skipped the rice
entirely, and greped the rest anyway — a gate that half-runs and still prints
nothing is indistinguishable from a gate that passed. Green either way, checked
both spellings.

⚠️ **This gate went through three wrong versions, and the third mistake is the
instructive one.** v1 pointed at `../hausfold/` (a path that doesn't exist) with
patterns that didn't match the real prose. v2 matched, then could never go green
— because it also matched **its own tombstones**: a `~~struck~~` quotation of a
repealed rule preserves the literal string.

The naive fix is to paraphrase every tombstone. That's wrong, and the hausfold
assurance pass caught why: **a repealed rule that isn't quoted reads as an
omission**, so a later session re-adds it in good faith. The rule has to stay
legible *and* the gate has to be able to pass.

Hence the two filters: what this gate is actually looking for is an assertion
that is **still standing** — not one struck through (`~~`) or quoted inside a
reversal blockquote (`> `). Marked-as-dead is the goal state, not a violation.

### 0.2 👤 Name clearance — registries 🔒 in `ops`, register 2026-08-10

"hausfold" as an *umbrella* was low exposure. As a **platform with a market and
paid products**, it's a different check:

| | Status |
|---|---|
| package registries, handles, namespaces | 🔒 **run 2026-08-08, re-checked 2026-08-10 — results in `hausfold/ops`'s `PRESENCE.md`, not here.** See the 🔒 box below. ⚠️ One line survives because it's about *loss*, not availability: `flick`, `nebelung`, `pounce` and `perch` are all **taken** on PyPI by unrelated projects, not recoverable, and PyPI has no reservation. (`flick` is moot since §3.4; `trill` is unchecked and only matters if that app ever publishes an SDK — today only holt does.) |
| A web search for an existing company using it | 🚨 **found one** — see below |
| USPTO + EUIPO, software classes (9/42) | ✅ **run 2026-08-10 — `hausfold` returns ZERO records worldwide.** See the box below for how, and for what it does and doesn't prove. |

🔒 **Why the availability rows moved out of this file — 2026-08-10.** They said
which registries and handles were **free**, and *free* is the half that makes
the register private: a list of what nobody has claimed hands it to whoever
reads it first, and **this repo is public**. The rule is decision 8's
`PRESENCE.md` bullet at the top of this file, and it now binds `hausfold`'s rows
as well as `haus`'s — they predated the rule rather than being exempt from it.
`hausfold/ops` holds both sets.

**The trademark rows stay, and the difference is not a judgement call:** those
quote *public register records*, so reproducing them discloses nothing
`tmdn.org` doesn't already serve to anyone who asks. Availability is a gap;
a registration is a document.

#### ✅ Run 2026-08-10 — the register half, for both `hausfold` and `haus`

**Not through TESS.** USPTO's own search needs a key or the web UI, which is why
this row sat undone. The way through is **[TMview](https://www.tmdn.org/tmview/)**
— EUIPO-operated, aggregating ~75 participating offices *including USPTO and
EUIPO*, with an unauthenticated JSON API behind the web UI:

```sh
UA='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)'    # NOT optional — see below
# GET the app first for a session cookie, then POST the search
curl -s -A "$UA" -c jar https://www.tmdn.org/tmview/ -o /dev/null
curl -s -A "$UA" -b jar -X POST https://www.tmdn.org/tmview/api/search/results \
  -H 'Content-Type: application/json' -H 'Referer: https://www.tmdn.org/tmview/' \
  -d '{"page":1,"pageSize":100,"criteria":"E","basicSearch":"haus",
       "offices":["US","EM"],"niceClass":["9","42"],
       "territories":[],"tmStatus":[],"tmTypes":[]}'
```

⚠️ **Five gotchas, every one of which returns a confident wrong answer rather
than an error.** Four of them are indistinguishable from "nothing found":

- **A browser `User-Agent` is required.** With curl's default UA the WAF resets
  the POST — `exit 56`, http `000`, reproducibly — *even with a valid cookie*.
  Because the next gotcha primes you to blame the session, this one costs real
  time. Set `-A` on both requests.
- **The session cookie is required** — POST without the GET and the API returns
  an empty body, not an error. An empty body parsed as "no results" is a false
  all-clear, which is the worst possible failure for this check.
- **The nice-class filter key is `niceClass`.** `niceClasses` and `classes` are
  accepted and **silently ignored** — same query came back 2,566 vs 566.
- **`criteria:"E"` is not "exact".** It word-matches, so it returns `WolfHaus`,
  `ModelHaus`, `KOOL HAUS AI`. Filter `tmName` yourself for a true exact hit.
  **`criteria:"C"` is the substring search**, and the two disagree in the
  direction that fools you: `haus fold` gives **5** under `"C"` and **0** under
  `"E"`. Use `"C"` for a phrase or a fragment; never read an `"E"` zero as
  clearance for one.
- **Run a positive control with the *same* parameters you're using**, so an
  empty result is known to mean empty. `nike` is 15,854 wide open
  (`criteria:"C"`, no office or class filter) but **37** under this box's
  narrowed query (`"E"`, US+EM, 9/42). Quoting the wide number while running the
  narrow query is how you conclude the API is broken.

**`hausfold`: zero records, worldwide, any class, any status** — under `"E"` and
`"C"` alike. So is `housefold`. The register is clear.

**And the SC laundry business never filed.** `haus fold` (`criteria:"C"`)
returns 5 marks, none theirs (`FOLDHAUS`, `PARKETTHAUS SCHEFFOLD` ×2, an exhaust
manifold, a Japanese *HOUSING FOLDER*). That
materially improves §0.4's coexistence position: HAUS FOLD is a **common-law
user only** — no registration, a services class, three cities in one state.
First in time, yes; but with nothing on the register to assert.

⚠️ **One near-mark, and it's a law firm.** `HAUSFELD` — one letter out,
near-identical to an English speaker — is registered by **Hausfeld LLP** at
USPTO, EUIPO and UKIPO, all in **class 45 (legal services)**. Different class,
different trade, coexistence is ordinary; log it because the registrant being a
litigation firm raises the odds of a letter above what the class distance would
suggest. (`CAMPBELL HAUSFELD`, class 7 air compressors, is noise.)

**`haus` — the check decision 8 created, and the result is not what the
decision's own note predicted.** It guessed "expect it taken and weak as a
mark." Half right:

| `haus` | |
|---|---|
| exact word **HAUS**, US+EUIPO, **class 9 or 42** | **7 records, 6 dead.** The one live: **US 99283190, `Haus Analytics, Inc.`**, filed 2025-07-14, cls 35+42, word mark, still **pending** |
| exact word **HAUS**, US+EUIPO, all classes | 44 records, 13 live — and **none of the 13 is registered in 9 or 42.** They sit in 1, 8, 16, 18, 25, 30, 32, 33, 35, 36, 41 and 43: drink, clothing, hospitality, real estate |
| word-*containing* haus, US+EUIPO, cls 9/42 | **566 records, 318 live** — `WolfHaus`, `ModelHaus`, `KOOL HAUS AI`, `HealthyHaus`, … |
| package registries, handles, the CLI name | 🔒 **ran the same day; the results live in `hausfold/ops`'s `PRESENCE.md`, not here.** See the box below. |

🔒 **Why half of `haus`'s matrix isn't in this file.** Which registries,
handles and package names are *free* is precisely the register-of-gaps material
`PRESENCE.md` exists to hold, and **the workshop is public** — publishing a list
of what nobody has claimed hands it to whoever reads it first. The rule is
stated in decision 8's `PRESENCE.md` bullet at the top of this file: if a
session finds itself filling in §0.2's matrix for `haus` *here*, that's the
mistake. The register half above is different in kind and stays — trademark
records are public documents, and quoting them discloses nothing that
`tmdn.org` doesn't already serve to anyone.

**So read the register half on its own terms.** As a *mark*, don't file `haus`
and don't lean on it: **566 records containing haus in our own classes, 318 of
them live**, is a crowded field, and a word that crowded is weak, expensive to
register and impossible to police. **The mark is `hausfold`** — exactly decision
8's split (the layer is `haus`, the house is `hausfold`), so nothing here asks
for a naming change. The practical question underneath — *can people actually
type `haus`* — was answered the same day and answered well; it's just answered
in `ops`.

🚨 **The one thing to watch: US 99283190.** If Haus Analytics' class-42
application registers, a live senior registrant owns bare "HAUS" for software
services in the US. It does not reach `haus` used as a product name under the
hausfold house mark — but it does mean: never file HAUS alone, and never market
the layer as a standalone brand detached from hausfold. Re-check its status at
the same trigger below.

⚠️ **This is a knockout screening, not a clearance opinion**, and the difference
is not pedantry. It reads the register only: it does **not** cover unregistered
common-law use, phonetic and foreign-equivalent marks beyond the two checked
here, design marks, or state registrations. Everything below the trigger line
stays as it was — this box lowers the unknowns, it doesn't replace counsel at
the moment one is warranted.

🚨 **`hausfold.com` is an operating US business: HAUS FOLD, in-home laundry and
light housekeeping in Charleston / Columbia / Greenville, South Carolina.**
Registered 2025-04-19, live site, phone, pricing, testimonials, and
`instagram.com/hausfold`. Not German or Austrian, which is why the original
phrasing of this check wouldn't have found it. Full detail in §0.4.

**Gate: passed on the register half — no forced rename.** They sell a household
*service*; we sell software. Different Nice classes coexist routinely and
nobody confuses a laundry round with a nix-darwin platform. The 2026-08-10
search adds one fact: they hold **no registration anywhere**.

🚨 **Do not read that as the risk shrinking — US common-law rights don't depend
on registration.** They remain **first in time on the word, in the US, in
commercial use**, and that is the whole of the exposure both before and after
this search. What changed is that the exposure is now *shaped* rather than
unknown: unregistered, one service class, three cities in one state, with
nothing on the register to assert against a software mark. The word
"provisionally" came off the register clause only.

⚠️ **What's still undone has a trigger, not a date.** The *register* has been
searched (see the box above). What hasn't: **the common-law position of the very
business found here**, any other unregistered user, phonetic and foreign
equivalents past `hausfeld`/`housefold`, design marks, state registrations — i.e.
everything a real clearance opinion adds, and the first item on that list is the
one that matters most. Get one before **any** of: filing an application, paid
marketing, or incorporating an entity that trades under the name. Below that
line the exposure is logged and accepted. Above it, a knockout screening is
still not a clearance opinion — it just means counsel starts from a clear
register instead of an unknown one.

### 0.3 🟨 Drain the queue — PR/lock half green 2026-08-08, branches still open

**A namespace rename conflicts with every open branch.** Today the family has
exactly one open PR — that's the readiness signal, and it decays.

```sh
for r in workshop nebelhaus nebelung pounce perch holt homebrew-tap .github; do
  gh pr list --state open -R nebelhaus/$r
done
# the loop above is the nebelhaus org only — the hausfold org already holds
# repos that §2 and §5 edit, and they have their own lanes
for r in hausfold.co ops; do gh pr list --state open -R hausfold/$r; done
holt                            # every live/parked worktree, all repos
~/code/workshop/bench status    # dirty trees, unpushed, stale locks
```

- Both PRs this section named (workshop#249, nebelhaus#257) have landed. **Re-run
  the loop before starting §1 rather than trusting this line** — it was true at
  one instant and the whole point of the step is that the instant passes.
  Checking only one repo is how a rename lands over an open rice PR.
- `holt reap` anything already landed.
- `bench status` must show **no stale lock edge and no OFF-MAIN pin** before the
  sweep starts — a rename ripple on top of a stale lock is undebuggable.

**Gate:** `bench status` clean, zero open PRs, zero unmerged `worktree-*`
branches.

**Measured 2026-08-08 — two of the gate's three clauses.** Zero open PRs across
the eight `nebelhaus/*` repos; all six lock edges current, no OFF-MAIN pin. The
**branch clause is not met** and shouldn't be forced: `holt` lists live lanes
across workshop, nebelhaus, hausfold and perch. Sort them like this:

- 🚨 **`nebelhaus`'s `worktree-fizzy-moseying-snowglobe` is exempt.** It carries
  §1.0's parked spike (wip `7d9ee70`), which is §1's expensive input. An agent
  reaping to satisfy this gate deletes the artifact the next phase depends on.
- A stale `perch` branch `worktree-workshop-name` — no checkout, no registry row.
  `git -C perch branch -D` it.
- A `holt` checkout under `~/.codex/worktrees/`. That path is **not** where any
  client's lanes live (`AGENTS.md`: every client shares
  `~/.cache/claude-worktrees/`), so it's an orphan created outside `holt` — the
  invisible-in-the-statusline gotcha, not a session to resume. Remove it.
- Everything else: land or park normally.

One release edge is behind — `nebelhaus v2026.08.08` is 13 commits behind main —
which is orthogonal to the rename, but note that **cutting that release after §1
lands stamps a `haus.*` rice**, so either release before the sweep or accept that
the next tag is the rename's.

### 0.4 ✅ hausfold.com — checked 2026-08-08, and it isn't for sale

Decision 3 accepts `.co`. Two consequences to hold consciously rather than
discover:

- ~~The `.com` gets more expensive as the brand gains value, and this rename is
  the event that gives it value.~~ **Moot — see below.**
- The seller name appears on receipts and terms. `.co` reads second-tier there.

**This section used to end: *"check the `.com` isn't parked by a squatter today,
and if it's ~$12, the argument for buying it is that this is the last time it's
that cheap."* That check has now been run, and the answer is no.**

`hausfold.com` was registered **2025-04-19** (expiry 2028-04-19) and serves
**HAUS FOLD — "For your household."**, an operating in-home laundry and
light-housekeeping service in Charleston, Columbia and Greenville, South
Carolina. Live site, phone number, service tiers, testimonials, pricing. Not
parked, not a squatter, **not a $12 registration waiting to be made** — buying
it would mean buying a working business's primary domain.

So there was never a purchase to be early for, and "buy it now while it's cheap"
was wrong from the start rather than expired. Three things follow:

1. **Decision 3 stands, for a different reason.** Accepting `.co` isn't a thrift
   decision any more; it's the only option.
2. **It explains the handles.** `instagram.com/hausfold` is theirs, linked from
   their own site — which is why the register records `hausfold.co` there.
   Anywhere else the bare `hausfold` was "unavailable", assume the same cause
   and stop re-checking.
3. **It promotes the trademark question.** A same-word user in commercial use in
   the US, first in time. Likely fine — a household *service* against *software*
   are different Nice classes — but that was a reading, not a search.
   ✅ **The search has now been run — 2026-08-10, §0.2's box.** The register is
   clear: **zero records for `hausfold` at any office**, and **this business has
   never filed**, so it is a common-law user, not a registrant. ⚠️ Which is not
   the same as safe: US common-law rights don't require registration, so first-in-
   time still means something. **Get a clearance opinion before filing anything,
   spending on marketing, or incorporating under the name** — that trigger is
   unchanged. What's different is that counsel now starts from a searched
   register rather than an unsearched one.

Re-logged in `go-to-market.md` §9 decision 4 as decided-accept.

### 0.5 👤 App Store Connect audit — **this is the deadline**

`perch` already has `IOS_DIST_CERT_P12` and `ASC_KEY_*` repo secrets (created
2026-08-07), so Apple-side work has started. **Apple never lets a bundle ID
change after an app record exists.**

**Audited 2026-08-08 — 🚨 THE GATE FIRED. An app record exists with an uploaded
build. Rechecked 2026-08-09 after route A: the old record is Developer Rejected,
and the replacement is Waiting for Review.**

| Found | Status |
|---|---|
| App Store Connect → My Apps: **"Perch for Mac" iOS 1.0**, Apple ID `6799010687` | **Developer Rejected**; optional cleanup, but it still owns the old App ID |
| App Store Connect → My Apps: **"Perch Companion" iOS 1.0** | **Waiting for Review** under `com.hausfold.perch.ios` |
| `XC com nebelhaus perch ios` → `com.nebelhaus.perch.ios` | App ID, **bound to that record** |
| `XC com nebelhaus perch ios share` → `com.nebelhaus.perch.ios.share` | App ID, share extension |
| `group.com.nebelhaus.perch` | **registered App Group — it exists** |

The `XC ` prefix said "automatic signing", which was true and not the point: a
build has been uploaded and associated, so **the bundle ID on that record is
locked**, and App Store Connect's bundle-ID dropdown is only editable while no
build is associated.

**The window is open only until Apple approves it**, which can happen within a
day. After approval the app is published, `com.nebelhaus.perch.ios` is in users'
devices, and the *only* remaining fix is publishing a separate app and sunsetting
the first — losing ratings, reviews and any purchase history. There is no
bundle-ID migration on the App Store.

#### 👤 Do this first, before deciding anything

**Remove the submission from review.** App Store Connect → the version →
*Remove from Review* (or *Cancel Submission*). It costs a resubmission and your
queue position — roughly a day — and it preserves **both** options below.
Approval forecloses one of them permanently. That asymmetry is the whole
argument; take the free move now and decide after.

#### The fork, once the clock is stopped

| | **A — recreate under `com.hausfold.perch.ios`** | **B — freeze iOS at `com.nebelhaus.*`** |
|---|---|---|
| Do | Cancel review, delete the app record, create a fresh one with the new bundle ID | Accept the old reverse-DNS on the iOS app only |
| Cost | A review cycle, and **the App Store name is at risk** — Apple does not reliably release a deleted app's name back immediately | A permanent inconsistency **no user ever sees** (bundle IDs don't appear in a listing) |
| §4.3 App Group | must migrate or discard shelf data | **disappears** — the group stays `group.com.nebelhaus.perch`, no data touched |
| Reversal | ⚠️ **one-way.** Deleting the record burns `com.nebelhaus.perch.ios` — Apple never permits reuse — so option B is gone the moment you delete | fully reversible: a future rename is the same decision, just later and no worse |

**Note the macOS app is not affected either way.** perch for Mac ships Developer
ID + notarized via Homebrew, never the App Store, so `com.nebelhaus.perch` →
`com.hausfold.perch` is free. Only the *iOS* record is locked.

#### ✅ Decided 2026-08-08: **route A**

The code half is done — **perch#41** renames the four bundle IDs, both
entitlements and `MobileConfig.appGroupID`, and adds a
*Re-identifying an already-submitted app* runbook to `perch/docs/app-store.md`.
That runbook is the authority on the human steps; it is written to protect the
App Store **name**, which is the real hostage here (plain `Perch` is taken by
someone else, which is why the listing is `Perch for Mac`).

The ordering, in one line each — full version in perch's doc:

- [x] 👤 1.0 removed from review
- [x] 🤖 perch#41 merged — bundle ids, entitlements, `MobileConfig.appGroupID`
- [x] 👤 App IDs + App Group `group.com.hausfold.perch` registered
- [x] 👤 New ASC record created: **`Perch Companion`**, `com.hausfold.perch.ios`,
      SKU `perch-ios-hausfold`
- [x] 🤖 TestFlight build green — run `31261461679`, marketing `2026.8.8`, build 70
- [x] 🤖 perch#42 — docs updated to the new name
- [x] 👤 Re-enter listing metadata on the new record and submit — **Waiting for
      Review 2026-08-09**
- [ ] 👤 Delete the old `Perch for Mac` record (optional cleanup, no deadline)

**The green build is the proof, not the diff.** `-allowProvisioningUpdates`
cannot invent an App Group, so an unregistered or unassigned
`group.com.hausfold.perch` would have failed the archive at signing.

**★ The move that made this cheap: the new record took a name chosen to be
kept** (`Perch Companion`) rather than a placeholder waiting to trade
`Perch for Mac` back. That deleted the one irreversible risk in route A —
there's no name to reclaim, so the old record is now ordinary cleanup. The rule
generalises past Apple: **when a forced rename makes you pick a new name anyway,
take one you'd keep.** `Perch for Mac` was itself only a consolation prize for
`Perch` being taken, and it read oddly on an iPhone app.

⚠️ **Metadata does not travel with a bundle id.** Description, keywords,
screenshots, privacy label, export compliance and review notes are per-record and
start empty; `perch/docs/app-store.md` is the copy of record to paste from.

### 0.6 🚨 The Mac app has the same problem, with a released install base

Found while doing §0.5, and **§4 originally missed it entirely.** perch for Mac
is publicly released — `v2026.08.08`, a live Homebrew cask — and its bundle id
*is* its sandbox container and its defaults domain:

- `~/Library/Containers/com.nebelhaus.perch/Data/…` — **the shelf itself**
  (`perch/docs/reference.md:34`)
- `defaults` domain `com.nebelhaus.perch` — where `LicenseStore` lives
- every TCC grant

So `com.nebelhaus.perch` → `com.hausfold.perch` **empties a released app**:
shelf gone, settings gone, permissions re-prompted, and — once Phase 2 ships the
public key — **every paid license de-activated**. Today that costs nothing
because the install base is approximately you and the license layer is inert.
After the paid launch it is unrecoverable without a migration shim.

**This is an argument for doing it soon, not for skipping it.** It stays in §4.2
rather than jumping the queue like the iOS half, because Apple's review queue is
a clock and Homebrew is not — but it must land **before** perch's Phase 2.

- [x] ✅ **Decided 2026-08-08: discard, no migration shim.** "No users yet" — the
      shelf, the settings and the (inert) license state are ours alone, so the
      rename simply starts a fresh container. Note it in perch's changelog; do
      **not** write a migration path for data that belongs to one person.
- [x] ✅ **Landed 2026-08-08, before the license layer — [perch#44](https://github.com/nebelhaus/perch/pull/44).**
      `com.nebelhaus.perch` → `com.hausfold.perch`, plus everything derived from
      it: both `PRODUCT_BUNDLE_IDENTIFIER` configs and `.tests`, seven `Logger`
      subsystems, the three `OperationQueue` names, the three Keychain services,
      and the dev-app id `com.hausfold.perch.dev` (`bench` fixed in the same
      change — it hardcoded the old one at three lines). Verified by running it:
      full macOS suite green and a signed dev build creates
      `~/Library/Containers/com.hausfold.perch/` with an empty ActiveShelf
      manifest. Two mentions of the old id survive on purpose, annotated as
      historical: `perch/docs/app-store.md`'s re-identification runbook and
      ADR 0006's consequences list.

      Two things worth carrying forward, because they were wrong until checked:
      the Homebrew cask has **no `zap`/`uninstall` stanza** and never names a
      bundle id, and `release.yml` doesn't either — so nothing downstream pinned
      it and the rename needed no cask or workflow edit. And what actually breaks
      the phone pairings is the **Keychain service strings**, not the container
      move; the Mac's `PairedDeviceStore` and the phone's `MacPairingStore` /
      `MobileConfig` move together, so identity and pairing die together (the
      safe half) instead of the phone presenting a new id while holding an old
      key.

      Accepted, user-visible: empty shelf (old container orphaned, safe to
      `rm -rf` — `perch/docs/reference.md` says so now), Settings back to
      defaults, pairings need re-doing, local-network prompt re-appears.

**§0.6 is closed.** Both halves of the Mac/iOS re-identification have landed;
what remains of the hausfold work is §1 onwards.

---

## §1 — The namespace sweep: `nebelhaus.*` → `haus.*`

The technically hardest phase — **and the spike has now run, so it is a known
quantity rather than a fork.** Per the family's own rule
(`options-roadmap.md` §7) a **breaking option rename couples the consumer's
lock-bump and config edit into one PR — `bench ship` can't split them without
breaking main mid-ripple.** §1.0's answer is that the rename doesn't have to be
breaking, so that coupling never has to happen.

**The tree is 110 declared leaves, not the "~44" this section used to claim**
(155 paths counting each `<name>` submodule field). Measured, not estimated —
see §1.0's method, which is also the only way to get the real number.
⚠️ `options-roadmap.md` says **130** for the same tree, on its own date and by its
own count. Don't reconcile the two by picking one: **re-run §1.0's snippet** — it
states its rule (every node whose `_type` is `"option"`, under
`options-modules.nix`, internals included) and is the number `renamed.nix` has to
agree with.

### 1.0 ✅ Spike run 2026-08-08 — the alias carries it. Take §1.1a.

The question was: if `lib.mkRenamedOptionModule` can carry the whole tree, the
atomicity problem **dissolves** — `haus.*` becomes real, `nebelhaus.*` becomes a
warning-emitting alias, main never breaks, and `~/.config/nix` bumps its lock
whenever it likes.

**It carries it.** The spike renamed all 14 declaration sites, generated
`modules/renamed.nix` (105 `mkRenamedOptionModule` entries), and left the example
host, both presets and the pack file still written as `nebelhaus.*`. Result:

- `nix flake check --no-build` **green across all 16 checks** — including
  `presets`, `packs`, `data-only-surface` and `preset-composition`, which is the
  one that composes two rices.
- The example system's derivation differs from pristine in **exactly one leaf**:
  `options.json`. Everything else that moved (`claude-skill`, `host-template`,
  and therefore `system-path`, `etc`, `system-applications`) is downstream of
  that one file. See §1.2 — this is the corrected gate, not a failure.
- `.#options-json` renders **155 `haus.*` keys and zero `nebelhaus.*`**: the
  aliases are `visible = false`, so they never reach the docs.

The spike tree is parked, not thrown away: nebelhaus branch
`worktree-fizzy-moseying-snowglobe`, wip commit `7d9ee70` (`holt unpark` in that
lane). 27 files, and the generated `renamed.nix` is the expensive part.

#### The five things it found that the plan didn't have

1. 🚨 **`nix build .#options-json` is NOT the leaf list, and generating
   `renamed.nix` from it silently misses five options.** `optionsDoc` drops
   anything `internal = true`. Four are obvious (`_roster`, `_workspaces`,
   `_appWorkspace`, `_launchers`); **the fifth is `theme.ports.handled`, which
   is internal without an underscore**, so `options-doc.nix:78`'s
   `hasPrefix "_"` filter isn't what hides it and no naming convention will
   find it. Enumerate from the module system instead:

   ```nix
   # nix eval --impure --raw --file leaves.nix
   let ev = lib.evalModules {
         modules = (import ./modules/options-modules.nix) ++ [ { _module.check = false; } ];
       };
       go = path: opts: lib.concatLists (lib.mapAttrsToList (n: v:
         if !(lib.isAttrs v) then [ ]
         else if v._type or "" == "option" then [ (path ++ [ n ]) ]
         else go (path ++ [ n ]) v) opts);
   in lib.concatStringsSep "\n" (map (lib.concatStringsSep ".") (go [ ] ev.options.nebelhaus))
   ```

   110 leaves out, 105 of which options.json knows about.
2. **Internal options get swept, not aliased.** They're ours; an alias would
   just emit an obsolete-option trace on every eval of our own code.
3. **Reading an option's *declaration* through an alias breaks.** `doRename`'s
   alias carries no `default`, so `options.nebelhaus.fonts.mono.name.default`
   throws `attribute 'default' missing`. One site today —
   `modules/den/default.nix:151` — and it has to move with the declarations.
   Reading a *value* (`config.nebelhaus.x`) is fine: `doRename` gives the alias
   an `apply` that returns the target's value, which is precisely why consumer
   reads don't have to move in the same PR.
4. **`modules/options-doc.nix:78` hardcodes `optionsEval.options.nebelhaus`** —
   the docs generator must move in the same commit or the whole build fails, not
   just the docs.
5. **The option-file list is written twice** — `modules/options-modules.nix` and
   `modules/default.nix` each carry their own copy — and `renamed.nix` must be in
   **both**. In only `default.nix`, the pure-lib option-surface evals in
   `flake.nix` (`packCompose`, the pack surface check) fail with ``The option
   `nebelhaus' does not exist``. In only `options-modules.nix`, the *system*
   eval fails instead. Neither failure names the duplication.

The second spike question — does `checkRice` still work when a rice sets the
alias — has a sharper answer than expected. **It can't be carried by the alias
at all:** `checkRice` reads the *file's* top-level attribute name, not the option
system, so a `{ haus = …; }` rice is rejected by a string comparison
(`flake.nix:198`) no matter what the module system thinks. It has to accept
**both names for the length of the transition** and narrow to `haus` only at
step 6 — third-party rices are exactly the consumers who move last.

### 1.1a ✅ Alias path — **landed and verified 2026-08-08 as hausfold#261**

1. `haus.*` is the canonical namespace in all **14** `options.nix` files —
   a one-line change each (`options.nebelhaus` → `options.haus`).
2. Generated `modules/renamed.nix` aliases the old tree, warning on use. Listed
   in **both** module lists (finding 5) — one list now, because that PR's first
   commit folded `default.nix`'s copy into `import ./options-modules.nix`.
3. Swept in the same PR, being what the alias can't cover: the five internal
   options and their references, `options-doc.nix:78`, and `den/default.nix:151`.
4. `checkRice` accepts `haus` **and** `nebelhaus`, and now **rejects a file that
   sets both** — one namespace, two spellings, and every reader downstream picks
   one key, so a both-keys file would lose half its definitions in silence.
5. `presets/*.nix`, `packs/*.nix`, `hosts/example/default.nix` moved too, along
   with `bootstrap.sh`, `haus set`, pounce's Install-App generator and the
   shipped Claude skill — see the box below for why that wasn't optional.
6. ✅ `~/.config/nix/hosts/mbp/default.nix` moved to `haus.*` on 2026-08-09
   (`nix-config` `452b9b8`), together with the private repo's current GitHub
   links and `haus.git.org = "hausfold"`. `bench try` built with **zero**
   obsolete-option traces; the old spelling had already proved the alias on
   every preceding rebuild.
7. Aliases deleted, and `checkRice` narrowed to `haus` alone, in a follow-up PR
   **after** the last consumer moves.

#### 🚨 The aliases are for other people's configs, not for ours

The plan above (and the spike) said consumer *reads* could move later, because
`doRename` gives the alias an `apply` that forwards the target's value. True,
and it hid the cost: **`mkRenamedOptionModule`'s `use` is a `builtins.trace`, so
every read through an alias prints.** Leaving the rice's own 128 reads on the old
spelling produced **106 obsolete-option lines on every rebuild**, naming options
the user never wrote — and `haus rebuild` tees that stderr straight to the
terminal. It also quietly made the rice the largest remaining consumer of the
aliases it had just shipped, which is the wrong thing for a file whose header
says "delete this once the last consumer has moved."

So the rule the doc was missing: **alias the boundary, sweep everything inside
it.** `nix eval` of the example host has to be silent, and that is a cheaper
gate to check than anything in §1.2 — one `grep -c 'Obsolete option'`.

#### What only a build caught, twice

Both of these passed `nix flake check` and both broke something real, which is
the argument for §1.2's `bench try` clause being load-bearing rather than
belt-and-braces:

- **`host-template` has a builder-time self-check** that greps the rendered file
  for the namespace and exits 1 on an empty render. Eval-only checks sail past
  it. The same shape hides in `skill.nix`, and in `haus.sh`'s "wrote N options"
  count.
- **Two CI/CLI greps would have passed *vacuously* instead of failing**:
  `.github/workflows/check.yml`'s `sed` that uncomments the template (it would
  have evaluated an empty host and gone green) and `bootstrap.sh`'s dry-run
  option count (it would have printed "0 options" on the public installer). The
  first gained a `grep -q` proving it uncommented something.

And one that only a **regex-sweep review** caught: the bulk substitution
rewrote a shell `case` pattern, `nebelhaus.*)` → `haus.*)`, killing the
compat branch in `haus set` — *and* rewrote the test that covered it, so the
suite still passed. **When a sweep edits both the code and its test, the test
stops being evidence.**

### 1.1b 🤖+👤 Atomic path (fallback — no longer expected to be needed)

Kept because a future nixpkgs could regress `doRename`, not because anything
points here today. One PR in `hausfold/hausfold` renaming the tree with no alias,
and one in `~/.config/nix` rewriting the host file + bumping the lock, merged in
that order within the same sitting. Nothing else may be mid-ripple.

### 1.2 🤖 Prove it changed nothing — the gate, as measured

The house technique — `options-roadmap.md` §3.1 (the options split, nebelhaus#92)
did exactly this and called it "byte-identical derivation":

```sh
# BEFORE the sweep, on a clean tree
nix path-info --derivation .#darwinConfigurations.example.system > /tmp/before.drv
# AFTER
nix path-info --derivation .#darwinConfigurations.example.system > /tmp/after.drv
diff /tmp/before.drv /tmp/after.drv
```

**First, the technique is sound and that was worth checking.** A control run —
same commit, one added comment — produced the identical drv path, so the flake's
source hash does *not* leak into the derivation and a difference here is a real
difference.

⚠️ **But `diff` cannot be empty for this particular change, and a plan that
demands it will get "fixed" by deleting the gate.** The rice **ships its own
option surface as an artifact**: `.#options-json` feeds `.#claude-skill` and
`.#host-template`, which are in `system-path`, `etc` and `system-applications`.
Renaming the namespace legitimately renames every key in that file.

So the gate is **one leaf divergence, and it is `options.json`**. Walk the two
derivation graphs and find where they stop differing:

```sh
# recurse both drvs through inputs.drvs, matching by name, and report every
# pair that differs while all of its own inputs match
```

Measured on the spike: exactly one such leaf, `options.json.drv`. Anything else
in that list is a real behavior change and the gate is red.

🚨 **The trap that produced a second leaf on the first run, and the reason it
belongs to §2 rather than §1:** `modules/sill/default.nix:119` reads
`# GENERATED from nebelhaus._roster by modules/sill/default.nix — do not edit.`
— and that line is **inside the `workspacesSh` string**, so it is a line of
`~/.config/sketchybar/workspaces.sh`, not a comment on the Nix. Sweeping it
changed the shipped file. There are ~12 more `# GENERATED from nebelhaus.*`
comments in `sill/default.nix` alone, plus `prowl/aerospace.toml`,
`prowl/scripts/resort-windows.sh` and `sill/sketchybar/plugins/launch_mode.sh`.
**Leave every one of them for §2.** In §1 they are gate-breakers; in §2, after
the gate has passed, they are ordinary text.

Plus `nix flake check` (it evaluates a real system per preset, and composes two
rices) and the options-drift CI.

**Gate:** the derivation walk's only leaf divergence is `options.json`,
`nix flake check` green, `bench try` builds.

---

## §2 — In-repo naming, docs, tooling

Pure text, ~250 files, but **not** a blind `sed`. Three distinct classes that a
single find-replace would conflate:

| Class | Rule |
|---|---|
| the **platform** (options, modules, the CLI, the docs' subject) | → **`haus`** for the layer itself and `haus.*` for the namespace; `hausfold` only for the org, the maker and the seller — **amended 2026-08-10, decision 8**. This row read `→ hausfold / haus.*` and would now sweep layer prose the wrong way. |
| the **rice** (presets, the desktop, the showcase, the grey) | stays **nebelhaus** |
| **historical record** (roadmap §5 bodies, PR titles, commit messages, `holt`'s `~/.cache/claude-worktrees/` path) | **leave alone** |

⚠️ **A fourth class the table missed, handed over by §1.2: comments that are
inside generated files.** `# GENERATED from nebelhaus.<option> …` appears ~12
times inside string bodies in `modules/sill/default.nix`, and again in
`prowl/aerospace.toml`, `prowl/scripts/resort-windows.sh` and
`sill/sketchybar/plugins/launch_mode.sh`. They *are* the shipped file, so
touching them changes a store path.

**✅ Done in nebelhaus#261, and not by choice.** Silencing
the alias traces meant moving the option READS in the same modules, which put the
comment two lines away, now stating something false. So §1 ended with 25 leaf
divergences instead of one — `options.json` plus 24 files whose only change is
the namespace inside a comment or a printed string. The gate that replaced
byte-identity, and the one to reuse: **prove the source diff is a pure
substitution** (diff `-U0`, apply the substitution to each `-` line, assert it
equals the `+` line — 3 hand-written hunks out of ~560, each reviewed). What
remains for §2 in the rice is prose about the *brand*, not the namespace.

⚠️ **And a fifth: the option namespace crosses repo boundaries.**
`web/scripts/gen-options.mjs` filtered on `nebelhaus.` and had **no emptiness
guard**, so against a `haus.*` rice it renders the reference page with a title,
an intro and zero options — and `options-drift.yml`'s Monday cron would have
opened that blank page as a routine-looking PR, green. Fixed in the same sitting
(workshop#266: detect the prefix, refuse to render nothing). The lesson beyond
this one script: **a generated cross-repo artifact fails by emptying, not by
erroring**, so every renderer of someone else's data needs a floor.

### 2.1 🤖 Per repo

🚨 **Most of the list below is not §2's, and the audit that established that is
the useful output.** Read this before working the bullets — three of them are
misfiled and following them literally breaks `main`.

§2's own gate says the phase **changed nothing** (see the `FAMILY`-entry note
below — the archived client's entry read `trill` when this was written,
`messages` after workshop#269, and is gone entirely since workshop#283 — and the
gate at the end of the section). Measured against that,
every entry in this section falls into exactly one of four buckets:

| bucket | example | phase |
|---|---|---|
| **the option namespace** | `nebelhaus.agents.default` | ✅ §1 — already done in the rice; §2 only mops up the **other** repos |
| **brand prose** — who the family/platform/seller *is* | "the nebelhaus workshop", `part_of-nebelhaus`, `© nebelhaus` | ✅ **§2. This is all §2 actually owns.** |
| **an identifier that resolves** — repo URL, org slug, flake input name, `GH_ORG`, `FAMILY` directory name, `--override-input nebelhaus/*` | `github.com/nebelhaus/pounce` | **§3**, which exists to "rewrite every edge" in one sitting. Renaming any of these now points a doc at a repo that 404s, or breaks a build outright — both are behavior changes, which §2 is gated against. |
| **the domain** | `nebelhaus.com` | **§5**, with the 301s |

So: **`bench`'s §2 share is one line** — its `:2` header comment, which is brand
prose. `FAMILY` (`bench:78`) is a directory name settled by §3.1(b), and the repo
lists and the `--override-input` block at `:281-286` are edges owned by §3.3. And **the
rice's §2 share is empty**: audited 2026-08-09,
every surviving `nebelhaus` in it is the repo name, the rice's own name (§6),
the flake input, `nebelhaus.com`, a launchd label or a state dir. Its
`LICENSE` holder is `Julien Martel`, not a brand. Its `flake.nix` description
(`"nebelhaus — an opinionated macOS, raised in the fog"`) is the **rice's**
tagline and stays until §7 actually splits the platform out of it — renaming it
now would assert a split that hasn't happened.

The two `test/haus-settings.sh` hits are the deliberate compat test for
`haus set` accepting the old prefix. Leave them; they're the evidence §1.1a
step 4 works.

- ✅ **hausfold** (was nebelhaus): **nothing to do — see the audit above.**
  This bullet's `modules/**`, `presets/**`, `packs/**`, `bootstrap.sh` and
  `hosts/example` all moved in nebelhaus#261; `README.md`/`AGENTS.md` are the
  rice's own name; `flake.nix` description and the `LICENSE` holder line are
  §7 and not-a-brand respectively. The rice's `AGENTS.md` already carries the
  authoritative "three things stay `nebelhaus`" stanza — read it rather than
  re-deriving this.
- **web**: 29 doc files under `web/src/content/docs/`.
  `start/what-is-nebelhaus.md` → `what-is-hausfold.md` (**leave a redirect**),
  `start/the-family.md`, `reference/haus.md`, `reference/options.md`
  (regenerates — don't hand-edit), `guides/sharing-a-rice.mdx` (the format doc),
  `astro.config.mjs:8` (`site:`), `:63` (the GitHub edit baseUrl).
  ⚠️ **~24 of those guides teach `nebelhaus.<option>` and are now stale rather
  than wrong** — the alias means every line they print still works, which is
  exactly why nothing will fail and nobody will notice. Regenerating
  `reference/options.md` against the renamed rice is a one-command job
  (`node web/scripts/gen-options.mjs --rice ../nebelhaus`) and should happen the
  day nebelhaus#261 merges; the hand-written guides are the real work here.
  *(That page had also drifted for an unrelated reason — a
  `theme.systemAppearance` description changed in the rice and nobody re-ran the
  generator, so `main`'s own drift check was already red. Regenerated in
  workshop#266, which is how it surfaced: the check fires on every PR, not only
  on the Monday cron, so an unrelated branch inherits it.)*

  ✅ **The namespace half is done — workshop#267, 2026-08-08.** nebelhaus#261
  merged at 22:43Z and a release (`2026.08.08-1`) was cut straight on top of it,
  so `main`'s options-drift went red within four minutes: the docs' single source
  of truth had renamed itself and nothing here had moved. Regenerated
  `reference/options.md` (155 options, all `haus.*`) and swept the 20 hand-written
  pages, 159 lines, verified as a pure substitution.

  **Two things that a naive `nebelhaus.` → `haus.` sweep gets wrong, and the rule
  that separates them.** The namespace is not the only thing spelled
  `nebelhaus.<word>`: the docs also carry the **flake input** and its outputs
  (`nebelhaus.url`, `nebelhaus.mkNebelhaus`, `nebelhaus.presets.everyday`,
  `nebelhaus.lib.pack`), the **domain** (`nebelhaus.com`, §5) and a **bundle id**
  (`org.nebelhaus.editoropen`, §4) — none of which move in this phase. Don't
  eyeball the difference: **the regenerated `options.md` is the authority.**
  Extract its 155 keys, take the 31 distinct top-level roots, and rename only
  `nebelhaus.<root>`. That test also correctly keeps `<name>` submodule instances
  (`nebelhaus.roster.slack`, `nebelhaus.workspaces.D`) — which read like data,
  not options, and a hand-curated list would have missed.

  🚨 **And it silently breaks 20 in-page links, because the anchor is the option
  name with the dots removed.** `/reference/options/#nebelhausthemeaccent` still
  resolves to a page that exists, so nothing 404s, nothing fails the build, and
  Starlight does not check fragments — the reader just lands at the top of a
  700-line page. Sweep `#nebelhaus<slug>` → `#haus<slug>` in the same pass and
  assert every anchor against the regenerated headings; that check found the one
  link that had **already** been broken before the rename
  (`#one-list-nebelhausroster`, a truncation of a heading slug), which is the
  argument for asserting rather than substituting.

  🚨 **A dot-based sweep does not find the namespace's other spelling, and the
  assurance pass is what caught it.** A rice file's top-level key is the
  namespace with no dot after it — `{ haus = { … }; }` — so
  `guides/sharing-a-rice.mdx` and `guides/making-it-yours.mdx` went on teaching
  `{ nebelhaus = …; }` while the *same pages*, edited by the same commit, said
  "a file that changes only `haus.*`". Self-contradictory 30 lines apart, and
  every regex above was blind to it because there is nothing after the word.
  `checkRice` still accepts both keys (§1.1a step 4), so nothing would have
  failed — a reader would just have copied the deprecated form out of the
  authoring guide. Two more of the same shape: `web/src/pages/` is not under
  `content/docs/` and its `perch.astro` teaches an option in landing-page copy,
  and the sweep's own summary called what remained "brand prose" when three
  namespace misses were still in the tree. **Grep the bare word too, and read
  the result — most hits are the brand and must stay.**

  Added while there: a `haus.md` aside saying `nebelhaus.*` still works via the
  alias. The docs had renamed the namespace with no signal to the people whose
  host files are entirely the old spelling.

  Verified by running it: `gen-options.mjs --check` current,
  `check-rice-bindings.mjs` unchanged, `npm run build` green at 33 pages, every
  `#haus` fragment resolves and a site-wide fragment check finds zero dangling.
  What's left for §2 in `web/` is genuinely **brand** prose —
  `what-is-nebelhaus.md` and its redirect, `astro.config.mjs`'s `site:` — which
  belongs with §5's domain move, not here.
- ✅ **bench** — one line, `bench:2`'s header ("the workshop CLI for the
  hausfold family"), done 2026-08-09. **Everything else this bullet named is a
  resolving identifier and belongs to §3.** `FAMILY=(…)` at `bench:78` is a list
  of *directory names* (`local_src` → `$ROOT/$1`), which §3.1's
  on-disk-collision decision settles; the repo lists at `:1005`/`:1453`/`:1539`,
  `GH_ORG` at `:79` and the `--override-input nebelhaus/*` block at `:281-286`
  are §3.3's edges — along with eight more literals §3.3 enumerates. Moving any
  of them before the transfer breaks `bench` on a live machine.
  ✅ **The archived Messages client's `FAMILY` entry is gone — workshop#283,
  2026-08-09.** This bullet used to say *leave it alone*: it was kept
  deliberately so `bench status` reported the checkout, it read `trill` until
  workshop#269 renamed repo + entry + on-disk dir together (§3.4), and removing
  it counted as a behavior change §2 was gated against. #283 made that removal
  its own change — the repo is archived and read-only, with no lock edge below
  it and no release path above it, so `status`/`clone`/`pull` had nothing useful
  to say about it. Nothing in `FAMILY` may ever read `trill` either: that name is
  the notification compositor's, which is deliberately not a family repo, so the
  entry would read as either app depending on who looked.
- ✅ **workshop — done 2026-08-09.** `README.md` title + `part_of` badge,
  `AGENTS.md`'s opening ("the **hausfold** workshop … every repo in the
  **hausfold** family"), the three `.agents/skills/*` descriptions and
  `.codex/config.toml:1`, all of which said "the nebelhaus family / workshop".
  The routing table itself is repo names and stays.
  ✅ Including `incubator/trill/README.md:11`'s badge, swept once workshop#269
  landed and stopped moving that directory out from under it. *(It was
  `incubator/flick/` when this bullet was written — deferring one line was
  cheaper than conflicting with a whole-directory rename.)*

  **Plus the namespace residue §1 structurally couldn't reach.** §1 renamed the
  *rice*; nothing renamed the option paths quoted in **other** repos' prose, and
  they read as live instructions: `AGENTS.md:113` told every agent the default
  client comes from `nebelhaus.agents.default`, `.agents/README.md`'s
  `nebelhaus.claude.skill`, the ship skill's atomicity row, and
  `README.md`'s installer roadmap. All → `haus.*`. Find them with the root list,
  not by eye:

  ```sh
  R=$(grep -oE '^### `haus\.[a-zA-Z0-9_]+' web/src/content/docs/reference/options.md \
      | sed 's/^### `haus\.//' | sort -u | paste -sd'|' -)
  grep -rnP "(?<![.\w/-])nebelhaus\.($R)\b" .
  ```

  The lookbehind is what keeps `com.nebelhaus.perch` (§4) and
  `nebelhaus/modules/…` (a path) out of the result — **`perch` and `pounce` are
  both option roots and both bundle-id components**, so a bare
  `nebelhaus\.(perch|pounce)` matches the thing §4 owns.

  Deliberately left: the historical anecdotes in `options-drift.yml:17` and
  `gen-options.mjs:5` (they describe options as they were named at the time),
  everything under `notes/` (historical record, `options-roadmap.md` §5.14),
  and `docs/workflows.md`, whose every hit is a repo name, a URL or the domain.
- ✅ **nebelung / pounce / perch** (+ the rice) — **done 2026-08-09**:
  nebelhaus#266, nebelung#33, pounce#68, perch#46. The `part_of-nebelhaus`
  shields badge in each (the family is hausfold now, and the badge is safe
  before §3 — shields.io, no GitHub dependency), `perch/AGENTS.md:3`'s "in the
  nebelhaus family", and **fifteen live option references the rice's own rename
  structurally could not reach**: pounce's `docs/reference.md` and two Swift
  files (one of them the stderr line a user reads when they try to edit a
  store-owned `config.json` — it told them to go edit `nebelhaus.pounce.*`),
  perch's `AGENTS.md`, `docs/reference.md` and `RicePalette.swift`, and
  nebelung's palette-generator comment. Everything else in these repos is a
  repo URL, the tap slug, or `nebelhaus` meaning the rice. **holt has zero
  hits.** `org-profile` and `homebrew-tap` are §3, not §2: `nebelhaus/.github`
  and `nebelhaus/tap` are the org's own name, and the tap slug is what
  `brew tap` resolves.

  **Two exclusions worth naming, because both look like misses:**
  `perch/docs/architecture-decisions/0002` keeps the old spelling — an ADR is a
  dated record of what was decided, and rewriting the option name inside one
  makes it claim a decision taken against a namespace that didn't exist yet.
  And `nebelhaus/test/haus-settings.sh:37-38` keeps it because it *is* the
  regression test for `modules/renamed.nix`: it asserts `haus set` accepts the
  pre-rename prefix and does not write it back. Renaming those two lines
  deletes the only coverage the alias has.

  🚨 **The copyright surface is one escalation, not four edits, and it is
  already self-contradictory.** Four READMEs say `© nebelhaus`
  (nebelung:181, pounce:133, perch:95, workshop:151) while the LICENSE files
  they summarise say `Copyright (c) 2026 Julien Martel` — **except perch's,
  which says `nebelhaus`** (`perch/LICENSE:9`), the only copyright line in the
  family naming a brand. perch is the **paid** product on a fair-source
  licence, so its holder is a legal-identity choice — `hausfold`
  (unincorporated today, §0.2) or the person — not a naming one, and swapping
  the word in the README alone would leave the README and the LICENSE naming
  two different holders.

  ✅ **Decided 2026-08-09: `hausfold`, on all five.** The seller is hausfold,
  and perch's holder is the name that ends up on a receipt — so the brand, not
  the person, and not the rice. Landed as nebelung#34, pounce#69,
  workshop#275, perch#47.
  ⚠️ **`perch/LICENSE:9` needs one hand edit and perch#47 must not merge
  without it.** The agent harness refuses an agent editing a licence holder
  line — the right default — so that PR carries the README half only, and its
  README *quotes* the LICENSE. Half of it is worse than none of it.
  🟨 **perch#47 merged anyway, 2026-08-09, without the hand edit — closed the
  same day by [perch#48](https://github.com/nebelhaus/perch/pull/48).** For a
  few hours perch sat in exactly the half-state this warning existed to
  prevent: `README.md:94` reading `FSL-1.1-ALv2 © hausfold` over a
  `LICENSE:9` still reading `Copyright (c) 2026 nebelhaus` — one repo, two
  holders, on the **paid** product's licence. perch#48 is the one word, made
  on the user's explicit instruction; absent that, agents leave a licence
  holder line alone. The repo has exactly two copyright lines and they now
  agree verbatim.
  *(Worth keeping after the ✅: the merge is what the gate could not stop. A
  "must not merge without X" that lives only in a note is not a gate — nothing
  enforced this one, and nothing will enforce the next.)*
  ⚠️ **The substance behind the word is NOT settled: `hausfold` is not a legal
  person.** Copyright vests in the author; an unincorporated brand can neither
  hold nor assign title, so today the notice is a trade name. Ordinary on an
  MIT repo, sharper on perch — the FSL hangs its patent grant, its
  Competing-Use carve-out and its **trademark reservation** on the same
  `Licensor ("We")`, and perch is the product with hausfold as seller of
  record. Nothing is lost by writing it now (incorporating means an
  author→entity assignment either way), but this is an **accepted** position,
  not a resolved one. Re-read all five notices at §0.2's trigger — filing,
  paid marketing, or incorporating — which is the same moment the three
  `Julien Martel` MIT files get answered.
  ⏳ **And the other three LICENSE files still say `Julien Martel`**
  (nebelhaus, nebelung, pounce — all MIT). That mismatch predates the rename
  and is not a regression, but it is now the whole remaining inconsistency:
  four READMEs saying `hausfold` over three LICENSEs saying a person. One
  deliberate pass, with §0.2's incorporation trigger — the same question,
  which is why it isn't worth answering twice.

### 2.2 🤖 The agent surface specifically

Easy to miss and it breaks *your* sessions, not users':

- ✅ `nebelhaus.claude.globalMd` → `haus.claude.globalMd`, in `hearth` — done in
  nebelhaus#261 with the rest of the namespace. **Moved again 2026-08-11:
  `haus.claude.*` → `haus.agents.instructions` / `haus.agents.skill`, and the
  `claude` option group folded into `agents`.** Not part of this rename — the
  `claude` room was named for one CLIENT, and both its options describe a file
  every client reads, so hearth now writes one copy per entry in
  `haus.agents.clients` (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`,
  `~/.config/opencode/AGENTS.md`, and the matching skills dirs). Aliased in a new
  `modules/moved.nix`, which is the file for in-namespace moves — `renamed.nix`
  stays the generated `nebelhaus.*` set with its own deletion condition.
  ⚠️ Writing a file per client is also a **reach-table** change: `flake.nix`'s
  `expectedScaleTable` / `expectedFontTable` enumerate every `home.file` entry by
  literal path, and they only diff at BUILD time — `nix flake check --no-build`
  passes while the real run goes red naming a font/scale error nobody associates
  with the agents room. Handled in hausfold/haus#312; the same trap waits for the
  next option that writes per-client.
- ✅ The generated skill dir `~/.claude/skills/nebelhaus/` → `.../haus/`, and the
  skill's own `name:` + description — **landed 2026-08-08: nebelhaus#263 (the
  rice), workshop#268 (the docs that point at it), workshop#271 (the
  regenerated option description, auto-opened by `options-drift.yml` and merged
  2026-08-09). Released as v2026.08.08-2 and the locks are rippled.**
  ⏳ **`~/.claude/skills/haus/` does not exist on this machine yet** — the
  rebuild that creates it is 👤's, and until it runs the *old* `skills/nebelhaus/`
  is what a session actually loads. Don't read its absence as a failed rename.
  ⚠️ **Two golden tests pin that path by hand.** The literal line
  `file .claude/skills/nebelhaus/references/this-machine.md moves` is in
  **both** `expectedScaleTable` (`nebelhaus/flake.nix:1233`) and
  `expectedFontTable` (`:1350`). So the rename fails the *scale-reach* and
  *font-reach* checks — errors about scale and fonts, the last two places anyone
  would look. Fix only one and the other still fires. Move both in the same commit.
  🚨 **And `nix flake check --no-build` passes anyway.** Both are
  `pkgs.runCommand` with the `diff -u` in the *builder*, so the table
  comparison only runs when they are BUILT. The rice's CI does run the full
  `nix flake check` (`.github/workflows/check.yml:36`) and would have caught
  it — so the gap isn't in the pipeline, it's in the shortcut an agent reaches
  for locally. `nix build .#checks.aarch64-darwin.{scale-reach,font-reach}` is
  the local equivalent. Same shape as §1.1a's "what only a build caught,
  twice": eval-green is not the same claim as build-green.

  **A do-not-touch list is the one place a rename must delete an entry, not
  edit it.** `nebelhaus/AGENTS.md` carries a "three things stay `nebelhaus`, and
  they are not drift" stanza that listed the skill path. The bulk rename
  rewrote it *in place*, so the rice's own instructions ended up asserting that
  `~/.claude/skills/haus/` is a thing that stays `nebelhaus` and isn't the
  current phase — a licence for the next session to put the old path back.
  Caught by the assurance pass, not by any build.

  Two more the pass caught, both downstream and neither self-healing: the
  workshop's `guides/ai-agent.mdx` had a copy-paste block that would have
  **ENOENT**'d the day this merged, and `web/src/pages/llms{,-full}.txt.ts` —
  the pointer we hand to *other* models — named the old path. Generated
  `reference/options.md` self-heals, but only on the next `options-drift` run.

  Migration needed nothing: the six files are plain `home.file` entries, so
  home-manager's cleanup removes the orphaned leaves and `rmdir`s
  `skills/nebelhaus/` on the same rebuild that creates `skills/haus/`. The
  user-visible cost is that the slash command becomes **`/haus`**, and a
  session running across the rebuild keeps the old skill until it restarts.
- ⚠️ **The state directories are NOT part of this phase, and that is a
  decision, not an oversight.** *(And since decision 8 they are misnamed a
  third way: the dir belongs to the **layer**, which is now called `haus` — so
  neither "it's the rice's name" nor "it's the org's name" explains it any
  more. Still held, for the reason below: the reason was never the name.)*
  `~/.local/state/nebelhaus/`,
  `~/.config/nebelhaus/` and `share/nebelhaus/host-options.nix` all still carry
  the old name. The state dir holds `settings-snapshots` — written by `haus
  capture` and by every rebuild, and read by **`haus revert-settings`**
  (`modules/den/haus.sh:619`, `:733`, `:781`). Not `haus set`'s undo, which is
  `unset`/`reset` and edits Nix options; getting that wrong understates the
  stakes, because `revert-settings` is the *only* escape hatch for macOS
  defaults that a Nix rollback cannot reach. Renaming the dir orphans that
  state on every installed machine for a cosmetic gain — the same trade §0.6
  made the *other* way for perch, and it came out differently here only
  because there is no deadline forcing it.
  Decide it with §4, or leave it forever; either is defensible, silently
  half-doing it is not.
- ✅ `~/.claude/CLAUDE.md`'s generated body (rendered from the option above) —
  done 2026-08-09 in `~/.config/nix` (`hosts/mbp/default.nix`): "the hausfold
  family", and the workshop dir it names is `~/code/workshop`, renamed off
  `nebelhaus` back in 2026-07 and never updated here.
- ✅ **`~/.config/nix`'s own agent files, which nothing self-heals.**
  `CLAUDE.md:22` and `.agents/README.md:41` both pointed at
  `~/.claude/skills/nebelhaus/` and the first also named
  `nebelhaus.claude.skill`. They were **hand-copied from the rice's shipped
  starter pair**, so a rice-side rename can never reach them — which is the
  general shape: *the starter pair is a copy, and every copy of a generated
  file is a place the generator's rename doesn't arrive.* Fixed 2026-08-09,
  along with the worktree-hook row that still said `wt create` / `wt remove`
  (retired in nebelhaus#245).
  ⚠️ Still on the old spelling **on purpose**: `hosts/mbp/default.nix`'s 41
  `nebelhaus.*` option settings (§1.1a step 6 — they are what keeps proving the
  alias works) and `AGENTS.md:67`, which points at them. Those two move
  together or not at all. `nebelhaus.mkNebelhaus` in `flake.nix` is the input,
  and stays.
- ✅ **The agent memory files** (§9's tail) — swept 2026-08-09. 15 of the ~50
  under `~/.claude/projects/-Users-julienmartel-code-workshop/memory/` carried
  live `nebelhaus.<option>` paths; all now `haus.*`, by the root-list method in
  §2.1. `org.nebelhaus.editoropen` and `com.nebelhaus.trill.dev` correctly
  survived the lookbehind (§4 owns them). Added one new memory,
  `haus-namespace-hausfold-brand.md`, carrying §2's four-bucket table — recall
  is per-file, so the *rule* has to be a file of its own or a session only
  learns it by accident.
- `HAUS_CONSUMER` — already `haus`-prefixed, **no change**.
- `holt` hooks — repo-agnostic, **no change**.
- `~/.cache/claude-worktrees/` — already documented as historical, **leave**.

**Gate:** `bench try` builds; the §1.2 derivation walk shows **no leaf divergence
beyond `options.json` and the generated files this phase deliberately edited**
(the ~12 `# GENERATED from nebelhaus.*` comment lines — see the fourth class
above); the docs site builds and `nix build .#options-json` regenerates
`reference/options.md` with zero drift. *(This used to read "the §1.2 derivation
diff is still empty", which §2 is designed to break — the exact shape of
over-broad gate §1.2 warns gets deleted rather than met.)* *(No `haus rebuild` here — that activates the machine, which is
👤's, never 🤖's.)*

---

## §3 — The GitHub org migration

9 repos (10 until §3.4 took the archived Messages client off the list). **Do all
transfers in one sitting**, then one lock ripple — a half-migrated org means
flake inputs resolving through redirects for days.

### 3.1 ✅ Pre-flight — complete

**All six bullets below are now settled** — four measured against the live API
2026-08-08, and the first two ticked because their own prose already resolved
them (there is no name collision; the on-disk one is resolved by §5.1). Which
turns the transfer sitting into clicking.

**This section originally closed with five open boxes, not one.** `gh auth
refresh` was the only command; the other four were owner-keyed identifiers the
original list missed. As of 2026-08-09 every box is checked, including npm's
post-transfer publisher flip, so §3.3's owner-identifier gate and the holt
release gate are satisfied.

- [x] 👤 `gh auth refresh -h github.com -s admin:org`, then list the org secrets.
      **✅ run 2026-08-09: `orgs/nebelhaus/actions/secrets` returns
      `total_count: 0`.** There were never any org secrets, so nothing was
      silently left behind by the transfer — the repo-level table above is the
      whole picture.
- [x] 🤖 ~~**`bench`'s `GH_ORG` can no longer be one value**~~ — **dissolved
      2026-08-09 by workshop#283**, which reaped the archived Messages client
      from `FAMILY` entirely. The finding was real when written: §3.4 keeps that
      repo in the `nebelhaus` org, so a single `GH_ORG` would have made
      `bench clone` ask for `hausfold/messages` and die. With the entry gone,
      every `FAMILY` member is in one org again. **`GH_ORG="hausfold"` landed in
      workshop#8017988**, with a `gh_repo <name>` indirection for the two
      checkouts whose directory name isn't their repo name.
- [x] npm's trusted publisher below — flipped to `hausfold/holt` 2026-08-09

- [x] `hausfold` org has `website` (archived), `hausfold.co` and `ops` today.
      Confirm **no GitHub name collision** with an incoming repo — there isn't
      one, none of the three is on §3.2's transfer list.
- [x] ⚠️ **There IS an on-disk collision, and it must be decided before §2.1.**
      *(Decided here — but **still unimplemented in `bench`, and pointing the
      wrong way**. See §3.3's `bench` subsection: that is where it gets fixed.)*
      `bench` resolves `FAMILY` entries as *directory names* under the workshop
      root (`local_src` → `$ROOT/$1` at `bench:249-255`; `cmd_clone`'s
      `[ -d "$ROOT/$name/.git" ]` at `bench:1542`). Renaming the FAMILY entry
      `nebelhaus` → `hausfold` puts the platform checkout at
      `~/code/workshop/hausfold` — **which is already the site checkout**
      (`hausfold/website` then, `hausfold/hausfold.co` now). This repo survived
      exactly this once before (the
      `~/code/nebelhaus` → `~/code/workshop` rename, and the child-repo name
      collision that forced it). Pick one:
      **(a)** keep the platform's *directory* named `nebelhaus/` even though the
      repo is `hausfold/hausfold` — zero churn, mildly confusing; or
      **(b)** move the website checkout to `website/` and update `bench:1005`'s
      `repos=(… hausfold consumer)` list plus the comment at `bench:1002-1004`.
      **✅ Resolved by §5.1's decision: take (b).** The site consolidates into
      `hausfold/hausfold.co`, so the checkouts become `workshop/hausfold/` (the
      platform) and `workshop/hausfold.co/` (the site) — each named for its repo.
      *(This read `workshop/website/` until 2026-08-08, when the site repo was
      recreated under a new name; the on-disk name follows the repo.)*
- [x] Confirm you can create repos in `hausfold` and that transfer targets show
      it. **✅ measured 2026-08-08:** `gh api user/memberships/orgs/hausfold` and
      `…/nebelhaus` both return `admin` / `active`, so both ends of every row in
      §3.2 are yours — which is the condition GitHub puts on the transfer form
      offering an org as a target at all.
- [x] **Repo secrets travel with the repo; org-level secrets do not.**
      **✅ measured 2026-08-08 — every secret the family uses is repo-level**, so
      the transfer carries all of them:

      | repo | secrets |
      |---|---|
      | `perch` | `ASC_*` ×3, `IOS_DIST_CERT_P12`+`_PASSWORD`, `MACOS_CERT_P12`+`_PASSWORD`, `NOTARY_*` ×3, `TAP_DEPLOY_KEY` |
      | `pounce` | `MACOS_CERT_*`, `NOTARY_*` ×3, `TAP_DEPLOY_KEY` |
      | `workshop` | `CLOUDFLARE_ACCOUNT_ID` / `_API_TOKEN` / `_ZONE_ID` |
      | `holt` | `MIRROR_TOKEN` — ⚠️ the one that doesn't survive, see below |
      | `messages` (archived, **stays in `nebelhaus`** — §3.4) | `MACOS_CERT_*`, `NOTARY_*` ×3, `TAP_DEPLOY_KEY` |
      | `nebelhaus`, `nebelung`, `homebrew-tap`, `.github`, `holt-swift` | none |

      ✅ **The org half is closed.** After refreshing the token's `admin:org`
      scope, `gh api orgs/nebelhaus/actions/secrets` returned `total_count: 0`;
      there was no owner-scoped secret to strand.
- [x] **Deploy keys and Actions permissions** — **✅ measured: the three keys all
      live on `homebrew-tap`** (the *receiving* end of the bump, which is where a
      deploy key has to be), titled `pounce release workflow`,
      `perch release workflow` and `trill release workflow`, all
      **read-only = false**. Deploy keys are repo objects and travel with the
      repo, so pounce/perch keep pushing after the transfer, and their private
      halves are the `TAP_DEPLOY_KEY` secrets in the table above — for those two,
      both ends move together. ⚠️ **The third key is the exception, and it
      sharpens the advice rather than softening it:** `trill release workflow`'s
      private half is the `TAP_DEPLOY_KEY` in **`nebelhaus/messages`**, which per
      §3.4 does *not* transfer — so after the sitting a repo left behind in the
      dead org still holds a live **write** key to the tap in its new org. The
      cask it existed for is already deleted, so **delete the key** (tap →
      Settings → Deploy keys) while you're in there; nothing uses it. The
      workflows themselves hardcode `repository: nebelhaus/homebrew-tap` —
      `perch/.github/workflows/release.yml:156` and
      `pounce/.github/workflows/release.yml:185` (**not** the same line number;
      pounce's job name is at `:179`) — which is §3.3's sweep, not a credential.
- [x] Cloudflare Pages / Workers GitHub integrations bound to `nebelhaus/*`
      repos will need re-authorizing against the new owner. **✅ measured: there
      are none, and this bullet is a non-issue.** Both sites deploy by running
      `npx wrangler deploy` inside a GitHub Actions job authenticated with the
      `CLOUDFLARE_API_TOKEN` repo secret (`.github/workflows/deploy-web.yml:58`,
      `preview-web.yml`, and `hausfold.co`'s own `deploy.yml:52-64` — its
      `preview.yml` is the PR preview, not the deploy) — there is no
      Cloudflare↔GitHub app installation to re-point, and an API token is scoped
      to a Cloudflare account, which the transfer doesn't touch.

#### 🚨 Four identifiers that do **not** travel with a transfer

The bullets above are the reassuring half: secrets and deploy keys are repo
objects and move with the repo. These four are keyed to the **owner**, so they
break at the moment of transfer while every test still passes locally — and all
four are in `holt`, the one repo that publishes to the outside world.

| | What breaks | Fix |
|---|---|---|
| `MIRROR_TOKEN` | a fine-grained PAT's resource owner is an **org**, so a token scoped to `nebelhaus/holt-swift` cannot write to `hausfold/holt-swift` (`holt/.github/workflows/release.yml:37`) | re-mint against `hausfold`, replace the repo secret |
| npm / PyPI / crates.io **trusted publishers** | all three authenticate by OIDC with **no fallback token**, and each is configured with owner `nebelhaus` (`holt/docs/releasing.md:93-95`, restated in the workflow header at `holt/.github/workflows/release.yml:28-33`). GitHub's OIDC claim carries the *current* owner, so the next publish fails the trust check | **add a *second* trusted publisher for `hausfold/holt` alongside the existing one, before the transfer.** Not a *pending* publisher — that's for packages that don't exist yet, and all three (`@hausfold/holt`, `hausfold-holt` ×2) already do. PyPI and crates.io accept multiple publishers, so both can be pre-armed; **npm's is single-valued and must be flipped after** the transfer, which makes npm the one narrow window |
| the **Go SDK's module path** | `module github.com/nebelhaus/holt/sdk/go` (`sdk/go/go.mod:1`), already published at `v0.2.1` on the immutable proxy. ⚠️ And it is **not one line** — see §3.3's Tier D: the *root* module `holt/go.mod:1` is `github.com/nebelhaus/holt`, spelled out in 60 imports across 23 `.go` files | see below — a decision, not a chore, and **✅ decided: keep the path.** Recorded in §6 so a later sweep can't undo it |
| the **SwiftPM mirror URL** | `holt/sdk/swift/sync-mirror.sh:22`'s default *and* the live one — the credentialed push URL CI actually uses, `holt/.github/workflows/release.yml:239` — plus every consumer's `Package.swift` dependency URL | sweep in §3.3; SPM follows a redirect but records the old URL in `Package.resolved` |

⚠️ **None of these four is reachable by §3.3's gate**, which checks locks, a
build and a clone. All four fail for the first time at the next
`bench release holt` — which blocks on CI and would go red **mid-release**, with
some SDKs published and some not. So they get boxes of their own, and §3.3's
gate names them: **no `bench release holt` until all four are ticked.**

- [x] `MIRROR_TOKEN` re-minted against `hausfold` and replaced as holt's repo
      secret — the secret was replaced 2026-08-09 after the transfer.
- [x] second trusted publisher armed on PyPI and crates.io **before** the
      transfer — **done 2026-08-09, ahead of the sitting.**
- [x] **npm's trusted publisher flipped to `hausfold/holt` 2026-08-09.** It is
      single-valued, so this was the one publisher that had to wait until after
      the transfer.
- [x] the Go module path decision honoured (keep it — §6) rather than swept —
      both `go.mod` files and the 60 internal imports still use the published
      path.
- [x] the SwiftPM mirror URL rewritten in both places; no family consumer has a
      `Package.resolved` entry for it to refresh.

If one does fire mid-release anyway, the publish jobs are independent and
idempotent, so `gh run rerun --failed` recovers it once the identifier is fixed.

**The Go one is the only one with a real fork, and it should be taken
deliberately rather than by whichever agent runs §3.3.** A Go module *is* its
import path. Two options:

- **Keep `github.com/nebelhaus/holt/sdk/go` forever.** Costs nothing and breaks
  nobody: `go get` follows GitHub's redirect, and the path in `go.mod` still
  matches what was requested, so new tags keep resolving. The smell is a
  `hausfold` SDK importing as `nebelhaus` for the rest of its life.
  ⚠️ **This option has a dependency, and it is written down two sections away:**
  it works only because §3.2 commits to keeping the `nebelhaus` org alive to hold
  redirects. Delete that org and every `go get` of the SDK stops resolving. Same
  dependency as the shipped-binary update endpoints in §3.3 — the dead org is
  load-bearing infrastructure, not a courtesy.
- **Move it to `github.com/hausfold/holt/sdk/go`.** That is a *different module*
  in Go's eyes — every importer edits their imports, the two paths' version
  histories diverge on the proxy, and the published `v0.1.0`/`v0.2.x` lines stay
  at the old path forever.

⚠️ Whichever way it goes, remember `bench release holt`'s invariant: **five SDKs
share one version number.** A path change is therefore a version-contract event
for all five, so it belongs in a release, not in the transfer sitting. **Take
option 1 for the transfer** and revisit at the next major bump — where an import
path is *allowed* to change and nobody is surprised.

### 3.2 👤 Transfer, in this order

Upstream first, so each lock bump has a settled target:

| # | From | To | Note |
|---|---|---|---|
| 1 | `nebelhaus/nebelung` | `hausfold/nebelung` | keeps its name — see §6 |
| 2 | `nebelhaus/pounce` | `hausfold/pounce` | |
| 3 | `nebelhaus/perch` | `hausfold/perch` | |
| 4 | `nebelhaus/holt` | `hausfold/holt` | |
| 5 | `nebelhaus/holt-swift` | `hausfold/holt-swift` | the generated SPM mirror |
| 6 | `nebelhaus/nebelhaus` | `hausfold/hausfold` | **rename during/after transfer** |
| 7 | `nebelhaus/workshop` | `hausfold/workshop` | |
| 8 | `nebelhaus/homebrew-tap` | `hausfold/homebrew-tap` | |
| 9 | `nebelhaus/.github` | `hausfold/.github` | the org front page |
| 10 | ~~`nebelhaus/trill`~~ | ✅ **done — `nebelhaus/messages`, and it stays there** | reversed and executed 2026-08-08, see §3.4. It does NOT transfer, and it must never arrive at `hausfold/trill` — the notification compositor holds that name. |

**Keep the `nebelhaus` org alive and empty.** It costs nothing and holds every
redirect. Deleting it breaks them permanently.

✅ **One repo that doesn't exist yet still had to be repointed: `flick` — done
2026-08-08, and it came back as `trill`.** Its eject target was written as
`nebelhaus/flick` across `AGENTS.md`, its own `BOOTSTRAP.md` and `CLAUDE.md`,
`.agents/README.md` and `nix/package.nix`. There was no row for it in the table
above because there was no repo to transfer — which is exactly how it gets
created in the dead org months from now. It now points at **`hausfold/trill`**.
Treat "a repo that doesn't exist yet" as a category the transfer table
structurally can't see.

✅ **And that repo now exists: `hausfold/trill`, public, ejected 2026-08-09**
(workshop#286). Born in the right org on the first try — which is the whole
point of having repointed it while it was still a string in a checklist. Three
`github.com/nebelhaus` links in its own tree (`AGENTS.md`, `README.md`,
`.agents/README.md`) were caught in the same change; a repo born in the new org
linking the old one is the same trap one indirection out. The workshop's
`incubator/` is gone with it.

### 3.4 ✅ Decided 2026-08-08 — flick becomes **trill**, and the old trill stays behind

The family's iMessage/SMS client was archived 2026-08-04, which freed the name
it was using. The notification compositor incubating as **flick** took it: a
trill is the small chirred note a cat makes in passing, which is what a quiet
notification compositor *is*. An ear-flick was the second-best version of the
same image, and the name was free for the price of a `git mv` — the app has no
repo, no release, no cask and no install base yet, so this is the cheapest it
will ever be. **After eject it costs a repo rename, a cask token change, a
bundle-ID change that strands the TCC grant, and a flake-input ripple.**

Two consequences that reverse rows written above:

1. **The archived client does not transfer.** §3.2 row 10 said "transfer or
   leave, low stakes"; it is now "leave, and rename", because leaving it named
   `trill` anywhere the compositor also lives is what makes it not low stakes.
   It is renamed in place inside `nebelhaus` — the org stays alive to hold
   redirects (§3.2 already says so), and GitHub redirects `nebelhaus/trill` to
   `nebelhaus/messages`, including its release-asset URLs. **Renaming needs it
   unarchived and re-archived** — GitHub makes an archived repo's settings
   read-only.
2. **`flick` leaves §6's do-not-change list** and `com.nebelhaus.flick` leaves
   §4.2's pending column — both are already done.

**The new name is `messages`** — decided 2026-08-08, chosen over
`trill-messages` for a clean break rather than a tombstone that keeps the word
"trill" in search results beside the live app. All three slots the old app held
are now free:

| Slot | Was | State |
|---|---|---|
| GitHub repo name | `nebelhaus/trill` | ✅ **`nebelhaus/messages`**, still archived. Never needed to move for the compositor (different org) — renamed so the two apps are never both "trill". |
| on-disk `~/code/workshop/trill` | the archived clone | ✅ `~/code/workshop/messages`, remote repointed, `.gitignore` and `bench`'s `FAMILY` entry following (§3.1's rule: each checkout named for its repo). The dir is what the eject's final `mv` needs. ⚠️ **workshop#283 then reaped the workshop's side of it entirely**: the `FAMILY` entry and the `.gitignore` line are both gone, so `bench clone` no longer fetches it and `bench status` no longer reports it. ✅ **And the checkout is gone — deleted 2026-08-09, 👤.** For a few hours it sat there *untracked*: #283 dropped the `/messages/` ignore line without removing the dir, so the workshop showed `?? messages/` and a `git add -A` up there would have tried to add a nested repo. Deleting it was the answer over restoring the ignore line — the repo is archived on GitHub and its releases stay downloadable, so a local clone bought nothing. **Nothing local points at the archived client any more**, and `~/code/workshop/trill` is free for the compositor's eject. |
| Homebrew cask token `trill` | `homebrew-tap/Casks/trill.rb` | ✅ **deleted.** Not `disable!`-then-deleted: the cask had no install base (`brew list --cask` found it nowhere, no `Trill.app` on disk), and the final release stays downloadable regardless. |

How the rename was done, because it isn't the obvious one-liner:

```sh
gh api -X PATCH repos/nebelhaus/trill  -F archived=false   # settings are
gh api -X PATCH repos/nebelhaus/trill  -f name=messages     # read-only while
gh api -X PATCH repos/nebelhaus/messages -F archived=true   # archived
```

GitHub keeps the `nebelhaus/trill` → `nebelhaus/messages` redirect for the web
UI, the API and **release-asset URLs** (verified: the v2026.08.04-1 zip still
returns 200 through the old path). Everything we own is spelled `messages`
anyway rather than living on that redirect.

This is §3.1's on-disk-collision finding recurring with different names: two
family repos wanting one directory. It was resolved there by naming each
checkout for its repo, and the same rule settles it here.

**Inherited leftovers in `web/` — all cleared, 2026-08-08 (workshop#269).** The
bullets below were written mid-PR, when the plan was to *repoint* the archived
app's plumbing; the PR's last web commit **removed** it instead — the site
presents the living family only. Kept with their outcomes because two of them
were recorded here as blockers and are not blockers any more:

- ✅ `astro.config.mjs`'s four `/trill*` redirects are **gone**, not repointed.
  This block's earlier 🚨 said a compositor docs page at `/trill` could not
  exist until they came out — **they are out, so `/trill` is free.** Accepted
  knowingly at the time: the URL the archived app's about box prints and the
  two `/guides/trill/` links frozen into its README now 404. Nothing else
  referenced them, the cask that printed one was deleted the same day, and
  there is no install base.
- ✅ `worker.js`'s `DOWNLOADABLE` is `{pounce, perch}`. The slug went `trill` →
  `messages` first and then came out altogether — a `/download` route for a
  finished app is a promise we don't want to keep. Its releases stay on GitHub
  for anyone holding the link, so `/download/trill` is free as well.
- ✅ `--neb-product-trill` (+ `-hover`) in `styles/palette.css` and the
  `'trill'` slot in `FamilyNav.astro` are gone, together with the dead
  `product === 'trill'` branch in `ProductDemo.astro` (+33/−388 there alone),
  every `.trill-*` rule and `/media/app-icons/trill.png`. The perch demo ferries
  **Pounce** through the notch shelf now and the pounce demo lists **Perch**.
  One survivor was caught later, by workshop#283's assurance pass: the perch
  demo's mock browser still read *"Your Messages, native."* under a
  `nebelhaus.com/pounce` URL pill — a rendered, on-screen tagline for the
  archived app, missed because it names the product nowhere in the markup.
- ✅ The ~70 classes that dead branch *shared* with the live demos
  (`.chat-row`, `.bubble`, `.tapback`, `.search-sheet`, …) sat under an
  `ORPHANED` note rather than being purged in the same change, so a broken
  pounce/perch demo could never be blamed on the removal. That worry has
  passed and workshop#291 swept them: 1,005 lines, 305 rules and 31 keyframes
  out, **0 surviving rules rewritten** — a rule died only when a selector named
  a class absent from the markup, a `@keyframes` only when nothing animated it.
  Because `inlineStylesheets: 'always'` inlines this CSS, `/pounce` dropped
  80,849 → 62,549 bytes and `/perch` 78,703 → 60,403. A negative test now
  fails if any of it comes back.

So the compositor's page starts from a clean `/trill`, a free `/download/trill`
and no product colour of its own yet — `--neb-product-trill` will have to be
declared, not inherited. Nothing here carries over. The one
"Trill" still rendered on the site is `reference/options.md`'s `float`
description ("FaceTime, Trill's Settings/Inbox") — **that one is the
compositor**, generated from the rice after nebelhaus#264 renamed
`haus.roster.flick` → `haus.roster.trill`. It looks like leftover drift and
isn't.

### 3.3 🤖 Rewrite every edge — **but not every hit**

> ✅ **Swept 2026-08-09**, one PR per repo, seven of them. Everything below is kept
> as written because it is the *reasoning*, and a later session re-reading it
> needs the Tier D table more than it needs a tick. What actually landed:
>
> | repo | the edge that mattered |
> |---|---|
> | nebelung | the two `templates/css/*.tera` headers, stamped into eight `dist/**` files consumers copy — `dist/` regenerated in the same commit |
> | pounce | `flake.nix`'s `nebelung` input + lock; `update-pounce.sh` and `UpdateCheck.swift`'s self-update endpoints; the release asset URL the tap is fed |
> | perch | `nix/package.nix`'s `fetchurl` (proved with a real build — the sha256 was not allowed to move); `UpdateCheck.swift` + its test literals; the tap checkout and both asset URLs |
> | holt | the SwiftPM mirror (`sync-mirror.sh:22`, `release.yml:239`) and the written record of all three trusted publishers. **The Go module path was NOT touched** — see Tier D |
> | homebrew-tap | `url` *and* `homepage` in both files. Only `url` self-heals at the next release; nothing in CI ever rewrites `homepage` |
> | the rice | the four `github:` inputs + lock (all four repin at the same revs, on main); `bootstrap.sh`'s three URLs, keeping the `inputs.nebelhaus` NAME; `refresh_family_apps`' brew-tap directory |
> | workshop | the site's install commands, family tables and repo links; `README.md`, `AGENTS.md`'s four-spellings box, `docs/`, `.agents/**`; `check-rice-bindings.mjs`; `options-drift.yml`'s org note; this file's own §3.3 |
>
> **Left deliberately, and each for a reason above:** the Go module path; the
> `--override-input nebelhaus/…` input names in `bench` and `test/bench.bats`;
> `bench:89`'s comment, which exists to describe the dead org; the
> `name: bump nebelhaus/homebrew-tap` job labels (a display string, and the
> `bench` fixtures that assert on it); `~/.config/nebelhaus/`;
> `/Library/Application Support/nebelhaus/`; `nebelhaus.com` (§5); and the
> synthetic slugs in holt's five `fake-holt.sh`
> fixtures and `test/statusline.bats`.
>
> ⚠️ **One Tier D row below has expired and is NOT a hold any more.** "`nebelhaus/modules/…`
> source paths in docs" was written when the rice's checkout was `./nebelhaus`.
> It is `./haus` now (`./hausfold` between 2026-08-09 and §10), so
> `haus/modules/…` is what those paths mean, and
> `bench` and this repo's `.agents/` already write it that way. The stragglers
> are cross-repo *comments* in pounce and perch — not owner references, so out
> of this sweep, but a real cleanup and not something to defend.
>
> ✅ **npm's trusted publisher was flipped 2026-08-09.** The private consumer's
> `flake.nix:7` now points at `github:hausfold/hausfold`; only the flake input
> *name* remains `nebelhaus`, deliberately (§6 / the input-name box above).
> ⚠️ That URL is one rename behind since §10 — it resolves through the redirect,
> and retargeting it at `github:hausfold/haus` is §10.4's one 👤 line.

Redirects work, but `flake.lock`'s `original` field keeps the old owner and
that's a landmine.

> 🚨 **"Every edge" is not "every occurrence of the word", and this heading has
> been read the wrong way before.** ~90 of the census's hits below are
> *correct as they stand* and a sweep that touches them breaks working things —
> the rice keeps its name (§6). **Read the Tier D table before running any
> find-replace**, and if you are an agent working this section unattended, treat
> §6 as a hard list, not a preamble.

There are **three** such files, not four, and the command below reaches only two
of them:

| File | `github:nebelhaus/*` inputs |
|---|---|
| `nebelhaus/flake.nix` | nebelung, pounce, perch, holt |
| `pounce/flake.nix` | nebelung |
| 👤 `~/.config/nix/flake.nix` (`$HAUS_CONSUMER`) | nebelhaus |

`perch`, `holt`, `nebelung`, the archived Messages client and `incubator/trill`
have none.

```sh
rg 'github:nebelhaus/' --type nix          # from ~/code/workshop — misses the consumer
rg 'github:nebelhaus/' ~/.config/nix       # 👤 the one flake this machine builds from
# then, per repo, upstream → downstream:
nix flake update <input> --refresh
```

⚠️ **Two known traps here, both already learned:**
- `bench ship` can pin a lock **one commit behind** your merged HEAD (GitHub /
  flake-cache lag). Verify the rev after shipping, `--refresh` to correct.
- Bare `bench ship` from a *workshop worktree* silently fails (exit 128) because
  `./bench` shadows the real one. Call `~/code/workshop/bench` explicitly.

Also: `holt/sdk/swift/sync-mirror.sh` and any `Package.swift` URL, the
homebrew-tap's formula/cask `homepage`/`url` (👤 CI-owned — hand-edit only to
bootstrap), and `.github/workflows/*` that reference `nebelhaus/`.

#### The census, taken 2026-08-09 — and the grep count is a lie

**649 owner-keyed hits** across the eleven checkouts. The regex is
`nebelhaus/(nebelung|pounce|perch|holt|holt-swift|nebelhaus|workshop|homebrew-tap|\.github|messages|trill|flick)\b`,
excluding `.git`/`DerivedData`/`node_modules`/`flake.lock`.

⚠️ **Re-run it with `--hidden` or the number is 609 and the workflows are
missing.** `rg` skips dotfile directories by default, so a plain run drops all
**40** hits under `.github/` — which is exactly the Tier B row below. A census
that doesn't count the thing it tiers is worse than no census.

Measured, by file kind (all-in, 649):

| Kind | Hits |
|---|---|
| generated — `web/src/content/docs/reference/options.md` alone | **175** |
| prose — `.md` / `.mdx` / `.txt` / `.astro` / `.html`, that file excluded | **236** |
| code, config, workflows, scripts | **238** |

And by what to *do* about it, which is the only split that matters:

| Tier | What | When |
|---|---|---|
| **A — breaks, no redirect saves it** | the three `flake.nix` `original` owners (table above); `bench` (below — more sites than you'd guess); holt's `MIRROR_TOKEN` PAT + three OIDC trusted publishers (§3.1) | **in the sitting** |
| **B — rides a redirect, but the redirect is now permanent** | perch's and pounce's `UpdateCheck` endpoints (below); the tap's `url`/`homepage` (CI rewrites them at the next release, so they self-heal); every release-asset URL; the 40 hits under `.github/` — 8 workflow files carry an owner-keyed reference, of which **5** are an `actions/checkout` `repository: nebelhaus/…` (workshop ×2, pounce, perch, messages) | verify after, don't rush |
| **C — prose, cosmetic** | READMEs, `AGENTS.md`s, `docs/`, the site's hand-written pages | any time |
| **D — do NOT sweep** | ≥126 measured: `messages/` alone is **66** (§3.4 — it stays in the `nebelhaus` org) and holt's Go imports are **60**, plus every `nebelhaus/modules/…` source path. See the Tier D table below | never |

The tiers deliberately don't sum to 649 — a hit can be prose *and* Tier D, and
the generated 175 sit outside all four. **Don't reconcile the arithmetic; use
the tiers to decide, and the kinds to estimate.**

**The single largest concentration is generated, and that makes it the cheapest
thing here, not the most expensive.** `web/src/content/docs/reference/options.md`
carries **175** `github.com/nebelhaus/nebelhaus/blob/main/modules/…/options.nix`
"declared in" links — one per documented option. It is a `GENERATED FILE — do not
edit by hand`, and every one of those 175 links is interpolated from **a single
line**: `web/scripts/gen-options.mjs:34`,
`const REPO = 'https://github.com/nebelhaus/nebelhaus/blob/main'`. Change that
one string, re-run the generator (or let `options-drift.yml` open its own PR),
and all 175 follow. A naive census prices this at 175 lines; it is one — and it
is the same shape as `~/.claude/skills/haus/`'s regenerated description in §2.2:
**generated files hide rename drift, in both directions.**

#### 🚨 `bench` is the Tier-A repo, and it has two problems the plan hasn't recorded

**1. ~~`GH_ORG` can no longer be a single value — `bench clone` hard-fails on a
fresh machine.~~ ✅ Dissolved by workshop#283, hours after this was written.**
The finding was: `FAMILY` held `messages`, `GH_ORG` is one value, `cmd_clone`
loops `"${FAMILY[@]}" org-profile homebrew-tap` cloning
`https://github.com/$GH_ORG/$repo.git` — and **§3.4 keeps the archived Messages
client in the `nebelhaus` org**, so the moment `GH_ORG` became `hausfold` that
loop would ask for `hausfold/messages`, which will never exist, with a bare
`git clone` and no `|| warn` (unlike the `hausfold.co` clone below, deliberately
non-fatal). Correct at the time. **#283 then removed `messages` from `FAMILY`
entirely** — `FAMILY=(nebelung pounce perch holt nebelhaus)` (`bench:78`),
`GH_ORG="nebelhaus"` (`:79`), `cmd_clone`'s loop (`:1539-1548`) — and every
remaining entry, plus `org-profile` and `homebrew-tap`, transfers to `hausfold`
together. **So one `GH_ORG` is right again; the per-repo-owner refactor this
finding prescribed is not needed.** Two PRs open at once, neither aware of the
other; the census was measured against a `bench` that no longer exists.
⚠️ What survives: the same `$GH_ORG` is interpolated into `gh pr list` /
`gh run list` / `gh run view` (`bench:793,1226,1255,1413,1421,1429`), so it
still flips **all six** call sites in one edit — fine while the family is one
org, and the thing to re-check the day any family repo *doesn't* transfer.

**2. The `$ROOT/hausfold` directory collision that §3.1 marked resolved is still
live in code, and pointing the wrong way.** ✅ **Closed twice over: §3.3's step 4
fixed the code, and §10 removed the collision itself** — the layer's checkout is
`$ROOT/haus` now, which shares no prefix with `$ROOT/hausfold.co`, so the
"one dot apart" failure this finding describes can no longer be typed. Kept as
written because the *shape* is the reusable part: two checkouts one character
apart, one of them silently building the wrong tree. §3.1 resolved it as (b): "the
checkouts become `workshop/hausfold/` (the **platform**) and `workshop/hausfold.co/`
(the site) — each named for its repo." `bench` implements the opposite —
`bench:1560-1568` plants **the site** at `$ROOT/hausfold`
(`git clone https://github.com/hausfold/hausfold.co.git "$ROOT/hausfold"`), and on
this machine today `workshop/hausfold/` is a **stale clone of the archived,
private `hausfold/website`** while `workshop/hausfold.co/` holds the real site.
This bites when `FAMILY`'s `nebelhaus` entry becomes `hausfold`: `local_src()`
(`bench:249-255`) resolves a family repo as `$ROOT/$1`, so `local_src hausfold`
returns the **website checkout**.

⚠️ **The failure mode depends on how far the rename got, and only one of the two
is loud.** `overrides()` (`bench:281-286`) does *not* read `FAMILY` — it passes a
hardcoded `local_src nebelhaus`. So:

- rename `FAMILY` **only** → `local_src nebelhaus` → `$ROOT/nebelhaus`, which no
  longer exists, and nix errors immediately. Annoying, but safe.
- rename `FAMILY` **and** `bench:282` → `local_src hausfold` → the website
  checkout, and `bench try` silently builds the rice against a folder of HTML.
  **Nothing errors.** This is the one to avoid, and it is the state a careful
  half-finished sweep lands in.

- [x] `rm -rf ~/code/workshop/hausfold` (the stale `hausfold/website` clone —
      that repo is archived, and `hausfold.co/` supersedes it). **Done
      2026-08-09**, verified clean and fully pushed first.
- [x] **Done in workshop#8017988.** Repoint `cmd_clone`'s site clone at
      `$ROOT/hausfold.co`, and update
      `bench:1005`'s `repos=(workshop "${FAMILY[@]}" org-profile homebrew-tap
      hausfold consumer)` with it — `cmd_pull`'s list already names the site
      `hausfold`, so once `FAMILY` holds `hausfold` too **the same name appears
      twice in one array**, and `bench pull` fast-forwards one checkout under
      the other's identity. The `bench:1002-1004` and `bench:1550-1559` comments
      follow.
- [x] add `/hausfold.co/` to the workshop's `.gitignore` and retire
      `/nebelhaus/` there once the FAMILY entry moves — the ignore file names
      both checkouts. **Done 2026-08-09**, in the same commit as the entry.
- [x] **Done 2026-08-09 — and it was `mv ~/code/workshop/nebelhaus
      ~/code/workshop/hausfold` plus the literals below, in one commit, because
      a `bench` that disagrees with the disk finds no rice at all.** The rice's
      live agent worktree survived the `mv`; both gitdir pointers were checked
      and `git worktree repair` was a no-op. **Only then** rename the `FAMILY`
      entry — and when you do, rename it
      *everywhere*, because `nebelhaus` is spelled out as a literal in eight
      more places `FAMILY` doesn't reach: `OVERRIDABLE` (`bench:88`), the
      lock-edge table (`:219-223`), `overrides()` (`:281-286`), the
      release-audience case (`:529,535`), the version-file case arms
      (`:1033,1044,1058`), and the release allowlist (`:1353,1359`).
      **`FAMILY` is not the single source of truth it looks like.**

**All of this is `bench` edits and they belong in the same PR as `GH_ORG`.** Do
them *before* the transfer sitting, not after: none of it depends on the repos
having moved, and doing it first means the sitting's only follow-up is locks.

💡 **If a per-repo owner is ever needed again, `cmd_clone` already has the
shape.** `bench:1541` is `[ "$name" = "org-profile" ] && repo=".github"` — a
per-repo override of the *name*; the same two lines would override an *owner*.
Written for `messages`, and **moot since #283 removed it from `FAMILY`** (finding
1 above) — kept because the next repo that stays behind will want exactly this.

⚠️ One more that only shows up at build time: `overrides()` emits
`--override-input nebelhaus/nebelung`, `nebelhaus/pounce`, … Those are **flake
input paths**, not repo owners — the leading `nebelhaus` is the input's *name*
in `~/.config/nix/flake.nix`. Whether that input gets renamed to `hausfold` is a
👤 call on a 👤 file (§3.3's third flake), and `bench:281-286` has to move in the
same breath as it or every override silently addresses a non-existent input.

#### The two shipped-binary edges — why the dead org can never be deleted

§3.2 already says "keep the `nebelhaus` org alive and empty. It costs nothing and
holds every redirect." That is stronger than housekeeping, because **two shipped
binaries hardcode the old owner and can never be swept:**

- `perch/Perch/Platform/UpdateCheck.swift:191,194` —
  `api.github.com/repos/nebelhaus/perch/releases/latest` and the matching
  `releases/latest` web URL
- `pounce/pkgs/pounce/UpdateCheck.swift:136` — the same endpoint for pounce

Every copy already installed carries those URLs; editing the source only fixes
the *next* release. GitHub's API redirects a transferred repo and `URLSession`
follows it, so the update nudge keeps working — **for exactly as long as the
`nebelhaus` org exists.** Deleting it doesn't break links, it breaks update
checks on installed apps, silently, with no error a user would report. Write that
next to the org, not just here.

#### Tier D — the rice keeps its name, so these are correct as they stand

⚠️ **The highest-risk thing in §3.3 is a later session "finishing the job".**
`nebelhaus` is still the rice (§6), so a large share of the census is *right*:

| Do not sweep | Why |
|---|---|
| `/Library/Application Support/nebelhaus/perch.installed-from` | a **two-repo contract**: written by the rice (`nebelhaus/modules/perch/default.nix`), read by perch (`Perch/Platform/UpdateCheck.swift:118`, documented at `perch/docs/architecture-decisions/0003-*.md`). Rename it in one repo and perch stops recognising a rice install — it would start nudging rice users to download from GitHub. It is the *rice's* directory and the rice keeps its name. |
| `~/.local/state/nebelhaus/` | §2.2, deliberately held |
| ⚠️ *(those two are **not** among the 649)* | neither matches the census regex — there's no repo name after the slash. A sweeper who reads "Tier D is ≥126 of the hits" and assumes the state dirs are inside that number is wrong: **they need their own grep**, which is §2.2's whole point |
| `nebelhaus/modules/…` source paths in docs | the rice's own tree |
| everything in `messages/` (24 hits) | §3.4 — it stays in the `nebelhaus` org |
| holt's Go imports — **60 lines across 23 `.go` files** for `github.com/nebelhaus/holt`, of which 59/22 are `…/internal/…` and the 60th is in `sdk/go` | see below |

**Why §3.1's identifier table now carries an "it is not one line" warning.**
That table cites `sdk/go/go.mod:1`, but `holt/go.mod:1` is
`module github.com/nebelhaus/holt` — the *root* module — and every internal
import in the repo spells it out: **60 import lines across 23 `.go` files**, plus
the nested SDK module. The recommendation there ("take option 1 — keep the path,
revisit at the next major bump") is unchanged and now better supported: the root
module is a **binary**, so its path is nobody's API, and a path change is a
60-line sweep coupled to a five-SDK version contract. Keep it.

**Gate:** `bench status` shows every lock edge fresh and no OFF-MAIN pin;
`bench try` builds; `bench clone` into an empty directory completes (this is the
one that catches the `GH_ORG` split — nothing else exercises it); `local_src` for
every `FAMILY` entry resolves to that repo's own checkout; a clean `git clone` of
each new URL works without redirect.

**✅ Measured green 2026-08-09.** `bench ship` rippled the final pounce/perch
commits through `hausfold` and the private consumer; `bench status` then showed
all six lock edges current; `bench try` built; and a fresh workshop clone's
`bench clone` populated all eight expected checkouts at direct
`github.com/hausfold/*` URLs, with `hausfold/` holding the platform and
`hausfold.co/` holding the site.

⚠️ **And a gate this one cannot see: §3.1's four owner-keyed identifiers.** None
of the checks above touches them — they fail for the first time *inside* a
`bench release holt` run, half-published. **No `bench release holt` until all
four boxes in §3.1 are ticked.**

---

## §4 — Apple identity

**Gated on §0.5.** Highest-blast-radius phase; every step is felt on your own
Mac immediately.

### 4.1 👤 Developer portal, before touching code

✅ **The iOS half is already done and pulled forward** — §0.5 route A, perch#41.
The product migration here is macOS; the old iOS record and identifiers remain
as optional, approval-gated cleanup.

- [x] **Registered and verified 2026-08-09:** `com.hausfold.perch`,
  `com.hausfold.pounce`, `com.hausfold.trill`. These ship Developer ID +
  notarized, never through the App Store, so they're unconstrained by any record.
- ✅ **`com.nebelhaus.perch` → `com.hausfold.perch` is done** — perch#44,
  2026-08-08, pulled forward out of this phase exactly like the iOS half. See
  §0.6 for what it cost. The App ID is now registered too; the code side was
  already complete.
- Pounce actually had **three** identifiers to migrate, not the one this plan
  originally recorded: app bundle `com.local.pounce`, embedded standalone agent
  `com.local.pounce.daemon`, and rice launchd label `org.nixos.pounce`. The code
  table below is the corrected inventory.
- ✅ **`.perchlicense` decided 2026-08-09.** `.nebelhauslicense` was the one
  user-facing artifact named after the demoted brand, and it was in the same
  deadline class as the bundle IDs.
  `perch-monetization.md:43` defines it as the signed JSON blob a customer
  receives, and shipped code parses it (perch#27). It is free to rename today
  and unrecoverable after the first sale — a renamed extension orphans every
  license file already in a customer's hands. **Decide it in the same breath as
  §0.6's Mac container, and land both before Phase 2 bakes the public key.**
  The neutral `.perchlicense` won because it is product-scoped already. No
  compatibility alias: the production key is still empty and no valid customer
  license has existed under the old extension. Code + docs are in perch#51.
- [x] The replacement iOS App IDs, App Group, provisioning and signing path were
  proved by TestFlight build 70 (§0.5). The three macOS apps use Developer ID
  distribution and need no App Store provisioning-profile migration.
- [ ] 👤 **Delete the old `Perch for Mac` App Store record first, then the two
  `XC com nebelhaus perch ios*` Identifiers.** The 2026-08-09 portal audit
  corrected the earlier claim that they were unclaimed: `com.nebelhaus.perch.ios`
  is still bound to Apple ID `6799010687`, so the identifiers cannot be treated
  as independent cleanup. **Do not delete any of them until `Perch Companion`
  has been approved** (or a later explicit human milestone replaces that guard).
  Deletion is permanent; the replacement record is only Waiting for Review.
- **Team ID `88M28542LQ` does not change.** Certificates don't change.

### 4.2 🤖 The code

| Old | New |
|---|---|
| ✅ `com.nebelhaus.perch` (+ `.ios`, `.ios.share`, `.mobile-*`, `.dev`, `.tests`, `.transfer`, `.promises`, `.export`) | `com.hausfold.perch…` — done, perch#41 + perch#44 |
| ✅ `group.com.nebelhaus.perch` | `group.com.hausfold.perch` — done, perch#41 |
| ✅ `com.nebelhaus.flick` | `com.hausfold.trill` (+ `.debug`, `.tests`) — done in the incubator, 2026-08-08, in the same change that renamed the app. Never shipped under either old id, so there is no install base and nothing to migrate. |
| ✅ **`com.local.pounce`** app bundle | `com.hausfold.pounce` — pounce#72, merged 2026-08-09 |
| ✅ **`com.local.pounce.daemon`** standalone embedded login agent | `com.hausfold.pounce.daemon` — pounce#72, merged 2026-08-09 |
| ✅ **`org.nixos.pounce`** rice launchd agent | `com.hausfold.pounce` — hausfold#275, merged 2026-08-09 |

`org.nixos.pounce` is a nix-darwin launchd convention leaking into a product,
while `com.local.pounce` escaped the original census entirely. The migration is
split by ownership: pounce owns the app and standalone agent; the rice owns its
launchd agent and re-signing identity. Because launchd labels move:

- The old agent must be unloaded before the new one loads. The rice activation
  explicitly boots out `org.nixos.pounce`; still verify with
  `launchctl list | grep -i pounce` that only one remains.
- Direct installs keep the legacy embedded plist as a permanent upgrade bridge,
  because their updater can skip any number of releases. A serialized detached
  helper unregisters the old SMAppService job, waits for its socket to vanish,
  then registers the canonical label. The plist remains; the loaded old job does
  not.
- The rice temporarily associates both app bundle IDs so its supported unsigned
  and signing-failure paths still resolve the currently pinned old Pounce app.
  The exact closeout sequence is: merge pounce#72 first; update hausfold#275 to
  pin that main commit and remove `com.local.pounce` from the association; rerun
  the combined build; only then merge hausfold#275. A later mechanical
  `bench ship` lock ripple does **not** remove source compatibility by itself.
- **The `AssociatedBundleIdentifiers` work is keyed to that label.** Re-verify
  the maintainer's legal name doesn't reappear in macOS permission prompts —
  that was a five-PR chain to fix and this step can undo it.
- The daemon-restart race is real: force
  `launchctl kickstart -k "gui/$(id -u)/com.hausfold.pounce"` and verify by
  binary timestamp.

✅ **Combined build green 2026-08-09:** `bench try-batch pounce perch hausfold`
integrated pounce#72, perch#51 and hausfold#275 onto throwaway trees and built
the full `mbp` system. Nothing was merged or activated.

✅ **Then all three merged (13:39–13:40) and pounce + perch released** —
`v2026.08.09-3` and `v2026.08.09-1`, both cut after the merges, and in the
required order (#72 before #275). The label migration is confirmed *on this
machine*, not just in the diff: `launchctl list | grep -i pounce` returns exactly
one job, `com.hausfold.pounce`, and `~/Library/LaunchAgents/` holds exactly one
*pounce* plist, `com.hausfold.pounce.plist`. Old label unloaded, new label
loaded, no double-load. **That is the boot-out step verified, and it is the one
that could have left two daemons fighting over ⌘Space.**

⚠️ **The closeout sequence's second half is still open.** It reads "update
hausfold#275 to pin that main commit **and remove `com.local.pounce` from the
association**". The pin happened — the rice locks pounce at `e3c2305`, the
release commit, on main. The removal did not:

- [x] 🤖 **Drop `com.local.pounce` from `AssociatedBundleIdentifiers`** —
  `hausfold/modules/pounce/default.nix`, live in the installed
  `~/Library/LaunchAgents/com.hausfold.pounce.plist`. The comment beside it said
  "Remove `com.local.pounce` with that lock ripple", and **that ripple had
  already happened**, so the entry was residue. This is the association that
  decides which app macOS attributes the agent to — leaving a stale id in it is
  exactly the class of thing that put the maintainer's legal name in a Login
  Items row once before. **Done: hausfold#282.** The evidence chain is in that
  PR: the pin is `e3c2305`, whose `pkgs/pounce/Info.plist` declares
  `com.hausfold.pounce` and whose `build.sh` rewrites only the version keys, so
  the unsigned path and the signing-failure fallback both resolve to the id
  that stays. `bench try` green; the `example` host (the unsigned one) evals to
  a one-element array.
  - [ ] 👤 **After activating it, re-check the attribution** — System Settings ▸
    Login Items & Extensions still reads "Pounce", not a person's name, and on
    Tahoe the "Allow in the Background" toggle didn't flip off. ⚠️ Activation
    does **not** bounce the daemon here (`kickstartPounce` fires on a
    `.signed-from` lag and `signedFrom` didn't move), so "the daemon didn't
    restart" is not evidence the change failed to apply.

⚠️ And what the launchd check does **not** cover is §4.4: a loaded job proves the
label moved, not that the TCC grants came back. Bundle-ID-keyed grants are
re-prompted per app, and the palette's classic-API denials **abort silently** —
so a pounce that launches and a palette that opens can both be true while a
plugin command does nothing. §4.4 stays 👤 and stays open.

⚠️ **Two `nebelhaus`-spelled labels are still loaded, and neither is a §4
finding.** `launchctl list | grep -i nebelhaus` shows `org.nebelhaus.awake` (a
rice-owned job) and `application.com.nebelhaus.flick.…` (the still-running old
build of what is now trill — the id changed in the source, this session's process
predates it; it dies with the next restart). The rice label is the one that needs
a ruling, because §4's census never mentions it and the next session to run that
`grep` will find a demoted brand word with no verdict beside it:

- [ ] 👤 **Rule on `org.nebelhaus.awake`.** It is a *rice* label, and §6 says the
  rice keeps its name — so "leave it" is defensible and probably right. But every
  one of its siblings is `org.nixos.*` (`aerospace`, `hush-watcher`,
  `sill-bottom`, `sketchybar`, `sleepwatcher`), so it is the odd one out either
  way, and `org.nixos.pounce` was just migrated *away* from that convention.
  Whichever way it goes, write it down here — an unruled label gets "fixed" by a
  later session, and renaming a launchd label means an unload/reload dance.

### 4.3 🤖+👤 The App Group is a data container, not just an identifier

**Applies under §0.5 option A only.** Under B the group is untouched and this
section is dead. `group.com.nebelhaus.perch` is confirmed registered.

✅ **Decided and landed before external testing: discard.** perch#41 moved to
`group.com.hausfold.perch`; TestFlight build 70 proved the registered group and
signing path. No external tester data existed, so there is no migration shim.

**This one silently destroys perch's state and nothing else in §4 covers it.**
`group.com.nebelhaus.perch` is passed to
`containerURL(forSecurityApplicationGroupIdentifier:)` and
`UserDefaults(suiteName:)` — see `perch/PerchMobileCore/MobileConfig.swift:10-14,38`.
Renaming it gives you a **new, empty container and empty defaults**: every shelf
item and every setting goes invisible, and the old container is orphaned on disk
with no UI pointing at it.

The decision considered:

- **(a) Migrate** — on first launch under the new group, copy the old
  container's contents and read the old `UserDefaults` suite, keeping the old ID
  readable for one release. Costs a one-shot migration path you delete later.
- **(b) Discard** — declare that shelf state is lost, and **land it before any
  external tester has data**. Free today (the install base is you), impossible
  once §0.5's audit or Phase 1 testers exist.

Whichever you take, write it in perch's changelog. A user who loses a shelf
without warning does not file a bug, they uninstall.

### 4.4 👤 Re-grant everything

**TCC grants are keyed to bundle ID + path.** Renaming invalidates all of them:

- Accessibility, Screen Recording, Full Disk Access for pounce and perch.
- ⚠️ The palette's plugins inherit the spawner's TCC identity — the daemon must
  own ⌘Space, and classic-API denials **abort silently**. Test the command
  palette specifically, not just app launch.

### 4.5 👤 Check the license layer

Does perch's offline-Ed25519 license bind to the bundle ID? If yes, **this must
land before the first sale**, and any test licenses you've issued are void.
If no, note it here so nobody re-checks.

✅ **No.** The signed canonical payload contains `product`, `email`, `purchased`
and `seats`; it contains no bundle identifier. The stored license blob likewise
has no bundle-ID field. The `.perchlicense` spelling therefore changes file
recognition only, and it lands while the production public key is still empty.

**Gate:** pounce launches and its palette runs a plugin command; perch's shelf
accepts a drop; `codesign -dv` shows the new IDs; nothing prompts with a legal
name.

---

## §5 — Domains and sites

### 5.1 ✅ Decided 2026-08-08 — one site repo, `hausfold/hausfold.co`

> ⚠️ **Renamed 2026-08-08, after this section was written.** The site repo is
> **`hausfold/hausfold.co`** (public), not `hausfold/website` (private, now
> archived). This wasn't a rename — it's a new repo, and the blocker subsection
> below explains why that was the only way to satisfy §5.1's public requirement.
> Read `hausfold/website` in this section as `hausfold/hausfold.co` throughout.

Two site codebases exist today and they merge into the second:

- `workshop/web/` — the Astro Starlight docs + `index/pounce/perch` landing
  pages + **the Worker**, serving `nebelhaus.com` (worker name `nebelhaus`,
  apex route).
- `hausfold/hausfold.co` — a small static site on `hausfold.co` + `www`,
  assets-only Worker: the landing page, `/desktops`, `/perch/privacy`, `404`.

**Everything moves into `hausfold/hausfold.co`: `/`, `/haus`, `/docs`,
`/desktops`, `/holt`, `/pounce`, `/perch`.** *(`/haus` — the layer's page — was
added to this list 2026-08-10 with decision 8, ~~ahead of the build~~ **and it
shipped the same morning**, from a parallel session: `hausfold/hausfold.co` PR
#8, live at `hausfold.co/haus`. Same pattern as `/desktops` — the page beat the
plan by hours, so read this list as "already true for `/haus`", not "to do".)* One repo, one domain, one deploy. The landing pages get
**redesigned**, not ported — nebelhaus stops being a destination and becomes one
rice inside `/desktops`, so its landing page has no domain to be the front door of.

This decision does two useful things beyond tidiness:

1. **It dissolves §3.1's on-disk collision.** Checkouts become
   `workshop/hausfold/` (the platform) and `workshop/hausfold.co/` (the site) —
   which is just what the repos are called. Take §3.1 option (b).
   ⚠️ *Written before the site repo was renamed; this said `workshop/website/`
   until 2026-08-09. And "dissolves" is optimistic — `bench` still implements
   the opposite and the collision is live today. §3.3 has the fix.*
2. **It removes the duplicate perch surface** — perch marketing currently exists
   in both repos.

#### ✅ Blocker found and cleared 2026-08-08: the site repo was **private**

`hausfold/website` was private for a reason its own README spelled out:
`PRESENCE.md` listed every namespace held **and every gap**, which is a shopping
list for a reader. A docs site can't live in a private repo — Starlight's edit
links, contributions and "improve this page" all assume public — so §5.1 needed
it flipped.

**The plan was to scrub and flip. The plan was wrong, and the reason is the part
worth keeping.** It was:

1. Scrub a cached Cloudflare account id out of the history via `git
   filter-repo`, **before** flipping.
2. Move `PRESENCE.md` to a new private `hausfold/ops`.

Step 1 does not do what it claims. `hausfold/website` had pull requests, and
**GitHub keeps `refs/pull/N/head` forever — a history rewrite does not GC them.**
Measured on 2026-08-08 before deciding: every PR ref then in existence still
reached both artifacts after the rewrite, so they stay fetchable — on a repo that
has just gone public. **Rewriting history on a repo that has ever had a pull
request is hygiene, not removal.** The original plan also named only the blob,
not the file: a `git mv` of `PRESENCE.md` to another repo leaves every past
revision of it behind.

*(The exact paths, commits and refs stay in `hausfold/website`'s own README,
which is private. **This repo is public** — writing the fetch recipe down here
would hand over what the migration was for. Same reason this section no longer
enumerates the gaps it used to list verbatim.)*

**So the site moved to a new repo instead**, which has no PR refs and nothing to
purge. Cost: 33 commits of a placeholder page — which this very section replaces
with an Astro build anyway.

Where things landed:

- **`hausfold/hausfold.co`** — public, created 2026-08-08. `public/`, both
  wrangler configs, both workflows, `README.md`, `AGENTS.md`, as one commit.
- **`hausfold/ops`** — private, created 2026-08-08. `PRESENCE.md` with its
  eleven revisions replayed, plus the rest of the ops surface: pointers to where
  credentials live (never the credentials), the Cloudflare and Paddle account
  facts, the register's annual re-check.
  ⚠️ **This doc first said `workshop/notes/`, and that would have been the whole
  bug: `nebelhaus/workshop` is a public repo**, so the "prerequisite" would have
  published the exact gap list that makes the file sensitive — trading a private
  repo for a public one and protecting nothing.
- **`hausfold/website`** — stays private **permanently**, archived. Not deleted:
  it is the site's only pre-2026-08-08 history. (Deleting it wouldn't break the
  domain — the `custom_domain` binding lives in Cloudflare, tied to the Worker
  name — it would just lose the history.) 🚨 *Never flip it to public. No scrub
  makes it safe; see above.*

- [x] 🤖 create `hausfold/ops`, private, `PRESENCE.md` carried with its history
- [x] 🤖 create `hausfold/hausfold.co`, public, site carried as one commit
- [x] 🤖 archive `hausfold/website` (workflows removed, README/AGENTS rewritten)
- [x] 👤 re-enter the three Actions secrets on `hausfold/hausfold.co`
- [x] 👤 delete those secrets from `hausfold/website` and archive it

**✅ §5.1's blocker is fully closed as of 2026-08-08.** hausfold.co serves from
`hausfold/hausfold.co` — deploy green, `/`, `/desktops/` and `/perch/privacy/`
all 200, an unknown path 404s (so `not_found_handling = "404-page"` came over
intact). `hausfold/website` is archived, private, and holds no secrets.

#### The one condition: don't drag Nix into the site repo's CI

`web/scripts/gen-options.mjs` consumes `nix build .#options-json` from the rice,
and `options-drift.yml` fails the build when `reference/options.md` is stale.
Move that as-is and `hausfold/hausfold.co` needs Nix plus a flake pin just to
check its docs.

Use the family's own rule instead (`options-roadmap.md` §7): *"mirror only what
fits in one expression and can be pinned by a golden test; anything table-shaped
becomes an output of the repo that owns it."* Same lesson as `ports.meta.json`.

So: **`hausfold/haus` commits `options.json` as a generated, drift-checked
artifact** (its CI already has Nix), and the site reads that file. No Nix in the
site repo, and the drift check stays where the derivation is.

✅ **Built 2026-08-09, ahead of the move — nebelhaus#268 + workshop#277.** The
rice ships `.#site-data`, commits it at `docs/site-data/`, and pins the two with
a `site-data-current` flake check; both web scripts read that directory and both
drift workflows dropped `nix-installer-action`. **The site repo's Nix dependency
is now zero, before the port rather than during it** — which was the point of
doing this piece early: it is the riskiest part of §5.2 and the only one that
doesn't depend on who owns the repos, so it could run in parallel with §3.

Three things the build found that this section didn't have:

1. 🚨 **It was never only `options.json`.** `check-rice-bindings.mjs` shells out
   to `nix build .#wm-bindings-json` for the keybinding tripwire, so solving the
   options half alone would have left the site repo needing Nix anyway and the
   condition would have read as met while being false. `site-data` publishes
   **three** files — options, group blurbs, bindings.
2. **The committed copy has to be `jq -S`'d and filtered, or nobody can review
   the drift PR.** Raw `options.json` is one 148 KB line; sorted and indented
   it's 3549 readable ones. Filtering to `haus.*` drops nixpkgs' own
   `_module.args`, whose description text churns on every nixpkgs bump — a
   committed artifact that moves for reasons unrelated to the rice trains
   everyone to merge its diffs unread.
3. **The friction moves upstream, and that's the improvement.** A rice PR that
   edits an option description now goes red until it regenerates. That cost
   already existed; it just used to surface a week later as a red drift run in
   *another* repo, where the person who could fix it wasn't. It's now fixable in
   the PR that caused it.
   ⚠️ **The residue: the site now checks a snapshot, not the source.** The cron
   used to re-derive from the rice's live module system and so could not be
   fooled; it now reads the rice's committed copy. If a rice commit ever reaches
   `main` with `docs/site-data/` stale — an admin merge, a skipped check — the
   site's drift run goes **green** on a stale page and nothing anywhere says so.
   The rice's CI runs the full `nix flake check` (not `--no-build`) and
   `site-data-current` is in the all-systems set, so that path is closed today.
   It reopens the day anyone weakens either.

The two drift workflows keep their jobs unchanged otherwise — the Monday cron
still opens the regeneration PR, it just no longer installs Nix to do it.

### 5.2 🤖 The move — and the salvage list

#### 🟡 Status 2026-08-12 — the shell is up, and twenty-one of twenty-nine pages

**Landed, batch one** ([hausfold.co#12](https://github.com/hausfold/hausfold.co/pull/12);
#15 followed with the colour pass):
the Fumadocs build, the hausfold-styled theme, the CI, and **five** of the
twenty-nine pages. `hausfold.co` gained a build step and kept its shape — no
`main`, still assets-only, `public/` copied into `out/` verbatim so every
hand-written page is served from exactly the file you edit.

**Landed, batch two** ([hausfold.co#17](https://github.com/hausfold/hausfold.co/pull/17)):
the daily-driver spine — `haus/guides/window-management`, `adding-apps`,
`the-shell`, `theming`, and `nebelhaus/keybindings`. **Ten pages of twenty-nine**,
1,675 source lines rewritten to 979 — **58%**, or 63% if you exclude the
`reference/palette` that folded into `theming`. Both are above batch one's 55%,
and the reason is what the batch contained: a cheatsheet and a field table are
already at their floor. Four things it settled:

- **Consolidation is where the real cut is, not compression.**
  `reference/palette` folded into `theming` (its live swatch component had no
  Fumadocs equivalent, and nebelung's own preview is one click away), and the
  roster's field-by-field breakdown moved out of `window-management` into
  `adding-apps` so it is stated once. Two source pages that duplicated each
  other became one page each doing one job. Expect the same for
  `pounce` + `reference/pounce` + `pounce-commands`, and for `ai-agent` +
  `claude-agents`.
- **The cheatsheet is nebelhaus's, not haus's.** `reference/keybindings` went in
  the desktop tree — it is muscle memory, which AGENTS.md's tree rule names
  explicitly — and it is what gives that tree a third page. The bindings are
  still `haus.keys.*` options underneath, and the page says so.
- 🚨 **Fact-checking each page against the rice is not optional, and it pays.**
  Two live bugs in the old pages: `key = "e"` in two roster examples, which
  `rosterBuiltinCollisions` asserts on (`e` is launch mode's emoji key), so a
  reader who copied it got a failed rebuild; and a palette `Tab` binding that
  does not exist in pounce at all. Both fixed in `web/` too, in the same change as this note.
  Budget a clean-context verification pass per batch.
- **A page owes an icon, and the vocabulary grows with the tree.** Five added
  (`tiling`, `shell`, `palette`, `apps`, `keys`) — `adding-apps` can't reuse
  `install`, because a page's icon is a claim about what the page *is* and
  adding Slack is not installing haus. `first-run` and `the-bar` also gained the
  doorway cards AGENTS.md requires and batch one had left off them.

📌 **One follow-up this batch found and deliberately did not take, because it
belongs in the rice**: `haus.roster.<name>.key`'s option *description* says only
"must be unique across the roster", so the generated `reference/options.md`
never mentions the reserved launch-mode letters either. Both prose trees now
name them; the generated page can't be hand-edited, so the fix is one sentence
in `haus/modules/options.nix` (where `leaderExtras.*.key` already lists them)
and a regenerate. It is the familiar shape: a generated page looks documented
precisely because it regenerates, and nobody re-reads what it actually says.

**Landed, batch three** ([hausfold.co#18](https://github.com/hausfold/hausfold.co/pull/18)):
the launcher — `guides/pounce` + `reference/pounce` + `guides/pounce-commands`
consolidated into **two** pages (a guide and a reference, because a config-key
table is reference-shaped and compresses least), plus `guides/touch-id` and
`guides/hush`. **Fifteen of twenty-nine.** The clean-context pass caught three
drifted claims — a wrong default, a self-contradicting network-request claim,
two command-name typos — which is the third batch running to say the same thing:
budget the verification pass, it always finds something.

**Landed, batch four** ([hausfold.co#19](https://github.com/hausfold/hausfold.co/pull/19)):
the other flagged consolidation — `guides/ai-agent` + `guides/claude-agents` +
`writing/park-not-stash` → `haus/guides/coding-agents`, 761 source lines to 487
(**64%**). 👤 then split it in two ([hausfold.co#20](https://github.com/hausfold/hausfold.co/pull/20)):
`coding-agents` keeps holt (293 lines), `agent-rebuilds` takes the skill and the
rebuild loop (202) — **the one case where the work-list's "→ one page" was wrong,
and the tell was in the draft**: the page had to open by telling the reader it
was two halves. Length was the symptom; different prerequisites and no shared
vocabulary were the cause. **Eighteen of twenty-nine sources**, nineteen pages.
Three more things it turned up:

- **The consolidation was the easy half; the drift was the story.** Two
  clean-context passes (one against the rice, one against holt) returned
  corrections on **eleven** of twenty-three checked claims, including two the
  old pages got flatly wrong: the tab-bar signal is a leading state *dot*
  (`○`/`◐`/`●`) with a count chip only above one agent, not "a filled badge
  carrying a count"; and `haus.agents.clients` does **not** default to
  `[ "claude" "opencode" ]` — it defaults to that *only* under
  `haus.developer.agents.enable`, and to `[ ]` otherwise. A reader following
  the old page would have been told their machine was wired when it wasn't.
- **holt's own vocabulary moved and the docs hadn't.** The noun is a **lane**
  now — one agent's branch, checkout and pane — and it is what `holt`'s output
  says. The ported page introduces it once and then uses it; `web/`'s copy
  still says "agent worktree" throughout.
- **Two subcommands existed with no page anywhere**: `holt reaped` (the reap
  ledger, and the `git branch` line that undoes a sweep) and `holt drop` (retire
  a lane that will never land). Both are in the new page's command table.

Three of this section's own predictions were tested by doing it:

- ✅ **Static export + `worker.js` unchanged** holds. `[assets] directory`
  moved `./public` → `./out`; `custom_domain`, `not_found_handling` and
  `html_handling` are untouched, and `trailingSlash: true` is pinned so the
  export keeps the directory-with-`index.html` shape those depend on.
- ✅ **`generateBuildId` pinned**, and the build-twice-and-diff check this
  section asked for is `.github/workflows/docs.yml`. Six consecutive cold
  builds measured byte-identical. ⚠️ Turbopack's CSS chunk id is
  content-derived, so a stylesheet edit renames it *and* every page that links
  it — a diff of "one css file plus every html file" is almost always source
  drift, not nondeterminism. That cost an hour; it is written into the
  workflow.
- 🚨 **`public/404.html` could not survive.** Next's export always writes its
  own `out/404.html` and overwrites a same-named file copied out of `public/`,
  so the page had to become `src/app/not-found.tsx`. It is therefore no longer
  one of the files `sync-nebelung.mjs --check` walks for a dark `theme-color`.
  Nothing on the salvage list predicted this, and it generalizes: **any
  hand-written page whose path collides with a Next route loses.**

Two things this section decided that the landing **changed**:

- **The docs are two trees behind a switcher**, `/docs/haus/*` and
  `/docs/nebelhaus/*` — Fumadocs root folders, rendered as the dropdown at the
  head of the sidebar. 👤's call, 2026-08-12. It makes decision 8 navigable
  rather than merely stated: the layer and the desktop are different reading
  paths, not two sections of one. ⚠️ **The cost is slugs**: no docs URL keeps
  its old shape, so "preserve slugs" is spent and the 301 map must be derived
  from the old build's output in full. This section already required deriving
  it (cross-framework), so the change is in degree, not in kind.
- **Porting is a rewrite, not a move.** 👤's instruction, 2026-08-12: verify,
  consolidate, simplify, consumerize — *"probably half the amount"*. Maintainer
  reasoning, one-person detail and anything a click away come out; the facts
  and the warnings stay. Four batches in, the ported pages ran 55 / 58 / 64% of
  their originals — the consolidations sit highest, because three pages merged
  into one still owe every fact. That is now a rule in `hausfold.co`'s
  AGENTS.md, so the remaining pages don't quietly get copied. ⚠️ **Batch five
  broke the band at 73%** (guide 76%, reference 70%), and the reason is worth
  keeping: its two sources were the most factually rotten yet — the whole
  `~/.secrets` step had been replaced by secretspec, and the installer had
  grown a build-and-switch consent gate — so verification *added* lines. When
  a source is that stale the ratio measures the drift, not the discipline; the
  page to compress is the one that still reads like a commit message.

**Landed, batch five** ([hausfold.co#21](https://github.com/hausfold/hausfold.co/pull/21)): the recommended pair —
`guides/staying-in-sync` + `guides/new-mac` → `haus/guides/keeping-it-current`
(the loop and the restore are one arc: same machine over time, then the same
machine on new hardware) — plus `reference/haus` → `haus/reference/haus`. 489
source lines to 358 (**73%**; see the ratio bullet above for why this one is
allowed to be high). **Twenty-one of twenty-nine sources**, twenty-one pages.
Two clean-context passes returned corrections on **fourteen** of forty-seven
checked claims, and three of them were not drift but *reversal*:

- **`~/.secrets` no longer exists.** The secrets room is
  [secretspec](https://secretspec.dev) now: a committable `secretspec.toml`
  declares names, `haus.secrets.provider` (default `keyring` = the login
  keychain) decides where values live, and the new-Mac step is
  `secretspec check` → `secretspec set`, not "AirDrop your dotfiles". The
  module header says in so many words that it "replaces the old hand-carried
  `~/.secrets` directory on the new-Mac checklist" — the docs never got the
  memo. ⚠️ **`haus/modules/hearth/default.nix:7` still points at `~/.secrets`
  too**, so the rice's own comment is stale in the same way.
- **The installer activates now, if you let it.** `bootstrap.sh:606-617` ends
  with a `gum confirm "Raise the house now?"` that builds, switches and runs
  `haus doctor` — **interactive runs only**, which turned out to be the whole
  story (see the 🚨 below). Every "it does not change your Mac / nothing
  activates until you run the printed command" sentence is now qualified rather
  than absolute, on **three** pages across both trees, including batch one's
  `install`.
- **The agent-rebuild guard is Claude-Code-only.** `under_agent()` tests
  `CLAUDECODE` and nothing else, so the "AI agent session without Full Disk
  Access" the reference described is really *one* client — a Codex or OpenCode
  pane is never refused and will half-activate, which is the exact failure the
  guard exists to prevent. (`agent-rebuilds` already said this correctly; the
  reference did not. Both trees now name `HAUS_AGENT_REBUILD=1` as the
  override.)

Smaller, all fixed in both trees: `haus diff` compares the config this machine
is **running**, not the one declared in your tree (that's `haus plan`); `haus
update` also upgrades the family's tap casks *and formulae* — pounce is a
formula, so the casks-only wording excluded the flagship — and prints a
best-effort changelog;
`haus options` reads the *active build*, not the lock's pin; `haus doctor` runs
three sections nobody documented (Pounce's Accessibility grant, nebelung's theme
ports, secretspec); the launcher command is **Rebuild System** and ships from
the rice, not from pounce, which deleted both commands in July; `roster` has
five install sources, not three; `signingIdentity` wants the full common name,
because a SHA-1 doesn't survive a cert renewal.

Three things the pre-PR pass caught that are worth carrying into batch six.
**A consolidation can import an error the sources were careful about**: both
originals listed only `cask`/`brew`/`package` as what returns on a new Mac, and
the port "improved" that into `appStoreId` as well — which is wrong, because
`haus.appStore.install` defaults to `false` and `mas` cannot buy. **Anything
gated by `haus.developer.agents.enable` must say so** — `holt` and `zscratch`
both live behind it, and the ported `coding-agents` already says so, so a
reference that calls them "ships beside `haus`" contradicts a page one click
away. And **check the doors point inwards, not just outwards**: the two new
pages had a `<Cards>` foot each and almost nothing in the tree linked *to*
them, which the fix adds from `install` and `nebelhaus/first-run`.

🔧 **Three fixes this batch found in `haus`, and made there**
([hausfold/haus#326](https://github.com/hausfold/haus/pull/326)):
`cmd_options` counted its rows with `grep -c '^  # nebelhaus\.'` while
`host-template.jq` emits `  # haus.…`, so the fresh-write branch of `haus
options` printed "**0 options, all commented out**" on success — a string the
namespace rename missed. `docs/modules.md:53` recommended the SHA-1 form of
`haus.pounce.signingIdentity` that `options.nix` spends fifteen lines arguing
against. And `modules/hearth/default.nix:7` still told you to load secrets
"from `~/.secrets` or similar", the directory its own secrets room replaced.

🚨 **And one that is neither a docs fix nor a one-liner: the documented install
command never reaches the interview.** `bootstrap.sh:65-66` clears
`INTERACTIVE` when stdin isn't a TTY — deliberately, so a piped run can't hang
— and under `curl … | bash` stdin *is* the script. So the headline one-liner on
every page takes the defaults silently: no gum, no questions, no consent gate.
The form that *is* interactive is `bash -c "$(curl …)"`, which the install page
currently presents as the **unattended** example. Both trees now qualify the
consent-gate sentence rather than assert it, but the real fork is 👤's: either
document the `bash -c` form as the headline, or have `bootstrap.sh` reopen
`/dev/tty` when one exists so the one-liner already in the wild starts asking.

**Still open, and each is its own piece of work:**

- the remaining **6 source pages**, including `reference/options.md` — the generated
  one, which needs `gen-options.mjs` + `check-rice-bindings.mjs` moved over and
  pointed at the rice's committed `docs/site-data/`. ✅ Checked while planning:
  that file carries **236 `haus.*` options across 35 rooms**, `haus.developer.*`
  among them, so "every option including the dev ones" needs no change to the
  generator — it filters on the namespace and nothing else.
- the landing pages becoming Next routes. 👤 decided **yes** on 2026-08-12,
  which settles the "still not decided" line below; not done.
- `worker.js`, the `hausfold.co/<rice>.sh` installer route, and the
  `nebelhaus.com/*` 301s. **Until those land the docs print
  `nebelhaus.com/init.sh`**, deliberately — it is the URL that resolves — and
  nebelhaus.com stays live serving the unported pages. A fact fixed in one tree
  and not the other will disagree; fix it in both or in neither.

##### The six left, with the tree each lands in

Derived after batch two and struck through as batches land, so the next session
doesn't re-derive it. `→` means consolidate into one page. Source paths are under
`web/src/content/docs/`, and `haus` names the layer tree — no row wants the
desktop tree, which is the finding, not an omission. **Seven ported sources have no row at all** and the table does not
reconcile to twenty-nine without them: batch one's four (`start/install`,
`start/first-run`, `start/what-is-nebelhaus`, `guides/the-bar`), which predate
the table, and three of batch two's (`guides/adding-apps`, `guides/the-shell`,
`nebelhaus/keybindings`), which landed as it was being written. The ✅ rows are
batch two's other three plus everything struck since, kept so a later session
can see what the consolidations actually became. So: 6 rows = 6 pending
sources, plus 16 in ✅ rows, plus the 7 rowless = 29.

| Source | Lines | Tree | Note |
|---|---|---|---|
| `guides/leaving` | 304 | haus | uninstall. |
| `guides/sharing-a-rice` | 211 | haus | how a *rice* is made — arguably the most decision-8-relevant page on the site. **Batch six parked two things here on purpose:** `haus.tour.steps` (dropped from the ported `making-it-yours` — it is a rice-author knob, and `sharing-a-rice` already links at it), and **packs** (`nebelhaus.packs.<name>`, wrapped by `lib.pack` so they lower to `mkDefault` and a host beats them *plainly* — the opposite of a preset's conflict rule, and nowhere on the site today). |
| `internals/flakes` | 100 | haus | |
| `internals/contributing` | 238 | haus | contributing to the **layer**, so it names `hausfold/haus` now. |
| `start/the-family` | 91 | — | probably dies: `/docs`'s index and hausfold.co's own front page already do this job. Decide before porting. |
| `reference/options` | 5231 | haus | generated — the `gen-options.mjs` bullet above, not a writing job. |
| `guides/theming` residue | — | — | ✅ done (batch two) |
| `guides/window-management` | — | — | ✅ done (batch two) |
| `reference/palette` | — | — | ✅ folded into `theming` (batch two) |
| `guides/pounce` + `reference/pounce` + `guides/pounce-commands` | — | — | ✅ → `guides/pounce` + `reference/pounce` (batch three) |
| `guides/touch-id` | — | — | ✅ done (batch three) |
| `guides/hush` | — | — | ✅ done (batch three) |
| `guides/ai-agent` + `guides/claude-agents` + `writing/park-not-stash` | — | — | ✅ → `guides/coding-agents` + `guides/agent-rebuilds` (batch four; drafted as one page, split on review) |
| `guides/staying-in-sync` + `guides/new-mac` | — | — | ✅ → `guides/keeping-it-current` (batch five) |
| `reference/haus` | — | — | ✅ done (batch five), as `reference/haus` |
| `guides/making-it-yours` | — | — | ✅ done (batch six). `tour.steps` deliberately held for `sharing-a-rice`; the workspace/roster half deferred to the already-ported `adding-apps` + `window-management`. |
| `reference/troubleshooting` | — | — | ✅ done (batch six), as `reference/troubleshooting` |

The desktop tree stays deliberately thin: three pages, and none of the six
adds to it — because a desktop's docs are its opinions and its muscle memory,
not the machinery underneath. If a page seems to want both trees, AGENTS.md's
rule applies: it is two pages.

#### 🚨 Decided 2026-08-09 — the docs are rebuilt on **Fumadocs**, not ported from Starlight

👤's call, and it changes what §5.2 *is*. Everything below this box was written
as a **port**: move `workshop/web`'s Astro + Starlight tree into the site repo,
keep the build, redesign only the landing pages. That is no longer the job.
**The docs get rebuilt on [Fumadocs](https://fumadocs.dev); Starlight does not
come across.** Read every "port"/"move" below as "re-author into Fumadocs,
carrying the content".

What that changes, and what it doesn't:

- **The content is still the salvage list.** MDX bodies, the copy, the
  frontmatter meaning — all of it carries over. Fumadocs eats MDX, so this is a
  re-shell, not a rewrite of the prose. Nothing in the table below stops being
  load-bearing.
- **The stack changes underneath** — Starlight is Astro; **Fumadocs is React on
  Next.js** — but ✅ **the deployment shape does not.** That fork (static export
  vs the OpenNext adapter, and with it whether `worker.js` survives or becomes
  route handlers) was the part with teeth, and it is **settled: static export,
  `worker.js` unchanged.** See the decision box below.
- ⚠️ **The Starlight-shaped things do not have Fumadocs equivalents by default,
  and each is a decision, not a lookup:** the sidebar/tree config, the
  `editLink` baseUrl, and the two generated routes (`llms.txt.ts`,
  `llms-full.txt.ts`) which are Astro endpoints and become Next route handlers.
- ✅ **§5.1's Nix-removal work is unaffected and still paid for.** `site-data`
  publishes three JSON files and both scripts read a directory; that is
  framework-agnostic. Fumadocs consuming `docs/site-data/` is the same read.
- ⚠️ **Slug preservation gets harder, not easier.** §5.2's "preserve slugs"
  bullet assumed one docs framework's routing carried to itself. Across
  frameworks the redirect list has to be *derived* from the old build's actual
  output, not assumed — enumerate the live `nebelhaus.com` URLs before the old
  site goes away, or the 301 map is guesswork.

#### ✅ Decided 2026-08-09 — **static export**, and `worker.js` survives unchanged

👤's call, taken with the Fumadocs one. Next builds with `output: 'export'`; the
**OpenNext adapter is not used**. The docs are static, and this keeps the
install one-liner — the thing printed in every README and every doc — running on
code that is already proven rather than on a freshly-ported runtime.

**The shape this lands in already exists in this repo, and that's the argument.**
`web/wrangler.toml` is *today* a Worker with `main = "worker.js"` **and** an
`[assets]` binding over a static build, on the apex route:

> *"Static assets short-circuit first; only `/init.sh` (and any non-asset path)
> reaches `worker.js`."*

So the target config is that file's shape with hausfold.co's routes. Concretely,
`hausfold.co/wrangler.toml` gains a `main` and `binding = "ASSETS"`, and its
`directory` moves from `./public` to Next's export output:

- ✅ **Keep `custom_domain = true`** on both routes. Its comment explains why —
  the zone has no DNS records and a plain `pattern` route needs a proxied record
  to already exist. Gaining a `main` does not change that.
- ✅ **Keep `not_found_handling = "404-page"`.** It survived the last move
  intact; Next's export emits a root `404.html` from `app/not-found`, so the key
  keeps working with a Fumadocs-rendered page behind it.
- ✅ **`html_handling` stays default (`auto-trailing-slash`)** — that's what maps
  `/desktops` to `desktops/index.html`. Next's export produces exactly that
  directory-with-`index.html` layout **when `trailingSlash: true`**. ⚠️ **Pin
  that setting deliberately.** Leave it off and every docs URL changes shape,
  which quietly doubles §5.2's 301 map for no reason.
- The four dynamic routes (`/init.sh` → `/<rice>.sh`, `/download/<app>`,
  `/api/release/<app>`) stay in `worker.js`, and `web/test/*.js`'s four suites
  come across with it and keep passing. That is the whole point of this choice.

#### ✅ Search: spiked and measured 2026-08-09 — it works, and the index is byte-deterministic

The gate this section used to carry ("prove search works on a throwaway export
**before** porting content, because a docs site can build, deploy and look
complete while search silently does nothing") **has been run.** Result: static
search works, and the emitted index is reproducible. Recorded here so the port
doesn't re-spike it.

**How it's wired** — and the scaffolder does all of it, which is the headline:

```sh
npx create-fumadocs-app@latest <name> \
  --template "+next+fuma-docs-mdx+static" --search orama \
  --pm npm --src --linter eslint --og-image next-og --install
```

There is a **first-class static template**. It emits `next.config.mjs` with
`output: 'export'`, `src/app/api/search/route.ts` holding
`export const { staticGET: GET } = createFromSource(source, { language: 'english' })`
plus `export const revalidate = false`, and `src/components/search.tsx` using
`staticClient()` from `fumadocs-core/search/client/orama-static`. Nothing had to
be hand-wired. ⚠️ **Pass every flag** — it still prompts interactively for any
you omit, which hangs an unattended run.

**Proof it answers queries**, not just that a file exists (the failure mode is
an index that loads and returns nothing). Loading `out/api/search` the way
`staticClient` does — `create({schema:{_:'string'}})` then `load()` — and
querying it:

| term | hits |
|---|---|
| `fumadocs` | 2 — `/docs#what-is-next`, `/docs/test#cards` |
| `writing` | 1 — `/docs` |
| `document` | 2 |
| `zzzznotathing` | **0** (so it isn't matching everything) |

Real URLs with heading anchors, and a negative control.

**Determinism — the actual question, and the answer is yes for the index.**
Built three times: twice in the same directory, once from a copy at a
**different absolute path** (a build that embeds its own cwd looks reproducible
locally and breaks the day CI checks out elsewhere). All three:

```
0446fb413a3b5f5d5005c3d057f9385cd983c1bf8870b92be45d81844a1ef841  b1/api/search
0446fb413a3b5f5d5005c3d057f9385cd983c1bf8870b92be45d81844a1ef841  b2/api/search
0446fb413a3b5f5d5005c3d057f9385cd983c1bf8870b92be45d81844a1ef841  b3/api/search
```

**Why** it's stable, so the property is understood rather than observed: the
file is a fully serialized Orama database (`type: "advanced"`) whose document
ids are **derived from page slugs** — `/docs`, `/docs-0`, `/docs-1`, … — not
generated. Grepping it for `created|updated|timestamp|date|buildId|generatedAt`
returns nothing. No clock, no randomness, no absolute paths.

🚨 **But the rest of the export is NOT deterministic by default, and that is a
separate finding.** Next mints a **random `buildId` per build** and embeds it in
`_next/static/<buildId>/`, in every RSC `.txt` payload and in `404.html` — so
two builds of identical source differ in dozens of files, *including two runs in
the same directory a minute apart*. Measured, then fixed and re-measured:

```js
// next.config.mjs
generateBuildId: () => 'hausfold',   // or the release tag / commit sha
```

With that pinned, `diff -rq` across two builds is **empty — the whole export is
byte-identical**, and the index hash is unchanged by the pin. **Set it during
the port**, not after: without it "did this deploy change anything?" is
unanswerable, and a diffable deploy is most of the value of a static site.

⚠️ **This is a property of these versions, so it needs a check, not a memory.**
Measured on `fumadocs-core` 16.14.3, `fumadocs-mdx` 15.2.3,
`fumadocs-ui`(`@fumadocs/base-ui`) 16.14.3, `next` 16.3.0. **Add a CI step that
builds twice and diffs `out/`** — it costs one extra build and it is the only
thing that would catch a future Fumadocs or Next release quietly introducing a
timestamp. Without it, this box's ✅ decays silently into a claim.

✅ **Bonus, and it's on the salvage list:** the same template already ships
`llms.txt` and `llms-full.txt` as static routes, plus per-page
`llms.mdx/docs/*/content.md` and OG images. §5.2's table lists
`web/src/pages/llms.txt.ts` and `llms-full.txt.ts` as must-survive — they don't
need re-authoring, they come with the template.

##### ✅ And it indexes the **live `haus.*` option surface**, because that page is part of the corpus

The determinism that matters day to day isn't build reproducibility — it's
*"does search find an option I added last week?"* It does, and the chain is
already built (§5.1), unchanged by the move to Fumadocs:

```
rice module system  →  nix build .#site-data  →  hausfold/docs/site-data/options.json
     (committed in the rice, pinned by its own `site-data-current` flake check)
         ↓  web/scripts/gen-options.mjs
     src/content/docs/reference/options.md   (generated, COMMITTED)
         ↓  the docs build
     a normal page  →  indexed like any other  →  searchable
```

The options reference is a **generated file that is committed**, not rendered at
build time — `gen-options.mjs` runs in the drift workflow (Monday cron + a PR
check), not in `npm run build`. So a deploy indexes whatever snapshot is
committed. That is §5.1's already-recorded residue ("the site checks a snapshot,
not the source"), and it is the *only* gap between "live options" and "what
search returns". Nothing about Fumadocs changes it: same script, same input,
output lands in the content dir, Fumadocs indexes it.

✅ **Confirmed by the measurement below rather than assumed** — `options.md` was
in the 29-page corpus that produced the 3,004-section index, so the numbers
already cover the whole option surface.

⚠️ **And it's the reason the index is big.** `reference/options.md` is
**151 KB of the corpus's 429 KB (35%)** and carries **226 of its 477 headings
(47%)**. So the search index's size is, roughly, *the option reference*. If the
457 KB brotli figure ever needs to come down, that page — not the prose docs —
is the lever, and trimming what's indexed per option beats changing search
engines.

##### 🚨 Then measured against the **real** corpus, and the index is big

A 2-page scaffold proves nothing about size. The 29 real pages from
`web/src/content/docs` (prose only — see the caveat below) were built through
the same pipeline:

| | |
|---|---|
| source prose indexed | 381 KB across 29 pages |
| indexed sections | **3,004** |
| `out/api/search` raw | **4,185,685 bytes (4.2 MB)** |
| gzip -9 | 798 KB |
| brotli -q 11 | **457 KB** |
| determinism | ✅ still byte-identical across two builds (`8af65f22…`) |

**An 11× blowup over the prose**, and ~450 KB even brotli'd. Determinism holds
at real scale, which was the question — but the size is the thing this spike
found that nobody had asked about, and it is exactly what Fumadocs' own docs
warn about ("for large docs sites, it can be expensive").

Three things make that liveable, in order of importance:

1. ✅ **It is fetched lazily, on the first query — not on page load.**
   `staticClient`'s `getDBCached` is called inside `search(query)`
   (`fumadocs-core/dist/search/client/orama-static.js`), and cached per URL
   afterwards. So the cost lands only on readers who actually open search, once
   per session. This is the fact that keeps 4.2 MB from being a page-weight
   regression.
2. 🚨 **But verify it's actually compressed, because the filename fights you.**
   Next writes the file as `out/api/search` — **no extension**. Cloudflare
   infers content type from the extension and only compresses compressible
   types, so an extensionless file can be served as
   `application/octet-stream` and shipped **uncompressed — 4.2 MB, not 457 KB**,
   with nothing failing or warning. **Check `content-encoding` and
   `content-type` on the deployed URL** (`curl -sI -H 'Accept-Encoding: br'`),
   and if it's wrong, set it in `public/_headers` — which this site already
   ships and already knows how to use.
3. If it still reads as too much, the lever is *what gets indexed* (trim page
   content in `createFromSource`, or split per section) — not switching search
   engines. Don't reach for it before measuring point 2, which is a
   one-line-of-config difference between 457 KB and 4.2 MB.

⚠️ **Caveat on the measurement, stated so nobody over-trusts it.** The Starlight
MDX does **not** compile under Fumadocs unmodified, so the corpus was stripped
to prose (JSX components, imports, `:::` asides and images removed) to get it
through the build. Real pages will index *somewhat* more (component text) —
call 4.2 MB a floor, not a ceiling. Two concrete incompatibilities found while
doing it, both worth knowing before the port:

- **Markdown images become build-time module imports.** `![](/media/ripple.webp)`
  compiles to `import __img0 from "../../public/media/ripple.webp"`, resolved
  **relative to the content file**. In Starlight that string is just a public
  URL that's never resolved. So a missing asset is a **hard build failure**
  under Fumadocs where it was a broken `<img>` under Starlight — better, but it
  will bite on day one, and the corpus has exactly one such image
  (`/media/ripple.webp?v=2`, used in two pages).
- Every Starlight component (`<Card>`, `<Tabs>`, `:::note`) needs a Fumadocs
  equivalent or removal; MDX that merely *looks* portable fails at `acorn`
  parse time, not with a helpful message.

⚠️ Other `output: 'export'` constraints, so they're not rediscovered one by one:
no server components doing runtime work, no middleware, no ISR/SSR, and
`next/image` needs `images.unoptimized`. None of these are wanted here — the
site is a docs tree and some landing pages — but each fails at build time in a
way that reads as a config error rather than as this decision.

~~Still not decided (don't settle it by accident while building): whether the
landing pages become Next pages too, or stay the hand-written HTML they are
today, served from the same assets directory beside the exported docs.~~
✅ **Decided 2026-08-12 — they become Next pages**, 👤's call, asked rather than
settled by accident. Not done: the first landing left them as hand-written HTML
beside the export, which is the shape this paragraph described as the
alternative. Read it as a staging order, not as the answer.

**The three things this decision hands the port as concrete work**, all proven
below rather than guessed: pin `generateBuildId`, verify the search index is
served compressed, and add a build-twice-and-diff check to CI.

The pages get redesigned. **These are not pages and must survive verbatim:**

| Salvage | Why it's load-bearing |
|---|---|
| `web/worker.js` (158 lines) + `web/test/*.js` (4 suites) | `/init.sh` **proxies the rice's `bootstrap.sh`** — it *is* the install one-liner in every README and doc. Plus `/download/<app>` → latest release, and `/api/release/<app>`, which is how the landing pages label the download button with a real version instead of a hardcoded one that goes stale. |
| `hausfold/public/perch/privacy/` | perch's **privacy policy** — an App Store submission requirement. |
| `web/src/pages/llms.txt.ts`, `llms-full.txt.ts` | generated routes LLM/agent consumers read. |
| `web/public/` — `logos/`, `social/*-og.png`, `media/stills/`, `_headers` | the assets and OG cards; see `assets/SHOTLIST.md` for the media policy. |
| the **copy** in the three `.astro` pages | redesign the layout, keep the sentences that took work. |

Then:

- `astro.config.mjs` → `site: 'https://hausfold.co'`, and the GitHub editLink
  baseUrl → the new repo.
- Routes: `/` (one-sheet), `/docs/*` (the Starlight tree), `/desktops` and
  `/desktops/<rice>`, `/holt`, `/pounce`, `/perch`.
  ✅ **Resolved 2026-08-08 — and the two routes already exist.** This bullet
  used to demand a separate top-level **`/nebelhaus`**, because the installer
  decision below puts `hausfold.co/nebelhaus.sh`'s only CTA on the nebelhaus
  page, and §7 was going to make the gallery a placeholder for months: net, the
  rice would ship with its one-liner advertised nowhere. The site repo
  then shipped `/desktops` **and** `/desktops/nebelhaus` as plain HTML, the
  latter carrying the install command — which is exactly the
  independent-of-the-gallery route this was asking for, one level deeper than
  proposed. No top-level `/nebelhaus` is needed; **preserve
  `/desktops/nebelhaus` through the Astro port** rather than re-deriving it.
- `worker.js`: `REPO` → `hausfold/haus`, `DOWNLOADABLE` app URLs →
  `github.com/hausfold/<app>`, and drop `trill`.
- `wrangler.toml`: this repo stops being assets-only — it gains a `main` and a
  build step. ⚠️ **Keep `custom_domain = true`** on the hausfold.co routes; its
  comment explains why (the zone has no DNS records, and a plain `pattern` route
  needs a proxied record to already exist).
- Add the `nebelhaus.com/*` route and **301** it path-for-path to hausfold.co.
- Preserve slugs; where you can't (`what-is-nebelhaus` → `what-is-hausfold`),
  add an explicit redirect.

#### ✅ Decided 2026-08-08 — the installer becomes per-rice

`nebelhaus.com/init.sh` → **`hausfold.co/nebelhaus.sh`**, and it is **not** a CTA
on hausfold.co's front page — it lives on the rice's own page, which as of
2026-08-08 is **`/desktops/nebelhaus`** (see §5.2: that page exists and already
carries the command, so nothing waits on the gallery).

⚠️ **That page prints the old one-liner today** —
`curl -fsSL https://nebelhaus.com/init.sh | bash`, hand-copied from
`nebelhaus/README.md`. It is correct now and wrong the moment this decision
lands. `hausfold/ops`'s `PRESENCE.md` Gaps records the duplication; **this is the step
that has to edit it**, and nothing checks the two agree.

That generalizes for free: `hausfold.co/<rice>.sh` is every rice's own
one-liner, which is exactly the shape a platform wants. `worker.js`'s `/init.sh`
handler becomes a `/<rice>.sh` route; today it resolves one name, and the
resolution table is the thing to keep small.

**Explicitly deferred:** whether that table scales, and what happens when rices
come from repos the worker doesn't own. Ship the one-name version, watch it,
fix later.

- Keep `nebelhaus.com/init.sh` alive as a 301 to `hausfold.co/nebelhaus.sh` —
  it's in READMEs and shell histories.
- ⚠️ `nebelung.sh` would be the wrong filename: **nebelung is the palette**, the
  rice is **nebelhaus**. Easy slip, and it's a URL.

### 5.3 👤 DNS + verification

- Cloudflare: `hausfold.co` zone gets the Astro worker; confirm the custom-domain
  records wrangler creates.
- 👤 `npx wrangler deploy` (nixpkgs' wrangler fails to build — use npx).
- ⚠️ **Cloudflare edge-caches 404s.** Cache-bust when verifying, or you'll chase
  a redirect that already works.

### 5.4 ✅ Support address — swept, and settled on `hi@hausfold.co`

~~`support@nebelhaus.com` → `support@hausfold.co` in perch's terms, the site
footer, `perch-monetization.md`, and the Paddle application notes.~~ *That was
the instruction, and its target address was wrong — the sweep found `support@`
was never created and `hi@hausfold.co` was already doing the job. See the
decision below; the destination changed, the sweep itself still happened.*

✅ **Swept, verified 2026-08-09.** `rg 'support@nebelhaus'` across the whole
workshop and every family checkout returns **five hits, four of them history**:
this file's reversal bullet at the top, `go-to-market.md:221`'s struck-through
decision, and `perch-monetization.md:155` + `perch/docs/going-paid.md:64`'s
parentheticals recording what it *was*. Those are the record of the reversal
and must stay — deleting them is how a settled decision gets re-litigated. The
fifth is the struck-through instruction line directly above, which is this
section's own task text, not history. **No live occurrence is left to change.**

#### ✅ Decided 2026-08-09 — the address is `hi@hausfold.co`

The sweep exposed that two addresses were in play and nothing reconciled them.
The seller surface that actually shipped used **`hi@hausfold.co`**
(`hausfold.co/public/terms/index.html:187,194` — the contact of record on a
*legal* page), while perch gated on **`support@hausfold.co`** existing in three
places (perch's `docs/going-paid.md` and `docs/app-store.md`, and
`perch-monetization.md`'s Phase 3 — line numbers deliberately omitted, they
move). `going-paid.md` recorded the split; nothing resolved it.

Measured while deciding: `hi@hausfold.co` is on **all nine** of the site's HTML
pages *and* in the JSON-LD organization record, while `support@hausfold.co`
appears in **zero** shipped surfaces across every family repo — only in those
three checkboxes.

**`hi@` wins, and the deciding fact is that it is the one that exists.**
`support@hausfold.co` appeared in exactly three unchecked checkboxes and on zero
pages; `hi@` is live, routes today, and is already printed on `/terms` and
`/refunds` — the two pages a buyer is pointed at when something goes wrong. So
the choice was never "which address is better", it was "keep the working one, or
create a second one and then find-and-replace the legal pages onto it before the
first receipt". The second is strictly more work for a distinction no buyer of a
one-person product notices.

What that buys, concretely: **three pre-flight boxes stop being blockers.** They
were written as *create a mailbox* tasks; they become *decide an SLA* tasks, and
an SLA doesn't gate a receipt.

- ⚠️ **The one real cost:** `support@` is what a buyer types when guessing. If
  that ever bites, the fix is an **alias** `support@ → hi@`, which is additive
  and changes nothing printed. **Do not** make `support@` canonical later —
  aliasing in is free, but moving the *printed* address after receipts exist
  means old receipts point at a mailbox you then have to keep forever.
- ⚠️ **Don't "fix" `hi@` to `support@` on the site.** It reads informal and a
  later session will want to. It's deliberate; this is the record.

- [x] 🤖 `perch/docs/going-paid.md`, `perch/docs/app-store.md`,
  `perch-monetization.md`, `go-to-market.md` — all four now say `hi@` and carry
  the reason, so none of them re-opens this.
- [ ] 👤 Decide the SLA you'll honour on `hi@` before the first receipt. That's
  the part of the old checkbox that survives.
- [ ] 👤 Paddle application notes (in `hausfold/ops`, not here) — make sure the
  merchant-of-record contact matches `hi@`, since Paddle prints it on the
  receipt and that copy is outside this repo's reach.

### §5's gate

*(The phase gate, not §5.4's — it sits here only because §5.4 is the last
subsection. §5.4 can be green while this is red, and today it is: §5.2 and §5.3
haven't run.)*

**Gate:** `curl -sI https://nebelhaus.com/guides/pounce` returns 301 to the
hausfold.co equivalent; every docs page resolves; the options reference renders.

---

## §6 — What deliberately does *not* change

Write these down or they get "fixed" by a later session:

- **`nebelung`** keeps its name. It's a cat breed, its audience is the
  Catppuccin community, and renaming costs a 53-port catalog sweep for zero gain.
- **`nebelhaus`** keeps its name — as the **rice**. It loses its domain and its
  landing page, but it still needs a *page*: it's the developer-focused showcase
  and the first entry in `/desktops`. Don't let "no landing page" turn into "no
  page" — `curl … /init.sh | bash` installs it, so something has to describe it.
- **`haus` the CLI** — unchanged, and now the namespace matches it. As of
  2026-08-10 the *layer* is called `haus` in user-facing copy too (decision 8),
  which makes verb, namespace and name one word on purpose. `hausfold` stays
  the org, the maker and the seller — do **not** sweep one into the other.
- **`holt`, `pounce`, `perch`, `trill`, `prowl`, `sill`, `den`, `hearth`,
  `collar`, `hush`** — all product/room names, all unchanged. ~~`flick`~~ is the
  one exception this list ever took: it became **`trill`** on 2026-08-08 (§3.4),
  reusing the name the archived Messages client gave up. Not part of the
  hausfold rename — an independent decision that happened to land in the same
  week.
- **Team ID, signing certs, notary keys** — unchanged.
- 🚨 **holt's Go module path stays `github.com/nebelhaus/holt`** — the root
  module (`holt/go.mod:1`) *and* the SDK's (`sdk/go/go.mod:1`). Decided in §3.1;
  written here because §3.3 is a 🤖 "rewrite **every** edge" step whose own file
  list names `sync-mirror.sh`, `Package.swift` URLs and workflows, and an agent
  sweeping that list will otherwise "fix" a module path that is **irreversible
  on Go's immutable proxy**. It is 60 imports across 23 `.go` files, it is
  nobody's API (the root module is a binary), and a change is a version-contract
  event for all five SDKs at once. Revisit only at a major bump.
- **`/Library/Application Support/nebelhaus/perch.installed-from`** — the rice
  keeps its name, so this marker is correctly spelled. It is also a **two-repo
  contract** (written by `nebelhaus/modules/perch/default.nix`, read by
  `perch/Perch/Platform/UpdateCheck.swift:118`); renaming it in one repo makes
  perch stop recognising rice installs. See §3.3's Tier D.
- **`~/.cache/claude-worktrees/`** — already historical, stays.
- **Roadmap §5 bodies, commit messages, PR titles** — historical record.

---

## §7 — Deliberately out of scope (the next arc)

**The nebelhaus rice is not a directory — it's the platform's default values.**
`presets/full.nix` says so in its own comment: *"the whole rice, and the rice's
own default. Importing this changes nothing from a bare install."* So
`git mv`-ing rice files into `rices/nebelhaus/` moves ~187 lines of presets and
nothing else.

Making nebelhaus a real rice means **neutralizing every default** in
`modules/*/options.nix` and pushing the opinions into `rices/nebelhaus.nix`.
That's a behavioral refactor gated by a readiness test — months, not days, and
`developer.enable` (§3.2 of the roadmap) was only its first installment. It does
not belong in a rename that must be provably behavior-neutral.

**And `/desktops` has a known blocker** — `options-roadmap.md` §6 Limit 3. State it
as that file **measured** it, not as it first asserted: §6(b) retracted the
"they see a raw trace rather than anything we wrote" claim, because someone
finally read the trace and it names the option, both files and `lib.mkForce`.
Not friendly, but nearly everything.

The part that is genuinely unfixed is **rice-vs-rice**, which is precisely what a
gallery manufactures:

- §6(d), measured: presets at `mkDefault` collide exactly like plain values.
  Leaf-`mkDefault` is a fix for **host-vs-rice** and "can never be one for
  rice-vs-rice" — so it is the right rule for *packs*, and not the gate here.
- `checkRice` structurally cannot catch it: the module system stops before any
  assertion of ours runs.
- A seam that *transforms* a rice erases the filename — two packs naming one app
  report ``- In `<unknown-file>'`` twice: loud and anonymous.

So the gallery cannot open properly until §6(e)'s **priority by list position**
(`compose [ a b ]`, stamping each rice one `mkOverride` weaker than the next)
ships. That's the live candidate and it's measured in both directions.

**Amended 2026-08-08 — the gate is on the *second* entry, not on the page.**
This section said `/desktops` ships as a placeholder page. What actually shipped
is a working one: `/desktops` lists nebelhaus and `/desktops/nebelhaus` carries
a real install command. That doesn't trip Limit 3, and re-reading the bullets
above says why in one line — **every one of them is about rice-vs-rice, and
rice-vs-rice needs two rices.** Today there is one, offering one command that
installs nebelhaus alone, exactly as nebelhaus.com already does. No composition
happens, so no seam collides.

The gate therefore binds where the danger actually is: **adding a second rice to
the gallery is blocked on §6(e)**, and `hausfold/AGENTS.md`'s Shipping section
carries the same rule at the point someone would break it. Restating it as "the
page is a placeholder" was over-broad, and the cost of an over-broad gate is
that the first person who finds it harmless ignores the whole thing.

---

## §8 — Order of operations, at a glance

```
§0  decisions rewritten · name cleared · queue drained · App Store audited
      │
§1  haus.* namespace  ──── gate: options.json is the ONLY leaf that moved
      │
§2  docs, tooling, agent surface  ──── gate: bench try + zero options-drift
      │
§3  GitHub org migration + lock ripple  ──── gate: bench status clean
      │
      ├── §4  Apple bundle IDs  ──── gate: TCC re-granted, palette works
      │
      └── §5  domains + 301s  ──── gate: curl shows the redirect
                │
§7  LATER: neutralize defaults → rices/nebelhaus.nix → a 2nd rice in /desktops
```

(§6 is the do-not-touch list — no steps, nothing to gate.)

§4 and §5 are independent of each other and can run in either order once §3 is
green. Everything else is strictly sequential.

**You are here (2026-08-10):** §0 green bar §0.3's branch clause — §0.2's
register search ran 2026-08-10 and leaves only the clearance *opinion*, which is
trigger-gated, not a step; §1–§3 green; **§4 fully merged and released, with no 🤖
work left in it** (hausfold#282 closed the last one) — its 👤 TCC feel-test and
its post-activation attribution re-check are what remain. **§5 is the live
phase**, and its §5.1 groundwork (site repo public, `site-data` published so the
site needs no Nix) is already done — what's left is §5.2's rebuild itself, then
§5.3's deploy. **§5.2 is the only step in this document an agent takes
unattended; §5.3 is 👤** — DNS records and `npx wrangler deploy` are a
production change on a live zone, and the section is tagged 👤 for that reason.

## §9 — Loose ends found while writing this

- ✅ **`bench`'s `FAMILY` entry for the archived client — closed 2026-08-09.**
  It listed **`trill`**, deliberately, so
  `bench status` reported the checkout; recorded here only because it reads like
  drift and gets "fixed" otherwise. §3.4 then changed what the entry *meant* —
  `FAMILY` entries are directory names, and that directory now belongs to the
  notification compositor — so **workshop#269** renamed repo, entry and on-disk
  dir together to `messages`. **workshop#283** then deleted the entry outright,
  which is the answer to the question this bullet ended on ("decide whether the
  dead client is worth an entry at all"): it isn't — archived and read-only, no
  lock edge below it, no release path above it. `FAMILY` is `(nebelung pounce
  perch holt hausfold)` at `bench:78` — the rice's entry followed its checkout at
  §3.3 step 4 — and it must **never** contain `trill` —
  that name is the compositor's, which is deliberately not a family repo.
  ⚠️ **The rice consuming trill's overlay does not change this.** `flake.nix`
  says "the rice adds this overlay", and `FAMILY` is about the *lock-ripple
  chain*, not about who imports whom: trill is a leaf with nothing pinned below
  it, so `bench ship` has no edge to walk and `bench status` has no staleness to
  report. Adding it to `FAMILY` to "make bench see it" is the mistake this
  bullet exists to prevent — the rice-wiring PR should say so in its body.
  ✅ **The legitimate way to make bench see it — closed 2026-08-09.** `trill`
  (and `hausfold.co`) now sit in **`DOCS_REPOS`**, `bench clone` and `bench
  pull`, and in none of `FAMILY`/`try`/`try-batch`/`ship`/`status`. Docs
  coverage and lock coverage are different questions, and `docs-since` walks
  `DOCS_REPOS` — so from the eject until this change the compositor was
  unreachable to the daily sweep, which reports a repo with no arm exactly the
  same way it reports a repo with nothing to say. (The local checkout existed;
  membership was the gap. `clone`/`pull` follow so a cloud run has one too.)
  That is the whole of the concession: no lock edge, no ripple, no release path.
  ⚠️ And `FAMILY` was never the single source of truth for the word — §3.3's
  `bench` subsection lists eight more places `nebelhaus` is a literal. See §2.1.
- `notes/launch-phase-1.md` §0 has an unresolved **`.bak` discrepancy**
  carry-over (`guides/the-bar.mdx:128`) — unrelated, but it's in the same file
  you'll be editing.
- ✅ ~50 of the agent memory files are keyed to nebelhaus names and will
  misroute future sessions. Cheap sweep, do it last (§2.2's tail) — **done
  2026-08-09**; 15 files held live option paths, and the rest are the rice, the
  domain or bundle ids. See §2.2.
- ✅ **The rice's per-room options list was duplicated — closed.**
  `modules/options-modules.nix` and `modules/default.nix` each held their own
  copy of the same 14 paths, and `options-modules.nix`'s header comment ("the
  ONLY modules that declare `nebelhaus.*`") read as if it were the single
  source; adding a module to one and not the other failed in a way that named
  neither file (§1.0, finding 5). `default.nix` now does the
  `import ./options-modules.nix`, and the header records the fold ("three now
  that modules/default.nix imports this file"). The suggested ordering — do it
  *before* §1 — is moot; it landed during the sweep instead, and the sweep
  survived it.

---

## §10 — The layer's repo becomes `hausfold/haus`

**Decided 2026-08-11, in conversation. Ran the same day.** Decision 8 (2026-08-10)
settled the words: *haus* is the nix-darwin layer, *hausfold* is the org, the
maker and the seller, and **hausfold is never the layer**. It then explicitly
declined to move anything in code, because the point at issue was copy. The
question this section answers is the one that leaves open: **the layer's repo
slug was `hausfold/hausfold`, which says in the one place nobody can misread
that the layer is called hausfold.**

### 10.0 Why this isn't decision 8 being re-litigated

Decision 8's box says "it renames no repo" and 🚨-flags a `hausfold` → `haus`
sweep. Both stand, and this is neither:

- **Not a sweep.** A sweep asks "which occurrences of this word mean the layer?"
  and gets it wrong ~90 times out of 100 in this family. This renames **one
  identifier** — a GitHub slug and the directory named for it — and every edge
  that quotes it. The org, the bundle ids, `hausfold.co`, the Homebrew taps and
  every other repo's URL are untouched.
- **It is decision 8 finished, not reversed.** `hausfold/hausfold` was the last
  place the layer was spelled with the org's name. The ergonomics were the tell:
  `bench ship hausfold`, `bench release hausfold`, `./hausfold/modules/sill`,
  `~/.cache/claude-worktrees/hausfold/<lane>` — every one of them a daily
  sentence that said the word decision 8 had just ruled out.
- **It matches the ecosystem shape.** `nix-community/home-manager`,
  `LnL7/nix-darwin`: the repo is named for the layer, the owner for who ships
  it. `hausfold/haus` reads as "haus, by hausfold", which is the sentence.

**One thing it does NOT do: rename the flake input.** The consumer still writes
`inputs.nebelhaus.url = "github:hausfold/haus"` and `bench` still passes
`--override-input nebelhaus/…`. The input name is the **rice's**, it is a 👤 call
on a 👤 file (§3.3's flake-input-paths box), and it stays exactly where §6 left
it. Renaming it here would silently stop every override applying — the same trap
that box was written for.

### 10.1 ✅ The slug — done first, on purpose

`gh repo rename haus -R hausfold/hausfold`. Ordering matters and only in this
direction: GitHub redirects the **old** name to the new one forever, so
everything keeps working the moment the rename lands and the edge PRs can follow
at leisure. Write `hausfold/haus` into a flake *before* the rename and the input
doesn't resolve at all.

**Measured on the 2026-08-09 rename, before relying on it here** — every one of
these already resolves `nebelhaus/nebelhaus` today:

| surface | after a rename |
|---|---|
| `git clone` / `fetch` / `push` | ✅ redirects (git warns on push, then works) |
| `raw.githubusercontent.com/<old>/…` | ✅ **200, not a 404** — measured. This is the one that matters: it is how `init.sh` fetches `bootstrap.sh` |
| `api.github.com/repos/<old>` | ✅ 301, and every client that follows redirects (Workers' `fetch`, `gh`) lands right |
| `gh pr list -R <old>` | ✅ resolves |
| open PRs, issues, branches, stars | ✅ all carried, ids unchanged |

So nothing in this rename is a flag day, and the freed slug `hausfold/hausfold`
now behaves exactly like `hausfold/nebelhaus`: it resolves *by redirect*, which
is precisely why `bench`'s `gh_repo` refuses to lean on redirects
(`test/bench.bats` asserts it).

### 10.2 ✅ The edges — one PR per repo

| repo | what moved |
|---|---|
| **workshop** | `bench` (`FAMILY`, `OVERRIDABLE`, `EDGES`, `local_src`, the release + version arms, `repo_dir`, usage), `test/bench.bats`, `.gitignore`, `AGENTS.md`, `README.md`, `docs/workflows.md`, `.agents/**`, `.github/copilot-instructions.md`, **both drift workflows' `repository:`**, `web/worker.js` + its tests, `web/scripts/*.mjs`, the docs tree and the generated `reference/options.md` link base |
| **haus** (the layer) | `bootstrap.sh`'s three URLs, `flake.nix`'s two `nix run` comments, `README.md`, `AGENTS.md`, `docs/modules.md`, the `report-issue-nebelhaus` pounce command's `repo=` |
| **nebelung · pounce · perch · holt** | the "🏠 the house" README link and a handful of prose refs — no code |
| **hausfold.co** | `public/haus/index.html`, `public/desktops/nebelhaus/index.html`, `README.md`, `AGENTS.md` |
| trill · org-profile · homebrew-tap | **nothing** — zero hits, measured, not assumed |

🚨 **The one trap in the mechanical half: `hausfold/hausfold.co`.** A naive
`hausfold/hausfold` → `hausfold/haus` replace turns the *site* repo into
`hausfold/haus.co`, which does not exist. Every sweep here used a negative
lookahead (`hausfold/hausfold(?!\.co)`) and the result was grepped for
`haus\.co` afterwards. It caught one (`web/README.md:86`).

**Deliberately left alone:** historical PR citations (`hausfold#305`,
`.../hausfold/hausfold/pull/200`) — they redirect, and the display shorthand
records the name the repo had at the time, which is the convention this family
already kept through the org migration.

### 10.3 👤 The checkout — `bench relocate-haus`

The directory is the only part that a `git pull` cannot deliver: it is machine
state, and on this machine it had **four live agent lanes** whose `.git` files
hold absolute paths into `~/code/workshop/hausfold/.git/worktrees/<lane>`.
Moving the dir by hand and stopping there strands every one of them.

So `bench` carries a one-shot `relocate-haus` that does the whole thing in
order, and refuses if a lane is occupied:

1. `mv $ROOT/hausfold $ROOT/haus`
2. `git remote set-url origin` → the new slug (hygiene: the old one redirects)
3. `mv ~/.cache/claude-worktrees/hausfold → …/haus` — lane checkouts are named
   for the repo too
4. `git -C $ROOT/haus worktree repair <every lane path>` — **with** the paths,
   because both ends moved and plain `repair` only fixes one direction
5. rewrite the absolute paths in holt's `registry.tsv` (backed up to
   `registry.tsv.bak.relocate`, in holt's own `.bak.*` convention)

Until it runs, `repo_dir haus` falls back to `$ROOT/hausfold` when `$ROOT/haus`
is absent, so a machine that pulled the new `bench` but hasn't moved the dir
still works — and `bench status` says so out loud, once, because a silent
fallback is how a shim becomes permanent. **Three bats cases pin that arm's
exact shape.** Delete the arm, the nudge, the command and its tests when every
machine has run it.

### 10.4 👤 Left for you, and why each is small

- **`~/.config/nix/flake.nix:7`** — `inputs.nebelhaus.url = "github:hausfold/hausfold"`.
  A 👤 file outside the family. It resolves through the redirect, so this is
  hygiene; fix it at the next `haus rebuild` and the input *name* still stays
  `nebelhaus`.
- **`flake.lock`'s `original` field** across the family — same story as §3.3:
  the recorded owner/repo is the old one until a `nix flake update --refresh`
  rewrites it. Nothing breaks meanwhile (the rev is what's fetched), and
  `bench ship` corrects it on the next real ripple.
- **The org repo descriptions** — `workshop`'s and `homebrew-tap`'s still say
  "nebelhaus family" / `brew tap nebelhaus/tap`. Unrelated to §10, found while
  looking; a two-minute `gh repo edit`.

### §10's gate

`bats test/bench.bats` green (71 cases, 3 of them new), `web`'s vitest green
(43), `shellcheck bench` clean, and `rg 'hausfold/hausfold(?!\.co)'` returning
nothing outside historical PR links. Then, on the machine: `bench relocate-haus`
followed by `bench status` reporting the layer at `./haus` with every lane
still resumable in `holt`.

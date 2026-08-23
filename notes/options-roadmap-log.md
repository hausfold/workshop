# Option-surface roadmap — the status log

> ★ **The passes moved to [`drift.md`](drift.md) on 2026-08-23**, along with
> §5.14 of the roadmap, because what they were finding had stopped being about
> the option surface. **This file keeps its name**, and the reason is smaller
> than the first draft of this paragraph claimed. It said *"thirty-six dated
> entries link to it by that name"*; **none of the thirty-six do** — the string
> appears nowhere inside them. What links by name is the roadmap's pointer and
> the **three** entries now in `drift.md`, whose own text says *"moves to
> `options-roadmap-log.md` unedited"* — and this log's first rule is that an
> entry is never edited, so correcting those three to match a rename is exactly
> what it forbids. Three links and one rule is still enough, and it is what the
> evidence supports. The name is also a fact about where these passes came from,
> and they did come from there.

Every dated pass on [`options-roadmap.md`](options-roadmap.md), newest first,
from the thirty-seventh (2026-08-23) back to the first (2026-08-02) —
thirty-eight blocks, because 2026-08-04 carries two and only one of them was
numbered. It was the roadmap's own preamble until 2026-08-20, when it had
grown to 2,393 lines — larger than every other file in `notes/` put together,
and sitting between the document's title and its §1.

**This is a record, not a plan. Nothing here is a to-do.** A pass is what one
session found when it checked the roadmap's open boxes against the repos: what
shipped, what was already ticked and shouldn't have been, and — the part worth
keeping — the claims this document made about itself that turned out to be
false. §5.14 of the roadmap ("How this doc drifts, and the one rule that fixes
it") is the standing summary of that; these are its evidence.

Read it when you want to know *why* a section says what it says, or before
re-deriving something a pass already settled. Never edit an entry: a dated
finding that gets corrected in place stops being evidence. The three most
recent passes stay in the roadmap itself, where a reader meets them; when a
fourth lands, the oldest of those three moves here, on top.

⚠️ **Read every `haus.*` below as today's `haus.*`, and every `trill` as the
archived Messages client** (`hausfold/messages` since 2026-08-08). The
roadmap's naming banner covers both and is not repeated here.

---

> **Status, 2026-08-23 (thirty-seventh pass) — the thirty-sixth pass's finding
> was FIXED twelve seconds before the pass reporting it merged, by the same
> session, out of the same keyboard. Its body was rev-bounded exactly as row
> eleven demands and its HEADLINE was not, and the headline is the sentence a
> reader quotes. And the pass that landed with it turned up the same shape one
> layer down: 318 leaves, unchanged for the second pass running, while an
> option description quietly withdrew the word "one-time".**
>
> Fetched first (twenty-third pass's rule), dated at revs (row eleven), derived
> from the rev rather than from a PR body (the thirty-fourth pass's sharpening):
> workshop = `2ea7793`, haus = `b1e263a`, perch = `a74e42a`, hausfold.co =
> `2d22b02`. pounce is `aabd99a`, holt `1ba98aa` and nebelung `5d5d0a2` — all
> three unmoved as of those revs, which is a fact about three revs and not a
> licence to skip a section (row nineteen).
>
> ⚠️ **"Fetched first" is not "fetched last", and this pass proves it.** The
> earlier drafts of this paragraph read *"workshop `main` = `origin/main` =
> `2ea7793`"*, and by the time the pass was committed (`c4f4cfa`, 05:08:00Z)
> four of the seven had moved: workshop to `e8ebc5f` (#438 05:00:22Z, #439
> 05:01:32Z), haus to `a373ca0` (#471 04:52:54Z), perch to `cb15526` (#87
> 04:59:04Z) and holt to `c796d9d` (#54 04:59:47Z). **Every rev-bounded claim
> below survives untouched** — that is what rev-bounding is for — and the
> enumerated window (04:13:58Z–04:39:00Z) is unaffected; what went stale is the
> two `= origin/main` equalities, which are the only clauses in a pass that
> claim a repo's *tip* rather than a repo's *content*. They are struck, not
> re-measured, because re-measuring them just resets a clock that runs the whole
> time a pass is being written. This is row nineteen's third instance and its
> narrowest: **do not write `X = origin/main` in a pass at all.** Named
> separately in §5.14 would be over-cataloguing; it is the same row with the
> smallest possible fix. ★ Re-checked at haus `1ddeb51`
> anyway, since the leaf count is what a stale rev would most plausibly
> falsify: **still 318, still key for key** (#471 and #473 add none), so the
> headline holds three haus PRs later. Non-cloud, so every time below is a committer date on
> `origin/main`, rendered in UTC. **This family's local time is UTC−5 and this
> window crosses midnight**, as the thirty-sixth pass's did: the whole range
> below is 2026-08-23 in UTC and was still Saturday evening at the keyboard.
>
> Landed since the thirty-sixth pass's revs — a **25-minute** window, the
> shortest any pass here has read: every commit below landed between 04:13:58Z
> and 04:39:00Z. **Three haus commits** (#469 04:37:38Z, #468 04:38:36Z, one
> lock bump 04:39:00Z), **one perch** (#86 04:16:51Z), **one hausfold.co** (#131
> 04:13:58Z), and nothing in pounce, holt, nebelung or the workshop beyond the
> thirty-sixth pass itself.
>
> **The count is 10 at `2ea7793`**, re-derived with the command the last nine
> passes ran (`sed -n '/^## 5\. The option families/,/^### 5.14/p'
> notes/options-roadmap.md | grep -c '^- \[ \]'`) — the number the thirty-sixth
> pass predicted. This pass **opens one box and closes none**, so the pass after
> this one should find **11**. The eleventh is §5.6's, which is BUILT and green
> and open as haus#472 — left `- [ ] ◐` on §5.14's own instruction that only
> `mergedAt` earns a tick, and to be ticked the moment the PR has one, not
> re-derived from scratch. It adds a §5.14 row and rotates the log: the thirty-fourth pass
> moves to [`options-roadmap-log.md`](options-roadmap-log.md) unedited, and both
> pointer counts are re-COUNTED rather than incremented (35).
> `docs/site-data/options.json` at `b1e263a` is **318 leaves in 35 namespaces**,
> key for key identical to `8c1fa43` (`diff <(git show 8c1fa43:… | jq -r
> 'keys[]') <(git show b1e263a:… | jq -r 'keys[]')` is empty).
>
> ★ **First, and it is the pass: twelve seconds.** haus#469 (`70a3555`,
> 04:37:38Z) fixed the twin sentence the thirty-sixth pass had just found. The
> pass itself (`2ea7793`, 04:37:50Z) merged **12 seconds later**, headed *"it is
> still standing"*. Same author, same session — both commits carry
> `Claude-Session: …session_01GRm5Q4t18YXjezha6J6tka` — and haus#469's own body
> says *"Found by the workshop's options-roadmap thirty-sixth pass."* One piece
> of work, landing in two repos, with the remedy arriving first and the report
> reading as though it hadn't.
>
> **The pass did the rev-bounding right and it did not help.** Its evidence
> paragraph is exemplary: *"At `8c1fa43`, `grep -n 'haus show'
> modules/shelf/default.nix` returns exactly two lines"* — a claim about a rev,
> true forever, which is precisely what row eleven asks for and what the
> thirty-second pass sharpened row nineteen into. The ★ heading above it is in
> the unbounded present tense, and so is the block header the log will carry.
> **Row eleven was applied to the INSTANCE and not to the CLAIM** — which is the
> thirty-sixth pass's own row twenty-two, turned on the pass that wrote it,
> inside the same commit. That is not an irony worth a line for its own sake; it
> is the reason the rule needs restating in a form that reaches headlines: a
> reader meets a status block through its bolded first sentence, quotes that,
> and never opens the paragraph where the rev is.
>
> ⚠️ **And the twelve seconds is not a near miss to tighten up.** No ordering
> discipline fixes it. The two repos have no seam — §5.14's structural reason 1,
> *"the work happens in four repos and the doc lives in a fifth"* — so the two
> PRs were queued independently and merged in whichever order GitHub got to
> them; had they landed the other way the block would have been true for twelve
> seconds and false forever after. **The fix is grammatical, not procedural**:
> a finding written as *at `<rev>`, X* survives either order, and a finding
> written as *X is still standing* survives neither. Two of the last four
> passes have now been about a sentence's WIDTH rather than its truth.
>
> ★ **Second: the leaf count saw nothing again, and what moved was a promise.**
> haus#468 — the same PR that takes SketchyBar from nixpkgs so a fresh Tahoe Mac
> stops building it from source — rewrote the `haus.focus` room description
> twelve lines away from anything it was about. Old: *"grant sketchybar once for
> the pill). `focus doctor` walks the **one-time** steps."* New: *"the pill needs
> one on sketchybar itself, and TCC keys that to the binary — so it is asked
> again after a rebuild that moves it). `focus doctor` walks **those** steps."*
> **The word "one-time" was withdrawn.** Moving the binary from
> `/opt/homebrew/opt/sketchybar/bin` into the system profile means the
> Accessibility grant is keyed to a store path a nixpkgs bump will move, and the
> user is re-prompted. That is a behaviour change a person will feel, and the
> only **user-facing** surface that says so is a description string — with
> **zero** leaves added, removed or retyped. (Not the only place it is written
> down: `modules/bar/default.nix:1801-1807` reasons it out at length in a source
> comment. That is the width the evidence supports; *"declared in exactly one
> place"* is the wider sentence, and it is the row this file added one pass
> ago.) `options.json` is the same 318 keys it was.
>
> **Three of the last five passes, the instrument has missed the day's most
> stranger-visible change**: the thirty-third's command header (a declaration
> surface with no options page), the thirty-fifth's declaration/value gap, and
> now a description that is the only user-facing record of a regression. ⚠️
> *Three of five*, not "three running" — the thirty-fourth added four leaves and
> the thirty-sixth added none, so the misses are not consecutive, and the leaf
> count itself is unchanged only for the **second** pass in a row, which is what
> this block's own header says. The header keeps the leaf count for the reason
> the thirty-fourth pass gave — it is the one number that is cheap and
> comparable — but three misses in five is no longer a caution about the number,
> it is a statement about what the number measures:
> **`options.json` tracks the SHAPE of the surface and nothing about what the
> surface promises.**
>
> ⚠️ **The published copy of that sentence is stale as this is written, and the
> check that reads it runs weekly.** `content/docs/haus/reference/options.mdx`
> at hausfold.co `2d22b02` still carries *"grant sketchybar once for the pill"*
> at lines 5806–5807. `options-drift.yml`'s cron is `30 9 * * 1` — the next
> firing is 2026-08-24T09:30Z, **28 h 51 m** after the merge, and the general
> ceiling is seven days. The hand-written `rooms/focus.mdx:280` says *"sketchybar
> has no Accessibility grant yet"* with no mention of the re-prompt and has no
> check at all. Fourth toss of the thirty-fourth pass's coin and it landed the
> same way: the copy with a check is the slow one, the copy without a check is
> fixed only if somebody happens to have the file open, and here nobody did.
>
> ★ **Third, and it is a new box: `haus.roster.<name>.scope` is documented as
> REACH and is load-bearing as a PATH.** haus#468 moves the sketchybar entry from
> `brew = "FelixKratz/formulae/sketchybar"` to `package = pkgs.sketchybar` with
> `scope = lib.mkDefault "system"`, and that `scope` is what puts the binary in
> `/run/current-system/sw/bin` — a literal string that **fifteen call sites in nine
> files across three rooms** now hardcode — the bar (`default.nix`,
> `barpop.swift`, `aerospace-notify.sh`, three `plugins/` scripts), focus
> (`default.nix`, `focus.sh`) and
> core (`awake.sh`). The option's own description frames the choice as
> availability — *"'system': …on PATH for root, for non-login shells, and for
> launchd jobs… It is about REACH"* — and never says a path depends on it. A
> host setting `scope = "user"`, which is the DEFAULT for every other roster
> entry and a documented in-range value, moves the binary to the user profile,
> leaves the launchd agent pointing at nothing, and the bar simply never draws.
> Nothing asserts: `grep -rn 'roster\.sketchybar\|sketchybar\.scope' modules/`
> at `b1e263a` returns **nothing**, while the bar room's own assertion block,
> in the same file, exists for exactly this class and says so — *"each of these is a
> pill that cannot work, as opposed to one that merely won't draw."* This is
> **§5.4's** limit, not §5.9's: registry v2 shipped "install from any of four
> sources" as a metadata choice, and the first entry to actually MIGRATE between
> sources turned one of its fields into a filesystem contract three other rooms
> depend on. Box opened there.
>
> ◐ **And one built, deliberately not ticked.** The box the thirty-fifth pass
> opened — *state §5.6's policy over effective VALUES, and check it* — is
> written to its sketch and green under `nix flake check`, and is open as
> haus#472 rather than merged. §5.14's own row says a PR number in a tick is a
> promise that only `mergedAt` keeps, so the box stays `- [ ] ◐` and stays
> counted. It resolves all 66 leaves of the ten groups on
> each of the four shipping desktops and diffs the non-quiet ones against an
> expected table, tagging each by who supplied the value. **The result is two
> rows and no `desktop:` among them**, which is the part worth keeping: not one
> of the four desktops names a single one of the 66 leaves, so the entire
> curated surface is offered and unexercised by the product — exactly as §5.6
> intended — and **every row this check will ever gain starts life as a `room:`
> row**, the one class the policy was never addressed to. The thirty-fifth
> pass's topological tell (29 of §5.6's 33 citations sit inside its own
> implementation) is now a mechanical one.
>
> ⚠️ **And building it found a fifth instance of the shape this file keeps
> re-deriving, in the one file that documents itself as prone to it.** haus's
> `.github/workflows/check.yml` carries a hand-written census of which checks
> run where, with a comment that says *"Keep this census honest when a check is
> added: it is this repo's only record of what CI actually covers, and it rots
> in every direction"* and then recounts three prior rots by date. Re-derived
> at `b1e263a` with the two commands that comment prints: the darwin list said
> FOURTEEN and is fifteen with the new check, and the **Linux** list said
> FIFTEEN while `nix eval .#checks.x86_64-linux --apply builtins.attrNames`
> returns **nineteen** — `pounce-command-headers`, `pounce-header-grammar`,
> `userstyles-inline` and `userstyles-important` were declared for Linux and
> never listed. Fourth rot, and the first in the SAFE direction: the checks
> were running and the census undercounted them, which is why nothing ever
> noticed. Both fixed in haus#472. The generalisable half is small and is not
> new — a comment that tells you how to re-derive it is not a check, however
> honestly it confesses. §5.14's structural fix ("make the upstream repo emit
> something mechanical") has an obvious application here that nobody has spent
> a PR on: the census is two `nix eval` calls away from being generated.


> **Status, 2026-08-23 (thirty-sixth pass) — the correction reached the
> INSTANCE and not the CLAIM. The sentence haus#467 fixed has a twin twelve
> lines below it, in the same comment, carrying the same argument, authored by
> the same commit, and it is still standing. And the reason both corrections
> give — *`haus show` reads a desktop FILE and never a machine's resolved
> values* — is false: run here, it reads this machine's resolved value for 23
> leaves, ranks every one of them, and calls three `overridden`. The true
> reason is narrower and unquotable: no file NAMES the leaf.**
>
> Fetched first (twenty-third pass's rule), dated at revs (row eleven), derived
> from the rev rather than from a PR body (the thirty-fourth pass's
> sharpening): workshop `main` = `origin/main` = `7ca290d`, haus = `8c1fa43`,
> perch = `0d7780d`, hausfold.co = `c942439`. pounce is `aabd99a` and holt
> `1ba98aa`, both unmoved since the thirty-fifth pass's own revs; nebelung is
> `5d5d0a2`, unmoved since 2026-08-20 — three facts about three revs and not a
> licence to skip §5.9 (row nineteen). **This family's local time is UTC−5 and
> this window crosses midnight**: times below are UTC as always, so the block is
> dated 2026-08-23 while the day at the keyboard was still 2026-08-22. The
> thirty-fifth pass has the mirror of it — headed 2026-08-22, its own commit
> `5accf9a` landed 2026-08-23T03:26:27Z — so a reader comparing the two headers
> to the two commit dates finds a day that does not line up in either
> direction, and both are right.
>
> Landed since the thirty-fifth pass's revs: **three haus commits** — two PRs
> (#466 03:25:52Z, #467 04:05:04Z) and one lock bump (04:08:16Z) — **two perch**
> (#84 2026-08-22T12:36:01Z, #85 2026-08-23T03:32:33Z), **two hausfold.co**
> (#129 2026-08-23T03:01:20Z, #130 2026-08-23T04:07:45Z), **six workshop**
> (#431 — the thirty-fifth pass itself — #432, #433, #435, #436 and a docs-sync
> watermark), and nothing in pounce, holt or nebelung.
>
> **The count is 10 at `7ca290d`**, re-derived with the command the last eight
> passes ran (`sed -n '/^## 5\. The option families/,/^### 5.14/p'
> notes/options-roadmap.md | grep -c '^- \[ \]'`) — the number the thirty-fifth
> pass predicted. This pass amends §5.6's loose-end note — striking a false
> clause in place rather than rebutting it below, which is row twenty-two aimed
> at this pass's own diff — adds a §5.14 row, and opens and closes no box, so
> the pass after this one should also find 10. It also rotates the log, per the
> log's own rule that the three most recent passes stay here: the thirty-third
> moves to [`options-roadmap-log.md`](options-roadmap-log.md) unedited, and both
> pointer counts are re-COUNTED rather than incremented (34), which is the
> correction the thirty-third pass asked for and did not get.
> `docs/site-data/options.json` at `8c1fa43` is **318 leaves in 35 namespaces**,
> both unchanged; haus#466 inserted 397 lines and none of them is an option.
>
> ★ **First, and it is the pass: two sentences, one comment, one commit — and
> the fix reached one of them.** haus#461 (`e7fd997`, 2026-08-22T10:40:10Z)
> wrote both. The first argued the screenshot write should go through a named
> option because it would then be *"readable as a named option in `haus show`
> and the reference"*; the second, twelve lines down and closing the same
> argument, says *"Through the option rather than the plist key direct, so the
> generated option reference and `haus show` describe what the machine actually
> does. That is the whole gain and it is worth being exact about."* haus#467
> (`bf1c1ea`, 2026-08-23T04:05:04Z — **17 h 24 m 54 s** later) corrected the
> first, in place, with a parenthetical naming the wrong surface and the right
> one, and its own message enumerates what it
> fixed — *"Two stale comments fixed in the same change, both found by the
> assurance read"*, one here and one in `modules/options-modules.nix`. The twin
> is neither of them. At `8c1fa43`,
> `grep -n 'haus show' modules/shelf/default.nix` returns exactly two lines —
> **219, the correction, and 231, the claim it is about** — and
> `modules/shelf/options.nix`'s new comment says *"the claim two files over in
> ../shelf/default.nix was wrong about which surface"*, singular, about a file
> holding two of it.
>
> ★ **Second, and it is why the twin survived: the reason everybody stated is
> wrong, and the right one cannot be quoted.** Re-run at `8c1fa43` rather than
> cited: `haus show --json ./desktops/hacker.nix` reports 23 leaves in `.sets`
> — neither `haus.shelf.watchScreenshots` nor `haus.screenshots.thumbnail`
> among them, so the claim's *conclusion* holds — and its `.machine.leaves`
> block carries the same 23, **every one with a `prio`**, 20 `unchanged` and
> **3 `overridden`**. A verdict of `overridden` is a statement that something
> on this machine outranks the file, and it cannot be computed without
> evaluating this machine: `modules/core/haus-show.sh:520-585` reads
> `o.highestPrio` and `o.value` out of `darwinConfigurations` of the user's own
> consumer flake, over a path list that is `[.sets[].path]` plus the leaves the
> machine's CURRENT desktop sets and the candidate does not (`dropped`). So
> `haus show`'s boundary is the **leaf set, not the layer**: it reads resolved
> machine values for every leaf some file names, and it misses
> `haus.screenshots.thumbnail` because no file names it — the write lives
> inside a room's `mkIf`, which is exactly what the thirty-fifth pass found and
> exactly what neither correction says. The *outcome* both corrections reach is
> right, and was re-checked here: `haus get haus.screenshots.thumbnail` prints
> `false` on this machine at `8c1fa43`.
>
> ⚠️ **And the published documentation has been right about this the whole
> time.** `content/docs/haus/reference/haus.mdx` at hausfold.co `c942439`
> describes the command as *"see what it would change on this Mac"*, and
> `modules/core/haus-show.sh`'s own help and footer say only that it is *"a
> leaf diff, not a rebuild preview"* — neither ever claimed the machine was out
> of the evaluation. The false version exists only in source comments and in
> this file, i.e. in exactly the two places no docs check reads, written by
> people correcting each other about a command whose user-facing text they did
> not need to open.
>
> **Three statements of the wrong reason, two of them corrections, inside 41
> minutes.** The thirty-fifth pass wrote *"with your own config never part of
> the evaluation"* (`5accf9a`, 03:26:27Z) — this document's own, and the first;
> haus#467's parenthetical repeated it at 04:05:04Z; workshop#435 put it in
> §5.6 at 04:07:48Z, 2 m 44 s later, in a ⚠️ correcting a different error in
> the same sentence. **The generalisable half is the width of the reason, not
> the number of copies.** The fact that justified all three is narrow, specific
> and dead on arrival as prose — *this desktop file does not set that leaf, and
> `haus show` reports the leaves a file sets*. The reason each author reached
> for instead is a rule about the command — *it never reads your machine* —
> which is memorable, general, load-bearing for the next argument, and false.
> A correction is written at the moment of maximum confidence about a single
> line, and the sentence it produces is the one later readers cite; row
> twenty-two below.
>
> ⚠️ **§5.6's own trigger had already fired when it was written.** The note
> added at 04:07:48Z ends *"Twice in one section, from two authors, about a
> command whose own footer says what it does not do — worth §5.14's attention
> if it happens a third time."* The third instance was 17 hours old at that
> moment, sitting in the file the note is about, and the fourth is the note's
> own next clause. A condition stated as a future test, met in the past, by the
> text being corrected: it is worth naming because the note is *right* — the
> repetition is the finding — and the only thing that failed was looking for it
> where it already was. Amended in §5.6.
>
> ★ **Third, smaller and worth a line: the published reference has started
> printing rules instead of values, and there are three of them.** haus#467
> gives `haus.shelf.watchScreenshots` `default = config.haus.shelf.enable` with
> a matching `defaultText`, so `options.json` at `8c1fa43` now holds **three**
> leaves whose default is an expression naming another option —
> `developer.git.enable`, `developer.toolbelt.enable` and this one, all three
> `config.haus.<x>.enable`. `haus set`'s picker declines to prefill them —
> `modules/options-catalogue.jq:45-50` makes `pasteable` false when
> `defaultText | test("\\bconfig\\.")`, re-read here rather than taken from
> haus#467's message, which says the same thing — which is honest; the
> reference prints the expression, which is also honest and is the first time a
> stranger reading that page learns a rule where every other
> row hands them a value. Nothing is wrong and nothing is checked: no surface
> resolves it for a reader, which is the thirty-fifth pass's declaration/value
> gap arriving on the *documentation* side of the same option, one day later.
>
> ⚠️ **And one on the check, which inverts row twenty.** hausfold.co#130 fixed
> two stale copies of that default and its own message sorts them: the
> generated `reference/options.mdx` **has** a drift check and it is a weekly
> cron, so left alone it could have said `true` for up to a week; the
> hand-written `rooms/shelf.mdx` has none and would never have been caught —
> and it was fixed **2 m 41 s** after the merge, because the person who moved
> the default was still holding the change. The copy with a check was the slow
> one and the copy without a check was fixed by proximity, not by tooling.
> Same coin as the thirty-fourth pass's four days and the thirty-fifth's 59
> seconds, third toss: what fixes a copy is whether somebody had a reason to
> have the file open, and a check only changes *the ceiling* on how long it can
> stay wrong.


> **Status, 2026-08-22 (thirty-fifth pass) — the surface grew by one leaf, and
> that leaf turns a macOS setting off on two of the four shipping desktops.
> §5.6's null-default policy — the one rule this section derived from first
> principles and then held across ten groups — is breached, from OUTSIDE §5.6,
> by a room, at `mkDefault`; and every surface that could have shown it prints
> `null`, correctly, because the declaration still is.**
>
> Fetched first (twenty-third pass's rule), dated at revs (row eleven), derived
> from the rev rather than from a PR body (the thirty-fourth pass's sharpening):
> workshop `main` = `origin/main` = `7ea7bc2`, haus = `ff8ecf3`, pounce =
> `aabd99a`, perch = `c4c67bb`, holt = `1ba98aa`, hausfold.co = `a1dbbcd`.
> nebelung is `5d5d0a2`, unmoved since 2026-08-20 — a fact about a rev, not a
> licence to skip a section (row nineteen). Non-cloud, so every time below is a
> committer date on `origin/main`, rendered in UTC.
>
> Landed since the thirty-fourth pass's revs — an **82-minute** window, the
> shortest any pass here has read: every commit below landed between 10:38:35Z
> and 12:00:55Z. **Six haus commits** — three PRs (#464
> 10:38:35Z, #461 10:40:10Z, #465 10:54:53Z), two lock bumps and the
> `2026.08.22` release — **one pounce** (a release), **three perch** (#83 plus
> two release commits), **one holt** (`0.3.1`), **two hausfold.co** (#125,
> #128), **two workshop** (#429, #430), and **nothing in nebelung**.
>
> ⚠️ **#461 is the number the thirty-fourth pass recorded as *"no #461 reached
> `main`"*, and that parenthesis was FALSE when it merged.** haus#461 landed at
> 10:40:10Z, 8 m 31 s after `0f3a61c` — the rev that pass measured at — and 62
> minutes before the pass itself merged (`b39291a`, 11:42:26Z). Row nineteen's
> honest form is *"no box had closed as of `<rev>`"*, and the pass **had** the
> rev: it opens *"Landed since the thirty-third pass's revs"* and names all
> seven. Read strictly against that range the parenthesis is true. Read the way
> a gap in a PR-number run is actually read — as a fact about the repo — it was
> already wrong 8 m 31 s later. **The rev has to be inside the clause, not merely
> in the paragraph.** Forty words of separation is enough for a bounded claim
> to be received as an unbounded one, which makes this row nineteen's second
> instance and its first sharpening: the fix is not "attach a rev to the
> paragraph", it is "write the negative claim so it cannot be quoted without
> its rev". This pass's own first draft repeated the mistake in the other
> direction (*"it merged 78 minutes after that sentence"*, backwards by an
> hour) and was caught by re-deriving the two timestamps rather than by
> re-reading the prose — row eleven, on a pass about row nineteen.
>
> **The count is 9 at `7ea7bc2`**, re-derived with the command the last seven
> passes ran (`sed -n '/^## 5\. The option families/,/^### 5.14/p'
> notes/options-roadmap.md | grep -c '^- \[ \]'`) — the number the thirty-fourth
> pass predicted. This pass amends §5.6's header and its policy note, adds a
> §5.14 row, and **opens one box**, so the pass after this one should find 10.
>
> ★ **First, and it is the pass: 317 → 318 leaves in 35 namespaces (unchanged),
> and the one new leaf writes a `com.apple.screencapture` key on a machine that
> never asked.** The leaf is `haus.shelf.watchScreenshots` (haus#461), a `bool`
> defaulting **`true`**, and the half of it that lives in haus rather than in
> perch is one line: `haus.screenshots.thumbnail = lib.mkIf
> config.haus.shelf.watchScreenshots (lib.mkDefault false);`
> (`modules/shelf/default.nix:236`). Evaluated at `ff8ecf3` over all four
> shipping desktops — `mkHaus` per desktop, reading the resolved
> `haus.screenshots.thumbnail` and `system.defaults.screencapture` — `hacker`
> and
> `everyday` both come out **`thumbnail = false`**, with every other key in
> that domain `null`; `minimal` and `blank` come out `null`, because both leave
> the shelf off. So two of four shipping desktops now write
> `show-thumbnail = false` into a user's plist, and the published reference
> renders that option as **`null or boolean` · default `null`** over the
> sentence *"null (the default) leaves macOS's own choice alone…"* Both are
> accurate. The declaration IS null; the value is not.
>
> **§5.6's policy is not a style preference and that is what makes this a
> finding.** The section states it once for all ten groups — *every leaf
> defaults to null = write nothing, and null is deliberately not the same as
> "off"* — and then derives it: **the write is one-way.** Going back to `null`
> stops writing, it cannot restore, because a `defaults` write is sticky and
> macOS keeps no memory of the prior value, so an on-by-default group does not
> merely express an opinion, it *destroys* the setting it overwrote on machines
> already running. `animations` (rice#286) was drafted defaulting to `"fast"`
> with a good argument and was **reversed before merge** on exactly that
> ground. `watchScreenshots` is the same trade, decided the other way, one
> domain over — and the room's own comment reaches the same fact independently
> and uses it to describe the behaviour rather than to pick the default:
> *"disabling this room stops the write, it does not put the thumbnail back."*
>
> ⚠️ **Nothing here was done carelessly, which is the useful part.** haus#461
> reasoned the priority ladder out in a 33-line comment
> (`modules/shelf/default.nix:203-235`): `mkDefault` rather than an outright
> write, *so* a desktop at 900 or a host at 100 wins with no `mkForce`. It
> added a third paragraph to `haus.screenshots.thumbnail`'s own
> description saying the shelf turns it off — which regenerated into
> `options.json` and onto hausfold.co inside the same window — and routed the
> write through the named option rather than the plist key for a stated reason:
> *"a capture behaviour that changes machine-wide should be readable as a named
> option in `haus show` and the reference…"* **`haus show` is the one surface
> in that sentence that structurally cannot show it, and it says so itself.**
> Run at `ff8ecf3`, `haus show ./desktops/hacker.nix` reports *"sets 23 options
> across 11 rooms"*; neither `haus.shelf.watchScreenshots` nor
> `haus.screenshots.thumbnail` is among the 23, because `haus show` is a leaf
> diff of the FILE — *"what the file sets and what it leaves alone"*, with your
> own config never part of the evaluation — and the write lives in a room the
> file merely switches on. Its footer names the limit and hands off correctly
> (*"A leaf diff, not a rebuild preview… 'haus plan' builds that answer"*), so
> nothing is broken; the write is simply one layer below every surface that
> reads a declaration. The reference prints a declaration. `haus set`'s picker
> prints a description's first physical line — *"Whether the floating preview
> thumbnail appears in the bottom-right"* (§3.4, thirty-fourth pass). What is
> left is `haus plan` and the plist verifier, the two that read the BUILT
> config, and the module comment names `haus plan` for exactly that reason.
>
> **The policy travels as a comment, and the shape of where it travels is the
> mechanism.** `§5.6` is cited **33 times** in haus's source at `ff8ecf3` —
> `core/options.nix` 11, `core/default.nix` 6, `lib/restart-map.nix` 4,
> `lib/login-map.nix` 3, `flake.nix` 2, and one each in
> `core/loginwindow-keys.nix`, `options-groups.nix` and `lib/reachability.nix`
> — **plus four in a room, all four in `windows`**, which is §5.6's own tenth
> group and lives in a room because it interlocks with what that room does
> (`windows/options.nix:312`: *"Every option is null-by-default like every
> other §5.6 group"*). So the policy HAS reached a room, exactly one, and it is
> the room that hosts one of these groups. It has never been cited by a room
> that merely **consumes** one of these leaves — which is the shelf's position,
> and now the only position it can be broken from. And **no check reads a §5.6
> leaf's effective value**: of the thirty-three `nix flake check` entries at
> `ff8ecf3` exactly one reads resolved values at all — `desktop-projection`,
> which diffs 55 `haus.*` paths out of `darwinConfigurations.example` against
> `test/projections/example.json` — and not one of those 55 belongs to any of
> the ten groups. New box below; §5.14 row twenty-one.
>
> ⚠️ **That paragraph said "ten times … and zero times in a room" until the
> assurance read.** The ten came from a `grep -rn '5\.6' modules/ flake.nix`
> piped into `head`, so the count was the terminal's and not the repo's, and
> the four `windows` hits — the ones that make the claim interesting rather
> than just bigger — were 21 lines below the cut. Row ten again: a negative
> claim ("zero in a room") resting on a grep whose output was truncated before
> it was read.
>
> ★ **Second: two hand-written cross-repo copies corrected in 59 seconds and 6
> m 18 s — by nothing — and five more left standing, three of them in the repo
> the change was made in.** haus#465 (10:54:53Z) took the paw off the agents
> pill across twelve files, and hausfold.co#128 landed the docs half at
> 10:55:52Z. The shelf's screenshot behaviour merged at 10:40:10Z and
> hausfold.co#125 documented it — *"and the two macOS settings it turns off"*,
> both of them, correctly — at 10:46:28Z. At today's revs `git grep -nwiI paw`
> returns **zero** in hausfold.co and zero in the workshop's text. In haus it
> returns **eleven**, and **eight** of those are the **tour** pill's paw, kept
> deliberately and said so in #465's own message (*"The tour pill keeps ITS
> paw"*) — so the rename is exact, not merely thorough. The other **three** are
> in haus's own `notes/zellij-exit.md`, and **two more sit in holt**
> (`SPEC.md:359`, `test/holt.bats:600`); all five describe the agents pill,
> and holt's two say *"the rice's paw pill"* — stale twice over, since the pill
> is a robot now and "rice" stopped being the word on 2026-08-10.
>
> **No check was involved anywhere in this, in either direction.**
> `check-rice-bindings.mjs` compares launch-key data to launch-key data; the
> options page is regenerated by hand; the guides and the specs are prose. The
> tempting reading — *a session carries the repos it is sitting in* — is
> falsified by this pass's own numbers: **three of the five stale copies are in
> haus**, the repo #465 was made in, and holt cut `0.3.1` inside the same
> 82-minute window, so a session was sitting there too. The variable that
> survives its own evidence is narrower and more useful: **not which repo, but
> whether the copy sat in a file the change had a reason to open.** #465 swept
> the plugin, the bar module, the option descriptions, `AGENTS.md` and the
> generated site data — twelve files, every one of them downstream of the pill
> — and never opened a design note in `notes/` or a spec in another repo,
> because nothing about changing a glyph points at either. That sharpens row
> twenty rather than adding a row. Row twenty says a green check can hide a
> stale copy; this says the copies a change reaches and the copies it misses
> are sorted by **blast radius, not by diligence**, and no amount of care
> inside the diff widens it. The 59 seconds and the thirty-fourth pass's four
> days are the same coin, seen from each side.
>
> ⚠️ **This paragraph claimed "zero across all seven repos" until the assurance
> read, on the strength of `git grep -niE '\bpaw\b'`.** `git grep -E` is POSIX
> ERE, where `\b` is not a word boundary — the command returns zero for every
> word, in every repo, always. **A negative claim proved by a grep that cannot
> match is row ten**, and it is the second row this pass tripped over while
> writing about rows nineteen and twenty. The working spellings are `-P` or,
> as re-run above, `-w`.
>
> ⚠️ **Third, a window that closed itself, worth recording because the lock
> chain is what closed it.** haus#461 writes `screenshotsFolder` into
> `~/.config/perch/config.json`; the perch that reads it is perch#83, merged
> **8 seconds later** (10:40:18Z); haus's `perch` pin moved to that rev at
> 10:48:51Z. For **8 minutes 41 seconds** haus `main` wrote a key no perch it
> pinned could read, and the only thing that made that survivable is the clause
> the module states three times, once verbatim at
> `modules/shelf/default.nix:116` — *"A perch that predates the key ignores it,
> the same way an older one ignores the theme keys."* A forward-compat sentence written
> for a stranger's stale install was load-bearing for its own repo first, and
> for eight minutes the six-edge chain in "The one gotcha that explains
> everything" was the difference between a feature and a dead key.
>
> ⚠️ **And one for the tempo.** Eighty-two minutes, four releases (pounce, perch and
> holt within 17 seconds of each other at 11:47Z, perch's `nix release pin`
> three minutes later, haus at 12:00:55Z), three haus PRs, one new leaf. `holt
> 0.3.1` is the semver one — five SDKs, none of which can withdraw a published
> number. The thirty-third pass reported twelve PRs and zero leaves; this one
> reports three PRs and a policy. Neither number predicted the other, and after
> three passes saying so it is no longer a caution — it is the reason the leaf
> count stays in the header and never in the finding.

---

> **Status, 2026-08-22 (thirty-fourth pass) — the option surface grew for the
> first time in three passes, and one of the four new leaves is read by
> nothing. The finding worth the pass is four days old and was GREEN the whole
> time: the reserved launch-key set is the one enumeration in this family that
> is published as data AND has a drift check, and the published reference
> advertised a freed letter for four days and three minutes — because the check
> fires when the DATA moves, and its snapshot was re-blessed 43 seconds after
> it moved.**
>
> Fetched first (twenty-third pass's rule), dated at revs (twenty-fourth pass,
> row eleven): workshop `main` = `origin/main` = `43e1f4d`, haus = `0f3a61c`,
> pounce = `ecd7a26`, hausfold.co = `3d16b16`, perch = `91791bd`, holt =
> `a81d64c`. nebelung is `5d5d0a2`, unmoved since 2026-08-20 — stated as a fact
> about a rev and not as a licence to skip a section, which is the
> thirty-second pass's row. Non-cloud, so every time below is a committer date
> on `origin/main`, rendered in UTC.
>
> Landed since the thirty-third pass's revs: **22 haus commits** — sixteen PRs
> (#447–#460, #462, #463; no #461 reached `main`) and six lock bumps — **three
> pounce** (#95, #96, one release), **three perch** (#82 plus two release
> commits), **three holt** (#51–#53), **nine hausfold.co** (eight numbered,
> #119–#124 and #126–#127, plus one unnumbered), **eleven workshop** (#421–#428,
> two `rooms-desktops` commits and a docs-sync watermark), and **nothing in
> nebelung**. **The count is 9 at `43e1f4d`**, re-derived with the command the
> last six passes ran (`sed -n '/^## 5\. The option families/,/^### 5.14/p'
> notes/options-roadmap.md | grep -c '^- \[ \]'`) — the number the thirty-third
> pass predicted. This pass amends §3.4, §5.5 and §5.9, adds a §5.14 row, and
> opens no box, so the pass after this one should also find 9.
>
> ★ **First: 313 → 317 leaves in 35 namespaces (unchanged), and the fourth one
> is a switch with no wire behind it.** The four are `apps.cursor.enable`,
> `apps.vscode.enable`, `apps.zed.enable` and `homebrew.adopt`; `bar.items` is
> byte-identical for the fifth pass running. The three editors exist BECAUSE of
> the fourth — "declare VS Code even though you already installed it yourself"
> — and the fourth is **declared, typed, defaulted `true`, documented in
> eighteen lines, listed in `modules/options-groups.nix`, and read by
> nothing.** `config.haus.homebrew.adopt` occurs in `modules/core/default.nix`
> only inside the comment explaining why it is *not* inherited beside
> `autoUpdate`, `upgrade` and `cleanup`: Homebrew removed `brew bundle install
> --adopt` and now adopts unconditionally, so the option's last paragraph says
> `false` is a no-op. That is honest and it is invisible where it counts —
> `haus set`'s picker shows a description's **first physical line**
> (`modules/options-catalogue.jq`), so the row reads *"Whether a cask haus
> declares that is already sitting in"*, a fragment that stops mid-clause over
> a knob that does nothing in either position. Written into §3.4 rather than
> here, because §3.4 is the section that promised a generated reference cannot
> rot: it cannot, and it also cannot say this. How many OTHER leaves are in the
> same position is deliberately not claimed — `inherit (config.haus.X) a b;`
> and per-module `cfg` aliases defeat the grep that would answer it, and a
> count from that grep is row ten.
>
> ★ **Second, and it is the pass: this family built the exact mechanism the
> document keeps recommending, aimed it at the OTHER repo's prose, and its own
> two copies drifted for four days.** `modules/windows/launch-keys.nix` is a
> single authority whose header says *"two things render this list and neither
> may guess at it"*; it is published as `docs/site-data/launch-keys.json` and
> tripwired from hausfold.co by `scripts/check-rice-bindings.mjs`. haus#398
> (`41b84a8`, 2026-08-18T10:17:38Z) moved it `e` → `f` and carried the
> cheatsheet row, the collision assertion's message and three comments along in
> the same commit — one of those comments literally says "`e` went back to the
> roster". It also **regenerated `options.json` in that commit**, changing two
> descriptions — `haus.launcher.fnKey` and `haus.launcher.items`, both edited
> *because of* that same key move, the second gaining the words "`e` is unbound
> now, and `f` is Find Files" — while the two that enumerate the reserved set by
> hand had no diff to carry and went on saying `e`. Those two are
> **`haus.roster.<name>.key`** and **`haus.keys.leaderExtras.*.key`**, the
> published spellings, read off `options.json` rather than copied from
> haus#463's own PR body, which names both of them wrongly. They were corrected
> by haus#463 (`698d3f8`) at 2026-08-22T10:21:17Z — **four days and three
> minutes** — and hausfold.co's
> own third copy at 10:23:54Z (#127, "wrong twice"). The tripwire did fire, on
> 2026-08-18: hausfold.co#76 re-blessed the snapshot and fixed the one page it
> named **43 seconds after #398**. So the whole system worked at the speed of
> the check and then stopped, because the check compares data to data and the
> stale copies were prose. **The direction is what makes it worth a row: the
> surface that REFUSES you was current the whole time — a host typing `key =
> "f"` was stopped by an assertion that named `f` correctly — and the surface
> you read before writing the line was four days stale, telling you `e` was
> taken when the layer had just handed it back.** True for `e`/`f`, inverted
> for `.`: haus#460 reserved it without teaching the assertion message to name
> it, so the same enumeration failed loudly for 28 minutes instead of quietly
> for four days. Full amendment in §5.5, the
> generalisable half as §5.14's newest row.
>
> ★ **Third, §5.9's header-grammar half closed, eight seconds apart.**
> pounce#95 (`ecd7a26`, 10:31:12Z) and haus#459 (`4712700`, 10:31:20Z) both
> merged this morning, with the lock bump 19 seconds behind them pinning pounce
> at exactly `ecd7a26`. That number matters only because #459's own comment
> makes a promise conditional on it — *"when the lock moves past pounce#95 this
> can read those fixture files directly"* — so the condition was satisfied 19
> seconds after the sentence was written, and eleven of pounce's sixteen
> fixture names are still hand-mirrored into haus's table at `0f3a61c`
> (eleven, not the twelve §5.9 says twice — corrected there by this pass).
> Nothing is wrong; the seam that would
> end the mirroring is simply open and unwalked, one layer above the mirroring
> the two PRs just ended. The box stays `◐`: the other checkable half — the
> `~/.local/state/haus/any-page` literal shared by two rooms with nothing
> mechanical joining them — is untouched by either PR.
>
> ⚠️ **And one for the tempo, continuing the thirty-third pass's note.** Two
> days, 22 haus commits, sixteen PRs, and the number this file leads with moved
> by four — but the two days also produced a four-day-old lie on the published
> reference, a reader-less option, and a conditional TODO that came true inside
> its own minute. None of the three is visible in a leaf count, a check result
> or a PR title. The pass that reads only what moved sees a quiet week; the
> pass that reads WHY each thing moved sees three findings. That is not an
> argument for reading more commits — it is the argument for what the last five
> passes have been converging on: **the durable half goes in the box, the
> perishable half goes in the pass, and the check goes in the repo.**
>
> ⚠️ **And the pre-PR assurance read falsified three of this pass's own numbers
> before it merged, all of the same kind: a count or a name copied from a PR
> body instead of re-derived at a rev.** "twelve cases" was eleven (inherited
> from §5.9's own paragraph, written from the open PRs — corrected in both
> places); the two stale option paths were `haus.roster.<app>.key` /
> `haus.keys.leaderExtras`, which are haus#463's PR-body spellings and are
> respectively nonexistent and a different leaf; and the `"period"` example
> belonged to haus's `leaderExtras.*.key` for 28 m 16 s, not to hausfold.co's
> hand-copy page. Every one of them would have passed a reader's spot-check,
> because a PR body is written by the person who did the work and reads exactly
> like a measurement. Row eleven says *date it at a rev*; the sharper form this
> pass earns is **derive it from the rev** — a PR body is a claim about a rev,
> not a reading of one.


> **Status, 2026-08-20 (thirty-third pass) — twelve haus PRs in one day, more
> than any pass here has reported, and the option surface moved by ZERO leaves.
> The day's most stranger-visible new behaviour is declared on a surface this
> document has never counted, and §5.9's FOURTH way for a row to be absent
> merged 47 minutes after the pass that recorded the third.**
>
> Fetched first (twenty-third pass's rule), dated at revs (twenty-fourth pass,
> row eleven): workshop `main` = `origin/main` = `2657865`, haus = `73e7e9c`,
> pounce = `0c0c3aa`, nebelung = `5d5d0a2`, perch = `cd520d2`, holt =
> `eb4c438`, hausfold.co = `8f09436`. All seven moved since the thirty-second
> pass and all seven are read here, so the shape it was burned on — a rev spent
> on a negative claim, licensing not looking — is not available to this pass and
> was not needed. Non-cloud, so every time below is a `mergedAt`.
>
> Landed since the thirty-second pass's revs: **eighteen haus commits** —
> twelve PRs (#435–#446, 15:24:36Z → 21:34:15Z), four lock bumps and two
> releases — **two pounce** (#93 at 16:00:30Z, #94), one nebelung (#47), two
> perch (#80, #81) plus two release commits, one holt (#50) plus `0.3.0`,
> **eight hausfold.co** (#111–#118), and seven workshop commits (#415–#420 and
> the docs-sync watermark). **The count is 9 at `2657865`**, re-derived with the
> command the last five passes ran (`sed -n '/^## 5\. The option families/,/^###
> 5.14/p' notes/options-roadmap.md | grep -c '^- \[ \]'`). This pass amends
> three boxes and §6(b), corrects the log pointer's entry count (one short since
> the split, and one short again if incremented rather than counted), and opens
> none; a pass after this one should find 9 and should not treat that as
> drift.
>
> ★ **First: the number this file leads with saw none of it.**
> `docs/site-data/options.json` at `73e7e9c` is **313 leaves in 35 namespaces**
> — the same 313 as `9b64840`, key for key (`diff <(git show 9b64840:… | jq -r
> 'keys[]') <(git show 73e7e9c:… | jq -r 'keys[]')` is empty), eighteen commits
> and 2,411 inserted lines later. Four strings changed and nothing else, all of
> them the Stylus retirement's blast radius: `theme.accent`, `zen.extensions`,
> its example, and `zen.userStyles`. `bar.items` is 16 keys / 15 pills for the
> fourth pass running. **A pass that measured only the option surface would have
> reported the largest day this document has recorded as "nothing happened."**
> What moved instead was the **command header** — `# pounce: key = value` at the
> top of a command script — which gained `whenFile` (pounce#93) and `cheatWhen`
> (haus#436) and is a declaration surface with its own grammar, its own three
> parsers, and no options page. Seven keys over 23 commands today (`name`,
> `icon`, `description` ×23; `cheat` ×7; `submenu` ×6; `whenFile` and
> `cheatWhen` ×1). §5.9 has never counted it and the generated reference
> structurally cannot show it: it is not `haus.*`, so `optionAttrSetToDocList`
> never sees it, and the `data-only-surface` check that mechanises "an option
> typed `package` is invisible to a data file" has no counterpart for "a
> declaration that isn't an option at all".
>
> ★ **Second, §5.9's newest box moved under it within the hour: there is a
> fourth way for a row to be absent, the header grammar it is written in has
> three parsers that disagree about whitespace, and the two keys only haus reads
> sit behind the strictest of them.** pounce#93 (16:00:30Z, 47 minutes after
> the thirty-second pass merged at 15:13:03Z) adds `whenFile` to **both** pounce
> parsers — a file whose first line is exactly `0` vetoes the row. haus#436
> (16:09:22Z, **8 m 52 s** later, against 25 seconds for the #92/#427 pair) is
> its first and only consumer: `launcher/commands/pages.sh` declares
> `whenFile = ~/.local/state/haus/any-page` and `cheatWhen = while a page
> exists`, and `windows/scripts/workspace-mru.sh` writes that one byte on every
> workspace change. The header at `modules/launcher/default.nix:712` still
> reads *the two ways an items entry fails silently* — untouched for the second
> day running,
> and this time it is not even wrong: `whenFile` is not an items entry. **The
> frame aged, not the members.** The two shell-side columns below were RUN
> (`builtins.match` per line as the module does it, and the awk on its own
> input); the Swift column is read off `value(of:)` + `field()`, whose tolerance
> is explicit in the code and was not executed here:
>
> | a header line spelled | `CommandRegistry.swift` | `pounce-palette`'s awk | haus's `commandField` |
> |---|---|---|---|
> | `# pounce: k = v` | `v` | `v` | `v` |
> | `# pounce: k  = v` | `v` | `v` | **no match** |
> | `# pounce: k= v` | `v` | `v` | **no match** |
> | `#  pounce: k = v` | no match | no match | no match |
> | `␣␣# pounce: k = v` | `v` | no match | no match |
> | `# pounce: k = v␣` | `v` | `v␣` | `v␣` |
>
> Swift is the most tolerant and trims; the awk is next; haus's regex is
> `"# pounce: ${field} = (.*)"`, one space either side, no leading anything.
> ⚠️ **Row four said `v` in the Swift column until the assurance read ran that
> column instead of reading it**: `value(of:)` drops leading whitespace and then
> demands the literal `# pounce:`, so a second space after the `#` is read by
> *nobody* — only the indented line is Swift-only. The hedge above named exactly
> the column that was wrong and did not stop it being printed as a measurement,
> which is §5.14's opening complaint arriving inside a table this pass built to
> make a point about unchecked spellings. And
> the split of *who reads what* runs the other way: pounce reads `name`,
> `description`, `icon`, `submenu`, `whenFile`; haus reads `name`,
> `description`, `cheat`, `cheatWhen` — so **the only two keys nobody but haus
> parses are the two the strictest parser owns.** The two it shares fail loudly
> there: a `description` haus cannot parse is `null` in a string concatenation,
> and a `name` it cannot parse is `null` into `lib.splitString` unless the
> command also declares `cheat`, which is that line's fallback — both stop the
> rebuild. `cheat` and `cheatWhen` fail silently: the key box falls back to the
> name's first word,
> and the caption simply loses its ` · while a page exists`. That caption is the
> one surface whose entire job is explaining a row that isn't there — so the
> cheapest possible typo, a second space in a comment, disarms the explanation
> for the newest way to make a row vanish, on a path where nothing throws and
> the row still works. Same argument the box already makes: **the checkable half
> has no repo boundary in it.** Neither has the second half — the state path is
> a literal in two rooms (`pages.sh:6` and `workspace-mru.sh:71`), joined by a
> prose cross-reference in each direction and by nothing mechanical.
>
> ★ **Third, the previous pass's distinction held on its first test, which is
> the outcome that makes it worth keeping.** `whenFile` is *operative* — the
> declaration IS the behaviour — and it arrived with its reader in its own PR:
> `pounce doctor` names every command that declares one, the file it watches,
> and whether that file is hiding the row right now. So the three *operative*
> fields have three readers between them, and the two *descriptive*
> instances (nebelung's ports, `bar.widgets.<name>.permissions`) still have one.
> This box's own three questions — mutates? needs confirm? needs network? — are
> descriptive and are still unbuilt at pounce `0c0c3aa`. The instance count that
> bears on the box is unchanged at two, for the second pass running, while the
> room around it gained two more fields.
>
> ⚠️ **Also amended, in §5.1: `scheme = "auto"` gained a second candidate by a
> path being RETIRED.** haus#445 dropped the Stylus half of Zen's web theming,
> so the palette reaches real websites through one compiled
> `zen-userContent-<flavor>-<accent>.css` that Gecko reads once at startup —
> pinned to `theme.flavor` and to the last launch. Nothing regressed (the
> bundle it replaced was flavor-stamped too); what changed is that the fix
> stopped being somebody else's extension setting and became two compiles under
> a `@media (prefers-color-scheme: dark)` rule in a `runCommand` haus already
> writes. Whether Zen honours that in a *user* sheet is the unmeasured half, and
> it is the whole question. Written into the box.
>
> ⚠️ **And one sentence into §6(b), from somebody else's PR.** That paragraph's
> standing conclusion — the consumer *"is told nearly everything"* — is a claim
> about a printed message, and haus#435 measured what happens once the input has
> a publisher: `toJSON` escapes quotes, backslashes and three whitespace
> controls and nothing else, so `ESC` rode a desktop's own attribute names
> through `jq -r` to a raw byte, and the class line prints before the values.
> A stranger's file could repaint haus's verdict on itself. Stripped in that PR,
> and the hole predated it. Recorded in full in
> [`rooms-desktops.md`](./rooms-desktops.md)'s step-B findings; §6(b) gets the
> qualifier only: re-telling a sibling note's finding is how a pair of notes
> ends up with two copies that can then disagree.
>
> ⚠️ **For §5.14, from the tempo rather than from any one finding.** The
> thirty-second pass merged at 15:13:03Z and its subject moved at 16:00:30Z; the
> thirty-first pass's negative sentence was 66 minutes stale when it merged. Two
> passes running, §5.9 has outrun the paragraph describing it inside the hour.
> That is not a reason to check faster — nothing checks faster than 47 minutes —
> it is a reason to keep the durable half in the **box** and the perishable half
> in the pass, which is exactly the split this file already claims to run.


> **Status, 2026-08-20 (thirty-second pass) — §5.9's last box predicted that
> "the third instance will declare into the same void." The third instance
> shipped four hours after that sentence merged, with three readers in two
> repos, and it still does not discharge the box, because the box has been
> counting the wrong thing. First non-cloud pass in five, so every time below is
> a `mergedAt` rather than a committer date.**
>
> Fetched first (twenty-third pass's rule), dated at revs (twenty-fourth pass,
> row eleven): workshop `main` = `origin/main` = `c8fe4d8`, haus = `9b64840`,
> hausfold.co = `83a91c0`, pounce = `10fd02f`, holt = `564b5e6`, perch =
> `f907516`, nebelung = `d76f124`. All seven read here; none carried from an
> earlier pass, which is this pass's second finding.
>
> Landed since the thirty-first pass's revs: **ten haus PRs** (#425–#434,
> 07:55:17Z → 14:23:31Z), their **nine site mirrors** (hausfold.co #101 and
> #103–#110 — #102 IS `a231642`, and #101 merged seven minutes after it),
> **one pounce** (#92, 08:15:24Z), **two holt** (#48, #49) and four workshop
> notes commits — #411, the thirty-first pass itself, plus #412, #413 and #414,
> steps A, B and E0 of [`rooms-desktops.md`](./rooms-desktops.md). Across ten
> haus PRs the option surface gained **exactly two leaves**, diffed between
> `4e2dd61` and `9b64840`: `haus.launcher.items.<name>.workspaces` and
> `.bundleIds` — both in §5.9's room, which is where this pass ends up. 313
> options and 35 namespaces (311 and 35 last pass). `bar.items` re-derived at
> `9b64840` is **16 keys, 15 pills**, unchanged since the thirtieth pass, so the
> header line's `15 bools` is right and stays untouched for the third pass
> running.
>
> **The count is 8 at `c8fe4d8`**, re-derived with the command the last four
> passes ran (`sed -n '/^## 5\. The option families/,/^### 5.14/p'
> notes/options-roadmap.md | grep -c '^- \[ \]'`) — **and this pass adds the
> ninth**, in §5.9, from the third finding below. A pass after this one should
> find 9 and should not treat that as drift.
>
> ★ **The finding: §5.9's last box got its third instance and it doesn't count,
> because that box has been enumerating declarations when the hazard belongs to
> one kind of them.** The prediction merged in workshop#406 at 04:08:32Z
> (twenty-eighth pass). pounce#92 merged at 08:15:24Z — `items` gains
> `workspaces` and `bundleIds`, two per-item predicates deciding where a row is
> LISTED — and haus#427 mirrored both into `haus.launcher.items` **25 seconds
> later**. It arrived with three readers in two repos: pounce filters the rows
> at summon time, `pounce doctor` names every scoped item and which rows the
> current page leaves out, and haus's cheatsheet card appends `· on T` to a
> scoped row's caption (`workspaces` only — the caption has never read
> `bundleIds`). A third instance that declares into no void at all, and a box
> that stays open — which is only a contradiction until the two kinds are
> pulled apart. **Descriptive** declarations (nebelung's ports,
> `bar.widgets.<name>.permissions`) state a property; a reader is optional,
> which is why one of the two hasn't got one.
> **Operative** ones (`workspaces`, `bundleIds`) ARE the behaviour; a reader
> cannot be missing, because a missing reader means the field does nothing. The
> void is a hazard of the descriptive kind alone, this box's three questions are
> all descriptive, and all three are still unbuilt at pounce `10fd02f`. The
> instance count that bears on the box is still two, with one reader between
> them. Written into the box, with what #92 does supply: `pounce doctor` is now
> a place where a per-item declaration gets explained to a person, and the one
> surface that could read all three fields at once.
>
> ★ **Second, and it is for §5.14: a rev can be true when measured and false
> when published, and it is the NEGATIVE clause that pays.** The thirty-first
> pass lists five fetched revs and then adds *"nebelung (`d76f124`) and pounce
> (`adf03c5`) have not moved since the twenty-ninth pass, so neither of §5.9's
> two open boxes could have closed."* The five are mutually consistent with one
> read **between 07:37:15Z and 07:42:57Z** — the window opens with
> hausfold.co#102 producing `a231642` and closes with holt#48 leaving `fadebfa`
> — and `adf03c5` was pounce's head across all of it, so nothing there was
> careless. (This paragraph's first draft said "≈07:45Z", by which two of the
> five had already moved: a paragraph arguing *date it at a rev* carrying a
> falsified wall clock, caught by the assurance read.) That block merged at
> 09:21:21Z, **66 minutes** after pounce#92, and by then the sentence was wrong
> about the repo and wrong about the section.
> The asymmetry survives the excuse: a rev cited positively stays true forever,
> because it is a fact about that rev, and row eleven's "date it at a rev" is a
> complete defence. A rev spent on a negative claim has no such anchor — *"could
> have closed"* is about a section's future, and its only job is to license not
> looking. The honest form is *"no box had closed as of `<rev>`"*, which says
> less and cannot go stale. And it costs most exactly where it is spent: the one
> section that sentence excused itself from checking is the one that had moved,
> an hour earlier, with the PR its own last box predicted.
>
> ★ **Third, and it is the previous pass's ledger row recurring in somebody
> else's code — an hour BEFORE that row was written.**
> `modules/launcher/default.nix` carries the header `---- validation: the two
> ways an items entry fails silently ----` (written 2026-07-30 by rice#149 —
> the same PR §5.14's opening incident is about), over
> the two checks §5.9(b) is about. haus#427 added a third way twenty lines above
> it at 08:15:49Z and did not touch the header — 66 minutes before the ledger
> row about exactly that shape merged in workshop#411. `workspaces = [ "Q" ]` is
> an error nowhere: haus writes it, and where the recency file is readable the
> row is never listed, while on a machine that has none pounce fails open and
> lists it everywhere. Every member of the header still true, the list no longer
> complete. Two things make it a box rather than a bug report. It is uncaught
> because haus did **not** mirror pounce's matching grammar — nothing records
> that as a decision, but it is the twenty-third pass's lesson holding either
> way, and it paid off unplanned: haus#427 wrote the new field 1 h 16 m before
> the lock moved to a pounce that knew it (`3b75c7a`, 09:32Z), and nothing
> broke, because `ItemSettings.parse` ignores fields it doesn't know. **A mirror
> that enumerates breaks on the app's next addition; a mirror that only writes
> degrades.** And the checkable half was never pounce's grammar: the base
> segment of a `workspaces` entry checks against `haus._workspaces` +
> `haus._numberedWorkspaces`, which haus normalizes itself and three rooms
> already read — no repo boundary, and the identical warning (`unknownMembers`)
> is already in `modules/workspaces/default.nix`.


> **Status, 2026-08-20 (thirty-first pass) — §6(f)'s surviving scope is an
> ENUMERATION, and it has a third member that needs no strangers at all. Every
> member of it is still true, which is why spot-checking it passes. Measured
> rather than read: the sibling note's probe re-runs from this session, against
> haus's real validator.**
>
> Fetched first (twenty-third pass's rule), dated at revs (twenty-fourth pass,
> row eleven): workshop `main` = `origin/main` = `896ded7`, haus = `4e2dd61`,
> hausfold.co = `a231642`, perch = `f907516`, holt = `fadebfa`. nebelung
> (`d76f124`) and pounce (`adf03c5`) have not moved since the twenty-ninth pass,
> so neither of §5.9's two open boxes could have closed. **The count is
> unchanged at 8**, re-derived at `896ded7` with the command the last three
> passes ran: `sed -n '/^## 5\. The option families/,/^### 5.14/p'
> notes/options-roadmap.md | grep -c '^- \[ \]'`.
>
> Landed since `ffcdb0a`: **one haus commit** — `4e2dd61` (haus#424: the tiled
> popup geometry, and a phantom ⇧ swept out of five places) — its site mirror
> **7 seconds later** (`a231642`, hausfold.co#102), same-day releases in perch
> and holt, and one workshop commit that is this file's own neighbour:
> `896ded7` (#409), step E of [`rooms-desktops.md`](./rooms-desktops.md). **No
> §5 box moved.** Same cloud-session caveat as the four passes before it —
> committer dates, not `mergedAt`.
>
> ★ **The finding: §6(f) was narrowed by a fix, and the narrowing is what
> broke.** The 2026-08-14 repeal in the banner above ends *"The silent blend
> survives exactly where the model still allows two of something: two packs, or
> two raw `extraModules` fragments"*, and §6(f)'s own ⚠️ closes the same way.
> Both members are still true. The list is not complete, because both were drawn
> at the layer §6(f) has always worked at — **definitions**, two rices each
> setting a value — and the module system merges at a second layer that neither
> the seam nor the sentence ranges over: **declarations**, two modules each
> saying an option exists. `896ded7`'s probe measures it, and it re-ran clean
> here at `4e2dd61` (nixpkgs `lib` at `391b592e`):
>
> | two modules declare | what happens |
> |---|---|
> | the same leaf, both fully described | throws, naming two **store paths** and no publisher |
> | the same leaf, one of them bare (`type` only) | `sameLeafOneBare: true` — **merges, silently** |
> | different leaves under one namespace | `differentLeaves.evaluates: true` — **merges, silently** |
>
> Two things follow that §6(f) as written cannot say. **The dichotomy is not
> about the option's type**: row two is a `bool` — a scalar, the case this
> document calls "the loud failure mode" — merging without a word, because what
> disarms the throw is a missing `default`/`description`, not a list-shaped
> value. And **row three does not blend anything at all**: the probe's
> `namespaceHolds` prints `["catalog","enable"]`, `enableDeclaredBy` names only
> Ada's file, and Ben's `config` sets Ada's switch to `true`. Not two values
> combined — one author steering another's room, with the machine's own
> `declarations` naming the wrong person. That is a worse shape than the blend
> §6(f) is about, and it is the *ordinary* shape of two independently written
> rooms.
>
> ⚠️ **And the live exposure needs zero strangers, which is why this isn't
> filed under acquisition.** Both surviving members of the old enumeration need
> two third-party things, and the desktop seam bounds them (a host takes exactly
> one desktop). A module is not a desktop, so that seam does not reach here —
> and the second party need not be a person: the other claimant can be **a
> future haus release**, on a machine that installed nothing from anyone.
> ⚠️ **Step E's reading of the page is the half that does not survive being
> re-read, and this pass had borrowed it.** Step E has `rooms/creating`
> teaching the `haus.<name>` shape *and then* offering the escape hatch. At
> `a231642` the order is the other way round: the "write a plain module in
> your own config **and stop reading**" callout is at line 46, the
> `options.haus.kettle` example at line 71 — and the escape-hatch bullet above
> the callout points at `system.defaults.…`, not at `haus.`.
> (`options.haus.kettle` appears **once**, not three times; `haus.kettle` is
> what appears three times.) So the page does not invite the collision, and the
> exposure stands on the weaker footing that nothing *bounds* it — no seam, no
> check, and silence when it happens. Caught by opening the artifact instead
> of trusting the note that cites it, which is the twenty-second pass's rule
> pointed at a sibling file. The counts around it do survive: 35 namespaces and 311 options,
> identical at `ffcdb0a` and `4e2dd61` (#424 declares none), and the 35 and
> 277 step E measured one day earlier — that third one re-derived at `6ba56c8`
> by this pass's assurance read rather than by the pass. §6(f) gains the
> layer; the design that answers it is step E's, and it stays in
> `rooms-desktops.md` where the acquisition plan is.
>
> **The ledger shape, which is new (§5.14 gains it).** Every other row there
> describes an entry decaying, or an edit that never happened. This one is an
> entry that was **improved**: an open limit got a shipped seam, a pass wrote
> down what the seam left standing, and the enumeration it wrote is stronger
> than the sentence it replaced — so it can be wrong while each member checks
> out. Nothing catches it by spot-checking members; what caught it is asking
> **what the seam actually bounds** and finding a layer underneath it.
>
> ★ **§8's "Doesn't work" was right about the flakeref and wrong about GitHub,
> and this pass measured both ends.** `nix flake metadata github:NixOS/nixpkgs`
> 403s here exactly as §8 says — the body is the proxy's `add_repo` message. But
> `nix flake metadata git+https://github.com/numtide/flake-utils` **resolves**,
> third-party org and all (rev `11707dc2`). The gate is **api.github.com**, not
> github.com: a `github:` flakeref goes through the API, and `git+https` is the
> same anonymous git read the proxy already serves for the "read every repo at a
> rev" bullet — which was never restricted to our org, only ever tested there.
> What it buys is what this pass used: nixpkgs' pure `lib/` in one 15 MB sparse
> clone, and haus's own `modules/lib/desktop.nix` through `lib.evalModules` —
> its **real** validator over its real registry, in seconds, on Linux.
> *(Reasoning, not a measurement: this does not put `nix flake check` in reach.
> haus pins all nine of its inputs as `github:`, so a full eval needs every one
> rewritten, and its darwin half is out regardless.* ⚠️ *Nor is flake-utils'
> printed `systems` input evidence that transitive `github:` refs resolve —
> `flake metadata` reads that from the committed lock rather than fetching it.)*
>
> ★ **A shipped answer to "which display is this" is borrowed by three rooms
> and USED as a selector by none.** §5.10's `haus.displays` ships a vocabulary
> built for this question — `internal`, `main`, `<uuid>`, most-specific-wins,
> with `hausdisp list` printing the UUIDs. Grepped at `4e2dd61`, three rooms
> do reach for it, and not one of them to name a display: `appearance`,
> `launcher` and `focus` cite `haus.displays.*` in option **descriptions**,
> and `focus/focus.sh:45` shells out to the room's **binary** for a screen
> count — deliberately without depending on the room, as its own comment says
> (`system_profiler` is the fallback). The helper is reused; the vocabulary is
> not. Meanwhile two rooms answer the same
> question with the literal string `"Built-in Retina Display"`: `windows`, in
> **six** rows of the generated `aerospace.toml` — four written into the
> template and two more by `monLine` (`default.nix:339`) at render, which is
> the difference between reading the generator and reading the artifact — and,
> new in #424, `terminal`, at `float-term.sh:233`, where a popup's geometry
> turns on `name === "Built-in Retina Display"`. They are not even the same
> test, and the code says so: AeroSpace treats its monitor key as a **regex**,
> float-term as `===`. For this document the point is not the divergence, it is
> that **the gap numbers ride `haus.ui.scale` — a publishable option a desktop
> sets — while the column they land in is a product-name literal.** A desktop
> is portable; its gap selector is not.
> ⚠️ **And it sharpens §5.10's open box, which points the tester at the wrong
> setup.** That box says multi-display is untested because only one display was
> attached, and sends the reader to *"test on the dock"*. The failure above is
> **identity, not arrangement**: it reproduces on **one** display, on any Mac
> whose built-in panel reports a different `localizedName` — no dock, no second
> monitor. A box whose stated setup is more expensive than its cheapest
> reproduction is a box nobody runs the cheap half of. *(What the mechanism is,
> is measured — both spellings are in the files at `4e2dd61`. Which Macs
> actually diverge is not, and cannot be from here; `hausdisp list` settles it in
> one command on the machine.)*
>
> **Two smaller things, both about #424.** It is a **second instance of the
> twenty-eighth pass's ledger row** — a true fact read as an impossibility: *"a
> terminal mouse report has no bit for ⌘"* is true, and governs what the
> *program* can see, while Ghostty consumes the ⌘-click before anything is
> forwarded. The ⌘⇧ spelling it produced had spread to five places in haus plus
> the published page. Worth recording because the row's stated mitigation didn't
> apply: nobody asked what it would cost to do it ourselves, they asked **who
> acts first**. And the negative the thirtieth pass would have wanted: **the
> workshop carries no copy of it this time** — unlike ⌃⌥⇧A, which it was the
> last repo still documenting. Checked the way row ten demands, by reading
> around the hits rather than counting them: `⇧` appears five times in tracked
> files — two keymap-syntax mentions here, and three epitaphs for the retired
> chord (this file, `AGENTS.md`, `docs/workflows.md`) — and none of them is
> about the mouse. ⚠️ **That count was true at `896ded7` and this paragraph
> spoils it**: the block you are reading adds four more `⇧`, so re-running the
> check from HEAD says nine. The thirtieth pass records the same hazard about
> its own `16 bools` grep one block below; a check whose subject is a
> character this file writes is single-use by construction, and the rev is
> what makes it re-derivable at all.
>
> ⚠️ **What this pass's own assurance read killed, because two of them are
> ledger rows the block above cites.** First, row ten again, from the paragraph
> that invokes row ten: *"no other room references `haus.displays`"* was a
> negative proved by a grep over two rooms' files and stated over all twelve.
> Three rooms do reference it — the finding survives because none of them uses
> it to NAME a display, which is the claim that was worth making and is not the
> one that got written. Second, the `rooms/creating` reading above, borrowed
> from step E and falsified by opening the page. And third, `AGENTS.md` carried
> §8's wrong gate in the file every agent in this family reads — *"needs an
> environment whose network policy allows general `github.com` egress"* — while
> this session had been cloning github.com all afternoon. **Fixed in this
> commit**, which is the check the ⇧ paragraph above runs on somebody else's
> correction and this pass had not run on its own.


> **Status, 2026-08-20 (thirtieth pass) — §5.9's count went DOWN for the first
> time, and the correction that was supposed to raise it two days ago was never
> made, so the sentence on the page is right today by accident. The
> twenty-ninth pass's hand-written generated file held against the next copy of
> it, which is the most this session can measure.**
>
> Fetched first (twenty-third pass's rule), dated at revs (twenty-fourth pass,
> row eleven): workshop `main` = `origin/main` = `a535fc1`, haus = `ffcdb0a`
> (tagged `v2026.08.20`), hausfold.co = `2e4cfd1`. nebelung (`d76f124`,
> 08-16) and pounce (`adf03c5`, `2026-08-19T04:33:25Z` — 08-18 only in the
> author's timezone, which is what row eleven is about) have not moved since
> the last pass, so neither of §5.9's two open boxes could have closed.
>
> Landed in haus since `da94efd`: **four commits in 27 minutes**
> (06:09:13Z → 06:36:37Z, the first landing 24 minutes after `da94efd`) — an
> input bump (`59dca7a`, perch + holt), haus#422 (`206bc0e`), a whitespace-only
> commit (`df8b269`) and the day's release
> (`ffcdb0a`, `VERSION` alone). **No §5 box moved**, and the count is
> unchanged at **8**, re-derived at `a535fc1` with the command the last two
> passes ran: `sed -n '/^## 5\. The option families/,/^### 5.14/p'
> notes/options-roadmap.md | grep -c '^- \[ \]'`.
>
> Same cloud-session caveat as the twenty-eighth and twenty-ninth passes —
> committer dates, not `mergedAt`, because only the workshop is an attached
> repo. One thing worth writing into §8 rather than rediscovering: **`add_repo
> hausfold/haus` does not attach it.** It answers `read_available` and explains
> that the proxy already serves anonymous reads of a public repo, so nothing is
> attached and the GitHub API tools stay closed — which is the half a pass
> wants. From here you can read what a commit says and what its diff contains,
> and you cannot read whether a check went green.
>
> ★ **The finding, and it is the ledger's own subject caught in the act: a
> correction that reports itself as applied.** The twenty-seventh pass found
> §5.9's "closed submodule of 15 bools" stale (haus#396 added the `page` pill)
> and wrote, in the paragraph directly beneath it, *The header line's "15 bools
> (13 when this was written)" reads **16 (13 when this was written)** now.* It
> does not. The line has said 15 since it was written, and `f449cc9`'s only hunk
> in that region — `@@ -3778,6 +3880,14 @@` — **does not touch that line at
> all**: its nearest context is the re-derivation parenthetical three lines
> below, and the only `15 bools` anywhere in the diff is the quotation inside
> the correction being added. The pass wrote what the line now reads without
> reading it. Every shape in §5.14's table so far is an entry *decaying* while
> nobody looks; this one is an edit that exists only in the prose announcing it,
> and it is worse than the stale number it describes, because a reader who
> checks the paragraph against the line sees them disagree and believes the
> newer one. Caught by grepping the file for the string a correction quotes as
> its **result** — the same act as reading the artifact rather than its
> generator (twenty-second pass), pointed at this file instead of at a repo.
> ⚠️ **Two hedges the assurance pass insisted on, both fair.** The sentence
> parses two ways — *the line has been changed*, and *the right value is now 16*
> stated without rewriting anything — and the finding survives either, because
> no reader can tell which and the checkable half says 15. And `git log
> -S'16 bools' -- notes/options-roadmap.md` was confirmation only **before this
> commit**: the pass has now put that string in the file twice, so the check
> that caught it no longer works from HEAD. A grep-shaped check spoiled by the
> prose that cites it — the twenty-second pass's blind spot, arriving from
> inside the document.
>
> ★ **And then the number healed on its own, which is the part worth carrying.**
> haus#422 removed `haus.bar.items.page` and `haus.bar.bottom.items.page`
> (`206bc0e`, 06:09:31Z), so the same command the twenty-fourth, twenty-seventh
> and twenty-eighth passes ran now says **16 keys, 15 pills** — the count the
> page has carried all along. The unmade edit had a window of exactly **1 d 21 h
> 33 m** in which it was right (haus#396 `mergedAt 2026-08-18T08:36:08Z` →
> `206bc0e`), and applying it today would be applying a correction backwards.
> **A stale number can come back**, and nothing in §5.14 expects that: every
> mitigation in it assumes decay is monotonic and a re-derivation is a repair.
> The measurement is over the life of the `haus.bar.items.*` namespace — the
> committed artifact dates to 2026-08-09 (`33b5d63`) and the namespace to the
> rooms rename: 16 from `653d834` (2026-08-16), 17 from haus#396 (`a49a48d`),
> 16 again at `206bc0e`. Two days of drift is also two days in which nobody
> read the page, which is the honest reading of why the unmade edit cost
> nothing.
>
> ⚠️ **The box's own argument is what actually broke, not the number.** The
> sentence says the submodule "grows by one every time a pill lands", and this
> is the first time it shrank — `page` was not deleted. It was promoted OUT of
> the item list: a page is a property of the workspace you are on rather than a
> movable readout, so it sits in the menu bar's left group and is gated by
> `haus.windows.enable` through `$BAR_PAGES`, the way gravity already was. So
> `bar.items` counts **placeable** pills, and a pill can leave it by becoming
> more load-bearing rather than less. A count recruited as evidence for "this
> submodule is closed and it keeps growing" turns out not to be a measure of the
> bar's surface at all, which is the twenty-eighth pass's "the number has stopped
> being the argument" arriving with a mechanism.
>
> ★ **The twenty-ninth pass hand-wrote a generated file and a second, independent
> copy of the same directory agrees with it — which is the most that can be
> measured from here.** That pass regenerated `docs/site-data/` by hand and said
> in as many words that `site-data-current` would accept or refuse it on its
> own. haus#422 rewrote the same directory 24 minutes later — that *its* copy
> came from the generator is the commit's shape and not something the repo
> states — and the key-level diff between `da94efd` and `206bc0e` contains
> **only** #422's own subject: two keys removed
> (`bar.items.page`, `bar.bottom.items.page`), one added
> (`terminal.restoreWindows`), and four descriptions changed
> (`ai.default`, `ai.enable`, `bar.widgets.<name>.interval`, `keys.windowNav`),
> each traceable to a hunk in that commit's own `modules/**/options.nix`.
> Nothing else moved, so the hand-made copy carried no error for the second one
> to absorb. **The generalisable half: hand-writing a generated artifact is safe
> exactly when a check builds the generator somewhere you don't control** —
> `site-data-current` is one of the twelve portable checks haus's `check.yml`
> runs `nix flake check` over on a Linux runner, so a refusal would have arrived
> from GitHub rather than from either author. A hand-made generated file with no
> such check is not a guess with a check behind it; it is just a guess.
>
> ★ **§8's formatting trap grew its first recorded instance, from the pass that
> followed §8's advice.** `df8b269` — *"`nix fmt` had never run on #422 or #423.
> focus's whole `lib.mkIf cfg.enable` body sat two columns short; terminal's
> `replaceStrings` call had been hand-wrapped across three lines where the
> formatter wants one."* §8 tells a cloud session to match the surrounding style
> by hand precisely because running the formatter would bury the change, and the
> twenty-ninth pass did exactly that and produced **one of the two** files
> `df8b269` swept — `modules/focus/default.nix`; the other is haus#422's own
> `replaceStrings` rewrap — at the cost of a follow-up commit half an hour
> later. The advice protects the **diff** and does not protect the **file**, and
> the difference had never been written down. §8 gains
> the fix, which is one command and a separate commit; the reasoning about *why
> §8's own recipe cannot catch this* is in §8, marked as reasoning.
>
> ★ **The workshop was the last repo in the family still documenting a chord
> that no longer exists, and this pass fixed it here.** haus#422 retired ⌃⌥⇧A —
> the resident in-place agent — along with the palette's **Agent Here** row and
> `modules/launcher/commands/agent-here.sh`; `c` in the window's own shell is
> the same act, one keystroke shorter, and follows `haus.ai.default`
> identically. hausfold.co#94 took it out of three — two room pages and the
> generated reference — **18 minutes later**. The workshop's own `AGENTS.md`
> still described it twice, and `docs/workflows.md` once, 45 minutes later —
> fixed in this commit.
> ⚠️ **The mechanism this paragraph first offered was false, and the assurance
> pass killed it.** It read *"the site is swept on a schedule (`/docs-sync`) and
> `AGENTS.md` is swept by nobody"* — but `/docs-sync` names agent instructions in
> its scope (`.agents/skills/docs-sync/SKILL.md`, and its reconcile table lists
> the workshop's own `AGENTS.md` as a target), so the file is swept on exactly
> the cadence the site is. What 45 minutes measures is a **targeted PR beating a
> sweep**, not an unswept file: someone edited the site because they were
> changing the site, and the workshop waits for a routine. A negative claim
> asserted without running the check, in the pass that added a ledger row about
> exactly that.
> The same commit amends the `zmx` sentence beside it, which survived #422 by
> luck: a restarted window comes back to its scrollback because of a restore
> path that shipped in that same `206bc0e` and is an option
> (`haus.terminal.restoreWindows`), not because a new window happens to land on
> a parked session — which is the bug #422 fixed.
>
> ★ **One cross-repo ordering rule, learned in hausfold.co#98 and belonging in
> §7.** That PR is the docs half of §5.8's daemon and it deliberately did NOT
> regenerate `options.mdx`: the site's `options-drift` check renders the page
> against **haus's default branch**, so a render carrying options that exist
> only on a haus PR branch fails the site's CI until that PR lands. §7 already
> records the mirror image from the code side (a haus change consuming a new
> nebelung output can't carry its own lock bump); this is the same constraint on
> a generated *document*, and the answer is the same shape — describe the
> feature in the PR, let the regeneration job own the artifact — which ran on
> demand here rather than on its Monday cron, 22 minutes after haus#423.


> **Status, 2026-08-20 (twenty-ninth pass) — a shipping pass, not an audit: the
> last Phase-5 item that needed code is built, merged before the pass landed,
> and this file dropped a number rather than fix it.**
>
> Two things asked for, both done, and neither is a §5 box moving.
>
> **First, the naming banner's "for six weeks" is gone** — dropped, not
> corrected, four passes after the twenty-fifth flagged it. The reason it could
> never be fixed is the useful half: the interval was measured from the wrong
> end (this file dates itself 2026-07-25, three weeks before the rename) and its
> right end lives in the "earlier brainstorm" this document refines, which is
> not in the repo and whose first `focus` nobody has. **An interval no one can
> re-derive is worth less than the claim without it.** The banner now makes the
> claim with no number and says in place that it used to carry one. The one
> sentence that depended on it — "the dialect the banner credits for being six
> weeks early", in the **twenty-fourth pass's** block rather than in §6(b),
> which is where its subject lives — is re-pointed at what the banner actually
> credits. Deleting the number
> silently was the other option and it is the shape this ledger exists to catch.
>
> **Second, §5.8's trigger daemon is BUILT** — `haus.focus.scenes.<name>.when`
> plus `focus auto`, in haus#423, with its docs half at hausfold.co#98.
> The box stays `- [ ]` and the count below is unchanged at **9**, because
> neither PR is merged: the twenty-fifth pass's rule (*a PR number inside a
> `[x]` is a promise; only `mergedAt` keeps it*) is the one rule in this file
> that was written by tripping over it, and a shipping pass is exactly when it
> is tempting to break.
> ⚠️ **haus#423 merged at `2026-08-20T05:45:03Z` (`da94efd`), six minutes after
> this paragraph was written**, so the box is ticked, the header and Phase 5's
> line moved with it, and the count is **8**. The paragraph stands as written
> because it was true when written and the rule it names is what decided when to
> change it — which is the whole difference between this and the twenty-fifth
> pass's ticked-while-open box. Re-derived, not adjusted:
> `sed -n '/^## 5\. The option families/,/^### 5.14/p' notes/options-roadmap.md
> | grep -c '^- \[ \]'` — **8**. Re-derived, same command as last pass:
> `sed -n '/^## 5\. The option families/,/^### 5.14/p' notes/options-roadmap.md
> | grep -c '^- \[ \]'` — **9**, unchanged from `020b1ce`.
> ⚠️ **That rev is not the one the twenty-eighth pass quoted.** It cites
> `5421e3d` twice, and `git cat-file -t 5421e3d` says *Not a valid object name*
> — almost certainly the pre-squash hash of the pass's own commit, which landed
> as `020b1ce` (the count there is 9, re-run). The number was right and the
> citation isn't checkable, which is the twenty-fourth pass's *date it at a rev*
> rule failing in the one place nobody re-runs: **a hash a squash-merge renamed
> looks exactly like a hash you can trust.** Cite the merge commit, or a PR.
>
> ★ **The finding is about the sketch this file has carried since July, and it
> is a good outcome rather than a drift one: the four triggers it named — time,
> Wi-Fi SSID, power source, display attach — all shipped, and the fifth item on
> that list was never a trigger at all.** "Pounce command" sat in the same
> sentence as the other four from the first draft, and building the daemon is
> what showed it is a different kind of thing: a palette row that enters a scene
> is a PERSON pressing something, and it has existed since haus#381 without
> anyone counting it. A list that mixes *conditions the machine can observe*
> with *ways a human can ask* reads as one list for a year and then costs a
> design conversation on the day someone implements it. **§5.14's shapes are all
> about a claim going stale; this is a claim that was never one claim.**
>
> ★ **The assurance pass found the design's real hole, and it is a shape worth
> carrying: a rule that is conservative in one direction is not conservative.**
> The daemon's probes answer `""` for "I could not tell", and the first draft
> made that mean "does not hold" — which is careful on the entering side and
> the exact opposite on the leaving side, because macOS reports no Wi-Fi
> network during sleep/wake and the display count under-counts while monitors
> re-negotiate, both of which launchd's timer lands directly on. One blank read
> would have left the scene and the next re-entered it: hooks off then on, the
> caffeinate hold dropped and retaken, and with `apps.closeOnExit` **the apps
> quit and relaunched** — OBS, mid-recording, on the room's own example scene.
> The fix is a third answer (*holds* / *definitely does not* / *cannot say*),
> and the generalisable half is the question: **a predicate used in both
> directions needs its unknown case decided twice, once per direction.** Two
> more in the same read, both the same shape as findings this file already
> carries: the leave path had no "spend the edge first" guard while the entry
> path's own comment explains why it needs one, and ownership tracked by scene
> NAME made a hand off-then-on inside one interval invisible — the headline
> promise, false in a window exactly one tick wide. All fixed, each with a test
> that fails without it.
>
> ⚠️ **And one correction this pass owes §5.8's own sketch:** the section
> proposed the daemon as the thing standing between the room and "done", with
> the reachability gap as a detour. Backwards, and the gap between the palette
> rows landing and the first feel-test proves it — **2 d 13 h**, haus#381
> `mergedAt 2026-08-16T20:10:48Z` → haus#408 `6510aa6` 2026-08-19T09:50:02Z, and
> that is elapsed rather than the calendar subtraction this same block corrects
> two paragraphs up. What those two days produced is `apps.closeOnExit`: a scene
> that opened OBS and left it running on the way out, which nobody notices until
> a person enters and leaves the same scene by hand a few times. (The palette
> rows are **not** an example of that — haus#381's own body says "found while
> building scenes", and Phase 5's line already said so; using a scene and
> building one are different weeks.) The deferral was right for a reason its own
> box never states: **the precondition wasn't "is a scene useful", it was "has
> anyone used one enough to find the bugs".**
>
> **Verified, and the split matters more than usual because this pass wrote
> code from a cloud container:** `test/focus-auto.sh` runs the real engine
> (built by the same substitutions `default.nix` makes, not a copy) against
> stubbed probes and a fake clock — **65** assertions, green, covering the edge
> story in both directions, manual override of both kinds, a one-tick handover,
> the midnight wrap, all three probed facts, the `system_profiler` fallback, a
> scene deleted mid-flight, and **four** regression tests, each one verified to
> fail with its own fix reverted (which is the only thing that separates a
> regression test from a decoration). `shellcheck --severity=warning` clean at
> 0.11.0; CI gains the lint and
> the suite (`grep -cE '^assert_eq |\|\| fail ' test/focus-auto.sh` is where the
> number comes from). **Not verified, and named in the PR rather than buried:**
> nothing ran on a Mac — the probe reads (`pmset`, `networksetup`,
> `hausdisp`/`system_profiler`) are exactly what `focus auto --probe` checks in
> one command — no Nix evaluated anything (§8's ceiling, unchanged),
> and `docs/site-data/` was regenerated **by hand**, which `site-data-current`
> will either accept or refuse on its own. A hand-made generated file is a guess
> with a check behind it, which is the only reason it was worth making.

> **Status, 2026-08-20 (twenty-eighth pass) — §5.9's oldest unbuilt box closed,
> and the layer shipped it with its five field names unchanged off this file's
> own July sketch. Three other claims were falsified — one of them written
> three days earlier — and the pass's own finding is the twenty-seventh's, a
> day later and inside a single repo.**
>
> Fetched first (twenty-third pass's rule), dated at revs (twenty-fourth pass,
> row eleven): workshop `main` = `origin/main` = `1960252`, haus = `148c303`.
> ⚠️ **The timestamps below are merge commits' committer dates read out of a
> clone, not `mergedAt` off the API** — this pass ran from a cloud session,
> where only the workshop is an attached repo and the rest of the family is an
> anonymous git read (§8 gains a line for it). For a squash merge the two are
> the same instant; the rev is the half that stays checkable, which is the
> twenty-fourth pass's rule arriving as a constraint rather than a discipline.
>
> Landed in haus since `dc86913` (#400, 2026-08-19T06:00:30Z) — seventeen PRs
> in twenty-one hours (21 h 16 m, `dc86913`→`148c303`), plus four
> flake-input bumps:
> #401 (zellij gone), #402 (the AI room owns its payload), **#403 and #405,
> which are already recorded here** — ticked on 2026-08-19 by two single-purpose
> notes commits (`0257e30` §5.2's motion, `77f23ed` §5.6's tenth group), not by
> a pass; #404 (below), #406/#409/#412 (bar and terminal fixes), #407 (CI),
> #414 (the third naming rule, whose record is [`rooms-desktops.md`](rooms-desktops.md)),
> #408 and #413 (focus, below), #410 (the free-key validator's diagnostic),
> #411 (jcode dropped), #415 (a lane stops needing the tiler), #416 (below),
> #417 (below).
>
> Elsewhere in the family, and split by whether this file has actually read it,
> because the first draft of this line waved the lot past as already-read:
> **read by the last pass** — pounce#89/#90, holt#43–#46, hausfold.co#72–#78.
> **New since `f449cc9` (2026-08-19T06:19:48Z) and read here** — holt#47
> (`f48d8fc`), perch#78/#79, and **fourteen** hausfold.co PRs, #79–#92, five of
> which are the documentation half of exactly what this pass audits: #83
> (writing your own pill), #84 (`apps.closeOnExit`), #86 (what a shared desktop
> may do with each option, which renders `widget-entries`' rule sentence), #91
> (lanes without the windows room) and #92 (the Zen callout carrying both
> routes). Waving a docs repo past as already-read is how docs drift survives an
> audit, so the split stays in the format.
>
> **One §5 box closes.** [haus#404](https://github.com/hausfold/haus/pull/404)
> (`0dec9e8`, 2026-08-19T08:34:54Z) makes `haus.bar.items` sugar over an open
> `haus.bar.widgets.<name>` — §5.9's first box, and the commit says so by
> number. The sketch below it, written in July, shipped with its five field
> names unchanged. Details in the box; the header and both §6 phase lines move
> in this same edit, per the fourteenth pass's rule.
>
> **Three closed claims falsified, all shape 2, none of them by a PR that knew
> this file existed:**
>
> - **§5.1's Zen paragraph.** "Real sites are **Stylus's** job" is retired by
>   [haus#416](https://github.com/hausfold/haus/pull/416) (`d6e8622`,
>   2026-08-20T02:53:14Z): `haus.zen.userStyles` compiles nebelung's userstyles
>   at build time into the `userContent.css` the layer already places, so the
>   accent reaches github.com with no extension and no import click. The
>   supporting clause — the accent var lives in the extension's storage — is
>   still true, and that is what makes it a new shape: **a true premise carrying
>   a false conclusion, because the premise is about one mechanism and the
>   conclusion was about the whole space.** New row on §5.14's table.
> - **§5.8's "exactly the six fields".** Seven since
>   [haus#408](https://github.com/hausfold/haus/pull/408) (`6510aa6`,
>   2026-08-19T09:50:02Z) added `apps.closeOnExit`; eight leaves with
>   `description`, re-derived from `options.json` at `148c303` rather than read
>   off the commit.
> - **§5.8's reachability ✅, three days old** (haus#381 `mergedAt
>   2026-08-16T20:10:48Z` → haus#413 `82894a4` 2026-08-20T00:22:41Z = 3 d 4 h;
>   it reads as "four days" only if you count calendar dates, which row eleven
>   is about). It cites
>   `modules/launcher/default.nix:224` reading `config.haus.focus.scenes`;
>   [haus#413](https://github.com/hausfold/haus/pull/413) (`82894a4`,
>   2026-08-20T00:22:41Z) made Focus *contribute* the pill and the palette rows
>   instead of being read, so the launcher reads `_contrib.launcher.focus` at
>   `:260-261`. The outcome the box wanted is intact and the sentence describing
>   it is wrong twice: the read is gone and the line number moved. **A file:line
>   in prose is a mirror of another file's formatting** — last pass's finding,
>   in prose, where no guard can fire.
>
> **The pass's own finding, and it is that same coupling costing CI just under
> three hours:**
> haus#410 reworded the free-key validator's diagnostic and the golden table in
> `flake.nix` kept the old wording, so `desktop-seam` was red on main from
> `8a6b9d6` (2026-08-20T00:21:37Z) until #417 re-synced it by hand at `148c303`
> (03:16:21Z). The twenty-seventh pass asked *what in the upstream am I matching
> that isn't the thing I care about?* of a mirror **across a repo boundary**;
> this is the same question with "upstream" meaning the file next door. Filed in
> §5.14 as a candidate, not a check: pinning a validator's predicate instead of
> its prose is one line of judgement per golden table, and nobody has swept them.
>
> **Not a §5 item but worth the line, because §6's readiness test is about
> non-dev machines:** haus#415 removed the assertion that `haus.ai` needs
> `haus.windows`. What actually wanted a tiler was placement and the
> window→session join, and the join has a second spelling now (Ghostty's own
> scripting API), so a lane works on a machine with no window manager. One fewer
> room dependency is one fewer thing a `writer` desktop has to inherit to get an
> unrelated feature.
>
> **What's left, in one place — nine open boxes across §5.1–§5.13, down from
> twelve, and eight of the nine are live** (the ninth is struck through as
> superseded). Basis, because the last two attempts at this number had none:
> markers at the start of a line, between `## 5.` and `### 5.14` —
> `sed -n '/^## 5\. The option families/,/^### 5.14/p' notes/options-roadmap.md
> | grep -c '^- \[ \]'` — **9** at `5421e3d` against **12** at `05699f7`, the
> twenty-sixth pass's own commit. Three closed in between, all three recorded in
> this file: `0257e30` (§5.2's `motion`), `77f23ed` (§5.6's tenth group) and
> haus#404 above.
> ⚠️ **That pass's "eleven" was an enumeration, not a count**, and it said
> "counted as the literal `- [ ]` markers in §5" — a literal count of its own
> file gives 12, 13 or 17 depending on whether prose quotations and §5.14 are
> in, and none of them is eleven. So the honest delta is 12 → 9, not 11 → 10,
> and reporting it the second way would have made three closed boxes look like
> one. The fifth pass's rule — *quote the command that produced a count* — has
> been in this file since 2026-08-06 and this is the first time it has been
> turned on one of these passes' own headline numbers.
> The twenty-sixth pass's three-way split survives, and one of its three buckets
> has emptied:
>
> - **Code:** §5.9's two remaining boxes, both pounce's — command packs, and
>   command metadata, where the schema question is now answered twice over and
>   what's missing is a **reader**; §5.1's `flavor = "custom"` + `theme.palette`;
>   §5.3's app-side `sans` across pounce/perch/trill, still needing a config
>   seam before it needs a font; §5.8's trigger daemon, still deliberately
>   behind its own "one hand-written scene proves useful" precondition — and
>   better equipped to meet it than at the last pass, since a scene now has a
>   palette row, a cheatsheet line, `apps.closeOnExit` and a `focus` binary on
>   `PATH`.
> - **Tests nobody has run, 👤:** §5.5's non-QWERTY claim (`windowNav =
>   "ctrl-alt"` exists; untested on real AZERTY or Dvorak hardware) and
>   §5.10/§5.13's docked multi-display validation, which gates any
>   `profiles.docked` design. Neither has moved, and neither can move from a
>   keyboard this machine doesn't have.
> - **Deferred on a reason — this bucket is now empty.** §5.6's Windows row and
>   the two logout-only halves inside shipped groups (`lock`'s login half,
>   `security`'s guest half) all landed on 2026-08-19 in haus#405, on a third
>   fact table (`modules/lib/login-map.nix`) that renders the wait into each
>   option's own description instead of changing anything about the domains.
>   What stays deliberately unbuilt there is not a box: remote login, which is
>   not a `defaults` key at all.
> - **Not work, and worth saying so where a reader counts boxes:** §5.1's
>   `scheme = "auto"` is `◐` on a design answer — per-tool rather than
>   everywhere at once, with ghostty the one tool left — so re-opening it is a
>   decision, not a backlog item; and §5.5's `~~Split windows.enable~~` is
>   superseded by `keys.leader = "none"` / `keys.windowNav = "none"`, kept
>   struck through rather than deleted so the reasoning survives.
>
> **Verified**, from the repos' side (a workshop worktree can't build the
> layer), all at haus `148c303`:
> `jq -r 'keys[]' docs/site-data/options.json | grep -cE '^haus\.bar\.items\.'`
> = 17 → 16 pills once `claudeUsage`'s deprecated alias is dropped, unchanged
> from last pass; the same query for `^haus\.bar\.widgets` = 7 keys, which is
> **six leaves under one container** and not the "seven new leaves" #404's own
> body claims — the difference between a key list and a leaf count, which is
> the fifth pass's rule applied to a number this file was about to inherit;
> `^haus\.focus\.scenes\.<name>\.` = 8; and each of the ledger's seven check
> names looked up in `flake.nix` — all seven present, none renamed, in a file
> that now declares 26 `runCommand` checks rather than 25
> (`git show 148c303:flake.nix | grep -c runCommand`; the same command returns
> 25 at `6ba56c8`, the rev the last pass read). The jcode withdrawal
> the twenty-sixth pass flagged as "all four in review, confirm on `mergedAt`"
> is merged four for four: haus `656726a` (#411), holt `f48d8fc` (#47),
> hausfold.co `262a10f` (#85), workshop `8e82bf8` (#401). No rebuild is owed —
> this pass changes no layer.

> **Status, 2026-08-19 (twenty-seventh pass) — no §5 box moved in three days,
> and the two things that DID move are both shape 2: a format this file cites
> six times was retired, and a check the ledger counts by name was renamed.**
>
> Fetched first, per the twenty-third pass's rule: workshop `main` =
> `origin/main` = `021edb5`, haus = `6ba56c8`, and every claim below is dated at
> a **rev**, not a day (twenty-fourth pass, row eleven). Landed in haus since
> workshop#391: haus#386 (the app-pack format retired, `mergedAt
> 2026-08-17T06:36:00Z`), #388/#389 (lanes are zmx windows), #390 (CI ceilings),
> #391 and #392 (the FDA-escape spikes, 08-18T06:19:47Z / 06:52:54Z), #394–#397
> (the lane chord, the `page` pill, the pointer zoom), #398 (caps → f), #399
> (the zmx 0.7.0 parse, 08-19T05:49:24Z); plus pounce#89/#90, holt#43–#46,
> hausfold.co#72–#78, and the workshop's own #392–#396 (the MDM note, and
> `bench`'s cache-lag retry).
>
> **Nothing here closes a §5 box.** The eleven the last pass counted are still
> eleven, and the three-way split it drew — code / 👤 tests / deferred on a
> reason — survives unchanged. What this pass does is repair four claims the
> repos falsified, all found by reading commit bodies rather than diffing the
> checkbox list:
>
> - **The pack format is gone (haus#386).** `haus.lib.pack`, `checkPack`,
>   `checkRice`, `riceBody` and `packFiles` came off the public surface, leaving
>   exactly two shareable things — a **desktop** (data, closed schema,
>   `lib.checkDesktop`) and a **room** (code, an ordinary module), one format per
>   trust class. §3.3's last box cited `checkRice` as a shipped deliverable and
>   now cites a function that does not exist; amended in place. The word `packs`
>   survives *only* in its non-shareable sense —
>   `haus.apps.packs.<name>.enable` and `modules/apps/packs/writing.nix` are
>   untouched — so every "pack" below is a **collection inside the Apps room**,
>   never a thing a stranger publishes. That is the §5.14 shape the banner was
>   built for, arriving a third time: a surviving word whose sense moved.
> - **The `packs` check is `app-collections` (same PR), and the ledger names it
>   by the dead spelling** — the seventh pass's exact error, which the
>   twenty-second pass caught by re-deriving the roster from `nix flake check`
>   and which has now recurred within four passes. Re-derived again here from
>   `flake.nix` at `6ba56c8`: `data-only-surface`, `accent-reach`,
>   `app-collections`, `fragment-compat`, `scale-reach`, `font-reach`,
>   `pounce-item-grammar` — **seven checks, unchanged in number**. It also
>   changed platform: `app-collections` moved inside the darwin-only block, so
>   the "runs on Linux CI" property `packs` had is gone. A rename that keeps
>   the count and loses the platform is worse than one that loses both, because
>   the number the ledger quotes stays right.
> - **`pounce-item-grammar` took a fourth prefix and a fifth shape** —
>   `setting:<pane>[?<anchor>]` (pounce#90 → haus#399) — and the check **could
>   not report it**: pounce's error literal is built by `+` concatenation and
>   wrapped once it grew a fourth shape, so the grep matched nothing, the diff
>   came back empty, and the don't-delete-this-check guard spoke instead. The
>   twenty-third pass filed this mirror as reason 1's answer; what it now also
>   demonstrates is the failure mode of reading another repo's *source*: **a
>   mirror that greps a literal is coupled to that literal's FORMATTING**, and a
>   line wrap is not a semantic change on either side. The guard firing is the
>   check working — it refused to go green empty — but it named the wrong
>   problem, and the second cause hid the first for a day of red CI on main.
> - **§5.9's re-derived pill count is 16, not 15** (haus#396's `page` pill,
>   08-18T08:36:08Z). The twenty-fourth pass re-derived 15 and wrote "a count
>   that stays true does so only with its scope attached"; two days later the
>   scope held and the number didn't. Both are amended in place, with the
>   `jq` re-run at `6ba56c8`. This is the box's own argument landing on it: the
>   submodule grows by one every time a pill ships, which is why `bar.widgets`
>   is the open box it is.
>
> **The one new candidate for a check**, phrased to be asked of any mirror:
> *what in the upstream am I matching that isn't the thing I care about?*
> `pounce-item-grammar` cares about a list of prefixes and matches a sentence's
> punctuation. The generalisable fix already shipped inside it — flatten the
> source first — but the question is the reusable half, and it is the sibling of
> the twenty-third pass's "which dimension of this copy did I decide was
> closed?".
>
> **Verified from the repos' side** (a workshop worktree can't build the layer):
> `jq -r 'keys[]' docs/site-data/options.json | grep -cE '^haus\.bar\.items\.'`
> = 17 keys → 16 pills once `claudeUsage`'s deprecated alias is dropped;
> `grep -n checkRice flake.nix` at `6ba56c8` returns one hit and it is a comment
> saying the function is gone. ⚠️ **And one caveat on the roster below, found by
> this pass's assurance read: the seven are not `flake.nix`'s check list.**
> `flake.nix` declares **25** `runCommand` checks at `origin/main`; the ledger
> has always counted the subset that *encodes a ★ finding from this file*, which
> is a judgement no grep makes — `room-registry`, `keymap`, `desktop-seam` and
> the rest are perfectly good checks that no finding here asked for. So the
> re-derivation is "look up each of the seven names in `flake.nix` and see
> whether it still exists", which is what catches a rename; it is **not** a
> re-derivation of *which* checks belong, and this ledger has no mechanical way
> to do that. Recording it because the fifth pass's rule — quote the command
> that produced a count — is unsatisfiable here, and saying so is better than
> implying a command. Also: haus moved to `dc86913` (#400) while this pass was
> being written, which changes nothing above. No rebuild is owed — this pass
> changes no layer.


> **Status, 2026-08-16 (twenty-sixth pass) — scenes merged 38 seconds before
> the pass that recorded them as "in review" did, so this pass's whole code
> change is one checkbox; the rest is the honest inventory of what's left.**
>
> Fetch ran at the top of the pass, per the rule the twenty-fifth pass wrote
> after tripping without it: local `main` = `origin/main` = `c987372`, so the
> list below is read from the repos' clocks, not this checkout's. Landed since
> workshop#385 (18:07:17Z), grouped by theme — the parentheticals carry the
> clocks, and the groups interleave (the jcode PRs merged before the site
> sweep's, not after):
> [haus#376](https://github.com/hausfold/haus/pull/376) `mergedAt
> 2026-08-16T18:06:39Z` and
> [hausfold.co#64](https://github.com/hausfold/hausfold.co/pull/64) 18:07:04Z —
> **both of which merged BEFORE #385 did**, 38 and 13 seconds respectively, so
> the twenty-fifth pass's "neither is merged" was false by the time it landed
> (⚠️ now flagged in place, below); then the word sweep — haus#377 (every
> nebelhaus compat surface deleted), holt#39, nebelung#46, trill#5, perch#73
> (18:18–18:19Z), and its site half, .github#21 / workshop#386 /
> hausfold.co#65 (18:50–18:54Z), which #386 already normalized through this
> file's own body; then jcode as the fourth AI client (holt#40, haus#378,
> hausfold.co#66 — ⚠️ **being withdrawn, 2026-08-19** (holt#47, haus#411,
> hausfold.co#85, plus this repo's own PR — **all four in review as this was
> written, none merged**; confirm on `mergedAt` before reading this as done):
> the option enum, its holt spec, the Homebrew install path and every doc
> naming it are removed there, leaving `claude`/`codex`/`opencode`),
> haus#379 (the rooms.md guard tests wiring, not spelling) and
> perch#74 (a sweep). **Only haus#376 moves a §5 item.** §5.8's first box flips
> to `[x]` on its `mergedAt`, and the header plus Phase 5's line move in the
> same edit, per §6's own convention. No new §5.14 row: a box born stale by 38
> seconds is the twenty-fifth pass's ticked-while-open row with the clock run
> the other way, and the mitigation is the same word — `mergedAt`.
>
> **What's left, in one place** — the question this file keeps making a reader
> derive from four surfaces (§5 headers, §5 boxes, §6 phase lines, and the
> `◐`s that `grep '\- \[ \]'` misses). Eleven open boxes — counted as the
> literal `- [ ]` markers in §5, so §5.1's `scheme` box is one of them, §5.6's
> three deferred halves share its single honest-docs box, and §5.8's
> reachability gap lives *inside* the trigger box rather than beside it — in
> three kinds:
>
> - **Code, in build order within each item:** §5.8's reachability gap (feed
>   `modules/launcher`'s two static `./commands` halves from
>   `config.haus.focus.scenes`, so a scene has a palette row and a cheatsheet
>   line — the box's own precondition for the trigger daemon, which stays
>   deliberately behind it) — **done hours after this block was written**
>   ([haus#381](https://github.com/hausfold/haus/pull/381), `mergedAt
>   2026-08-16T20:10:48Z`), so what §5.8 still holds is the trigger daemon
>   alone; §5.9's three (an open `bar.widgets` with
>   `bar.items` as sugar; pounce command packs; commands declaring
>   mutates/confirm/permissions); §5.1's `flavor = "custom"` + `theme.palette`;
>   §5.2's `motion = "none"`; §5.3's app-side `sans` across pounce/perch/trill,
>   which needs its config seam before it needs a font. §5.1's `scheme =
>   "auto"` stays `◐` on a design answer (per-tool rather than everywhere at
>   once — its box says "rice-wide", in the old word), not on missing work —
>   its box counts among the eleven, but re-opening it is a decision, not a
>   backlog item.
> - **Tests nobody has run, 👤:** §5.5's non-QWERTY claim (`windowNav =
>   "ctrl-alt"` exists, untested on a real AZERTY/Dvorak), and §5.10/§5.13's
>   docked multi-display validation, which gates any `profiles.docked` design.
> - **Deferred on a reason, not forgotten:** §5.6's Windows row and the two
>   halves inside shipped groups (`lock`'s login half, `security`'s
>   guest/remote-login half) — all logout-only, so they wait on the restart
>   map growing a `logout` story a user would accept, plus the honest-docs box
>   that names that.
>
> **Verified,** all from the repos' side since a workshop worktree can't build
> the layer: `haus.focus.scenes.<name>` and its six leaves read back from
> `docs/site-data/options.json` **at haus `main`**; merge commit `3690be1` is
> an ancestor of main (`compare … status: ahead`); the focus room's page
> serves scenes on the live site (200, cache-busted). No rebuild is owed —
> nothing in this pass changes the layer, and the feel-test the twenty-fifth
> pass left open (the real DND keypress, `caffeinate`, the audio switch)
> remains open and remains Julien's.


> **Status, 2026-08-16 (twenty-fifth pass) — the last Phase-5 item that needed
> code is built, and the room rename that landed this morning had already
> inverted the move it was built around.**
>
> Landed since the last pass and read for this one, in merge order:
> [haus#374](https://github.com/hausfold/haus/pull/374) 16:36Z (the install
> table hands out `hacker.sh` — ⚠️ **on `main`, not on the site**: the Worker
> serves `bootstrap.sh` from the latest *release tag*, and #384 below is where
> that is recorded — **a docs fix inside `bootstrap.sh` is a release, not a
> merge**), [workshop#381](https://github.com/hausfold/workshop/pull/381) 16:40Z
> (§11 closes; a fourth 301 chain found by curling),
> [hausfold.co#63](https://github.com/hausfold/hausfold.co/pull/63) 17:02Z and
> [workshop#382](https://github.com/hausfold/workshop/pull/382) 17:02Z (two
> rebased branches landing what the rename sweeps missed — including
> `docs/workflows.md` telling readers to set an option `moved.nix` deleted with
> no alias, and a room page calling the **Development** room "Terminal", which is
> a *namespace inside it*: the read-the-hit discipline this file's banner is
> built on, recurring one repo over), and
> [workshop#384](https://github.com/hausfold/workshop/pull/384) 17:08Z (§11's
> last ⏳, and the 31-destination curl sweep re-run green).
>
> Nothing in that list moves a §5 item, so this is a **shipping pass**: §5.8's
> declarative half is **built and in review**
> ([haus#376](https://github.com/hausfold/haus/pull/376)), with the page a
> stranger meets it on
> ([hausfold.co#64](https://github.com/hausfold/hausfold.co/pull/64)). Neither
> is merged — which is the difference §5.8's checkbox turns on, below.
> ⚠️ **False by 38 seconds by the time it landed:** haus#376 merged at
> 18:06:39Z and hausfold.co#64 at 18:07:04Z, while this pass's own PR
> (workshop#385) merged at 18:07:17Z. Corrected by the twenty-sixth pass
> (above), which ticks the box on `mergedAt`.
>
> ⚠️ **That list read "exactly two" until the assurance pass fetched.** The
> local `main` this pass audited against was two commits behind `origin/main`,
> so #382, #384 and hausfold.co#63 were invisible — **§5.14's own row 9** (*a
> claim about a repo, read from the LOCAL CHECKOUT*), recurring inside the pass
> that cites it, two passes after the row was added for exactly this. The
> mitigation was already written down, which is the uncomfortable part: this is
> not a rule nobody had, it is a rule nobody ran. The one thing worth adding is
> procedural — **the fetch belongs at the top of a pass, before the "landed
> since" list is drafted**, not somewhere inside it.
>
> ★ **First, and it is the one to carry: a sketch borrowed a plain English word,
> and then the codebase took that word for something it already had.** §5.8 has
> proposed `haus.scenes.*` as a NEW namespace since July, with `focus.*`
> demoted to an alias "so no host breaks" — written when this room was called
> `hush` and `focus` was a free word the document had picked up.
> [haus#367](https://github.com/hausfold/haus/pull/367) merged at 10:08 UTC
> **today** and made it the room's actual name, and the sketch's central move
> inverted in that minute: a `haus.scenes` room beside a `haus.focus` room is two
> rooms for one job — the thing the room doctrine exists to forbid — and the
> alias that was supposed to protect hosts would instead **retire a room name on
> the day it was given**. Scenes ship inside the room instead, as
> `haus.focus.scenes.<name>`, and no alias is needed because nothing moved.
> **What makes it a ★ rather than a rewrite: none of the twelve shapes in
> §5.14's table catch it** (twelve when this pass opened, **fourteen** when it
> closed — it added two, and the second one is its own; both counts taken off
> the table rather than carried forward). The entry didn't go stale, wasn't
> falsified, doesn't disagree with its
> marker, isn't about the wrong layer. It stayed literally true and quietly
> started proposing something else, because the *tree* moved under a sentence
> that didn't. The naming banner three paragraphs up even notices the
> coincidence — it counts §5.8's `focus` and §5.9's `bar.widgets` as evidence
> that "where §5 sketched a room that had a code name, it wrote the room's own
> word" — and reads it as a happy accident rather than as a collision to check.
> New row in §5.14's table, and the mitigation is one line: **read a sketch
> against today's option tree, not against its own vocabulary.**
>
> ★ **Second: the plan of record for a room lived in a different repo from the
> room, and the note sitting beside the code did not know it existed.** haus's
> own `notes/focus-design.md` is that room's design record — it has a "v2
> candidates (explicitly not v1)" list, and from the day it was written until
> today that list named a timed focus and a windows binding and **not scenes**,
> which is the only thing on
> §5.8's line and the last Phase-5 item. A reader in the haus repo would have
> concluded scenes were nobody's idea. This is §5.14's structural reason 1 (*the
> work happens in four repos and the doc lives in a fifth*) at its most concrete,
> and the fix is not a mechanism: **when a roadmap item names a room, the room's
> own note is where it has to be written down.** Done in the same PR, with the
> four design decisions and why each had a plausible other answer.
>
> ★ **Third, and it changes what to build next: §5.8's remaining box asks for the
> wrong thing first.** The box says build the trigger engine only after one
> hand-written scene proves useful — correct, and still open. What building it
> exposed is that **a scene has no surface but the CLI**: quiet has a bar pill
> and a palette row, while `focus scene recording` has a terminal and whatever
> `keys.leaderExtras` chord a host writes. That is a reachability gap, not a
> trigger gap, and much the cheaper of the two — no daemon, no new mechanism.
> An unreachable scene can't prove itself useful, so the trigger box's own
> precondition depends on closing this one first. Written into the box, with the
> correction the assurance pass attached: `modules/launcher` builds both the
> installed scripts and the cheatsheet rows from a **static** `./commands` dir,
> and a comment beside the second says reading a generated command's header
> would be IFD on every eval — so the staticness is the obstacle to work
> around, not the reason it's easy.
>
> ⚠️ **Correction to the twenty-fourth pass's headline, which this pass copied
> before checking it.** That block is titled *"the rooms were renamed eight days
> after the desktop was"*. The desktop became `hacker` in
> [haus#364](https://github.com/hausfold/haus/pull/364), merged 2026-08-15
> 10:06 UTC (decision dated 2026-08-14); the rooms landed in haus#367, 2026-08-16
> 10:08 UTC. **That is one day, not eight** (two if you count from decision 10's
> own date, 2026-08-14). Eight days is
> [haus#261](https://github.com/hausfold/haus/pull/261) `2026-08-08T22:43Z`
> → #367 — the *namespace* rename, a different rename of a different thing, in
> the header of the pass whose own subject was reading the hit rather than the
> word. ⚠️ And "eight" there is the calendar subtraction: elapsed is **7d
> 11h25m**, which matters only because it is the same rounding this paragraph
> exists to refuse. The first
> draft of §5.8's box above inherited the phrase verbatim, which is the more
> useful half of this note: **a wrong interval propagates the way a wrong option
> name can't, because nothing evaluates it.** Both are dated at a rev and a
> timestamp now, per the twenty-fourth pass's own rule. ⚠️ A sibling in the same
> block, flagged rather than corrected because its subject predates this file:
> the naming banner's *"for six weeks the document and the code used different
> words for the same room"* is measured from the same wrong end — **this file
> dates itself 2026-07-25**, three weeks before the rename, and only the
> "earlier brainstorm" it says it refines could reach six. Whoever knows when
> that brainstorm first wrote `focus` should fix the number or drop it.
> → ✅ **Dropped 2026-08-20**, four passes later, because nobody does: the
> brainstorm this file refines is not in the repo and its first `focus` is
> unrecoverable, so there is no end to measure from. The banner now makes the
> claim without an interval and says in place that it used to carry one — the
> alternative, deleting the number silently, is the shape this ledger exists to
> catch.
>
> Housekeeping: §5.8's header carries `◐` and its built-not-merged box is
> written out; Phase 5's line moves from `[ ]` to `◐` and its closing sentence
> (*"§5.8 is once again the only thing on this line needing code"*) is struck
> rather than deleted, since it was true for two days. **Two** rows added to
> §5.14's shapes table.
>
> **Verified:** `nix flake check` green in the haus lane at **24 checks** —
> unchanged in number, since the new fixture rides the existing `desktop-seam`
> rather than adding a check. `docs/site-data/` regenerated and committed
> (`site-data-current` is what fails otherwise); a whole `darwin-system` drv
> evaluated with two scenes declared, one of them naming an audio device, since
> that is the only path that reaches `switchaudio-osx`; both new assertions
> read back as messages rather than as a thrown eval (reserved name, malformed
> name, and a well-formed one producing none). The engine was **run, not read**,
> against a fake `$HOME`: `focus scene list / status / <unknown> / <name> / off`
> — the unknown name exits 64 and prints the list, entering a second scene
> leaves the first, the hook log holds exactly `on` then `off`, once, and
> `~/.local/state/focus` is left with no scene files behind. Then the four-row
> DND matrix, with `apply` swapped for a recorder so nothing pressed the real
> hotkey: **already-quiet + `restorePreviousState = true` makes zero `apply`
> calls** (which is the Slack-clobber fix, below), and `= false` makes exactly
> one, on the way out. `shellcheck` clean at `-S warning`; the three remaining
> infos are SC2016 on jq programs, one of them pre-existing. The docs site
> builds (96 static pages). ⚠️ **Not verified, and it is the feel-test:** every
> path that acts on this Mac — the real DND keypress, `preventSleep`'s
> `caffeinate`, the audio switch, `apps.open` — was left unrun on purpose. No
> `bench try`, no switch, no lock moves.
>
> **The assurance pass found two 3/5s, and they were the same mistake wearing
> two faces: the exit read itself off the scene table.** A scene table is a file
> that changes under a running scene — every rebuild rewrites it — so
> **(i)** leaving a scene the host had deleted in between released the caffeinate
> hold, printed success, and left the Mac quiet on the wrong microphone with
> nothing remaining that knew to put either back; and **(ii)** entering a quiet
> scene while *already* quiet re-ran the Slack leg, which stashes the
> current — already quiet — status as the one to restore, so "heads down" became
> the permanent Slack status at the next un-quiet. Both are fixed by writing what
> the scene actually **took** on entry and reversing that alone, which is a
> better rule than either bug: `restorePreviousState` now has exactly one job
> (`false` ends quiet-off even if you were quiet before) and the hook edges pair.
> ★ The generalisable half is worth more than the fixes: **a state machine whose
> "undo" is computed from configuration has a half-life measured in rebuilds** —
> this layer rewrites its own config several times a day, which makes
> "read the table on exit" a materially worse idea here than in software that is
> configured once. Six smaller findings landed too, of which the one to remember
> is that `focus off` and `focus toggle` — the pill's path and the palette's —
> knew nothing about scenes, so clicking the bell un-quieted while the hold and
> the microphone stayed: **the pill lying is the exact failure this room's whole
> state-reading design exists to prevent, arriving through the one door nobody
> had shut.** Nothing ≥4/5 was found.
>
> **A second assurance pass read THIS file's diff, and it found the only 4/5 of
> the day inside the note rather than inside the code: the box was ticked for a
> PR that is open.** It also caught the stale-`main` list above, the
> Phase-5 sentence its own §5.8 box contradicts, "eight days" left as a calendar
> subtraction in the paragraph refusing calendar subtractions, a "six weeks" this
> pass asked someone else to fix while asserting it in the sibling PR, an option
> description promising a palette item that does not exist, and the `./commands`
> reasoning that cited the fact arguing against it. Seven findings, three at
> ≥3/5, all folded in. **Two passes, two repos, and each one's headline finding
> was the author's own shape turned back on them** — the code pass found the
> engine reading its undo out of config, and the notes pass found the note
> claiming a state the repo could have denied in one API call. The cheap rule
> from the second: **a PR number inside a `- [x]` is a promise; only `mergedAt`
> keeps it.**


> **Status, 2026-08-16 (twenty-fourth pass) — the rooms were renamed eight days
> after the desktop was, and the twenty-third pass's own "correction" turns out
> to have replaced a true sentence with a false one, in the hour it was writing
> down why that happens.**
>
> ⚠️ **"eight days after the desktop was" is wrong, corrected by the
> twenty-fifth pass (above).** haus#364 (the desktop → `hacker`) merged
> 2026-08-15 10:06 UTC; haus#367 (the rooms) merged 2026-08-16 10:08 UTC — **one
> day.** Eight days is haus#261 → #367, the *namespace* rename: a different
> rename, of a different thing, in the header of the pass about reading the hit
> rather than the word. The rest of the block is unamended.
>
> Landed since the last pass and read for this one: haus
> [#366](https://github.com/hausfold/haus/pull/366) (the Vim keys go, workspaces
> become a count, a throw can stay),
> [#367](https://github.com/hausfold/haus/pull/367)/[#368](https://github.com/hausfold/haus/pull/368)
> (every code-named room renamed to what it does),
> [#369](https://github.com/hausfold/haus/pull/369) (`haus.launcher.fnKey`),
> [#370](https://github.com/hausfold/haus/pull/370)–[#372](https://github.com/hausfold/haus/pull/372)
> (bar dropdowns), [#373](https://github.com/hausfold/haus/pull/373) plus the
> `ai/SKILL.md` sweep across pounce, perch, holt, trill and nebelung
> ([`agent-surface.md`](./agent-surface.md), workshop#379). The room rename is
> the event, and the naming banner above carries it. **Nothing in §5 changed
> shape** — the rename configures nothing differently — so this pass is an audit
> plus one workshop-side fix, and no rebuild is owed.
>
> ★ **First, and it is the one to carry: a correction can go BACKWARDS, and
> "measured" is the word that makes it stick.** The twenty-third pass's headline
> finding was *the local checkout is memory wearing the repo's clothes*. In the
> PR immediately before the one that wrote that (workshop#375, merged 11:14 UTC),
> the same session **replaced a true clause in `AGENTS.md` with a false one**:
> the flake-input row had said *"§11.2 moves it to `haus` — new installs scaffold
> that already"*, correct, written by workshop#372 at 10:06 UTC; #375 rewrote it
> to *"⚠️ **not yet, and nothing scaffolds `haus` today**: `haus`'s
> `bootstrap.sh` writes `inputs.haus.url` for a fresh install (measured
> 2026-08-15)"*. [haus#364](https://github.com/hausfold/haus/pull/364) had
> flipped that line to `inputs.haus.url` at **10:06:01 UTC**, sixty-eight minutes
> earlier (`gh api repos/hausfold/haus/commits/9718fb3` shows the one-line patch;
> `bootstrap.sh:603` on main says `inputs.haus.url` today). So the stale checkout
> did not merely leave a claim un-updated — it **manufactured a fresh wrong one,
> deleted a right one to make room, and dressed it in a ⚠️, a date and the word
> *measured*.** Every rule this file has for spotting staleness keys on age; this
> one was the newest sentence in the file and the only wrong one on the page.
> The mitigation is not "fetch first" (that pass already knew): it is **date the
> measurement against the repo's clock, not the calendar day** — "measured
> 2026-08-15" and "measured at rev afc3b58" are different claims, and only the
> second can be checked.
>
> ★ **Second, from re-reading the row that finding sits in: it named the wrong
> file as the coupled one, and the coupling it was protecting is now gone.**
> Both `AGENTS.md` and the rename record said
> renaming the layer's flake input needs *"`bench`'s `OVERRIDABLE` in the same edit"*.
> `OVERRIDABLE` holds **repo directory names** (`nebelung pounce perch holt
> haus`) and never held an input name; the literals that actually
> coupled were `overrides()`'s five `--override-input haus/…` strings and
> one row of `EDGES`. A decision record that says *don't touch this, it's
> coupled* has to name the line, or the next person greps the named file, finds
> nothing to change, and concludes the warning is stale rather than misfiled.
> Both are corrected, and the coupling is retired rather than re-documented:
> **`bench` now reads the input's name off `$CONSUMER/flake.lock`** instead of
> mirroring one machine's spelling (`lock_layer_input`, matched on the node whose
> own inputs carry `pounce` + `nebelung`, so it survives the slug being renamed
> under it). That was worth doing on its own account: a `--override-input` naming
> an input the flake doesn't have is **not an error in Nix, it is a no-op**, so
> the mirror's failure mode is `bench try` announcing your branch while building
> the pinned layer — and since 2026-08-15 there are two live spellings, because
> every machine `bootstrap.sh` scaffolds calls it `haus`. §11.2's *"the one edit
> in §11 that cannot be half-done"* is now an ordinary one-line edit to a 👤 file.
>
> ★ **Third, found while writing that fix, and it is a five-day-old live one:
> `~/.config/nix` fetches the layer from `github:hausfold/hausfold` — the slug
> §10 freed on 2026-08-11 — and only GitHub's rename redirect makes it resolve.**
> `bench status` printed that edge as `✓ current` every day since, because it
> compares the locked **rev** and has never looked at the locked **source**.
> `bench`'s own `gh_repo` carries a 🚨 about exactly this hazard ("a bare
> `$GH_ORG/$name` appears to work, right up until someone creates a repo actually
> named…") — written about `gh` calls, three functions above the lock reader
> where the freed slug was already live. **The dimension a warning was written
> about is not the dimension it covers**, which is the twenty-third pass's
> mirror question (*which dimension of this copy did I decide was closed?*)
> arriving as *which dimension of this warning did I decide was the only one?*
> `bench status` reports it as `RENAMED` now, under the edge's own row, for every
> edge — measured across all six, exactly one is wrong today and it is the one
> nobody sweeps, because it lives in a 👤 file.
>
> ★ **Fourth, and it is the softest kind: §6(b)'s "measured" error transcript
> names an option that never existed.** The block quotes
> ``error: The option `haus.bar.enable' has conflicting definition values``
> as the measurement that retracted this file's own claim about composition — and
> on 2026-08-05 the bar room was `sill`, so the real error can only have said
> `haus.sill.enable`. (`modules/renamed.nix` is generated by enumerating the
> whole option tree at the `haus`→`haus` rename; it maps
> `haus.sill.enable` → `haus.bar.enable` and contains no `haus.bar.*`
> at all.) Nothing the block concludes is wrong — the error does name the option,
> both files and the fix. What happened is that the transcriber **normalised the
> quote into the document's own dialect**, the same dialect the banner above
> credits for landing on the room's eventual word, and a paraphrase inherits the
> authority of a paste the moment it sits inside a fenced block. ⚠️ **And it just became
> uncatchable**: since haus#367 the string is a real option name, so nobody
> reading this file tomorrow has any way to notice. Corrected in place at §6(b).
>
> Housekeeping: §5.5's shipped box claimed `windowNav` moves *"all fifteen
> main-mode chords plus service-mode entry"* — after rice#210 retired `⌥⇥` and
> #366 unbound `⌥hjkl`, and with the workspace digits living in launch mode, the
> real number is **nine** (`grep -cE '\$\{m(s)? "' modules/windows/wm-bindings.nix`
> → 8, plus `serviceEntry` in `modules/windows/default.nix:193`); amended there
> with the count re-derived rather than adjusted. §5.9's opening count of
> `bar.items` re-derived the same way and survived: 16 leaves,
> one of them the deprecated `claudeUsage` alias, so **15 pills — the number the
> box already says**, which is what a count claim looks like when it happens to
> stay true, and it stays true only with its scope written down. Two rows added
> to §5.14's shapes table.
>
> **Verified:** `shellcheck bench` clean (bare, as CI runs it) and the bats suite
> green at **93 tests** (81 before — the base moved under this branch mid-review
> when workshop#380 landed, so both numbers are re-derived from
> `grep -cE '^@test '` rather than carried forward) under nixpkgs' bats 1.12 *and* a real bats
> **1.10.0** tarball — CI's apt version, which doesn't subshell a test body, so a
> suite can print all-`ok` and still exit non-zero there. Every new assertion was
> mutation-checked: re-baking the literal `haus` into `overrides()` fails
> exactly one test, re-baking it into `EDGES` fails exactly one, and dropping
> `locked_slug`'s github-type guard fails the test that says a GitLab-hosted
> input has no GitHub slug to be wrong about. The `RENAMED` row and the resolved
> input name were both read off a live `./bench status` against the real
> `~/.config/nix`, not a fixture. No `bench try`, no switch, no lock moves —
> nothing this pass touched is in the flake.
>
> **The assurance pass re-derived every factual claim above and confirmed all
> eleven of them, then found ten things anyway, three at 3/5** — and two of the
> three are this pass repeating, inside its own diff, the shapes it had just
> filed. **(i)** The `RENAMED` hint printed at the terminal repeated the false
> coupling (*"renaming it needs bench's `OVERRIDABLE` in the same edit"*) that
> finding two exists to retire — newly written, in the user-facing copy, one file
> away from the correction. **(ii)** The banner paragraph above said the body
> holds "eight hits, all `haus.pounce`", which this pass's own §6(b)
> correction falsified in the same commit by adding two `haus.sill`; the
> count is re-derived and scoped now, one paragraph after §5.9 preaches exactly
> that. **(iii)** The PR number this work cites in three permanent places was
> already taken by another open PR — a plan-of-record citation pointing at a
> stranger's branch. Also fixed: `activate_built` reached `$(overrides)` with no
> resolve in its own shell (`cmd_rebuild`'s path — benign today, a latent empty
> `--override-input`), `layer_input` could splice a `warn` **into the value** in
> `cmd_ship`'s `nix flake update "$input"` because `warn` prints on stdout while
> only `die` redirects (so `layer_input` is silent by contract now, with a test),
> and the `/docs-sync` skill carried a third copy of the corrected
> table — the copy a scheduled sweep reads to decide what NOT to touch, which is
> how a retired claim gets re-asserted by tooling. **A pass that files a shape
> and then commits it is not embarrassing, it is the evidence the shape is real**
> — and it is the second consecutive pass where the clean-context read was the
> only thing between a finding and its own counter-example.


> **Status, 2026-08-15 (twenty-third pass) — the desktop this whole document is
> about was renamed out from under it, and the audit that found that nearly read
> a stale checkout instead of the repo.**
>
> [haus#364](https://github.com/hausfold/haus/pull/364) merged four hours after
> the twenty-second pass's own PR: **decision 10 drops the name `haus`**,
> the desktop becomes **`hacker`**, and the naming banner above is amended rather
> than the body rewritten. Nothing this file tracks as work moved — the rename
> configures nothing differently, and its three compatibility seams mean no
> consumer has to act. What moved is every sentence here that says the word.
>
> ★ **The finding: a translation rule for a historical document is only as good
> as the token it keys on, and the bare word is the one no regex finds.** The
> 2026-08-08 banner told readers to translate `haus.*`; the rename that
> arrived translated `haus`. Those are different edits on the body's 137
> hits — the dotted rule gets 63 right and two wrong — and the undotted word
> carries three referents at once (repo, desktop, org), so a reader "applying the
> banner" is right on **under half** of them and silently mis-reads the rest.
> ⚠️ The first draft of this paragraph said "203 hits, the rule reaches 82",
> which is **two different regions counted once each** — 203 is the whole file
> (including the fifteen times this very block says the word) and 82 was the
> body. A count is a claim, and a pair of counts is a claim about a scope; the
> fifth pass's rule (quote the command that produced the number) exists exactly
> because this is easy to get wrong while sounding precise. The workshop's own `AGENTS.md` had already written
> the trap down — *"grep the bare word separately: a desktop file's top-level key
> is `{ haus = { … }; }`, with no dot for a regex to find"* — for the layer, one
> repo over, in the same week. **A rule written for the code and not carried to
> the prose about the code is a rule that has to be learned twice.**
>
> ★ **Second, and it is about how these audits are run: "audit against the repos,
> not against memory" (§5.14's founding rule) has a third thing in it. The local
> checkout is memory wearing the repo's clothes.** `~/code/workshop/haus` still
> held `desktops/haus.nix`, with no `hacker.nix`, **46 minutes** after #364
> merged (`holt child` branched this lane from `afc3b58`, the commit immediately
> before the merge)
> — so every question this pass put to the disk would have come back answered by
> yesterday, in the confident voice of a file that exists. It is the worst of the
> three sources precisely because it *looks* like the repo; memory at least knows
> it is memory. The signal is one command and already exists: `bench status`
> fetches before it compares `@{u}` (`bench:583`) and reports `↓ 1`. Two cheap
> mitigations, both now written into §5.14: **fetch, or read GitHub** — this pass
> switched to `gh api …/contents/…`, which cannot be stale — and **never let a
> pass cite a path on disk it hasn't dated**.
>
> ⚠️ Recorded because it happened while writing the sentence above: the first
> draft of that finding said `bench status` *never* fetches, from a `grep "git
> fetch"` that could not match `git -C "$dir" fetch -q --tags`. **A negative claim
> proved by a grep is only as strong as its pattern, and negatives are where
> patterns are weakest** — the same family as the twenty-second pass's
> generator-not-artifact row, and rows nine and ten of §5.14's table.
>
> ★ **Third, the one that shipped code: the lock ripple carries the binary and
> nothing carries the grammar it speaks.** `haus.launcher.items` validates its keys
> against a hand copy of pounce's `ItemTarget` grammar. pounce added a fourth
> address prefix — `shortcut:<uuid>`, the Shortcuts library as launcher rows
> ([pounce#80](https://github.com/hausfold/pounce/pull/80), merged 2026-08-14
> 21:03:50) — and haus's lock moved to that exact merge commit **seventy-nine
> seconds later** (657a3a2, `Update flake inputs (pounce perch)`, 21:05:09), so
> this layer has been
> shipping a daemon that accepts the key while its own module asserts the key
> *"is not an item key"*. The layer tells the user their valid key is a typo, at
> build time, in an assertion, quoting an error string that pounce's own copy had
> already outgrown. §5.9's box (b) asserts that validation as a *feature*
> and is amended there.
>
> **What makes it worth a ★ rather than a fix: the two mirrors sit in the same
> `let`, and only the smaller one was ever argued about.** `builtinModes` carries
> a comment weighing its own risk — *"Six strings, so it's the size of mirror
> that's worth its risk"* — and the if-chain three lines below it, which
> enumerates the prefixes inline rather than as a list, carries none.
> The comment sized the risk of the **values** it mirrors and never the risk of
> the **set** it enumerates, which is the twenty-second pass's blind-spot finding
> one level up: *a check that varies one option is blind to what hides behind a
> second one* becomes *a mirror that reasons about the axis it varies is blind to
> the axis it fixes*. Ask it of every mirror in the family: **which dimension of
> this copy did I decide was closed?**
>
> ★ **And the seventh check, which arrives from a direction §5.14 never
> proposed.** `pounce-item-grammar` diffs the mirror against **the locked
> pounce's own source** — `ItemSettings.swift`, at the rev `flake.lock` pins, not
> at pounce's main — so the question it answers is never "what does pounce do
> now" but "does the grammar we validate against match the binary we install".
> §5.14's reason 1 says every cross-repo seam here got fixed by making the
> upstream repo *emit* something, and that the doc-side seam is still prose on
> both sides; this is the third option nobody wrote down: **a flake input already
> IS the upstream repo, pinned at the rev you ship, and its source is readable as
> data without asking that repo for anything.** It cost no change in pounce. It
> is in the all-systems check set, so unlike `accent-reach` it fires on CI as
> well as here. **Ten ★ findings, seven checks.** Open as
> [haus#365](https://github.com/hausfold/haus/pull/365) — with an owner and a
> number, per the twentieth pass's rule.
>
> ⚠️ **And the assurance pass earned its place again: the first version of that
> check mirrored pounce's ERROR SENTENCE, which is not where pounce's grammar
> lives.** Only `ItemTarget.modes` is single-sourced in pounce (its "can't drift"
> comment sits on that line and covers it alone); the prefixes are `hasPrefix`
> literals in `parse` and a hand-written restatement in `problem` — two copies,
> so the mirror was a mirror of a mirror. A prefix added to `parse` and forgotten
> in the sentence would have left both repos wrong **in agreement**, with the
> check green: this very bug, recurring undetected. The same read found that a
> check pinning the mirror pins nothing about the **validator** — the cheapest
> way to green it is appending one string to the data file, which leaves
> `itemKeyProblem` rejecting the key its own error message now advertises (fixed
> with an assertion that every shape has a sample and every sample survives),
> and that the check's "don't delete me" guard was unreachable under the
> builder's `set -e -o pipefail`. **A tripwire is worth exactly what its
> weakest sample is worth, and three of those four defects were the check being
> green for the wrong reason** — the twenty-second pass's fourth finding,
> arriving as a class rather than an instance.
>
> ★ **Fourth, and it is this section's own lesson wearing a different repo's
> clothes: haus's CI census carries the instruction to keep itself honest, and
> checking it beat appending to it four to nothing.** `.github/workflows/check.yml`
> enumerates which checks run on CI's Linux runner, and says in the file: *"Keep
> this census honest when a check is added: it is this repo's only record of what
> CI actually covers, and it went one stale before anyone noticed."* The
> twenty-third pass's first instinct was to add one name and bump "ten" to
> "eleven" — which would have been correct and would have left **four** existing
> errors in place: the count was already one short, `bar-rc-executable` was
> filed as darwin-only when it is portable, `desktop-projection` as portable when
> it is darwin-gated, and `bar-plugins-executable` had never been listed at all.
> Both lists are re-derived now from the one line that decides the split
> (`optionalAttrs (hasSuffix "-darwin" system)`), and the portable half is a
> table rather than a paragraph, because a paragraph is what made four errors
> invisible. **Same shape as the ledger correction on the twenty-second pass, in
> another repo, found the same way — by re-deriving instead of reading.** The
> rule generalises past both: *a prose census of a machine-readable fact rots in
> every direction at once, so the instruction to keep it honest has to mean
> re-derive it, not extend it.*
>
> Housekeeping: two rows added to §5.14's shapes table (stale checkout, negative
> claim by grep), the ledger paragraph appended there, and §5.9's two pounce
> boxes amended — its address space is four prefixes now, not three. Two
> rename-side corrections fell out of the assurance read and are fixed in the
> same commit, both shape 2: `AGENTS.md` still called the four state dirs
> "deliberately held" and the rename record's do-not-sweep table still
> agreed with it (that record is deleted as of 2026-08-16) — left behind by the very commit (workshop#372) that amended
> the row four lines above, which is how a partial sweep fails. The
> instructive part is *where* it was found: the pass quoted `AGENTS.md`
> approvingly two lines below a line its own finding falsified — **a document you
> are citing is not a document you are reading.**
>
> **Verified:** `nix flake check` green in the haus lane (**24** checks),
> `nixfmt --check` clean, `docs/site-data/options.json` regenerated and
> committed. `pounce-item-grammar` mutation-checked in every direction —
> deleting `shortcut:<uuid>` from the data file reproduces the exact pre-fix
> error string and the check names the missing prefix; corrupting a mode name
> names that instead; an unsampled shape and a sampled-but-still-rejected shape
> each fail with their own sentence; a dropped mode caption names the mode. The
> assertions were proved live rather than by reading: a system evaluating two
> `shortcut:` items builds, and a `shortcutz:` typo still fails, now with
> pounce's wording word for word. No `bench try switch` — no drawn output moves.
> **The two assurance passes (one per repo, clean context, diff plus AGENTS.md)
> found eleven things between them, four of them ≥3/5** — including both count
> claims in this block, a check that could go green while the validator it
> protects stays broken, and the CI census above. Every one of them was a claim
> about code, made from a document, by the session that wrote the code.


> **Status, 2026-08-15 (twenty-second pass) — the small `sans` is built, and the
> reason it could hide is now a row in the check that couldn't see it.**
>
> [haus#363](https://github.com/hausfold/haus/pull/363) open. `haus.fonts.sans.name`
> exists, defaults to `".AppleSystemUIFont"`, and `clockLabelFont` reads it —
> the one-option, one-reader version §5.3's last box asked for, with no
> `sans.size` and no `sans.package`. §5.3's `sans` box ticks; a new box under it
> holds the ·M app-side half, which is unchanged and still needs a seam before
> it needs a font. **Nothing the machine DRAWS moves**: the option's default is
> byte-for-byte the literal it replaces, pinned by
> `test/projections/example.json` — so the `bench try switch` and the look at the
> clock pill the last pass said were Julien's to run are **not owed**. Stated
> that carefully because the first draft said "nothing on any machine moves" and
> the assurance pass falsified it in one command: **adding a public option moves
> the generated option surface**, so `options.md` in every agent's skill dir,
> `haus set`'s catalogue and the options page all change. Three lines later this
> same box calls that a *benefit*. An invisible refactor that is invisible
> everywhere is rarer than it looks, and "nothing moves" is the claim most worth
> checking before writing.
>
> ★ **The finding — stated by the twenty-first pass, made a CHECK by this one,
> and the distinction is the whole point of the ledger below: A REACH TABLE THAT
> VARIES ONE OPTION IS BLIND TO ANYTHING BEHIND A SECOND ONE.** `font-reach`
> evaluates two systems differing in `fonts.mono.name`; both leave
> `bar.clock.monoFont` at its `true` default, so `clockLabelFont`'s other branch
> — the one holding the hardcoded family — was never evaluated **inside the one
> check whose entire job is finding hardcoded families.** No smarter pattern
> fixes that. The fix is a third pair of systems with the second key flipped, and
> it is now in the flake with the sans rows beside it. The question it leaves for
> every golden table here: *which conditional does my sample never enter?*
>
> ★ **And that makes this the first INSTANCE of §5.14's longest-surviving check
> candidate to become a check.** "What second key or precondition makes the first
> one a lie" has outlived every other candidate since the sixth pass, and the
> reason §5.14 gave was that it is a design rule for options not yet written
> rather than a property of one that exists. Careful about what that corrects:
> the sixth pass logged an *instance* two sentences after writing the excuse
> ("the terminal font can't clip" holds only while windows tiles the window), and
> there are four more scattered through §5. So instances were never scarce —
> what had never happened is one of them becoming **a check**, which is the only
> thing the ledger counts. **Nine ★ findings, still six checks**: the two numbers
> move independently, and this pass moves only the first, because `font-reach`
> now carries two findings the way `packs` and `scale-reach` already do. The
> six are `data-only-surface`, `accent-reach`, `packs`, `fragment-compat`,
> `scale-reach` and `font-reach`, from `nix flake check` in the haus lane — see
> the ledger, where this pass had to correct the roster itself. The one
> `bench status` *warning* stays counted separately, as the fourteenth pass
> ruled.
>
> ★ **Third, from the assurance pass, which killed two sentences and left the
> finding standing.** The write-up said the hardcode "sat in [the blind spot] for
> months" — `git log -S` finds it landed the day before, in haus#330. And "six
> pills set `label.font=` in the same generated file" counted the **source**: one
> of the six writes a different file, three are opt-in `bar.items` the example
> system never enables, and the survivor is `:Regular`, so the sampled file has
> exactly **one** matching line. Both errors have the same shape and it is this
> section's own: **a claim about a generated artifact, derived by reading the
> generator.** The first one also inverts the moral — the blind spot is *older*
> than the bug it hid (font-reach is rice#243, the literal is haus#330), so the
> cost was luck rather than time: nothing here would have reported it in a year.
>
> ★ **Fourth, small and reusable: a row that passes for a reason it does not
> state.** The new capture is anchored to the clock's own block, and the anchor
> is **not load-bearing today** — widening it to `.*` leaves the row green,
> because the sampled file's only other `label.font=` (weather's popup) is
> `:Regular` and this row's pattern wants `:Bold`. That is a property of the
> SAMPLE, not of the bar, which is the argument for keeping the anchor and for
> saying so in the comment. ⚠️ The comment first said "the example system
> enables only the clock" — false, and the third finding above is exactly the
> shape it made: a claim about the generated file, derived from the generator,
> **written in the sentence that files that error as a lesson.** A check that is
> green for an unstated reason is indistinguishable from one that is green for
> the stated one, right up until the sample changes.
>
> Housekeeping: the audit half of this pass was empty — haus's tip was
> [haus#362](https://github.com/hausfold/haus/pull/362), the twentieth pass's
> follow-up (merged during the twenty-first), so no open box had shipped and no
> closed claim was falsified.
> Two things fixed on the way: `options-groups.nix`'s `fonts` blurb still said
> "the bar keeps its own font", which rice#243 made false; and the new option was
> missing from `test/desktop-projection.nix`, which names the public values a
> desktop carve-out may move — it is desktop-safe, so a projection without it
> reports "no difference" for a machine whose clock changed face.
>
> **Verified:** `nix flake check` green in the haus lane (23 checks), mutation-checked
> in both directions — re-welding the literal turns the new row into
> `.AppleSystemUIFont | .AppleSystemUIFont` and drops the file row, naming exactly
> what regressed — plus `desktop-projection` red-then-green against its updated
> golden. The *default* is pinned by that golden rather than by the new check
> row, which names both its values explicitly. `site-data` regenerated twice (the
> second time for a reworded first line: `haus set`'s picker shows the
> description's FIRST PHYSICAL LINE, and it ended mid-phrase). No
> `bench try switch`: the drawn output is byte-identical. **The assurance pass
> found thirteen things in this write-up, three of them ≥3/5** — including the
> "nothing moves" claim above and a check named in §5.14's roster that has not
> existed since rice#239's subject retired. Every one of them is a claim about
> code, made from a document, by the session that wrote the code.

> **Status, 2026-08-14 (twenty-first pass) — `fonts.sans` is not the next item,
> and the audit that says so found the option already shipped, spelled as a
> boolean, in another room.**
>
> No code in this pass either; one box measured rather than built. §5.3's last
> open item asked, since rice#243, *which surface would read `sans`* — the
> answer, from an audit of every `font-family` the layer emits and every family
> literal under `modules/`, is **one label**:
> `modules/bar/default.nix:161`, `clockLabelFont = if cfg.clock.monoFont then
> barFont else ".AppleSystemUIFont"`. Everything else the desktop draws — the
> terminal, the whole bar, the wallpaper's debug band — is mono on purpose, and
> the layer emits no third proportional string anywhere.
>
> ★ **The finding: a bool can be a family option with the value welded in, and
> then it doesn't show up when you grep for the option you think is missing.**
> `bar.clock.monoFont = false` IS `fonts.sans`, at one fixed value, filed under
> the room that needed it — and its description sells it on *legibility* (a
> dotted zero against an 8), which is §5.3's own opening argument. This document
> tracked "sans doesn't exist" while a one-value version of it shipped and was
> documented. The general shape, and it is the useful half: **an option surface
> is not the same as an option list.** And the two checks that could plausibly
> have caught it miss for *different* reasons, which is the instructive part.
> `data-only-surface` reads the evaluated option tree, so it sees a
> package-typed leaf with no string sibling and never a literal. `font-reach`
> doesn't read the tree at all — it evaluates two whole systems differing in
> `fonts.mono.name` and diffs the generated files (which is why it's
> darwin-gated); it is the one that *should* have found this, and it can't,
> because both of its systems leave `clock.monoFont` at its `true` default and
> the branch holding `.AppleSystemUIFont` is never taken in either. **A reach
> check that varies one option is blind to anything hidden behind a second one.**
>
> ★ **Second, about this file rather than the layer: a box that names a blocker
> you have since removed promotes itself.** §5.3's sans line read "nothing blocks
> it now that naming a package is possible" — pointing at `packageName`, the
> format limit this very section fixed — and that was never sans's dependency.
> `.AppleSystemUIFont` needs no package; what sans needs is a consumer that can
> be told to use it. So the box didn't just go stale, it read as *ready*, which
> is worse than reading as blocked: **it is the only one of §5.14's shapes that
> makes an entry look better than it is.** Rule 1 re-audits the box against the
> repos and rule 2 reads commits for falsified *closed* claims — the reason
> sentence beside an OPEN box is in neither's path, and it's the sentence that
> decides whether anyone picks the box up. Filed as §5.14's **sixth row**, with
> the mitigation: when a section closes a limit, re-read every open box in that
> section that cites it.
>
> **What it re-sizes.** A real `sans` is not S. The machine's proportional type
> lives in pounce, perch and trill, all drawing `.system(…)` — three apps the
> layer reaches to three different depths (pounce built from source as a flake
> input, perch consumed as a notarized zip with a theme-activation seam, trill
> not an input at all). Reachable at the near end, because the layer already
> hands pounce a typography key through its generated config (`scale`, with the
> older-app-ignores-the-key tolerance already established), so `fontFamily`
> beside it is the identical seam. That's ·M across three repos, and the far end
> needs a seam built before it needs a font. The S-sized
> thing that remains honest is naming the literal: `fonts.sans.name` defaulting
> to `".AppleSystemUIFont"`, read by `clockLabelFont`, no `sans.size` (nothing
> sizes proportional text by name here). Not built in this pass — it wants a
> `bench try switch` and a look at the clock pill, which is Julien's to run.
>
> Housekeeping: the twentieth pass's [haus#362](https://github.com/hausfold/haus/pull/362)
> **merged**, so §5.6's restart-map comment now says what the look proved and
> both references here are ticked.
>
> **Verified:** by audit, not by build — `grep -rl font-family modules` (three
> files, all mono) plus a sweep of `modules/` for hardcoded family literals (two
> hits: the clock's, and `sketchybar-app-font`, which is an icon font pinned on
> purpose), read against `modules/appearance/options.nix:65-73`,
> `modules/bar/options.nix:454-463` and `modules/launcher/default.nix:892`. Every
> citation in this pass was re-checked against the files by the pre-PR assurance
> subagent, which caught four of them wrong — including one that credited
> `appearance/options.nix` with a measurement it never made. No
> `nix flake check` run: nothing evaluable changed.

> **Status, 2026-08-14 (twentieth pass) — §5.12 is closed: the eye-check's own
> code landed the same day. And the *other* eye-check's follow-up didn't,
> because it had been parked on this one's PR.**
>
> [haus#360](https://github.com/hausfold/haus/pull/360) and
> [hausfold.co#43](https://github.com/hausfold/hausfold.co/pull/43) both merged.
> §5.12's last box is ticked, §5.2's `cursorScale` box with it, and Phase 5's
> line goes back to naming §5.8 alone. What shipped, beyond the one-word
> promotion the box first predicted: a **fifth reachability class, `by-eye`**;
> the restart-map entry (`com.apple.universalaccess` → `universalaccessd`) with
> a **per-key** trigger in core rather than a per-family one; and a `keyTypes`
> table, because `mouseDriverCursorSize` is the domain's first float and both
> consumers had `-bool` baked in. `haus.accessibility` is seven options now,
> still generated from the table.
>
> ★ **The residue this section called load-bearing is gone, and nobody removed
> it.** §5.12's guard refused the raw `system.defaults.universalaccess.*` route
> while three nix-darwin-typed keys were reachable *only* that way — a guard
> that costs you a setting, defended here as "the right residue". nix-darwin
> types exactly five keys in this domain; all five have a guarded option today,
> so the raw route reaches strictly less than the safe one. **The friction was
> never the guard's strictness, it was three unmeasured keys**, and it ended
> when somebody watched a cursor rather than when anybody argued about policy.
>
> ★ **The finding, and it is about this document's own mechanics: an edit parked
> on somebody else's PR has no owner and no trigger.** The nineteenth pass
> watched §5.6's `lock`/`menuBar` pair, found them fine, and wrote down that
> `restart-map.nix`'s comment (and §5.6's prose) still denied the measurement —
> then filed the fix as *"can be upgraded when the restart-map PR in §5.12 opens
> that file anyway."* haus#360 opened that file, edited it heavily, and did not
> touch the comment, exactly as a PR scoped to a different domain should. The
> box was in this doc; the file was in another repo; the PR was about a third
> thing. **A follow-up that names no repo, no PR and no owner is a note, not a
> plan** — the same shape as the phase-list drift the fourteenth and seventeenth
> passes found, one repo over. Fixed on its own, and **open as
> [haus#362](https://github.com/hausfold/haus/pull/362)** — which is where a
> follow-up with an owner is supposed to live, so this file gets to say "open
> as", not "somebody will get to it".
>
> ★ **And the thing that fix had to say is stronger than "nobody needs it
> today": a restart-map entry for an unconditionally-written domain cannot be
> confirmed by watching a rebuild.** `com.apple.menuExtraClock` and
> `com.apple.controlcenter` sit in core's `typedDomainsWritten` *unconditionally*
> (only `com.apple.universalaccess` has a `restartDeclaredBy` gate), so
> SystemUIServer and ControlCenter are killed on every rebuild of every machine
> whether or not a clock option is set. The clock re-rendering is therefore
> evidence for "no logout needed" and can never be evidence for *this row*. The
> only experiment that could isolate it is **deleting the entry** and seeing
> what stops — which generalises: an always-on entry in a table of triggers is
> falsifiable only by removal, so its cost is not "it's untested", it's "it is
> untestable in place". `com.apple.screensaver = "none"` is the opposite and was
> genuinely confirmed — no persistent process, nothing else firing on its
> behalf.
>
> **Verified:** `nix flake check` green in the haus lane (23 checks, four
> rebuilt), `nixfmt --check` clean. The change is comment-only — no eval
> behaviour moves — which is why it needed no `bench try`.

> **Status, 2026-08-14 (nineteenth pass) — both of this file's outstanding
> eye-checks were finally watched, in one hour, and they came back opposite.**
>
> No code shipped in this pass; two boxes closed and one of them reopened as a
> smaller code item. §5.6's `lock`/`menuBar` pair **needs nothing** — seconds
> appeared in the menu bar clock the moment `bench try switch` finished, and the
> screen saver honoured a 60-second grace period on macOS 26 despite Apple
> having moved that setting to `sysadminctl -screenLock`. `restart-map.nix`'s
> `"none"` for `com.apple.screensaver` is confirmed; the `SystemUIServer` entry
> is *not* separately confirmed, because every rebuild restarts that process
> anyway — see the box for why that doesn't weaken the answer the box asked for.
> §5.12's three `unconfirmed` `universalaccess` keys
> (`mouseDriverCursorSize`, `closeViewScrollWheelToggle`,
> `closeViewZoomFollowsFocus`) **all work** — and none of them does anything
> until `universalaccessd` is restarted, which the layer never does.
>
> **★ The finding: an oracle doesn't only tell you whether a key works — it
> selects which keys you ever learn from, and the generalisation you draw is
> about that sample.** `"com.apple.universalaccess" = "none"` was true, and was
> measured, for the four keys with an NSWorkspace read behind them. Those four
> are the ones with an oracle *because* they are the ones with an oracle; the
> three without were then judged by a rule derived entirely from their
> unmeasurable siblings, and looked dead. Both halves of the mistake are the
> same shape as §5.6's ★ below (a deferral needs its premise checked as hard as
> a shipped option), one level up: **a domain-level fact inferred from the
> measurable subset of that domain is not a domain-level fact.**
>
> Second, smaller, and aimed at whoever wires `haus capture` to this domain:
> deleting the three test keys did **not** restore the plist. Using zoom once
> left `universalaccessd`'s own bookkeeping behind. This domain grows keys from
> ordinary use, with nobody writing them.
>
> **What that leaves as work** (§5.12's box has it, §5.8's line too): a
> `restart-map.nix` entry teaching this domain `universalaccessd`, then the
> promotions and the descriptions they demand. Promoting without the restart
> entry ships exactly the thing §5.12 refused three times — an option that
> writes a plist and shows the user nothing until their next logout. **Open as
> [haus#360](https://github.com/hausfold/haus/pull/360)** the same day, with
> [hausfold.co#43](https://github.com/hausfold/hausfold.co/pull/43) behind it;
> `ui.cursorScale` is answered there rather than built — see §5.2.
>
> **Verified:** by eye, on `mbp`, macOS 26.6.1 (25G76), by Julien — the whole
> point; there is no oracle for any of these five keys and there is not going to
> be one. Test state was reverted afterwards, by hand, including the weakened
> `askForPasswordDelay`.

> **Status, 2026-08-14 (eighteenth pass) — §5.12 is built out to its last 👤
> box, and the guard that existed to make its sharpest edge unhittable was
> asking the wrong question in both directions at once.**
>
> Three boxes flipped ([haus#356](https://github.com/hausfold/haus/pull/356)),
> carrying four things: the `reachability = "needs-fda"` designation, the option
> coverage that makes it enforceable (inside the first box), the strict guard,
> and the `com.apple.Accessibility` prohibition turned from a rule into a table
> row. §5.12's fourth box stays open and stays 👤 — the
> `mouseDriverCursorSize` / `closeView*` eye-check.
> `modules/lib/reachability.nix` is the
> sibling of `restart-map.nix` — restart-map says what makes a write *felt*, this
> says whether the write can *land* and whether it *means* anything.
>
> **★ The finding: a guard that identifies its caller is guessing; a guard that
> tests the capability is checking.** `haus rebuild` refused to run when a config
> set `system.defaults.universalaccess.*` — the shape that aborts activation
> two-thirds in and takes every launchd service with it — and its first line was
> `under_agent || return 0`. That let **two of the three clients through**
> (`under_agent` tests `CLAUDECODE`; ⌘A spawns Codex and OpenCode too, and
> neither sets it) *and* **waved through the human it was protecting** (a person
> in a terminal nobody granted FDA hits the identical abort, unwarned), while
> refusing an FDA-holding Claude pane that was always going to work. One
> predicate is wrong twice. The fix deletes the question: does this config write
> an unguarded TCC-protected domain, and can *this process* write it — the same
> answer the machine is about to give anyway. The wrong shape came from a true
> observation ("the agent broke it") promoted to the wrong rule ("agents break
> it").
>
> **★ Strictness needed coverage, and neither would have shipped alone.** The
> reason anybody reaches for the hazardous spelling is that the safe one didn't
> reach their key: `reduceMotion` and `reduceTransparency` are nix-darwin-typed,
> so until this pass the documented way to set them was the one that breaks the
> machine. `haus.accessibility` now covers all four measured-effective keys, so
> refusing the raw form never refuses a setting that had no safer way to be said.
> A guard that forbids the only route is a guard people route around.
>
> **★ The table generates the option surface rather than being checked against
> it.** `lib.genAttrs` over the `effective` keys, so the two cannot disagree in
> either direction — a key promoted with no prose fails at eval, prose for a key
> the table doesn't back is refused. It also reverses a judgement this file made
> in §5.1: *"that designation never became a typed field, and on this evidence
> probably shouldn't."* True at one copy, false at six, and nothing about writing
> the second copy tells you which world you're in. **A fact stated twice is a
> style choice; the same fact stated six times is a table you haven't written
> yet.**
>
> Verified by running it: 22 `nix flake check` checks green, the host-template
> settability step run locally, `bench try` against `mbp`, `haus doctor` run from
> the branch, and — the check that matters — four synthetic configurations built
> to four *distinct* store paths, each grepped for the announcement core renders:
> nothing declared → silence, `haus.accessibility.*` → `needs-full-disk-access`,
> raw `system.defaults.universalaccess.*` → `aborts-without-full-disk-access`,
> `com.apple.Accessibility` captured → `writes-but-does-nothing`. Distinct
> derivations rather than a mutate/revert loop, which sidesteps the `path:`
> override's root-mtime trap entirely. `plan_permissions` and all five guard
> branches are pinned in `test/haus-plan.sh`; writing those tests turned up one
> more thing worth knowing — bash scopes dynamically, so a stub reading `$keys`
> saw the *function under test's* `local keys`, and every case passed for the
> wrong reason until it was renamed.
>
> **The docs cost was cross-repo, and the assurance pass is what found it.**
> Three hausfold.co pages described the guard as agent-scoped in enough detail
> to be actively misleading — one told a reader in an ungranted terminal that
> the refusal they had just hit could not happen to them
> ([hausfold.co#41](https://github.com/hausfold/hausfold.co/pull/41), which
> **must merge after** haus#356: its `options-drift` job checks out
> `hausfold/haus` main). Worth generalising: a behaviour change whose whole
> subject is "who does this apply to" will have been *explained* somewhere, and
> the explanation is where the reversal actually bites.
>
> Also recorded: **`?Privacy_Automation` lands on the right pane on macOS 26**,
> confirmed by hand — one of the three deep links the seventeenth pass left as an
> eye-check. The other two, and §5.6's `lock`/`menuBar` eye-check, are still open
> and still 👤.

> **Status, 2026-08-14 (seventeenth pass) — §5.11 is closed, and the box this
> file called "low priority, a belt on a check" was hiding a silent break in
> the user's home directory.**
>
> Three open boxes shipped ([haus#353](https://github.com/hausfold/haus/pull/353)),
> and one line of this document's own preamble was contradicting the section it
> summarises.
>
> **★ The finding: `accent-reach`'s referent box was filed under the wrong
> risk, and the audit half was the whole of it.** The box read "Low priority: no
> break has occurred, and this is a belt on a check rather than a check on the
> surface" — true of the glow half (the one line it predicted, now shipped), and
> false of the roster-port half it appended as an afterthought.
> `modules/theme/ports.nix` set `home.file.<target>.source` to a plain string
> under nebelung's themes root, and home-manager's `insertFile` ends in a bare
> `ln -s` — read out of the pinned home-manager's `modules/files.nix`, not
> assumed — so a port whose file nebelung doesn't render becomes a **dangling
> symlink in `~/`**, with no error at build and none at activation. Glow's gap
> could only fool a *check*; this one fools the *machine*, and its symptom is
> "the app looks stock", which is verbatim the outcome that room's own header
> says it refuses to produce. **A pointer-vs-referent gap is worth exactly as
> much as what stands on the other end of the pointer, and this file graded two
> instances of one bug by the more comfortable one.**
>
> Fixed by copying the placed ports through one `runCommand`, which makes the
> referent a build **dependency** rather than a promise. Swept the pinned
> nebelung across 4 variants × 14 accents × all 22 placeable darwin ports: **0
> missing files**, so both checks are insurance rather than a fix for a live
> break — which is what the original box guessed, for the wrong reason.
>
> **★ And the mutation check caught a bug the fix itself introduced.** A
> rendered port's filename routinely contains a space (`Catppuccin
> Mocha.xccolortheme`), which an unquoted `[ -e ]` reads as two arguments — so
> the first version of this assertion failed the build on a file that was
> *there*. **A referent check is a new place for the referent's own shape to bite
> you**, and it was only visible by mutating against the real `mbp` host's
> roster, not the synthetic one the flake checks use.
>
> **§5.11's last two boxes, and the one that wasn't the rendering job it was
> filed as.** `haus doctor` grew a `Permissions` section — Accessibility, Full
> Disk Access, Automation, each with its `x-apple.systempreferences:` pane; they
> had been three grants in three sections with no link between them, and FDA
> moved rather than being stated twice. Automation is the first row with **no
> readable state at all** (every API that answers it prompts, and prompting from
> a health check is worse than not knowing), so it reports whether anything on
> this machine will *ask* and links the pane regardless: a checklist may not be
> able to check, but it can always say where.
> The other box was filed as "the data half is done and this is now a rendering
> job." Half right. `plan_restarts` already read killalls, `activateSettings` and
> the notification posts out of the built script — but the map's `logout`
> sentinel was subtracted in core and then **vanished**, so there was nothing for
> a reader to find. ★ **A verb that renders to nothing is not a rendering
> problem**, and this is the same silence §5.6 refuses to ship a settings *group*
> into, left wide open to a domain arriving the other way, through `haus capture`
> into a host's own `CustomUserPreferences`. Activation announces those domains
> now and `plan` reads the announcement back out of the built script — the
> reader stays "grep what a rebuild actually runs", so no second copy of the map
> comes into existence.
>
> **Housekeeping, in this file's own shape 1.** The naming banner told readers
> `compose` was "the live candidate" and what a second rice in `/desktops` should
> wait on; §6(e) had **decided against building it on 2026-08-05**, in the same
> pass that measured it buildable. Corrected in place, with what actually binds a
> second entry named instead (§6(f)'s silent blend on list- and attrs-valued
> options — the failure mode with no check and no story). The sixteenth pass's
> locale bullet still called restart-map's third verb "the gating work item"
> after rice#267 shipped it; amended. **Both are the same drift the fourteenth
> pass found in the phase summary: a claim written at the top of a file, about a
> section further down, that nothing keeps true when the section moves.**
>
> Verified by running it: 22 `nix flake check` checks green with
> `accent-reach`/`scale-reach`/`font-reach` byte-identical, a real `bench try`
> against `mbp`, three mutation checks each reverted and re-proved, `haus doctor`
> run from the built binary, and shellcheck clean of anything new. Not verified,
> and left where this file always leaves it: whether the three deep links still
> land on the right System Settings panes on macOS 26 — `open` accepts the URLs,
> but the pane is an eye-check, alongside §5.6's still-open `lock`/`menuBar` one.
> (One of the three has since been confirmed by hand: `?Privacy_Automation`
> lands correctly on 26. `?Privacy_Accessibility` and `?Privacy_AllFiles` are
> still unchecked.)
>
> **Status, 2026-08-08 (sixteenth pass) — §5.6's last unspiked box is closed:
> Sound, Locale/input sources and Power are all reachable, and the reason given
> for deferring each of them was wrong.**
>
> This is a **notes-and-probes pass, nothing shipped in the rice.** The eleventh
> pass (below) deferred these three groups because "no domain for any of them
> has been spiked for effect on this machine at all (typed or not), so there is
> nothing yet to curate honestly, only to guess at" — a good rule that was
> applied to a false premise. All three have typed nix-darwin surfaces: **Sound
> two keys, Locale four, Power six.** The check that would have caught it is
> `grep mkOption modules/system/defaults/*.nix modules/power/*.nix`, which costs
> less than the spike it was used to postpone. ★ **The transferable bit: a
> deferral needs its premise verified as hard as a shipped option does.** This
> document's own "verified, not remembered" language protects what we build and
> not, until now, what we decline to build.
>
> Three probes and two oracles are on the shelf
> (`notes/probes/{sound,locale,power}-sweep.sh`, `locale-effective.swift`,
> `tis-toggle.swift`); the full results are in
> [`macos-settings-matrix.md`](./macos-settings-matrix.md#sound--localeinput-sources--power--swept-2026-08-08).
> The two `defaults`-based scripts snapshot, restore, and then compare every
> touched key's XML fragment (value *and* type) against the snapshot before
> claiming success; the machine ends byte-identical, as with every sweep in that
> file. `power-sweep.sh` writes nothing at all unless you ask it to
> (`POWER_SWEEP_WRITE=1`), because its write is root-level and per-machine.
>
> **What the spike found, in the order it changes decisions.**
>
> - ★ **The missing piece for Locale is not a key — it is a distributed
>   notification.** A `defaults write` reaches newly launched processes only; a
>   running app never notices, not even through `Locale.autoupdatingCurrent`,
>   the flavour documented to track changes. Posting
>   `AppleDatePreferencesChangedNotification` immediately after the write flips
>   it within one sample, and a made-up notification name does nothing. This is
>   the first setting family whose "restart" is neither a `killall` nor a
>   logout, so `modules/lib/restart-map.nix` (rice#249) needs a **third verb**
>   before this group can ship honestly. That is now the gating work item, and
>   it is small. → ✅ **Built, and the group shipped with it (rice#267).** The
>   verb is `notify:<DistributedNotificationName>`, and the map's locale entry
>   carries both it and `activateSettings` — the two do different jobs (one
>   invalidates a cache, one tells running apps), which is why it's a list and
>   not a replacement. Anyone re-reading this bullet for "what's left" should
>   read the map, not this paragraph.
> - **`com.apple.sound.beep.volume` is `e^(slider − 1)`, not a fraction** —
>   `0.5` is 31% and anything at or below `e⁻¹ ≈ 0.368` is silence. nix-darwin's
>   docstring lists 75/50/25% as three magic constants and never names the
>   curve. A curated `sound.alertVolume` takes 0–100 and converts; exposing the
>   typed float would ship a lie that reads as a bug in *our* option. Same key
>   is written back by the volume keys, so it is also a two-writers leaf (§5.7's
>   question, inside a settings group).
> - **A bad `beep.sound` path is SILENCE, not a fallback** — settled by ear
>   2026-08-08 (control beeped, Submarine beeped, `/nope/does-not-exist.aiff`
>   did not). So `sound.alertSound` must validate its path at eval time, or take
>   an enum of the 14 names in `/System/Library/Sounds` and build the path
>   itself. Same family as `screencapture.location`'s missing directory, worse
>   consequence: there you find your screenshots on the Desktop, here the
>   machine just stops making the sound you asked for.
> - **`AppleMeasurementUnits` is typed, friendly, and inert.** Of the four typed
>   region keys it is the only one that moves nothing measurable, and it is the
>   one a rice reaches for first (`Inches`/`Centimeters` enum). `AppleMetricUnits`
>   is load-bearing. §5.6's "what second key makes the first a lie", with the
>   roles reversed — here the *decorative* key is the well-typed one.
> - **`AppleFirstWeekday` lands and lies**, the second dict-valued key to do so
>   after `FontSizeCategory`. Promoting that to a rule: **treat structured keys
>   in Apple's global domain as GUI-only until one proves otherwise.** Set
>   `AppleLocale` instead — it moves hour format, measurement system and first
>   weekday together, and is the group's real lever (untyped →
>   `CustomUserPreferences`).
> - **Input sources are settable from a plist, and the authoritative-looking key
>   is the decorative one.** `AppleEnabledInputSources` resolves a layout by
>   `KeyboardLayout Name`; the `KeyboardLayout ID` beside it must merely be
>   *present* and is never validated (`99999` works fine). Exact inverse of the
>   hot-corners finding. And the name isn't derivable from the input-source id
>   (`com.apple.keylayout.SwissFrench` → `"Swiss French"`), so a hand-typed table
>   in Nix would be wrong for precisely the layouts nobody here tests: the option
>   should take the stable `com.apple.keylayout.*` id and resolve it through the
>   documented TIS API at activation.
> - ⚠️ **Power is typed, source-blind, and on this machine it does not work at
>   all.** `power.sleep.*` and `power.restartAfter*` shell out to `systemsetup`,
>   not `system.defaults` — the `security.firewall` family, not the `hotCorners`
>   one. No `systemsetup` verb takes a power source, while macOS stores battery
>   and AC separately, so "sleep at 5 min on battery, never on AC" — the only
>   opinion a laptop rice has — is not expressible. ★ **And the missing selector
>   is not neutral: measured, `systemsetup -setcomputersleep 17` run while the
>   machine was on BATTERY wrote the AC profile and left battery alone.** So
>   `power.sleep.computer` configures a power source the config never named,
>   silently, while `pmset -b`/`-c` does exactly as told. nix-darwin also sends
>   every call to `&> /dev/null`, and `systemsetup` really does emit an
>   Admin-framework `-99` on stderr — even on a write that succeeds — so there
>   is live content in a stream nobody reads. Worth filing upstream. Low Power
>   Mode, lid behaviour and per-source anything are `pmset`, root-only, untyped
>   regardless.
>
> **★ The Power row has now produced three confident wrong answers, and that is
> the most useful thing in this pass.** Section C is opt-in behind
> `POWER_SWEEP_WRITE=1` (an env gate, not a sudo-cache check, so a warm
> timestamp can't make an agent run it by accident).
>
> - **Run 1** — `systemsetup` applied nothing → *"nix-darwin ships six silent
>   no-ops, file it upstream."*
> - **Run 2**, with a `pmset` control — pmset applied nothing either → the
>   *setting* is pinned on this Mac, and run 1 was never evidence about
>   `systemsetup`. **A failed write says nothing about the writer until a second
>   writer has failed the same way and a second setting has succeeded**: the
>   negative-result twin of this document's "the write succeeded ≠ it took
>   effect".
> - **Run 3**, the full 2×2 — four timer writes failed and `pmset -a
>   lowpowermode 1` **landed**, same shell, same run, same root. That clears
>   privileges and `pmset` itself… except the four failures were read from
>   `/Library/Preferences/com.apple.PowerManagement.plist` and the one success
>   from `pmset -g custom`. **Two oracles, opposite verdicts.**
> - **Run 4**, reading `pmset -g custom` — **every write had been landing all
>   along.** The plist is a file `powerd` flushes on its own cadence; the probe
>   caught it in the act on the way out, printing `computer AC=18(file:1)`.
>
> ★ **Four runs, three wrong conclusions, and not one was a macOS surprise —
> all three were measurement errors.** A single row read as a verdict; a
> negative result with no control; and finally two oracles inside one table,
> which is not a cross but two experiments sharing a heading. The rule, which
> generalises well past power: **where a domain exposes two readable states,
> decide which one is the oracle before running anything, and never let one
> table's rows be judged by different readers.** The PowerManagement plist is to
> this section what `com.apple.Accessibility` was to §4 — the thing that reads
> like evidence and isn't.
>
> **And the real limit turns out to be sharper than "source-blind".**
> `systemsetup -setcomputersleep 17`, run while the machine was on **battery**,
> set the **AC** profile and left battery alone. So `power.sleep.computer`
> doesn't merely fail to express battery-vs-AC — it writes a profile the config
> never named, silently, while `pmset -b`/`-c` does exactly as told. That is a
> correctness bug worth filing upstream, and it is the reason a curated group
> must be built on `pmset`.
>
> **What this unblocks.** §5.6's rule — no unspiked domain gets curated — is now
> satisfied for every row in its table except the two deliberately-deferred
> logout-only ones (`loginwindow`, `WindowManager`). Sound is buildable today.
> Locale is buildable once restart-map learns `notify`. Power is buildable as an
> activation step of the rice's own, and should not pretend to be a
> `system.defaults` group.


> **Status, 2026-08-08 (fifteenth pass) — §5.1's macOS Light/Dark box is shipped,
> and the spike falsified the box's own premise: `AppleInterfaceStyle` is inert in
> BOTH directions on macOS 26, not just the "off" one.**
>
> This is the box the fourteenth pass (below) deliberately left open and handed
> to Julien — *"whether that box gets escalated in prose or simply built is
> Julien's call, pending."* It was built. Worth noting which half of that pass's
> reasoning held: it was right that rice#249 cleared the **stated** blocker and
> right that rice#252's palette row made the gap one click deep — and wrong, in
> good faith, to inherit the box's account of *why* the gap existed. The audit
> checked whether the blocker had cleared; nobody had checked whether the blocker
> was real.
>
> **What shipped ([haus#257](https://github.com/hausfold/haus/pull/257)).**
> `haus.theme.systemAppearance` — `unmanaged` (default) / `flavor` /
> `light` / `dark`. `"flavor"` is the one that makes light mode complete: latte
> sets macOS to Light, mocha to Dark, so a latte rice stops looking half-done on
> a dark Mac. Applied from home-manager activation via System Events, guarded and
> idempotent; `hausax` grew an `appearance` key and is the oracle.
>
> **★ The finding is the valuable part, and it is the reverse of what this doc
> said for eleven passes.** The box claimed dark-on was one typed setting and
> dark-off was the impossible half. Measured on real hardware with a probe
> watching `NSApp.effectiveAppearance` and subscribed to
> `AppleInterfaceThemeChangedNotification`: **neither direction works.** Writing
> `Dark` from a light session and deleting the key from a dark one both change
> nothing — through `activateSettings -u`, through a `killall SystemUIServer`,
> and for a process launched *fresh* afterwards, with no notification posted
> either time. The key is a mirror the appearance system writes on its way past.
> `system.defaults.NSGlobalDomain.AppleInterfaceStyle` is a dead option on macOS
> 26. A plausible asymmetry story survived this long precisely because it
> explained the observed behaviour ("light rice, dark Mac") correctly while being
> wrong about the mechanism — §5.14 should count "a stated blocker nobody
> re-measured" as its own drift shape.
>
> **Phase 4 was the stated blocker and turned out not to be the enabler.**
> `restart-map.nix` gets a documented entry, but its honest content is "no
> restart can make an inert write live". The map answers *what makes a write
> live*; it has nothing to say about a key macOS doesn't read. Generalisable: an
> unreachable setting has at least two causes, and only one of them is a missing
> restart.
>
> **What this does and doesn't close.** The default is `"unmanaged"` on purpose —
> a managed default would silently revert an appearance picked in System Settings
> on the next rebuild. Which left pounce's one-click "Switch to light mode"
> (§5.7's audience) still landing on a dark macOS — **closed in the follow-up,
> [haus#258](https://github.com/hausfold/haus/pull/258)**: `haus set`
> takes PAIRS now (`haus set theme.flavor latte theme.systemAppearance flavor`),
> all-or-nothing, one rebuild, and the palette row sets both. The reason it had
> to be one call rather than two lines in the runner is the interesting part —
> `haus set` rebuilds per call, so two calls is two rebuilds *with the machine
> sitting in the half-done state in between*. Driving System Events also needs an
> Automation grant, degrading to a named warning — the same reachability shape as
> `accessibility.increaseContrast`'s FDA caveat. (§5.12 had decided not to promote
> that into a typed field; it reversed on 2026-08-14, so Automation is now the
> obvious second row for `modules/lib/reachability.nix` — a `needs-automation`
> reachability whose `guardedBy` is `haus.theme.systemAppearance`. Not built:
> nothing measures an Automation grant without prompting, which is the same wall
> `haus doctor`'s Automation row already hit, so the table would carry a
> designation with no reader for it yet.)
> **Status, 2026-08-08 (fourteenth pass) — an audit pass, not a shipping one.
> Nothing new was built; two claims in this file were wrong, the phase summary
> had drifted from the sections it summarizes, and this pass's own first finding
> was wrong and had to be retracted before the PR opened.**
>
> Run the §5.14 way — reading every commit across the family since the
> thirteenth pass's work rather than diffing the checkbox list. The window is
> small (rice #254/#255 + the 2026.08.08 release, nebelung#29, pounce#65,
> perch#36/#37, holt's SDK run — nebelung#29 and pounce#65 landed *before*
> rice#253 merged, so "since the thirteenth pass" is by write-up date, not by
> merge order), and the findings that survived all came out of commit *bodies*,
> not diffs.
>
> **★ Finding 1 — RETRACTED, and the retraction is the finding.** This pass
> first reported that `accent-reach`'s `glow` row had been a false green for
> seventeen minutes on 2026-08-07: rice#247 shipped the accent-matrix path
> `glowStyle = "${nebelungRoot}/glow/themes/<flavor>/catppuccin-<flavor>-<accent>.json"`
> at 06:15 while its lock pinned nebelung at `4ea4fa4`, which is not
> nebelung#29's merge commit (`2110fac`, 06:13) — so the JSON looked absent and
> the check looked green anyway. **The pre-PR assurance pass killed it.**
> `4ea4fa4` *is* nebelung#29 — its own PR-branch head, tree-identical to the
> squash (`git diff 4ea4fa4 2110fac` is empty) — and rice#247 bumped the pin in
> the very same commit that introduced the path. glow resolved the whole time;
> the check's green was correct.
>
> **The rule that mistake earns: a lock rev that isn't the upstream's main rev
> is not evidence of a stale pin, and this file's audits keep reaching for revs
> where the question is about trees.** Squash-merge guarantees the rev you
> locked pre-merge never appears on main, so "the lock doesn't point at the
> merge commit" is the *normal* state for anything pinned from a PR branch, not
> a smell. The check is `git diff <lockrev> <mainrev>`; comparing hashes proves
> nothing. That is a cheaper lesson than the one this pass thought it had.
>
> **★ And the same evidence does hold a real hazard, one the retraction
> surfaced.** For those seventeen minutes rice `main`'s lock pinned a nebelung
> rev that existed **only on an unmerged PR branch**. It is still fetchable today
> purely because that branch was never deleted (`origin/worktree-bdab`) — and
> GitHub deletes head branches on merge by default, which is the premise holt's
> whole `reship` story is built on. A merge-and-delete inside that window would
> have left rice `main` unable to fetch nebelung at all: not a silent wrong
> colour, a repo that doesn't evaluate. **Pinning a downstream lock at a rev
> that is not yet on the upstream's `main` is the actual cross-repo hazard
> here**, it is invisible to every check in the family, and §7's ripple story
> doesn't cover it because `bench ship` only ever bumps to merged HEADs — this
> came from a hand-run `nix flake update` inside a PR.
>
> **What survives of the original observation, as design reasoning rather than
> an incident:** Nix does interpolate a store path into a string without
> asserting anything is there, so `accent-reach`'s `glow` row *would* read
> `moves` even with the referent missing — it fingerprints the plugin file's
> text, and the accent varies only inside a path. No such break has happened.
> The cheap belt is one line in the existing `glowPlugin` `runCommand`
> (`[ -f ${glowStyle} ]`), and the file already half-knew: the `zed` row carries
> a comment calling itself "the one row whose fingerprint is a FILENAME rather
> than a file's contents", noticed and then not generalized.
>
> **★ Finding 2 — the tenth pass's own headline claim was half false, and
> rice#255 corrected it.** That block says core's restart commands are
> "read out of `config`, not hardcoded, so a future module gets this for free."
> True of the **domains**, false of the **processes**: #249 then filtered the
> map's values through `restartProcesses = [ "Finder" "ControlCenter"
> "SystemUIServer" ]`, an allowlist that had to be edited in lockstep with the
> map — so the day a domain's value named a process not on the list, the map
> said "restart X" and core silently dropped it. That is precisely the
> hand-maintained gap `restart-map.nix` exists to close, reintroduced one file
> over, and #250's own comment had already noticed the smell ("`restartProcesses`
> has carried ControlCenter unused since rice#249") without drawing the
> conclusion. #255 inverted it to subtract the four sentinels
> (`Dock`/`activateSettings`/`none`/`logout`) instead. The lesson is narrower
> than "check your allowlists": **a table plus a filter over that table is two
> sources of truth wearing one name**, and the tenth pass's own closing
> paragraph had flagged the shape (`haus revert-settings` hand-rolls the same
> triad) while missing this instance inside the file it was describing.
>
> **Finding 3 — §5.1's recommended pattern needs a condition.** That section
> sells `theme.ports.handled` — rooms declaring what they already wire by hand —
> as "the pattern to copy for any future generic-pass-plus-hand-tuned-exceptions
> option." rice#255 found its failure mode: #251 made the gh-dash integration
> opt-in (`terminal.ghDash.enable`, default false) but claimed the port as
> `handled` unconditionally, so a machine with the integration **off** got no
> theme (the roster pass had been told to skip it) *and* no `haus doctor` nudge
> (it had been told a room handles it). A `handled` claim has to be gated on the
> same flag that does the wiring; an unconditional one converts an opt-in
> feature into a silent hole in two systems at once. Noted in §5.1's box.
>
> **Housekeeping — the phase summary was stale, in the doc's own shape 1.**
> Phase 4 and Phase 5 still read fully-unstarted for §5.6 (rice#250 shipped
> three of the seven groups still open after rice#198, taking the table to five
> of nine), §5.9's pounce half (pounce#43) and §5.11 (all four commands shipped
> *and felt*, rice#248 — its own section header says so).
> §5.6's header still carried "gated on §4" after rice#249 removed that gate.
> All corrected below. This is the failure §5.14 was written about, recurring in
> the summary list rather than in a section: **the phase list is a second
> checkbox surface, and nothing was keeping it honest.**
>
> **Not touched this pass, deliberately:** §5.1's macOS Light/Dark box. Its
> stated blocker — "an activation-script `defaults delete -g` plus the restart
> map, i.e. Phase 4" — cleared when rice#249 landed, and rice#252 has since put
> **Switch to light mode** in the palette writing `theme.flavor = latte` alone
> (`modules/launcher/commands/settings.sh:21`), so the asymmetry is now reachable
> by one click from the non-technical user §5.7 exists for. Whether that box
> gets escalated in prose or simply built is Julien's call, pending.
>
> **Status, 2026-08-07 (thirteenth pass) — §5.4's last open box, a real workspace
> model, is shipped: Phase 3 now has no unstarted item.**
>
> **What shipped ([haus#253](https://github.com/hausfold/haus/pull/253)
> + a paired, currently-draft [nix-config#45](https://github.com/JulienMartel/nix-config/pull/45)).**
> `haus.workspaces` is a real, first-class option now: `roster.*.workspace`
> and `roster.*.barIcon` are gone — a workspace names its own member apps
> (`apps = [ "slack" "mail" "messages" ]`) instead of one app claiming a
> workspace, so a role or project workspace is representable for the first
> time. `roster.*.float` (+ `titleRegex`) also generalizes the second half of
> this box — window rules beyond assignment — replacing the three hand-hardcoded
> always-float `aerospace.toml` rules with the same data-driven shape
> auto-assignment already used.
>
> **★ No back-compat alias, and that was the risky part §5.4's own text warned
> about — done anyway, on instruction.** The original sketch proposed
> `roster.<id>.workspace` desugaring into the new option so existing hosts
> wouldn't break; Julien is the only consumer of this rice and said explicitly
> not to bother — a clean rename, migrate his own host file, no sugar nobody
> but him would ever use. That's the harder-to-undo version of this migration,
> which is why it stayed §5.4's last box through ten prior passes: "the one
> item here that can break a live host if done carelessly" (this section's own
> earlier words) meant reading the whole section before touching a line, not
> just the open checkboxes — the shift-throw binding namespace had to move off
> the app entirely (a workspace's own `key`, not its one owning app's), which
> the sketch above never mentioned and only surfaced from tracing every
> consumer (windows, bar, the doc generator, pounce's `add-app.sh`, the shipped
> `packs/writing.nix` example) by hand.
>
> **`center` and `sticky` are checked off as verified-infeasible, not shipped.**
> AeroSpace has no command to position or resize a floating window's geometry,
> and no primitive for a window visible across every workspace — its own docs
> call sticky windows "not yet supported." Confirmed against upstream before
> writing either off, so the box closes on a citation instead of staying open
> because nobody got to it.
>
> **What this does and doesn't close.** A pack still can't claim a workspace
> for its own apps — `checkPack` only carries `haus.roster` through
> `lib.pack`, and extending it to `haus.workspaces` (where `apps` needs
> list-merge semantics every other pack field doesn't) is real follow-up work,
> not done here; `packs/writing.nix` and its README now say so explicitly
> rather than silently going stale. `monitor` / `layout` from the original
> sketch didn't ship either — nothing needed them this pass, and per-workspace
> monitor pinning is its own feature with its own risk (bridging AeroSpace's
> monitor matching against `haus.displays`' UUID vocabulary).
>
> Verified on the real machine, not just through an evaluator: a full build of
> the actual `mbp` host against this branch finished with zero warnings, the
> generated `aerospace.toml` and `sketchybar/workspaces.sh` were read back and
> checked against pre-migration output line-for-line, and `nix flake check
> --all-systems` stayed green throughout (`presets`, `packs`,
> `data-only-surface`, `preset-composition`, `keymap`, `theme-variants`,
> `accent-reach`, `font-reach`, `scale-reach`). §5.4 has the full account,
> including the five new assertions each exercised by hand and why the
> consumer-side PR is deliberately a draft rather than red.
>
> **Status, 2026-08-07 (twelfth pass) — §5.7 is built: the machine-writable
> overlay is ordinary Nix, and the palette has its first settings front door.**
>
> **What shipped ([haus#252](https://github.com/hausfold/haus/pull/252),
> docs [workshop#247](https://github.com/hausfold/workshop/pull/247)).** `mkHaus` now auto-imports
> `hosts/<host>/settings/*.nix` beside the existing `packages/*.nix` seam.
> `haus set theme.accent teal` writes one managed module there, stages it so a
> git-backed flake can see it, evaluates the machine's own option tree to reject
> an unknown path or bad value, then takes the normal build-before-switch
> `haus rebuild` path. There is still one source of truth: the generated Nix file
> IS the setting; no JSON or mutable state database exists beside it.
>
> **★ The priority is part of the feature.** A plain definition would collide
> with `large-print` (and any future preset that names the same option), because
> module import order is not priority. The overlay writes `lib.mkForce`: this is
> the machine owner's explicit answer and it has to beat a rice. `haus reset
> <path>` removes that answer and reveals the host/preset/rice value underneath;
> `haus unset <path>` is deliberately different and writes `null`, so the module
> system accepts it only for nullable options. `haus get <path>` reads the fully
> evaluated declaration, while bare `haus get` lists only overlay-owned values.
>
> **The boundary is executable, not prose.** Both `theme.accent` (short form)
> and `haus.theme.accent` resolve inside the same namespace; `system.*`, an
> unknown `haus.*` leaf, unsafe path syntax, and a type-invalid value all
> fail before activation. The integration test raises a real temporary consumer
> flake and proves string + number writes, nullable unset, reset-to-default,
> invalid enum rollback, and the non-haus guard through evaluation — not by
> grepping the emitted file alone.
>
> **The Pounce last mile came with it.** A `Haus Settings` submenu exposes the
> three §5.7 actions — **Make text bigger**, **Switch to light mode**, and **High
> contrast on** — and delegates all persistence, validation, and rebuilding to
> `haus set`. The palette does not grow a second implementation of settings.
>
> **Proof and the remaining feel-test.** `nix flake check`, the dedicated
> integration test, shellcheck, and a full consumer system build are green. A
> plain `bench try` was also attempted; it reached and built the new `haus` and
> Pounce command derivations, then the unrelated local Holt override failed
> because its newly nested `sdk/go` module is being treated as a root Go package.
> Repeating the same full consumer build with the last pre-Go-SDK Holt revision
> succeeded. Activation stays Julien's call, so the final live proof is still:
> `bench try switch`, make a macOS-backed change with `haus set`, then use the
> already-landed `haus diff` to prove the running generation matches effective
> state rather than merely eyeballing the generated file.
>
> **Status, 2026-08-07 (eleventh pass) — §5.6, unblocked by the tenth pass's
> restart map, ships three curated behaviour groups; four remain unbuilt, two
> of them deliberately.**
>
> **What shipped ([haus#250](https://github.com/hausfold/haus/pull/250)).**
> `haus.lock` (screensaver password + delay), `haus.menuBar.{clock,
> controlCenter}` (clock format/seconds/date/analog + which Control Center
> glyphs show) and `haus.security.firewall` (wraps nix-darwin's
> `networking.applicationFirewall`) — three of §5.6's seven still-open groups,
> named and scoped the same way `hotCorners`/`screenshots` already were: every
> leaf null by default, action names instead of raw plist values, restart
> behaviour read out of `modules/lib/restart-map.nix` rather than hand-rolled
> per group.
>
> **Two things gated this pass, both from the task brief rather than the code:
> check the restart map landed first, and don't ship a group that silently
> needs a logout.** The first was easy — #249 (the tenth pass, below) landed
> the same day. The second shaped the actual scope more than anything else:
> `com.apple.loginwindow` (the LOGIN half of "Lock / login / screensaver") and
> `com.apple.WindowManager` (all of "Windows") are both declared `"logout"` in
> the restart map, with no live-reload path on macOS 26. Rather than ship them
> anyway with a "requires logout" note in the description — which the codebase
> had no established pattern for at the time, unlike `haus.accessibility`'s FDA
> note (there is one now: `modules/lib/reachability.nix`, §5.12) — both are
> left out entirely, and §5.6's table now says so in place of
> the group. **Sound**, **Locale/input sources** and **Power** are left out for
> the opposite reason: no domain for any of them has been spiked for effect on
> this machine at all (typed or not), so there is nothing yet to curate
> honestly, only to guess at.
>
> **★ Not every shipped group could be verified the way hot corners and
> screenshots were.** Both of those inherited a restart nix-darwin already
> performs (Dock) or need no restart at all (screencapture re-reads per
> capture). `lock` and `menuBar` are the first groups here whose restart is
> `killall`-a-process-and-hope — plausible (Finder gets the identical
> treatment), backed by nix-darwin's own precedent, but not measured against an
> effective-state oracle the way `reduceMotion` was in the §4 matrix, because
> no cheap oracle exists for "did the menu bar clock re-render". Recorded
> honestly in `restart-map.nix`'s own comments and as an open box below, rather
> than claimed. `security.firewall` doesn't have this problem at all — it
> isn't a plist write, `socketfilterfw` is a live command nix-darwin already
> runs unconditionally in its own activation script, so none of the
> restart-map's uncertainty applies to it.
>
> **Verified:** `nix flake check` green on the PR branch, including a real
> `presets` darwin-system build (not just an evaluator) — the same bar the
> eighth pass set for limit 3. **Not verified:** `bench try switch` and an
> eye-check that the new groups actually take effect live, both left to
> Julien per this repo's own worktree etiquette; `bench try` (the full `mbp`
> host) is currently blocked by an unrelated, pre-existing break in the local
> `holt` checkout (`sdk/go` package layout), not by anything in this pass.
>
> **Status, 2026-08-07 (tenth pass) — §4's last open box, the restart map, is
> built and generalized past the one hand-rolled fix it started from.**
>
> **What shipped ([haus#249](https://github.com/hausfold/haus/pull/249),
> `modules/lib/restart-map.nix` + `modules/core/default.nix`).** The matrix's own finding — nix-darwin restarts
> only Dock, and only when a `dock.*` option changed, so Finder/menu-bar/Control
> Center writes silently wait for a logout — had exactly one fix in the repo
> before this pass: rice#181's hardcoded `killall Finder`, called out in §5.2's
> own text as "the first entry in §4's restart map, written by hand rather than
> as the map." It's now a declared table: every plist domain the rice writes
> maps to `killall <process>` / `activateSettings`-only / `none` / `logout`, and
> core's postActivation generates its restart commands from that table against
> whichever domains the built configuration actually has (typed domains the
> rice always sets via `mkDefault`, plus whatever `CustomUserPreferences`
> top-level keys any module or host contributed — read out of `config`, not
> hardcoded, so a future module gets this for free).
>
> *(Corrected on the fourteenth pass: true of the domains, **false of the
> processes**. #249 filtered the map's values through a hardcoded
> `restartProcesses` allowlist, so a future module naming an unlisted process
> got its restart silently dropped — not "for free" at all. rice#255 inverted it
> to subtract sentinels instead. See finding 2 at the top of this file.)*
>
> **★ The generalization has teeth, not just a data file — and the first
> version of those teeth was too sharp.** A first draft made an undeclared
> domain a hard `assertions` failure; the **pre-PR assurance pass caught that
> this breaks a real, documented workflow**: `haus capture <domain>` lets a
> consumer snapshot *any* plist domain into their own host file's
> `CustomUserPreferences`, which the map has no way to know about in advance,
> so the hard assertion would fail their `haus rebuild` over a file inside the
> pinned haus flake input they cannot edit. Fixed the same PR, one commit
> later: an undeclared domain is now `warnings`, matching the pattern the
> `universalaccess` block already uses just below it in the same file — "don't
> block a config that would otherwise work."
> *(The cited precedent has since moved: `universalaccess` **does** block now,
> at `haus rebuild` rather than at eval — §5.12, 2026-08-14. The rule is
> unchanged and this is the same rule applied, not an exception to it: that
> config would **not** otherwise work, it would abort activation partway and
> strand the machine, and the block arrives before anything is built with an
> escape hatch beside it. An undeclared restart-map domain, by contrast, still
> works perfectly — it just waits for a logout — so it stays a warning. What
> the tenth pass got right is what decides both: **ask who the check can fail
> on.** For universalaccess the answer is "someone whose rebuild was going to
> fail anyway, one step later and much worse".)*
> **A generalized check still needs
> to ask who it can fail on**, not just whether it fires correctly — the same
> lesson §5.14 has drawn from drift before, from the opposite direction (a
> check too soft to catch anything) rather than this one (a check hard enough
> to break someone else's rebuild).
>
> Proved on the real machine both ways, not just read through: a clean `bench
> try` (real `darwin-system` build, not an evaluator) went green, the generated
> `activate` script's `killall -qu … Finder` line was traced straight to this
> mechanism in the built output, and deliberately deleting a domain from the
> map reproduced the intended signal in both forms — a build failure with the
> hard-assertion draft, then a warning with the build still succeeding after
> the fix. Same mutation-check discipline `accent-reach`/`data-only-surface`
> already use elsewhere in this doc, applied to a spike finding instead of an
> option — and this time the mutation check is also what caught the check's
> own design mistake.
>
> **What this does and doesn't close.** `WindowManager` stays tagged `logout`
> in the map — the matrix found no live-reload path for that domain on macOS
> 26 and this pass didn't find one either, so it's declared rather than
> attempted. `haus revert-settings` (§5.11) still hand-rolls its own
> Dock/Finder/`activateSettings` triad in `haus.sh` rather than reading this
> same map — a second hand-maintained copy of the identical logic, left as-is
> since it's bash reading a Nix table and out of this pass's scope, but it's
> the next place this exact "one fix, not yet the pattern" shape could recur.
> §4 itself is now fully checked; §5.6 (curated settings groups) was gated on
> this landing and can proceed.
>
> **Status, 2026-08-07 (ninth pass) — §5.11 Reversibility built and felt: `haus
> plan`/`capture`/`diff`/`revert-settings` are real subcommands, and the headline
> risk they exist to catch (a settings diff that trusts the plist) was reproduced
> and caught on this machine, not just reasoned about.**
>
> **What shipped.** All four promote exactly what §5.11 named as already existing
> ad hoc: bootstrap.sh's `preflight_audit` → `haus plan`, its `HAUS_KEEP`
> current-value reader → `haus capture`, plus two genuinely new commands,
> `haus diff` and `haus revert-settings`. The comparison engine underneath
> `plan`/`diff` (`declared_defaults`) does **not** hand-map nix-darwin's ~193
> typed keys to plist domains — the matrix's own count of that surface was a
> warning that a hand-copied table would drift the moment upstream added one.
> Instead it parses the **built activation script itself** (`defaults write
> DOMAIN KEY '<xml…>'`, one uniform shape nix-darwin's own generator emits) —
> ground truth that can't go stale, verified against the real `/run/current-
> system/activate` on this Mac: all 47 `defaults write` calls it currently
> contains parsed correctly, one of them a dict value (`FXInfoPanesExpanded`)
> that the parser correctly flags as un-comparable rather than silently
> mis-reading.
>
> **★ The §4/§8 finding — "diff must compare effective state, not plists" — is
> now executable, not just documented.** A new probe binary, `hausax` (same
> compile-with-xcrun shape as `hausdisp`), wraps the exact `NSWorkspace` read
> the matrix's spike used, and `haus diff`/`haus plan` route the four keys
> measured to have a write-vs-effect gap through it instead of `defaults read`.
> Proved with a synthetic activation script exercising all four verdicts at
> once on the real machine: a plain key mismatch (`dock.orientation`) printed
> as an ordinary change; `universalaccess.reduceMotion` declared `true` against
> `hausax`'s real (false) reading was caught and reported as a **NSWorkspace
> mismatch, not a plist one**; a `com.apple.Accessibility` write was flagged
> **"KNOWN SILENT NO-OP"** without comparing it at all, since the matrix proved
> that domain lies regardless of what the plist says; and
> `mouseDriverCursorSize` (persists, effect never confirmed) was reported as
> **unconfirmed** rather than either a false match or a false mismatch. Four
> distinct, correct verdicts from one real run — this is the concrete
> reproduction of the exact failure mode §4 found (`haus rebuild` succeeding,
> the plist agreeing, the Mac unchanged) that a plist-only diff would have
> silently called "applied."
>
> **★ A `set -e` bug the design itself would have hidden, caught only by
> running it.** `defaults read` on an unset key — the common case for
> `unconfirmed`-class keys like `mouseDriverCursorSize`, which nothing on this
> machine sets — exits non-zero, and under `haus.sh`'s existing
> `set -euo pipefail` that aborted `settings_diff` **silently partway through**,
> before printing anything for the keys after it. Every `defaults read` call
> and the two `grep | while` extractors now have an explicit `|| true`, with a
> comment at each site naming why ("an unset key is the common case, not a
> script error"). This is the sharpest reason to distrust an untested read of
> this exact code: the bug was invisible in the diff, only visible in the
> terminal. A second instance — `revert-settings`'s own `killall Dock/Finder`
> and `activateSettings` calls, the same `[ cond ] && risky-command` shape —
> was caught the other way, by re-reading the diff against `core/default.nix`'s
> own `|| true` convention for the identical calls, not by running it. Neither
> method alone would have found both.
>
> **`haus capture` generalises past the three named categories, not just past
> "runs once at install."** `dock`/`keyboard`/`finder` still emit the same
> typed `system.defaults.<room>.<key>` lines bootstrap.sh always did (ported,
> not reinvented — bootstrap keeps its own copy since it runs before `haus` is
> on PATH). Any other argument containing a `.` is read as a literal plist
> domain and emitted through `system.defaults.CustomUserPreferences` — the
> escape hatch nix-darwin already ships for exactly this — with nested
> (array/dict) values called out as a comment rather than silently emitted,
> since JSON's `[a, b]` isn't valid nix list syntax and a broken generated file
> would be a worse failure than an honest gap. Felt against this machine's real
> `com.apple.screencapture` domain: three scalars captured correctly (a string,
> a bool, a float), one nested key correctly flagged instead of miscompiled.
>
> **`haus revert-settings` was proved to actually revert.** Not a design
> read-through: a scratch domain was set to a known value, `haus capture`
> snapshotted it (`defaults export`, byte-for-byte, not a replay of individual
> key writes), the value was changed again, and `haus revert-settings` put the
> *original* value back — read back and confirmed equal. The FDA-gated skip
> (`com.apple.universalaccess`/`com.apple.Accessibility` need Full Disk Access
> to restore, same as to write) and the partial-failure reporting (one domain
> restored, one missing file correctly reported as "restore failed", overall
> exit code non-zero) were both exercised directly, though with `has_fda`
> stubbed rather than this pane's own real TCC state — the logic is proved, the
> live FDA-denied path from an actual agent pane is not, which matches the
> asymmetry the matrix already named.
>
> **What this does and doesn't clear.** A real `bench try` (darwin-system
> build, not an evaluator) succeeded with these changes, and `nix-store -q
> --references` on the built `system-path.drv` confirms `hausax` lands beside
> `haus`/`haus-activate`/`hausdisp` exactly where `environment.systemPackages`
> puts it — so this is felt through the actual builder, the same bar the eighth
> pass set for limit 3. `nix flake check` is unaffected (still green: presets,
> packs, data-only-surface, preset-composition, keymap, theme-variants,
> accent-reach, font-reach, scale-reach). What is **not** felt: `bench try
> switch` and a real `haus plan`/`haus diff` invocation through the installed
> binary on a running generation — activation is Julien's call, not an agent
> worktree's, so that last mile is still open the way §6 would expect.
>
> **Left open, honestly.** §5.11's other two boxes — `haus doctor` growing a
> System Settings deep-link checklist, and restart/logout/reboot annotations
> from the §4 matrix surfacing anywhere — were not touched this pass. `haus
> plan`'s "packages" section is a bare closure diff (proven correct, reused
> verbatim from `haus rebuild`'s own mechanism) rather than a script-level
> preview of *what will restart* — the restart-map idea §4 raised is still
> unbuilt, and `plan`'s "scripts" promise from §5.11's own line is really just
> "settings + packages + casks" today, not a narrated list of what activation
> scripts will run.
>
> **Status, 2026-08-07 (eighth pass) — limit 3 was felt on a machine, not just
> an evaluator, and it held; plus an audit of everything that landed since the
> seventh pass.**
>
> **Limit 3, felt for real.** Every measurement of the pack/preset priority
> mechanism so far (`probes/pack-priority.nix`, flake.nix's `packCompose`,
> `preset-composition`) ran `lib.evalModules` over `modules/options-modules.nix`
> — the pure option **surface**, deliberately narrow so it's fast and
> Linux-capable. Nobody had run the actual thing a stranger's own flake calls:
> `mkHaus`, full home-manager and all, on a composition nothing here had
> tried — a preset **and** a pack **and** a host that already disagrees with
> the pack, together. Built (not just evaluated) from a haus child
> worktree: `flake.mkHaus { extraModules = [ flake.presets.everyday
> flake.packs.writing ]; host = <a file declaring roster.obsidian.key = "n">;
> }` — real `darwin-system` derivation, actually realised, not a drvPath.
> Result: **clean.** The host's key won (`"n"`), the pack's other three apps
> (zotero/anki/calibre) and Obsidian's `cask`/`workspace` survived, `everyday`'s
> own settings (`developer.enable = false`, `windows.enable = false`) held, and
> the built Brewfile lists all four casks. The contrast case — the same
> composition through the **unwrapped** `flake.packFiles.writing` (what a
> stranger gets from a gist, bypassing the `packs.writing` seam) — still
> conflicts, exactly as designed, and with a real file-based host both sides of
> the error name themselves correctly (`.../felt-host.nix` vs
> `.../packs/writing.nix`), confirming rice#228's `_file` fix holds outside the
> synthetic host `packCompose` uses internally.
> **What this changes and what it doesn't.** It moves limit 3 from "proven in
> an evaluator" to "confirmed through the actual builder, including a real
> build" — genuinely new evidence, not a re-run of an existing check. It does
> **not** clear the bar this doc uses elsewhere for "felt" (§5.1's contrast and
> latte flavor were felt by Julien looking at his own screen) — an agent running
> `nix build` is a stronger signal than an evaluator but not the same claim as
> a stranger who writes for a living actually installing this pack. That gap —
> "represented by a pack nobody who writes for a living has installed" — is
> still open, and is the one thing left in limit 3 that only a real outside
> user can close.
>
> **The audit** (§5.14's rule, run first): `haus` landed #240–#246 since
> the seventh pass (`rice#243`). Two are option-surface-relevant and both
> **already fix** things this file was still calling open:
> **(a)** §5.2's own "follow-up this turned up and did not fix" — the
> `ui.scale` honest-scope list missing Finder's sidebar and perch — was fixed
> the same day, one PR before #243 landed, in **#241** (added the sidebar row,
> named perch as never-reached) and **#242** (corrected #241's own first guess
> — display scaling doesn't move the perch shelf either, a **display's** points
> shrink by exactly the factor that grows them, so the shelf's physical size
> holds and everything around it grows past it). Marked done below.
> **(b)** **perch now follows `theme.accent`** (haus#244 + perch#31,
> merged the same day as #243) — takes the catppuccin **role name**, not a
> hex, so one key is right in both light and dark and needs no rebuild on a
> flavor change. `accent-reach` moves perch from `pinned` to `moves`; this is
> the boundary move that check exists to force someone to type out. It does
> **not** touch perch's `ui.scale` blindness (§5.2) — that's a different lever
> (size vs colour) and #242 reconfirms it's still a real, if small, gap.
> Everything else since #243 is infra, not option-surface: **#245** retired
> `wt.sh` entirely (holt is the only worktree tool now — a workshop/rice
> concern, nothing here routes through it) and **#246** is a Codex config
> fix. No open box in this doc is affected by either.
> **hausfold** was checked and is, as expected, irrelevant here — it was split
> out of the workshop into its own repo on 2026-08-06, is explicitly **not** a
> flake input and **not** part of `FAMILY` (per the workshop's own `AGENTS.md`),
> and this document never referenced it.
> **One thing worth a line, not a box:** `perch` relicensed MIT →
> FSL-1.1-ALv2 with a 2-tile free tier + paid unlock (perch#26/#27), and grew
> an iPhone/iPad companion (perch#29/#30) — both genuine direction
> changes for that room, neither one this roadmap's problem to track (perch is
> a shipped product now, per §9), but worth knowing if a future reference rice
> leans on perch: a "free" mouse-first rice that includes it may not be, past
> two pins. **(The FSL half was reversed on 2026-08-15 — perch is free and MIT,
> retroactively — so a rice that includes it is free after all. Left as written
> per §5.14: this is a dated finding, not a live claim.)**
>
> **Status, 2026-08-06 (seventh pass) — the same question asked of the OTHER
> option that fans out, and the answer was worse: `fonts.mono.name` reached ONE
> surface.**
> The sixth pass pinned what `ui.scale` reaches. Asking the same of the font —
> evaluate two rices differing only in `fonts.mono.name`, diff every file — gave
> **Ghostty's config, and nothing else**. The bar named `"Hack Nerd Font"` in its
> rc, four plugins and six generated blocks, so **the default rice already drew
> its bar in a different family than its terminal**, and §5.3's own motivating
> example (Atkinson Hyperlegible for a large-print rice) moved the terminal and
> left the bar alone. Fixed in **rice#243**: `BAR_FONT` joins the generated
> `sizes.sh` beside the `FS_*` sizes, every literal reads it, and bar stops
> installing Hack — core already installs whatever family the rice names.
> **★ The transferable half is what the check needed.** `font-reach` is the third
> reach table, but the bug lived in the **static** rc and plugins — files that are
> byte-identical whatever family the rice names, so *no number of evaluations can
> see them*. So the table carries one row that isn't an evaluation at all: a count
> of font literals still hardcoded in those files, read straight off the source.
> It is 0; the next hardcoded family makes it 1. **A reach table sees only what
> evaluation produces — when the promise also lives in files the rice copies
> verbatim, the check needs a row that reads them.**
> That makes **eight ★ findings in this file that are checks which can break,
> living in six checks.**
>
> **Status, 2026-08-06 (sixth pass) — §5.2's two unmeasured claims were
> measured, and the bigger one was aimed one layer off.**
> The fifth pass left three check candidates. Two of them were §5.2's — "every
> point-valued option is silently coupled to `displays`" and the honest-scope
> paragraph naming what `ui.scale` does *not* reach — and one measurement
> ([`probes/scale-reach.nix`](probes/scale-reach.nix)) answered both, then became
> **`scale-reach`** in the rice's `nix flake check`. Three things worth carrying:
> **★ the point-valued SURFACE is one option.** Six numeric leaves in the 130 the
> options page renders (plus four internal `_roster`/`_launchers` mirrors it
> doesn't), and exactly one is in points (`fonts.mono.size`); the rest are
> multipliers, ids, an ordering and a percent. Every other point-valued number in the rice — the tiler's
> gaps, the Dock tile, the bar's type, pounce's panel widths — is *internal to a
> module*, so a rule written about the option surface governs a set of size one,
> and §5.2's "audit `fonts.*.size` and the tiler's gaps" was asking about something
> that isn't an option.
> **★ And that one cannot clip *while windows tiles it*** — a bigger font on a
> `larger-text` display buys fewer columns, never a window wider than the screen.
> (Read off the code, not measured; the precondition is load-bearing, since a
> floating window or a rice with `windows.enable = false` has no such guarantee —
> which is §5.6's own "what second key makes the first one a lie", one room over.) The sharper rule: **a point-valued number only meets
> `displays` when something SIZES ITSELF from it**, which in this family is
> pounce (clamped, pounce#53), perch (proportional to `screen.frame.width`, so
> guarded by construction — and blind to `ui.scale` entirely) and the bar (bounded
> by a band that is itself in points). Tiled and OS-managed surfaces absorb it.
> **★ A ceiling needs its own verdict.** `accent-reach`'s moves/pinned/PARTIAL
> can't express a surface that changes and then stops, and `ui.scale` has two of
> them — so `scale-reach` evaluates **four** systems (1.0, 1.4, and two past every
> ceiling) and prints the generated numbers rather than a verdict word. A ceiling
> that regressed into a plain multiplier and a multiplier that grew a ceiling both
> fail now; mutation-checked in both directions.
> **The audit was empty again** — rice#239 merged, nothing has landed since, and
> `options-json` built either side of it is **the same store path** (130 leaves,
> unmoved). Two passes in a row where the option surface didn't move.
> **One correction to the pass below:** `nix fmt` with no arguments is a **silent
> no-op** in the rice (the formatter is bare `nixfmt`, which ignores a directory),
> so "I ran the formatter and nothing changed" proves nothing — see §8.
>
> **Status, 2026-08-06 (fifth pass) — the fifth check candidate is written, and
> the audit found no drift at all, which has never happened before.**
> The last pass ended by naming a `presets` check "in the shape of `packs`, with
> the twist that it must assert a **collision** as well as its absence". Built as
> **`preset-composition`** — rice#239, ~~open when this was written~~ **merged
> 2026-08-06**, so nothing in this block is contingent any more. It composes all six pairs of the shipped
> presets, plus a host that agrees, one that disagrees, one that says `mkForce`,
> one that joins an argument two presets are already having, and two rices that
> each add a tour step and an app, and diffs the result against a golden table. It
> is pure lib, so it runs on Linux CI beside `packs`. Three things worth carrying:
> **what it actually pins is `presets/README.md`'s NUMBERS** — "they share
> five options and disagree about four" was a sentence with arithmetic in it that
> nothing kept true, and the table is generated from `presetFiles`, so a fifth
> preset cannot be added without its four new pairs appearing and someone stating
> what they do;
> **★ derive the fixture from the rice, never name it** — the first draft
> hardcoded which option the host contradicts, and the row for "a plain host does
> NOT settle a preset collision" then quietly measured the wrong thing, landing
> on an option `everyday` and `minimal` *already* disagreed about, so the host
> changed nothing and the row read 4 where the finding is 5. Deriving *the option
> those two presets agree on* makes that row impossible to make vacuous, and it
> prints which option it used. **A golden table should print its own subject**;
> otherwise it can keep passing while testing nothing;
> and **the obvious name was taken**, by a check that answers a different
> question — `presets` evaluates each rice **alone** into a real darwin system
> (darwin-only), `preset-composition` asks what happens when one meets another.
> That split is the readiness test's blind spot, named twice in §6, now visible in
> the check list itself.
> **And the audit (§5.14's rule, run first) turned up nothing** — rice#229–#237 are
> terminal/core/pounce surfaces, and the option surface is unmoved. This time that
> was *measured* rather than asserted, and the measurement is better than a count:
> `options-json` built from rice#228 and from HEAD is **the same store path**, so
> the surface is identical rather than merely the same size. It holds **130**
> options (`jq '[keys[]|select(startswith("haus."))]|length'` over
> `share/doc/nixos/options.json` — the raw file has 131 keys, `_module.args`
> being the extra), which is the number this document has been quoting — worth
> pinning down, because three other defensible ways of counting the same tree
> give 203, 160 and 135, all true. **The number here is the one the options page
> renders, and nothing else**; a count without its method is not a checkable
> claim.
>
> **Status, 2026-08-05 (fourth pass) — limit 3's PRESET half is measured, and
> three of the things this document says about composing rices are wrong.**
> The last pass closed limit 3 for packs and left preset-vs-preset as the gap,
> excused as "colliding is the intended answer". Nobody had run it. Running it
> (`probes/preset-composition.nix` — the four shipped presets, all six pairs, the
> escape hatches, and two candidate seams; same `lib.evalModules` trick as the
> pack probe, seconds, no darwin system) turned up, in §6's limit-3 section:
> **(a)** overlap is **not** collision — `mergeEqualOption` accepts identical
> definitions, so the rule is *two rices compose iff they never disagree*, and
> half the pairs that "happen not to overlap" actually overlap and merge;
> **(b)** the conflict error **names the option, both files and `mkForce`** when
> a rice arrives as a path, which falsifies the "raw trace rather than anything
> this project wrote" premise option 2 was built on — **except through
> `lib.pack`**, whose wrapper erases the filename, so the one collision rice#222
> deliberately kept loud reports ``<unknown-file>`` twice — **fixed the same day
> in rice#228** (`_file`, plus a third `packs` rule, because that failure is
> invisible until two packs a *stranger* installed disagree);
> **(c)** the pack escape hatch (a plain host assignment) does **not** transfer
> to presets — it's a third normal definition and the build still stops;
> **(d)** presets at `mkDefault` wouldn't help either: equal priorities collide;
> **(e) ★** but **priority by list position works** — one `mkOverride` at a
> `compose` seam makes "the later rice wins" true, in both directions. It costs
> a *blend*, not a winner: `compose [ everyday minimal ]` keeps everyday's
> `tour.steps` because minimal never mentions steps;
> **(f) ★** and the options that don't collide **merge silently** — two rices'
> tour steps concatenate, in reverse import order, no warning. **Composing two
> strangers' rices has two failure modes and this doc only described the loud
> one.**
> **✅ Decided the same day: publish the rule, don't build `compose`** — the
> measurement that made the seam buildable also removed the reason for it, since
> the error a colliding consumer meets is already attributed. The rule now ships
> in `presets/README.md` and `guides/sharing-a-rice.mdx`, including the clause
> nobody knew: **a list- or set-valued option never conflicts, it combines,
> silently.** Adding `lib.compose` later is additive; removing it once a gallery
> depends on ordering is not. (Repos re-read first, per §5.14: since
> rice#222 nothing changed the option surface — 130 leaves, unmoved. rice#223–227
> are terminal/core/pounce surfaces, and the one roadmap-adjacent commit is
> §5.7's — the rice now generates `~/.config/holt/config.toml` from
> `haus.agents.default`, a third instance of the two-writers seam, correctly
> labelled *edit that option, not here*.)
>
> **Status, 2026-08-04 (third pass) — limit 3's proposed fix was RUN, and it has
> exactly one correct implementation.** The two passes below both ended by
> naming the same next step: try option 1 (ship packs at a lower priority) on
> `packs/writing.nix`. Done — the real pack composed against a host that already
> owns Obsidian, through `lib.evalModules` over the pure-lib option surface (§8's
> technique, no darwin system needed). Results in §6's limit-3 section; the
> headline is that **`mkDefault` on the whole `roster` attrset silently drops
> three of the pack's four apps**, while `mkDefault` per leaf does precisely what
> was wanted — and a data-only pack can write *neither*, because `checkRice`
> refuses a file that takes `lib`. So option 1 is a property of the import seam,
> not of the pack file, and the obvious version of it fails silently.
> **Then shipped, same day — rice#222**: `haus.lib.pack` + `checkPack`, and
> a `packs` check that composes a pack with a conflicting host and fails if the
> host doesn't win — the first check here that pins a *relationship between two
> rices* rather than one rice's table. **Limit 3 is closed for packs**; presets
> still collide, deliberately.
> (Repos re-read first, per §5.14: nothing roadmap-relevant landed after rice#220
> — #219 is a comment fix and #221 is a pounce command.)
>
> **Status, 2026-08-04 — the readiness test's last visible gap is closed, and
> the test found a new one.** Re-audited against the repos first (§5.14's rule),
> which is what turned up everything below.
>
> **The package-type format limit is FIXED (rice#215).** `packageName` — an
> attribute path into nixpkgs written as a string — now sits beside both
> package-typed options, so a data-only rice can change the font *family*
> (§5.3's own motivating example, unexpressible until today) and an app pack can
> install from Nixpkgs (§5.4). Three things worth carrying:
> **(a)** the fix is one convention, not two options: `<option>Name`, resolved by
> `modules/lib/pkg-by-name.nix`, and `nix flake check`'s new
> **`data-only-surface`** fails when a package-typed `haus.*` leaf is added
> without its string sibling — because the third one gets added by someone who
> never read the note explaining the first two.
> **(b)** the mechanical audit this doc kept asking for was finally run, and the
> answer was small: **three** typed leaves in 128, of which two were the known
> package pair and the third (`focus.hooks`, a path) is *fine* — a rice can ship a
> script beside itself and say `./thing`, which stays data. The audit that
> sounded like a project was a `jq` one-liner.
> **(c)** the trust line got sharper by being written down: naming a package is
> still data (the resolver walks `pkgs` by attribute path — no `import`, no
> string that becomes code), and it was never a claim that the software is
> vetted, since `cask` could always fetch anything. "You can read a rice and know
> what it does" ≠ "a rice can only install safe things."
>
> **★ And the readiness test has a new limit, which is bigger than the one it
> replaces (rice#203): composing rices is NOT the free operation §6 claimed.**
> The module system has no import-order priority — two definitions of one option
> at equal priority *conflict*, they don't override. So `[ everyday minimal ]`
> fails on `pounce.enable`, and a pack naming an app the consumer already has
> fails with a raw conflict error that never reaches the friendly roster
> assertion the pack advertises. `everyday + large-print` composes only because
> the two files happen not to overlap. Three READMEs said otherwise and are
> corrected; the consumer-side fix is `lib.mkForce`. **The composition story is
> now the format's sharpest limit** — it's the one a stranger hits on their first
> real pack, and unlike the package-type limit it has no fix in hand.
>
> Also landed since the last pass, none of it predicted here: **the accent's
> reach is a golden table** (`accent-reach`, rice#208 — seventeen surfaces × three
> accents, so a dropped accent wire fails loudly instead of silently), Zen's
> accent finally reaches **the actual web** via a declared Stylus bundle
> (rice#208/#211 + nebelung#22), and **trill is out of the rice entirely**
> (rice#212 opt-in → rice#213 removed) — "a supported option nobody should turn
> on is a lie in the option reference" is the sentence to reuse.
>
> > **Second 2026-08-04 pass — a parallel audit, and it found what the first one
> > couldn't.** Two sessions read the repos independently the same day. They agree
> > on everything above; these are the items only the second pass turned up, and
> > the *reason* it did is that it went looking at built artifacts rather than at
> > option definitions:
> >
> > **★ `everyday` shipped a tutor that drew nothing (rice#220).** §5.5's box said
> > the tour *hangs* with `windows.enable = false`. It doesn't any more — it draws
> > **no pill at all**, while the preset still sets `tour.enable = true` and its
> > own comments explain why a tutor is right for exactly that person. It passed
> > `checkRice`, passed `nix flake check`, and taught nobody anything. **This is
> > limit 3's class, from inside a single file: valid parts composing into an
> > experience nobody chose** — see §6's new closing note on what the readiness
> > test can't see. Closed by authoring the step, which made `everyday` the first
> > customer of §5.13's own community-tour mechanism, six days after it shipped.
> > That in turn exposed the mechanism's gap: **data-only means data cannot
> > interpolate**, so an authored hint could never name the keys the machine
> > resolved. Placeholders now do it; any future authored-TEXT option needs the
> > same seam.
> >
> > **The refuted composition model outlived its correction (rice#220).** rice#203
> > corrected "imported after, so it wins" in the three files that prompted it. It
> > survived in `modules/host-template.jq` — *including the header written into
> > every user's `hosts/<host>/options.nix`* — in `bootstrap.sh`, and in one
> > sentence at the bottom of the same `presets/README.md` #203 fixed at the top.
> > **Grep for the claim, not for the file.**
> >
> > **§5.7 splits in two, and its reading half is done** — rice#184 ships an
> > annotated `hosts/<host>/options.nix` + `haus options`, the rice's own version
> > of pounce#54's `config init`. "Configure without opening the docs" is met;
> > "configure without opening an editor" is not, and `haus set` is still what
> > that needs.
> >
> > **Smaller, all corrected below:** §5.1's OS-contrast box read `- [ ] ✅` —
> > drift wearing a tick, with both options long since shipped (§5.14 now lists
> > that as its own failure shape); `bar.items` is 15 bools, not 13;
> > `large-print` is four options, not three; the surface is **130** leaves where
> > §1 counted ~44, and four rooms — `agents`, `apps`, `perch`, `zen` — appear
> > nowhere in this document.
> >
> > **And §5.14's structural reason 1 has an answer now.** It said this file's
> > problem is living in a fifth repo no CI can see, while every other seam here
> > got fixed by making the upstream repo emit something mechanical. Two roadmap
> > findings are now checks that can break: `data-only-surface` and
> > `accent-reach`. **When a finding generalises, leave a check behind, not a
> > paragraph** — with the remaining candidates named in §5.14.
>
> **Status, 2026-08-03 — read §5.14 first.** An audit of every open box against
> the actual repos found **three items that had shipped and were never ticked**
> (§5.9's rice-side `pounce.items` in rice#149, §5.12's FDA detection in rice#128,
> §5.2's Finder sidebar in rice#181) plus one family renamed out from under the
> whole document: **`haus.apps` is `haus.roster` since rice#182**, which
> also shipped §5.4's multi-source install. Those are corrected below. §5.14
> records why it drifted and what to do about it — the short version is that this
> header is a summary and the CHECKBOXES are the source of truth, and when they
> disagree the repo settles it.
>
> Also new, both in rice#198: §5.6's first two groups shipped
> (`haus.hotCorners.*` and `haus.screenshots.*`), settling that
> section's default policy — null = write nothing, and null ≠ off — and turning up
> two silent failures worth reading before the next group. And **Phase 0 is
> closed**: `haus.packs.writing` is the shareable app pack that item asked
> for. Writing it found a real bug (roster leader keys were never checked against
> the built-in launch actions, so a pack could silently eat one) and hit §5.3's
> package-type format limit from a second family, which makes that limit worth
> fixing once rather than living with.
>
> **Status, 2026-08-02.** §3 (structure) and §4 (spikes) are **done**, Phase 3 is
> mostly done, and all three reference rices pass the readiness test (§6).
>
> **The sizing pass is DONE — both halves** (pounce#53 + rice#175). `ui.scale`
> reaches the command palette (the launcher and every panel behind it) and the
> menu bar's type. Those were the last two rice-owned surfaces `large-print`
> could not enlarge, so §5.2's fan-out is five targets now instead of three.
> Two findings outlived the change and are the reason to read §5.2:
> **(a) `ui.scale` and `displays.*.uiScale` MULTIPLY**, and nothing in the surface
> said so — every point-valued option is silently coupled to `displays`;
> **(b) the bar is a CEILING, not a multiplier** — its height belongs to macOS's
> menu-bar band, measured and confirmed to have no setting behind it, so the type
> scales to 1.25× and stops. That is the first place the readiness test ran into
> something macOS simply owns.
>
> What moved since the last pass is **pounce**, and it moved somewhere this doc
> didn't predict. The palette reads its theme from **runtime files** now
> (pounce#37 + rice#139), follows macOS Light/Dark **by itself** (pounce#42 +
> rice#142, `pounce.followSystemAppearance`), and has a **per-item settings
> schema** keyed by frecency key (pounce#43) — which is the action vocabulary
> §5.5 said `bindings` was waiting for. Two consequences worth carrying: pounce
> is no longer on the "bakes its own colours" side of §5.1's honest-scope line,
> and `scheme = "auto"` now has one shipped implementation to copy rather than a
> design.
>
> Alongside it, **`theme.ports.enable`** (rice#136 + nebelung#17/#18/#19) themes
> the apps in your roster from **port metadata** — so §5.6's "each setting carries
> a reachability designation" idea now ships as data for 53 ports, in a different
> room than the one that proposed it.
>
> **Still open:** §5.4 apps v2 (the schema migration, deliberately last) — and
> with sizing closed it is the last unstarted item in Phase 3. `density`/`motion`
> (§5.2) remain unbuilt but were never blockers.
> §5.10 displays shipped in rice#147 and the rice-side pounce options in rice#149;
> displays still wants a docked multi-monitor proof before growing profiles, but
> that validation no longer blocks `large-print`.
>
> **Earlier history.** §3's four items landed as haus#92/#96/#98/#93 +
> workshop#81 and the macOS spikes settled in the matrix; fonts (#91), the two
> working accessibility keys (#90), `ui.scale` (§5.2), the contrast axis
> (nebelung#11 + rice#103), light mode (nebelung#12 + rice#108) and `keys.*`
> (#108, which also ships `presets/large-print.nix`) are all in. Read §6's
> scoreboard and the two limits `large-print` exposed before celebrating.

# Drift — the shapes a write-up here goes wrong in, and what catches each one

**The standing catalogue.** Every row below is a way a claim in this family's
documents stopped being true, found by someone re-checking it against the
repos — and beside it, the only thing that actually catches that shape. It is
not a plan and holds no work: the roadmap it came out of does that.

**Split out of [`options-roadmap.md`](options-roadmap.md) §5.14 on 2026-08-23**,
after the thirty-eighth pass, because the two halves had stopped being one
subject. That file's option surface has been 318 leaves for four consecutive
readings while this catalogue has taken a new row in each of the last four
passes — and the passes' findings stopped being about missing options a month
ago. The third dangling-referent site in `haus` never met the first two
precisely because the fix was prose inside a section about themes; burying a
family-wide catalogue inside an option roadmap is the same mistake one level up.

**Three things to know before reading it:**

1. **The body below is moved VERBATIM and is not rewritten.** Inside it, *"this
   file"*, *"this document"* and *"§5.14"* mean `options-roadmap.md` and its old
   section number — which is what every dated finding was written about, and
   retroactively re-pointing them would make the evidence stop matching the PRs
   it cites. Same rule, and the same reason, as that file's own naming banner.
2. **The row numbering is FROZEN.** Rows are numbered by position, and "row
   eleven" is quoted by number in commit messages and source comments across
   four repos. A new shape is APPENDED; no row is ever reordered or removed. The
   table is 24 rows as of 2026-08-23.
3. **`options-roadmap.md` §5.14 still exists**, as a stub pointing here. It
   keeps its number for those citations, and because the command that measures
   that file's open boxes terminates on that heading.

The passes themselves are at the bottom of this file — the three most recent —
and the rest are in [`options-roadmap-log.md`](options-roadmap-log.md), which
keeps its name for the reason its own header now gives.

---

## How this doc drifts, and the one rule that fixes it

*`options-roadmap.md` §5.14, moved here whole on 2026-08-23 and not rewritten.
Every "this doc" and "this file" below is that one.*

Not an option family — a finding about the doc itself, recorded here because it
cost real work. An audit on 2026-08-03 checked every open `- [ ]` in §5 against
the actual repos. **Three had shipped and were never ticked**, and a fourth
family had been renamed out from under the whole document:

| Box | Actually shipped |
|---|---|
| §5.9 rice-side `pounce.items` | rice#149, 2026-07-30 |
| §5.12 `haus doctor` detects FDA | rice#128 |
| §5.2 Finder sidebar size | rice#181 |
| §5.4(a) multi-source install | rice#182 — and it **renamed `haus.apps` → `haus.roster`** |

The §5.9 one is the instructive case, because the doc **already knew**: the
status block at the top credits rice#149 by number, while the checkbox 600 lines
below still said "the next cheap win in this section". A reader picking work off
the checkboxes — the way you actually use this file — would have rebuilt
something that existed. That is exactly what happened.

⚠️ **Since 2026-08-20 the status blocks live in
[`options-roadmap-log.md`](options-roadmap-log.md)**, all but the three most
recent — which changes nothing about the rule below, and makes the failure it
describes easier to hit: the log is now a second file, so "the header credits
the PR by number" is no longer something you trip over on the way to the
checkbox. **Grep both.** The count this file is measured by is unmoved —
`grep -c '^- \[ \]' notes/options-roadmap.md` still returns only live boxes,
because the log carries none.

**The rule this leaves: a status-block edit is not a substitute for ticking the
box, and the box is the source of truth.** The header summarises; the checkbox
decides. When they disagree, believe the checkbox and then go check the repo,
because the header is written by whoever last did a pass and the checkbox is
written by whoever did the work.

Two structural reasons this drifts more than a normal TODO list, both worth
designing around rather than resolving to try harder:

1. **The work happens in four repos and the doc lives in a fifth.** Nothing in
   `haus`, `nebelung` or `pounce` CI can see this file, so a PR that closes
   an item has no mechanical way to say so. Every other cross-repo seam in this
   project got fixed by making the upstream repo emit data (`options-json`,
   `wm-bindings-json`, `ports.meta.json` — see §7); this one is still prose on
   both sides.
2. **Items ship out of phase, from the app side.** §5.1's port metadata and
   §5.9's item schema both arrived from downstream repos that wanted the data
   structure for their own reasons — noted in Phase 4 as a good thing, and it is,
   but it means the rice-side box goes stale without anyone in the rice touching
   the item.

The cheap mitigation, given both: **re-audit against the repos, not against
memory, before treating any `- [ ]` as work to do.** The full pass took one
session and would have been cheaper than the half-rebuild that prompted it.

**Second pass, 2026-08-04 — the rule held, and it found a failure it doesn't
cover.** Re-auditing first this time cost ten minutes and turned up no
shipped-but-unticked box (one day of drift, so that's expected). What it *did*
turn up is a different shape of staleness the checkbox rule can't catch: **a
shipped PR that falsifies a CLAIM in the prose.** rice#203 didn't close any item
here — it corrected the composition story §6 and Phase 0 were built on, and both
of those are ticked boxes and running text, not open ones. So:

- an open `- [ ]` goes stale when work ships → fixed by auditing the repos;
- a **closed** item goes stale when someone learns the thing it asserted was
  wrong → nothing catches that but reading the commit messages.

Both were found by the same act — reading every commit since the last pass rather
than diffing the checkbox list — which is the actual rule worth keeping. The
commit bodies in these repos are long on purpose; **the audit is reading them,
not grepping them.**

**A third shape, found by a parallel pass the same day.** Two sessions audited
this file independently on 2026-08-04 and overlapped on most of it — but each
found things the other didn't, and one of them is a category the two rules above
still miss: **a box whose marker and body disagree with each other.** §5.1's
"pair `contrast` with the OS lever" read `- [ ] ✅` — an open checkbox with a
tick inside it — and both options had in fact shipped. Nothing catches that but
looking at the marker and the prose as two separate claims. §5.5's tour box was
the fourth shape again: not stale, not falsified, but describing a failure mode
(*hangs at step 1*) that had been **replaced by a different one** (*draws
nothing at all*) — worse, and invisible to anyone re-reading the doc.

So the full list of ways an entry here goes wrong, none of which the others
catch:

| Shape | Caught by |
|---|---|
| open box, work shipped | auditing the repos |
| closed claim, later falsified | reading the commit messages |
| marker and body disagree | reading the two as separate claims |
| description replaced by a *different* truth | building the thing and looking |
| claim true, but about the wrong **layer** *(added on the sixth pass — see below)* | trying to write the check it implies |
| open box, blocker already removed *(added on the twenty-first pass — §5.3's `sans`)* | re-reading the WHY beside a box, not just the box |
| audit invents a regression *(fourteenth pass — it was written as a one-row table below and never folded in here, which is the hazard this table exists to fix; folded in on the twenty-second)* | a clean-context reader who re-derives the evidence |
| claim about a generated artifact, derived from its generator *(twenty-second pass — §5.3's `sans`)* | reading the artifact the check actually samples |
| claim about a repo, read from the LOCAL CHECKOUT *(twenty-third pass — haus's checkout sat one merge behind while the audit ran)* | fetching first (`bench status` does), or reading GitHub |
| a NEGATIVE claim ("X never happens") proved by a grep *(twenty-third pass — "`bench status` never fetches", from a pattern that couldn't match `git -C "$dir" fetch`)* | reading the file around the pattern, not the pattern's output |
| a CORRECTION that goes backwards — a true clause replaced by a false one, wearing a ⚠️ and the word "measured" *(twenty-fourth pass — `AGENTS.md`'s flake-input row, 68 minutes after the repo falsified it)* | dating the measurement at a **rev**, not a calendar day; nothing else can distinguish the newest sentence from a checked one |
| a "don't touch this, it's coupled" warning that names the **wrong line** *(twenty-fourth pass — `bench`'s `OVERRIDABLE`, which holds repo names and never held an input name)* | opening the file it names and finding the thing it says is there |
| a sketch borrows a plain English word, and the CODEBASE later adopts that word for something it already had *(twenty-fifth pass — §5.8 proposed a `scenes` namespace with `focus` demoted to an alias, three weeks before the room rename made `focus` a room's name)* | reading a sketch against today's option tree rather than against its own vocabulary — the entry never goes stale, never gets falsified, and never disagrees with its marker; it just quietly starts proposing something else |
| a box ticked for work that is BUILT but not MERGED — the first shape with its clock reversed, and the worse one *(twenty-fifth pass, caught by its own assurance read: §5.8 was written `- [x] ✅ shipped` while haus#376 was `"state":"OPEN"`)* | reading the PR's **state**, not its diff. Rule 1 sends a reader to the repo to confirm a ticked box, and here the repo says no — so the box doesn't just mislead, it burns the check that was supposed to catch it. A PR number in a tick is a promise; only `mergedAt` keeps it |
| a claim naming a FUNCTION, a check or a format that the repo has since retired — the entry stays true about what shipped and false about what exists *(twenty-seventh pass — §3.3's `checkRice` box, and the ledger's `packs` row, both retired by haus#386)* | grepping the repo for the identifier, not for the sentence. A rename that preserves the count is the dangerous one: the number a reader spot-checks stays right while the roster under it rots |
| an IMPOSSIBILITY claim that is really a description of how the incumbent works — one premise stays true, a second is falsified by the same change, and the conclusion they carried is gone *(twenty-eighth pass — §5.1's "real sites are Stylus's job", retired by a build-time LESS compile in haus#416)* | asking what it would cost to do the thing ourselves, instead of asking why the existing route can't be reached. Every other row here describes an entry that *decays*; this one is wrong on the day it is written, and reads as a scoping decision rather than as a mistake, which is why nothing re-examines it |
| a CORRECTION that reports itself as APPLIED — the paragraph says what the line "now reads" and the line was never touched; it need not even be deliberate, since *"reads 16 now"* parses equally as *the value is now 16*, and no reader can tell which *(thirtieth pass — §5.9's `15 bools`, quoted inside the correction while the line itself stays outside the hunk)* | grepping the file for the string the correction quotes as its **result** — once, before your own prose adds a copy of it. Every other row here is an entry decaying while nobody looks; this one is an edit that exists only in the prose announcing it, and it beats the staleness it describes, because a reader who notices the two disagree believes the newer sentence. Its sibling hazard is that a stale value can HEAL — haus#422 made §5.9's un-updated number right again — so a re-derivation is not always a repair, and neither is applying a correction you find unapplied |
| an ENUMERATION written when a fix NARROWED an open limit — every member of it is still true and the list is no longer complete *(thirty-first pass — §6(f)'s "survives exactly where the model still allows two of something", drawn at the definition layer while the module system also merges declarations)* | asking what the seam actually BOUNDS, not spot-checking the members. Every other row here is an entry that decayed or an edit that never happened; this one is an entry that was improved — a limit got a seam, a pass wrote down what the seam left standing, and an enumeration is a stronger claim than the open sentence it replaced. It survives every check aimed at its members, because the error is the boundary they were drawn inside |
| a rev that is true when MEASURED and false when PUBLISHED, spent on a NEGATIVE claim — the positive revs beside it age harmlessly *(thirty-second pass — the thirty-first's "nebelung … and pounce … have not moved since the twenty-ninth pass, so neither of §5.9's two open boxes could have closed", 66 minutes after pounce#92)* | writing the claim so a rev can bound it. This is row eleven's fix meeting the one clause it cannot reach: "haus was at `4e2dd61`" stays true forever, because it is a fact about a rev, while "neither box could have closed" is a statement about a section's future with no rev to attach and one job — to license not looking. The honest form says less and cannot go stale: *no box had closed as of `<rev>`*. It costs most where it is spent, because the section a pass excuses itself from checking is the section the excuse is about |
| a drift check REFRESHED where it fires — the snapshot tracks the data, the PROSE it exists to protect does not, and green comes back with the lie intact *(thirty-fourth pass — the launch-mode reserved keys: one authority, published as data, tripwired from the docs repo, and two option descriptions four days stale)* | asking which COPIES the check compares, not whether it is green. Every other row here is a claim nobody looked at; this one is a claim something looked at and passed. `check-rice-bindings.mjs` compares DATA to DATA — haus's published `launch-keys.json` against a snapshot in the docs repo — so when the authority moved it fired, the snapshot was re-blessed **43 seconds** later, and the hand-written copies of the same set were never in its path at all. A check whose remedy is *re-bless the snapshot* turns “the docs are wrong” into “the docs are current”, and does it faster than anyone can notice which of the two happened. The tell is cheap: a drift check that never fails twice for the same reason is not comparing the thing that drifts |
| a POLICY stated over DECLARATIONS and read as a promise about VALUES — every leaf in the group still defaults `null`, the reference still prints `null`, and the machine writes the key anyway, because the value arrives from a module the policy was never addressed to *(thirty-fifth pass — §5.6's null-default policy, breached by the shelf room's `watchScreenshots` at `mkDefault`)* | evaluating the option on the shipping desktops and comparing that against its published default, instead of re-reading the declaration the policy is written about. This is row five's wrong-**layer** shape aimed at a rule rather than at a claim, and it is the first entry here that nothing got wrong: §5.6 is accurate about every leaf it declares, the room reasoned its priority ladder out correctly in its own comment, and the generated reference carried both halves into the same page. What no surface holds is the **product** of the two — a declaration layer that says `null` and an evaluation layer that says `false`, each honest alone; the one check in the repo that reads resolved values pins 55 paths, and none of them is in the group the policy is about. The tell is topological rather than textual: of §5.6's 33 citations in haus's source, 29 are inside the machinery that already obeys it and the other four are in the one room that HOSTS one of its groups — so the rule has never been addressed to a room that merely consumes one of these leaves, which is the only place left it can be broken from. A policy whose every citation sits inside its own implementation is a habit with a footnote |
| a CORRECTION applied to the INSTANCE and not to the CLAIM — the diff fixes the sentence it has open, and states a reason WIDER than the fact that justified it, so the copy twelve lines down survives and the wide clause is the one later authors quote *(thirty-sixth pass — haus#467 fixing one of two `haus show` sentences in one comment, on the ground that the command "never reads a machine's resolved values", which is false of a command that ranks 23 of them)* | grepping the file for the phrase you are about to correct, **before** writing the correction — the twin is usually inside the same comment, because a claim gets restated where an argument closes. And then writing the reason at the width of the evidence: the fact here is *this desktop file does not set that leaf*, which is narrow, checkable and unquotable, while *it never reads your machine* is memorable, general, load-bearing for the next argument and wrong. Every other row here is about a claim decaying, or an edit that never happened; this one is about a correction that was applied, verified and reported honestly, and still left the section it corrected saying the same thing twice. The tell: a correction whose reason would survive deleting the case that prompted it is a rule someone invented at the keyboard |
| a claim rev-bounded in the BODY and unbounded in the HEADLINE — the evidence paragraph is exemplary, the bolded first sentence is in the present tense, and the headline is what gets quoted *(thirty-seventh pass — the thirty-sixth's "it is still standing", fixed by haus#469 **twelve seconds** before the pass reporting it merged, from the same session)* | writing the finding so the rev is inside the sentence a reader can lift out. This is row eleven meeting the fact that a status block is READ through its header: the paragraph below can be perfect and never be reached. It is also unfixable by ordering — the doc lives in a fifth repo (structural reason 1), so the fix PR and the report PR are queued independently and merge in whichever order GitHub reaches them; had they landed the other way the block would have been true for twelve seconds and false forever after. A finding written *at `<rev>`, X* survives either order; *X is still standing* survives neither. And note what did NOT go wrong: the pass fetched first, dated at revs, derived from the rev, and got the fact right — the defect is entirely in the width of one sentence |
| an IMPOSSIBILITY claim whose remedy is ALREADY IN THE REPO — row sixteen with the search moved inward: not "could we build this ourselves" but "did we already, and forget" *(thirty-eighth pass — `modules/ai/default.nix`'s *"the names are UNVERIFIABLE from here, by construction"*, written at haus `561af88` nine days after the same class was closed in `modules/theme/ports.nix` and terminal's `glowPlugin`, on this file's own fourteenth-pass box)* | grepping the repo for the FIX before writing down that there isn't one — the identifier, not the sentence, which is row fifteen's tell pointed at a remedy instead of at a claim. The reason this survives row sixteen's check is that the impossibility argument here is **half true and precisely stated**: listing a derivation's contents at eval time really is import-from-derivation, really would fire on `haus get`, and the comment says so correctly. What it never asks is whether the check has to happen at eval time at all — `runCommand` turns the same assertion into a build dependency and is not IFD. A wrong reason gets re-examined; a right reason carrying the wrong conclusion is quoted. And the cost of not asking is not a stale doc: it is a dangling symlink in a user's home with eval, `nix flake check` and the home-files build all green |

The sixth shape needs its own line because it is the only one that makes an
entry read *better* than it is. §5.3's `sans` box said "nothing blocks it now
that naming a package is possible" — naming the very limit that section had
fixed, which is a true sentence pointing at the wrong dependency, and which reads
to anyone picking work off this file as **ready to build**. The first two shapes
degrade an entry (stale, or wrong); this one promotes one. Rule 1 re-audits the
*box* against the repos and rule 2 reads commits for falsified *closed* claims —
the reason sentence beside an OPEN box is in neither's path, and it is the
sentence that decides whether the box gets picked up. Cheap mitigation, same
shape as the others: when a section closes a limit, re-read every open box in
that section that cites it.

★ **The structural fix for reason 1, and it exists now.** §5.14 observed that
every other cross-repo seam here got fixed by making the upstream repo emit
something mechanical, while this one stayed prose on both sides. Two roadmap
findings are now **checks in the repo that can break them**: `data-only-surface`
fails when a package-typed `haus.*` leaf has no string sibling (§5.3), and
`accent-reach` fingerprints seventeen surfaces under three accents so §5.1's
honest-scope paragraph can't silently stop being true. Both cost one PR each.
*(Corrected on the fifth pass: only `data-only-surface` is pure `lib` and runs on
Linux CI. `accent-reach` fingerprints a real evaluated system, so it is
darwin-guarded and runs on nobody's CI — it fires on this machine, or not at
all. Worth knowing before counting it as a tripwire.)*

★ **Noted on the fourteenth pass, as reasoning and not as an incident: a check
can pass on the pointer while the referent is missing.** `accent-reach`'s `glow`
row fingerprints `yazi/plugins/glow.yazi`, whose accent-varying content is a
*path* into nebelung's output. Nix interpolates a store path into a string
without asserting anything is there, so the row would read `moves` with the JSON
absent. **This has not happened** — the fourteenth pass first reported that it
had, and the pre-PR assurance pass proved otherwise (see the retraction at the
top of this file). The reasoning stands on its own: **a golden-table check needs
to ask what layer its fingerprint lives at**, because for anything whose
accent/flavor axis is a *reference* across a repo boundary, fingerprinting the
reference is free and proves nothing. `zed`'s row already carries a comment
calling itself the one fingerprint that is a FILENAME rather than a file's
contents — the same shape, noticed and then not generalized.

- [x] ✅ **Assert the referent exists for every cross-repo reference
      `accent-reach` pins** — shipped 2026-08-14. The glow half was the one line
      this box predicted (`[ -f "${glowStyle}" ]` in `glowPlugin`'s existing
      `runCommand`). **The audit half was not a belt, and this box's own "low
      priority: no break has occurred" was the wrong reading.**
      ★ **The roster-port rows have the same gap and it fails SILENTLY in the
      user's home directory, not in a check.** `modules/theme/ports.nix` set
      `home.file.<target>.source` to a plain string under nebelung's themes
      root, and home-manager's `insertFile` ends in a bare `ln -s` — measured
      in the pinned home-manager's `modules/files.nix` — so a port whose file
      nebelung doesn't render becomes a **dangling symlink** in `~/`, with no
      error at build and none at activation. Where glow's gap could only fool a
      *check*, this one fools the *machine*: you find it months later wondering
      why the app looks stock, which is verbatim the outcome that room's own
      header says it refuses to produce.
      It is also the riskiest place for it, because a port's path is re-spelled
      **twice** before it means anything — once for the flavor (and
      `modules/lib/nebelung.nix`'s own comment already said "a mocha path under
      a latte root silently resolves to nothing", noticed and not closed) and
      once for `<accent>`. Two substitutions, neither side validating.
      Fixed by copying the placed ports through one `runCommand`, which makes
      the referent a build **dependency** rather than a promise, and
      mutation-checked in both directions against the real `mbp` host: the
      broken path fails the build naming the port, the roster id, the flavor and
      the accent; the restored path builds clean (22 `nix flake check` checks
      green, real `darwin-system`).
      ★ **And the mutation check caught a bug the fix itself introduced** — a
      rendered port's filename routinely contains a space (`Catppuccin
      Mocha.xccolortheme`), which an unquoted `[ -e ]` reads as two arguments.
      The first version of this assertion failed the build on a file that was
      *there*. **A referent check is a new place for the referent's own shape to
      bite you**, and it was only visible by running it against the real host's
      roster, not against the synthetic one the checks use.
      *(One process note, for the next person who mutation-checks a `haus`
      module:
      `nix fmt` on `modules/terminal/default.nix` rewrites 727 lines — the file is
      not nixfmt-clean and the repo doesn't check it, so §8's "run the formatter"
      still means hand-matching the local style. And a `path:` flake override
      caches on the checkout's ROOT mtime: editing a file two directories down
      leaves `bench try` re-reading the old copy and reporting a green build for
      a mutation that never reached the evaluator. `touch` the worktree root
      between mutations, or the check silently proves nothing.)*
- [ ] ◐ **Assert the referent exists for every TOOL SKILL `modules/ai` lists** —
      the same gap as the box above, three sites on, and the first one whose own
      comment argues it cannot be closed. **Built and open at
      [haus#475](https://github.com/hausfold/haus/pull/475) as of
      2026-08-23T06:28Z**, `mergedAt` null when this was written; ticked when the
      PR has one, per row fourteen. The "as of" is dated on purpose and read
      back from the PR rather than from a clock — the box above this one had
      that timestamp wrong by nine seconds in the other direction, and nothing
      in this file would have caught it. ⚠️ It also said **#474** until the
      assurance read: guessed as next-free before the PR was opened, and #474
      had merged six minutes earlier as unrelated work. `haus.ai.skill` links each
      hausfold tool's skill folder into every installed client's skills dir, and
      the folder NAMES are a hand-written list (`holt`, `handoff`) because
      reading them off the store is IFD. That much is right; *"so nothing can
      check them"* is not. Measured at haus `561af88`: a name the pinned
      revision doesn't ship evaluates clean, builds `home-files` at exit 0, and
      lands a **dangling symlink** in `~/.claude/skills` — the same failure the
      roster-port box above describes in the user's home rather than in a check,
      and for the same reason (a `home.file` source inside a store output is
      never existence-checked). Closed the same way: one `runCommand` that
      copies each listed folder through, so the name is a build **dependency**.
      Mutation-tested both ways on darwin — the bogus name stops the build
      naming the derivation, the skill, the path and two remedies; restored, it
      builds and both skills land.
      ★ **The generalisable half is not "add a third check", it is that the
      first two did not travel.** `modules/theme/ports.nix:158-162` states the
      pattern in general terms — *"copying through one runCommand makes the
      referent a build DEPENDENCY rather than a promise"* — and even names its
      own precedent in terminal's `glowPlugin`. It is a comment on a specific
      port, in a room about themes, and the next author to spell a path into a
      store output was in a different room and never met it. §5.14's structural
      answer applies to a fix as much as to a claim: **the two ways this repo
      guards a cross-derivation pointer are prose in two comments, and prose is
      what row twenty-four says does not reach the third site.** A `lib`
      helper — `checkedRef drv path` — would have; that is the follow-up, and
      it is deliberately NOT in this PR, which fixes the instance.
- [x] ✅ **A downstream lock pinned at an upstream rev that is not on the
      upstream's `main`** — fetchable only until the PR branch is deleted, and
      nothing in the family noticed. Found in the fourteenth pass's retraction:
      rice#247's lock pointed at nebelung#29's PR-branch head for seventeen
      minutes. `bench ship` can't cause it (it bumps to merged HEADs); a
      hand-run `nix flake update` inside a PR can. **Shipped as an `OFF-MAIN`
      lock edge in `bench status` (workshop#252)**, reported separately from
      `STALE` because the fix is different — STALE says *ship it*, and there is
      nothing to ship. Three details that were not obvious before writing it:
      **(a)** the answer has to be three-valued, not boolean — a rev nix fetched
      but git never did isn't in the local clone at all, and calling that
      "off-main" would cry wolf on every machine that hasn't fetched, so
      `unknown` stays silent; **(b)** it checks `origin/main` *and* local
      `main`, since a checkout behind its remote would otherwise report landed
      revs as off-main — but `HEAD` is consulted **only** when neither resolves,
      because every extra ref widens the yes-set, and reading `HEAD` always
      would let a main checkout parked on a branch (the in-place agent mode does
      exactly that) declare every rev on that branch landed, silencing the
      warning where it is most likely to be earned; **(c)** it only runs on
      edges that already failed the equal-to-HEAD test, so the common path costs
      nothing. The assurance pass found (b) and the closing-verdict line, which
      still said *everything is current* when OFF-MAIN was the only problem —
      **a new warning has to be ranked in the summary that prints under it**, or
      the one line a reader treats as the verdict contradicts it.
      → ★ **This is the first tripwire in this file that is a *warning in a
      CLI*, not a check that fails a build.** §5.14's rule says leave a check
      behind; the honest footnote is that a `bench status` line only fires when
      someone runs `bench status`. It was still the right shape here — the
      condition is about a lock, and locks are what that command exists to
      report — but it does not belong in the "checks that can break" ledger.

**So the rule gains a second half: when a finding generalises, leave a CHECK
behind, not a paragraph.** Ask of every ★ in this file — *what would fail if
someone did this wrong tomorrow?* If the answer is "nothing, they'd have to have
read the roadmap", the finding isn't finished. The remaining candidates: §5.2's
point-valued options silently coupled to `displays`, §5.6's "what second key
makes the first one a lie", and every "what this does NOT reach" paragraph in
§5.1 and §5.2.

**A fourth candidate arrived with limit 3's measurements, and closed within the
hour: a pack's SURFACE.** Nothing enforced that a pack touches only
`haus.roster` — `checkRice` bounds it to `haus.*` and stopped there,
which is why `packs/writing.nix` opened with a comment explaining the narrower
rule instead of a check enforcing it. It cost nothing until §6's seam existed,
and would have cost real confusion the moment it did, because the wrapper
silently drops whatever it wasn't written to carry. `checkPack` (rice#222) is
the same shape as `checkRice`, one level in. **Two ★ findings in this file are
now checks that can break, and this is the third** — the rule is holding.

**Fourth pass, 2026-08-05 — the falsified-claim shape fired again, and this time
the falsified claim was one of MINE.** §6's limit 3 asserted that a colliding
consumer "meets a raw nix conflict trace rather than anything this project
wrote". Nobody had read the trace. It names the option, both files and the fix
(§6). The rule from the second pass — *a closed claim goes stale when someone
learns the thing it asserted was wrong* — was written about other people's
commits; the sharper version is that **this document's own unmeasured
justifications are the most likely thing in it to be false**, because nothing
downstream ever executes them. Both of the last two passes ended by naming a
measurement as the next step, and both times the measurement contradicted the
paragraph that proposed it.

A fifth check candidate, from the same pass: **a `presets` check** in the shape
of `packs`, with the twist that it must assert a **collision** as well as its
absence — the pairs the docs advertise as stackable have to keep composing, and
the pairs advertised as alternatives have to keep failing. And a **fourth
finding that became a check the same day** (rice#228): *a wrapper applied to
someone else's module owes it a `_file`* — `lib.pack` dropped it, so the
collision it deliberately preserves was anonymous, and rule 3 of the `packs`
check now fails if it goes missing again. **Four ★ findings in this file are
now checks that can break.**

**Fifth pass, 2026-08-06 — the fifth candidate is written, and the audit was
empty.** `preset-composition` (rice#239, **merged the same day**) is that
check; §6's limit-3 section has
what it pins. **That makes five ★ findings in this file that are checks which can break.**
The remaining candidates, unchanged and now the whole list: §5.2's point-valued
options silently coupled to `displays`, §5.6's "what second key makes the first
one a lie", and §5.2's "what this does NOT reach" paragraph (§5.1's is covered by
`accent-reach`).

Two things this pass adds to the drift rule itself:

- **The audit found nothing, for the first time in five passes.** Not because the
  repos were quiet — eight rice PRs landed — but because none of them touched the
  option surface. That is worth writing down as a *result*: the rule's cost is
  one session, and a clean pass is the outcome that tells you the document has
  stopped being the family's slowest-moving artifact.
- **★ A number in this file is a claim, and a claim needs its method.** The fourth
  pass asserted "130 leaves, unmoved". Re-deriving it, three defensible ways of
  counting the same option tree give **203** (every doc-list leaf, including
  submodule sub-options), **160** (visible only) and **135** (visible, no
  `<name>` placeholders) — and **130** is what `nix build .#options-json` emits,
  which is the surface the options page renders. All four are true; only one is
  the number this document means. So the rule gains a small third clause:
  **when the doc quotes a count, quote the command that produced it** — otherwise
  the next pass either reproduces it by luck or "corrects" it to something else
  true. And where a derivation exists, prefer it to a count outright: building
  `options-json` at two revisions and comparing **store paths** answers "did the
  surface move" exactly, with no counting convention to get wrong.

**Sixth pass, 2026-08-06 — two of the three remaining candidates fell to one
measurement, and the larger one was aimed at the wrong layer.** §5.2's coupling
warning and §5.2's honest-scope paragraph were both answered by
[`probes/scale-reach.nix`](probes/scale-reach.nix) and are now the rice's
`scale-reach` check. **Seven ★ findings in this file are checks that can break,
living in five checks** — the two counts have drifted apart because `packs`
carries two findings and `scale-reach` closes two candidates, and the fifth
pass's own rule applies to this number as much as to a leaf count: say which
one you mean. The whole remaining list is §5.6's "what second key or precondition makes the
first one a lie", which is the one candidate here that is a *design rule for
options not yet written* rather than a property of one that exists — worth saying
out loud, because that is why it has outlived every other candidate. This pass
also hit a fresh instance of it outside macOS settings: "the terminal font can't
clip" is true only *while windows tiles the window* (§5.2), which is the same
shape — a claim whose second precondition is the thing that makes it a lie.

**A fifth shape, added as a row to the table above rather than kept beside it** —
a one-row table nobody consults is the same hazard the table exists to fix:
*a claim that is true, but about the wrong layer.*

§5.2 said "every point-valued option is silently coupled to `displays` — worth
auditing `fonts.*.size` and the tiler's gaps". Nothing in it is false; it is simply
about numbers *inside modules*, while the sentence is phrased as a rule about the
option surface, where the set has one member and the tiler's gaps aren't in it. **The
thing that exposed the mismatch was trying to turn the paragraph into a check** —
you cannot write a golden table without deciding what its rows are, and the rows
were not where the paragraph said. That is a second argument for §5.14's "leave a
check behind, not a paragraph" beyond regression-catching: **the check is a
type-check on the finding.** Prose can be true at no particular altitude; a table
cannot.

**Seventh pass, 2026-08-06 — a reach table can only see what evaluation
produces.** The sixth pass's technique, pointed at `fonts.mono.name`, found an
option reaching exactly one surface while the bar drew in a hardcoded family of
its own (§5.3, closed by rice#243). `font-reach` is the third of these tables and
the first that had to look somewhere else as well:

- the **generated** half — `sizes.sh`, `workspaces.sh`, ghostty's config — is
  visible by evaluating two rices and diffing, which is all `accent-reach` and
  `scale-reach` ever needed;
- the **static** half — the rc and the plugins, copied to the machine verbatim
  and read at runtime — is *invisible* that way: those files are byte-identical
  whatever the rice names, so the bug lived exactly where the technique was
  blind. The row that catches it reads the source files and counts font literals
  (0, and the next hardcode makes it 1).

**Generalise it: when a promise is kept partly by files the rice copies rather
than computes, a differential check cannot see that half.** The candidates with
the same shape are every other verbatim-copied config the rice ships — the
sketchybar plugins, the zellij scripts, `aerospace.toml`'s prose. Ask of each
table: *if someone re-hardcoded the thing this option promises, in a file we
copy, would this fail?*

**Eight ★ findings, six checks** (`data-only-surface`, `accent-reach`, `packs`
carrying two, `preset-composition`, `scale-reach` carrying two, `font-reach`).
The remaining candidate list is still §5.6's alone.
> ⚠️ **Corrected on the twenty-second pass: `preset-composition` no longer
> exists.** Its subject retired with the preset format, and the generalisable
> half moved into **`fragment-compat`** — recorded at the top of this file and
> never carried back into this roster, so the count stayed right while one of
> its six names went dead. Read the six as `data-only-surface`, `accent-reach`,
> `packs`, `fragment-compat`, `scale-reach`, `font-reach`, from
> `nix flake check` in the haus lane. ★ **A ledger of checks is itself a claim
> about the repo, and it drifts the same way a checkbox does** — the fifth
> pass's rule (quote the command that produced a number) turns out to apply to
> the *names* beside the number too, and nothing here was auditing them.

**Fourteenth pass, 2026-08-08 — the first pure audit since the fifth, and this
ledger had itself gone stale.** Passes eight through thirteen all *shipped*
something, wrote it up in a status block at the top of this file, and none of
them appended here — so §5.14, the section about drift, silently stopped
recording six consecutive passes. Nothing was lost (the status blocks are
thorough), but the section that exists to catch staleness is not exempt from it,
and a reader looking for "when was this last audited" would have found
2026-08-06.

One finding in a shape already on the table — the tenth pass's own "read out of
`config`, not hardcoded" claim, falsified by rice#255 (shape 2). One thing this
pass corrected that has no shape on the table yet, because it isn't a *finding*:
**the phase summary in §6 is a second checkbox surface, and §5.14's rule was
only ever pointed at §5.** Three of its lines described work that had shipped.
The rule's cheapest extension: *when you tick a box in §5, read the phase line
that names it* — they are the same claim written twice, which is the standing
condition for drift.

**And a sixth shape** *(it is row 7 in the table today — the twenty-first pass
also claimed "sixth", writing its own row while this one still sat outside the
table; both numbers were right when written)* **, which this pass produced
rather than found: an audit that
invents a regression.** Finding 1 as first written described a seventeen-minute
false green in `accent-reach` that never happened; it was built on comparing a
lock *rev* against a *merge* rev without diffing the trees, which squash-merge
makes meaningless. The pre-PR assurance pass — a clean-context subagent reading
the diff against the repos — caught it before the PR opened, which is precisely
the job that step exists for and the first time it has overruled a finding in
this file rather than a line of code. The shape belongs on the table because it
is the most expensive kind: every other row here describes a *true thing going
stale*, while this one puts a false thing in a document whose whole authority is
that its claims were checked.

*(This shape's row lives in the table at the top of §5.14 — it sat here as a
one-row table until the twenty-second pass folded it in.)*

Still **eight ★ findings, six checks** — and one *warning*, which is a new
category the ledger should keep separate. The more valuable of the two
candidates this pass raised shipped immediately (workshop#252: `bench status`
reports an `OFF-MAIN` lock edge), but it fires only when someone runs
`bench status`, where all six checks fire on `nix flake check`. Counting it as a
seventh check would overstate the guarantee. The other candidate — assert the
referent exists behind `accent-reach`'s cross-repo references — stays open and
low priority, since no break has occurred.

**Twenty-second pass, 2026-08-15 — the oldest candidate on this list got its
first instance, and it turns out the candidate's own excuse was half wrong.**
§5.6's "what second key or precondition makes the first one a lie" has outlived
every other candidate since the sixth pass, and the reason recorded here was
that it is *a design rule for options not yet written* rather than a property of
one that exists. True about the rule; false about its instances. `font-reach`
had one sitting in it: the check varies `fonts.mono.name` across two systems
that both leave `bar.clock.monoFont` at its default, so `clockLabelFont`'s
second branch — the one holding a hardcoded family — was never evaluated *by the
check whose entire job is finding hardcoded families* (§5.3, haus#363). The fix
is a third pair of systems with the second key flipped, and it costs one PR.

**So the candidate splits, and only half of it is hard.** The general rule needs
a design convention nobody has written; the instances are ordinary check work,
and every golden table in the flake can be asked the question today: *which
conditional does my sample never enter?* `scale-reach`, `accent-reach` and
`ai-room` all evaluate systems that leave most options at their defaults, so
each of them is blind in the same way to some branch — the question is only
whether anything interesting hides there. **Nine ★ findings, still six checks**
(`font-reach` now carries two, like `packs` and `scale-reach`) — the two numbers
moving independently is normal and worth restating, since the fifth pass's rule
about quoting a count applies to this ledger's own. The six, re-derived from
`nix flake check` rather than from this section: `data-only-surface`,
`accent-reach`, `packs`, `fragment-compat`, `scale-reach`, `font-reach`. **That
re-derivation is how the roster's dead name was found** — see the correction
under the seventh pass; the ledger had carried `preset-composition` for six
passes after the check stopped existing.

★ **And an eighth row for the shapes table, from the same pass's assurance
read** (eighth, not seventh: the twenty-first pass filed the sixth, and folding
in the fourteenth's stray one-row table below makes seven). Two claims in the PR were derived by reading the *generator* rather than
the artifact — "six pills set `label.font=` in that file" (five write it, three
are opt-in, one writes a different file, so the sampled file has one matching
line) and "the hardcode sat there for months" (`git log -S` finds one day). Both
are one shape, and the second one also inverted the moral: the blind spot is
OLDER than the bug it hid, so the cost was luck rather than time. **Filed as a
row in the shapes table at the top of this section, not as a table down here** —
and while doing that, the fourteenth pass's own row turned out to have been left
as a one-row table beside the list rather than folded into it, which is verbatim
the hazard the third pass warned about when it created the list. Both are in the
table now.

**Twenty-third pass, 2026-08-15 — the seventh check, and it reads another repo's
source rather than waiting for that repo to emit something.** Reason 1 at the top
of this section says the fix for every other cross-repo seam here was making the
upstream repo *emit* data (`options-json`, `wm-bindings-json`, `ports.meta.json`),
and that this one stayed prose on both sides. `pounce-item-grammar` takes the
third door: **a flake input already IS the upstream repo, at the rev you ship**,
so `${pounce}/pkgs/pounce/ItemSettings.swift` is readable in a `runCommand` with
no cooperation from pounce at all. It diffs `modules/launcher/item-grammar.nix`
against `ItemTarget`'s mode list and its error text, and it is in the all-systems
set — so unlike `accent-reach` it fires on CI as well as on this Mac. What it
caught, retroactively, was a day-old drift: pounce#80 added `shortcut:<uuid>`,
haus's lock moved to it two minutes later, and the layer went on refusing the
key (§5.9(b)) — the sharpest statement of reason 1 this section has: **the
automation that keeps the binary current runs in minutes, and the mirror of what
that binary understands moves at the speed of somebody noticing.**

**Ten ★ findings, seven checks** (`data-only-surface`, `accent-reach`, `packs`
carrying two, `fragment-compat`, `scale-reach` carrying two, `font-reach`
carrying two, `pounce-item-grammar`), still one *warning* counted separately.
The candidate list keeps §5.6's and gains one from this pass, phrased so it can
be asked of anything: **which dimension of this copy did I decide was closed?** —
the pounce mirror reasoned carefully about the six mode names it copies and never
about the four prefixes it enumerates, which is the twenty-second pass's
one-option blindness with a mirror in place of a check.

**Twenty-fourth pass, 2026-08-16 — the previous pass's correction went backwards,
and the mirror it was defending has been retired instead of re-documented.** The
finding is at the top of this file; what belongs *here* is that it is the first
entry on the shapes table whose failure is **younger than the pass that filed
it**. Every other row degrades an entry over time, so every mitigation this
section has is a way of asking *how old is this claim*. Row eleven can't be
caught that way: the wrong sentence in `AGENTS.md` was written 68 minutes after
the repo falsified it, by a session whose headline finding was that reading the
local checkout is reading memory — it applied that lesson to the paragraph it
was writing and not to the paragraph beside it. The cheap mitigation is one word
of discipline: **a measurement is dated at a rev, not on a day.** "Measured
2026-08-15" survives contact with a merge that happened at 10:06; "measured at
`afc3b58`" is checkable by anyone, forever, and `bench status` already prints
the rev of every edge it reads.

The pass's other half is reason 1 again — *the work happens in four repos and
the doc lives in a fifth* — arriving from the direction this section keeps
recommending and one it hadn't: **stop mirroring the other side and read it.**
`bench` held one machine's spelling of the layer's flake-input name in five
`--override-input` literals plus a row of `EDGES`, and `bootstrap.sh` began
scaffolding a *different* spelling on 2026-08-15, so the mirror had one live
counter-example a day after the twenty-third pass ended. It reads the name off
`$CONSUMER/flake.lock` now, and — the same reading, one field over — `bench
status` compares each edge's locked **source** as well as its rev, which catches
`~/.config/nix` still fetching the layer through the slug §10 freed five days
ago. Both are **`bench status` warnings, not `nix flake check` checks**, so the
ledger's headline number doesn't move: **fourteen ★ findings, seven checks, and
three warnings** (this pair plus `OFF-MAIN`). What did gain a real tripwire is
the workshop's own CI — twelve bats tests (`bats test/bench.bats`: 81 before, 93
after), mutation-checked, that fail the moment either literal is baked back in.
That is the
first time this ledger has counted a check outside haus's flake, and it is worth
noticing why it was possible: the workshop repo has a test suite because `bench`
is a program. A document doesn't get one.

**Twenty-seventh pass, 2026-08-19 — the ledger's roster went stale again, four
passes after the last time, and the mechanism was the same one both times.**
`packs` is `app-collections` since haus#386 (`mergedAt 2026-08-17T06:36:00Z`),
which retired the format the check was named for and kept the rules that
outlived it. Re-derived from `flake.nix` at `6ba56c8` rather than from this
section: `data-only-surface`, `accent-reach`, `app-collections`,
`fragment-compat`, `scale-reach`, `font-reach`, `pounce-item-grammar` —
**fifteen ★ findings, seven checks, three warnings**, the count unmoved and one
name replaced. ⚠️ **"Re-derived from `flake.nix`" needs its scope, and the
assurance read supplied it:** `flake.nix` declares 25 `runCommand` checks, and
this ledger counts the subset that encodes a ★ finding *from this file* — a
judgement, not a grep. So re-deriving catches a **rename** (look each of the
seven up, see if it still exists) and cannot catch a *missing* row, because
nothing mechanical knows which of the other eighteen a finding here asked for.
That is the ledger's one structural hole and it has no fix; the honest form is
to say which question the re-derivation answers. Two more things worth carrying:

- **A rename that preserves the count is the worst kind for a ledger**, because
  the number a reader spot-checks stays right while the roster under it doesn't.
  The seventh pass's dead `preset-composition` survived six passes; this one
  survived two, and only because re-deriving from `nix flake check` is now the
  written habit. The habit is the mitigation — there is no check that can check
  a list of checks.
- **The renamed check also changed platform**, and that is invisible in a
  roster. `packs` was pure `lib` and ran on Linux CI; `app-collections` moved
  inside `optionalAttrs (hasSuffix "-darwin")` and now fires on this Mac or not
  at all. The ledger has counted `accent-reach`'s darwin-gating explicitly since
  the fifth pass; the same asterisk belongs on this row, and nothing announced
  it — the PR that moved it was about a format, not a platform.

★ **The pass's own finding, and it is about the mirror this ledger added last:**
`pounce-item-grammar` broke, on main, in the direction the twenty-third pass
didn't consider. pounce#90 added a fifth shape (`setting:<pane>[?<anchor>]`),
which grew pounce's error literal past one line — so Swift's `+` concatenation
**wrapped it**, the check's `grep -o '(expected [^"]*)'` matched nothing on the
raw file, and the diff that would have named the missing shape came back empty.
The don't-delete-this-check guard fired instead, so CI was red with the wrong
message while the real drift sat underneath (fixed in haus#399: flatten the
source, then grep). Generalised: **a mirror that reads another repo's source is
coupled to that source's FORMATTING, not just its content** — a line wrap is a
semantic no-op on both sides and a total failure in between. The new candidate
question, sibling to the twenty-third pass's: *what in the upstream am I
matching that isn't the thing I care about?*

**Twenty-eighth pass, 2026-08-20 — the roster held for the first time in three
passes, and the pass's own finding is the twenty-seventh's, one day later and
inside a single repo.** Re-derived from `flake.nix` at haus `148c303` rather
than from this section: `data-only-surface`, `accent-reach`, `app-collections`,
`fragment-compat`, `scale-reach`, `font-reach`, `pounce-item-grammar` — all
seven present, none renamed, in a file that now declares **26** `runCommand`
checks — `git show 148c303:flake.nix | grep -c runCommand`, the same command
returning 25 at `6ba56c8`, the rev the last pass read. **Seven checks and three
warnings, both unmoved, and the ★ count is left where the last pass put it at
fifteen rather than advanced**, which needs saying plainly: this pass produced
four ★ paragraphs (§5.1's impossibility shape, §5.9's borrowed sentence, §5.8's
`file:line` mirror, and the candidate below) and **not one of them left a
tripwire behind**, so counting them would inflate the only number here that is
supposed to mean "something can break if this stops being true". The count has
never had a written rule for what qualifies — the twenty-sixth→twenty-seventh
step moved it 14 → 15 for a single ★ that also shipped nothing — so read
"fifteen" as *the last figure derived under the old habit*, and read the seven
and the three as the numbers that are actually checkable. This section's second
half says a finding that generalises should leave a check, not a paragraph;
four paragraphs is what this pass has. The
re-derivation answers the same narrow question it did last pass and no wider one
— *does each of these seven still exist* — and the ledger's structural hole is
unchanged: nothing mechanical knows which of the other nineteen a finding here
asked for.

★ **`desktop-seam` was red on main for just under three hours (2 h 55 m,
`8a6b9d6`→`148c303`) for the same reason
`pounce-item-grammar` was red for a day, and the two are one shape.**
[haus#410](https://github.com/hausfold/haus/pull/410) (`8a6b9d6`,
2026-08-20T00:21:37Z) taught the free-key validator to reject tabs and reworded
its diagnostic; the golden table in `flake.nix` still carried the old wording,
so the check failed on main until [#417](https://github.com/hausfold/haus/pull/417)
re-synced the table by hand (`148c303`, 03:16:21Z). The twenty-seventh pass
asked *what in the upstream am I matching that isn't the thing I care about?* of
a mirror **across a repo boundary**, where the coupling is easy to believe in.
This says it costs exactly the same inside one repo, where "upstream" is the
file next door and nobody thinks of it as a mirror at all: a golden table that
pins a **sentence** is coupled to that sentence's wording, and a reword is a
semantic no-op on the producing side and a total failure on the consuming one.
What #417 did is re-copy, which restores green and leaves the coupling; what the
question asks for is to stop matching the prose — pin the validator's
**predicate** (which keys it rejects) and let the diagnostic say whatever it
says. Filed as a candidate rather than a check, because it is one line of
judgement per golden table and nobody has swept them: `desktop-seam`, `keymap`,
`accent-reach`, `scale-reach`, `font-reach` and `pounce-item-grammar` all pin
*something*, and only the last one has been asked what.

Two smaller things, neither a finding:

- **Two §5 boxes closed on 2026-08-19 by drive-by notes commits rather than by a
  pass** — `0257e30` (§5.2's `motion`, shipped as `haus.appearance.reduceMotion`)
  and `77f23ed` (§5.6's tenth group). Both are thorough, both tick the box *and*
  move the header, and neither appended here — the fourteenth pass's finding
  (six consecutive passes that shipped and never wrote a line in the section
  about drift) in its smallest form. No fix is proposed: this ledger is a record
  of *findings*, not of when the file was edited, and a box closed correctly
  without one costs nothing. Worth the line only so a reader counting passes
  doesn't read the gap as the file sitting still.
- **This pass ran from a cloud session**, so every claim about another repo is
  `git log` / `git show` over an anonymous clone rather than the GitHub API:
  `mergedAt` is unavailable and the timestamps quoted above are merge commits'
  committer dates, which for a squash merge is the same instant. The rev is the
  durable half either way. §8 gains the capability line, because "read the
  family at a rev" turns out to be most of what auditing this file needs and
  none of what §8 was written to answer.

---

## The passes

A pass is what one session found when it checked the roadmap's open boxes
against the repos: what shipped, what was ticked and shouldn't have been, and —
the part worth keeping — the claims a document made about itself that turned out
to be false. The table above is the standing summary; these are its evidence.

**The three most recent live here. When a fourth lands, the oldest of the three
moves to [`options-roadmap-log.md`](options-roadmap-log.md), unedited**, and
both pointer counts are re-COUNTED (`grep -c '^> \*\*Status, '`) rather than
incremented. Never edit an entry: a dated finding corrected in place stops being
evidence.

> **Status, 2026-08-23 (thirty-eighth pass) — at haus `561af88`, the defect
> class this repo has now FIXED TWICE was re-derived as impossible at a third
> site, in a comment that names a mechanism the shipped fix does not use. And
> two other classes in the same 47-minute window were swept by hand and left no
> check behind. `options.json` is 318 leaves for the fourth consecutive reading,
> key for key, across 17 h 25 m.**
>
> Fetched first (twenty-third pass's rule), dated at revs (row eleven), derived
> from the rev rather than from a PR body (the thirty-fourth pass's sharpening):
> workshop `5bf1fb7`, haus `561af88`, perch `352b466`, hausfold.co `09052fb`,
> holt `809cc3c`. pounce is `aabd99a` and nebelung `5d5d0a2`, unmoved as of
> those revs — a fact about two revs and not a licence to skip §5.9 (row
> nineteen). ⚠️ And no `= origin/main` anywhere above, which is the thirty-seventh
> pass's own narrowest rule, applied on the first pass that could apply it: a
> tip equality is the one clause in a pass that starts going stale the moment it
> is written. Non-cloud, so every time below is a committer date on
> `origin/main`, in UTC; the family's local time is UTC−5, so this whole block
> is Saturday evening at the keyboard.
>
> Landed since the thirty-seventh pass's revs — a **34-minute** window, every
> commit between 04:52:54Z and 05:26:26Z (33 m 32 s; 47 minutes is the distance
> from the previous pass's haus rev, which is not what this sentence says and
> not what the last three passes' windows measure). **Six haus** (#471
> 04:52:54Z, #473 05:13:02Z, #472 05:25:17Z, and **three** lock bumps — the
> third is this pass's own haus endpoint rev), **three perch** (#87 04:59:04Z
> plus the `2026.08.23` release and its nix pin), **two holt** (#54 04:59:47Z
> and the **`0.4.0` release**, 05:18:42Z — the semver one, five SDKs, none of
> which can withdraw a published number), **one hausfold.co** (#132 05:24:37Z)
> and **four workshop** (#438, #439, #440 and the thirty-seventh pass itself).
>
> **The count was 11 at `5bf1fb7`** — the number the thirty-seventh pass
> predicted — re-derived with the command the last ten passes ran (`sed -n '/^##
> 5\. The option families/,/^### 5.14/p' notes/options-roadmap.md | grep -c '^-
> \[ \]'`). This pass **closes one and opens none in the counted range**, so the
> pass after this one should find **10**. The one it closes is §5.6's, and it
> closes the way §5.14 said it would: written a pass ago as `- [ ] ◐ built and
> open, mergedAt null`, ticked here against `mergedAt 2026-08-23T05:25:17Z`
> (`6bb294c`). It also opens a box in **§5.14**, which the count command does not
> reach — deliberately, since that section's boxes are checks-about-the-doc
> rather than option work — and rotates the log: the thirty-fifth pass moves to
> [`options-roadmap-log.md`](options-roadmap-log.md) unedited, both pointer
> counts re-COUNTED rather than incremented (36).
>
> `docs/site-data/options.json` at `561af88` is **318 leaves in 35 namespaces**,
> and the interesting number is how long: `diff <(git show ff8ecf3:… | jq -r
> 'keys[]') <(git show 561af88:… | jq -r 'keys[]')` is **empty** — key for key
> identical across **17 h 25 m** (`ff8ecf3`, 2026-08-22T12:00:55Z → `561af88`,
> 2026-08-23T05:26:26Z), four consecutive readings and three passes reporting
> "unchanged". **Seven** haus PRs landed inside that window — #466, #467,
> #469, #468, #471, #473, #472 — twelve commits, five of them lock bumps.
>
> ★ **First, and it is the pass: haus#473 declared its own gap unfixable, and
> the fix was already in this repo, twice.** `modules/ai/default.nix` lists the
> skill names each hausfold tool ships (`holt`, `handoff`) so haus can link them
> into every client's skills directory, and its comment says, in full: *"⚠️ The
> names are UNVERIFIABLE from here, by construction: nothing checks that the
> derivation actually contains them, because the check would be a readDir on a
> store output — import-from-derivation. A name listed here that the pinned
> revision does not ship installs a DANGLING symlink, silently: eval, `nix flake
> check` and the home-files build are all green, because a home.file source
> pointing inside a store output is never existence-checked."* Quoted whole on
> the assurance read's insistence: the first draft stopped at "silently" and
> then presented the elided clause as its own measured result. **The comment
> already knew what happens.** What it gets wrong is three words — "by
> construction" — which is why the finding is about the conclusion and not the
> description.
>
> **Half of that is exactly right and the conclusion does not follow.** LISTING
> what a tool ships needs an eval-time read of a derivation's output, which is
> IFD and would force a build every time somebody runs `haus get`. ASSERTING
> that a listed name is there needs no eval-time read at all — and this repo
> already does it, in two rooms, on this document's own finding. §5.14's
> fourteenth-pass box (*"a check can pass on the pointer while the referent is
> missing"*) was closed on 2026-08-14 by copying the placed theme ports through
> one `runCommand`, which **makes the referent a build DEPENDENCY rather than a
> promise**; `modules/theme/ports.nix:158-161` says so in those words, and names
> terminal's `glowPlugin` as the other site. Neither is IFD. The third site
> re-derived the problem from scratch, reached for the one mechanism that is
> ruled out, and stopped.
>
> **Measured at `561af88`, adding a fourth name `no-such-skill` to the list:**
>
> ```
> $ nix eval …home.file.".claude/skills/no-such-skill".source
> /nix/store/sz1jm8z…-holt-skill/no-such-skill          # evaluates clean
> $ ls /nix/store/sz1jm8z…-holt-skill/
> handoff  holt                                          # it is not there
> $ nix build …home-files                                # exit 0
> …/.claude/skills/no-such-skill ⇒ /nix/store/…/no-such-skill
> $ test -e …                                            # DANGLING
> ```
>
> Fixed in [haus#475](https://github.com/hausfold/haus/pull/475) by the ports
> pattern, mutation-tested three ways; the box is in §5.14 with its sibling, and
> is ticked only on `mergedAt` (row fourteen). Its shape is **row sixteen**
> sharpened, and the sharpening is where to look — see row twenty-four.
>
> ⚠️ **And the first draft of this block cited haus#474, which is somebody
> else's merged PR.** The number was guessed as next-free while the PR was still
> unopened; #474 (*"ai: the desktop guard reads the target, not the text"*)
> merged at 05:34:02Z, **six minutes before** the commit that cited it. Caught
> by the assurance read, at 5/5. Row fourteen says a PR number in a tick is a
> promise only `mergedAt` keeps; this is that failure one step earlier — a
> number that is a promise about a PR *which does not exist yet*, and GitHub
> will resolve it to whoever got there first. **Open the PR, then write the
> number.** Not a new row: row fourteen with the clock wound back further, and
> the same fix.
>
> ⚠️ **This finding is written at a rev on purpose, headline included** — the
> thirty-seventh pass's row twenty-three, applied by the first pass that could.
> haus#475 and this block are two PRs in two repos with no seam between them
> (§5.14's structural reason 1), so they merge in whichever order GitHub reaches
> them, and the last time that happened the gap was twelve seconds. *At
> `561af88`, X* survives either order; *X is still standing* survives neither.
>
> ★ **Second: two more classes in the same window, both swept by hand, neither
> left a check.** haus#471 fixed the bash multibyte swallow — `"…“$query”"`
> makes the closing curly quote part of the identifier, so the row printed
> nothing under no `set -u` and **exited 1 having found its matches** under one,
> killing ⌘⇧F's transcript search on both its hit and its miss path. Its message
> carries a repo-wide sweep (`grep -rnP … '[^\x00-\x7F]'`) proving no site
> remains — run once, at a keyboard. At `561af88` that pattern appears in no
> workflow, no flake check and no test: `grep -n 'x00-x7F' .github/workflows/
> check.yml flake.nix test/*.nix` is empty, and `add-app.sh` is not in
> check.yml's lint list at all. shellcheck cannot see the class (SC1111 objects
> to the curly quotes, which are deliberate display text). And haus#472's own
> assurance read found the **fourth** rot in check.yml's hand-written CI census
> — the Linux list said fifteen where `nix eval` says nineteen — in the file
> whose comment says *"it rots in every direction"* and then dates the three
> previous rots.
>
> **Three classes, one 47-minute window, and the shape is the same in all
> three: the knowledge exists as PROSE at the site, and prose does not stop the
> next instance.** A comment that confesses a gap, a commit message that proves
> a sweep, a census that dates its own rots. §5.14 has said since the sixth pass
> that the structural fix is to *make the repo emit something mechanical*, and
> named `data-only-surface` and `accent-reach` as the two that took it. This
> window produced three candidates and one PR. The row this adds is narrower
> than "write more checks", because two of the three had a check available and
> declined it: **grep the repo for the FIX before writing down that there
> isn't one.**
>
> ◐ **And what actually moved this window, since the leaf count saw none of
> it**: holt `0.4.0` (five SDKs; `--prompt`/`--prompt-file` and a second shipped
> skill), perch `2026.08.23`, haus#473 turning `haus.ai.skill` from "haus's own
> skill" into "every hausfold tool's skill" — a widened *meaning* on an existing
> bool, with a rewritten description and **zero** leaves added. Fourth pass
> running that the day's most stranger-visible change is invisible to
> `options.json`, and the third of the last four in which it is a description
> string.


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


> **The passes before this one are in
> [`options-roadmap-log.md`](options-roadmap-log.md)** — **thirty-six** dated
> entries, 2026-08-22 back to 2026-08-02: the thirty-five numbered passes plus
> a second, unnumbered 2026-08-04 block that predates the numbering (which is
> why "twenty-nine" was one short on the day of the split, and is corrected here
> rather than incremented — and it is COUNTED at every move, with `grep -c '^>
> \*\*Status, ' notes/options-roadmap-log.md`, never incremented). Split out on
> 2026-08-20 when the
> preamble reached 2,393 lines and outweighed every other file in `notes/`.
> The three most recent stay above. Nothing moved but the text: no entry was
> edited, merged or dropped.

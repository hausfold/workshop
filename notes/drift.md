# Drift — the shapes a write-up here goes wrong in, and what catches each one

**The standing catalogue.** Every row below is a way a claim in this family's
documents stopped being true, found by someone re-checking it against the
repos — and beside it, the only thing that actually catches that shape. It is
not a roadmap and tracks no option work: the file it came out of does that. Its
boxes are **checks this catalogue left behind** — tripwires it owes the repo,
which is a different thing from a feature and is still work. As of the
thirty-ninth pass all three are closed; the follow-up the last one names (a
`lib.checkedRef` helper, so the pattern travels instead of being stated a fourth
time in a fourth comment) is deliberately not a box here.

**Split out of [`options-roadmap.md`](options-roadmap.md) §5.14 on 2026-08-23**,
after the thirty-eighth pass, because the two halves had stopped being one
subject. That file's option surface has been 318 leaves for five consecutive
readings while this catalogue has taken a new row in each of the last five
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
2. **The row numbering is FROZEN.** Rows are numbered by position and cited by
   number — in this repo's `notes/`, and from `haus`, whose commit `6bb294c`
   argues from *"§5.14 row twenty"*. That is two repos and a handful of
   citations, not the "four repos" an earlier draft of this line claimed; the
   rule is worth keeping at its real size, because a frozen numbering costs
   nothing and a renumbering silently rewrites someone else's argument. A new
   shape is APPENDED; no row is ever reordered or removed. The table is 26 rows
   as of 2026-08-23 — the twenty-fifth was written by this file's own split,
   about the prose that announced it, and the twenty-sixth by the pass that
   found that split's own headline number measuring one dimension too few.
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
| a DECISION that is right, propped up with support nobody checked — the reasoning stands without the extra clauses, and the extra clauses are what a later reader verifies *(twenty-fifth row, written from inside this file on the commit that created it: four claims in `55235fc`'s new prose — "thirty-six dated entries link to it by that name" (zero do), "cited by number across four repos" (two), "source comments in `haus` cite rows by number" (no `.nix` or `.sh` in that repo mentions §5.14 at all), and a header promising the file "holds no work" twelve lines above its one open box)* | asking, of each clause supporting a decision you have already made, whether deleting it would change the decision. If not, it is decoration, and decoration is the part that gets checked — a reader who catches one false support clause re-opens the whole decision, including the half that was sound. This is row twenty-two's *width* problem aimed at a rationale rather than at a correction, and it is the cheaper failure to make: nobody sets out to invent evidence, they reach for a second reason because one felt thin. Every instance above was written in the same twenty minutes, by the same author, **while moving the table that contains row twenty-two** |
| a STABILITY claim measured by an instrument NARROWER than the claim — the metric is honest, its dimension is not the one that moved, and "unchanged" comes back true reading after reading *(thirty-ninth pass — "318 leaves, key for key" carried four headlines from `ff8ecf3` to `56697b7`, 21 h 59 m, while `haus.displays.<name>.uiScale` gained a fifth legal value in haus#478 and the key set never twitched)* | diffing the instrument's output at a SECOND dimension before writing "unchanged" — here one substitution, `jq -Sr 'to_entries[]\|"\(.key)\t\(.value.type)"'` in place of `jq -r 'keys[]'`, which is how this was found. The tell is a claim whose subject ("the option surface") is wider than the measurement's ("the option NAMES"): a new legal value is the most stranger-visible growth an option can have short of a new option — it is precisely what a desktop author may now write — and a key-set diff cannot see one. Distinct from row twenty, which is a check whose snapshot refreshes while the prose it protects rots: this instrument refreshes nothing and is not wrong, it is aimed one dimension away from the sentence it is quoted for. And what let it survive four readings is that it kept being RIGHT — four true "unchanged"s are what made the fifth feel like confirmation rather than a measurement, which is the same trap row twenty-five names one level up, a sound claim propped on support nobody re-derived |
| a REMEDY named in shipped instructions and MEASURED to be a no-op by the same repo — the advice still parses, still exits 0, and produces nothing; the room that ships it is not the room that measured it, and the falsification is not LATER than the claim but beside it, in the same rev *(fortieth pass — `modules/ai/default.nix:260`'s *"`open -g` launches without activating"*, live as line 80 of `~/.claude/CLAUDE.md` on every machine the layer installs, and `desktop-guard.sh:243` handing an agent that same form as the compliant one, 49 seconds after `lane-open.sh:236` recorded that `open -g -na Ghostty.app` "leaves a live Ghostty process with NO window, ever")* | grepping for the MECHANISM a commit falsifies — the identifier, not the sentence — inside the PR that falsifies it: `git grep -n 'open -g'` at `4151ac0` is **14 hits in 6 files**, of which that PR touched two, both places where the measurement is written DOWN. This is row twenty-four's search pointed the other way — row twenty-four asks *did we already build the fix and forget*, this asks *who else is quoting the thing I just disproved* — and it needs its own row because neither surface §5.14 polices can see it and neither can a check: `test/desktop-guard.bats` came back green **while pinning `open -g -a Ghostty` as the approved silent form**, because a fixture pins the SHAPE it was written for and knows nothing about whether that shape still works. Row twenty aimed at a fixture instead of a snapshot. And the cost is not a stale doc — it is every agent on every installed machine following an instruction to a command that exits 0 and draws nothing |

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
- [x] ✅ **Assert the referent exists for every TOOL SKILL `modules/ai` lists** —
      the same gap as the box above, three sites on, and the first one whose own
      comment argues it cannot be closed. **Shipped in
      [haus#475](https://github.com/hausfold/haus/pull/475), `mergedAt
      2026-08-23T06:57:37Z`** (`db09f32`) — written a pass earlier as *"built and
      open as of 2026-08-23T06:28Z, `mergedAt` null"*, and ticked here only once
      the PR had one, per row fourteen. ⚠️ The `mergedAt` is **one second later**
      than the merge commit's committer date (06:57:36Z); the box above this one
      was off by nine seconds the other way. Two instances is enough of a pattern
      to state the rule: read `mergedAt` off the PR, never off the log. The "as of" is dated on purpose and read
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

> **Status, 2026-08-23 (fortieth pass) — at haus `7968b7f`, the layer ships an
> instruction whose remedy the same rev measures as a silent no-op.**
> `modules/ai/default.nix:260` tells every agent on every machine *"Never
> foreground an app just to see it. `open -g` launches without activating"* —
> and `modules/terminal/lanes/lane-open.sh:236`, merged **49 seconds** before
> this pass's endpoint, records that `open -g -na Ghostty.app` "leaves a live
> Ghostty process with NO window, ever". haus#487 touched **no file under
> `modules/ai`**. Separately, the thirty-ninth pass's own *"both pointer counts
> re-COUNTED"* moved one of the two.
>
> Fetched first (twenty-third pass's rule), dated at revs (row eleven), derived
> from the rev rather than from a PR body (the thirty-fourth pass's sharpening),
> and with no `= origin/main` anywhere (the thirty-seventh pass's narrowest
> rule, applied for the third time): workshop `6bb78d9`, haus `7968b7f`, perch
> `617703d`, hausfold.co `511364a`, pounce `979acb5`. holt is `c8c1056` and
> nebelung `5d5d0a2`, both unmoved as of those revs — a fact about a rev and not
> a licence to skip §5.1 (row nineteen). Non-cloud, so every time below is a
> committer date on the branch, in UTC; the family's local time is UTC−5, so
> this block is still Sunday morning at the keyboard.
>
> Landed since the thirty-ninth pass's revs — **9 commits in 20 m 59 s**,
> 10:56:15Z to 11:17:14Z, by some way the narrowest window any pass has read
> (the last three were 4 h 28 m, 34 m and 25 m). **Three perch** (#95–#97),
> **two workshop** (#444, the thirty-ninth pass itself, and #445), **two haus**
> (#487 and the lock bump that is this pass's endpoint), **one hausfold.co**
> (#137) and **one pounce** (#98). **Zero holt, zero nebelung.**
>
> **The count is 10** — the number the thirty-ninth pass predicted — re-derived
> with the command the last twelve passes have run (`sed -n '/^## 5\. The option
> families/,/^### 5.14/p' notes/options-roadmap.md | grep -c '^- \[ \]'`). This
> pass closes none and opens none in the counted range, so the pass after it
> should find **10** again. It rotates the log: the thirty-seventh pass moves to
> [`options-roadmap-log.md`](options-roadmap-log.md) unedited, both pointer
> counts re-COUNTED rather than incremented (38) — at **both** of them this
> time, which is the second finding below.
>
> ★ **First, and it is the pass: an instruction shipped to every machine names a
> remedy the same repo has measured to be a no-op.** haus#487 (`4151ac0`,
> `2026-08-23T11:16:25Z`) is titled *"⌃↵ opened no window at all — `open -g` is
> why"*, and the comment block it lands at `lane-open.sh:232` is a measurement:
>
> ```
> open -g -na Ghostty.app --args --title=probe --initial-command=<script>
> ```
>
> "leaves a live Ghostty process with NO window, ever, and the initial-command
> NEVER RUNS — so no zmx session, no client, no lane: a Dock icon and nothing
> else." It goes on to name the reason nothing downstream noticed for as long as
> ⌃↵ has existed: **`open` returns the moment LaunchServices accepts**, so the
> whole chain exits 0 over a window that was never drawn.
>
> That is the exact mechanism three other sites recommend, and **the PR touched
> none of them.** `git grep -n 'open -g'` at `4151ac0` returns **14 hits in 6
> files**; #487's five files include two of the six, both places where the
> measurement is *written down*. The other four are where it is *contradicted*:
>
> - **`modules/ai/default.nix:260`** — the `haus.ai.instructions` default, and
>   therefore the text of `~/.claude/CLAUDE.md` on every machine the layer
>   installs. Checked here, not inferred: **line 80 of the file this session is
>   running under**, resolved through the store symlink. It is unqualified.
> - **`modules/ai/desktop-guard.sh:243`** — the PreToolUse hook's own refusal
>   text, *"Use `open -g` to launch it in the background, or ask the user to
>   open it."* The guard is the thing that catches an agent about to take the
>   screen, and the compliant form it hands back is the one that opens nothing.
> - **`test/desktop-guard.bats:66`** — `silent 'open -g -a Ghostty'`. A fixture
>   pinning as the approved quiet form the flag-and-app pair the same rev
>   measures as producing no window. **Ghostty is the app it names.**
> - **`modules/shelf/default.nix:329`** — `open -g "$perchDest"`, on a *file*
>   rather than an app, and the one of the four that is not touched by any of
>   this. It is here because the row must not be read wider than the evidence.
>
> ⚠️ **What is measured and what is not.** #487 measured Ghostty, with `-n` and
> `--args --initial-command`. Nothing here proves `open -g -a Preview` fails,
> and the instruction is not simply false. What it is is **unqualified where the
> repo now knows a qualification**, in prose whose readers are agents doing the
> one thing the qualification bites: opening an app *to see it*. And because
> `open` exits 0 either way, an agent that follows the instruction cannot tell
> which it got — the same blindness #487 blames for `holt spawn` "exiting 0 over
> a lane that had never started".
>
> **The catch is a grep, and it is row twenty-four's aimed the other way.** Row
> twenty-four says: before writing that something is impossible, grep for the
> fix. This says: before merging a commit that falsifies a MECHANISM, grep for
> the mechanism's other readers — the identifier, not the sentence. Fourteen
> hits, six files, one command, inside the PR that already knew. And note which
> surface failed: the layer has a check for this class, `test/desktop-guard.bats`
> — it ran green, because a fixture pins the *shape* it was written for and
> knows nothing about whether the shape still works. Row twenty pointed at a
> fixture instead of a snapshot. **Row twenty-seven**, and the fix is a PR in
> `haus`, not a sentence here.
>
> ★ **Second: the correction that reported itself applied at two sites was
> applied at one — and it is the rule that exists to prevent exactly this.** The
> thirty-ninth pass's block closes *"both pointer counts re-COUNTED rather than
> incremented (37)"*. `drift.md`'s tail moved to **thirty-seven**.
> `options-roadmap.md:180` still reads **thirty-six**, and dates its range
> *"2026-08-22 back to 2026-08-02"* where the log's newest entry is 2026-08-23.
> `grep -c '^> \*\*Status, ' notes/options-roadmap-log.md` returned **37** while
> the pointer said thirty-six — which is the whole content of the rule the same
> sentence invokes. **Row seventeen, second instance**, and the first one aimed
> at a re-count rather than at a line of prose. Both halves corrected in the
> commit carrying this block, and both counts re-derived: log **38**, this file
> **3**.
>
> ◐ **Third: the instrument, widened again — and this time the check underneath
> it was checked.** `docs/site-data/options.json` at `7968b7f` is **318 leaves**
> for the sixth consecutive reading, and **byte-identical to `56697b7` at every
> field**, not just key and type: `diff <(jq -S . A) <(jq -S . B)` is empty.
> Widening the instrument shortens the span you may honestly claim, which is the
> thirty-ninth pass's point turned on its own fix — the key set has been quiet
> for 23 h 16 m, the whole leaf only since `7be2ae0` (09:27:03Z, haus#483), **1
> h 50 m**.
>
> **And the foundation, for the first time in forty passes.** Six headlines have
> led with a number read out of a COMMITTED artifact, and none had asked what
> forces the committed copy to equal the module system. It is
> `checks.<system>.site-data-current`, and all three of its load-bearing
> properties hold: it is in the **all-systems** set (`nix eval
> .#checks.x86_64-linux --apply builtins.attrNames` lists it among twenty), CI
> runs **`nix flake check` unqualified** (`.github/workflows/check.yml:141`, so
> the builder-side `diff -ru` is not skipped the way `--no-build` would skip it),
> and it is **green on darwin here** — `nix build
> .#checks.aarch64-darwin.site-data-current`, run at this rev, exit 0. That last
> one is not decoration: CI's only flake-check job is `ubuntu-latest`, so the
> committed copy is pinned to the Linux render, and nothing but a Mac run proves
> the darwin projection agrees. It does. **Row twenty-five's remedy, applied by
> hand** — the decision was sound and its support had never been re-derived.
>
> ◐ **Fourth: §5.4's `scope` box is fifteen no longer, four hours after it was
> written.** The box (thirty-seventh pass, `5bf1fb7`, 05:25:26Z) counts *"a
> literal string fifteen call sites in nine files across three rooms now
> hardcode"*. At `7968b7f` it is **sixteen call sites**, still nine files, still
> three rooms — haus#484 (`a6d1474`, 09:40:29Z) added
> `bar/sketchybar/aerospace-notify.sh:26`, an `aerospace_tiling_change` trigger,
> from the **windows** room, for a reason with nothing to do with `scope`. The
> box's thesis is that the literal spreads; it spread once in the first four
> hours and fifteen minutes of the box's life, and the box is the only thing in
> the repo that would notice.
>
> ⚠️ **Derived twice, because the naive grep says eighteen.**
> `git grep -c '/run/current-system/sw/bin/sketchybar' 7968b7f -- modules` sums
> to 18; two of those are **comments** (`modules/bar/default.nix:1692` and
> `:1799`, both prose *about* the path). Fifteen was exactly right when written —
> 17 total minus 2 — which is worth saying plainly, because the interesting
> version of this finding was the wrong one, and it took the second derivation
> to keep row twenty-five off this block.
>
> ◐ **And what actually moved, since the leaf count saw none of it — including
> this document's own output.** The thirty-ninth pass's finding **left the file
> and landed in another repo in sixteen minutes**: hausfold.co#137 (`511364a`,
> 11:12:01Z) regenerates `reference/options.mdx` from haus `56697b7`'s
> site-data, and its body says so — *"Found by the workshop's options-roadmap
> thirty-ninth pass"*. It corrected **five** option entries, not the one the pass
> named, and then three hand-written pages beside them (`rooms/displays.mdx`,
> `agent-rebuilds.mdx`, `rooms/focus.mdx`) that no check covers at all: the
> weekly options-drift cron would have caught the generated page and never the
> prose. **Row twenty again — and for the first time measured across a repo
> boundary, where the check and the prose it fails to protect are in different
> repos on different schedules.** Beside
> that: perch's #95–#97 (bounded cloud-wait syscalls, a watched drag-out
> destination that shelved the item straight back, and coverage-instrumented
> binaries out of the shipped build) and pounce#98 swallowing a claimed Return's
> key UP so macOS stops dropping a context menu on the palette. Sixth pass
> running that the day's most stranger-visible change is invisible to
> `options.json` — and the first in which the day's most stranger-visible change
> is **a sentence this file caused to be rewritten somewhere else.**
>
> ⚠️ **Coda, written into this block rather than corrected into it: the streak
> ended 83 seconds after this pass's rev.** haus#486 (`cdb4198`,
> `2026-08-23T11:18:37Z`) adds `haus.ai.repoRoots` — the palette's Spawn Agent
> repo list, previously a `$HAUS_REPO_ROOTS` env var that the one process which
> reads it, a launchd GUI agent, could never see. **`docs/site-data/options.json`
> is 319 leaves there**, ending six consecutive readings of 318, and the key-set
> instrument sees it perfectly: a new leaf is precisely the growth a key diff
> CAN show. So the thirty-ninth pass's widening is not retired by this — it was
> aimed at the growth a key diff cannot show, and both instruments are now
> earning their keep on the same file eighty-three seconds apart.
>
> This is left standing rather than folded into the paragraphs above because
> the block is dated at `7968b7f` and was true there, and **this is the first
> time a pass has been able to demonstrate rev-bounding working rather than
> assert it** (row nineteen, row twenty-three). A reader who lifts *"318 leaves
> for the sixth consecutive reading"* out of this block without its rev is
> quoting something that had ninety seconds to live.
>
> ⚠️ And one thing that is NOT a second missed catch, said plainly so it does
> not become one: `cdb4198` does edit `modules/ai/default.nix`, the file
> carrying the instruction above — at line 799, `inherit (cfg) default
> repoRoots;`, 539 lines from the sentence and with no reason to read it. The
> finding is that the room shipping the remedy never learned; it is not that
> someone looked at the line and left it.


> **Status, 2026-08-23 (thirty-ninth pass) — at haus `56697b7`, the number five
> readings have led with is honest and one dimension too narrow.
> `options.json` is 318 leaves for the FIFTH consecutive reading, key for key,
> across 21 h 59 m — and inside that span an option's TYPE grew a fifth legal
> value, which a key-set diff cannot see. Separately, §5.10's open box lost its
> blocker to a PR in the same repo the same morning, and the one-command remedy
> it names does not print the thing it is asked for.**
>
> Fetched first (twenty-third pass's rule), dated at revs (row eleven), derived
> from the rev rather than from a PR body (the thirty-fourth pass's sharpening),
> and with no `= origin/main` anywhere (the thirty-seventh pass's narrowest
> rule, applied for the second time): workshop `736b065`, haus `56697b7`, perch
> `48ba346`, hausfold.co `59d08f4`, holt `c8c1056`, pounce `5afd6cb`. nebelung
> is `5d5d0a2`, unmoved since 2026-08-20 as of those revs — a fact about a rev
> and not a licence to skip §5.1 (row nineteen). Non-cloud, so every time below
> is a committer date on the branch, in UTC; the family's local time is UTC−5,
> so this block is Sunday morning at the keyboard.
>
> Landed since the thirty-eighth pass's revs — **33 commits in 4 h 28 m**,
> 05:31:51Z to 09:59:45Z, a window several times wider than the last two passes'
> 34 and 25 minutes. **Nineteen haus** (twelve PRs, #474 through #485, plus
> seven lock bumps — the last of which is this pass's haus endpoint), **seven
> perch** (#88 through #94, one morning's sweep of the shelf), **three
> hausfold.co** (#133–#135, each documenting a haus PR from this same window),
> **two workshop** (#442 — the split that created this file — and #443), **one
> holt** (#55) and **one pounce** (#97). **Zero nebelung.**
>
> **The count is 10** — the number the thirty-eighth pass predicted —
> re-derived with the command the last eleven passes have run (`sed -n '/^## 5\.
> The option families/,/^### 5.14/p' notes/options-roadmap.md | grep -c '^- \[
> \]'`). This pass closes none and opens none in the counted range, so the pass
> after it should find **10** again. It does close the one box in THIS file, on
> `mergedAt` and not before (row fourteen): haus#475, written a pass ago as
> *"built and open … `mergedAt` null"*, merged at **2026-08-23T06:57:37Z**
> (`db09f32`) — one second AFTER its committer date, the same discrepancy the
> box above it recorded at nine seconds in the other direction, which is now
> two instances and a reason to read `mergedAt` off the PR every time rather
> than off the log. And it rotates the log: the thirty-sixth pass moves to
> [`options-roadmap-log.md`](options-roadmap-log.md) unedited, both pointer
> counts re-COUNTED rather than incremented (37).
>
> ★ **First, and it is the pass: the leaf count is a key-set diff, and what
> moved was a type.** `docs/site-data/options.json` at `56697b7` is **318 leaves
> in 35 namespaces**, key for key identical to `ff8ecf3` (2026-08-22T12:00:55Z →
> 2026-08-23T09:59:45Z, **21 h 58 m 50 s**) — the fifth consecutive reading and
> the fourth pass to report it. Every one of those reports ran
> `diff <(git show A:… | jq -r 'keys[]') <(git show B:… | jq -r 'keys[]')`, and
> every one of them was correct.
>
> **Ran the same command at a second dimension and the span is not quiet:**
>
> ```
> $ diff <(git show ff8ecf3:… | jq -Sr 'to_entries[]|"\(.key)\t\(.value.type)"') \
>        <(git show 56697b7:… | jq -Sr 'to_entries[]|"\(.key)\t\(.value.type)"')
> < haus.displays.<name>.uiScale  null or one of "more-space", "default", "larger-text", "largest-text"
> > haus.displays.<name>.uiScale  null or one of "more-space", "default", "slightly-larger-text", "larger-text", "largest-text"
> ```
>
> One line, in twenty-two hours, and it is **the thing a desktop author may now
> write that they could not write yesterday** — haus#478, `mergedAt
> 2026-08-23T07:48:54Z`. A new legal value is the most stranger-visible growth
> an option surface can have short of a new option, and the instrument these
> headlines lead with is blind to it by construction. Widening the same command
> from `.type` to the whole leaf finds one more change and correctly ranks it
> lower: `haus.ai.enable`'s description, rewritten by haus#483 when
> `haus.ai.skill` stopped meaning haus's own skill and started meaning every
> hausfold tool's. **Row twenty-six**, and the fix is the substitution above —
> one `jq` filter, in the pass's own command, not in the repo.
>
> ⚠️ **What makes this a row rather than a correction is that the number was
> never wrong.** Four consecutive readings of "unchanged" are four true
> statements, and their truth is exactly what turned the fifth into
> confirmation instead of a measurement. The thirty-eighth pass's own closing
> line — *"fourth pass running that the day's most stranger-visible change is
> invisible to `options.json`, and the third of the last four in which it is a
> description string"* — had this finding one dimension away and reached for
> prose to explain the gap. This time it is not a description string. It is the
> type, and the instrument could have said so.
>
> ★ **Second: §5.10's box lost its blocker overnight, and names a remedy that
> cannot answer its own question.** The box reads *"Multi-display arrangement is
> still untested (only one display was attached). Test on the dock before
> designing `profiles.docked`."* haus#478's message says it was *"verified
> against both attached panels with `hausdisp list` / `resolve`"*, and at
> `56697b7` `hausdisp list` reports `active displays: 2` — a Studio Display
> (**main**, nine rungs) beside the internal panel's five. **The dock arrived
> and the box did not move.** `git grep -ni 'profiles\.docked\|arrangement' --
> modules/displays` is empty, so what is still untested is *arrangement*: the
> box keeps its subject and loses its precondition. Row six, second instance,
> caught the way it was caught the first time — by re-reading the WHY beside a
> box rather than the box.
>
> **The sharpening is the box's own ⚠️, which prices a check that does not
> exist.** It closes *"`hausdisp list` settles which Macs diverge in one
> command"* — the question being which built-in panels report a `localizedName`
> other than the literal `"Built-in Retina Display"` that seven rows in two
> rooms select on (`modules/windows/aerospace.toml:63-68`,
> `modules/windows/default.nix:346`, and
> `modules/terminal/scripts/float-term.sh:364`, which the box still cites at
> `:233`). `hausdisp list` prints a kind, a UUID and a mode ladder;
> **`localizedName` appears nowhere in `modules/displays/hausdisp.swift`.** The
> command that answers it belongs to the other room — `aerospace list-monitors
> --json`, which here returns `Studio Display` and `Built-in Retina Display`, so
> on this Mac the literal holds and the divergence stays unproven. A box that
> names its own remedy reads as cheap; this one was never runnable as written,
> and a reader would have found that out only after deciding to spend the
> session on it.
>
> ⚠️ **And the same PR falsified the section's code fence, which no checkbox
> surface covers.** §5.10 opens with `# more-space | default | larger-text |
> largest-text` under a header reading ✅ **shipped in haus#147**. All four
> values are still legal and the list is no longer complete — **row eighteen,
> second instance** — and it rotted in the one place this file has no reader
> for: a ✅ header says nothing here needs checking, and a fence is neither a §5
> checkbox nor a §6 phase line, the two surfaces §5.14 warns are one claim
> written twice. Both corrected in the commit carrying this block.
>
> ◐ **And what actually moved, since the leaf count saw none of it:** perch's
> seven-PR morning (FSEvents on watched folders, so a file rewritten in place is
> seen at all; a lazy tile strip; fifty Finder drag-out positions asked for once
> instead of fifty times; an iCloud poll that was reading a cached status and so
> could only ever time out), holt#55 shipping a `tart` runtime backend and
> haus#483 putting it on PATH with the rule it exists for — a lane takes a VM,
> not the screen — pounce#97 giving the ⌃⇥ page walk a HUD so eight pages stop
> being a corridor, and haus#484/#485 rebuilding the tiling key as a two-mode
> flip with an exact grid and per-workspace state. Fifth pass running that the
> day's most stranger-visible change is invisible to `options.json`, and the
> first in which it is not a description string.


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


> **The passes before this one are in
> [`options-roadmap-log.md`](options-roadmap-log.md)** — **thirty-eight** dated
> entries, 2026-08-23 back to 2026-08-02: the thirty-seven numbered passes plus
> a second, unnumbered 2026-08-04 block that predates the numbering (which is
> why "twenty-nine" was one short on the day of the split, and is corrected here
> rather than incremented — and it is COUNTED at every move, with `grep -c '^>
> \*\*Status, ' notes/options-roadmap-log.md`, never incremented). Split out on
> 2026-08-20 when the
> preamble reached 2,393 lines and outweighed every other file in `notes/`.
> The three most recent stay above. Nothing moved but the text: no entry was
> edited, merged or dropped.

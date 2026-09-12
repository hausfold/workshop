# Drift — the shapes a write-up goes wrong in, and what catches each one

**The standing catalogue**: every way a claim in this family's documents stopped
being true, and the one thing that catches that shape. It binds every repo.

**Row numbering is frozen.** Rows are cited by number, from here and from
`haus`'s commit messages. A new shape is **appended**; no row is ever reordered
or removed. Count the rows, never increment a number written in prose.

## The catalogue

| # | Shape | Caught by |
|---|---|---|
| 1 | open box, work shipped | auditing the repos |
| 2 | closed claim, later falsified | reading the commit messages |
| 3 | marker and body disagree — `- [ ] ✅` | reading the two as separate claims |
| 4 | description replaced by a *different* truth — not stale, not falsified: the failure mode it describes has been swapped for another | building the thing and looking |
| 5 | claim true, but about the wrong **layer** | trying to write the check it implies |
| 6 | open box, blocker already removed — reads as *ready to build* when the dependency it names is gone. The one shape that makes an entry read **better** than it is | re-reading the WHY beside a box, not just the box |
| 7 | audit invents a regression | a clean-context reader who re-derives the evidence |
| 8 | claim about a generated artifact, derived from its generator | reading the artifact the check actually samples |
| 9 | claim about a repo, read from the LOCAL CHECKOUT | fetching first (`bench status` does), or reading GitHub |
| 10 | a NEGATIVE claim ("X never happens") proved by a grep | reading the file around the pattern, not the pattern's output |
| 11 | a CORRECTION that goes backwards — a true clause replaced by a false one, wearing a ⚠️ and the word "measured" | dating the measurement at a **rev**, not a calendar day; nothing else distinguishes the newest sentence from a checked one |
| 12 | a "don't touch this, it's coupled" warning that names the **wrong line** | opening the file it names and finding the thing it says is there |
| 13 | a sketch borrows a plain English word, and the CODEBASE later adopts that word for something it already had | reading a sketch against today's option tree rather than against its own vocabulary — it never goes stale and never disagrees with its marker; it quietly starts proposing something else |
| 14 | a box ticked for work that is BUILT but not MERGED — row 1 with its clock reversed, and worse: it burns the check that was supposed to catch it | reading the PR's **state**, not its diff. A PR number in a tick is a promise; only `mergedAt` keeps it |
| 15 | a claim naming a FUNCTION, check or format the repo has since retired — true about what shipped, false about what exists | grepping the repo for the **identifier**, not for the sentence. A rename that preserves the count is the dangerous one |
| 16 | an IMPOSSIBILITY claim that is really a description of how the incumbent works — one premise stays true, a second is falsified by the same change, and the conclusion they carried is gone | asking what it would cost to do the thing ourselves, instead of why the existing route can't be reached. Wrong on the day it is written, and reads as a scoping decision |
| 17 | a CORRECTION that reports itself as APPLIED — the paragraph says what the line "now reads" and the line was never touched | grepping the file for the string the correction quotes as its **result**, before your own prose adds a copy of it. A reader who notices the two disagree believes the newer sentence |
| 18 | an ENUMERATION written when a fix NARROWED an open limit — every member still true, the list no longer complete | asking what the seam actually BOUNDS, not spot-checking the members. It survives every check aimed at its members, because the error is the boundary they were drawn inside |
| 19 | a rev that is true when MEASURED and false when PUBLISHED, spent on a NEGATIVE claim | writing the claim so a rev can bound it. *"haus was at `<rev>`"* stays true forever; *"no box could have closed"* is a statement about the future whose one job is to license not looking. The honest form: *no box had closed as of `<rev>`* |
| 20 | a drift check REFRESHED where it fires — the snapshot tracks the data, the PROSE it protects does not, and green comes back with the lie intact | asking which COPIES the check compares, not whether it is green — a check whose remedy is *re-bless the snapshot* reports "the docs are current". The tell: a drift check that never fails twice for the same reason is not comparing the thing that drifts |
| 21 | a POLICY stated over DECLARATIONS and read as a promise about VALUES — every leaf still defaults `null`, the reference still prints `null`, and the machine writes the key anyway, from a module the policy was never addressed to | evaluating the option on the shipping desktops and comparing that against its published default. The tell is topological: a policy whose every citation sits inside its own implementation is a habit with a footnote |
| 22 | a CORRECTION applied to the INSTANCE and not to the CLAIM — the diff fixes the sentence it has open and states a reason WIDER than the fact that justified it, so the copy twelve lines down survives and the wide clause is what later authors quote | grepping the file for the phrase you are about to correct **before** writing the correction — the twin is usually in the same comment. Then writing the reason at the width of the evidence. A correction whose reason would survive deleting the case that prompted it is a rule someone invented at the keyboard |
| 23 | a claim rev-bounded in the BODY and unbounded in the HEADLINE — the evidence paragraph is exemplary, the bolded first sentence is present-tense, and the headline is what gets quoted | writing the finding so the rev is inside the sentence a reader can lift out. Unfixable by ordering: fix and report merge independently. *At `<rev>`, X* survives either order; *X is still standing* survives neither |
| 24 | an IMPOSSIBILITY claim whose remedy is ALREADY IN THE REPO — row 16 with the search moved inward: not "could we build this" but "did we already, and forget" | grepping the repo for the FIX before writing down that there isn't one. Survives row 16: a wrong reason gets re-examined, a right reason carrying the wrong conclusion gets quoted |
| 25 | a DECISION that is right, propped up with support nobody checked | asking, of each clause supporting a decision you have already made, whether deleting it would change the decision. If not it is decoration, and decoration is the part that gets checked — a reader who catches one false support clause re-opens the whole decision, the sound half included |
| 26 | a STABILITY claim measured by an instrument NARROWER than the claim — the metric is honest, its dimension is not the one that moved, and "unchanged" comes back true reading after reading | diffing the instrument's output at a SECOND dimension before writing "unchanged". The tell is a claim whose subject ("the option surface") is wider than the measurement's ("the option NAMES"). What lets it survive is that it keeps being RIGHT |
| 27 | a REMEDY named in shipped instructions and MEASURED to be a no-op by the same repo — the advice still parses, still exits 0, and produces nothing; the falsification is not later than the claim but beside it, in the same rev | grepping for the MECHANISM a commit falsifies — the identifier, not the sentence — **inside the PR that falsifies it**. Row 24's search pointed the other way: not *did we build the fix*, but *who else is quoting what I just disproved*. No check sees it: a fixture pins the SHAPE it was written for |
| 28 | a PRECONDITION that is a PERIPHERAL, so the box has no stable state to record — every other blocker is monotonic, and a pass that writes "no longer blocked" is believed by the next one | re-deriving a peripheral precondition at the START of the session that depends on it, by running the command the box names. The tell is a blocker phrased as a state of the world — "attached", "signed in", "granted", "on this network". Mitigation is structural: build the half that doesn't need it, design the half that does |
| 29 | a DERIVED value that falsifies a neighbouring assertion's MESSAGE without touching its condition — the guard fires on the right cases and the sentence it prints has quietly become untrue | grepping the assertions and warnings that MENTION a value you just made derived, and reading each message at the new value, not just re-running the condition. A message is not a comment, it is UI, read at the moment someone is confused. Second half: when the old reason dies, don't replace it with a stronger one you haven't tested |
| 30 | a CHECK whose pattern the SUBJECT ITSELF satisfies — the grep is aimed at the right file and matches something in it that never changes, so the rename it exists to catch passes green | grepping for the token that CHANGES when the thing changes — for an assembled path, never the bare name. The tell: the pattern would still match a file deleted down to its header. Mutation-test by making the change the check exists to REFUSE, in the place a person would actually make it |
| 31 | a reader that addresses an entry in a GENERATED index by NAME, where the generator only hands that name to whoever asked first — right for as long as one holder wants the entry, then silently answering about somebody else's | resolving through the index's own mapping rather than its keys, and mutation-testing by adding a SECOND holder. The tell: the thing being read is regenerated by a tool whose naming rule nobody wrote down, and the change that breaks the reader is in a file the reader never mentions — nothing in the subject's own repo moved |
| 32 | a CHECK declared on the wrong side of a PLATFORM guard — the code is right, the census names it, and no runner ever selects it, so the suite goes green having never evaluated the thing | enumerating what the runner actually EVALUATES and diffing that against the source, never reading the declaration. The tell is a check whose own comment names the platform it wants while its declaration sits inside an attrset keyed for another. It survives every review aimed at the check's LOGIC, because the logic is sound; and it survives the census, because a list of names is written from the same declarations |
| 33 | a CHECK whose CENSUS is a HAND-MAINTAINED list — every subject it names is evaluated, so the logic is sound and the coverage is whatever somebody last typed. A subject added at the source does not skip and does not redden; it is outside the suite, and green comes back at full strength over a smaller population. Row 32 inverted: there a name no runner selected, here a runner that takes every name and names that are short | a SECOND check walking the other way — enumerate the population where it LIVES, never the list against itself. The tell is coverage that cannot move: adding the subject a person would really add leaves the run byte-identical. Two walk-backs that only look like the fix — one deriving its population FROM the list cannot see a missing WHOLE holder, one needing checkouts CI lacks is a standing skip. Twice in `PRODUCT_MARKS` (perch's iOS icon, then the three light tiles) a hand closed the gap inside the hour; that nothing else would have is the argument |

## Why this family drifts more than a normal TODO list

1. **The work happens in four repos and the write-up lives in a fifth.** No CI in
   `haus`, `nebelung` or `pounce` can see a workshop document, so a PR that
   closes an item has no mechanical way to say so.
2. **Items ship out of phase, from the app side.** A downstream repo builds a
   data structure for its own reasons; the upstream note goes stale without
   anyone upstream touching it.

## The pass that finds them

Not a diff of the checkbox list — **read every commit landed since the last
sweep**, bodies included. The commit bodies in these repos are long on purpose.
Ordered, and each step catches what the one before it can't:

1. **Fetch first** (row 9).
2. **Re-audit open boxes against the repos**, not against memory (rows 1, 6).
3. **Read the commit messages** for closed claims a later change falsified (row 2).
4. **Read every marker and its body as two separate claims** (row 3).
5. **Grep for identifiers, not sentences** (row 15).
6. **Date every measurement at a rev**, inside the sentence a reader can lift
   out (rows 19, 23).

`/docs-sync` is this pass, scheduled.

## Seen once, not yet a row

For a finding certainly true about its instance, whose finder could not yet say
its general form or tell it from a row already here. The numbering is frozen, so
"not yet" is cheaper than a row that turns out to be a special case of row 9.
**A second sighting is the promotion: append the row, delete the entry here.**
Nothing here is less *true* than a row; it is less *settled*. A pass about to
append a row reads this section first.

**A guard correct about the hazard it was written for, and silently wrong in the
direction that fails a build nobody broke.** Three sites asserting a path spelled
into a store output all tested it DOUBLE-QUOTED — `[ -e "…" ]`, `[ -f "…" ]` —
which stops a SPACE, the hazard all three comments name, and nothing about a `$`
or a backtick, which none names; a real `theme $HOME.json` read as MISSING to all
three. A check that misses costs nothing extra; one that fails a build on a file
that is *there* sends someone hunting an upstream that is fine. **Caught by**
asking of a guard which hazards its quoting answers, not which one the comment
names.

**A "must not merge without X" that lives only in a note is not a gate.** A note
warned that a PR must not merge until a second file agreed with the first,
"because half of it is worse than none of it". It merged with one half, and the
product carried two disagreeing copyright lines for hours. **Caught by** writing
the condition where the merge happens — a required check, a PR-template line, a
`bench` refusal — or by writing it as a request; a rule nothing can enforce reads
to its author as a control and to everyone else as prose.

**A test fixture that isolates every candidate but the absolute one.** A `notify`
test unset the env var overriding where `Trill.app` is looked for and pointed
`HOME` at an empty dir, hiding `~/Applications` and saying nothing about
`/Applications/Trill.app` — a real app on every machine the code ships to. The
suite delivered a genuine banner on every run, titled `t`, bodied `b`, sourced
`bench.run`, a source no call site can produce; it stayed green because the
assertion was `status -eq 0`, which the real send satisfies as well as the fake
one. **Caught by** asking what a fixture's *un*-overridden fallback resolves to
on the machine running the test, and by asserting on its log rather than the exit
status — a helper that swallows its output is observable only through the
renderer it was pointed at.

**A gate whose condition can never be true, hidden by the fact that refusing is
its normal answer.** A throttle admitted work only while the week's spend sat
below a line drawn linearly from zero across the weekly window; spend only rises
and the clock does not rewind, so the line was beatable by an idle week and
nothing else. Nineteen consecutive passes read `OVER`, none read `under`, and the
path behind it — spawning a lane on a red main — had never executed. Its log line
for *stuck shut* is the word it logs for *working*, the arithmetic and the
comparison lived in different files so no test could reach the verdict, and the
gate's other input never fired either, so even the skip was never written.
**Caught by** asking of every gate what its **yes** looks like and when it last
happened — `grep`ing the log for the affirmative, not the refusal — and by making
the verdict the artifact, in the file that holds the numbers. The tell: two sides
that are a monotonic quantity and a monotonic clock cross once, then never again.

**A standard that specifies the happy path and leaves the refusal unstated, so
every implementation invents one and its own suite pins the invention.** A3 of
`docs/agent-surface.md` fixed what `skill install` writes and that it refuses
rather than clobbers, and said nothing about the exit code of a run that left a
file alone, `--dir` and `--client` together, or a flag handed no value. Six tools
diverged three ways on each: `haus` exited 0 after refusing, `scruff` 2, `trill`
and `factory` 3; `haus` and `pounce` ranked `--dir` over `--client` silently;
`pounce` and `perch` took `--dir ""` as a path. Every one green, because a repo's
suite pins the answer that repo chose and the caller the contract exists for —
an agent branching on the code — is in neither repo. **Caught by** asking of a
cross-repo standard what it says about the case where the tool *declines*, and
writing one conformance fixture per implementation from the standard's own
words rather than from the implementation in front of you. The tell is a rule
whose verbs are all about the success path, in a document every repo cites and
none tests against.

**A per-item `skip` in `setup()` blanks every test in the file, and reads green.**
`test/design-palette.bats` copies each mark named in `PRODUCT_MARKS` out of its
repo, falling back to GitHub raw, and skipped when one could not be found — so a
mark not yet on its upstream's `main` printed `ok … # skip` for every test whose
setup fetches, the six that never open a mark included, and `bats` exited 0 with
the hexes, the latte citations and the page register unchecked. A missing input
should narrow a suite, never silence it, and the silence arrives exactly when
someone is *adding* coverage. Ordering the merge upstream-first is the answer
only as a gate: **a "must not merge without X" that lives only in a note is not a
gate** is already on this shelf, and a comment beside `PRODUCT_MARKS` would have
been that note. The five mark tests now fail by name on a partial set. **Caught
by** reading the skip *reasons* on a green run instead of the exit code.

**A property nobody chose, promised by six write-ups that describe the build
settings instead of the artifact.** Every `Perch.app` ever published carries an
arm64 slice and no other, and six claims said any Mac: the flake's `systems`
list, `meta.platforms`, the README, hausfold.co's perch index and install pages,
and a cask whose silence about arch is itself a claim, where pounce's formula
spells out `depends_on arch: :arm64`. On an Apple Silicon Mac `-destination
'platform=macOS'` matches `arch:arm64` and `arch:x86_64` for one "My Mac";
xcodebuild takes the first, announcing it in every release run under "Using the
first of multiple matching destinations", and signing, notarization, stapling,
`spctl --assess` and `codesign -R` all pass afterwards, none being about arch.
Row 8 with the generator one level further out, row 5 with its two layers a build
apart. It survives a careful check because the project declares no `ARCHS`, so
`xcodebuild -showBuildSettings` resolves the universal `ARCHS_STANDARD` and
*confirms* the claim; only the command line that overrides it disagrees. **Caught
by** `lipo -archs` on the published artifact rather than on the settings meant to
produce it, and by treating an ambient default as undeclared until something
asserts it — a warning printed in every green run is not evidence anybody read it.

**A fixture that carries a field on rows the real data never puts it on.** The
family's docs-search tool promises breadcrumbs in its description and requires
them in its `outputSchema`, and every surface reading that index — the MCP
tool, the REST search, the A2A binding, the natural-language endpoint —
answered `breadcrumbs: []` for every hit that was not one of 59 rows, from the
day it shipped until the join landed. In the built index only a `type: 'page'`
row carries the trail; the heading and text rows beneath it, all but 59 of the
~4,970, carry a `page_id` and nothing else. All three of the suite's fixtures
wrote `breadcrumbs` onto rows with neither field, a shape the index cannot
produce, so the one assertion about it passed against data that could not
occur, and two more results ranked as the tests said they would only because of
a breadcrumb boost that was dead outside those same 59 rows. What makes it
survive a careful check: the field is in the schema's `required` list and `[]`
satisfies a required array, so a client validating every response it is handed
passes this one every time; and the structured payload and the text block are
the same object, so the two agreed with each other while both were empty. Row 8
with the evidence invented rather than derived from the generator, and row 27's
tail ("a fixture pins the SHAPE it was written for") without the falsification
— nothing here was disproved later, the fixture was never the shape it stood in
for. **Caught by** reading one real record out of the artifact a stub imitates,
field by field, before trusting an assertion about any field the stub invents,
and by treating a field that is empty in every production answer as a failing
test rather than as the data being sparse.

**An instrument added to make a cost readable, reading a unit the budget it
guards does not count.** A CI job printed `du -sh /nix/store` so the store's
growth toward GitHub's 10 GB cache ceiling would show up as a number rather
than as an eviction. That ceiling counts the compressed cache entry: 472 MiB
where `du` read 2.8 G. Nothing the line printed was false and nothing about the
store was misreported — it simply could not be compared with the figure it
existed to warn about, and it showed six times the pressure the repo was under,
in the direction that provokes a fix nobody needs. **Caught by** measuring the
same quantity through both instruments once, on real data, and reading the
ratio: a stable factor between a gauge and the budget it is checked against is
a unit error, not headroom.

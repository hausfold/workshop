# Drift — the shapes a write-up goes wrong in, and what catches each one

**The standing catalogue.** Every row is a way a claim in this family's
documents stopped being true, and beside it the only thing that actually catches
that shape. It binds every repo.

**Row numbering is frozen.** Rows are cited by number from this repo and from
`haus`'s commit messages. A new shape is **appended**; no row is ever reordered
or removed. Count the rows, never increment a number written in prose.

## The catalogue

| # | Shape | Caught by |
|---|---|---|
| 1 | open box, work shipped | auditing the repos |
| 2 | closed claim, later falsified | reading the commit messages |
| 3 | marker and body disagree — `- [ ] ✅` | reading the two as separate claims |
| 4 | description replaced by a *different* truth — not stale, not falsified, describing a failure mode that has been swapped for another | building the thing and looking |
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
| 16 | an IMPOSSIBILITY claim that is really a description of how the incumbent works — one premise stays true, a second is falsified by the same change, and the conclusion they carried is gone | asking what it would cost to do the thing ourselves, instead of why the existing route can't be reached. Wrong on the day it is written, and reads as a scoping decision rather than a mistake |
| 17 | a CORRECTION that reports itself as APPLIED — the paragraph says what the line "now reads" and the line was never touched | grepping the file for the string the correction quotes as its **result**, before your own prose adds a copy of it. A reader who notices the two disagree believes the newer sentence |
| 18 | an ENUMERATION written when a fix NARROWED an open limit — every member still true, the list no longer complete | asking what the seam actually BOUNDS, not spot-checking the members. It survives every check aimed at its members, because the error is the boundary they were drawn inside |
| 19 | a rev that is true when MEASURED and false when PUBLISHED, spent on a NEGATIVE claim | writing the claim so a rev can bound it. *"haus was at `<rev>`"* stays true forever; *"no box could have closed"* is a statement about the future whose one job is to license not looking. The honest form: *no box had closed as of `<rev>`* |
| 20 | a drift check REFRESHED where it fires — the snapshot tracks the data, the PROSE it protects does not, and green comes back with the lie intact | asking which COPIES the check compares, not whether it is green. A check whose remedy is *re-bless the snapshot* turns "the docs are wrong" into "the docs are current". The tell: a drift check that never fails twice for the same reason is not comparing the thing that drifts |
| 21 | a POLICY stated over DECLARATIONS and read as a promise about VALUES — every leaf still defaults `null`, the reference still prints `null`, and the machine writes the key anyway, from a module the policy was never addressed to | evaluating the option on the shipping desktops and comparing that against its published default. The tell is topological: a policy whose every citation sits inside its own implementation is a habit with a footnote |
| 22 | a CORRECTION applied to the INSTANCE and not to the CLAIM — the diff fixes the sentence it has open and states a reason WIDER than the fact that justified it, so the copy twelve lines down survives and the wide clause is what later authors quote | grepping the file for the phrase you are about to correct **before** writing the correction — the twin is usually in the same comment. Then writing the reason at the width of the evidence. A correction whose reason would survive deleting the case that prompted it is a rule someone invented at the keyboard |
| 23 | a claim rev-bounded in the BODY and unbounded in the HEADLINE — the evidence paragraph is exemplary, the bolded first sentence is present-tense, and the headline is what gets quoted | writing the finding so the rev is inside the sentence a reader can lift out. Unfixable by ordering: fix and report merge independently. *At `<rev>`, X* survives either order; *X is still standing* survives neither |
| 24 | an IMPOSSIBILITY claim whose remedy is ALREADY IN THE REPO — row 16 with the search moved inward: not "could we build this" but "did we already, and forget" | grepping the repo for the FIX before writing down that there isn't one. Survives row 16 because the argument is half true and precisely stated; a wrong reason gets re-examined, a right reason carrying the wrong conclusion gets quoted |
| 25 | a DECISION that is right, propped up with support nobody checked | asking, of each clause supporting a decision you have already made, whether deleting it would change the decision. If not it is decoration, and decoration is the part that gets checked — a reader who catches one false support clause re-opens the whole decision, including the half that was sound |
| 26 | a STABILITY claim measured by an instrument NARROWER than the claim — the metric is honest, its dimension is not the one that moved, and "unchanged" comes back true reading after reading | diffing the instrument's output at a SECOND dimension before writing "unchanged". The tell is a claim whose subject ("the option surface") is wider than the measurement's ("the option NAMES"). What lets it survive is that it keeps being RIGHT |
| 27 | a REMEDY named in shipped instructions and MEASURED to be a no-op by the same repo — the advice still parses, still exits 0, and produces nothing; the falsification is not later than the claim but beside it, in the same rev | grepping for the MECHANISM a commit falsifies — the identifier, not the sentence — **inside the PR that falsifies it**. Row 24's search pointed the other way: not *did we build the fix*, but *who else is quoting what I just disproved*. No check sees it: a fixture pins the SHAPE it was written for |
| 28 | a PRECONDITION that is a PERIPHERAL, so the box has no stable state to record — every other blocker is monotonic, and a pass that writes "no longer blocked" is believed by the next one | re-deriving a peripheral precondition at the START of the session that depends on it, by running the command the box names. The tell is a blocker phrased as a state of the world — "attached", "signed in", "granted", "on this network". Mitigation is structural: build the half that doesn't need it, design the half that does |
| 29 | a DERIVED value that falsifies a neighbouring assertion's MESSAGE without touching its condition — the guard fires on the right cases and the sentence it prints has quietly become untrue | grepping the assertions and warnings that MENTION a value you just made derived, and reading each message at the new value, not just re-running the condition. A message is not a comment, it is UI, read at the moment someone is confused. Second half: when the old reason dies, don't replace it with a stronger one you haven't tested |
| 30 | a CHECK whose pattern the SUBJECT ITSELF satisfies — the grep is aimed at the right file and matches something in it that never changes, so the rename it exists to catch passes green | grepping for the token that CHANGES when the thing changes — for an assembled path, never the bare name. The tell: the pattern would still match a file deleted down to its header. Mutation-test by making the change the check exists to REFUSE, in the place a person would actually make it |

## Two structural reasons this family drifts more than a normal TODO list

1. **The work happens in four repos and the write-up lives in a fifth.** Nothing
   in `haus`, `nebelung` or `pounce` CI can see a workshop document, so a PR
   that closes an item has no mechanical way to say so.
2. **Items ship out of phase, from the app side.** A downstream repo wants a
   data structure for its own reasons and builds it; the upstream note goes
   stale without anyone upstream touching it.

## The pass that finds them

Not a diff of the checkbox list — **read every commit landed since the last
sweep**, bodies included. The commit bodies in these repos are long on purpose.

Ordered, and each catches something the one before it can't:

1. **Fetch first.** A local checkout one merge behind produces row 9.
2. **Re-audit open boxes against the repos**, not against memory.
3. **Read the commit messages** for closed claims a later change falsified.
4. **Read every marker and its body as two separate claims.**
5. **Grep for identifiers, not sentences** — a rename that preserves the count
   is invisible to a sentence-level read.
6. **Date every measurement at a rev**, in the sentence a reader can lift out.

`/docs-sync` is this pass, scheduled.

## Seen once, not yet a row

For a finding that is certainly true about its instance and whose finder could
not yet say its general form, or could not distinguish it from a row already
here. The numbering is frozen, so a row can never be taken back out — which
makes "not yet" a cheaper answer than a row that later turns out to be a special
case of row 9.

**A second sighting is the promotion: append the row, and delete the entry
here.** Nothing on this shelf is less *true* than a row; it is less *settled*. A
pass about to append a row should read this section first — the shape may
already be waiting on it.

**A guard correct about the hazard it was written for, and silently wrong in
the direction that fails a build nobody broke.** Three sites asserting a path
spelled into a store output all tested it DOUBLE-QUOTED — `[ -e "…" ]`, `[ -f
"…" ]` — which stops a SPACE, the hazard all three comments name and the one
that had actually bitten, and does nothing about a `$` or a backtick, which none
of them names. A real rendered file called `theme $HOME.json` was reported
MISSING by all three. The direction is what makes it worth a line: a check that
misses costs nothing extra, but a check that fails a build on a file that is
*there* sends someone hunting an upstream that is fine. **Caught by** asking, of
a guard, which hazards its quoting actually answers rather than which one the
comment beside it names.

**A "must not merge without X" that lives only in a note is not a gate.** A note
carried a warning that a PR must not merge until a second file agreed with the
first, "because half of it is worse than none of it". It merged with one half,
and for a few hours the product had two disagreeing copyright lines. Nothing
enforced the note, and nothing would have enforced the next one. **Caught by**
writing the condition where the merge happens — a required check, a PR-template
line, a `bench` refusal — or by writing it as a request rather than as a rule; a
rule nothing can enforce reads to its author as a control and to everyone else
as prose.

**A test fixture that isolates every candidate but the absolute one.** A
`notify` test unset the env var that overrides where `Trill.app` is looked for
and pointed `HOME` at an empty dir — hiding the `~/Applications` candidate and
saying nothing about `/Applications/Trill.app`, which is a real, executable app
on every machine the code ships to. So the suite delivered a genuine banner to
the developer's own notification compositor on every run, titled `t`, bodied
`b`, sourced `bench.run` — a source no call site can produce, since each sets
its own. It stayed green because the assertion was `status -eq 0`, which the
real send satisfies exactly as well as the fake one. **Caught by** asking what a
fixture's *un*-overridden fallback resolves to on the machine running the test,
and by asserting on the fixture's log rather than on the exit status — a helper
whose every path swallows its output can only be observed through the renderer
it was pointed at, so a test that never reads that log cannot tell which
renderer answered.

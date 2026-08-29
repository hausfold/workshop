---
name: docs-sync
description: >-
  The daily docs sweep for the hausfold family: read every commit landed since the last
  sweep, then cut, correct, or as a last resort add, across the web docs (the SOT),
  READMEs, in-repo docs and code comments. One PR per affected repo, never a direct
  landing on main. Use when I say /docs-sync, "sync the docs", "docs audit", "are the
  docs stale", or when the scheduled routine fires.
---

# Docs sync — reconcile the docs with what actually shipped

Code moves across eleven repos all day; the docs don't follow on their own. Once a day
this sweep reads what landed, decides what it broke or bloated, fixes it in the right
place, and opens a PR.

**An empty run is a success.** The watermark (Step 1) means you only ever read commits no
run has read before. If nothing is new, don't re-audit pages no commit touched — take the
run's one comment file (Step 5) and stop. An invented finding costs a reviewer's afternoon;
a skipped no-op costs nothing.

**The site is the source of truth.** `hausfold.co/content/docs/` (Fumadocs) documents
everything a *user* experiences. READMEs, `AGENTS.md` and in-repo docs serve contributors
and agents. When the two disagree, the site wins and the repo doc gets corrected.

## Step 0 — in a cloud container, plant the other eleven repos

Skip this on Julien's Mac; the checkouts are already there.

```bash
./.agents/setup.sh              # Determinate Nix + the proxy CA; no-ops if Nix exists
command -v python3 gh || echo "MISSING — the watermark needs python3, Step 6 needs gh"
./bench clone                   # the eleven others, at the dir names bench expects
git config --global user.name  "docs-sync"
git config --global user.email "docs-sync@hausfold.co"
```

Three layout facts are load-bearing and none is guessable: the eleven live **inside** the
workshop checkout as gitignored subdirectories (`<workshop>/haus`, …), `org-profile`'s
directory is `org-profile` while its remote is `hausfold/.github`, and **`ops` is
private**, so its clone needs credentials and warns rather than dying without them.
`bench clone` gets all three right. Call it `./bench` — nothing puts it on PATH in a
container.

> 🔒 **`hausfold/ops` is swept, and the wall around it is one-way.** It holds the name
> register, the gap list — what nobody has claimed, which of our surfaces has no answer to
> a fair objection — and real testers' names. Facts flow **in**: a repo rename, a published
> package, a shipped page all make a claim in there wrong, and fixing that is this sweep's
> job. Nothing flows **out**. Never quote, summarise or paraphrase a line from `ops` into a
> public repo's PR, doc or issue, and never let a finding about `ops` appear in another
> repo's PR body. If `ops` can't be cloned, say so in Step 8 and sweep the other eleven.

> 🚨 **Repos pre-cloned elsewhere get `mv`d into place, never symlinked.** `.gitignore`
> spells the ten with trailing slashes (`/haus/`), which match a directory and not a
> symlink to one — so a symlinked checkout stops being ignored and `git add -A` stages it.

> 🚨 **A pre-cloned container also lies about `main`, and Step 7 believes it.** Those
> checkouts arrive shallow, parked on a scratch branch, with `main` and `origin/main` left
> at whatever graft the clone made. Nothing complains — `docs-since` reads `HEAD`, so the
> *range* is right and the run looks normal — but `--mark` records `git rev-parse main`,
> writing stale revs into `.docs-sync.json` so the next sweep re-reads the whole backlog.
> The tell is `git diff main...HEAD` answering **`fatal: no merge base`**. Fix it in every
> repo, the workshop included, **after** your PRs are pushed so a reset can't strand a
> branch:
>
> ```bash
> git -C <repo> fetch origin main
> git -C <repo> checkout -B main origin/main
> ```

**Push access is per-repo.** `git -C <repo> push --dry-run origin HEAD` before you spend a
run's budget on docs you can't land. A repo you can read but not push to still gets
reconciled: carry its findings and intended diff into the **workshop** PR under
`## Couldn't land`. A silently skipped repo looks exactly like a clean one, which is the
failure this sweep exists to prevent.

## Step 1 — what landed?

```bash
./bench docs-since
```

Per repo, every commit past the last reconciled watermark plus the files it touched. It is
watermark-based, not "since yesterday": a sweep that slept four days still picks up all
four. **Don't `--mark` yet** — that's Step 7.

> ⚠️ **Every `⚠` line is a hole, not a clean repo.** `no checkout at …` means the repo
> wasn't swept at all (`bench clone`). `first sweep — reading its FULL history` means the
> whole backlog is unreconciled, so that run is a big one and its PR should say so.
> `watermark … is gone` means the range is a one-day guess and older commits were read by
> nobody. `N commits READ but not landed` means an earlier run's corrections are still
> sitting in an open PR (or one that got closed) — those commits are outside your range,
> so **that repo's open PR is the only thing that will ever fix them**: extend it in
> Step 6, don't re-read them. None of these aborts the sweep. Carry them into the report.

Read the diff of anything whose subject is thin (`git -C <repo> show <sha> --stat`).
Version stamps, lock bumps and merge commits carry no doc consequence; skip them fast and
spend the budget on behavior. Read the range as a **sequence**: a later commit routinely
undoes an earlier one, and two commits that each look like housekeeping can leave a doc
wrong between them.

## Step 2 — route each change to its doc

Site paths below are under `hausfold.co/content/docs/`. **Read the tree's `meta.json`
before assuming a page exists** — the trees move, and a page invented from memory is a
broken link. Grep before concluding something is undocumented; it may live under a name
you didn't search for:

```bash
grep -ril "<feature>\|<flag>\|<option>" hausfold.co/content/docs/ <repo>/README.md
```

| Changed… | Reconcile against |
|---|---|
| `pounce/` — the launcher | the **`pounce/` tree** (`config.mdx` carries every `config.json` key), plus `haus/rooms/launcher.mdx` for the *haus wiring only*. A room page documents the room; the app is documented in the app's tree. ⚠️ **pounce has no `docs/`**: the tree is the whole manual, and the repo's `README.md` is a door — what it is, one install line, links |
| `perch/` — the notch file shelf | the **`perch/` tree**, which is the manual; `docs/` (`cli.md`, `feel-testing.md`, `app-store.md`) is for someone working on perch. Plus `haus/rooms/shelf.mdx` for the wiring, and `haus/keeping-it-current.mdx` for anything install-shaped (perch ships as a cask). ⚠️ **The tree is the only page about perch**: `/perch` 301s to `/docs/perch/`, so there is no second surface to keep in step. `/perch/privacy` is a live route the App Store listing points at, so a behavior claim in that policy is a two-file change |
| `trill/` — the notification compositor | `trill/docs/*` — the one app of the four whose **manual is in-repo**, because the site's `trill/index.mdx` is a single incubator page hausfold.co's `AGENTS.md` forbids growing while the tab's positioning is undecided. Plus `trill/ARCHITECTURE.md`, and `trill/README.md`, a door onto `docs/` |
| `snug/` — the terminal-presentation runtime | `snug/README.md` and `snug/AGENTS.md`. No site page yet: it is a library and a binary the family drives, not something a user installs. ⚠️ The standard it implements is the **workshop's** `docs/cli-presentation.md` — reconcile the two against each other, and keep *how a line is drawn* in snug while the design stays there |
| `nebelung/` — palette, ports | `haus/rooms/appearance.mdx` (theming and the palette are one page), `nebelung/README.md` |
| `scruff/` — the worktree substrate + its five SDKs | its own `README.md`, `SPEC.md`, `docs/*`, `sdk/*/README`, plus `haus/rooms/ai.mdx` for the user-facing worktree story. scruff has **no site tree**, so "the docs" for it are the repo's. An SDK surface change is also a release question — see `/release` |
| `haus/modules/*` | the matching **room** under `haus/rooms/`, and `haus/desktops/*` when a desktop's values move. haus's own `docs/` is contributor material and generated data, never a manual: `model.md` and `macos-settings.md` are pinned by name from a dozen source files each, `focus.md` is the design record for a room built with no public API, and 🚨 `docs/site-data/` is what the row below regenerates the options reference *from* — never prune it. `README.md` is a door |
| a new or renamed nix option | `haus/reference/options.mdx` — **always**, and it is **generated**: `cd hausfold.co && npm run options -- --haus ../haus`. Never hand-edit it. An option a user can set and can't discover is a bug |
| a new or changed keybind | the **room that owns the key** (`windows` for the tiling binds, `launcher` for ⌘Space, `ai` for the ⌘↵ lane chord). There is no standalone keybindings page. `npm run bindings:check -- --haus ../haus` snapshots the window-manager binds only, not the other two — and those print on `desktops/hacker.mdx` (`#first-moves`) and `rooms/development.mdx` as well as `rooms/windows.mdx` |
| `bench`, workshop `README.md` | `haus/internals/*`, workshop `README.md` / `AGENTS.md` |
| `homebrew-tap`, release CI | `haus/install.mdx`, `haus/keeping-it-current.mdx` |
| `org-profile` (the `hausfold/.github` repo) | `profile/README.md`, the org front page and the first thing anyone sees, plus `profile/assets/README.md`. Reconcile its repo list against `content/docs/meta.json` and the `#made` list in hausfold.co's `src/app/page.tsx`; there is no `/docs` index page, only the four trees |
| `hausfold.co/` itself — shell, routes, landing pages | that repo's own `README.md` / `AGENTS.md`. The *docs* it serves are the rows above, not this one. 🚨 Never move anything out of `hausfold/ops`' name register and into it — that repo is private for a reason, and this one is the world |
| a shot or asset placement anywhere | `assets/SHOTLIST.md` in the workshop |
| 🔒 anything that dates a claim in the **private** `ops` repo | `ops/PRESENCE.md` (the register: a repo renamed or created, a package published to npm/PyPI/crates, a namespace won or lost, a domain or handle moved), `ops/MARKETING.md` (a pipeline that got built, a tool that got installed, a blocker that cleared), `ops/scoreboard/` (a **new public repo** has to be added to `collect.sh`'s `REPOS` by hand — one that isn't listed reports as nothing, which looks exactly like a repo nobody visits), `ops/LANDSCAPE.md` and `ops/TESTERS.md` (hand-maintained; correct them only against something that landed). **One-way: nothing from `ops` goes into any other repo's PR** |

**Every repo is both an input and a target.** The question is never only "does this commit
change the site?" but "did it make a doc *in that repo* wrong?" The front-of-house repos
(`org-profile`, `homebrew-tap`) are the easiest to miss precisely because they don't feed
the site.

Two spellings to correct on sight:

- **Old room code names** (`haus.{sill,prowl,hearth,pounce,perch,hush,collar}.*`) are an
  eval error, not a style nit → `haus.{bar,windows,terminal,launcher,shelf,focus,security.touchId}.*`.
  The table is in haus's `docs/model.md`.
- **A desktop is `hacker`, `everyday`, `minimal` or `blank`.** Anything else is a stale name.

`inputs.<anything>.url` in a *consumer's* flake is that machine's own choice — leave it.

## Step 3 — the bar: cut, correct, fold, add (in that order)

Most commits need no doc change. Be a strict editor, not an eager one — and reach for the
knife before the pen.

**1. Cut**, from the reader-facing surfaces: the site trees, product READMEs, the org
front page. The docs are too long before they are too short. Delete on sight:
- Anything **repeated** elsewhere. One fact, one home; everywhere else links to it.
- Anything **history**: how a thing used to work, what it was called, when it moved, why
  it changed. Users don't care and it dates the page. Document the current version,
  cleanly and professionally, as if it had always been this way.
- Anything **no longer true or no longer interesting** — a caveat about a bug that's
  fixed, a workaround for a version nobody runs, a feature that got absorbed.
- Anything a **haus user** would never act on: internal refactors, module plumbing,
  implementation trivia.

  🔒 **`haus/internals/` is the exception on the site, and the only one.** Contributing
  and flakes are written for someone working *on* the family, so mechanism, rationale and
  detail belong there. History still doesn't.

  🔒 **Off the site, this whole list stops applying.** `AGENTS.md`/`CLAUDE.md`,
  `SPEC.md`, `ARCHITECTURE.md` and `bench`'s own comments are *written* in why-it-bit-us:
  the trap, the date it bit, the fix. That narrative is the payload, not bloat. Correct
  them when they're wrong; never cut them for length.

  🔒 **`ops` is the third case, and it cuts like the site.** It is a register, not a
  narrative: it says what is claimed and what is missing *today*. Which decision reversed
  which, what a page was called for an afternoon, when a thing went live — all of it is in
  git, so cut it on sight. **A date survives only when it is provenance for a claim about
  the world outside this org** (a trademark search, a competitor's star count, a vendor's
  published price), because there the date is what makes the number checkable.

**2. Correct.** No hesitation when the docs state something now factually wrong: a flag,
path, default, keybind, option name, version or behavior that changed; a step that would
fail if a user followed it today; a dead link or renamed file; a code comment that lies
about the code beside it.

**3. Fold in.** New behavior usually belongs inside a page that already exists. Find the
paragraph that is now incomplete and grow it by a sentence.

**4. Add — last resort.** A new page is justified only when a subject has no home at all,
and only when the change clears all three: a **user** can see or act on it, it is
discoverable **nowhere** today, and not knowing it would cost someone real time. The site
grows faster than anyone reads it.

**Leave it alone:** refactors, perf work, tests, CI plumbing, version stamps, lock bumps;
anything experimental, reverted, or behind a flag that isn't on by default; your own
opinion about how something *should* work. Document what shipped.

When a change sits on the line, **note it in the report instead of writing the doc**. A
surfaced judgment call is cheap; a wrong doc is expensive.

## Step 4 — write it in the house voice

The docs read like a person who knows the system explaining it to a friend, never like
generated reference. Match the file you're editing; `haus/rooms/bar.mdx` is the reference
for tone.

- **Slim and dense.** Every sentence earns its place. Cut hedging, preamble, restatement.
  If a paragraph can be a sentence, make it a sentence.
- **Lead with the point.** What it does and why you'd want it, then the mechanics.
- **Show the command.** A fenced block someone can paste beats a description of one.
- **Fun, lightly.** Dry wit and a strong turn of phrase are house style. One good line per
  page, not one per paragraph, and never at the reader's expense mid-problem.
- **No em dashes in reader-facing copy** — prose, headings, frontmatter `description`,
  anywhere on the site. Use a period, colon, semicolon, comma or parentheses. (The
  generated `options.mdx` is exempt; its text comes from haus.)
- **Pretty.** The Fumadocs components are global, so a page imports nothing: `<Callout>`
  for the gotcha that will bite them, `<Steps>`/`<Step>` for ordered setup,
  `<Cards>`/`<Card>` for parallel choices, tables for dense reference. They are **not**
  Starlight's `<Aside>`/`<CardGrid>`, which are undefined here and fail the build. Keep the
  frontmatter `description` accurate; it's the search and social snippet.
- **Link, don't repeat.** Cross-link to `/docs/haus/reference/options/#…` rather than
  restating an option inline.
- **Keep it honest.** Say what's read-only, what needs a permission, what's a non-goal.
  Under-promising is house style.

## Step 5 — the comment pass (one file a run)

Every repo carries far more code comment than it needs. Cut what restates the line below
it, what's repeated three files over, and what's simply no longer true. **Keep** the
comment that encodes something nuanced — a reason, a trap, an ordering constraint, a "this
looks wrong and isn't" — including the ones that earn it by naming what bit us and when.
In code, that history *is* the reason. Step 3's cut-the-history rule is about reader-facing
pages, not about `bench`'s margins.

This is a rolling job, not a run's job. **One file per run, at most, and only when the doc
half of the run was light** — a no-op doc day is the best day for it, and the one PR such a
day produces. Read `comments.done` in `.docs-sync.json` first: its last entry names the repo
you skip this run. Then take the fattest un-swept file in another:

```bash
grep -rcE '^[[:space:]]*(#|//|\*|--)' <repo> --include='*.nix' --include='*.swift' \
  --include='*.go' --include='*.ts' --include='*.sh' | sort -t: -k2 -rn | head
```

Then record it, so the next run doesn't re-read it. The key survives `--mark`:

```bash
python3 - <workshop>/.docs-sync.json <path> <<'EOF'
import json, sys
p, *done = sys.argv[1:]
s = json.load(open(p)); c = s.setdefault("comments", {}).setdefault("done", [])
c += [d for d in done if d not in c]
json.dump(s, open(p, "w"), indent=2); open(p, "a").write("\n")
EOF
```

The ledger tracks what's been **proposed**, not merged. If Julien closes a comment PR
unmerged, delete its line from `comments.done`.

Two hard rules, because this is the one step that edits code files:

- **Comment lines only.** `git diff -U0 <file>` must show nothing but comment lines moving.
  If a fix needs a code change, don't make it — Step 6 says where it goes instead.
- **Some comments are code.** Shebangs, `# shellcheck`, `//go:build`, `# type:`, license
  headers, Nix doc-comments feeding `nixosOptionsDoc`, and anything a generator reads. Leave
  them.

## Step 6 — land it: one *open* PR per repo

Nothing lands on `main` unattended, and PRs open **ready for review, never as drafts**. The
first question for each repo is not what to call the branch — it's whether one is already
open:

```bash
gh pr list -R hausfold/<repo> --state open --search 'head:docs-sync-' --json number,headRefName
```

**One open PR per repo, growing until Julien merges it, is the shape.** A fresh PR per run
buries the signal and hands the reviewer conflicts for free.

**If Step 1 warned that this repo has commits read but not landed, find out which way its
last PR went** — no PR open is equally consistent with *merged* and with *closed unmerged*,
and the two want opposite answers. Ask, don't infer:

```bash
gh pr list -R hausfold/<repo> --state merged --search 'head:docs-sync-' \
  --limit 1 --json number,mergedAt
```

**Merged** → say so, and the ⚠ clears:

```bash
./bench docs-since --landed <repo>
```

Order matters: `--landed` catches `landed` up to whatever `read` holds *right now*, which
is still the value that merged PR covered. Run it here, before Step 7's `--mark` moves
`read` on. **Closed unmerged** → don't run it. The ⚠ is telling the truth, and those
corrections have to ride again in the PR you're about to open.

**None open → start one:**

```bash
git -C <repo> checkout main && git -C <repo> checkout -b docs-sync-<YYYY-MM-DD>
git -C <repo> add <the doc files>
git -C <repo> commit -m "docs: <what you reconciled>

Docs-Sync: <YYYY-MM-DD>"
git -C <repo> push -u origin docs-sync-<YYYY-MM-DD>
gh pr create -R hausfold/<repo> --head docs-sync-<YYYY-MM-DD> \
  --title "docs: sync <YYYY-MM-DD>" --body-file /tmp/docs-sync-<repo>.md
```

If that branch name is taken because an earlier PR merged the same day, use
`docs-sync-<YYYY-MM-DD>-2` — in the `checkout -b`, the `push -u` **and** the `--head`.

**One open → extend it.** Same commit shape, but **rewrite** the body rather than appending
to it: a reviewer reads it once, at merge time, and two stacked findings lists make them
reconcile two half-stories.

```bash
git -C <repo> fetch origin <headRefName>
git -C <repo> checkout <headRefName> && git -C <repo> pull --ff-only
# …edit, add, commit with the Docs-Sync trailer, as above…
git -C <repo> push origin <headRefName>
gh pr edit <n> -R hausfold/<repo> --body-file /tmp/docs-sync-<repo>.md
```

- **`org-profile`'s remote is `hausfold/.github`.** That applies to every `gh` call
  including the `pr list` above — point it at `hausfold/org-profile` and it reports "no open
  PR" for a repo that has one, so the sweep opens a second. When in doubt, drop `-R` and let
  `gh` read the checkout's remote.
- **Every commit carries the `Docs-Sync:` trailer.** `bench docs-since` filters on it;
  without it, the next run reads your output as its input, forever.
- Doc files only (plus Step 5's comment-only edits). Branch per repo, never a cross-repo
  commit.
- If the site changed, build it before pushing: `cd hausfold.co && npm run build`.

**Something bigger than a doc?** Two places, and they're not the same size:

- A local code smell — a stale name, a comment that lies, a flag doing nothing — goes in
  the PR body under `## Needs code, not docs`.
- Something **structural** that keeps making docs wrong, or wants a real refactor: open a
  GitHub issue on that repo saying what's wrong, why it bites, and what you'd do. Search
  first (`gh issue list -R hausfold/<repo> --search "…"`) and add to the existing one
  rather than opening a second. An issue is for a thing worth Julien's attention on its
  own, not a place to file every nit.

**The PR body carries the findings.** Same principle as `/ship`'s: the session that wrote
the diff is gone by the time anyone reads it, so the body has to stand alone. A scheduled
run's chat output is read once and lost. Never `--fill`. Drop any section that's empty:

```markdown
Docs sweep — reconciled <N> commits landed since <date>.

## Cut
- `<file>` — <what went, and why it wasn't earning its lines>.

## Corrected
- `<file>` — was: <the wrong claim>. Now: <what shipped>. (<sha>)

## Added
- `<file>` — <what got a first home>, because <how it cleared the bar>.

## Left alone (deliberately)
- <change> (<sha>) — <why it didn't earn a doc>. Would change if <trigger>.

## Needs code, not docs
- <the smell>, at `<path>` — <why a doc can't fix it>.

## Couldn't land
- `<repo>` — <read fine, push refused>. The diff it wanted: <files + the correction>.

<!-- opened by the /docs-sync routine -->
```

**"Left alone" is the section a reviewer actually needs** — it's the audit trail for the
judgment bar, and the only way anyone catches the sweep being too timid or too eager.

If a repo has findings but no doc change, carry them into the *workshop* PR tagged with the
repo they belong to; don't open an empty PR. The one exception is `## Couldn't land` — a
refused push is a finding, and swallowing it to honor the no-empty-PR rule hides exactly
the failure that rule was never about.

## Step 7 — mark the watermark

**Only after the PRs are open**, and name every repo you left a PR on:

```bash
./bench docs-since --mark --pending <repo> <repo>…
```

Each repo carries two watermarks. `--mark` advances **`read`** for all of them; `--pending`
holds **`landed`** back for the ones whose corrections are still in an unmerged PR, so the
gap shows up as a ⚠ on every run until that PR merges and Step 6 runs `--landed`. Name them
accurately in both directions: a repo you list but left no PR on warns forever, and one you
leave off silently claims documented what is still only read.

It records each repo's **`main`**, deliberately, not the branch you're standing on: the
watermark tracks source commits you've *read*, and those live on `main`. Your doc PR is
this sweep's output, not its input. Marking before landing loses the run silently — if the
sweep failed partway, leave the watermark alone so tomorrow re-reads it.

Then put **every** repo back on `main`, the workshop included. `git push origin main`
pushes the local ref *named* `main`, so a workshop still sitting on a `docs-sync-*` branch
commits the watermark there and pushes an unchanged `main`: the push succeeds, the
watermark never moves, and the next run re-reads everything.

```bash
git -C <repo> checkout main
git -C <workshop> rev-parse --abbrev-ref HEAD    # must print: main
git -C <workshop> add .docs-sync.json
git -C <workshop> commit -m "docs-sync: watermark <YYYY-MM-DD HH:MM>

Docs-Sync: <YYYY-MM-DD>"
git -C <workshop> pull --rebase origin main && git -C <workshop> push origin main
```

The `--rebase` isn't decoration: `main` moves under a run that took twenty minutes, and a
bare push then fails on a non-fast-forward *after* the PRs are open. If it conflicts,
another run advanced the watermark while you worked. The file is generated state, never a
merge to resolve by hand — take the upstream copy and re-mark on top of it. **Mind git's
sense of the words**, which is backwards from the one you want: mid-rebase `--ours` is
`origin/main` and `--theirs` is your own replayed commit.

```bash
git -C <workshop> checkout --ours .docs-sync.json   # --ours IS origin/main, in a rebase
./bench docs-since --landed <repo>…                # whatever Step 6 confirmed merged
./bench docs-since --mark --pending <repo>…
git -C <workshop> add .docs-sync.json && git -C <workshop> rebase --continue
```

`--ours` takes the whole file, so it also drops two things `--mark` won't put back: the
`comments.done` line Step 5 wrote, and any `--landed` catch-up from Step 6 — `--mark`
reads the old `landed` out of the file that was just reverted, so a merged PR would go
back to warning forever. Re-run the `--landed` and re-apply the `comments.done` line
before `rebase --continue`.

This is the one commit the sweep puts on `main` directly, and it's deliberate: it must
advance even on a day that produced no PR. Content still only ever lands through a PR.

## Step 8 — report

The PR bodies hold the detail. The chat report is an index, not a duplicate:

- **PR links**, one line each on what that repo's sweep covered.
- **The two or three judgment calls closest to the line** — not the whole "left alone" list.
- **Anything that blocked you**: a repo you couldn't read or push to, a failed build, a
  watermark you deliberately left unmarked, and any repo still carrying a read-but-not-
  landed ⚠ — that one is a PR waiting on Julien, and saying so is how it stops waiting.

A clean no-op run is one line saying so. Never claim a doc is now accurate unless you read
the code it describes.

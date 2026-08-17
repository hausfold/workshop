---
name: docs-sync
description: >-
  The rolling docs sweep for the hausfold family: read every commit landed since the last
  sweep, find what those commits made stale or left undocumented across the web docs (the
  SOT), READMEs, in-repo docs and code comments, and open a PR per repo with the fixes.
  Use when I say /docs-sync, "sync the docs", "docs audit", "are the docs stale", or when
  the scheduled routine fires. Never lands on main unattended — one PR per affected repo.
---

# Docs sync — reconcile the docs with what actually shipped

Code moves across ten repos all day; the docs don't follow on their own. This sweep
closes that gap on a few-hour cadence: read what landed, decide what it broke or left
unsaid, fix it in the right place, open a PR.

**It runs often, so each run is small.** The watermark (Step 1) means a run only ever
reads commits no run has read before — most fire on an empty range and cost nothing.
That cadence is the point: a doc fix lands within hours of the change that broke it,
while the commit is still legible. It also means **a run must not open its own PR when
one is already open for that repo** — see Step 5.

**The site is the source of truth, and since 2026-08-14 that is `hausfold.co`.**
`hausfold.co/content/docs/` (Fumadocs) is where anything a *user* experiences
gets documented. ⚠️ **The workshop's own docs tree is gone**, along with `web/`
itself, so a path below that starts `web/…` is history. READMEs,
agent instructions (`AGENTS.md`/`CLAUDE.md`) and in-repo docs serve contributors and
agents. When the two disagree, the
site wins and the repo doc gets corrected — never the reverse.

## Step 0 — if you're in a cloud container, plant the other nine repos first

Skip this entirely when you're on Julien's Mac — the checkouts are already there.

The scheduled run boots a bare Linux container holding **only** the workshop. `bench
docs-since` reads nine other checkouts, and a repo it can't open is a blind spot it
reports as clean, so plant them before anything else:

```bash
./.agents/setup.sh              # Determinate Nix + the proxy CA; no-ops if Nix exists
command -v python3 gh || echo "MISSING — the watermark needs python3, Step 5 needs gh"
./bench clone                   # the nine others, at the dir names bench expects
git config --global user.name  "docs-sync"
git config --global user.email "docs-sync@hausfold.co"
```

Two things about that layout are load-bearing and neither is guessable. The nine live
**inside** the workshop checkout, as gitignored subdirectories — `<workshop>/haus`,
`<workshop>/nebelung`, … — not beside it (`repo_dir` is `$ROOT/<name>`, and `$ROOT` *is*
the workshop). And `org-profile`'s directory is `org-profile` while its remote is
`hausfold/.github`. `bench clone` gets both right; a hand-rolled `git clone` gets both
wrong, and the reward is nine `⚠ no checkout at …` lines you can mistake for a quiet day.

**Call it `./bench`, not `bench`.** On Julien's Mac a wrapper puts it on PATH; here
nothing does, so every bare `bench` below is a `command not found` in a container.

**Push access is per-repo and may not cover all ten.** Find out before you spend a run's
budget writing docs you can't land — `git -C <repo> push --dry-run origin HEAD` says so
in a second. A repo you can read but not push to is not a failed sweep: reconcile it
anyway and carry its findings into the **workshop** PR under a `## Couldn't land` section,
naming the repo, the files and the diff you would have pushed. Say it in the chat report
too (Step 7) — a silently skipped repo looks exactly like a clean one, which is the
failure mode this whole sweep exists to avoid.

## Step 1 — what landed?

```bash
./bench docs-since
```

This prints, per repo, every commit past the last reconciled watermark plus the files
each touched. It is watermark-based, not "since yesterday" — a sweep that didn't run for
four days still picks up all four.

`docs-since` walks **`DOCS_REPOS`** (`bench:1783`): the workshop, `FAMILY` (nebelung,
pounce, perch, holt, haus), `org-profile`, `homebrew-tap`, and the two repos that
carry docs without carrying a lock edge — **`trill`** and **`hausfold.co`**. That last
pair is why this list is not `FAMILY` plus trimmings: docs coverage and lock coverage
are different questions: from trill's eject (2026-08-09) until workshop#296 the
compositor's docs were structurally unreachable, and a repo with no arm here looks
exactly like a repo with nothing to say. If you find yourself "tidying" `DOCS_REPOS`
toward `FAMILY`, don't.

> ⚠️ **Three `⚠` lines in that output are holes, not clean repos — read them.**
> `no checkout at …` — never cloned, so **not swept at all** (fix: `bench clone`).
> `first sweep — reading its FULL history` — the repo just joined the list, so treat
> its whole backlog as unreconciled; that run is bigger than a normal day and its PR
> should say so. `watermark … is gone` — the range is a **one-day guess**, not a
> baseline, so commits older than that were read by nobody; widen it by hand if the
> repo matters. None of the three aborts the sweep, so a quiet run can still be an
> incomplete one — carry them into the report.

**Do not `--mark` yet**; that happens at the very end,
only for what you actually reconciled.

If it says nothing is new, say so and stop. A no-op day is a fine outcome — don't go
hunting for something to change.

For any commit whose subject is thin, read the actual diff before judging it:

```bash
git -C <repo> show <sha> --stat
git -C <repo> show <sha> -- <the file that matters>
```

Version-stamp commits (`pounce 2026.07.20-4`), lock bumps and merge commits carry no
doc consequence — skip them fast and spend the budget on behavior changes.

## Step 2 — route each change to its doc

Every repo maps to a documentation surface. Follow the workshop's routing table, then:

Doc paths below are relative to **`hausfold.co/content/docs/`** unless a repo is
named. The trees are the layer (`haus/`) and the apps; a desktop is documented
under `haus/desktops/`, because it is a set of values for the layer's options
rather than a subject of its own. If a page seems to want two trees, it is two
pages.

| Changed… | Reconcile against |
|---|---|
| `pounce/pkgs/pounce/*.swift`, commands | the **pounce tree** — `pounce/config.mdx` (every `config.json` key), `pounce/cli.mdx`, `pounce/commands.mdx`, `pounce/writing-commands.mdx`, `pounce/using.mdx` — plus `haus/rooms/launcher.mdx` for the *haus wiring only*, and the repo's own `README.md`/`docs/reference.md`. ⚠️ **`haus/reference/pounce.mdx` is gone**: pounce got a tree of its own on 2026-08-14 and that page was retired into it. A room page documents the room; the app is documented in the app's tree |
| `nebelung/` palette, ports | `haus/rooms/appearance.mdx` (theming and the palette are one page now), `nebelung/README.md` |
| `perch/` — the notch file shelf | the **perch tree** — `perch/index.mdx`, `perch/using.mdx`, `perch/install.mdx` (it got one on 2026-08-14, same day as pounce's) — plus the repo's own `README.md` and `docs/*`, `haus/rooms/shelf.mdx` for the haus wiring, and `haus/keeping-it-current.mdx` for anything install-shaped (perch ships as a cask). ⚠️ **perch is the one product with a sheet AND a tree**: `/perch` is a hand-written landing route in `src/app/perch/`, and hausfold.co's `AGENTS.md` binds a behaviour fixed on one to be fixed on the other in the same commit |
| `trill/` app behavior — the notification compositor | `trill/README.md`, `trill/ARCHITECTURE.md`, and `trill/index.mdx` on the site (it exists now — an incubator page that says what trill is, not what it does) |
| `holt/` — the worktree substrate + its five SDKs | `holt/README.md`, `holt/SPEC.md`, `holt/docs/*`, `holt/sdk/*/README`, and `haus/rooms/ai.mdx` (the user-facing worktree story). ⚠️ An SDK surface change is also a **release** question — see `/release`. ⚠️ holt's `AGENTS.md` arrived only in [holt#31](https://github.com/hausfold/holt/pull/31), so anything older than that was written with no boundary doc in the repo. ⚠️ holt has **no docs tree and no page** on hausfold.co — only an outbound GitHub link from the landing page — so "the docs" for it are the repo's own |
| `hausfold.co/` — the site itself (shell, routes, landing pages) | `hausfold.co`'s own `README.md`/`AGENTS.md`. ⚠️ The *docs* it serves are the row above and below this one, not this row. Never move anything from `hausfold/ops`' name register into it — that repo is private for a reason |
| `haus/modules/*` (the layer + the desktop) | the matching **room**: `haus/rooms/{bar,development,windows,security,focus,apps,appearance,launcher,ai,displays,shelf,text-expansion}.mdx`, plus `haus/reference/options.mdx` and `haus/rooms/windows.mdx` |
| a new/renamed nix option | `haus/reference/options.mdx` — **always**; an option users can set and can't discover is a bug. It is **generated** in hausfold.co from haus's committed `docs/site-data/`, so the fix is re-running its generator, not writing prose |
| a new/changed keybind | the **room that owns the key**: `haus/rooms/windows.mdx` for the window-manager binds, `haus/rooms/launcher.mdx` for ⌘Space, `haus/rooms/ai.mdx` for ⌘A. There is no standalone keybindings page any more. hausfold.co's `keybindings-drift` workflow snapshots `wmBindings`/`launchModeKeys`/`resizeModeKeys` only, so it catches the windows row and **not** the other two |
| `bench`, workshop `README.md` | `haus/internals/contributing.mdx`, `haus/internals/flakes.mdx`, workshop `README.md`/`AGENTS.md` |
| `homebrew-tap`, release CI | `haus/install.mdx`, `haus/keeping-it-current.mdx` |
| `org-profile` (the `hausfold/.github` repo) | `profile/README.md` — **the org front page, the first thing anyone sees** — and `profile/assets/README.md`. Reconcile its repo list and framing against the docs index, `content/docs/index.mdx` (the old `start/the-family` page was retired, not ported) |
| a shot/asset placement anywhere | `assets/SHOTLIST.md` in the workshop — it tracks which README each still has landed in, so a placement commit makes it stale |

**Every repo here is both an input and a target.** The question is never only "does
this commit change the site?" — it's also "did it make a doc *in that repo* wrong?" A
repo with no bearing on the site can still have a stale README of its own, and the
front-of-house repos (`org-profile`, `homebrew-tap`) are the easiest to overlook
precisely because they don't feed the docs site.

### The spellings to correct on sight

| you see | it is | you |
|---|---|---|
| `haus.{sill,prowl,hearth,pounce,perch,hush,collar}.*` | a room under its old **code name** (haus#367, 2026-08-16) | **fix** → `haus.{bar,windows,terminal,launcher,shelf,focus,security.touchId}.*`. **No aliases** — the old spelling is an eval error, so this one is a break, not a style nit. `notes/rooms-desktops.md` has the table |
| a desktop called anything but `hacker`, `everyday`, `minimal` or `blank` | a pre-2026-08-14 name | **fix**, unless the sentence is about the past |
| `inputs.<anything>.url` in a **consumer's** flake | that machine's name for its haus input | **leave** — it is a 👤 file's choice. `bench` reads the name off the consumer's `flake.lock`, so there is nothing here to keep in step |

Same trap in the other direction: `./haus` is the **layer's repo** (`./hausfold` until
2026-08-11, §10 — that directory no longer exists) and `./hausfold.co` is the
**company site**. A doc that sends site work to a short name edits the wrong repo,
and nothing errors.

Grep before concluding something is undocumented — the feature may be described under a
name you didn't search for:

```bash
grep -ril "<feature>\|<flag>\|<option>" hausfold.co/content/docs/ <repo>/README.md
```

## Step 3 — the bar (don't be trigger-happy)

Most commits need no doc change. Be a strict editor, not an eager one.

**Fix it — no hesitation:**
- The docs state something now factually **wrong** (a flag, path, default, keybind,
  option name, version, or behavior that changed).
- A documented step would **fail** if a user followed it today.
- A dead link, a renamed file, a moved section, a stale screenshot reference.
- A code comment that lies about what the code beside it now does.

**Document it new — only if it clears all three:**
1. A **user** can see or act on it (not an internal refactor), **and**
2. it is **discoverable nowhere** today, **and**
3. not knowing it would cost someone real time — a new option, command, keybind,
   permission prompt, or a changed default.

**Leave it alone:**
- Refactors, perf work, test changes, CI plumbing, version stamps, lock bumps.
- Anything experimental, reverted, or behind a flag not yet on by default. (Check for a
  later `Revert` in the same range before documenting a feature.)

**Read the range as a sequence, not a set.** A later commit routinely invalidates an
earlier one — a revert undoes a feature, and a placement commit closes a TODO that
another doc still advertises as open. Two commits that each look like housekeeping can
leave a doc wrong *between* them. When two commits in a range touch the same subject,
check what the pair did before judging either.
- Features whose shape is still moving — a doc written too early is worse than none.
- Your own opinion about how something *should* work. Document what shipped.

When a change sits on the line, **note it in the report instead of writing the doc**.
A surfaced judgment call is cheap; a wrong doc is expensive.

## Step 4 — write it in the house voice

The docs read like a person who knows the system explaining it to a friend — never like
generated reference. Match the file you're editing; when in doubt, read
`haus/rooms/bar.mdx` as the reference for tone.

- **Slim and dense.** Every sentence earns its place. Cut hedging, preamble and
  restatement. If a paragraph can be a sentence, make it a sentence.
- **Lead with the point.** What it does and why you'd want it, then the mechanics.
- **Show the command.** A fenced block a reader can paste beats a description of it.
- **Fun, lightly.** Dry wit and a strong turn of phrase are house style — *"reads
  everything, changes nothing"*. One good line per page, not one per paragraph. Never
  jokey at the reader's expense when they're mid-problem.
- **Pretty.** Use the Fumadocs components — `<Callout>` for the gotcha that will bite
  them, `<Steps>`/`<Step>` for ordered setup, `<Cards>`/`<Card>` for parallel choices,
  tables for dense reference. They are global (hausfold.co's `src/components/mdx.tsx`
  provides them), so a page imports nothing — and they are **not** Starlight's
  `<Aside>`/`<CardGrid>`. Keep frontmatter `description` accurate; it's the search and
  social snippet.
- **Link, don't repeat.** Cross-link to `/docs/haus/reference/options/#…` rather than
  restating an option inline. One fact, one home.
- **Keep it honest.** Say what's read-only, what needs a permission, what's a non-goal.
  Under-promising is house style.

Prefer **editing an existing page over adding one**. A new page is justified only when a
subject has no home at all; otherwise the site grows faster than anyone reads it.

## Step 5 — land it, one *open* PR per repo

Nothing lands on `main` unattended. And because this sweep fires several times a day,
the first question for each repo is never "what do I call my branch" — it is **"is there
already an open docs-sync PR here?"**:

```bash
gh pr list -R hausfold/<repo> --state open \
  --search 'head:docs-sync- in:title docs: sync' --json number,headRefName
```

Six small PRs a day per repo is the failure mode this replaces: it buries the signal,
and a reviewer who merges #3 while #4 is open gets a conflict for no reason. **One open
PR per repo, growing through the day, is the shape.** So the answer picks the branch:

**None open → start one.** Write the findings body to a scratch file first (template
below):

```bash
git -C <repo> checkout main && git -C <repo> checkout -b docs-sync-<YYYY-MM-DD>
git -C <repo> add <the doc files>
git -C <repo> commit -m "docs: <what you reconciled>

Docs-Sync: <YYYY-MM-DD>"
git -C <repo> push -u origin docs-sync-<YYYY-MM-DD>
gh pr create -R hausfold/<repo> --head docs-sync-<YYYY-MM-DD> \
  --title "docs: sync <YYYY-MM-DD>" --body-file /tmp/docs-sync-<repo>.md
```

If that branch name is already taken because today's earlier PR merged, use
`docs-sync-<YYYY-MM-DD>-2` — in the `checkout -b`, the `push -u` **and** the `--head`.

**One open → extend it.** Same commit, but the body gets **rewritten**, not appended to:
a reviewer reads it once, at merge time, and two stacked "Corrected" lists make them
reconcile two half-stories. Read the old body, fold your findings into it, write the
union to the scratch file:

```bash
git -C <repo> fetch origin <its headRefName>
git -C <repo> checkout <its headRefName> && git -C <repo> pull --ff-only
# …edit, add, commit with the Docs-Sync trailer, as above…
git -C <repo> push origin <its headRefName>
gh pr edit <n> -R hausfold/<repo> --body-file /tmp/docs-sync-<repo>.md
```

- **A checkout's directory name is not its repo name.** `-R hausfold/<repo>` is right for
  every repo *except* `org-profile`, whose remote is **`hausfold/.github`** (the dir can't
  be named `.github` — it would be invisible and collide with the workshop's own CI dir).
  That applies to **every** `gh` call above, the `pr list` that opens the step included —
  point it at `hausfold/org-profile` and it reports "no open PR" for a repo that has one,
  so the sweep opens a second. `bench`'s `gh_repo()` is the only place that knows; when in
  doubt, drop the `-R` and let `gh` read the checkout's own remote.
- **Every commit gets the `Docs-Sync:` trailer.** Your PRs land on `main` like anything
  else, so without it the next sweep reads yesterday's output as today's input — every
  day, forever. `bench docs-since` filters on that trailer; a commit missing it will come
  back to haunt you tomorrow.
- Commit **only** doc files. If a fix needs a code change, don't make it — report it.
- Branch per repo, never a cross-repo commit. Each repo owns its own boundary.
- If the site changed, build it before pushing — a broken build is worse than a stale
  page: `cd hausfold.co && npm run build`.

**The PR body carries the findings.** A scheduled run's chat output is read once and
lost; the PR is where the reasoning has to live, so a reviewer can judge the diff without
re-deriving it. Never use `--fill`. Write the body as:

```markdown
Docs sweep — reconciled <N> commits landed since <date>.
Previous sweep: <the `last_run` in .docs-sync.json, before you re-marked it>.

## Corrected
- `<file>` — was: <the wrong claim>. Now: <what shipped>. (<sha>)

## Documented new
- `<file>` — <what got a first home>, because <how it cleared the bar>.

## Left alone (deliberately)
- <change> (<sha>) — <why it didn't earn a doc>. Would change if <trigger>.

## Needs code, not docs
- <the smell>, at `<path>` — <why a doc can't fix it>.

## Couldn't land
- `<repo>` — <read fine, push refused>. The diff it wanted: <files + the correction>.

<!-- opened by the /docs-sync routine -->
```

Drop any section that's empty. **"Left alone" is the section a reviewer actually needs**
— it's the audit trail for the judgment bar, and the only way you'd catch the sweep
being too timid or too eager. Include it even when the diff is trivial.

If a repo has **findings but no doc change** — everything landed cleanly, but you spotted
something code-level — carry those findings in the *workshop* PR under "Needs code, not
docs", tagged with the repo they belong to. Don't open an empty PR.

If nothing needed changing and there is nothing to report anywhere, open no PR.

**"Don't open an empty PR" bows to `## Couldn't land`.** A push you were refused is a
finding, not an absence of one — if that's all a run produced, the workshop PR carrying it
is the whole point, and swallowing it to honour the no-empty-PR rule hides exactly the
failure that rule was never about.

## Step 6 — mark the watermark

**Only after the PRs are open**, and only then:

```bash
./bench docs-since --mark
```

This records where the next sweep starts. Marking before landing loses the day's work
silently — if the sweep failed partway, leave the watermark alone so tomorrow re-reads it.

It records each repo's **`main`**, deliberately, not the branch you're standing on: a
sweep ends sitting on its own `docs-sync-*` branch, and parking the watermark on a commit
`main` doesn't contain sends every later run reading from a bogus base. `main` is also the
right answer — the watermark tracks the source commits you've *read*, and those live on
`main`. Your doc PR is this sweep's output, not its input.

Then put **every** repo back on `main` — the workshop included, and that one is not
housekeeping. `git push origin main` pushes the local ref *named* `main`, so a workshop
still sitting on its own `docs-sync-*` branch commits the watermark to that branch and
then pushes an unchanged `main`: the push succeeds, the watermark never moves, and the
next run re-reads everything. Assert it, don't assume it:

```bash
git -C <repo> checkout main
git -C <workshop> rev-parse --abbrev-ref HEAD    # must print: main
```

`.docs-sync.json` is **committed**, because the sweep normally runs as a scheduled routine
in a throwaway container — anything it must remember between runs has to live in the repo.
So push the advanced watermark to the workshop's `main` on its own:

```bash
git -C <workshop> add .docs-sync.json
git -C <workshop> commit -m "docs-sync: watermark <YYYY-MM-DD HH:MM>

Docs-Sync: <YYYY-MM-DD>"
git -C <workshop> pull --rebase origin main && git -C <workshop> push origin main
```

The `--rebase` is not decoration at this cadence: `main` moves under a run that took
twenty minutes, and a bare `push` then fails on a non-fast-forward *after* the PRs are
already open — leaving the watermark behind and the next run re-reading everything you
just reconciled.

If the rebase conflicts, another run advanced the watermark while you worked. The file is
generated state, never a merge to resolve by hand — take the upstream copy and re-mark on
top of it. **Mind git's sense of the words here**, because it is backwards from the one
you want: mid-rebase, `--ours` is `origin/main` and `--theirs` is the commit being
replayed, so the intuitive `--theirs` hands you back your own file and clobbers the run
you were trying to preserve.

```bash
git -C <workshop> checkout --ours .docs-sync.json   # --ours IS origin/main, in a rebase
./bench docs-since --mark
git -C <workshop> add .docs-sync.json && git -C <workshop> rebase --continue
```

This is the one commit the sweep puts on `main` directly, and it's deliberate: it must
advance even on a day that produced no PR, or those commits get re-read forever. It
carries the `Docs-Sync:` trailer like everything else, so it never feeds the next run.
Content still only ever lands through a PR.

## Step 7 — report

The PR bodies hold the detail, so keep the chat report short — it's an index, not a
duplicate:

- **PR links**, one line each on what that repo's sweep covered.
- **The judgment calls worth a human's attention** — the two or three closest to the
  line, not the whole "left alone" list.
- **Anything that blocked you** — a repo you couldn't read, a build that failed, a
  watermark you deliberately left unmarked.

Never claim a doc is now accurate unless you read the code it describes.

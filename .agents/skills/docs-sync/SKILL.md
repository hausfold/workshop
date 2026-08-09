---
name: docs-sync
description: >-
  The daily docs sweep for the hausfold family: read every commit landed since the last
  sweep, find what those commits made stale or left undocumented across the web docs (the
  SOT), READMEs, in-repo docs and code comments, and open a PR per repo with the fixes.
  Use when I say /docs-sync, "sync the docs", "docs audit", "are the docs stale", or when
  the daily routine fires. Never lands on main unattended — one PR per affected repo.
---

# Docs sync — reconcile the docs with what actually shipped

Code moves daily across seven repos; the docs don't follow on their own. This sweep
closes that gap once a day: read what landed, decide what it broke or left unsaid, fix
it in the right place, open a PR.

**The site is the source of truth.** `web/src/content/docs/` (Astro Starlight,
nebelhaus.com) is where anything a *user* experiences gets documented. READMEs,
agent instructions (`AGENTS.md`/`CLAUDE.md`) and in-repo docs serve contributors and
agents. When the two disagree, the
site wins and the repo doc gets corrected — never the reverse.

## Step 1 — what landed?

```bash
bench docs-since
```

This prints, per repo, every commit past the last reconciled watermark plus the files
each touched. It is watermark-based, not "since yesterday" — a sweep that didn't run for
four days still picks up all four. **Do not `--mark` yet**; that happens at the very end,
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

| Changed… | Reconcile against |
|---|---|
| `pounce/pkgs/pounce/*.swift`, commands | `web/.../guides/pounce.mdx`, `guides/pounce-commands.mdx`, `reference/pounce.md`, `pounce/README.md` |
| `nebelung/` palette, ports | `web/.../reference/palette.mdx`, `guides/theming.mdx`, `nebelung/README.md` |
| `trill/` app behavior — **the notification compositor**, once it ejects (`incubator/trill` until then) | `trill/README.md`, `trill/ARCHITECTURE.md`, and a web guide once one exists. ⚠️ `guides/trill.mdx` was the *archived Messages client's* page and is deleted; `/trill` on the site still redirects to that repo. See `notes/hausfold-rename.md` §3.4. |
| `nebelhaus/modules/*` (rice) | `web/.../guides/*` (the-bar, the-shell, window-management, touch-id, hush), `reference/options.md`, `reference/keybindings.md` |
| a new/renamed nix option | `reference/options.md` — **always**; an option users can set and can't discover is a bug |
| a new/changed keybind | `reference/keybindings.md` — **always** |
| `bench`, workshop `README.md` | `internals/contributing.mdx`, `internals/flakes.mdx`, workshop `README.md`/`AGENTS.md` |
| `homebrew-tap`, release CI | `start/install.mdx`, `guides/staying-in-sync.mdx` |
| `org-profile` (the `nebelhaus/.github` repo) | `profile/README.md` — **the org front page, the first thing anyone sees** — and `profile/assets/README.md`. Reconcile its repo list and framing against `start/the-family.md` |
| a shot/asset placement anywhere | `assets/SHOTLIST.md` in the workshop — it tracks which README each still has landed in, so a placement commit makes it stale |

**Every repo here is both an input and a target.** The question is never only "does
this commit change the site?" — it's also "did it make a doc *in that repo* wrong?" A
repo with no bearing on the site can still have a stale README of its own, and the
front-of-house repos (`org-profile`, `homebrew-tap`) are the easiest to overlook
precisely because they don't feed nebelhaus.com.

Grep before concluding something is undocumented — the feature may be described under a
name you didn't search for:

```bash
grep -ril "<feature>\|<flag>\|<option>" web/src/content/docs/ <repo>/README.md
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
`guides/the-bar.mdx` as the reference for tone (`guides/trill.mdx` was the
old pointer here; it was deleted with the archived Messages client's page in
workshop#204).

- **Slim and dense.** Every sentence earns its place. Cut hedging, preamble and
  restatement. If a paragraph can be a sentence, make it a sentence.
- **Lead with the point.** What it does and why you'd want it, then the mechanics.
- **Show the command.** A fenced block a reader can paste beats a description of it.
- **Fun, lightly.** Dry wit and a strong turn of phrase are house style — *"reads
  everything, changes nothing"*. One good line per page, not one per paragraph. Never
  jokey at the reader's expense when they're mid-problem.
- **Pretty.** Use the Starlight components already imported in the file — `<Aside>` for
  the gotcha that will bite them, `<Steps>` for ordered setup, `<CardGrid>`/`<Card>` for
  parallel choices, tables for dense reference. Keep frontmatter `description` accurate;
  it's the search and social snippet.
- **Link, don't repeat.** Cross-link to `/reference/options/#…` rather than restating an
  option inline. One fact, one home.
- **Keep it honest.** Say what's read-only, what needs a permission, what's a non-goal.
  Under-promising is house style.

Prefer **editing an existing page over adding one**. A new page is justified only when a
subject has no home at all; otherwise the site grows faster than anyone reads it.

## Step 5 — land it, one PR per repo

Nothing lands on `main` unattended. For each repo you changed:

```bash
git -C <repo> checkout -b docs-sync-<YYYY-MM-DD>
git -C <repo> add <the doc files>
git -C <repo> commit -m "docs: <what you reconciled>

Docs-Sync: <YYYY-MM-DD>"
git -C <repo> push -u origin docs-sync-<YYYY-MM-DD>
# write the findings body to a scratch file first (see the template below)
gh pr create -R nebelhaus/<repo> --head docs-sync-<YYYY-MM-DD> \
  --title "docs: sync <YYYY-MM-DD>" --body-file /tmp/docs-sync-<repo>.md
```

- **Every commit gets the `Docs-Sync:` trailer.** Your PRs land on `main` like anything
  else, so without it the next sweep reads yesterday's output as today's input — every
  day, forever. `bench docs-since` filters on that trailer; a commit missing it will come
  back to haunt you tomorrow.
- Commit **only** doc files. If a fix needs a code change, don't make it — report it.
- Branch per repo, never a cross-repo commit. Each repo owns its own boundary.
- If the site changed, build it before pushing — a broken build is worse than a stale
  page: `cd web && npm run build`.

**The PR body carries the findings.** A scheduled run's chat output is read once and
lost; the PR is where the reasoning has to live, so a reviewer can judge the diff without
re-deriving it. Never use `--fill`. Write the body as:

```markdown
Daily docs sweep — reconciled <N> commits landed since <date>.

## Corrected
- `<file>` — was: <the wrong claim>. Now: <what shipped>. (<sha>)

## Documented new
- `<file>` — <what got a first home>, because <how it cleared the bar>.

## Left alone (deliberately)
- <change> (<sha>) — <why it didn't earn a doc>. Would change if <trigger>.

## Needs code, not docs
- <the smell>, at `<path>` — <why a doc can't fix it>.

<!-- opened by the daily /docs-sync routine -->
```

Drop any section that's empty. **"Left alone" is the section a reviewer actually needs**
— it's the audit trail for the judgment bar, and the only way you'd catch the sweep
being too timid or too eager. Include it even when the diff is trivial.

If a repo has **findings but no doc change** — everything landed cleanly, but you spotted
something code-level — carry those findings in the *workshop* PR under "Needs code, not
docs", tagged with the repo they belong to. Don't open an empty PR.

If nothing needed changing and there is nothing to report anywhere, open no PR.

## Step 6 — mark the watermark

**Only after the PRs are open**, and only then:

```bash
bench docs-since --mark
```

This records where the next sweep starts. Marking before landing loses the day's work
silently — if the sweep failed partway, leave the watermark alone so tomorrow re-reads it.

It records each repo's **`main`**, deliberately, not the branch you're standing on: a
sweep ends sitting on its own `docs-sync-*` branch, and parking the watermark on a commit
`main` doesn't contain sends every later run reading from a bogus base. `main` is also the
right answer — the watermark tracks the source commits you've *read*, and those live on
`main`. Your doc PR is this sweep's output, not its input.

Then put each repo back on `main` so the next sweep starts from a clean tree:

```bash
git -C <repo> checkout main
```

`.docs-sync.json` is **committed**, because the sweep normally runs as a scheduled routine
in a throwaway container — anything it must remember between runs has to live in the repo.
So push the advanced watermark to the workshop's `main` on its own:

```bash
git -C <workshop> add .docs-sync.json
git -C <workshop> commit -m "docs-sync: watermark <YYYY-MM-DD>

Docs-Sync: <YYYY-MM-DD>"
git -C <workshop> push origin main
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

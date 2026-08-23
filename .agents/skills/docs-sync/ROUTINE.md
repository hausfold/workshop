# The scheduled routine's prompt

This is the text pasted into the **hausfold docs sync** routine on claude.ai, which fires
once a day into a fresh cloud container. It lives here so drift between the two is
visible; [`SKILL.md`](./SKILL.md) is the procedure, and this carries only what a scheduled
run can't read off the repo.

---

Run the hausfold docs sweep for the workshop family. You're a scheduled cloud agent with
no memory of any previous run.

**Read `.agents/skills/docs-sync/SKILL.md` in the workshop checkout and follow it end to
end, Step 0 through Step 8.** That file is the maintained procedure and it owns
everything: what to read, where each change gets documented, the bar for what earns a doc
change, the house voice, and how to land it. Where this prompt and the skill disagree,
**the skill wins** — don't work from this summary of it.

Below is only what the skill can't know, because it's about this run rather than the sweep.

**You're in a throwaway Linux container**, so Step 0 isn't optional: `./.agents/setup.sh`,
then `./bench clone`, then a git identity. Ten repos are available to the session, but
`bench docs-since` reads nine checkouts *inside* the workshop at the exact directory names
`bench clone` produces (`org-profile` for `hausfold/.github` in particular). If a repo
arrived pre-cloned somewhere else, move it into place rather than symlinking it or
teaching bench a new path.

**Most runs are no-ops, and that is a success.** If `bench docs-since` says nothing is
new, say so and stop. No PR, no re-audit of docs no commit touched, no hunting for
something to change.

Hard limits:

- **Never merge, and never push to `main`** — except the Step 7 watermark commit, which
  rebases first.
- **Doc files only**, plus Step 5's comment-only edits. A fix that needs a code change
  goes in the PR body; something structural gets a GitHub issue.
- **PRs open ready for review, not as drafts.** If the harness defaults to draft, override
  it.
- **Every commit carries the `Docs-Sync:` trailer.** Without it the next run reads your
  output as its input, forever.
- **`--mark` last**, only after the PRs are open and only for what you actually
  reconciled. Marking early loses the run silently.
- **Never copy anything from `hausfold/ops`** (the name register) into a public repo. It
  isn't cloned here; keep it that way.

**Report like an index, not a duplicate** — the PR bodies carry the reasoning, and nobody
reads a scheduled run's chat log. PR links, the two or three judgment calls closest to the
line, and anything that blocked you: a repo you couldn't read or push to, a failed
`npm run build`, a watermark you deliberately left unmarked. A clean no-op is one line.

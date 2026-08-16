---
name: release
description: >-
  Cut a release in the hausfold workshop with `bench release <repo> [version]` — stamp the
  version, tag it, watch CI publish, then ripple the lock. Use when I say /release, "cut a
  release", "release holt", "publish the SDKs", "ship a new version to npm", or ask what the
  next version number should be. Its main job is the one thing `bench` can't do for you:
  DECIDING holt's semver bump by reading the diff since the last release. Releasing is
  gated — propose the number and the command, run it only when I say go.
---

# Release (hausfold workshop): pick the number → `bench release` → ripple

`bench release` already does everything mechanical: stamp the version into the repo's own
version source, commit it, push, tag `v<version>`, then BLOCK on the CI run and report when
it's live. You never push a `v*` tag by hand and you never touch `homebrew-tap` — CI owns
the formula bump.

So this skill is about the two things `bench` deliberately doesn't decide:

1. **Is the repo ready to release?**
2. **What number?** — which is only a question for `holt`. Everything else is CalVer.

## Which repo, which scheme

| repo | scheme | command | who consumes the release |
|---|---|---|---|
| `pounce` | CalVer | `bench release pounce` | Homebrew tap |
| `perch` | CalVer | `bench release perch` | Homebrew tap + the rice's flake pin |
| `haus` | CalVer | `bench release haus` | `hausfold.co/hacker.sh` |
| `holt` | **semver** | `bench release holt <X.Y.Z>` | npm, PyPI, crates.io, SwiftPM, the Go proxy |

CalVer repos take **no** version argument — the date IS the version, and `bench` refuses an
argument to make that unarguable. holt takes one and refuses to run without it.

### Why holt alone is semver

Not a style preference — it was decided before we got here. holt publishes five *libraries*
to third-party registries, and `@hausfold/holt`, `hausfold-holt` (PyPI) and `hausfold-holt`
(crates.io) already hold **0.1.0**. npm, PyPI and crates versions are immutable: a number,
once published, can never be re-cut or withdrawn, only superseded. CalVer would also force
the Go SDK's import path to end in `/v2026` (Go's major-version rule) and change it every
January. So holt's number is a compatibility contract, and someone has to read the diff to
set it. That someone is you.

## Deciding holt's bump

Read the actual change, not the commit subjects:

```sh
LAST=$(git -C ~/code/workshop/holt describe --tags --abbrev=0 --match 'v*' 2>/dev/null || echo 0.1.0)
git -C ~/code/workshop/holt log --oneline "$LAST"..main
git -C ~/code/workshop/holt diff "$LAST"..main -- sdk/
```

On the FIRST cut there is no `v*` tag — the 0.1.0 on the registries was published by hand
before this flow existed. Diff against the commit that stamped 0.1.0 into the manifests, or
just read `sdk/*/` history since then.

Judge it against the **published SDK surface**, not the CLI internals:

- **MAJOR** — a signature, type, or behaviour that existing SDK code depends on changed or
  disappeared. Renaming an exported method, changing a returned shape, dropping a field
  from an event, tightening what an argument accepts.
- **MINOR** — new capability, everything that compiled before still compiles. A new client
  method, a new optional field, a new event variant consumers can ignore.
- **PATCH** — a fix, a doc, a test, a CLI-only change with no SDK surface movement.

Two rules that override the taxonomy:

- **The five SDKs share one number.** A MAJOR change in the Rust SDK alone bumps all five.
  That is the point of one version: five clients agreeing about one wire format is the
  invariant the SDK CI job exists to protect, and five drifting version lines would hide a
  divergence rather than surface it.
- **Pre-1.0, breaking still means MINOR-or-major, never PATCH.** holt is 0.x. If you'd have
  called it MAJOR at 1.0, cut a MINOR (`0.1.0` → `0.2.0`) and say so in the release notes.
  Never smuggle a break into a patch — that is the number people pin against.

Say which one you picked **and the sentence of evidence for it** before running anything:

> `0.2.0` — MINOR. `watchLane` gained an events form in the Go and Rust clients (#28); the
> line-yielding form is still there, so nothing published against 0.1.0 breaks.

## Preconditions (check, don't assume)

```sh
bench status          # the release-edges section names what's behind
```

Then, for the repo you're cutting:

- Working tree clean and **pushed** — `bench release` refuses both, but check first so you
  find out before it does.
- The work landed via its PR. Releasing an unmerged branch isn't a thing: `bench release`
  tags the checkout's HEAD, which should be `main` at origin.
- For holt, the number isn't already tagged. `bench` checks; you check first.

## Run it

```sh
bench release holt 0.2.0          # or: bench release haus
```

It stamps, commits, pushes, tags, then paints a live job tree until CI finishes. For holt
that's the shared PR gate (both OSes, all six suites) followed by six publish jobs — the
GitHub release, npm, PyPI, crates.io, the `sdk/go/vX.Y.Z` tag, and the SwiftPM mirror tag.
Every publish job is independent and idempotent, so if one registry fails the others still
land and `gh run rerun --failed` finishes the job rather than half-cutting a second release.

**If a publish job fails on auth**, the registry hasn't been told to trust the workflow yet.
That's a one-time browser setup per registry, listed in the header of
`holt/.github/workflows/release.yml`. Point me at the specific one and stop — it is my
click to make, not yours.

## Afterwards

The version stamp is a commit, so the repo's HEAD moved and its downstream flake lock is now
stale. `bench release` says so; ripple it:

```sh
bench ship                        # or cut with: bench release holt 0.2.0 --ship
```

## The gate

Releasing is the one step in this workshop that is **not** standing permission — it's
user-facing and irreversible on three registries. Propose the number, the evidence, and the
exact command, then wait. `/ship` explicitly stops short of it. Once I say go, run it all
the way to "live" and ripple, without re-asking per repo.

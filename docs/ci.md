# CI

One gate per repo, all of it GitHub Actions. Every repo in the family is
public, so runner minutes are free and **the only thing CI costs is the wall
clock between pushing and knowing**. Everything below is written to keep that
number small, and it binds every repo here.

The gate's job is unchanged by any of it: a PR that goes green is a PR whose
claims were checked. Speed is never bought by dropping a check — it is bought
by not paying twice for the same one.

## The gate, repo by repo

| repo | workflow | where it runs | what it can only prove there |
| --- | --- | --- | --- |
| `haus` | `check` | ubuntu ×5 | evaluating a whole darwin system, plus twenty-four platform-independent flake checks; the shell half is bats and shellcheck, in four jobs grouped by what a suite needs — the lint, the suites that read snug's painter, the agent surface, every other room |
| `pounce` | `build` | macOS ×2, ubuntu ×2 | the app is built by `xcrun swiftc` through Nix, so it wants a real Mac; the skill guards and the command lint do not |
| `perch` | `build` | macOS ×2, ubuntu | Xcode test + analyze + Release, the arm64 slice guard, and the iOS companion; the skill guards are the one job off the Mac |
| `trill` | `build` | macOS | Xcode test + analyze + Release, and the no-instrumentation guard on the built bundle |
| `scruff` | `check` | ubuntu ×3, macOS ×2 | the acceptance suite on both OSes (occupancy and reflink diverge), five SDKs against one fixture, and `vendorHash` |
| `snug` | `ci` | ubuntu ×3, macOS | the Go width sweeps on both OSes, the bash painter on Linux only (it needs bash 4), and `vendorHash` |
| `nebelung` | `check` | ubuntu ×2 | that `dist/` and `preview/` still equal what the flake renders |
| `factory` | `Tests` | ubuntu | bats over the shift, the tier filter, the watchdog and the lease |
| workshop | `Tests` | ubuntu | `bench` itself — bats plus shellcheck |
| workshop | `issue templates` | ubuntu | that ten repos still match one generator; weekly, because the child half can only be caught by a sweep |
| `hausfold.co` | `Docs`, `Preview`, `Deploy`, `Worker`, `DNS`, `Palette`, the preview sweep and four drift jobs | ubuntu | the site builds, its tables still match the data the layer publishes, and its palette still matches nebelung's |

`homebrew-tap`, `org-profile`, `producer-desktop` and `scruff-swift` have no
gate: the first three carry no code of their own that a test could fail, and
the fourth is a generated mirror. `ops` runs a scheduled `scoreboard` and
nothing on a push.

Release workflows are a different animal and are not on this list: they fire on
a `v*` tag, they publish something that cannot be withdrawn, and none of the
**speed** rules below are worth a risk there. **Rule 4 is not a speed rule and
is not exempt** — a floating action on the job that signs and notarises what
users install is the worst place in the repo to have one.

## Four rules

**1. Ask the runner image before you ask a package manager.** `shellcheck`,
`jq`, `git`, `node`, `npm`, `go` and `python` are already on `ubuntu-latest`.
`bats` is the one thing the family regularly needs that is not — it comes from
`sudo npm install -g bats`, never from apt, and on a macOS runner without the
`sudo` (that image's npm prefix belongs to the runner user). Print the version
of anything taken from the image, so an image that drops it fails loudly
instead of as `command not found` halfway through a lint.

**Never `apt-get update`.** The Azure mirrors the runners point at fail in a
way apt does not treat as failure, so the step can look alive for hours while
getting nowhere — `haus`'s `.github/workflows/check.yml` carries the full
account of the afternoon that taught us, and `Acquire::http::Timeout` is not
the fix. If apt ever becomes genuinely necessary, wrap the whole call in
`timeout 120 …`; a per-request option cannot bound a step that retries.

**2. One run per commit.** The trigger is:

```yaml
on:
  push:
    branches: [main]
  pull_request:
  workflow_dispatch:
```

`branches: ['**']` fires the same workflow twice for every push to a PR branch
— once as `push`, once as `pull_request` — for one commit and one answer.

`workflow_dispatch` is the third line's whole job: narrowing `push` to `main`
takes away the only way a branch with no PR yet was ever checked, and the
dispatch button hands it back. Drop it and the gate is one run per commit *and*
no run at all for work that isn't a PR. Dispatching a branch and then opening a
PR on the same tree does produce two runs, which is the one hole in the rule's
own headline — it takes a deliberate button press, so it stays.

That block is the floor, not the whole `on:`. `scruff`'s `check.yml` also
carries `workflow_call`, because its release workflow calls the gate at a tag.

**3. Cancel a superseded PR run.** A second push to a branch has already made
the first run's answer worthless, and the abandoned run still holds its
runners. On the macOS ones that is a queue slot the next PR waits behind, which
is most of what a Mac job's start time is.

```yaml
concurrency:
  group: <workflow>-${{ github.event_name == 'pull_request' && github.ref || github.sha }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
```

**Only a PR run is ever in a shared group**, and the ternary is the whole
point of the line. Keying every event on `github.ref` would put all main pushes
in one group, where two things go wrong even with cancelling off: they
serialize, and GitHub cancels a *pending* run outright when a newer one joins
the group. Three merges inside one build's wall clock would then leave the
middle commit with no run at all — the exact tick the rule is protecting.
Everything that is not a PR keys on the commit instead, so it gets a group of
its own and cancels nothing.

The same reasoning is why `scruff`'s `check` is safe: its release workflow
calls it at a tag, a called run reports the caller's event (`push`), and a
cancel there would be a half-published release.

`hausfold.co` is where to look for the rule that is NOT on this list: most of
its workflows carry a `paths:` filter, so a PR that touches no content runs no
content check. That is the rule the rest of the family has the least of — most
of these gates are small enough that a filter would cost more reading than it
saves, but it is the first thing to reach for when one is not. Its drift jobs
are also the place rules 2 and 3 are least applied (`push:` with `paths:` and
no `branches:`, and no `concurrency` at all), which is a thing to fix there
rather than a thing to copy.

**4. Pin third-party actions to a tag.** `@main` is whatever that vendor
pushed this morning, running on the machine that compiles what we ship.

## The Nix store cache

`haus` and `nebelung` keep `/nix` between runs with
[`nix-community/cache-nix-action`](https://github.com/nix-community/cache-nix-action),
sitting behind `nixbuild/nix-quick-install-action` — one of the three
installers that action documents itself as compatible with, and the fastest of
them to land.

The key is `flake.lock` plus every `*.nix`, so a lock bump or a module edit
pays full price and nothing else does.

**`save: ${{ github.event_name != 'pull_request' }}` is the line that matters
most, and it is not the default.** GitHub's ref scoping governs *reads*: a
branch may read its base's cache, which is what lets a PR restore what `main`
saved. It says nothing about writes. Left on the default, every PR uploads its
own multi-gigabyte copy scoped to `refs/pull/N/merge`, two open PRs push the
repo past GitHub's 10 GB budget, and its LRU eviction takes the `main` entry
the whole thing exists for.

**No `gc-max-store-size-*` is set either, which is also not the obvious
choice.** The action collects garbage before saving, and `keep-outputs` does
not rescue you: `nix build` roots its own outputs through `./result` but not
the flake inputs, and a job that only evaluates (`nix eval`, `nix flake check`)
creates no root at all — so a collector run before the save takes exactly the
paths the next run wants. The store is saved whole instead, and each job prints
`du -sh /nix/store` so the creep that buys is readable rather than arriving as
a surprise eviction.

It is on those two repos because that is where it pays:

- `nebelung` builds **whiskers**, a Rust CLI that is not in `cache.nixos.org`
  and that moves only when the lock does, while the palette under it changes
  every PR.
- `haus` evaluates nixpkgs and then *builds* twenty-four check derivations, and
  most PRs touch none of their inputs.

It is **not** on the repos that build their own Swift on a Mac. There the
expensive derivation is the one whose source just changed, so a restore buys
the dependencies and nothing else, and a large `/nix` restore on a macOS runner
can cost more than it saves. Measure before adding it anywhere new.

## What we deliberately don't do

**No third-party runner fleet.** Blacksmith, BuildJet and the rest are free for
open source and genuinely faster per core, but they are x86-64 Linux: they
cannot run a single one of the Xcode jobs, which is where most of the family's
wall clock actually goes. That makes the trade a vendor in the critical path of
every merge, for minutes we do not pay for, on the half of CI that is already
the fast half.

**No hosted binary cache.** Cachix's open-source tier and FlakeHub Cache would
both beat the GitHub cache on a cold store, and both mean an account, a token
in nine repos, and a service that can be down when a PR cannot wait. The
Actions cache is already there, already free, and already scoped per repo.

All three grounds are about a cache we would *rent and push to*, which is what
Cachix's OSS tier and FlakeHub sell. Reading someone else's public cache is a
different trade, and it is allowed: a read-only `extra-substituters` entry
needs no account and no token, and a substituter Nix cannot reach is treated as
absent, so the run builds from source exactly as it does today. It cannot turn
a green PR red, only a fast one slow — which is why "can be down when a PR
cannot wait" does not carry over. The trust question is real but bounded to one
signing key for one path, so name the dependency and the key in the PR.

**No `paths-ignore` on a repo's gate.** This is the denylist, and it is the
opposite of the allowlist `paths:` above: a `paths:` says what one task
workflow is *about*, and a `paths-ignore:` on the gate says which changes the
whole repo will merge unchecked. The second is the one we don't write.

The idea is that a docs-only PR should skip the build. Measured over each
repo's last 40 merged PRs, against the ignore list a filter would actually
ship —

```
docs/**  (except **/SKILL.md)
README.md  AGENTS.md  CLAUDE.md  CHANGELOG.md  CONTRIBUTING.md
SECURITY.md  THANKS.md  FOUNDING.md  LICENSE
.github/ISSUE_TEMPLATE/**  .github/FUNDING*
```

— the share that would skip is haus 1, trill 6, scruff 10, perch 11,
nebelung 12. A quarter at the top of the range, one PR in forty at the bottom,
saving two or three minutes each.

That does not buy what it costs. A filter is a second, silent copy of the
answer to "which files does this job protect?", and the copy rots — that is
`docs/drift.md`'s whole subject. Prose here is *guarded* prose, so the copy has
real work to do and real ways to be wrong: `embed-skills.sh --check`, the two
`check-skills.sh`, the generated issue forms.

The sharp end is `scruff`, and only for one implementation. A `paths-ignore:`
under its `on:` is harmless at a tag — a `workflow_call` invocation does not
evaluate the called workflow's own triggers, so `release.yml` still runs the
full gate. An in-job changed-files filter (`dorny/paths-filter` plus an `if:`)
is evaluated every time the job runs, including that one, so *there* a docs
path can skip a job for a tag that publishes to npm, PyPI and crates.io, none
of which have an undo. If a filter is ever worth it somewhere, it goes on the
trigger, never in the job.

Cache the slow step instead. It helps every PR rather than one in four, and a
cold miss still runs the real gate.

The loose version of this measurement is how the idea keeps coming back. A
classifier that counts `modules/**/*.md` and `dist/**/README.md` as docs says
80%, which for haus is wrong by a factor of thirty. Re-run it against the list
above with `gh pr list --state merged --limit 40 --json number,files`, or don't
quote a number.

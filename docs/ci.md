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
| `haus` | `check` | ubuntu ×2 | evaluating a whole darwin system, plus twenty-four platform-independent flake checks; the shell half is bats and shellcheck |
| `pounce` | `build` | macOS ×2, ubuntu ×2 | the app is built by `xcrun swiftc` through Nix, so it wants a real Mac; the skill guards and the command lint do not |
| `perch` | `build` | macOS ×2, ubuntu | Xcode test + analyze + Release, the arm64 slice guard, and the iOS companion; the skill guards are the one job off the Mac |
| `trill` | `build` | macOS | Xcode test + analyze + Release, and the no-instrumentation guard on the built bundle |
| `scruff` | `check` | ubuntu ×3, macOS ×2 | the acceptance suite on both OSes (occupancy and reflink diverge), five SDKs against one fixture, and `vendorHash` |
| `snug` | `ci` | ubuntu ×3, macOS | the Go width sweeps on both OSes, the bash painter on Linux only (it needs bash 4), and `vendorHash` |
| `nebelung` | `check` | ubuntu ×2 | that `dist/` and `preview/` still equal what the flake renders |
| `factory` | `Tests` | ubuntu | bats over the shift, the tier filter, the watchdog and the lease |
| workshop | `Tests` | ubuntu | `bench` itself — bats plus shellcheck |
| workshop | `issue templates` | ubuntu | that ten repos still match one generator; weekly, because the child half can only be caught by a sweep |
| `hausfold.co` | `Docs`, `Preview`, `Deploy`, `Worker`, the drift jobs | ubuntu | the site builds, and its tables still match the data the layer publishes |

`homebrew-tap`, `org-profile`, `producer-desktop` and `scruff-swift` have no
gate: the first three carry no code of their own that a test could fail, and
the fourth is a generated mirror. `ops` runs a scheduled `scoreboard` and
nothing on a push.

Release workflows are a different animal and are not on this list: they fire on
a `v*` tag, they publish something that cannot be withdrawn, and none of the
speed rules below are worth a risk there.

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
```

`branches: ['**']` fires the same workflow twice for every push to a PR branch
— once as `push`, once as `pull_request` — for one commit and one answer.

**3. Cancel a superseded PR run.** A second push to a branch has already made
the first run's answer worthless, and the abandoned run still holds its
runners. On the macOS ones that is a queue slot the next PR waits behind, which
is most of what a Mac job's start time is.

```yaml
concurrency:
  group: <workflow>-${{ github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
```

Only PR runs cancel. A push to `main` is a distinct commit whose tick someone
may need to read back, and `scruff`'s `check` is called by its release workflow
at a tag, where a cancel would be a half-published release.

`hausfold.co` is the repo that already does all four, and one more besides:
every workflow there carries a `paths:` filter, so a PR that touches no content
runs no content check. That is the rule the rest of the family has the least of
— most of these gates are small enough that a filter would cost more reading
than it saves, but it is the first thing to reach for when one is not.

**4. Pin third-party actions to a tag.** `@main` is whatever that vendor
pushed this morning, running on the machine that compiles what we ship.

## The Nix store cache

`haus` and `nebelung` keep `/nix` between runs with
[`nix-community/cache-nix-action`](https://github.com/nix-community/cache-nix-action),
sitting behind `nixbuild/nix-quick-install-action` — one of the three
installers that action documents itself as compatible with, and the fastest of
them to land.

The key is `flake.lock` plus every `*.nix`, so a lock bump or a module edit
pays full price and nothing else does. The cache is saved on `main` and
restored by PRs: GitHub scopes a cache to the ref that wrote it and lets a
branch read its base's, so a PR never writes one. `gc-max-store-size-linux`
keeps our store well under GitHub's 10 GB per-repo ceiling, so holding it never
evicts another workflow's cache.

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

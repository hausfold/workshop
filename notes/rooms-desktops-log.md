# Rooms and desktops — the status log

Every dated pass on [`rooms-desktops.md`](rooms-desktops.md), in the order it
was written, from the 2026-08-19 re-verification through 2026-08-21's "every
step in this plan now is." It was the note's own preamble until this split —
sitting between the title and §The model, narrating the same build each
step's own section (design → build → findings) already records in full.

**This is a record, not a plan. Nothing here is a to-do.** Each block is what
one session found when it checked a step against the repos: what shipped,
what a probe or a real build cost the design, and which steps were still
unbuilt at the time. Read it when you want the order things actually
happened in, or the day-by-day narrative behind a step's findings section.
Never edit an entry: a dated finding corrected in place stops being evidence.

The acquisition plan's [execution table](rooms-desktops.md#execution-plan)
is the current, unmoved status — A through F, all **done**. This file is
how it got there.

> **Re-verified against merged `main` on 2026-08-19** (haus `6ba56c8`,
> hausfold.co `e9b625f`), and the extension-points finding again on 2026-08-20
> (haus `26422b7`). The model and both execution plans stand; what moved is
> recorded inline — the counts (§[past step 6](rooms-desktops.md#what-carries-past-step-6)), the
> findings now **closed**, one that got *bigger* rather than staler, and one
> whose recommendation was **withdrawn** on re-reading rather than confirmed.

> **2026-08-20 — step E is designed** (haus `ffcdb0a`, hausfold.co `2e4cfd1`),
> and it is the first thing in this note argued from Nix that was actually
> **run** rather than recalled: haus's own desktop validator and the module
> system's collision behaviour, probed directly. Two long-standing claims died
> doing it — see
> §[Step E](rooms-desktops.md#step-e-designed--the-machine-claims-the-namespace-not-a-registry).
> **Step A was built the same day** — `haus show`,
> [haus#428](https://github.com/hausfold/haus/pull/428) — and **E0 was built
> that afternoon**, [haus#429](https://github.com/hausfold/haus/pull/429) plus
> [hausfold.co#107](https://github.com/hausfold/hausfold.co/pull/107): the
> reserved `haus.my.*` prefix, the promise as a check, and a warning naming an
> unregistered `haus.<name>` and every file declaring under it. **Step B landed
> that evening** — [haus#435](https://github.com/hausfold/haus/pull/435) — so
> `haus show` now takes a source as well as a file, with
> [hausfold.co#111](https://github.com/hausfold/hausfold.co/pull/111) beside it.
> C, D, E1 and F are still unbuilt, re-checked at the same dispatch table.
> One of [step A's findings](rooms-desktops.md#findings-carried-out-of-step-a) is a hole in the
> section's trust story rather than in the command: reading a stranger's desktop
> is itself an evaluation, so **the closed schema governs what a desktop can
> declare, and a sandbox governs what reading one can do** — two protections,
> and every step from B on needs the second. Step B found the
> [third](rooms-desktops.md#findings-carried-out-of-step-b): the moment a command fetches, a
> remote party's bytes reach what it prints, and neither of the first two is
> looking at that.

> **2026-08-20, later — step B is designed, and then built.** The design ran
> against Nix 2.34.8 in a cloud container with no Mac and no haus checkout —
> second thing in this note argued from a probe rather than from memory, and it
> cost three claims: the sandbox step A built **cannot fetch**, it does **not
> keep its per-file precision** on anything fetched, and `flake.lock` has
> **never recorded a fetch date** — a phrase this note had carried since
> 2026-08-16. The build then held every rule of it and moved one the other way:
> the act that runs no publisher code is **fetching**, not `flake = false`, so
> `show --room` is inert at a remote source too. It also found the surface this
> section had no name for — **a stranger's bytes reach what the command
> prints**, through Nix's error text and through the desktop's own values alike
> — which is a third protection beside the schema and the sandbox, and one every
> later step inherits. See
> §[Step B](rooms-desktops.md#step-b-designed--fetch-and-read-are-two-acts-and-the-guard-covers-one),
> §[its findings](rooms-desktops.md#findings-carried-out-of-step-b) and
> [`probes/source-shapes.sh`](./probes/source-shapes.sh).

> **2026-08-20, later still — step C is designed, and running the command it
> extends found that `haus show` had never worked on a machine.** The design is
> the third thing here argued from a probe rather than from memory
> ([`probes/machine-diff.sh`](./probes/machine-diff.sh)), and it is the cheapest
> of the three: the module system already exposes the whole arbitration as one
> number per option, so the diff reads it instead of modelling it, and the
> stranger contributes only the option NAMES to the reader's own evaluation —
> never their file, never their values. What it cost was three claims and one
> live bug: a `nix eval` on a consumer flake **writes that consumer's lock**, a
> store path printed out of an evaluation is **a name rather than a location**
> under lazy trees (three evals, three names, none on disk), and the checker path
> `haus show` has shipped with since step A resolved through two symlinks into a
> `restrict-eval` refusal on **every single invocation on a Mac** — invisible
> because the suite runs the packaged wrapper, whose checker is a store path with
> no symlink in it. See
> §[Step C](rooms-desktops.md#step-c-designed--the-machine-answers-and-the-strangers-file-is-not-in-the-room),
> §[what running it first found](rooms-desktops.md#findings-that-arrived-before-the-step-did) and
> §[what building it found](rooms-desktops.md#findings-carried-out-of-step-c). Both halves are
> built: [haus#447](https://github.com/hausfold/haus/pull/447) and
> [hausfold.co#120](https://github.com/hausfold/hausfold.co/pull/120), which
> leaves **D, E1 and F** as the unbuilt ones.

> **2026-08-20, later still — step D is designed, not built.** Read against
> `bootstrap.sh`, `cmd_update` and `settings_write`, not run — the acquisition
> section's "attempt the mechanical edit, verify by re-parsing the result" had
> been standing in for a design since 2026-08-17, and reading the actual
> scaffolded `flake.nix` found it understated by one axis: `add` edits the file
> in **three** places at three syntactic depths (the input, the `outputs`
> binding pattern that makes the input reachable at all, and the `desktop`
> line), not one, and they have to land atomically. The verifier does not need
> inventing — `host-template.nix` already built it, aimed at a generated file
> rather than an edited one, and it is the same `nixfmt`-as-parser trick either
> way. `cmd_update [name]` is not "add an argument" — every local in the
> function today is hardcoded to the literal node `haus`, so it is a rewrite of
> a function that has had exactly one caller since it was written. See
> §[Step D](rooms-desktops.md#step-d-designed--add-edits-three-lines-not-one-and-the-parser-that-catches-it-already-ships).

> **2026-08-20, later still — step D is built** ([haus#450](https://github.com/hausfold/haus/pull/450)).
> The design's own "read, not measured" caveat named the exact gap that
> turned up: a real edit found a bug the design never predicted — a
> single-pass rewrite of the `desktop = ` line had two conditional insertion
> points that could both fire, doubling the line on every second write to a
> file that already had one. `test/haus-add.sh` proves the fix against a real
> `nix eval`: a third-party desktop, pinned offline via `haus add`, actually
> lands its value in the resulting `darwinConfigurations`. **Met for exactly
> one pinned desktop at a time** — a second concurrent `add` degrades to
> `--print` rather than risk a bad edit, a scope cut the design did not flag.
> Docs (`desktops/sharing.mdx`, `customizing.mdx`) are still owed, in
> hausfold.co. See §[findings](rooms-desktops.md#findings-carried-out-of-step-d), which leaves
> **E1 and F** as the only unbuilt steps.

> **2026-08-20, later still — that docs debt is closed, and E1 is built.**
> [hausfold.co#121](https://github.com/hausfold/hausfold.co/pull/121) rewrites
> `sharing.mdx` and `choosing.mdx` around `haus add`/`desktop`/`remove` (not
> `customizing.mdx` — re-read rather than assumed, it never described the
> hand-edit path). [haus#452](https://github.com/hausfold/haus/pull/452) is
> E1's claim table: `haus._rooms.claimed.<namespace> = "<origin>"` turns an
> unclaimed namespace's E0 warning into either silence (declarations agree
> with the claim) or a **fatal** assertion (they don't, or haus has since
> shipped the name) — fatal rather than a second warning, decided before
> writing any code: E0 is a private mistake nobody else is exposed to, E1's
> two cases are the silent-steering hazard the whole design exists to catch.
> **Only the Nix-module half** — `haus add --room` (step F) still doesn't
> exist to write the claim automatically, so it's hand-set for now; see
> §[findings](rooms-desktops.md#findings-carried-out-of-step-e1). **F is the only unbuilt
> step left.**

> **2026-08-21 — F is built, and every step in this plan now is.**
> [haus#457](https://github.com/hausfold/haus/pull/457): `haus add --room
> --namespace <ns>` pins a third-party room the same way `add` already
> pinned a desktop — dropping `flake = false`, wiring the input into
> `mkHaus`'s `extraModules` (a landmark this note's design section had to
> invent; `add` never needed one before, because a desktop's "select" was
> already an argument `mkHaus` took), confirming with a typed revision
> instead of a `y/N` because locking a room already runs its code, and
> writing `haus._rooms.claimed.<namespace>` — E1's own option, reached with
> no new Nix at all, through `cmd_set`'s existing write path. [Designed the
> same session](rooms-desktops.md#step-f-designed--the-confirmation-is-the-lock-and-the-namespace-is-typed-not-evaluated),
> [findings](rooms-desktops.md#findings-carried-out-of-step-f). The rooms-and-desktops
> acquisition model this section opened in 2026-08-16 has no unbuilt row
> left in its [execution plan](rooms-desktops.md#execution-plan).

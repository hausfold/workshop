# Rooms and desktops

Working vision, 2026-08-13. Current code is the source of truth for what exists;
this note defines the product model the code and docs should converge on.

> **Re-verified against merged `main` on 2026-08-19** (haus `6ba56c8`,
> hausfold.co `e9b625f`), and the extension-points finding again on 2026-08-20
> (haus `26422b7`). The model and both execution plans stand; what moved is
> recorded inline — the counts (§[past step 6](#what-carries-past-step-6)), the
> findings now **closed**, one that got *bigger* rather than staler, and one
> whose recommendation was **withdrawn** on re-reading rather than confirmed.

> **2026-08-20 — step E is designed** (haus `ffcdb0a`, hausfold.co `2e4cfd1`),
> and it is the first thing in this note argued from Nix that was actually
> **run** rather than recalled: haus's own desktop validator and the module
> system's collision behaviour, probed directly. Two long-standing claims died
> doing it — see
> §[Step E](#step-e-designed--the-machine-claims-the-namespace-not-a-registry).
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
> One of [step A's findings](#findings-carried-out-of-step-a) is a hole in the
> section's trust story rather than in the command: reading a stranger's desktop
> is itself an evaluation, so **the closed schema governs what a desktop can
> declare, and a sandbox governs what reading one can do** — two protections,
> and every step from B on needs the second. Step B found the
> [third](#findings-carried-out-of-step-b): the moment a command fetches, a
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
> §[Step B](#step-b-designed--fetch-and-read-are-two-acts-and-the-guard-covers-one),
> §[its findings](#findings-carried-out-of-step-b) and
> [`probes/source-shapes.sh`](./probes/source-shapes.sh).

## The model

**haus supplies rooms. A desktop curates them. A host makes one desktop yours.**

| Layer | Owns | Does not own |
|---|---|---|
| **haus** | the module system, room catalogue, shared option types, CLI and safe defaults | a particular person's workflow or taste |
| **room** | one capability, its packages/services, its options and optional integrations with other rooms | whether a particular desktop wants it |
| **desktop** | one complete, data-only selection of rooms and values for their public options | identity, secrets or machine-specific hardware |
| **host** | identity, secrets, hardware facts and personal overrides | reusable upstream opinions |

A person chooses **exactly one base desktop**. They may then enable or disable
rooms and override any room setting in their host. Whole desktops do not stack.

The built-in **blank desktop** is the from-scratch choice: no optional rooms and
no opinions beyond haus's safe foundation. It keeps “build my own” inside the
same one-desktop model instead of making absence of a desktop a second mode.

```text
haus foundation
      ↓
one desktop (blank, haus, …)
      ↓
host overrides
      ↓
machine-written `haus set` overrides
```

Later layers win deliberately. A host must be able to change its desktop with a
plain assignment; it should not need `lib.mkForce` for ordinary customization.

## What a room is

A room is a nix-darwin module with a public `haus.<room>` option namespace. It
may add whatever its capability requires: packages, files, services, defaults,
activation work, assertions and contributions to another room's extension
points.

Every user-visible room has:

- one switch, normally `haus.<room>.enable`;
- a neutral, useful configuration when enabled;
- all of its configurable behavior under its namespace;
- declared requirements, permissions and side effects;
- clean removal when disabled;
- generated metadata for the catalogue and docs.

Generic room defaults are conservative. Keyboard remaps, developer workflows,
personal bar pills and other strong opinions belong to desktops. Enabling a
launcher should provide a working launcher, for example, but a desktop decides
whether it takes over Command-Space.

Not every top-level `haus.*` namespace is a room. The registry classifies every
namespace as one of three kinds:

- **room** — owned by one product room in the catalogue below;
- **shared** — a surface several rooms consume, such as keys, the app roster or
  workspaces;
- **host** — machine/person-specific configuration such as identity.

Classification and desktop safety are separate. Every public option also states
whether desktop data may set it. The answer must be explicit, not inferred from
its namespace: most Pounce settings belong in a desktop, while its signing
identity belongs only in a host; semantic display scaling can belong in a
desktop, while a physical display UUID cannot. Host config may set any public
option. Desktop config is rejected when it reaches a host-only leaf.

Safety is transitive. An `attrsOf` or list-of-submodule option is desktop-safe
only when every reachable sub-option is classified and safe. Freeform attrsets,
`anything`, module values, paths that can import code and strings later executed
as commands default to host-only unless an explicit recursive validator narrows
their payload. A parent marked safe never blesses unknown dynamic children.

The generated reference used to treat every namespace as one of “35 rooms”,
which was an implementation accident rather than a model. Step 1 replaced it
with this registry and per-option desktop metadata, and step 6 taught the
reference to render both — the room a person meets, and the namespace their
host file spells.

## The room catalogue

The intended user-facing rooms are:

| Room | Scope |
|---|---|
| **Apps** | the roster, install sources, App Store policy and file associations |
| **Appearance** | theme, wallpaper, fonts and interface scale |
| **Displays** | resolution and per-display behavior |
| **Development** | terminal, shell, multiplexer, editor, Git, CLI toolbelt and language runtimes |
| **Windows** | tiling, workspaces and window navigation |
| **Bar** | placement, pills and readouts |
| **Launcher** | Pounce installation, daemon, commands and every Pounce setting haus exposes |
| **Shelf** | Perch installation and every declarative Perch setting haus exposes |
| **Focus** | Do Not Disturb, status and hooks |
| **AI** | agent clients, Holt, lifecycle/state wiring, instructions and the haus skill |
| **Text expansion** | snippets and their expansion engine |
| **Security** | Touch ID, lock behavior, firewall and secret-provider policy |

These are product groupings, and since 2026-08-16 they are also the spellings
(see below). Code may stay split into smaller modules where that keeps ownership
clear. The generated catalogue maps those modules and namespaces into the room a
person understands.

### The names (2026-08-16)

The rooms used to be spelled as house and cat words — a code name each, invented
before the catalogue above existed. The catalogue made them redundant and then
misleading: a person met **Bar** in the docs and typed `haus.sill` in their host
file, and every renderer had to carry a translation nobody could infer. So the
namespaces, the module directories and the `darwinModules` exports all moved to
the room's own name:

| was | is | note |
|---|---|---|
| `haus.hearth.*` | `haus.terminal.*` | the Development room's terminal half |
| `haus.prowl.*` | `haus.windows.*` | |
| `haus.sill.*` | `haus.bar.*` | `haus.menuBar.*` is untouched — that one is macOS's own bar |
| `haus.pounce.*` | `haus.launcher.*` | **Pounce is still Pounce**: the app keeps its name, the room that installs it doesn't borrow it |
| `haus.perch.*` | `haus.shelf.*` | same rule — **Perch is still Perch** |
| `haus.hush.*` | `haus.focus.*` | |
| `haus.collar.*` | `haus.security.touchId.*` | folded into the namespace the firewall already had, so the one Security room has one address |
| `modules/den`, `darwinModules.den` | `modules/core`, `darwinModules.core` | never a namespace; the foundation, not a room |

Names a person actually types or sees moved with them — this half is the one a
user feels, and it is not recoverable from the table above:

| was | is |
|---|---|
| the `hush` CLI (`~/.local/bin/hush`, `hush doctor`) | `focus` |
| `sillpop`, `sillvitals`, `sill-bottom` | `barpop`, `barvitals`, `bar-bottom` |
| `~/.config/sketchybar/sill-bottomrc` | `…/bar-bottomrc` |
| launchd `org.nixos.sill-bottom`, `org.nixos.hush-watcher` | `…bar-bottom`, `…focus-watcher` (both booted out once on the migrating rebuild) |
| SketchyBar event `hush_change` | `focus_change` |
| palette command **Toggle Hush** | **Toggle Focus** |
| `HAUS_ROOMS=bar,windows,pounce` (the installer) | `HAUS_ROOMS=bar,windows,launcher` |

Three rules came out of it and are worth keeping:

- **A room is named for what it does; a product is named for what it is.** The
  app in the Launcher room is Pounce and always will be. The room is not.
- **The room leads the copy; the product trails it.** The rename moved the
  addresses in one sweep and left the *prose* behind — for three days haus's
  own option descriptions said "pounce" where they meant the palette, at
  roughly twice the rate the same descriptions said "AeroSpace". The standard
  is the one windows and bar already set: name the app **once**, on the room's
  own `enable` option and on the room's own docs page, and after that use the
  room noun. The product name survives only where it is the literal thing a
  person types, clicks or grants — a CLI verb (`pounce doctor`, `perch add`),
  a path (`/Applications/Perch.app`, `~/.config/{pounce,perch}/themes/`), a
  launchd label or bundle id, the Accessibility row in System Settings, a
  Homebrew formula, a flake input, a package name, or a link into that
  product's own docs tree. Applied 2026-08-19 across haus's descriptions and
  `content/docs/haus/**` (workshop#403): pounce 69 → 19 occurrences in the
  generated option reference, perch 20 → 6. The same sweep found two addresses
  the rename had missed — `darwinModules.pounce` and `pounce.items` — which is
  the argument for doing the copy at the same time as the code: stale prose is
  where stale addresses hide.
- **No aliases.** The old spellings are gone rather than deprecated, for the
  reason the `agents` → `ai` move gives in `haus/modules/moved.nix`: the layer
  has one consumer, its host moved in the same sweep, and an alias set would be
  permanent furniture protecting nobody — while keeping the words in the tree,
  which was the point of the change. `modules/renamed.nix` is unaffected: its
  left-hand sides are the frozen `haus.*` spellings, so
  `haus.sill.position` still resolves, now to `haus.bar.position`.

Development deliberately includes the terminal. A terminal stack with no
development tools is not a distinct user intent in the current product, and
splitting the two makes both rooms explain their shared shell/editor/Git
boundary. AI remains separate: people may develop without coding agents, and AI
has meaningful integrations outside the terminal.

## Rooms cooperate

Rooms may talk to other rooms through explicit extension points. They do not
silently enable each other.

- AI contributes agent lifecycle bindings when Development is enabled.
- AI contributes agent pills when Bar is enabled.
- AI contributes agent commands when Launcher is enabled.
- Windows contributes workspace pills when Bar is enabled.
- Bar requests reserved screen space from Windows when it draws at an
  unreserved edge.
- Focus contributes controls to Bar and Launcher when either is present.
- Appearance supplies tokens; rooms decide how their own surfaces consume them.

The source room owns the feature; the receiving room owns the extension point.
Missing optional receivers remove that presentation without disabling the source
room. A hard dependency must be declared and fail with a message naming both
rooms.

The AI room is the first architecture proof because its present behavior spans
`developer.agents`, `agents.*`, core, terminal/zellij, Bar and Pounce. Turning AI
on should bring the selected clients, Holt and lifecycle wiring. Its Bar,
Launcher and Development additions should appear only when those rooms exist.

## What a desktop is

A desktop is a complete answer to “what should this Mac feel like?” It chooses
rooms and configures their exposed options. haus is the first desktop: its
silver-grey, keyboard-first, developer-focused choices should live in a desktop
definition rather than masquerading as generic module defaults.

A shareable desktop remains data-only and may set only options marked safe for
desktop data:

```nix
{
  haus = {
    development.enable = true;
    windows.enable = true;
    bar.enable = true;
    launcher.enable = true;

    theme.accent = "mauve";
    keys.palette = "cmd-space";
  };
}
```

The exact future option addresses above are illustrative; the trust boundary is
not. The evaluated value has one closed shape: a plain attrset whose only
top-level key is `haus`. A desktop is not a module function, has no `imports` or
`_module`, cannot name `system.*`, `home-manager.*` or activation hooks, and sets
only desktop-safe public `haus.*` leaves. Identity, secrets, account coordinates,
signing identities and hardware identifiers are host-only even when a room uses
them. Structural validation enforces the closed shape before a full host
evaluation proves that the remaining option names and values are valid.

One desktop per host removes desktop-versus-desktop precedence from the user
model. Concerns previously called presets or layers become room-owned profiles
when they remain useful: large print belongs to Appearance, for example. The
Apps room may call a saved app collection a **pack**, but pack is no longer a
peer of room or desktop and does not appear in the top-level journey. Since
2026-08-17 it is not a shareable format either: `haus.lib.pack` and its checkers
are retired, so the collections behind `haus.apps.packs.<name>.enable` are
haus's own data and a stranger's app collection is a **room**. There are exactly
two things a person can publish, and [Acquisition](#two-classes-and-nix-already-spells-the-difference)
is where that lands.

Sources should remain inspectable, typed and pinnable so a later distribution
workflow can identify whether it contains a desktop or executable room code,
preserve its origin and revision, and apply the appropriate trust warning. That
requirement now has a design rather than an open question — nothing of it is
built yet — see
[Acquisition](#acquisition--how-a-desktop-or-room-reaches-a-machine) below,
which supersedes this paragraph's deferral of acquisition commands, manifests
and remote-source UX.

## The user journey

1. Choose a desktop: haus, another published desktop, or Blank.
2. Review the rooms it enables and the visible choices it makes.
3. Add or remove rooms.
4. Tune the options surfaced by those rooms.
5. Add private identity, secrets and hardware details in the host.
6. Preview and rebuild.

The UI and docs should eventually describe intent first and Nix second. “Add the
AI room” is the user action; which modules install Holt, write Codex hooks and
contribute a Bar pill is implementation detail.

## Site and docs

The hausfold.co landing page stays short:

1. hero;
2. a brief haus explanation;
3. desktops;
4. apps and other products;
5. links into docs and source.

The docs teach the selection before the parts:

```text
Start
Desktops
  Choose a desktop
  Start blank
  Customize a desktop
  Create a desktop
  Share a desktop
Rooms
  Apps
  Appearance
  Displays
  Development
  Windows
  Bar
  Launcher
  Shelf
  Focus
  AI
  Text expansion
  Security
Reference
Internals
```

Each room page follows one template: what it adds, enable it, configure it,
works with, permissions and side effects, remove it, options. Theming, Focus,
Touch ID, coding agents, the bar, the shell and window-management guides become
room pages rather than an undifferentiated Guides list.

A desktop's own docs stay thin: its promise, room selection, strong opinions,
install/first run and muscle memory. Generic room behavior belongs to haus.

## Execution plan

Work in order. Each step may become more than one repo-specific PR, but its exit
gate must be green before the next step changes behavior. An agent taking a step
owns it through its report and leaves newly discovered work in **Findings**, not
silently folded into the scope.

The starting inventory is bounded by the current public surfaces:
`haus/flake.nix`'s exported `darwinModules`,
`haus/modules/options-modules.nix`, the generated
`haus/docs/site-data/options.json`, every `modules/*/options.nix`, and every
cross-read matching `config.haus` under `haus/modules`. Record the exact `rg`,
`jq` and `nix eval` commands used rather than substituting an agent's memory of
the tree.

| Step | Status | Work | Durable evidence | Exit gate |
|---|---|---|---|---|
| **0. Baseline** | done | Inventory current implementation modules, exported `darwinModules`, `haus.*` namespaces, enable switches, defaults and cross-room reads. Classify every public export, each namespace as room/shared/host, each leaf as desktop-safe/host-only, and each value as generic mechanism/haus opinion. | Commit `notes/rooms-inventory.md` in the workshop, including the bounded sources, commands and haus revision used to produce it. | The inventory accounts for every public module export and generated option group, and names every behavior that must remain identical during the refactor. Re-running its commands at the recorded haus revision reproduces its counts. |
| **1. Room registry** | done | Expand `haus/modules/options-groups.nix` into the single registry for public-export ownership, room/shared/host classification and per-option desktop safety, without moving or renaming options. Make the host template and docs renderer consume it. | The source registry, regenerated `haus/docs/site-data/groups.json`, and a flake check that fails on an unmapped `darwinModules` export, unclassified namespace, unsafe dynamic subtree or option with no desktop-safety decision. | Every public export, namespace and transitively reachable leaf is classified; current option addresses are unchanged; generated artifacts are current; counts come from the registry rather than prose. |
| **2. AI proof** | done | Make AI the first declared cross-room capability. Move ownership out of `developer.agents` while preserving compatibility; expose contributions to Development, Bar and Launcher through explicit extension points. | A named haus flake check covering AI alone and AI with each receiving room. Pair old and new addresses in fixtures that compare behavioral projections, warnings and plain-host-override priority. | AI alone brings clients, Holt and lifecycle wiring; its optional integrations appear only with their receiving rooms; old and new addresses produce identical behavior and precedence, with the intended migration warning only. |
| **3. Desktop seam** | done | Add exactly-one-desktop selection, source attribution, closed-schema validation, recursive desktop-safety enforcement and host-wins priority. Keep the full compatibility builder selecting haus implicitly. Preserve standalone `darwinModules` imports as Blank plus the explicitly imported room; they do not acquire haus opinions. Do not design remote acquisition here. | A named haus flake check with positive fixtures for one desktop, host override, every supported builder/module entry point and source diagnostics; negative fixtures for two desktops, module functions, `imports`, `_module`, extra top-level keys, `system.activationScripts`, unknown options, unsafe dynamic payloads and every class of host-only leaf. | One desktop is selected through a full builder; a plain host assignment overrides it; a second is rejected clearly; standalone room imports retain their current behavior without requiring a desktop selection; source filenames survive diagnostics; only the closed `{ haus = { … }; }` value reaches option evaluation. |
| **4. Carve out haus** | done | In one atomic change, neutralize generic room defaults, add the real hacker desktop and add the built-in Blank desktop. Keep `mkHaus`, every supported builder/module entry point and old option addresses as compatibility surfaces. | Commit the **projection schema and comparator**, plus the complete non-sensitive example projection. For the real consumer, compare full projections only in an ephemeral directory and commit/report only the equality result—never values, counts, hashes, host paths or serialized output. Add a Blank fixture; run `nix flake check` and `bench try`. PR commands use placeholders/environment variables and redact local paths. | Existing haus example and real-consumer projections compare equal; Blank enables no optional rooms; every prior public entry point passes its compatibility fixture; no consumer-derived values or paths enter git, logs or the PR; there is no commit on `main` where existing installs silently lose a room. |
| **5. Retire top-level fragments** | done | Move `large-print` under Appearance and `writing` under Apps. Keep temporary aliases where consumers need them; remove preset and pack from the top-level product vocabulary. | Compatibility fixtures evaluating old and new spellings to the same values, plus generated migration documentation. | The same configurations remain expressible, migration warnings name replacements, and no docs invite users to stack whole desktops. |
| **6. Rebuild the docs journey** | done | Regenerate the reference from the registry and reorganize hausfold.co around Desktops first, then Rooms. Keep each desktop's own docs thin. | Committed site-data artifacts, `npm run build` in hausfold.co, docs/palette checks, and links or screenshots for the Desktops and Rooms navigation states. | The landing page, docs navigation, generated reference and compatibility docs agree on the model and current option surface. |

Step 4 is deliberately indivisible at the behavior boundary. Neutral defaults,
the haus values that replace them and the compatibility selection must land
together even if preparatory refactors land earlier.

### Findings carried out of step 2

Reported rather than folded into that step's scope, because each one changes
what a LATER step has to do.

- **[3] The AI room defaults to another room's switch.** `haus.ai.enable`
  keeps `developer.enable` as its default, which is the exact "rooms do not
  silently enable each other" violation the model forbids. Step 2 could not fix
  it: a neutral default there is a behaviour change, and the value that replaces
  it belongs to the hacker desktop. It is step 4's, and it is the reason step
  4 is indivisible.
- **[3] The AI room sits in the standalone `darwinModules` foundation.**
  `flake.nix`'s `standaloneModule` imports `modules/ai` beside `core`, `roster`
  and `workspaces`, because a partial that imported only `bar` would otherwise
  draw its agents pill off an unwritten extension point. That is the behaviour
  those exports had before, so nothing regressed — but "Blank plus the
  explicitly imported room" (step 3) has to decide whether Blank carries the AI
  room, or whether an unwritten extension point is simply inert.
- **[2] The AI room's payload still lives in `core` and `terminal`.** Only
  ownership, the assertions and the contributions moved. `holt`, `agent-state`
  and the statusline are still system packages written by `core`; the clients,
  the instructions/skill files and the per-client hook wiring are still home
  ones written by `terminal`. Both are now gated on `haus.ai.enable`. Moving a
  package between a system and a home profile is an install change rather than a
  refactor, so it waits for step 4's projection comparator to prove it moved for
  free.
- **[2] Extension points are not yet the general mechanism.** `modules/lib/contrib.nix`
  and `haus._contrib.*` exist for exactly the three the AI room needs. The other
  cooperations the model names — Windows' workspace pills, Focus's controls,
  Bar's reserved space from Windows — still read each other's config directly.
  Generalising is worth doing on the next room that needs it, not speculatively.
- **[2] `bar`'s `focus` gate is the same shape and not yet on the seam.** The bar
  already special-cases `focus` (`name != "focus" || config.haus.focus.enable`)
  beside the new `contributed` predicate. Two spellings of one idea; folding
  `focus` in is a small, behaviour-preserving follow-up.
- **[1] `zscratch` left the agent switch.** It followed
  `developer.agents.enable` only because that is where the switch lived; nothing
  about a throwaway zellij session is about coding agents. It follows
  `developer.enable` now, beside `nixfmt`.
- **[2] The room took the whole namespace, with no aliases.** `haus.agents.*`
  became `haus.ai.*` and `haus.developer.agents.enable` became `haus.ai.enable`;
  neither old spelling is aliased. The rice has one consumer and its host moved
  in the same change, so an alias set for a five-day-old spelling would be
  permanent furniture bought to protect nobody. The `haus.*` aliases still
  resolve — they were repointed at `haus.ai.*`, since an alias follows its option
  rather than being re-created at every address it passes through.

### Findings carried out of step 3

The seam is built and empty: `mkHaus` selects `desktops/haus.nix`, that
file sets nothing, and the example machine's derivation is byte-identical to the
one before the change (`7q9wfryf…-darwin-system-26.11.57a3171.drv` on both). That
equality is the point — step 4 is then a data change against a boundary that
already works.

- **[2] A desktop currently outranks a pack.** The ladder is host 100 → desktop
  900 → room `mkDefault` 1000, which is exactly right for the two ends. But
  `lib.pack` carries a pack in at 1000, so a desktop also beats a pack the
  consumer explicitly composed into `extraModules` — the more specific statement
  losing to the more general one. Unobservable today (no desktop sets anything),
  so it is left alone rather than fixed blind: moving packs to 850 is one token
  plus a fixture that can actually see the difference, and step 5 is where the
  format vocabulary is settled anyway.
- **[2] There are three shareable formats now, and only one of them is closed.**
  A desktop is validated against the room registry, leaf by leaf, and refuses an
  unknown option before evaluation. A preset and a pack still get `checkRice`,
  which only asks that the top-level key be `haus`, so either may set a
  host-only leaf. That is not a regression — it is the older, looser format
  sitting beside the new one — but "presets" and "desktops" now answer the same
  question with different rules. Step 5 should decide whether a preset simply
  IS a desktop.
- **[2] Some desktop-safety lives in code rather than in the registry.** The
  registry says `haus.displays` is `recursive` with the validator
  `display-selectors`; that a key of `internal` or `main` is safe while a panel
  UUID is not is a rule in `modules/lib/desktop.nix`. Same for the "plain id"
  key rule on roster, workspace and pounce entries. One file, named validators,
  no drift today — but step 6 renders docs FROM the registry, and the registry
  alone would tell a reader that `haus.displays` is desktop-safe without saying
  which keys are.
- **[2] Blank still has to decide about the AI room, and step 3 did not move
  it.** Standalone `darwinModules` imports were kept exactly as they were —
  no desktop, same derivations — so step 2's finding stands untouched: the
  foundation those exports carry includes `modules/ai`, and step 4's Blank has
  to say whether "no optional rooms" includes it or whether an unwritten
  extension point is simply inert.
- **[1] The seam's check is darwin-only.** Half of it is pure lib (the
  diagnostics table) and would run on Linux CI, but it is one check because it
  is one seam, and the behavioural half needs a real evaluated machine. Worth
  splitting only if CI ever needs the fast half alone.

### Findings carried out of step 4

The step landed with the closure provably unchanged, and the interesting part
is what the inventory's "54 haus opinions" turned out to be once each one
was actually moved.

- **[3] "Opinion" was two categories wearing one name, and only one of them
  belongs in a desktop.** A desktop decides which ROOMS it wants and which
  machine-wide CLAIMS it makes (the global hotkeys, the root grant, the desktop
  picture, writing themes into apps the rice never installed). The tuned values
  INSIDE a room — the bar's pills and position, the launcher's `compact`, the
  wallpaper's grain and mark — stayed put, because the model already requires a
  room to be "neutral and useful when enabled" and a bar that is drawn badly is
  not neutral, just worse. The split also keeps retuning to one edit: values
  restated in a desktop drift the first time only one copy is changed. The
  desktop file is ~25 lines because of this, not because anything was missed.
- **[3] Three inventoried "opinions" cannot be carved out at all today, and
  each one is a room that would become BROKEN rather than unopinionated.**
  `fonts.mono.name` must stay a patched Nerd Font or starship, lsd, yazi and
  half the bar render tofu — which family is taste, being patched is a
  requirement. `terminal.editor` is host-only (it is executed) AND the layer
  installs helix unconditionally, so `hx` is what the room ships; a
  desktop-safe enum was written and deleted, because every value in it except
  `hx` named an editor nothing installs. The zellij interaction pair is
  in-room behaviour of a terminal the layer always ships. Step 5 or 6 should
  decide whether a desktop may choose which EDITOR and FONT get installed —
  that is the real fix, and it is vocabulary work rather than a default flip.
- **[3] Only the tuned font SIZE moved, and it needed a new option to move
  safely.** `fonts.mono.size` defaults to `19 * ui.scale`, so a desktop setting
  `size = 19` would have pinned it and silently stopped `ui.scale` — and the
  large-print preset with it — from moving the terminal font, while everything
  else still grew. `haus.fonts.mono.baseSize` carries the baseline instead and
  the scale relationship survives.
- **[3] A room's switch has to be able to REMOVE the room, which an assertion
  cannot do once a desktop is writing the values.** `ai.clients` was guarded by
  "clients are set but the room is off" — correct while the list defaulted from
  the room's own switch, and wrong afterwards: with the desktop naming three
  clients, a host setting `ai.enable = false` got a failed rebuild instead of a
  machine without agents. It resolves through an internal `haus._ai.clients`
  now. Expect the same shape wherever a desktop names a LIST that a room's
  switch is supposed to empty.
- **[2] A fixture can go vacuous the moment a default flips, and nothing says
  so.** `test/desktops/valid-sample.nix` set `bar.enable = false` to prove a
  desktop outranked a `true` room default. Step 4 made `false` the default, so
  the row asserted nothing and would have passed with the desktop seam entirely
  disconnected. It is `true` now. Worth a sweep of the other fixtures whenever
  a default moves under them.
- **[2] `nix fmt` reformats whole files, so it cannot be run casually on this
  repo mid-change.** It rewrote ~700 unrelated lines of
  `modules/terminal/default.nix` around a one-line edit. Format the touched files
  with `nixfmt` directly, or the diff stops being reviewable.
- **[1] The docs asserted layer-wide defaults in prose.** Three guides said a
  room was "on by default" — true of haus, false of `haus` now. Fixed in
  the same change; the generated options reference regenerates itself.

### Findings carried out of step 5

The vocabulary was the easy half. What the step actually surfaced is that
"preset" had been hiding two different things, and only one of them was a
desktop.

- **[3] `everyday` and `minimal` as desktops are not the machines the presets
  produced, and cannot be.** A preset was a LAYER: four lines on top of whichever
  whole rice you had selected, so `presets.everyday` meant "haus, minus the
  developer tooling". A desktop is the complete selection, so the new
  `desktops/everyday.nix` has to state the ~10 values the preset silently
  inherited from haus. One of them changes on purpose: the AI room is OFF
  there, because the preset never mentioned `ai.enable` and inherited a `true`
  that means coding agents on a machine that ships no coding tools. Reported
  rather than hidden — the compatibility ALIAS still produces the old machine
  exactly, so nobody's rebuild changes; only the new spelling differs.
- **[3] Only two of the four fragments were genuine MOVES, and those are the
  ones with a fixture.** `large-print` → `haus.appearance.largePrint` and
  `writing` → `haus.apps.packs.writing.enable` are the same values at a new
  address, so `fragment-compat` evaluates both spellings as whole systems and
  compares derivations. The other two are a vocabulary retirement, and no
  fixture can assert equality for them without asserting the wrong thing. Expect
  the same split whenever a "format" turns out to be two shapes under one name.
- **[2] Adding two public options is not a no-op for the machine, and that is
  worth knowing before the next step reads it as a regression.** The example
  host's derivation moved — `nix-diff` traces every difference to `options.json`
  flowing into the agent skill and the host template, both of which enumerate
  the surface. `desktop-projection` (the step 4 comparator) stayed equal, which
  is the value-level claim. So "the closure changed" and "behaviour changed" are
  now genuinely different questions on this repo.
- **[2] The installer was writing the retired spelling into every new
  machine.** `bootstrap.sh` scaffolded `extraModules = [ presets.$NAME ]`, so a
  fresh install would have landed on a deprecation warning on its first rebuild.
  It emits `desktop = haus.desktops.$NAME` now, `HAUS_DESKTOP` is the
  knob, and `HAUS_PRESET=full` still maps to the hacker desktop. Worth a
  standing habit: grep the installer whenever a public spelling changes.
- **[2] `preset-composition` was a check about a property the model forbids.**
  Its whole subject was "which two presets stack", so it retired with them. Two
  of its rows were not about presets at all — a list-typed option merges
  silently, an `attrsOf` merges per key — and those moved into `fragment-compat`
  intact, because they still bite two packs or two `extraModules` entries. A
  golden table that outlives its subject should be read for the rows that
  generalise before it is deleted.
- **[2] Three shareable formats went to two, and the loose one is now the
  narrow one.** Step 3's finding asked whether a preset simply IS a desktop; the
  answer is yes for the whole rices and no for the layer. What remained was a
  desktop (closed schema, registry-validated, one per host) and a pack (data,
  `haus.roster` only, `checkRice`/`checkPack`). ★ **And then two went to two
  again, differently** (2026-08-17): the pack retired and the ROOM took its place
  as the second format, because rooms were always shareable and three formats
  over two trust classes was one too many. `checkRice` and `checkPack` went with
  it — the observation below, that `checkRice` guarded only pack files, was the
  early sign it had no job left.
- **[1] The docs page is still at `/guides/sharing-a-rice/`.** Its content is
  one-desktop now, but renaming the file would break the URL, and the redirect
  belongs with step 6's navigation reorganisation rather than beside a content
  edit.

### Findings carried out of step 6

The docs turned out to be the place every earlier step's vocabulary went to
die quietly: the pages still said "preset", still told a consumer to reach for
`lib.mkForce`, and still explained how to compose two desktops.

- **[3] The registry knew which room owned a namespace and nothing else.**
  `roomOwners` has mapped every namespace to one of the twelve rooms since step
  1, but no renderer could use it: there was no room TITLE and no room
  sentence, so each consumer would have had to invent both. That is exactly how
  the site came to say "237 options across 35 rooms" over a table of module
  names. The fix is a `rooms` table beside the namespaces, with membership
  DERIVED from `roomOwners` — a second hand-maintained list would drift the
  first time a namespace moved. Two entries in it are not rooms (the shared
  surfaces, and the host's own facts); they carry a `kind` rather than being
  told apart by name in each renderer.
- **[3] "Rooms" and "namespaces" are two different countable things, and the
  docs were counting the wrong one.** Twelve rooms, thirty-six namespaces, 253
  options. A person meets rooms; a host file spells namespaces. The reference
  page renders both — room heading, namespace subheading — because dropping
  either loses something, and every other page now says twelve.
- **[3] Nine guides became room pages, but three rooms had no guide at all.**
  Displays, Shelf and Text expansion were fully implemented and entirely
  undocumented — the gap was invisible while the docs were an arbitrary list of
  guides, and became obvious the moment the navigation had to name every room.
  Expect that shape again: a catalogue-shaped table of contents is what makes a
  missing page a hole rather than an absence.
- **[2] A URL move is one line per page, by hand, in two spellings.** Every old
  `/docs/haus/guides/*` landed somewhere different, so a wildcard could only
  have sent them all to one place. Both the slashed and unslashed forms are
  needed, because the no-slash form only 307s while an `index.html` exists at
  that path.
- **[2] The generator refuses a haus checkout that predates the registry.**
  `gen-options.mjs` errors rather than falling back to namespace grouping, so
  the two PRs have a merge ORDER (haus first) and hausfold.co's `options-drift`
  job stays red until it lands. A silent fallback would have been worse — it
  would render a page that looks right and disagrees with the sidebar.
- **[2] The landing page's section order is a decision, not a gap.** This
  step's plan asks for hero → haus explanation → desktops → apps. The page
  deliberately closes with haus instead, and says so in a comment: that
  ordering "answered *how* before anyone had asked *what*". The model-agreement
  half landed (the Desktops section now says one desktop per Mac, rooms, and
  host-wins); the reordering is 👤's call and is left alone.
- **[1] `/guides/sharing-a-rice/` is finally dead.** Step 5's finding held the
  rename until the navigation moved; it now 301s to `/docs/haus/desktops/creating`
  along with everything else, and its content was split — writing a desktop is
  one page, publishing one is another.

## What carries past step 6

Step 6 closed on 2026-08-14 with haus#344 and hausfold.co#30 merged, so the
plan's six steps are all done and nothing is in flight. Its gate was re-checked
against `main` rather than against the PRs: `options drift` is green on
hausfold.co's `main` after both merges, the sidebar lists five Desktops pages
and then thirteen under Rooms (the twelve, plus the `agent-rebuilds` guide —
see below), `/docs/haus/guides/sharing-a-rice/` 301s,
`/docs/haus/rooms/displays/` and `/docs/haus/desktops/choosing/` are 200, and
`docs/site-data/groups.json` on haus `main` carries 14 registry entries —
twelve `"kind": "room"` plus one shared and one host — over 36 namespaces and
253 options. Every page that states a room count says twelve; that the
reference agrees with haus rather than with a snapshot is what the `options
drift` job guarantees from here on.

**The shape of that gate held; two of its three numbers did not, and the
difference between them is the point.** Re-measured on 2026-08-19 at haus
`6ba56c8`: still **14 registry entries, still twelve rooms**, now **35
namespaces** and **277 options**. So the count that a person meets is the one
that stayed put, and the counts a host file spells are the ones that move every
week — which is why step 6 was right to render both and right to generate them.
Nothing in this note is expected to track the two moving numbers; they are
recorded here once, with their revision, so the next reader compares against a
dated measurement rather than against prose. The `options drift` job is what
keeps the *site* honest, and it is doing it: the reference has been regenerated
since ([hausfold.co#77](https://github.com/hausfold/hausfold.co/pull/77)).

One row of that gate is worth restating because it reads as a contradiction:
`/docs/haus/rooms/agent-rebuilds/` **301s to `/docs/haus/agent-rebuilds/`** now.
The finding below predicted a guide sitting in the Rooms group; it was moved out
instead of relabelled, so the Rooms prefix holds exactly the twelve rooms plus
`rooms/creating` — and the sidebar's Rooms band is thirteen rows for that reason,
not for the old one.

The plan therefore has no step 7. What follows are the findings from earlier
steps that no step ever owned, **re-verified against merged `main` on
2026-08-19** — the dates in each bullet say when a claim was last actually
looked at, rather than when it was written. Each is a standalone change; none of
them blocks another.

**Three more closed on 2026-08-19, in one pass, and the pass itself is the
finding.** Two of the three ([haus#410](https://github.com/hausfold/haus/pull/410)
with [hausfold.co#86](https://github.com/hausfold/hausfold.co/pull/86), and
[haus#413](https://github.com/hausfold/haus/pull/413)) turned out to rest on a
premise that was **false at the code** — the options reference did not name a
validator, and the bar no longer spelled its gate three ways. Neither finding
was wrong about what to build; both were wrong about the world they described,
because they were written against a repo that then moved. A finding here has a
half-life measured in weeks, so **re-read the code before acting on one, and
treat its evidence as a hypothesis rather than a fact** — the three dates in
each bullet below are there for exactly that. What survives re-reading is the
*recommendation*; what rots is the *measurement*.

- **[3] Nothing owned "may a desktop choose the editor?" — ANSWERED, 2026-08-14
  ([haus#347](https://github.com/hausfold/haus/pull/347),
  [hausfold.co#34](https://github.com/hausfold/hausfold.co/pull/34)).** Step 4
  handed this to "step 5 or 6" and neither took it. Half of it had resolved on
  its own: `haus.fonts.mono.name` and `.packageName` are `desktopSafe: true` in
  the merged registry, so a desktop could already name a font family — the
  patched-Nerd-Font rule is a requirement at the option, not a trust boundary.
  The editor half got exactly the room-owned enum this finding predicted:
  `haus.terminal.editorName` (`helix` | `neovim` | `vim` | `nano`, default
  `helix`) is the desktop-safe half and the one that INSTALLS something, while
  `terminal.editor` keeps its type, its host-only classification and the last
  word — it just defaults to the chosen editor's command now. (Both shipped
  under `hearth.*`; they are spelled `terminal.*` here because the room was
  renamed two days later — see [the names](#the-names-2026-08-16).) Two things
  from doing it outlive the change: **the enum had to move four things at once
  and three of them fail silently** — the package, `$EDITOR`, the Nebelung theme
  file, and whether the room claims the `helix` port for `haus doctor` — which
  is why it ships with a `nix flake check` derivation (`editor-choice`,
  `flake.nix:2557`) that reads all four back off evaluated machines rather than
  a type and a hope. And **`bootstrap.sh` was scaffolding the wrong half of the
  pair**: it offered `hx/nvim/vim/nano` and wrote `editor`, so a fresh machine
  answering `nvim` got `$EDITOR=nvim` and no neovim installed. That is step 5's
  own finding — grep the installer whenever a public spelling changes — hitting
  for the second time in a week, which makes it a habit rather than a
  coincidence.
- **[2] ✅ A desktop still outranks a pack the consumer composed themselves —
  closed 2026-08-17 by retiring the pack.** Verified in merged `flake.nix` at
  the time: `desktopPriority = 900`, while `lib.pack` carried its file in at
  per-leaf `mkDefault` (1000). Step 3 left it alone as unobservable and it still
  was, but only by luck — `desktops/hacker.nix` sets no `haus.roster`, so the
  first desktop that named an app would silently have beaten a pack the host
  explicitly imported. It was briefly fixed with a `packPriority = 500` rung,
  and then the rung went away with the format
  ([haus#386](https://github.com/hausfold/haus/pull/386)). The full story is in
  [Acquisition](#open-decisions).
- **[2] ✅ Closed 2026-08-19 — the rule moved next to the name, and the finding
  was wrong about where the name is rendered.**
  [haus#410](https://github.com/hausfold/haus/pull/410) adds a `validators`
  table to the registry carrying one sentence per validator, exactly the move
  this finding predicted, with `room-registry` holding three lists in step:
  what `recursive` NAMES, what `modules/lib/desktop.nix` IMPLEMENTS, and what
  `validators` EXPLAINS. Only the third is a genuinely new failure mode — a
  name nothing implements already fails closed at evaluation, but a validator
  with no sentence renders as a bare word and nothing goes red.
  [hausfold.co#86](https://github.com/hausfold/hausfold.co/pull/86) is the
  other half, and it had to build the surface the finding assumed existed:
  **the options reference did not name the validator, or state desktop-safety
  at all.** `groups.json` shipped the classification and no renderer read it;
  the only rendered site was the `# desktop data:` line in a generated host
  file. So the site PR renders both — 43 host-only rows and 11 per-key ones out
  of 305 — and `desktops/creating` points at it instead of being the only
  statement.

  Three things out of doing it:

  - **A finding can be right about the fix and wrong about the world.** "The
    generated reference names a validator" was the premise; it did not. Closing
    it properly meant building the naming first, which is a bigger change than
    the "cheap fix" line promised and a better one — the classification a
    desktop author most needs was, until now, reachable only by `jq` over
    `groups.json`.
  - **A hardcoded reason is worse than none.** The site's first draft printed
    one sentence under all 43 host-only rows ("names a person, a secret or a
    piece of hardware"); it is false on about 30 of them — every
    `haus.locale.*` and `haus.power.*` leaf, and the several that are host-only
    for taking a `pkgs` value or a command the machine runs. The per-option
    reason belongs in the registry beside `desktopSafe`, the way the validator
    rule now sits beside its name. ✅ **Closed 2026-08-20** —
    [haus#420](https://github.com/hausfold/haus/pull/420) with
    [hausfold.co#95](https://github.com/hausfold/hausfold.co/pull/95): `hostOnly`
    maps each path to a reason key, `hostOnlyReasons` gives each key one
    sentence (twelve over 43 rows as it shipped; **thirteen over 44 at
    `ffcdb0a`** — the table grows with the surface, which is the point of it),
    `room-registry` fails on a row with no
    reason or a sentence nothing names, and all three renderers of the
    classification say the same thing — the generated host file, the options
    reference, and `checkDesktop`'s diagnostic, which had been telling a desktop
    author that a font package "belongs to a person or a machine".

    **The sweep is where the bug was, and the reason table is what exposed it.**
    `git` looked homogeneous enough to tag whole, so all five `haus.git.*`
    leaves got "it names you rather than a machine" — including
    `git.shellAliases`, an attrset of shell command strings that names nobody.
    Writing a reason down is what made the wrong one legible; the pre-PR
    assurance pass caught it, and `locale` and `power` are the two namespaces
    where the whole-namespace sweep is actually true. The check can see a
    MISSING reason and never a wrong one, which is the residue to remember when
    a leaf is added to a swept namespace.
  - **Two diagnostics for one fact still beat one that is bent to serve both.**
    `desktop.nix`'s `keySaid` messages are phrased to complete "…names a
    physical display"; the registry's sentence describes the rule. The check
    requires both to EXIST rather than to match, because folding them into one
    string makes either the error or the sentence clumsy.
- **[2] ✅ Closed 2026-08-19 — the AI room's payload moved, and the derivation
  did not.** Carried since step 2, which deferred it until a comparator could
  prove it free; `desktop-projection` has existed since step 4 and the proof is
  simply a derivation comparison — `nix eval` on the example host returns the
  two profiles **set-identical** to `main` — 39 system packages and 97
  home-file paths, evaluated on each branch and diffed — with the only
  derivation delta being three input SOURCES, each a repointed comment. Both halves went: the system
  profile (`holt`, both statusline scripts, `agent-state`) out of `modules/core`,
  and the home one (the instructions preamble, the `haus` skill, `agents/`) out
  of `modules/terminal`. What terminal keeps is its own — the client packages a
  pane needs on PATH, the dotfiles it themes, and the two activation blocks that
  merge into a client's user-editable JSON.

  Three things worth keeping out of doing it:

  - **The reason it looked expensive was wrong, and one throwaway line proved
    it.** The obstacle was assumed to be `home-manager.users.<name>`: terminal
    owns that attrset, so a second module writing one user's profile sounded
    like a merge waiting to happen. It is not — home-manager merges the two
    `home.file` sets, and a collision on a path is an **error**, not a silent
    last-wins, which is the property that makes the split safe rather than
    merely possible. Measured with a probe `home.file` from `modules/ai` before
    anything moved. The first draft of this move shipped a header comment
    asserting the opposite; the probe is what caught it. **Measure the
    constraint before designing around it** — this one had held the work for two
    weeks and was never true.
  - **The move is mechanical, and its risk is entirely in the `let`.** The three
    blocks that moved (`agentHomes`, `holtGuidance`→`agentSkillFiles`, and
    `onOff`→`thisMachine`) are a closed dependency set except for one string:
    `laneChordProse`, which reads as terminal's because it names a keybind but is
    prose *inside the generated agent instructions*. Nix names the failure
    immediately, so this is a compile error rather than a silent one — but it is
    the reason to move a `let` cluster by evaluation rather than by eye.
  - **The evidence was blind to the one thing that actually broke, and the
    check meant to protect it was testing the wrong shape.** `modules/ai` named
    `hostname` in its argument set for ONE row of prose — and it sits in
    `standaloneModule`'s shared foundation, so that made `hostname` mandatory
    for every `darwinModules.*` export: a consumer importing
    `darwinModules.windows` got `attribute 'hostname' missing` from the tiling
    module. Every proof above goes through a full builder, which always has a
    `hostname`, so none of them could see it — and neither could
    `standalone-modules`, whose whole job is the bare-import surface but which
    evaluated through a helper that passes the builders' args. The assurance
    subagent caught it (4/5); `terminal` and `launcher` turned out to have had
    the same latent bug all along. **Behaviour-neutral for the consumer you
    measured says nothing about the consumers you didn't** — and a check is only
    worth its name if it is shaped like the caller it defends.
  - **A comment can move the derivation, and on this repo that is not noise.**
    Repointing two prose references from `terminal/agents/` to `ai/agents/`
    changed the system drv, because `host-template.jq` is an input SOURCE — its
    hash covers its comments. Reverting that one comment restored the baseline
    exactly, which is how the "free" claim above was isolated. Step 5 already
    found that adding an option is not a no-op here; the sharper form is that
    **any file the host template or the skill reads is behaviourally live, down
    to its comments.**
- **[2] ✅ Closed 2026-08-19 — the bar's gate went from three sites to two and
  then to a declared point.** The finding named three sites; a change that was
  not about it had already folded them to two, and
  [haus#413](https://github.com/hausfold/haus/pull/413) replaced both with
  `_contrib.bar.focus`. The history is kept because each step taught something
  different.

  **The shrink, and why the finding's own evidence rotted.** The three sites this finding named — `contributed`, a
  `name != "focus" || config.haus.focus.enable` clause in `bottomGroup`, and
  `topFocus` — no longer exist as three. [haus#404](https://github.com/hausfold/haus/pull/404)
  opened the pill surface up as `haus.bar.widgets`, and in doing so folded the
  per-bar pair into one `contributed` predicate
  (`modules/bar/default.nix:1035`), whose own comment records the collapse:
  “Same gate, said once now instead of per bar.” What survives is a
  different pair, one layer apart rather than one bar apart — `contributed`
  (1041) decides whether a pill may be drawn at all, and `wanted` (1553), in the
  block that pre-declares every bundled pill as a widget, decides whether the
  sugar asks for it. Both read `config.haus.focus.enable` directly, because
  Focus has no switch in `bar.items` and never did.
  Two lessons, and the second is the one to keep: an open surface can absorb a
  duplication that no one set out to pay off — and a finding that names LINE
  NUMBERS as its evidence goes stale in the ordinary course of unrelated work,
  so the durable half of a re-check is the predicate's NAME, not its address.

  **The close, and the three things doing it turned up.** haus#413 gives Bar
  `_contrib.bar.focus` and Launcher `_contrib.launcher.focus`, and Focus writes
  both — so the same change closes this finding and the direct-config-reading
  half of the one below it, as predicted.

  - **A refactor that is behaviour-neutral is worth proving that way.** The
    example host's `drvPath` came out byte-identical to base with focus **on**
    *and* with it **off**. Two directions, not the one the fixture happens to
    enable — the on-path alone would have proved nothing about the gate.
  - **Removing a read can reveal that nobody was watching the other end.**
    Bar's gate comment has always said the bar drops a room-less pill and "the
    source room warns by name"; only the AI room ever did. Focus had no
    warning, and this change is what made the silent path reachable from
    desktop data, because it advertises `widgets.focus.enable = true` as
    something a desktop may write. The warning had to go OUTSIDE the room's own
    `mkIf` — **a room that only speaks when it is on cannot tell you it is
    off** — which is a shape worth reusing wherever one room's absence is
    another room's dead feature.
  - **An attrset option's KEYS may belong to a different file than its
    declaration, and that is invisible from a full builder.** The first draft
    of that warning read `config.haus.bar.widgets.focus.enable`. The bundled
    pills are keys bar's *implementation* writes; a standalone
    `darwinModules.focus` imports every room's `options.nix` and one room's
    implementation, so it had the attrset and no `focus` key, and the read
    threw `attribute 'focus' missing`. `standalone-modules` caught it — the
    same check that missed the `hostname` bug in the AI move, and catches this
    one because it has since been reshaped like the caller it defends. The
    general form: **`config.<x>` existing as an option says nothing about
    `config.<x>.<key>` existing on the machine you are on.**
- **[2] Extension points are still only the ones a concrete room needed — six
  now, and the Focus pair is the first the mechanism was reached for on
  purpose (re-checked 2026-08-19).** The AI room's original three
  (`_contrib.development.agents`, `_contrib.bar.agents`,
  `_contrib.launcher.agents`) were joined by `_contrib.launcher.mouseChords` —
  Windows contributing INTO Launcher (`modules/windows/default.nix:563`), the
  first use by a room other than AI — and now by `_contrib.bar.focus` and
  `_contrib.launcher.focus` ([haus#413](https://github.com/hausfold/haus/pull/413)),
  the first in the RECEIVING direction from a non-AI room. ⚠️ An earlier
  revision of this bullet counted `_contrib.windows.agents` as the fourth: it
  does not exist and has not since the lane chord became pounce's own ⌘↵
  (`modules/ai/default.nix` says so where it names the chord). The count was
  wrong, not merely stale — a reminder that a number in this file is only as
  good as the grep behind it.

  So the "generalise on the next room that needs one" judgement has now
  survived a room reaching for it rather than growing into it, which is the
  stronger test.

  ⭐ **Re-read at 26422b7 on 2026-08-20, and the survivors turned out to be
  three DIFFERENT shapes — only one of which `_contrib` fits.** The
  recommendation this bullet carried — "ONE point declared by Bar for a room
  that wants a pill drawn or a bar poked" — is withdrawn. It was built on the
  three reads being one idea, and reading them again says they are not:

  - **A query, not a contribution.** Bar asks Windows "is there a tiler?" —
    twice, in one generated file: `BAR_GRAVITY` and `BAR_PAGES` in
    `windowsConfigSh` (`modules/bar/default.nix:1117`). The bullet used to
    place this read in the `contributed` predicate, and that is no longer
    where it lives: [haus#422](https://github.com/hausfold/haus/pull/422) took
    `page` out of the widget table entirely — a page is a property of the
    WORKSPACE you are on, so its readout moved beside the workspace pills in
    the hand-written left group. Second time this bullet's evidence has rotted
    under unrelated work, in the same place, which is the argument for naming
    a mechanism rather than a site.
  - **Not a reach at all, on inspection.** `windows/default.nix:333` passes
    `config.haus.bar` whole — into `modules/lib/gaps.nix`, a shared arithmetic
    file that takes the bar's position and height as ARGUMENTS. And it has two
    callers: `wallpaper/default.nix` passes the same `bar` down to
    `render.nix`, so the debug band lands under the tiled window rather than
    beside it. That is the same shape as `lib/bar.nix` and `lib/keys.nix` — a
    surface both rooms consume, with one owner of the numbers — and it is
    working. Replacing it with an extension point would put a seam where the
    invariant is "these two must agree".
  - **A query again.** Focus's watcher reads `config.haus.bar.enable` /
    `.bottom.enable` to decide which bars to poke, twenty lines under the block
    that contributes to those same rooms.

  `_contrib` carries a PAYLOAD from a source room to a receiving room's
  declared point; the receiver owns the point, the source owns the feature.
  Two of the three above carry nothing and have no source — they ask whether
  a room EXISTS, which is a question about the machine rather than an offer to
  another room. So the thing they want is not a fourth, fifth and sixth
  `_contrib` point but a room publishing its own SHAPE: one read-only fact per
  room (is it on, which edges does it occupy) that any other room may read
  without knowing that room's option surface. Whether that is worth building
  at all is a fair question — `config.haus.<room>.enable` is already that fact,
  spelled with no ceremony — and the honest reading is that the direct read is
  fine for a query and `_contrib` is right for a contribution. The mistake was
  filing all three under one heading. **[2] stands; the recommendation is now
  "leave the queries alone", not "declare one more point".**
- **[2] ✅ Closed 2026-08-19 — the org/layer split settled the landing-page
  order, and 👤 said so.** The finding asked whether the page should run hero →
  haus explanation → desktops, per step 6's plan. It is moot: the site separated
  the org from the layer, so `/` is hausfold (`src/app/page.tsx`, an index of
  what the org publishes) and `/haus` is the layer (`src/app/haus/page.tsx`),
  where the Rooms and Desktops sections moved word for word — Rooms, then
  Desktops, then One file. The step-6 ordering was written for a page that
  explained the layer *and* sold the org in one scroll; splitting them answered
  the question the ordering was a compromise for. **No reorder is wanted.** The
  general lesson is worth more than the row: a layout argument can be settled by
  changing what the page is ABOUT rather than by resequencing it, and a finding
  that survives long enough may be dissolved rather than resolved.
- **[1] ✅ Closed 2026-08-19 — `/docs/haus/rooms/agent-rebuilds/` is no longer in
  the Rooms group.** The guide moved to `/docs/haus/agent-rebuilds/` (in the
  Start band, beside `install` and `keeping-it-current`), and the old URL 301s.
  The Rooms prefix now holds the twelve rooms plus `rooms/creating`, which is a
  room page in the sense that matters — it teaches you to write one.

Two earlier findings are NOT in that list, and both deserve a sentence rather
than a silent disappearance. Step 3's "Blank still has to decide about the AI
room" is **closed**: `desktops/blank.nix` is `{ haus = { }; }`, step 4 made
`haus.ai.enable` default `false`, and `flake.nix`'s `standaloneModule` comment
now says why `modules/ai` stays in the foundation — an unwritten extension point
is inert, so Blank carrying the module costs nothing. Step 3's "the seam's check
is darwin-only" is **still true and deliberately dropped**: splitting the pure
half out is only worth doing if CI ever needs the fast half alone, and it never
has.

### Agent status report

Every agent working a step reports back in this shape while work is live:

```text
Step: <number and name>
Status: not started | in progress | blocked | ready for review | done
Changed: <repos and the bounded outcome>
Why: <the need this step addresses>
Verified: <commands run, durable evidence path and observable result>
Findings:
- [impact 1–5] <new fact> — <consequence and recommendation>
Watch-outs: <risks, fragile boundaries and deliberately deferred work>
Decisions needed: <only unresolved items at impact 3–5, with a recommendation>
Next: <the next concrete action or the next plan step now unblocked>
```

The PR body keeps the repository-wide contract: **What** comes from Changed,
**Why** from Why, **Verify** from Verified, and **Watch-out** from Findings plus
Watch-outs. Do not paste the status line or Next action into the PR as substitute
headings.

“Done” means the exit gate is proven and its evidence is committed or linked,
not merely that a diff exists. A blocker names the failed gate and the evidence;
it does not expand the step. Findings at impact 1–2 may be resolved in scope when
reversible. Findings at 3–5 are reported with a recommendation before they
change the architecture.

## Acquisition — how a desktop or room reaches a machine

Design of record, 2026-08-16, grounded in haus `387e8a2` and the consumer flake
this machine actually runs. This is the item
[`go-to-market.md` §5](./go-to-market.md#5-the-gallery--marketplace-question--answered)
hands over when it says a third-party gallery entry now waits on “acquisition
and trust, not composition”, and the item `options-roadmap.md`'s status prologue
points at the same place.

> **Still nothing, re-checked 2026-08-19 at haus `6ba56c8`.** Verified at the
> CLI's own dispatch table rather than by grep: `modules/core/haus.sh`'s `case`
> knows `rebuild update rollback generations status edit options set get unset
> reset plan diff capture revert-settings doctor btm tour`, and none of `show`,
> `add`, `remove` or `desktop`. `haus update` also still takes no input-name
> argument (`update) cmd_update ;;`), so step D's one-line extension is unbuilt
> too. Every number and mechanism in this section was measured against a haus
> three days older than today's, and the parts that could have rotted did not:
> `checkDesktop` is still the entry point (`flake.nix:241`), `desktopPriority`
> is still 900 (226), and `lib.pack` is still gone with a comment at 203 saying
> why. **One thing did move, in the design's favour:** `/docs/haus/rooms/creating/`
> now exists and teaches a person to write a room, so the room half of step F
> has published documentation to point at — and step E's namespace question is
> now a hole in a page a stranger is being sent to, not a hypothetical.
>
> **Still nothing again, re-checked 2026-08-20 at haus `ffcdb0a` (the
> `2026.08.20` tag).** Same dispatch table, same four missing verbs, `update)
> cmd_update ;;` unchanged; `checkDesktop` is still the entry point and
> `desktopPriority` still 900. What did move is the surface under it — 35
> namespaces and **311** options, up from 277 yesterday, over the same twelve
> rooms. Two claims in the paragraph above did NOT survive being read
> at the code rather than summarised: the `rooms/creating` sentence is corrected
> in [step E's design](#step-e-designed--the-machine-claims-the-namespace-not-a-registry),
> and so is this note's long-standing account of what a namespace collision
> actually does.
>
> **And then step A was built, the same day** —
> [haus#428](https://github.com/hausfold/haus/pull/428) with
> [hausfold.co#104](https://github.com/hausfold/hausfold.co/pull/104), open at
> the time of writing. Both paragraphs above are true of haus's `main`, which is
> the revision immediately before it: `haus show <file>` reads a local desktop
> or room file and reports what it is. B through F are still nothing, and the
> design below is unchanged by building A — `haus.sh`'s dispatch knows `show`
> beside the eighteen verbs it had, and still none of `add`, `remove` or
> `desktop`. What building it turned up is
> [Findings carried out of step A](#findings-carried-out-of-step-a); one of them
> is a hole in this section's trust story rather than in the command, so read
> that one before B.

### The finding that decides the shape

**A haus machine is already a flake, so the pin store already exists.** The
consumer the bootstrap scaffolds — and the one on this Mac — is:

```nix
inputs.haus.url = "github:hausfold/haus";
outputs = { haus, ... }: {
  darwinConfigurations.mbp = haus.mkHaus {
    username = "…"; hostname = "…"; host = ./hosts/mbp;
    desktop = haus.desktops.hacker;      # written by bootstrap.sh when named
  };
};
```

`flake.lock` already records, per source: the origin as typed, the resolved
revision, a content hash, and the source's own last-modified date. (⚠️ This
sentence said “a fetch date” until 2026-08-20, and
[step B measured otherwise](#what-the-lock-records-and-the-one-word-this-note-had-wrong)
— `lastModified` is the commit's date, and **nothing** in a lock records when
you pinned it.) `nix flake update <name>` already
updates exactly one of them. The store copy already makes a rebuild work
offline. Every requirement the model states for a shareable source —
inspectable, typed, pinnable, origin-preserving — is a property `flake.lock`
has today, for free, on a file the consumer can read.

So **acquisition invents no manifest, no second lockfile, no registry index and
no fetcher.** `haus add` is a command that writes a flake input and a selection
line. That is the whole mechanism, and the reason to prefer it over anything
richer is not economy — it is that a second pin store can disagree with
`flake.lock`, and the one that wins is the one nobody is reading.

### Two classes, and Nix already spells the difference

A desktop is data; a room is code. That distinction has to survive all the way
into the machine's own files, or a person auditing their config a year later
cannot tell which strangers they trusted with what. It does, without being
invented:

| | **desktop** | **room** |
|---|---|---|
| what it is | a closed `{ haus = { … }; }` value | a nix-darwin module |
| how it arrives | a **non-flake** input (`flake = false`) | an ordinary flake input |
| what evaluates | nothing from the source — Nix hands over a path | the source's own `outputs` function, then its module |
| `flake.lock` records | `"flake": false` on the node | no such field |
| checked before use | `haus.lib.checkDesktop` — closed schema, registry-validated, leaf by leaf | nothing; a module may do anything a module may do |
| what it may do to the Mac | set desktop-safe `haus.*` leaves at priority 900 | install packages, write files, run activation scripts as root |
| the prompt it earns | a **diff** of what your machine becomes | a **warning** about what code can do |

`"flake": false` in the lock is not a convention we would be adopting — it is
what Nix writes, and it is exactly the typed origin the model asked for. A
person can answer “did I ever give a stranger code?” with `jq` over their own
lock file.

### The three source shapes, measured

Verified against real Nix on 2026-08-16, and re-measured on a real `flake.lock`
on 2026-08-20 ([`probes/source-shapes.sh`](./probes/source-shapes.sh) §3–4):

| source | input spelling | pins | selection line | notes |
|---|---|---|---|---|
| **a repo** (recommended) | `{ url = "github:ada/writer-desktop"; flake = false; }` | `rev`, `narHash`, `lastModified` — and, on the `git+https:` spelling, `ref` and `revCount` too. ⚠️ **The `github:` node itself was not measurable** from the cloud container the 2026-08-20 pass ran in (api.github.com 403s); it carries `owner`/`repo` where the `git` node carries `ref`/`revCount` | `desktop = "${inputs.writer}/writer.nix";` | the publisher's repo needs **no `flake.nix`** — the boring three-file repo `desktops/sharing.mdx` already recommends is exactly the right shape |
| **one file / a gist's raw URL** | `{ url = "file+https://…/writer.nix"; flake = false; }` | **`narHash` only — no revision and no date** | `desktop = inputs.writer;` | the store path *is* the file, so no path suffix. But there is no version to move between, so `haus update` on it silently follows whatever is at that URL now — and [prints a line that reads like a no-op](#the-revisionless-shape-is-worse-than-no-changelog) while doing it |
| **a gist as a repo** | `{ url = "git+https://gist.github.com/ada/<id>"; flake = false; }` | rev (a gist is a git repo) | as the repo row | ⚠️ **partly verified since 2026-08-20**: a real remote `git+https://` source locks to a full `rev`/`revCount`/`ref` node, so the *mechanism* is measured. What is still unverified is gist hosting specifically |
| **vendored** (today's advice) | none — a path in your own config | nothing | `desktop = ./desktops/writer.nix;` | stays supported forever, and is the right answer when you intend to *edit* it. See the git gotcha below |

**The selection line is a bare path, and that is not cosmetic.** `mkHaus`
applies the seam itself — `riceLib.desktop desktop` — so its `desktop` argument
takes the same shape `haus.desktops.<name>` has, a path. A pre-wrapped
`haus.lib.desktop …` passed there is wrapped twice and throws at `import`, and
`flake.nix` says why the wrapping lives at the seam rather than in the export:
a pre-wrapped module “would look importable anywhere and quietly bypass the
one-desktop assertion”. `haus.lib.desktop` is for the hand-composed case only,
where it goes in `extraModules` beside `desktop = null;`. Whatever `haus add`
writes, it writes the bare-path form.

Two measured facts the design leans on:

- **`checkDesktop` and `lib.desktop` accept a string store path and preserve
  it.** `nix eval` on the flake with a `"/…/writer.nix"` string returned
  `{"ok": true, "file": "/…/writer.nix"}` — so the `_file` a conflict message
  names is still the real source, and a third-party desktop needs no new
  evaluation machinery at all.
- **A `file+https` input lands in the store as a regular file, not a
  directory** (`.r--r--r-- root nixbld 1.5K …-source`), and `checkDesktop`
  takes it directly. ⭐ Since 2026-08-20 that is also a **security** property
  rather than a convenience: the guard's unit is the store path, so the shape
  whose store path *is* one file is the only shape that cannot read anything
  beside it — see [step B](#the-guards-granularity-changes-in-the-store).

### What acquisition deliberately does not get

- **No manifest.** Anything a manifest would carry (name, author, tested
  revision, which file is the desktop) is either already in the lock or belongs
  in a README a human reads. A manifest the tooling trusts is a second thing to
  keep honest, and it is *publisher-authored*, so it is the one input a trust
  boundary should not be reading facts from.
- **No `haus search`, no index, no gallery API.** Discovery is
  `hausfold.co/#desktops` and a GitHub topic. `go-to-market.md` §5's “don't
  build the store first” argument is unchanged, and a search command whose
  index ships inside the haus flake would tie every gallery addition to a haus
  release.
- **No new fetcher.** If Nix cannot fetch it, `haus add` cannot add it. That
  keeps the offline story, the hash story and the proxy/CA story identical to
  the one `nix flake update haus` already has.
- **No composition.** One desktop per host is settled and is not reopened by
  making desktops easier to obtain. `haus add` of a second desktop *replaces*
  the selection line; it never stacks. The `haus._desktop.sources` assertion
  stays the backstop for the hand-composed case.

### The commands

Four new verbs and one extension. Every one of them is bounded by two rules:
**acquisition never activates**, and **anything the tool cannot verify, it
prints instead of writing.**

```text
haus show <source|file>   inspect — fetch, validate, diff. Writes nothing.
haus add <source>         pin + select. Edits flake.nix + flake.lock. No rebuild.
haus desktop [name]       list what this machine has; switch between them.
haus remove <name>        unpin + reselect explicitly. No rebuild.
haus update [name]        existing command, now takes an input name.
```

**`haus show`** is the load-bearing one and the only one that is also useful to
a *publisher*. Given a remote source it resolves and fetches it; given a local
path it just reads it. Then it prints, in order:

1. where it came from and what it locked to (origin as typed, resolved rev, and
   the date the SOURCE was last changed — not the date you fetched it, which
   [nothing in the lock records](#what-the-lock-records-and-the-one-word-this-note-had-wrong))
   — or, for a `file+https` source, that there is neither a revision nor a date
   of any kind;
2. **the class**: “a desktop — data only, and haus checked it” or “a room —
   this is code”;
3. `checkDesktop`'s verdict, and on failure every diagnostic with its
   filename, which is what makes this the publisher's pre-share check;
4. **what your machine becomes**: rooms turned on and off relative to your
   current config, machine-wide claims (global hotkeys, default browser,
   wallpaper, Caps Lock), and every list-typed option it sets — because a host
   naming that list replaces it whole, which is the one interaction a reader
   cannot infer from either file alone;
5. what it does *not* set, so the reader knows what stays theirs.

**Built, as of 2026-08-20: 1, 2, 3 and 5.** 1 arrived in two halves — the
local-file half with step A (a local file has no origin and no revision, and
`show` says so rather than leaving the line out) and the remote half with step
B, which also split the one date into two, since [the source's is not the
fetch's](#what-the-lock-records-and-the-one-word-this-note-had-wrong) and only
one of them is recorded anywhere. 4 is step C, and its slot is marked in the
script so it extends the frame rather than reinventing it.

`haus show --json` for CI, per `notes/agent-surface.md`. That single command
collapses the first line of the publish checklist in `desktops/sharing.mdx`
(“`checkDesktop` prints `true`, and a real host evaluates”) and removes the
need for a separate `haus check`. It does not touch the second line — “you have
run it on a Mac” is not a thing a checker can assert.

**`haus add`** does `show`, asks for confirmation, then writes the input, the
selection line and the lock — and stops, printing `haus rebuild` as the next
step. Splitting acquisition from activation is what lets `show` be honest and
what keeps `add` reversible with a text edit. `--print` emits the lines instead
of writing them, `--as <name>` sets the input name, `--file <path>` picks the
desktop when a repo holds several, `--vendor` copies the file into the
consumer's config instead of pinning it.

**`haus desktop`** with no argument lists the built-ins plus every desktop this
machine has pinned, marking the selected one; with a name it rewrites the
selection line. It is the cheapest form of “select” and “what do I have”, and
it needs no network.

**`haus remove <name>`** drops the input and relocks. See the rule below about
what it must write in place of the selection.

**`haus update <name>`** extends today's `cmd_update`, which reads
`.nodes.haus` out of the lock and already knows the input name is the
consumer's to choose, not ours.

### The prompts, which are not the same prompt

For a **desktop**, the schema has already proven the file cannot run code, so a
danger warning would be theatre and would train people to click through the one
that matters. (⚠️ The proof is about what the file DECLARES. Reading it is still
an evaluation, and an evaluation can read files and fetch URLs — so every command
here evaluates a stranger's source inside the sandbox step A built, and the
absence of a warning is earned by that guard rather than by the schema alone.) The prompt is a *diff*: this is what turns on, this is what turns
off, this is the hotkey it claims, this list of yours it replaces. haus already
has `cmd_plan` and `cmd_diff` to build it from.

For a **room**, nothing is checkable and the prompt should say so without
hedging: this is code from `<origin>` at `<rev>`, it runs during activation as
root, and haus cannot tell you what it does. It requires an explicit `--room`
(never inferred from what the source contains, because inference is how a data
prompt gets shown for a code source), and a typed confirmation rather than a
y/n. Non-interactive use needs a per-name environment variable, so a piped
installer can never accept a room on a person's behalf — the same reasoning as
the `curl|bash` tty rules.

**Rooms are in scope, not deferred** (👤, 2026-08-17 — this paragraph used to
say phase 2, and it was wrong). Retiring the pack format is what settles it: a
stranger's app collection is a room, so rooms are no longer the exotic case but
the *only* way to share anything smaller than a machine. The room path is the
same command with `flake = false` dropped, plus the code prompt above.

What that makes load-bearing, and was not while rooms were deferred: **nothing
arbitrates a top-level `haus.<name>.*` namespace.** haus's own `room-registry`
check catches an unclassified namespace in *haus's* flake check, which never
runs on the consumer, and no other rule anywhere is looking. The extension-point
mechanism has since grown a fourth point and its first non-AI user, which is
progress on the *cooperation* half but none at all on this one.

⚠️ **The two paragraphs that used to follow here — what a collision does, and
what the published `rooms/creating` page does to the sequencing — were both read
at the code on 2026-08-20 and both were wrong.** They are replaced by
[step E's design](#step-e-designed--the-machine-claims-the-namespace-not-a-registry),
which measures the three collision cases instead of asserting one, and finds the
live exposure somewhere other than where this section had been looking for it.

### Rules that fall out, and the traps behind them

- **`add` and `remove` never rebuild.** They print the command.
- **`remove` must write an explicit replacement, never just delete the
  selection line.** `mkHaus`'s `desktop` argument defaults to
  `./desktops/hacker.nix`, so deleting the line does not return the machine to
  neutral — it silently installs the opinionated developer desktop. `remove`
  asks, and defaults to `blank`.
- **A vendored file must be `git add`ed.** Nix cannot see untracked files in a
  git-tracked flake, so `curl -O … && mv … ~/.config/nix/desktops/` — the exact
  sequence `desktops/sharing.mdx` recommends today — produces “path does not
  exist” at eval, on a file the person is looking at. `--vendor` stages it;
  the docs page should say so regardless of whether `add` is built. ✅ **The
  docs half closed 2026-08-20** —
  [hausfold.co#96](https://github.com/hausfold/hausfold.co/pull/96) puts the
  `git add` on all three pages that tell someone to vendor a file. Two things
  found doing it: the recipe failed one line EARLIER still (`bootstrap.sh`
  creates `hosts/<hostname>` and never `desktops/`, so the `mv` has no target),
  and **`checkDesktop` cannot catch this** — it reads the path it is handed, so
  it passes on the very file the rebuild cannot see. That last one is the
  argument for `haus show` doing the check from the machine's point of view
  rather than the file's.
- **Editing `flake.nix` is the one genuinely fragile part**, and it is the
  first thing in haus that would edit a hand-written file rather than write a
  generated one (`haus set` writes whole modules under `hosts/<h>/settings/`).
  The rule: attempt the mechanical edit, verify by re-parsing the result, and
  on any mismatch with the scaffolded shape restore and print the lines to
  paste. A hand-reorganised consumer flake is normal and must degrade to
  `--print`, not to a broken machine.
- **Input names are the namespace, and `haus` is reserved.** Derive from the
  repo name minus a `-desktop`/`-haus` suffix; on a collision, refuse and name
  `--as`. There is no second registry to keep in step, and
  `nix flake update <name>` already addresses exactly this namespace.
- **Offline**: `show` and `add` need network and say so; everything after them
  does not. A rebuild from a locked third-party desktop is as offline-capable
  as a rebuild from haus itself.
- **`haus update` on a `file+https` source silently follows head.** There is no
  revision to compare, so the changelog half of `cmd_update` has nothing to
  show and the pin moves on content hash alone. `show` and `add` both warn at
  the point the source is chosen, which is the only point where switching to a
  repo source is cheap. ⭐ **Measured 2026-08-20, and it is worse than
  "nothing to show":** Nix's own update line for a `file` node is one arrow,
  one URL and no hash, while the content underneath has changed. The warning this
  shape earns is therefore not "there is no changelog" but "**your update line
  will look like a no-op**", and `cmd_update` should print the narHash pair
  itself for a `file` node, since it is the only field that moves and Nix will
  not show it.

  ⭐ **Re-measured 2026-08-20 on Nix 2.33.0, and the shape is one notch
  different from what the probe reported.** There IS a left-hand side; both
  sides are the same URL, byte for byte:

  ```text
  • Updated input 'rawFile':
      'file:///…/writer.nix'
    → 'file:///…/writer.nix'
  ```

  And when nothing moved, Nix prints **no update line at all** — so "identical
  to what it prints when nothing moved", which this note said until now, was
  never right either. The probe's row only grepped for a line starting with the
  arrow, so it saw the last line of a three-line block and reported the side it
  had not asked for as missing; the note then wrote down what the probe could
  see. That is the failure mode of a measured claim rather than an argument for
  going back to recalled ones: **a probe that greps one line out of a multi-line
  block measures the grep.** The user-facing conclusion is unchanged and slightly
  sharper — an arrow with the same string on both ends is a stronger "nothing
  happened" signal than a line with one end missing.

  ✅ **The probe caught up the same day.** It reads the whole block now, and
  carries the two rows this claim always needed beside it: a `git` node's two
  ends **differ** (so the two-sided form really is informative everywhere else),
  and a second update with nothing moved underneath prints **no line at all**
  (so silence, not sameness, is what a true no-op looks like). Six rows where
  there were two, and nothing left in the tree saying the old thing.

### Step B, designed — fetch and read are two acts, and the guard covers one

> ✅ **Built the same day** — [haus#435](https://github.com/hausfold/haus/pull/435).
> The design survived intact and the command is the shape below: fetch outside
> the guard, read inside it, report the source's date as the source's and stamp
> the fetch. What the build added is
> [its own findings](#findings-carried-out-of-step-b), two of which matter here:
> a *correction upward* — the inert act is fetching rather than `flake = false`,
> so `show --room` stays honest at a remote source too — and a surface this
> section had no name for. A stranger's bytes reach the report, through Nix's
> error text **and** through the desktop's own values, which carry `ESC` past
> `toJSON` untouched. The second one had been there since step A and only became
> dangerous when the input started arriving from a stranger.

Designed 2026-08-20 against **Nix 2.34.8** (Determinate 3.21.9), from a cloud
container with no macOS and no haus checkout — nothing built at the time of
writing; the banner above is what happened next. Every row
below is a row of [`probes/source-shapes.sh`](./probes/source-shapes.sh), which
builds throwaway git repos in a `mktemp` dir and runs real `nix eval` and `nix
flake lock` against them — 24 rows in seconds, no Mac; `PROBE_REMOTE=` adds two
more over a genuine remote source.

⚠️ **It measures Nix, not haus.** `share/haus/desktop-check` is not reachable
from the workshop, so these are claims about the *mechanism* `haus show` stands
on, not about the command. Nothing here claims a rebuild outcome, and nothing
here was read off haus's own script. Rerun it on a Nix bump: the granularity
rows are evaluator behaviour, which is exactly what a release moves. (The
command that now stands on it was built and tested against **Nix 2.33.0** on
macOS, i.e. an *older* evaluator on a different platform, and every row that
matters to it reproduced — so these claims have now held across two Nixes and
two OSes rather than one of each.)

#### The guard cannot fetch, and the fetch cannot be guarded

[Step A's finding [4]](#findings-carried-out-of-step-a) left the sandbox as the
thing every later step inherits — "B fetches a stranger's source and evaluates
it… each has to use the same guard". The first measurement is that the guard
does not stretch that far:

```text
error: access to URI 'git+file:///…?ref=main' is forbidden in restricted mode
```

`builtins.fetchTree` under `allowed-uris = ""` is refused **by URI**. That is the
guard working rather than failing, and it means `haus show <source>` is two acts
that cannot be folded into one:

1. **fetch** — unguarded, network, and **no publisher code runs** *for a
   desktop*. A fetch is a `git clone` or an HTTP GET; nothing in a
   `flake = false` source is evaluated to perform it. The expression that does
   it must therefore be a literal `fetchTree` over the URL the user typed and
   must import nothing. (⚠️ This is a property of `flake = false`, **not of
   fetching** — see [step F](#and-step-f-cannot-borrow-it) below.)
2. **read** — guarded exactly as step A reads a local file, with the fetched
   store path as the allowed path. No network is needed and `allowed-uris` stays
   empty, because there is nothing left to fetch.

This is a better story than step A's, not a compromise on it: reaching the
network and running the file become separate acts, and neither can quietly do
the other's job. It also answers B's exit gate structurally — **fetching needs
no consumer flake at all** (measured: `fetchTree` returns a store path when it is
run from a directory holding no `flake.nix` and no lock — nothing about the
consumer is read to perform it), so "still writes nothing to the consumer" is a
property of the mechanism rather than of care taken.

One shape detail worth a comment at the call site, because the first person to
read it will try to delete it: **both acts must be `--impure`.** `fetchTree` on
an unpinned ref is refused in pure mode, and `--restrict-eval` only ever
*subtracts* — pure mode already forbids every absolute path outright, so the
guarded form of "read this one file" is necessarily `--impure --restrict-eval`.
Turning one protection off to turn the intended one on looks alarming and is
correct.

#### The guard's granularity changes in the store

Step A's rule is "exactly two paths named — the checker's own directory and the
ONE file being read, **not its parent**, because a stranger's file in
`~/Downloads` must not be able to read the rest of it." Measured, that rule is
exactly right — and only outside the store:

| allowed path | the desktop reads | verdict |
|---|---|---|
| `~/…/peek.nix`, outside the store | its sibling `NOTES.txt` | **blocked** |
| `~/…/`, the parent dir | the same sibling | allowed — which is the rule's own reason for existing |
| `$src/peek.nix`, **inside the store** | its sibling `NOTES.txt` | **allowed** |
| `$src/writer.nix`, inside the store | a *different* store path | blocked |
| `$src/writer.nix`, inside the store | `/etc/hostname` | blocked |

Naming a file inside the store allows its whole **store root**. So step A's
per-file precision silently widens to per-source-tree the moment the file
arrives by fetch — which is every source shape step B adds.

**That is acceptable, and it still has to be written down.** What it opens up is
the publisher's own repo: Ada's desktop can read a file Ada shipped beside it.
What it does *not* open is the consumer — another store path is blocked, and
everything outside the store is blocked — and that was the load-bearing half.
But this note has been describing a property ("the ONE file") that the mechanism
only delivers in the local case, and a guard believed to be tighter than it is
is precisely the kind of thing a later step builds on. The durable form:
**`restrict-eval`'s unit is the store path, not the file.**

Two consequences. The `file+https` shape, whose store path *is* a single file,
is the only one that gets the tight guarantee — an accidental virtue of the
shape this note otherwise warns about. And a repo desktop can `readFile
./anything` out of its own tree, so a value `show` prints is not necessarily
written in the file a reader is about to review: wherever `show` attributes a
value, it should name the **source tree**, not the file.

#### What the lock records, and the one word this note had wrong

[The finding that decides the shape](#the-finding-that-decides-the-shape) has
said since 2026-08-16 that `flake.lock` records "the origin as typed, the
resolved revision, a content hash, and **a fetch date**". Measured on a real
lock, the fourth is wrong:

| shape | lock node's `locked` fields |
|---|---|
| `git` (repo, local or remote) | `lastModified`, `narHash`, `ref`, `rev`, `revCount`, `type`, `url` |
| `file` (raw URL) | `narHash`, `type`, `url` — **that is the whole node** |

`lastModified` is the **source's** timestamp: it matched the fixture repo's
committer date exactly — that equality is the pinned row, and it is the whole
claim, since a value that IS the commit's date cannot also be a record of the
fetch. The remote row asserts the weaker, non-racy form (the source's date
predates the fetch) and prints the gap: 149 seconds on the run this was written
from. Nothing in a lock file records when you pinned anything.

Mostly that is harmless, and once it is not. For a repo source the date `show`
can print answers "how stale is this thing" rather than "how old is my pin" — a
better question, differently phrased, and `show` should label it as the source's
date rather than inheriting this note's word for it. For the raw-URL shape there
is no date **on either reading**, so the shape that most needs "when did I take
this" is the only one that cannot answer it. `show` and `add` must stamp that
date themselves, from the clock, or say plainly that there isn't one.

(`"flake": false` on the node survived the re-measurement unchanged, on both
shapes — the typed origin the model asked for is still there for free.)

#### The revisionless shape is worse than "no changelog"

Measured, and it belongs beside [the rule it sharpens](#rules-that-fall-out-and-the-traps-behind-them):
`nix flake update` on a `file` node prints an arrow with the same URL on both
ends, no rev and no date, while the content underneath changes. It is not a
missing changelog — it is a line that reads as *confirmation nothing moved*, to
anyone who knows the two-sided form from every other input, where the two ends
differ.

> This section said "one arrow, one URL, no left-hand side" until 2026-08-20,
> because the probe's row grepped the arrow line out of a three-line block.
> [The re-measurement](#rules-that-fall-out-and-the-traps-behind-them) has the
> real output and the lesson; the probe now reads the whole block, checks both
> ends against each other, and pins the two contrasts that make the claim mean
> something — a `git` node's ends differ, and a genuine no-op prints nothing.

#### …and step F cannot borrow it

The two-act split above rests on a fetch being inert, and that is true of a
desktop because a desktop is `flake = false`. A **room** is an ordinary flake
input, and locking one **evaluates the publisher's `flake.nix`** to discover its
own inputs. Measured, with a room whose `inputs` attrset throws:

| the same source, pinned as | `nix flake lock` |
|---|---|
| a room (an ordinary flake input) | **evaluated it** — the throw fires at lock time |
| a desktop (`flake = false`) | **inert** — locks clean, the file never read |

So for a room there is no unguarded-but-harmless fetch phase to hide behind:
**pinning a room is already running its code.** Two things follow for step F,
and neither is in its row yet.

The code prompt — "this is code from `<origin>` at `<rev>`, haus cannot tell you
what it does" — is owed **before the lock**, not merely before the rebuild. A
design that fetches first and prompts second is fine for a desktop and is
already too late for a room.

And `--room` skipping the evaluation, which is [step A's rule](#findings-carried-out-of-step-a)
("you have said it is code, and evaluating it anyway to say so is the one thing
this command must not do"), cannot extend to `haus add --room`: adding it means
locking it, and locking it evaluates it. `show --room` can stay honest; `add
--room` cannot, so its prompt has to say that pinning is itself the first
execution rather than implying the rebuild is.

#### What B settles about C and D

- **C's naive shape is the thing the guard exists to prevent.** The obvious way
  to diff a stranger's desktop against your machine is one evaluation with both
  in its allowed set — which hands a stranger's file your config directory. The
  split that works is B's, one act further: fetch, then **read the stranger's
  file under the guard down to a plain data value**, then diff *that value*
  against your machine in a second evaluation the stranger's file is not part
  of. Three acts, and the stranger participates in exactly one.
- **D's `--vendor` changes which guard applies.** Copying the file out of the
  store into the consumer's config moves it back to per-file granularity, so the
  same desktop is read under a tighter guard after vendoring than before. Worth
  a fixture, because it is the sort of asymmetry found by accident otherwise.
- **B needs no new trust vocabulary.** The prompts, the classes and the
  no-inference rule all survive; what B adds is a fetch phase in front of the
  read step A already built, and a store path where a local path used to be.

### Step E, designed — the machine claims the namespace, not a registry

Designed 2026-08-20 against haus `ffcdb0a` (the `2026.08.20` tag) and
hausfold.co `2e4cfd1`. What changed is that the three failure modes are
**measured** rather than assumed — and one of them turned out not to need
acquisition at all, which moves the step rather than merely sharpening it.

★ **E0 was built and merged the same day** — [haus#429](https://github.com/hausfold/haus/pull/429)
(`mergedAt 2026-08-20T10:27:25Z`) and its docs half
[hausfold.co#107](https://github.com/hausfold/hausfold.co/pull/107) (nine seconds
later). The design below stands as written except where the build corrected it;
what the build learned is in [Findings carried out of step E0](#findings-carried-out-of-step-e0).
**E1 is still unbuilt**, and the sentence it needs to make true is the one E0
could not: a machine running a legitimately published room has nothing recording
where the room came from, so it warns.

**How these were measured, because it decides how far to trust them.** From a
cloud session with no macOS and no way to build a machine: nixpkgs' `lib/`
sparse-cloned, haus's own `modules/lib/desktop.nix` and
`modules/options-groups.nix` imported directly, and each collision run through
`lib.evalModules`. Both files are pure — `desktop.nix` takes `{ lib, registry }`
and the registry is data — so this is haus's **real** validator over its real
registry, not a model of it. What is *not* measured here is anything needing a
darwin system, which is why nothing below claims a rebuild outcome.
What made `lib` reachable is a `--depth 1 --sparse` clone of nixpkgs' `lib/`
directory, 15 MB and seconds, handed to the probe as an argument — not the
flake, which still resolves `github:NixOS/nixpkgs` and still 403s exactly as
[AGENTS.md](../AGENTS.md) warns. Separately worth knowing, and not in that
warning: `git+https://github.com/…` **does** resolve in a cloud container, so
the 403 is api.github.com rather than GitHub. ✅ **That is in AGENTS.md's cloud
bullet now** (2026-08-20), re-verified independently while designing step B,
which needed the same fetch path and would have been unmeasurable without it.

All of it is re-runnable, and every row of the design below is a row of its
output: [`probes/namespace-collision.nix`](./probes/namespace-collision.nix).
Re-run it before acting on any of this; the measurements have the half-life this
note keeps recording, and the probe is what makes checking cheaper than
trusting. (The one claim quoted here that its JSON does *not* carry is the
duplicate-declaration message — `tryEval` catches the throw and Nix hands a
catcher no message. The probe header says how to read it.)

#### Three collision cases, and the note had the wrong one

This note has said since 2026-08-17 that two rooms claiming one namespace
"collide as a raw module-system option-declaration error naming neither
publisher". Half right, and the wrong half is load-bearing:

| two rooms declare | what the module system does |
|---|---|
| the same leaf, both fully described (`type` + `default` + `description`) | **throws** — ``The option `haus.photography.enable' in `/nix/store/aaa…-source/photography.nix' is already declared in `/nix/store/bbb…-source/photography.nix'`` |
| the same leaf, one of them bare (`type` only) | **merges, silently** |
| **different leaves under one namespace** | **merges, silently** |

The third row is the ordinary case and the dangerous one. Probed: Ada's room
declares `haus.photography.enable`, Ben's declares `haus.photography.catalog`
and sets `haus.photography.enable = true` in his own `config`. It evaluates
clean. `options.haus.photography` holds both leaves, `enable.declarations` names
only Ada's file, and **Ben's line is steering Ada's room** with nothing on the
machine saying so. So the real failure mode is not a loud error that names the
wrong thing — it is **silent co-ownership**, and the loud error is the lucky
case. A rule that only prevents exact-leaf collisions prevents the case that
already fails loudly and misses the one that never does.

The throw, when you get it, names **store paths**. That is worth restating as a
cause rather than a complaint: `_file` *cannot* name a publisher, because an
input's origin is gone by the time it is a file in the store, and `flake.lock`
is the only thing on the machine that still knows. Any diagnostic that names
who to blame has to be written by the thing holding the lock — which is `haus
add`, not the module system.

#### The hazard is not gated on step F, and `rooms/creating` is why

The 2026-08-19 revision said the published `/docs/haus/rooms/creating/` "raises"
this, because a stranger following it gets no arbitration. Re-read at
`2e4cfd1`, that is wrong in the way this note keeps catching: the page's own
callout scopes it — *"If the answer is only ever going to run on your Mac, write
a plain module in your own config and stop reading. Everything below is about a
room that lands in `hausfold/haus`."* A room that lands in haus **is**
arbitrated, by `room-registry`. The page invites nobody to publish
`haus.photography.*` to strangers.

It does something else, though, and it is sharper. It teaches the shape with
`options.haus.kettle` throughout, and then offers "keep it in your own config"
as the escape hatch — so the natural thing a reader does is keep the namespace
they were just taught, under `haus.`, on their own machine, with no stranger
and no `haus add` anywhere in the story. And `kettle` is drawn from the same
well as haus's own thirty-five: `sound`, `power`, `lock`, `zen`, `tour`, `keys`,
`git`, `focus`. **The collision that is live today is with a future haus
release, on a machine that never installed anything from anyone.** Step F
creates a second, worse case; it does not create the first.

That reorders the step. "Before D's room half" was the sequencing; the honest
one is **before the next haus release that adds a namespace** — which is most
of them: 35 namespaces and 311 options at `ffcdb0a`, against 35 and 277
measured one day earlier.

#### E0 and E1, because only one of them is about acquisition

- **E0 — a promise and an assertion, buildable now.** haus reserves a prefix it
  will never ship a room under, `rooms/creating` teaches the escape hatch to use
  it, and one assertion on the consumer's machine says so when it doesn't. No
  new command, no lock format, nothing from steps A–D. This is the half with
  live exposure. The prefix to argue about is **`haus.my.*`**: it reads right in
  the file it appears in (`haus.my.kettle.enable` says whose room it is), and it
  is a word haus can promise never to ship because it would be a strange name
  for anything. Whatever is chosen is reserved permanently, and `checkDesktop`
  keeps refusing it for the reason it already does — a private room is by
  definition not the thing a shared desktop may name.
- **E1 — the claim table, which only means anything once `haus add --room`
  exists.** Two strangers, one namespace, a machine that has to decide which of
  them meant it. Keep it sequenced before F, as before.

#### The design: the machine writes down who it believed

There is no central register, for the same reason there is no gallery API:
whoever runs it becomes a dependency of every rebuild. Instead the **consumer's
own machine** records the claim, in the one file that already knows origins.

`haus add --room github:ada/photo-room` writes, beside the input and the
selection, one line:

```nix
haus._rooms.claimed.photography = "github:ada/photo-room";
```

and refuses — naming both origins, which it can, because it is holding the
lock — if `photography` is already claimed by something else. First-come is
settled **per machine, at add time, in writing**, rather than globally by
anybody.

Then one assertion in haus's own foundation, evaluated on the consumer's Mac
rather than in haus's flake check. Probed against `lib.evalModules` and it does
what it says:

```text
haus: the namespace `haus.photography` is declared by
/nix/store/aaa…-source/photography.nix but no input claimed it.
```

It reads the **merged** option tree, so it sees every module the machine
actually has, including a private one, and subtracts the registry's 35 and the
claim table. It is the first check in haus that fires where the damage is.

🚨 **And the first draft of it accused a stock machine.** Deriving the namespace
list as "`attrNames options.haus`, minus the `_`-prefixed internals" reads like
the rule `room-registry` uses. It is not: `room-registry` filters on
`internal`/`visible`, and `mkRenamedOptionModule` leaves a hidden
`haus.claude.*` behind (`modules/moved.nix`), so the shorthand reports an
unclaimed namespace on a machine that has installed nothing from anyone — and
cannot even name the file, because the leaves it would name are invisible.
Measured both ways (`stockMachineNaive` vs `stockMachine`, `[ ]` once it
derives the surface the way haus already does). **A check that fires on a stock
machine is worse than no check**, and the general form is the one to keep:
*reuse the surface derivation, never a paraphrase of it* — the paraphrase was
three words shorter and wrong.

The file it names comes from walking **every leaf** under the namespace, not
from `<ns>.enable.declarations`: only 9 of haus's 35 namespaces have an
`enable` leaf at all, so keying on it would name a file for a quarter of them
and print `?` for the rest. That walk is also exactly what E1 needs for
co-ownership, so the two checks are one traversal.

Three cases fall out of that one mechanism:

- **an unclaimed namespace** (the private-room case) → named, with every file
  that declares under it, and fixed by moving to the reserved prefix or by
  writing the claim;
- **two claimed rooms, one namespace** → refused at `add`, by origin, before
  either is ever evaluated;
- **haus ships the name later** → the namespace is now in the registry *and* in
  the claim table, which is a contradiction the assertion can state in one
  sentence naming the release and the origin — instead of a
  duplicate-declaration throw naming two store paths, or, worse, a silent
  merge.

The silent-co-ownership row is caught by the same walk, one level down: gather
`declarations` across every leaf under a claimed namespace and assert they share
one store root. Two roots is Ben steering Ada's room, and it is detectable
exactly because `declarations` keeps both — measured above.

⚠️ **What the probe cannot tell you** is what this costs on a real machine.
`options` is an ordinary module argument, and the assertion forces the merged
declaration tree, which a full darwin evaluation is doing anyway — but "anyway"
is a claim about evaluation order, and this note has been wrong about a
constraint it reasoned about instead of measuring before. Build E0 against a
real host and read the eval time before deciding it is free.

#### What this settles about a desktop depending on a stranger's room

The trailing open decision — a third-party desktop cannot name a third-party
room's options, because `checkDesktop` refuses any leaf the registry has never
heard of (measured: `haus.photography is not a haus option`) — has an answer
that costs no new machinery, and the probe is what proves it. **A room ships its
own registry fragment**, and the seam merges it in:

```text
without a fragment:  haus.photography is not a haus option
with one:            haus.photography.hook is host-only, so a shared desktop
                     may not set it. It is a shell command this machine runs,
                     and a desktop is a file you can read to know what it does.
                     A leaf carrying a command is exactly what stops that
                     being true.
```

`modules/lib/desktop.nix` is already parameterised on `registry`, so this is a
merge at the call site and **not a single line changed inside the validator**.
Two details the probe turned up:

- **The reason table extends for free, in both directions.** That second
  sentence is haus's own, inherited: the fragment names one of the thirteen
  existing `hostOnlyReasons` keys (`runs-a-command`) and gets its prose. Name a
  key haus has never heard of and `hostOnlyWhy`'s fallback prints the generic
  sentence instead — no evaluation error, so a room that ships no reason table
  of its own still works. That fallback was written for a consumer pinned to an
  older registry; it turns out to be exactly the extension point a third-party
  fragment needs. A defensive default written for one reason was the mechanism
  for another — worth remembering before deleting one as dead.
- The fragment is **publisher-authored input to a trust surface**, which is the
  one class [the metadata decision](#open-decisions) kept out on purpose. The
  distinction that makes it fine here is worth stating flat: **that rule is
  about DATA.** A room is code you already granted root; a publisher who could
  lie in their classification could simply do the thing instead. So the
  classification is trusted exactly as far as its own code already is — and no
  further, which is the enforceable half: **a room's fragment may classify only
  paths under the namespace it claimed.** Drop the rest at the merge. Otherwise
  Ada's room re-classifies `haus.security.*` and Carol's desktop writes it.

#### Findings carried out of step E0

Four, from building it. Two are about the design being underspecified in ways
only a build could show; two are about the build itself, and both were caught by
the pre-PR assurance read rather than by the author.

- **"The assertion" and "it does not refuse" cannot both ship.** The design above
  says *assertion* eleven times and then says, under what E does not get, that E0
  "asserts and explains; it does not refuse". In nix-darwin an `assertion` is
  fatal, so the two sentences describe different features. The exit gate is what
  decided it — a person is *told*, and their machine still builds — so it is
  `warnings`. Worth keeping as a shape: a design can carry a word from the probe
  that measured it (`claimAssertion`) into a sentence about what to build, and
  the word quietly becomes a requirement nobody chose.

- **A message for the private case is wrong advice for the published one.** The
  first build said "move it under `haus.my.`", which is right for a room somebody
  wrote for themselves and wrong at every rebuild for a room somebody
  *installed* — a published room is supposed to hold a plain `haus.<name>`, and
  `desktops/sharing` says so. E0 has no claim table to tell them apart, so the
  text names the shared risk and splits only on the remedy. The gate's "nobody
  else is told anything" is therefore met for a stock machine and unmet for a
  consumer of a published room; E1 is what closes it, which is a sharper reason
  to build E1 than the one recorded above.

- **A new `modules/lib/` import can break the CLI without touching it.** The
  reserved prefix is defined once, in `modules/lib/namespaces.nix`, and
  `desktop.nix` imports it rather than spelling `my` a second time — which is
  right, and which broke `haus show`: `modules/desktop-check.nix` stages a
  flake-less copy of the validator for the CLI and copies an explicit list of
  files. `haus show` died with a missing path on any file with a bad option
  path — exactly the file people run it on — and `test/haus-show.sh` would have
  gone red on merge. **Any `lib/` file the validator imports has to be added to
  that staging list**, and nothing in the repo says so at the import site.

- **A pure-lib check declared below the `optionalAttrs` split runs on nobody's
  CI**, while reading exactly like one that runs everywhere. `namespace-guard`
  was written pure so it could run on the Linux runner, its comment said so, and
  it was declared four lines into the darwin-only block. `check.yml`'s census —
  which already carries a warning that it "rots in every direction" and had been
  four wrong twice that week — is the only thing that catches this, and only if
  whoever adds a check re-derives it. The failure is invisible in every other
  direction: the check passes locally, passes on a Mac, and simply never runs.

⚠️ **And what E0 did not measure, which the design asked for: eval cost on a
real host.** The whole thing was built from a Linux container. The walk is
scoped so a stock machine forces one namespace's subtree rather than all 311
options, and nothing forces `default` or `example` (those doc-list attrs are
lazy) — but that is reasoning, and the paragraph above that asks for the
measurement is still asking.

#### What E deliberately does not get

- **No reserved-prefix rewrite of the model.** The prefix is for private and
  unclaimed rooms. A room someone actually publishes claims a plain
  `haus.<name>`, because the whole point is that it reads like a room.
- **No global registry, no name reservation service, no `haus claim`.** The
  claim is a fact about one machine, and it lives in that machine's files.
- **No block on the private case.** E0 asserts and explains; it does not refuse.
  A person's own module on their own Mac is allowed to be wrong about a name
  haus might take in a year — they just get told, once, at the moment it becomes
  true.

### Execution plan

Same contract as the plan above: exit gate green before the next step changes
behaviour, findings reported rather than folded in, and the
[status report shape](#agent-status-report) while work is live.

| Step | Status | Work | Durable evidence | Exit gate |
|---|---|---|---|---|
| **A. Publisher-side inspection** | done | `haus show <file>` for local paths only: class, `checkDesktop` verdict with filenames, the sets/doesn't-set summary, `--json`. No network, no writes. | Fixtures in haus's `test/` covering a valid desktop, each class of `checkDesktop` failure, and a room module; the JSON shape in `notes/agent-surface.md`'s terms. | A publisher can run one command instead of the first two checklist lines in `desktops/sharing.mdx`, and its exit code gates their CI. |
| **B. Remote sources, read-only** | **done** — [haus#435](https://github.com/hausfold/haus/pull/435) + [hausfold.co#111](https://github.com/hausfold/hausfold.co/pull/111), [designed here](#step-b-designed--fetch-and-read-are-two-acts-and-the-guard-covers-one), [findings](#findings-carried-out-of-step-b) | `haus show <source>` for `github:`/`git+https:`/`file+https:` — resolve, fetch, report origin and revision, warn on the revisionless shape. Still writes nothing to the consumer. Fetch and read are **two acts**: the guard cannot fetch, so the fetch runs unguarded (no publisher code runs) and the read runs guarded over the fetched store path. Report the source's date as the source's, and stamp the pin date itself. | A check that the three source shapes resolve to a path `checkDesktop` accepts, plus the recorded lock nodes for each — the mechanism half is measured in [`probes/source-shapes.sh`](./probes/source-shapes.sh) and the haus half is what this step owes. A fixture reading a sibling file out of a fetched repo, pinning the store-root granularity so a later Nix bump cannot narrow or widen it silently. | Met. A person can fully evaluate a stranger's desktop without their config being touched — proven by the guard rather than by inspection of the script (the fetched source can reach nothing outside its own store path), and proven for the *config* by running the whole command from inside a directory that has a consumer flake and cksum-ing it either side. Two things the gate did not ask for and the build owes anyway: `show` fetches a **tree** and never locks one, so the inertness covers a room too; and Nix's error text is a rendering path a remote party can write into. |
| **C. The machine diff** | not started | Extend `show` with what the machine becomes: rooms on/off vs. current, machine-wide claims, list-typed replacements. | Golden diff output against the example host for two desktops that differ in rooms, a hotkey and a list. | The confirmation prompt in step D has real content, and the list-replacement rule is visible before it bites. |
| **D. `haus add` / `remove` / `desktop`** | not started | Write the input and the selection; parse-verify or print; `--as`, `--file`, `--vendor`, `--print`; explicit replacement on remove; `haus update <name>`. | Tests over a scaffolded consumer flake, a hand-reorganised one (must degrade to `--print`), and a name collision. Docs: `desktops/sharing.mdx` and `customizing.mdx` rewritten around the commands, vendoring kept as the edit-it path. | A stranger's desktop can be found, read, pinned, selected, updated and removed without hand-editing Nix — and every one of those states is legible in `flake.lock`. |
| **E0. The reserved prefix** | **done** — [haus#429](https://github.com/hausfold/haus/pull/429), [hausfold.co#107](https://github.com/hausfold/hausfold.co/pull/107), both merged 2026-08-20 | `haus.my.*` is reserved, and the promise is a check rather than a sentence: `namespace-guard`'s `promise` row fails if `my` ever turns up in the registry or in haus's own surface. The consumer-side half is `modules/namespaces.nix`, beside `modules/desktop` and riding with the foundation, so a standalone `darwinModules.<room>` import gets it too. It WARNS — the design said "assertion" throughout and also said "it does not refuse", and only one of those can be built; the exit gate decided it. `rooms/creating`'s callout teaches the prefix, and `checkDesktop` answers it properly instead of "haus.my is not a haus option". | `namespace-guard`, pure lib and above the darwin split so it runs on Linux CI: a golden table over a stock machine, a private room, a reserved one and both together, plus the promise row — and the warning text itself, pinned. `test/desktops/reserved-prefix.nix` in both desktop fixture tables. | Met, with one gap the design predicted and this step did not close: **eval cost on a real host is still unmeasured**, since the whole thing was built from Linux. "Nobody else is told anything" is met for a stock machine and NOT for a consumer running a legitimately published room — that one warns until E1's claim table exists, and the message says so rather than giving it the private case's advice. |
| **E1. The claim table** | not started | `haus._rooms.claimed.<namespace> = "<origin as typed>"`, written by `add`, refused on a second claimant by origin, and checked against the registry and against per-leaf `declarations` (two store roots under one claimed namespace is silent co-ownership). Sequenced before D's room half: it is a format decision, and formats are hard to change once anyone has published into them. | The three cases as fixtures — unclaimed, double-claimed, later-claimed-by-haus — each asserting on the CONSUMER's evaluated option tree rather than in haus's own flake check. | A room can be added without the possibility of silently breaking on a later haus release, or of silently steering a room it did not write. |
| **F. Rooms in `haus add`** | not started | The same command with `flake = false` dropped, plus the code prompt: `--room` required and never inferred, typed confirmation, a per-name environment variable so a piped installer can never accept a room on a person's behalf. ⚠️ **The prompt comes before the LOCK, not before the rebuild** — [measured 2026-08-20](#and-step-f-cannot-borrow-it): dropping `flake = false` means locking the source evaluates the publisher's `flake.nix`, so pinning a room already runs its code and `show --room`'s skip-the-evaluation rule cannot extend to `add`. | Tests over the three source shapes for a room, and a fixture proving `--room` is never inferred from what the source contains. A fixture pinning the lock-time evaluation, so the prompt's placement cannot regress silently. | A stranger's room can be found, read, pinned, updated and removed on the same terms as a desktop, with the trust story the class actually warrants. |

### Findings carried out of step A

`haus show` shipped on 2026-08-20 (haus PR pending at time of writing). The
design above survived being built — no rule in it changed — and the interesting
part is what building the FIRST publisher-facing verb turned out to cost, since
every other verb haus has drives the machine it is standing on.

- **[4] "A desktop cannot run anything" is true of what it DECLARES and false
  of what it costs to read.** The trust story in this section rests on the
  closed schema: a desktop is data, `checkDesktop` proves it, and that is why
  running a stranger's is reasonable. Inspecting one turns out to be the hole.
  Reading a `.nix` means EVALUATING it, and Nix evaluation is not inert —
  `builtins.readFile` and `builtins.fetchurl` run at eval time — so the first
  cut of `haus show` read any file the user could read and could reach the
  network, *during the very command they ran to decide whether to trust the
  file*. Measured rather than reasoned about: a fixture whose accent was
  `readFile ~/creds` had the secret read AND printed back in the report.

  It closes with `restrict-eval`, `allowed-uris` empty, IFD off, `NIX_PATH`
  cleared, and exactly two paths named — the checker's own directory and the
  ONE file being read, not its parent, because a stranger's file in
  `~/Downloads` must not be able to read the rest of it. (⚠️ **That last
  property is local-only**, measured 2026-08-20: `restrict-eval`'s unit is the
  store path, so naming a file that arrived by *fetch* allows its whole source
  tree — see
  [step B](#the-guards-granularity-changes-in-the-store). Step A's own case is
  a local path, so the finding is right about what it built and narrower than
  it reads.) `--room` skips the
  evaluation altogether: you have said it is code, and evaluating it anyway to
  say so is the one thing this command must not do. A blocked read is an error
  naming what it reached for, so the attempt is visible instead of silent.

  **This binds every remaining step, and it is why it is a 4 rather than a 3.**
  B fetches a stranger's source and evaluates it; C evaluates it against your
  machine; D writes it into your flake and hands it to a rebuild. Each of them
  is a place where a file gets read before anyone has decided to trust it, and
  each has to use the same guard — which now exists in one place, in the script,
  rather than needing to be re-argued per step. The note already said the closed
  schema "is not an escaping story"; the sharper form is that **the schema
  governs what a desktop can declare, and the sandbox governs what reading one
  can do.** Two different protections, and step A only had the first. (Step B
  added a [third](#findings-carried-out-of-step-b) — what a remote party can get
  *printed* — which neither of these two covers and which only appears once a
  command talks to a network.)

- **[3] A checker that only exists inside a flake cannot be run by the person
  who needs it.** The rules were reachable exactly one way — `haus.lib.checkDesktop`,
  i.e. a flake evaluation — and `show`'s job is to answer from a shell, offline,
  about a path that is outside every flake. Resolving the consumer's lock on each
  invocation to answer a question that is pure lib is the wrong shape, so the
  same two files (`modules/lib/desktop.nix` and the registry) are staged into
  `share/haus/desktop-check` with nixpkgs' `lib` beside them and an
  argument-free entry point. Two properties make that a copy rather than a
  second implementation: the SOURCE files are the ones the flake evaluates, so
  no rule can drift between the seam and the CLI; and the staged copy is built
  from the revision the machine PINNED, which is `host-template.nix`'s argument
  pointed the other way — a checker describing options your pin doesn't have is
  a failed publish for the least experienced person we have.

  The same fact splits the evidence in two, and this is the durable half:
  **the command's own suite cannot be a flake check**, because the script shells
  out to `nix eval` and no derivation may. So `desktop-show` (a check, portable,
  runs on Linux CI) pins the READING — the class, the counts, which room each
  leaf files under, over all 29 desktop fixtures — and `test/haus-show.sh` pins
  the exit codes, flags and JSON envelope against the built wrapper, from CI's
  eval job where a real nix exists. Expect that split for every verb that
  wraps an evaluation.

- **[3] The no-inference rule is ASYMMETRIC, and saying so is what lets `show`
  work without a flag.** This section says the class must never be inferred,
  "because inference is how a data prompt gets shown for a code source". That
  is true in one direction only. Inferring CODE from content can only ever be
  over-cautious: a module function is reported as a room, unasked, and the worst
  case is a warning over something harmless. Inferring DATA must never be an
  inference at all — `failures == [ ]` is a proof, and it is the checker's. So
  the rule as built is: **`show` may report a room; only the checker may
  certify a desktop.**

  Two things fall out. An attrset carrying `imports` is NOT quietly
  reclassified as code — it is a desktop that failed, and its diagnostic names
  the rule, which is the better answer for the case it usually is (a typo in a
  desktop). And the command needs an exit code of its own for the gap:
  **3, "it is code and you did not say `--room`"**. A publisher's CI must go red
  the day their desktop file becomes a function, and "nothing was checked" is
  not a pass. `--room` makes that 0; nothing about the file's contents ever
  does.

- **[2] `builtins.tryEval` does not catch a type error, and reading a
  stranger's file is exactly where you find out.** The first draft forced the
  imported value with `builtins.attrNames`, inside a `tryEval`, to make a broken
  file fail with the filename rather than as a raw trace somewhere downstream.
  `tryEval` catches `throw` and `assert`; `attrNames` on a list is neither, and
  it took the whole evaluation down — caught by `test/desktops/non-attrset.nix`,
  a fixture that exists for a different rule entirely. The shape that works:
  force with `deepSeq` (which raises no type errors of its own, so a `throw`
  buried in a value IS caught) and test a value's type before touching a key.

- **[2] The registry keys its namespaces BARE and its option paths PREFIXED,
  and mixing the two fails silently in the worst direction.** `registry.namespaces`
  is keyed `bar`; every option under it is `haus.bar.*`. Matching leaves against
  the unprefixed keys matched nothing at all — so every leaf resolved to no
  room, and the report rendered as a desktop setting nine options across zero
  rooms. Plausible-looking output, no error, and the only thing that caught it
  was a golden table whose expected value was non-empty. **A lookup that can
  return "no match" for every input needs a fixture that expects a match**, not
  one that expects the absence of a failure.

- **[2] This is haus's first `--json` verb, so it sets the envelope the sweep
  copies.** `notes/agent-surface.md`'s table still has haus at "no `--json` on
  any verb"; it has one now. Three decisions in it are worth reusing. `checked`
  is a FIELD rather than something a caller infers from an empty `failures` list
  — a room and a clean desktop are otherwise indistinguishable in JSON, which is
  the one confusion this command must never cause. The class is reported even
  when nothing was checked, rather than the command declining to answer. And
  **`ok` is `null`, never `true`, whenever `checked` is false** — the first cut
  had `ok: true` for a room and for a file that could not be parsed, which is
  the same lie in a field an agent is being taught to read. *A boolean that has
  to mean "passed" cannot also carry "not applicable".*

- **[2] A guard written for "every verb drives this machine" is wrong the first
  time a verb doesn't.** `haus.sh` refuses to load at all without a consumer
  flake at `~/.config/nix` — correct for eighteen verbs and exactly backwards
  for the nineteenth, whose audience includes a publisher's CI that has none.
  It is per-verb now. Worth expecting again at step D: `haus show` is the first
  command here with a reader outside this Mac, and it will not be the last.

- **[1] `set -o pipefail` plus a deliberately-failing command is a silent
  abort.** The diagnosis path re-runs the evaluation UNGUARDED to get Nix's own
  sentence, so that command is *expected* to fail — and under `pipefail` its
  non-zero status came back through the substitution and took the whole script
  down with no output and the wrong exit code. Which is precisely the failure
  this command exists to prevent, produced by the code that reports it. `|| true`
  on anything you are running for its stderr.

- **[1] `pkgs.path` carries no string context.** Staging nixpkgs' `lib` via
  `${pkgs.path}/lib` builds a derivation that MENTIONS a store path it does not
  depend on, which Nix warns about and a garbage collector is free to make true.
  `builtins.path` copies the subtree in under its own name with real context,
  and copies only `lib` (2 MB) rather than rooting the whole nixpkgs source in
  the system closure.

  ⚠️ Unrelated, found while verifying: **`nix flake check` is red on haus
  `main`** at 26422b7 — [haus#422](https://github.com/hausfold/haus/pull/422)
  added a generated home file that scales, and `scale-reach` enumerates every
  such file, so it needed a row it never got. It merged red because the reach
  checks are darwin-only and CI is ubuntu. Fixed in the same branch as a
  separate commit rather than folded in.

### Findings carried out of step B

`haus show <source>` shipped on 2026-08-20, the same day the step was designed
([haus#435](https://github.com/hausfold/haus/pull/435)). The design was argued
from a probe rather than from memory and it shows: **no rule in it changed**,
and every row it had flagged as evaluator behaviour reproduced on an *older* Nix
(2.33.0) on macOS where the probe had run 2.34.8 on Linux — the guard refusing a
fetch by URI, the store-path granularity in both directions, and locking-vs-
fetching. What building it added is a correction, two holes and a handful of
rules. The holes are both about the *report* rather than the mechanism, which is
the half a probe cannot see — and the second of them was found by the pre-PR
assurance pass rather than by building or measuring anything, which is the
clearest argument for that pass this note has yet produced.

- **[3] The inert act is FETCHING, not `flake = false` — and correcting that
  makes `show --room` honest at a distance.** The design's first act reads "no
  publisher code runs *for a desktop*", with a warning that this is a property
  of `flake = false` rather than of fetching. Measured at the command, against a
  repo whose `flake.nix` throws from `inputs`: `builtins.fetchTree` over it
  returns a store path having evaluated nothing, while `nix flake lock` over the
  same source fires the throw. Both halves of the probe were right; the sentence
  joining them was not. `flake = false` matters because it is what makes a
  **lock** a pure fetch — and `show` does not lock. It fetches a tree.

  So the guarantee is broader than the design claimed, in the one direction a
  trust story is allowed to be surprising: `haus show --room github:ada/photo`
  fetches, reports origin, revision and date, and prints the code warning with
  *nothing of the publisher's evaluated* — not even their `flake.nix`. Step A's
  rule ("you have said it is code, and evaluating it anyway to say so is the one
  thing this command must not do") survives the trip to a remote source intact,
  which it would not have if `show` had been built on `nix flake lock`.
  [Step F](#and-step-f-cannot-borrow-it) is unaffected and its reasoning is
  unchanged: `add --room` locks, and locking evaluates. The command says so in
  the room report — *fetched, not locked* — because "we did not run it" and "we
  will not run it when you add it" are different promises and only the first one
  is being made.

- **[3] A failed fetch lets a stranger choose the sentence haus prints.** Step A
  reports Nix's own words on a failure by taking the last non-blank line of
  stderr, which is right for a parse error and wrong for a fetch: Nix prints its
  message and then appends the **server's response body** underneath it. A 404
  from GitHub therefore came back as `Nix says: }` — the closing brace of an
  error document. The fix is to take the last `error:` line instead, which is
  the message on every path this command has (a blocked read, a type error, a
  missing input, a syntax error, an HTTP failure).

  The half that makes it a 3 is the second one: the response body is **cut off
  first**, because otherwise a server that writes `error: …` into its own body
  chooses the line haus renders. That is small in itself and it names something
  this section had not: **the closed schema governs what a desktop declares, the
  sandbox governs what reading one may do, and neither governs what a remote
  party can get printed.** Step A already split one protection into two; this is
  the third surface, it appears the moment a command talks to a network, and it
  belongs to every step from here on — C renders more, D renders a confirmation
  prompt someone is about to answer.

- **[2] "Which file?" has no safe default, and `--file` is refused rather than
  resolved — for the opposite of the usual reason.** A `file+` source's store
  path *is* the file; a repo's is a tree, and something has to say which `.nix`
  in it is the desktop. The rule built: root-level `.nix` files (minus
  `flake.nix`) plus a conventional `desktops/`, exactly one candidate used and
  **named in the report**, anything else refused with the list and `--file`.
  Picking among a publisher's desktops is the one guess here with a wrong
  answer.

  `--file` then rejects a leading `/` and any `..` component. Not because the
  sandbox would let such a path through — because the sandbox **allows the path
  it is handed**. An escaping `--file` does not sneak past the guard; it asks to
  have the escape allowed. Every guard in this design is configured from
  arguments, so that inversion is worth carrying: validate what you are about to
  put *into* a sandbox, not only what comes out of it.

- **[2] A bare `https://` URL is a tarball to Nix, and the failure names
  nothing.** `haus show https://example.org/writer.nix` fetches it as an archive
  and dies with `Failed to open archive (Unrecognized archive format)`, which
  says nothing about the missing prefix. It is refused with all three real
  spellings (`file+`, `git+`, `tarball+`) rather than rewritten, and the reason
  is a step-D reason: **the string typed here is the string `haus add` writes
  into `flake.nix`**, so guessing it would put an origin in someone's lock that
  nobody chose.

- **[2] The schema version did not move, and that is a rule rather than a
  shrug.** `--json` grew a top-level `origin`. A version bump is owed when an
  **existing input's answer changes**; `origin` is `null` for every input
  `schemaVersion: 1` could accept, and non-null only for sources that used to be
  an error. No reader breaks, so no reader is made to update. Worth stating
  because this envelope is the one the rest of the `--json` sweep copies, and
  "we added a field, bump it" is the reflex that makes a version number
  meaningless.

- **[1] A report over a fetched tree cannot attribute a value to a file.** The
  design predicted this from the granularity measurement and left it as advice;
  the build has to render it. A fetched desktop may read the siblings its
  publisher shipped, so the reader comparing `haus show` against the one file
  they are looking at on GitHub is comparing against the wrong thing. The report
  says so in one line, and the `tree` field is printed beside the origin so
  there is somewhere to look. It is also the first place `show` prints a store
  path at a person, which is a wart worth accepting rather than hiding: it is
  the only honest answer to "what exactly did you read?"

- **[1] Two shapes, and neither has every field.** `github:` resolves without a
  `revCount` where `git+file:` has one, so every read of the fetch result is
  `t.<field> or null` and the report asks what a shape *can* answer rather than
  assuming a schema. The date pair is the visible half: a repo gets `changed`
  (the source's own commit date, labelled as the source's) and `fetched`
  (stamped from the clock, because
  [nothing in a lock records it](#what-the-lock-records-and-the-one-word-this-note-had-wrong)),
  and a raw URL gets only the second one with the warning that its `haus update`
  line will read as a no-op.

- **[4] The report is a surface, and it was the unguarded one.** Found by the
  pre-PR assurance pass, not by building it, which is the whole argument for
  running one. `lib.generators.toPretty` goes through `builtins.toJSON`, which
  escapes quotes, backslashes and the three whitespace controls and **nothing
  else** — so `ESC` survives a desktop's own values *and its own attribute
  names* all the way to `jq -r`, which decodes it back to a raw byte. And `sets`
  is printed **after** the class line and after the list of broken rules. So a
  desktop that can move the cursor can repaint *"not a desktop — it breaks the
  rules below"* as *"a desktop — data only, and haus checked it"*. Measured, with
  `od -c` on the bytes rather than by reading the code.

  The exit code stayed honest throughout, which is exactly what makes it bad: a
  publisher's CI could not be fooled, and the person the command was written for
  could. It closes by stripping C0 controls (tab excepted, being the field
  separator) **in the render helpers** rather than at each call site, because a
  rule that has to be remembered per call is a rule with a hole in it; `--json`
  needs none of it, since jq re-escapes controls on the way out.

  Two things this says beyond the fix. It is the **same third protection** the
  fetch-error finding above names, arriving by a completely different route — so
  that surface is not a quirk of talking to a network, it is what happens
  whenever untrusted text reaches a renderer, and this one was there in step A.
  And the reason it *bites* now is not the code: step A's input was a file
  someone handed you, and B's arrives from a stranger. **A hole can be created
  by changing where the input comes from, without touching the line that has
  it.** Worth carrying into C and D, which render strictly more.

- **[3] A provenance report may not read from a cache.** Also from the assurance
  pass. Nix's `tarball-ttl` defaults to an hour, so `builtins.fetchTree
  "github:ada/x"` resolves from cache for an hour after any first look —
  measured at 0.05s cached against 0.43s with the TTL at zero. A consumer
  running `show` minutes after a publisher pushes a fix was therefore told the
  **previous** rev and the **previous** `changed` date, underneath a `fetched`
  line stamped from the clock in the freshest language the report has. Every
  other verb in haus can afford a cache; the one whose entire output is "where
  did this come from and how old is it" cannot, so the fetch pins
  `tarball-ttl 0`. The general form: **a cache is only invisible until something
  reports a timestamp.**

- **[1] A docs sentence that names a future step is a dated cheque.** The
  reference page said, in step A's own words, "It takes a local path today;
  remote sources come with `haus add`" — accurate when written, false the
  evening step B landed, and attached to the wrong verb besides (they came with
  `show`, not `add`). It is the cheapest kind of drift to produce and the
  hardest to notice, because nothing regenerates that page and nothing checks
  it. Fixed in the same change
  ([hausfold.co#111](https://github.com/hausfold/hausfold.co/pull/111)), and the
  habit it argues for is
  to write what a command *does* and let the absence of a feature be silent:
  "takes a local path" needed no expiry date, and "remote sources come later"
  did.

- **[1] The suite that proves a network feature runs offline.** `git+file://`
  and `file+file://` are the same two fetchers `github:` and `file+https://`
  resolve to, pointed at throwaway repos in a `mktemp` dir — so CI exercises the
  real fetch path with no network dependency to make it flaky for a reason that
  has nothing to do with haus. Step A's split holds: `desktop-show` still pins
  the reading inside a derivation, and everything about fetching lives in
  `test/haus-show.sh`, which shells out to `nix` and therefore cannot. B's own
  exit gate is measured there rather than asserted — the whole command runs from
  inside a directory holding a consumer `flake.nix`, and the directory is
  `cksum`ed either side.

### Open decisions

- **[3] ✅ Decided 2026-08-16 — a desktop carries no metadata about itself, and
  that is accepted rather than fixed.** The closed schema admits exactly one
  top-level key, `haus`, and every leaf under it must be a registry-classified
  option — which is what makes the format trustworthy and also what makes it
  anonymous, so `haus show` can report what a desktop *sets* but never who
  wrote it or what it was tested against. The rejected alternative was an
  inert, desktop-safe `haus.meta.*` (`name`, `description`, `author`,
  `hausRev`) that configures nothing and exists to be read; it was declined
  because it adds publisher-authored strings that a trust surface then
  displays, which is the one input class this design otherwise keeps out, and
  because the same fields are already required prose in the sharing checklist.
  **So metadata lives in the repo's README**, `haus show` reports origin from
  the lock and content from the file, and a raw single-file source simply has
  no author — which is a further reason to prefer the repo shape. Reopening
  costs a registry entry plus a `show` renderer if the gallery later wants
  machine-readable rows.
- **[2] `add` is a vague verb next to Pounce's “Install App”.** It should print
  what it decided the subject was (“pinned the desktop `writer` from …”) rather
  than take a mandatory noun, but if a future `haus add <app>` is wanted, the
  noun becomes mandatory then and the desktop form keeps working.
- **[3] ✅ Superseded 2026-08-17 — the pack seam is gone, not repositioned.**
  This was a ladder bug: `lib.pack` lowered a consumer-composed pack to
  `mkDefault` (1000), under the desktop's 900, so the more general statement
  beat the more specific one. Unreachable in practice (no shipped desktop sets
  `haus.roster`) but not by design — `haus.roster.<name>.key` is
  `desktopSafe: true`, so the first published desktop claiming a leader letter
  would have hit it. It was fixed with a `packPriority = 500` rung
  ([haus#384](https://github.com/hausfold/haus/pull/384)), and then both that PR
  and its docs companion were **closed** in favour of retiring the format —
  👤's call, and the better one.

  Why: **rooms are shareable too**, so three formats sat over two trust classes.
  A pack was data that arrived beside rooms, earning its own prompt, its own
  docs page and its own rung for no user — `riceLib.pack` had exactly one caller
  in haus, feeding only the deprecated `haus.packs.writing` alias and the checks
  that tested the format itself. Retired in
  [haus#386](https://github.com/hausfold/haus/pull/386) with
  [hausfold.co#68](https://github.com/hausfold/hausfold.co/pull/68).

  Four things worth keeping out of doing it:

  - **The trade is exactly one capability, and it is worth naming.** What a pack
    had that neither survivor does is *many per host, provably data-only*. A
    desktop is data but you get one; a room is many-per-host but it is code. So
    a shared app list moves from “haus can prove this is inert” to “trust the
    author”. A pack could not be re-expressed as a narrow desktop either —
    mechanically it would pass (`checkPack` ⊂ `checkDesktop`, `roster` is
    `desktopSafe: recursive`), but one-desktop-per-host closes it. Nothing used
    the capability, so the trade is cheap; it is still a trade.
  - **One rule survived its subject, and it could not become a check.** The
    per-leaf priority rule is `packEntries`'s too, so it moved into
    `app-collections`, run against the room's switch. But “a collection file
    sets nothing outside `haus.roster`” could not: `packEntries` carries only
    `roster` through, so a stray key is dropped with **no error**, and a check
    has nothing to look at. It is an assertion inside `packEntries` — the only
    code positioned to see it. A rule whose failure mode is silence belongs
    where the silence happens, not in a check.
  - **A check that guesses a filename is a check that reads the wrong file.**
    The first draft derived the collection's path from its option name. That is
    correct until a name and a filename diverge, at which point the check reads
    a different file than the room installs, silently. `modules/apps/packs/`
    is now a table both read, with an orphan rule on either side of it.
  - **Retirement is not symmetric with deprecation, and the docs are the tell.**
    `presets` got a warning-emitting shim for its migration window; `lib.pack`
    was hard-removed with none. Defensible at zero consumers — but the published
    docs still *taught* the removed helpers, so for as long as the two PRs sat
    unmerged the honest statement was “nobody uses it and everybody is being
    told to”. Retire the docs in the same breath as the API.
- **[3] ⏳ Answered in design 2026-08-20, unbuilt — nothing in this design lets a
  desktop depend on a room that is not in haus, and retiring packs makes that
  bite sooner.** The answer is
  [in step E](#what-this-settles-about-a-desktop-depending-on-a-strangers-room):
  the room ships its own registry fragment, the desktop seam merges it, and the
  fragment may classify only paths under the namespace that room claimed. It
  needs no change inside `modules/lib/desktop.nix` — measured — so what is left
  is a decision to take rather than a mechanism to find. The original statement
  stands below because the reasoning it records is what the answer had to
  satisfy.

  A third-party desktop that enables a third-party room is the case where the
  two classes have to arrive together, and the closed schema gives a desktop no way to say so — a desktop
  may only set registry-classified `haus.*` leaves, and a stranger's room
  declares a namespace the registry has never heard of. It used to be step E's
  problem, i.e. nobody's. It is now the shape of "share a photography setup":
  the room installs the apps, and the desktop that wants it cannot name it.
  Belongs with step E's namespace work, since both answer "what is a
  third-party namespace, and who vouches for it?" — which is precisely how it
  got answered.

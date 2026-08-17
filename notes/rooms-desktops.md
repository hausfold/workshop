# Rooms and desktops

Working vision, 2026-08-13. Current code is the source of truth for what exists;
this note defines the product model the code and docs should converge on.

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

Two rules came out of it and are worth keeping:

- **A room is named for what it does; a product is named for what it is.** The
  app in the Launcher room is Pounce and always will be. The room is not.
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

The plan therefore has no step 7. What follows are the findings from earlier
steps that no step ever owned, re-verified against merged `main` today so the
next agent starts from the tree rather than from the prose. Each is a
standalone change; none of them blocks another.

- **[3] Nothing owns "may a desktop choose the editor?"** Step 4 handed this to
  "step 5 or 6" and neither took it. Half of it resolved on its own:
  `haus.fonts.mono.name` and `.packageName` are `desktopSafe: true` in the
  merged registry, so a desktop CAN name a font family — the patched-Nerd-Font
  rule is a requirement at the option, not a trust boundary. The editor half is
  untouched: `haus.terminal.editor` is `desktopSafe: false` because its value is
  executed, and Development installs helix unconditionally, so no desktop can
  say "this Mac is a neovim Mac". The fix is a room-owned enum whose values name
  editors the room actually installs — a new option plus packages, not a safety
  flip on the existing one.
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
- **[2] The generated reference names a validator; the key rule it enforces is
  hand-written prose somewhere else.** `groups.json` ships `haus.displays` as
  `{"desktopSafe": "recursive", "validator": "display-selectors"}`. A reader is
  not stranded — `/docs/haus/desktops/creating/` explains in words that a
  display UUID is host-only and that attrsets carry per key — but exactly one of
  those two statements is generated, so they can now drift apart. Step 3
  predicted this against step 6; step 6 rendered rooms and left it standing.
- **[2] The AI room's payload still lives in `core` and `terminal`.** `modules/ai`
  is still `default.nix` + `options.nix` — ownership, assertions and
  contributions only. Step 2 deferred the move until a comparator could prove it
  free; `desktop-projection` has existed since step 4, so `holt`, `agent-state`,
  the statusline and the client/hook files can now move under proof.
- **[2] The bar spells one gate three ways.** `contributed`,
  `name != "focus" || config.haus.focus.enable` in `bottomGroup`, and `topFocus`
  all answer "does this pill's source exist?" — checked, and there is no bug:
  `topFocus` covers the top bar that `bottomGroup`'s filter does not. The cost is
  that the next contributed pill has to be remembered in two places.
- **[2] Extension points are still only the three the AI room needed.** Windows'
  workspace pills, Focus's controls and Bar's reserved space from Windows still
  read each other's config directly. Worth generalising on the next room that
  needs one, not speculatively — unchanged from step 2's judgement.
- **[2] The landing page's section order is still 👤's call.** The page closes
  with haus rather than explaining it second, and says why in a comment. The
  model-agreement half of step 6 landed; only the ordering is open.
- **[1] `/docs/haus/rooms/agent-rebuilds/` is in the Rooms group and is not a
  room.** Twelve room pages plus one guide share the prefix. Harmless, and
  exactly the kind of thing a catalogue-shaped navigation makes visible — step
  6's own finding about missing pages, running the other way.

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
points at the same place. Nothing here is built.

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
revision, a content hash, and a fetch date. `nix flake update <name>` already
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

Verified against real Nix on 2026-08-16, not recalled:

| source | input spelling | pins | selection line | notes |
|---|---|---|---|---|
| **a repo** (recommended) | `{ url = "github:ada/writer-desktop"; flake = false; }` | rev **and** narHash, plus `lastModified` | `desktop = "${inputs.writer}/writer.nix";` | the publisher's repo needs **no `flake.nix`** — the boring three-file repo `desktops/sharing.mdx` already recommends is exactly the right shape |
| **one file / a gist's raw URL** | `{ url = "file+https://…/writer.nix"; flake = false; }` | **narHash only — no revision** | `desktop = inputs.writer;` | the store path *is* the file, so no path suffix. But there is no version to move between, so `haus update` on it silently follows whatever is at that URL now |
| **a gist as a repo** | `{ url = "git+https://gist.github.com/ada/<id>"; flake = false; }` | rev (a gist is a git repo) | as the repo row | ⚠️ **unverified** — the mechanism is standard but I did not fetch one |
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
  takes it directly.

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

1. where it came from and what it locked to (origin as typed, resolved rev,
   fetch date) — or, for a `file+https` source, that there is no revision;
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
that matters. The prompt is a *diff*: this is what turns on, this is what turns
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
arbitrates a top-level `haus.<name>.*` namespace.** Two third-party rooms
claiming one collide as a raw module-system option-declaration error naming
neither publisher — but the worse case is haus later shipping a room with that
name and breaking a machine that was fine. haus's own `room-registry` check
catches an unclassified namespace in *haus's* flake check, which never runs on
the consumer. Needs an answer — a reserved prefix, or a claim check at `add`
time — designed with the room half rather than after it. The extension-point
mechanism is also still only the three points the AI room needed, a finding
carried since step 2.

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
  the docs page should say so regardless of whether `add` is built.
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
  repo source is cheap.

### Execution plan

Same contract as the plan above: exit gate green before the next step changes
behaviour, findings reported rather than folded in, and the
[status report shape](#agent-status-report) while work is live.

| Step | Work | Durable evidence | Exit gate |
|---|---|---|---|
| **A. Publisher-side inspection** | `haus show <file>` for local paths only: class, `checkDesktop` verdict with filenames, the sets/doesn't-set summary, `--json`. No network, no writes. | Fixtures in haus's `test/` covering a valid desktop, each class of `checkDesktop` failure, and a room module; the JSON shape in `notes/agent-surface.md`'s terms. | A publisher can run one command instead of the first two checklist lines in `desktops/sharing.mdx`, and its exit code gates their CI. |
| **B. Remote sources, read-only** | `haus show <source>` for `github:`/`git+https:`/`file+https:` — resolve, fetch, report origin and revision, warn on the revisionless shape. Still writes nothing to the consumer. | A check that the three source shapes resolve to a path `checkDesktop` accepts, plus the recorded lock nodes for each. | A person can fully evaluate a stranger's desktop without their config being touched. |
| **C. The machine diff** | Extend `show` with what the machine becomes: rooms on/off vs. current, machine-wide claims, list-typed replacements. | Golden diff output against the example host for two desktops that differ in rooms, a hotkey and a list. | The confirmation prompt in step D has real content, and the list-replacement rule is visible before it bites. |
| **D. `haus add` / `remove` / `desktop`** | Write the input and the selection; parse-verify or print; `--as`, `--file`, `--vendor`, `--print`; explicit replacement on remove; `haus update <name>`. | Tests over a scaffolded consumer flake, a hand-reorganised one (must degrade to `--print`), and a name collision. Docs: `desktops/sharing.mdx` and `customizing.mdx` rewritten around the commands, vendoring kept as the edit-it path. | A stranger's desktop can be found, read, pinned, selected, updated and removed without hand-editing Nix — and every one of those states is legible in `flake.lock`. |
| **E. Namespace arbitration** | Decide and build what stops two third-party rooms — or a third-party room and a future haus one — from claiming the same top-level `haus.<name>.*`. A reserved prefix, or a claim check at `add` time. Sequenced before D's room half, not after it: it is a format decision, and formats are hard to change once anyone has published into them. | The rule, plus a check that fires on the CONSUMER's machine rather than only in haus's own flake check. | A room can be added without the possibility of silently breaking on a later haus release. |
| **F. Rooms in `haus add`** | The same command with `flake = false` dropped, plus the code prompt: `--room` required and never inferred, typed confirmation, a per-name environment variable so a piped installer can never accept a room on a person's behalf. | Tests over the three source shapes for a room, and a fixture proving `--room` is never inferred from what the source contains. | A stranger's room can be found, read, pinned, updated and removed on the same terms as a desktop, with the trust story the class actually warrants. |

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
- **[3] Nothing in this design lets a desktop depend on a room that is not in
  haus, and retiring packs makes that bite sooner.** A third-party desktop that
  enables a third-party room is the case where the two classes have to arrive
  together, and the closed schema gives a desktop no way to say so — a desktop
  may only set registry-classified `haus.*` leaves, and a stranger's room
  declares a namespace the registry has never heard of. It used to be step E's
  problem, i.e. nobody's. It is now the shape of "share a photography setup":
  the room installs the apps, and the desktop that wants it cannot name it.
  Belongs with step E's namespace work, since both answer "what is a
  third-party namespace, and who vouches for it?".

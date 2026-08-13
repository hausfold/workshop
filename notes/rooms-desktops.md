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
one desktop (blank, nebelhaus, …)
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

The current generated reference treating every namespace as one of “35 rooms”
is an implementation accident to replace with this registry and per-option
desktop metadata.

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

These are product groupings, not an instruction to rename every existing option
immediately. Code may stay split into smaller modules where that keeps ownership
clear. The generated catalogue maps those modules and namespaces into the room a
person understands.

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
`developer.agents`, `agents.*`, den, hearth/zellij, Sill and Pounce. Turning AI
on should bring the selected clients, Holt and lifecycle wiring. Its Sill,
Launcher and Development additions should appear only when those rooms exist.

## What a desktop is

A desktop is a complete answer to “what should this Mac feel like?” It chooses
rooms and configures their exposed options. nebelhaus is the first desktop: its
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
peer of room or desktop and does not appear in the top-level journey.

Sources should remain inspectable, typed and pinnable so a later distribution
workflow can identify whether it contains a desktop or executable room code,
preserve its origin and revision, and apply the appropriate trust warning. This
note deliberately leaves acquisition commands, manifests and remote-source UX
open.

## The user journey

1. Choose a desktop: nebelhaus, another published desktop, or Blank.
2. Review the rooms it enables and the visible choices it makes.
3. Add or remove rooms.
4. Tune the options surfaced by those rooms.
5. Add private identity, secrets and hardware details in the host.
6. Preview and rebuild.

The UI and docs should eventually describe intent first and Nix second. “Add the
AI room” is the user action; which modules install Holt, write Codex hooks and
contribute a Sill pill is implementation detail.

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
works with, permissions and side effects, remove it, options. Theming, Hush,
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
| **0. Baseline** | done | Inventory current implementation modules, exported `darwinModules`, `haus.*` namespaces, enable switches, defaults and cross-room reads. Classify every public export, each namespace as room/shared/host, each leaf as desktop-safe/host-only, and each value as generic mechanism/nebelhaus opinion. | Commit `notes/rooms-inventory.md` in the workshop, including the bounded sources, commands and haus revision used to produce it. | The inventory accounts for every public module export and generated option group, and names every behavior that must remain identical during the refactor. Re-running its commands at the recorded haus revision reproduces its counts. |
| **1. Room registry** | done | Expand `haus/modules/options-groups.nix` into the single registry for public-export ownership, room/shared/host classification and per-option desktop safety, without moving or renaming options. Make the host template and docs renderer consume it. | The source registry, regenerated `haus/docs/site-data/groups.json`, and a flake check that fails on an unmapped `darwinModules` export, unclassified namespace, unsafe dynamic subtree or option with no desktop-safety decision. | Every public export, namespace and transitively reachable leaf is classified; current option addresses are unchanged; generated artifacts are current; counts come from the registry rather than prose. |
| **2. AI proof** | ready for review | Make AI the first declared cross-room capability. Move ownership out of `developer.agents` while preserving compatibility; expose contributions to Development, Bar and Launcher through explicit extension points. | A named haus flake check covering AI alone and AI with each receiving room. Pair old and new addresses in fixtures that compare behavioral projections, warnings and plain-host-override priority. | AI alone brings clients, Holt and lifecycle wiring; its optional integrations appear only with their receiving rooms; old and new addresses produce identical behavior and precedence, with the intended migration warning only. |
| **3. Desktop seam** | unblocked once 2 lands | Add exactly-one-desktop selection, source attribution, closed-schema validation, recursive desktop-safety enforcement and host-wins priority. Keep the full compatibility builder selecting nebelhaus implicitly. Preserve standalone `darwinModules` imports as Blank plus the explicitly imported room; they do not acquire nebelhaus opinions. Do not design remote acquisition here. | A named haus flake check with positive fixtures for one desktop, host override, every supported builder/module entry point and source diagnostics; negative fixtures for two desktops, module functions, `imports`, `_module`, extra top-level keys, `system.activationScripts`, unknown options, unsafe dynamic payloads and every class of host-only leaf. | One desktop is selected through a full builder; a plain host assignment overrides it; a second is rejected clearly; standalone room imports retain their current behavior without requiring a desktop selection; source filenames survive diagnostics; only the closed `{ haus = { … }; }` value reaches option evaluation. |
| **4. Carve out nebelhaus** | blocked by 3 | In one atomic change, neutralize generic room defaults, add the real nebelhaus desktop and add the built-in Blank desktop. Keep `mkNebelhaus`, every supported builder/module entry point and old option addresses as compatibility surfaces. | Commit the **projection schema and comparator**, plus the complete non-sensitive example projection. For the real consumer, compare full projections only in an ephemeral directory and commit/report only the equality result—never values, counts, hashes, host paths or serialized output. Add a Blank fixture; run `nix flake check` and `bench try`. PR commands use placeholders/environment variables and redact local paths. | Existing nebelhaus example and real-consumer projections compare equal; Blank enables no optional rooms; every prior public entry point passes its compatibility fixture; no consumer-derived values or paths enter git, logs or the PR; there is no commit on `main` where existing installs silently lose a room. |
| **5. Retire top-level fragments** | blocked by 4 | Move `large-print` under Appearance and `writing` under Apps. Keep temporary aliases where consumers need them; remove preset and pack from the top-level product vocabulary. | Compatibility fixtures evaluating old and new spellings to the same values, plus generated migration documentation. | The same configurations remain expressible, migration warnings name replacements, and no docs invite users to stack whole desktops. |
| **6. Rebuild the docs journey** | blocked by 5 | Regenerate the reference from the registry and reorganize hausfold.co around Desktops first, then Rooms. Keep each desktop's own docs thin. | Committed site-data artifacts, `npm run build` in hausfold.co, docs/palette checks, and links or screenshots for the Desktops and Rooms navigation states. | The landing page, docs navigation, generated reference and compatibility docs agree on the model and current option surface. |

Step 4 is deliberately indivisible at the behavior boundary. Neutral defaults,
the nebelhaus values that replace them and the compatibility selection must land
together even if preparatory refactors land earlier.

### Findings carried out of step 2

Reported rather than folded into that step's scope, because each one changes
what a LATER step has to do.

- **[3] The AI room defaults to another room's switch.** `haus.agents.enable`
  keeps `developer.enable` as its default, which is the exact "rooms do not
  silently enable each other" violation the model forbids. Step 2 could not fix
  it: a neutral default there is a behaviour change, and the value that replaces
  it belongs to the nebelhaus desktop. It is step 4's, and it is the reason step
  4 is indivisible.
- **[3] The AI room sits in the standalone `darwinModules` foundation.**
  `flake.nix`'s `standaloneModule` imports `modules/ai` beside `den`, `roster`
  and `workspaces`, because a partial that imported only `sill` would otherwise
  draw its agents pill off an unwritten extension point. That is the behaviour
  those exports had before, so nothing regressed — but "Blank plus the
  explicitly imported room" (step 3) has to decide whether Blank carries the AI
  room, or whether an unwritten extension point is simply inert.
- **[2] The AI room's payload still lives in `den` and `hearth`.** Only
  ownership, the assertions and the contributions moved. `holt`, `agent-state`
  and the statusline are still system packages written by `den`; the clients,
  the instructions/skill files and the per-client hook wiring are still home
  ones written by `hearth`. Both are now gated on `haus.agents.enable`. Moving a
  package between a system and a home profile is an install change rather than a
  refactor, so it waits for step 4's projection comparator to prove it moved for
  free.
- **[2] Extension points are not yet the general mechanism.** `modules/lib/contrib.nix`
  and `haus._contrib.*` exist for exactly the three the AI room needs. The other
  cooperations the model names — Windows' workspace pills, Focus's controls,
  Bar's reserved space from Windows — still read each other's config directly.
  Generalising is worth doing on the next room that needs it, not speculatively.
- **[2] `sill`'s `hush` gate is the same shape and not yet on the seam.** The bar
  already special-cases `hush` (`name != "hush" || config.haus.hush.enable`)
  beside the new `contributed` predicate. Two spellings of one idea; folding
  `hush` in is a small, behaviour-preserving follow-up.
- **[1] `zscratch` left the agent switch.** It followed
  `developer.agents.enable` only because that is where the switch lived; nothing
  about a throwaway zellij session is about coding agents. It follows
  `developer.enable` now, beside `nixfmt`.

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

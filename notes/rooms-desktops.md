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

Not every top-level `haus.*` namespace is a room. Identity, keys, the app roster,
workspaces and shared macOS settings are cross-room configuration surfaces. The
current generated reference treating every namespace as one of “35 rooms” is an
implementation accident to replace with an explicit room registry.

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

A shareable desktop remains data-only:

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
not. A desktop receives no `pkgs`, `lib` or `config`, cannot add activation code,
and sets only public `haus.*` options. A full host evaluation proves that those
options and values are valid.

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

| Step | Status | Work | Exit gate |
|---|---|---|---|
| **0. Baseline** | ready | Inventory current modules, exported `darwinModules`, `haus.*` namespaces, enable switches, defaults and cross-room reads. Record which values are generic mechanism versus nebelhaus opinion. | The inventory accounts for every generated option group and names every behavior that must remain identical during the refactor. |
| **1. Room registry** | blocked by 0 | Add one explicit, generated room registry. Map implementation modules and option namespaces to the product rooms above without moving or renaming options. Make the host template and docs renderer consume it. | Generated output has no unclassified namespace, current option addresses are unchanged, and counts come from the registry rather than prose. |
| **2. AI proof** | blocked by 1 | Make AI the first declared cross-room capability. Move ownership out of `developer.agents` while preserving compatibility; expose contributions to Development, Bar and Launcher through explicit extension points. | AI alone brings clients, Holt and lifecycle wiring; its optional integrations appear only with their receiving rooms; current nebelhaus behavior and old addresses still evaluate. |
| **3. Desktop seam** | blocked by 2 | Add exactly-one-desktop selection, source attribution and host-wins priority. Keep the compatibility builder selecting nebelhaus implicitly. Do not design remote acquisition here. | A fixture proves one desktop is selected, a plain host assignment overrides it, a second desktop is rejected clearly, and the source filename survives diagnostics. |
| **4. Carve out nebelhaus** | blocked by 3 | In one atomic change, neutralize generic room defaults, add the real nebelhaus desktop and add the built-in Blank desktop. Keep `mkNebelhaus` and old option addresses as compatibility surfaces. | Existing nebelhaus builds are behaviorally identical; Blank enables no optional rooms; there is no commit on `main` where existing installs silently lose a room. |
| **5. Retire top-level fragments** | blocked by 4 | Move `large-print` under Appearance and `writing` under Apps. Keep temporary aliases where consumers need them; remove preset and pack from the top-level product vocabulary. | The same configurations remain expressible, migration warnings name replacements, and no docs invite users to stack whole desktops. |
| **6. Rebuild the docs journey** | blocked by 5 | Regenerate the reference from the registry and reorganize hausfold.co around Desktops first, then Rooms. Keep each desktop's own docs thin. | The landing page, docs navigation, generated reference and compatibility docs agree on the model and current option surface. |

Step 4 is deliberately indivisible at the behavior boundary. Neutral defaults,
the nebelhaus values that replace them and the compatibility selection must land
together even if preparatory refactors land earlier.

### Agent status report

Every agent working a step reports back in this shape, in commentary while work
is live and in the PR body when it is ready:

```text
Step: <number and name>
Status: not started | in progress | blocked | ready for review | done
Changed: <repos and the bounded outcome>
Verified: <commands run and observable result>
Findings:
- [impact 1–5] <new fact> — <consequence and recommendation>
Decisions needed: <only unresolved items at impact 3–5, with a recommendation>
Next: <the next concrete action or the next plan step now unblocked>
```

“Done” means the exit gate is proven, not merely that a diff exists. A blocker
names the failed gate and the evidence; it does not expand the step. Findings at
impact 1–2 may be resolved in scope when reversible. Findings at 3–5 are
reported with a recommendation before they change the architecture.

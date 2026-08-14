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
| **2. AI proof** | done | Make AI the first declared cross-room capability. Move ownership out of `developer.agents` while preserving compatibility; expose contributions to Development, Bar and Launcher through explicit extension points. | A named haus flake check covering AI alone and AI with each receiving room. Pair old and new addresses in fixtures that compare behavioral projections, warnings and plain-host-override priority. | AI alone brings clients, Holt and lifecycle wiring; its optional integrations appear only with their receiving rooms; old and new addresses produce identical behavior and precedence, with the intended migration warning only. |
| **3. Desktop seam** | done | Add exactly-one-desktop selection, source attribution, closed-schema validation, recursive desktop-safety enforcement and host-wins priority. Keep the full compatibility builder selecting nebelhaus implicitly. Preserve standalone `darwinModules` imports as Blank plus the explicitly imported room; they do not acquire nebelhaus opinions. Do not design remote acquisition here. | A named haus flake check with positive fixtures for one desktop, host override, every supported builder/module entry point and source diagnostics; negative fixtures for two desktops, module functions, `imports`, `_module`, extra top-level keys, `system.activationScripts`, unknown options, unsafe dynamic payloads and every class of host-only leaf. | One desktop is selected through a full builder; a plain host assignment overrides it; a second is rejected clearly; standalone room imports retain their current behavior without requiring a desktop selection; source filenames survive diagnostics; only the closed `{ haus = { … }; }` value reaches option evaluation. |
| **4. Carve out nebelhaus** | done | In one atomic change, neutralize generic room defaults, add the real nebelhaus desktop and add the built-in Blank desktop. Keep `mkNebelhaus`, every supported builder/module entry point and old option addresses as compatibility surfaces. | Commit the **projection schema and comparator**, plus the complete non-sensitive example projection. For the real consumer, compare full projections only in an ephemeral directory and commit/report only the equality result—never values, counts, hashes, host paths or serialized output. Add a Blank fixture; run `nix flake check` and `bench try`. PR commands use placeholders/environment variables and redact local paths. | Existing nebelhaus example and real-consumer projections compare equal; Blank enables no optional rooms; every prior public entry point passes its compatibility fixture; no consumer-derived values or paths enter git, logs or the PR; there is no commit on `main` where existing installs silently lose a room. |
| **5. Retire top-level fragments** | done | Move `large-print` under Appearance and `writing` under Apps. Keep temporary aliases where consumers need them; remove preset and pack from the top-level product vocabulary. | Compatibility fixtures evaluating old and new spellings to the same values, plus generated migration documentation. | The same configurations remain expressible, migration warnings name replacements, and no docs invite users to stack whole desktops. |
| **6. Rebuild the docs journey** | done | Regenerate the reference from the registry and reorganize hausfold.co around Desktops first, then Rooms. Keep each desktop's own docs thin. | Committed site-data artifacts, `npm run build` in hausfold.co, docs/palette checks, and links or screenshots for the Desktops and Rooms navigation states. | The landing page, docs navigation, generated reference and compatibility docs agree on the model and current option surface. |

Step 4 is deliberately indivisible at the behavior boundary. Neutral defaults,
the nebelhaus values that replace them and the compatibility selection must land
together even if preparatory refactors land earlier.

### Findings carried out of step 2

Reported rather than folded into that step's scope, because each one changes
what a LATER step has to do.

- **[3] The AI room defaults to another room's switch.** `haus.ai.enable`
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
  ones written by `hearth`. Both are now gated on `haus.ai.enable`. Moving a
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
- **[2] The room took the whole namespace, with no aliases.** `haus.agents.*`
  became `haus.ai.*` and `haus.developer.agents.enable` became `haus.ai.enable`;
  neither old spelling is aliased. The rice has one consumer and its host moved
  in the same change, so an alias set for a five-day-old spelling would be
  permanent furniture bought to protect nobody. The `nebelhaus.*` aliases still
  resolve — they were repointed at `haus.ai.*`, since an alias follows its option
  rather than being re-created at every address it passes through.

### Findings carried out of step 3

The seam is built and empty: `mkNebelhaus` selects `desktops/nebelhaus.nix`, that
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
is what the inventory's "54 nebelhaus opinions" turned out to be once each one
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
  requirement. `hearth.editor` is host-only (it is executed) AND the layer
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
  so.** `test/desktops/valid-sample.nix` set `sill.enable = false` to prove a
  desktop outranked a `true` room default. Step 4 made `false` the default, so
  the row asserted nothing and would have passed with the desktop seam entirely
  disconnected. It is `true` now. Worth a sweep of the other fixtures whenever
  a default moves under them.
- **[2] `nix fmt` reformats whole files, so it cannot be run casually on this
  repo mid-change.** It rewrote ~700 unrelated lines of
  `modules/hearth/default.nix` around a one-line edit. Format the touched files
  with `nixfmt` directly, or the diff stops being reviewable.
- **[1] The docs asserted layer-wide defaults in prose.** Three guides said a
  room was "on by default" — true of nebelhaus, false of `haus` now. Fixed in
  the same change; the generated options reference regenerates itself.

### Findings carried out of step 5

The vocabulary was the easy half. What the step actually surfaced is that
"preset" had been hiding two different things, and only one of them was a
desktop.

- **[3] `everyday` and `minimal` as desktops are not the machines the presets
  produced, and cannot be.** A preset was a LAYER: four lines on top of whichever
  whole rice you had selected, so `presets.everyday` meant "nebelhaus, minus the
  developer tooling". A desktop is the complete selection, so the new
  `desktops/everyday.nix` has to state the ~10 values the preset silently
  inherited from nebelhaus. One of them changes on purpose: the AI room is OFF
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
  It emits `desktop = nebelhaus.desktops.$NAME` now, `NEBELHAUS_DESKTOP` is the
  knob, and `NEBELHAUS_PRESET=full` still maps to the nebelhaus desktop. Worth a
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
  answer is yes for the whole rices and no for the layer. What remains is a
  desktop (closed schema, registry-validated, one per host) and a pack (data,
  `haus.roster` only, `checkRice`/`checkPack`). `checkRice` no longer guards
  anything a person selects — only pack files — which is a smaller job than it
  had and worth remembering when its message is next edited.
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

- **[3] Nothing owned "may a desktop choose the editor?" — ANSWERED, 2026-08-14
  (haus#347, hausfold.co#34).** Step 4 handed this to "step 5 or 6" and neither
  took it. Half of it had resolved on its own: `haus.fonts.mono.name` and
  `.packageName` are `desktopSafe: true` in the registry, so a desktop could
  already name a font family — the patched-Nerd-Font rule is a requirement at
  the option, not a trust boundary. The editor half needed the enum this note
  predicted: `haus.hearth.editorName` (helix | neovim | vim | nano) is the
  desktop-safe half, and `hearth.editor` keeps its type, its host-only
  classification and the last word — it just defaults to the chosen editor's
  command now. Two things worth carrying forward from doing it:
  **the enum had to move four things, three of them silently** — the package,
  `$EDITOR`, the Nebelung theme file and whether the room claims the `helix`
  port for `haus doctor` — which is why it got a check that reads all four back
  off evaluated machines rather than a type and a hope. And **the installer was
  writing the wrong half again**: `bootstrap.sh` offered `hx/nvim/vim/nano` and
  scaffolded `hearth.editor`, so a fresh machine answering `nvim` got
  `$EDITOR=nvim` and no neovim. That is step 5's own finding — grep the
  installer whenever a public spelling changes — hitting for the second time in
  a week, which is a habit rather than a coincidence.
- **[2] A desktop still outranks a pack the consumer composed themselves.**
  Verified in merged `flake.nix`: `desktopPriority = 900`, while `lib.pack`
  carries its file in at per-leaf `mkDefault` (1000). Step 3 left it alone as
  unobservable and it still is, but only by luck — `desktops/nebelhaus.nix` sets
  no `haus.roster`, so the first desktop that names an app silently beats a pack
  the host explicitly imported. Moving the pack seam to a priority between 100
  and 900 is one token; the fixture that can see the difference is the work.
- **[2] The generated reference names a validator; the key rule it enforces is
  hand-written prose somewhere else.** `groups.json` ships `haus.displays` as
  `{"desktopSafe": "recursive", "validator": "display-selectors"}`. A reader is
  not stranded — `/docs/haus/desktops/creating/` explains in words that a
  display UUID is host-only and that attrsets carry per key — but exactly one of
  those two statements is generated, so they can now drift apart. Step 3
  predicted this against step 6; step 6 rendered rooms and left it standing.
- **[2] The AI room's payload still lives in `den` and `hearth`.** `modules/ai`
  is still `default.nix` + `options.nix` — ownership, assertions and
  contributions only. Step 2 deferred the move until a comparator could prove it
  free; `desktop-projection` has existed since step 4, so `holt`, `agent-state`,
  the statusline and the client/hook files can now move under proof.
- **[2] The bar spells one gate three ways.** `contributed`,
  `name != "hush" || config.haus.hush.enable` in `bottomGroup`, and `topHush`
  all answer "does this pill's source exist?" — checked, and there is no bug:
  `topHush` covers the top bar that `bottomGroup`'s filter does not. The cost is
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

# Rooms and desktops: implementation inventory

Step 0 baseline, 2026-08-13. This inventory describes `haus` at
`66a128957f1dc8687c69a7f6dbbb57d8cb86be8d` (`v2026.08.13`, `origin/main`).
It is classification evidence for `notes/rooms-desktops.md`; it changes no
runtime behavior.

## Baseline result

The bounded surface contains:

- 9 exported `darwinModules`: 1 self-contained aggregate and 8 legacy partial
  exports;
- 17 option modules, including the rename and move aliases;
- 237 generated public option entries in 35 top-level `haus.*` namespaces;
- 34 generated group records — `zen` is the one namespace with no record;
- 25 public paths ending in `.enable`;
- 142 lexical `config.haus.<namespace>` matches in implementation Nix files;
- 189 desktop-safe entries, 40 host-only entries and 8 recursively classified
  containers/dynamic entries under the baseline rules below;
- 54 defaults that encode a nebelhaus opinion and 183 generic mechanism or
  conservative defaults.

“Entry” means one record in generated `options.json`. Parent container options
therefore count alongside their reachable sub-options. The safety table treats
those parents transitively rather than pretending that a safe parent blesses an
unsafe child.

## Bounded source and reproduction

Run these commands from a clean checkout of the recorded haus revision. They
are the exact source boundary from the execution plan.

```sh
git fetch origin main
git switch --detach 66a128957f1dc8687c69a7f6dbbb57d8cb86be8d

git rev-parse HEAD
sed -n '/darwinModules = {/,/};/p' flake.nix
sed -n '1,240p' modules/options-modules.nix
sed -n '1,320p' modules/options-groups.nix
find modules -maxdepth 2 -type f -name 'options.nix' -print | sort
rg -n --no-heading 'config\.haus(?:\.[A-Za-z_][A-Za-z0-9_-]*)+' modules --glob '*.nix'

nix eval .#darwinModules --apply builtins.attrNames --json
nix eval --impure --expr 'builtins.length (import ./modules/options-modules.nix)'
jq 'length' docs/site-data/options.json
jq -r 'keys[] | split(".")[1]' docs/site-data/options.json | sort -u | wc -l
jq 'length' docs/site-data/groups.json
jq -r '[to_entries[] | select(.key | endswith(".enable"))] | length' \
  docs/site-data/options.json
rg -n -o --no-heading 'config\.haus\.[A-Za-z_][A-Za-z0-9_-]*' \
  modules --glob '*.nix' | wc -l

site_data_out=$(nix build .#site-data --no-link --print-out-paths)
cmp "$site_data_out/options.json" docs/site-data/options.json
cmp "$site_data_out/groups.json" docs/site-data/groups.json
```

The final two `cmp` commands exit zero at the recorded revision. The committed
JSON is therefore the evaluated surface used for all counts below, not a stale
render.

The per-namespace count is reproduced with:

```sh
jq -r '
  [to_entries[] | .key | split(".")[1]]
  | group_by(.)
  | map({ namespace: .[0], entries: length })
  | sort_by(.namespace)[]
  | [.namespace, .entries] | @tsv
' docs/site-data/options.json
```

## Public module and entry-point inventory

`flake.nix` exports these `darwinModules` and no others:

| Export | Source | Product ownership | Current standalone result |
|---|---|---|---|
| `default` | `modules/` | compatibility aggregate: foundation plus every current implementation module | evaluates |
| `den` | `modules/den` | foundation plus pieces now owned by Appearance, Development, Bar, Security and host policy | fails: `config.haus` is undeclared |
| `hearth` | `modules/hearth` | Development, with AI and Appearance reads | fails: `haus` option does not exist |
| `prowl` | `modules/prowl` | Windows | fails: `haus` option does not exist |
| `sill` | `modules/sill` | Bar | fails: `haus` option does not exist |
| `collar` | `modules/collar` | Security | fails: `config.haus` is missing |
| `pounce` | `modules/pounce` | Launcher | fails: `haus` option does not exist |
| `hush` | `modules/hush` | Focus | fails: `config.haus` is missing |
| `secrets` | `modules/secrets` | Security | fails: `config.haus` is missing |

The eight partial exports import implementation only. Their declarations live
in the separate `modules/options-modules.nix` list, which only `default` imports.
The flake comment saying a caller may “cherry-pick a room” is therefore not true
at this revision. `perch` is additionally named as a cherry-pickable module in
`modules/default.nix` but is not exported at all.

The standalone result above used the same platform, overlays, Home Manager
module and special arguments as `mkNebelhaus`, but replaced `default` with one
export at a time:

```sh
for module_name in $(nix eval .#darwinModules --apply builtins.attrNames --json | jq -r '.[]'); do
  printf '%s\t' "$module_name"
  INVENTORY_MODULE="$module_name" nix eval --impure --raw --expr '
    let
      moduleName = builtins.getEnv "INVENTORY_MODULE";
      f = builtins.getFlake (toString ./.);
      inherit (f) inputs;
      system = "aarch64-darwin";
      username = "you";
      hostname = "example";
    in
    (inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit inputs username hostname; };
      modules = [
        { nixpkgs.hostPlatform = system; system.stateVersion = 7; }
        {
          nixpkgs.overlays = [
            inputs.pounce.overlays.default
            inputs.perch.overlays.default
            inputs.holt.overlays.default
          ];
        }
        inputs.home-manager.darwinModules.home-manager
        {
          users.users.${username} = {
            name = username;
            home = "/Users/${username}";
          };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit username inputs;
            nebelung = {
              themes = inputs.nebelung.packages.${system}.default;
              palette = inputs.nebelung.palette;
              palettes = inputs.nebelung.palettes;
              ports = inputs.nebelung.ports or { };
            };
          };
          home-manager.sharedModules = [
            inputs.catppuccin.homeModules.catppuccin
            inputs.nix-index-database.homeModules.nix-index
          ];
        }
        f.darwinModules.${moduleName}
      ];
    }).system.drvPath
  ' >/dev/null && echo ok || echo fails
done
```

Other public composition surfaces that later steps must preserve are:

| Surface | Current members/behavior |
|---|---|
| `mkNebelhaus` | imports overlays, Home Manager, `darwinModules.default`, the host, machine-written `packages/*.nix` and `settings/*.nix`, then `extraModules` |
| `presets` | `everyday`, `full`, `large-print`, `minimal` as data-only paths |
| `packs` / `packFiles` | wrapped `writing` module / unwrapped `writing` path |
| `lib` | `checkRice`, `checkPack`, `pack`, `riceBody`, `riceNamespaces` |
| namespace compatibility | `nebelhaus.*` leaves alias to `haus.*`; moved `haus.claude.*` leaves alias to `haus.agents.*`, both with warnings |

### Complete implementation aggregate

`modules/default.nix` imports all 17 declaration modules, then these 19
implementation units:

| Unit | Behavior that must remain observable through the compatibility builder |
|---|---|
| `workspaces` | normalize named workspaces and app membership; enforce membership/key uniqueness |
| `roster` | normalize and install roster entries; feed launchers, window rules, pills, theme ports and App Store policy |
| `apps` | contribute the chosen video player and its file associations |
| `den` | macOS defaults, system/Homebrew foundation, fonts, core packages, GC and the haus/awake/zscratch/statusline/activation CLIs |
| `displays` | resolve semantic display scale and apply it through `hausdisp` |
| `theme` | resolve Nebelung flavor/contrast/accent and macOS appearance |
| `theme/ports.nix` | deploy supported app themes for roster entries |
| `wallpaper` | build, install and select the configured desktop picture |
| `hearth` | terminal, shell, editor, Git, CLI toolbelt, language runtime and agent client wiring |
| `hearth/zen.nix` | deploy Zen extension policy |
| `hearth/zen-tabs` | build/deploy the optional Zen native tab bridge |
| `prowl` | AeroSpace tiling, workspace routing, window navigation and leader bindings |
| `sill` | top/bottom SketchyBar services, pills, popups, status hooks and first-run tour |
| `collar` | Touch ID sudo and optional passwordless activation |
| `pounce` | Pounce app/daemon, stable signing copy, palette commands, hotkey and integrations |
| `perch` | Perch app installation and appearance configuration |
| `hush` | Focus toggle engine, Slack integration, hooks and optional bar updates |
| `secrets` | secretspec package and host-selected provider config |
| `snippets` | espanso package/config for declared text expansions |

This table is the behavioral projection boundary for the refactor. A behavior
may move to a different room or extension point, but `mkNebelhaus` must still
produce it until the compatibility surface is deliberately retired.

## Namespace classification

The proposed registry classification is below. “Room” means one product room
owns the namespace even when other rooms read it. “Shared” means it is an
extension surface with several consumers. “Host” means machine/person policy,
not a room a desktop selects. Safety is independent: `safe/host/recursive`
counts partition the generated entries in that row.

| Namespace | Entries | Kind | Product owner | Safe / host / recursive | Opinion defaults |
|---|---:|---|---|---:|---:|
| `accessibility` | 2 | room | Appearance | 2 / 0 / 0 | 0 |
| `agents` | 4 | room | AI | 3 / 1 / 0 | 2 |
| `animations` | 1 | room | Appearance | 1 / 0 / 0 | 0 |
| `appStore` | 1 | room | Apps | 1 / 0 / 0 | 0 |
| `apps` | 2 | room | Apps | 2 / 0 / 0 | 2 |
| `collar` | 2 | room | Security | 2 / 0 / 0 | 2 |
| `developer` | 5 | room | Development | 5 / 0 / 0 | 3 |
| `displays` | 2 | room | Displays | 1 / 0 / 1 | 0 |
| `fonts` | 4 | room | Appearance | 3 / 1 / 0 | 2 |
| `git` | 5 | host | host identity/work scope | 0 / 5 / 0 | 0 |
| `hearth` | 7 | room | Development | 5 / 2 / 0 | 4 |
| `homebrew` | 3 | room | Apps | 3 / 0 / 0 | 0 |
| `hotCorners` | 4 | room | Windows | 4 / 0 / 0 | 0 |
| `hush` | 7 | room | Focus | 5 / 2 / 0 | 1 |
| `keys` | 7 | shared | keyboard extension surface | 5 / 1 / 1 | 3 |
| `locale` | 6 | host | host locale | 0 / 6 / 0 | 0 |
| `lock` | 2 | room | Security | 2 / 0 / 0 | 0 |
| `menuBar` | 12 | room | Bar | 12 / 0 / 0 | 0 |
| `perch` | 2 | room | Shelf | 2 / 0 / 0 | 1 |
| `pounce` | 14 | room | Launcher | 12 / 1 / 1 | 2 |
| `power` | 8 | host | host power policy | 0 / 8 / 0 | 0 |
| `prowl` | 1 | room | Windows | 1 / 0 / 0 | 1 |
| `roster` | 16 | shared | app/package roster | 13 / 2 / 1 | 0 |
| `screenshots` | 5 | room | Appearance | 4 / 1 / 0 | 0 |
| `secrets` | 1 | room | Security | 0 / 1 / 0 | 0 |
| `security` | 5 | room | Security | 5 / 0 / 0 | 0 |
| `sill` | 59 | room | Bar | 56 / 2 / 1 | 13 |
| `snippets` | 4 | room | Text expansion | 3 / 0 / 1 | 0 |
| `sound` | 5 | room | Appearance | 5 / 0 / 0 | 0 |
| `theme` | 5 | room | Appearance | 5 / 0 / 0 | 4 |
| `tour` | 4 | shared | first-run extension surface | 3 / 0 / 1 | 1 |
| `ui` | 1 | shared | semantic interface scale | 1 / 0 / 0 | 0 |
| `wallpaper` | 19 | room | Appearance | 19 / 0 / 0 | 13 |
| `workspaces` | 4 | shared | window/app/bar workspace model | 3 / 0 / 1 | 0 |
| `zen` | 8 | room | Development | 1 / 7 / 0 | 0 |
| **Total** | **237** | 27 room / 5 shared / 3 host | 12 rooms plus host/shared surfaces | **189 / 40 / 8** | **54** |

The current `groups.json` has one row for every namespace above except `zen`.
That is permitted by today's renderer fallback, but Step 1 must make it an
error rather than silently sorting an unclassified namespace last.

## Desktop-safety classification

The 237 generated entries are partitioned by these ordered rules. This is the
input decision for Step 1's recursive validator; it is not inferred from a
namespace label.

### Host-only entries (40)

| Path/pattern | Count | Reason |
|---|---:|---|
| `haus.git.*` | 5 | personal/work identity and executable shell aliases |
| `haus.power.*` | 8 | machine-specific battery/charger policy |
| `haus.locale.*` | 6 | person/host locale |
| `haus.agents.instructions` | 1 | instruction injection reaches code-running agents |
| `haus.fonts.mono.package` | 1 | evaluated package value; `packageName` is the safe data seam |
| `haus.hearth.{editor,obsidianVaults}` | 2 | executed command and host-relative paths |
| `haus.hush.{hooks,slack.tokenCommand}` | 2 | executed paths/commands |
| `haus.keys.leaderExtras.*.command` | 1 | executed command string |
| `haus.pounce.signingIdentity` | 1 | host signing identity |
| `haus.roster.<name>.{installedBy,package}` | 2 | implementation-owned marker and evaluated package value |
| `haus.screenshots.location` | 1 | personal filesystem location |
| `haus.secrets.provider` | 1 | host secret-infrastructure choice |
| `haus.sill.{calendar.me,elgato.host}` | 2 | personal identity and physical/network coordinate |
| `haus.zen.extensions` plus its five reachable child entries | 6 | downloads executable browser code; the container is transitively unsafe |
| `haus.zen.extraPolicies` | 1 | unconstrained freeform attrset |

### Recursive/dynamic entries (8)

| Path | Rule |
|---|---|
| `haus.displays` | validate selector keys recursively; `internal` and `main` are desktop-safe while a UUID is host-only |
| `haus.keys.leaderExtras` | empty is safe; any valid entry reaches the host-only required `command` leaf |
| `haus.pounce.items` | validate each launcher item against its closed submodule schema |
| `haus.roster` | arbitrary entry names are allowed, but every child is checked; `package` and `installedBy` remain host-only |
| `haus.sill.media.icons` | validate arbitrary icon keys with string-only values |
| `haus.snippets.matches` | validate each match against its closed submodule schema |
| `haus.tour.steps` | validate each tour step against its closed submodule schema |
| `haus.workspaces` | validate arbitrary workspace names against their closed entry schema |

Every other generated entry is desktop-safe (189). In particular, constrained
roster source names (`cask`, `brew`, `packageName`, `appStoreId`), finite enums,
plain presentation strings, built-in room switches and recursively closed
submodules remain expressible by a desktop.

The counts can be reproduced directly from the generated keys:

```sh
jq '
  def host_only:
    (.key | startswith("haus.git."))
    or (.key | startswith("haus.power."))
    or (.key | startswith("haus.locale."))
    or (.key == "haus.agents.instructions")
    or (.key == "haus.fonts.mono.package")
    or (.key == "haus.hearth.editor")
    or (.key == "haus.hearth.obsidianVaults")
    or (.key == "haus.hush.hooks")
    or (.key == "haus.hush.slack.tokenCommand")
    or (.key == "haus.keys.leaderExtras.*.command")
    or (.key == "haus.pounce.signingIdentity")
    or (.key == "haus.roster.<name>.installedBy")
    or (.key == "haus.roster.<name>.package")
    or (.key == "haus.screenshots.location")
    or (.key == "haus.secrets.provider")
    or (.key == "haus.sill.calendar.me")
    or (.key == "haus.sill.elgato.host")
    or (.key | startswith("haus.zen.extensions"))
    or (.key == "haus.zen.extraPolicies");
  def recursive:
    (.key == "haus.displays")
    or (.key == "haus.keys.leaderExtras")
    or (.key == "haus.pounce.items")
    or (.key == "haus.roster")
    or (.key == "haus.sill.media.icons")
    or (.key == "haus.snippets.matches")
    or (.key == "haus.tour.steps")
    or (.key == "haus.workspaces");
  to_entries | {
    host_only: ([.[] | select(host_only)] | length),
    recursive: ([.[] | select(recursive)] | length),
    desktop_safe: ([.[] | select((host_only or recursive) | not)] | length),
    total: length
  }
' docs/site-data/options.json
```

## Default-value classification

Defaults are classified independently from safety. A host-only leaf can still
have a generic empty default; a desktop-safe leaf can still carry a strong
nebelhaus opinion that Step 4 must move into the nebelhaus desktop.

These 54 generated defaults encode nebelhaus opinion:

| Paths | Count | Opinion |
|---|---:|---|
| `agents.{clients,default}` | 2 | chosen clients and primary client |
| `apps.videoPlayer.*` | 2 | chosen app and file ownership |
| `collar.*` | 2 | Touch ID/passwordless activation policy |
| `developer.{enable,agents.enable,languages}` | 3 | developer-first machine, AI coupling and Node runtime |
| `fonts.mono.{name,size}` | 2 | typeface and tuned size |
| `hearth.{editor,floatBorder,rightClickFullscreen,zellijStartLocked}` | 4 | editor and terminal interaction model |
| `hush.enable` | 1 | Focus room selected |
| `keys.{leader,palette,windowNav}` | 3 | global remaps |
| `perch.enable` | 1 | Shelf selected |
| `pounce.{enable,windowMode}` | 2 | Launcher selected and compact presentation |
| `prowl.enable` | 1 | Windows selected |
| `sill.enable`, `sill.position`, `sill.clock.mode`, the five true `sill.items.*` leaves and five interactive/logo leaves | 13 | Bar selected, placed and curated |
| `theme.{accent,contrast,flavor,ports.enable}` | 4 | Nebelung appearance and app theming |
| `tour.enable` | 1 | first-run tutor selected |
| `wallpaper.{style,size,depth,grain}`, three active `glow` values and all six `mark` values | 13 | generated nebelhaus desktop art |

All other 183 defaults are generic mechanism or conservative no-op values. That
includes empty containers, nullable macOS settings, disabled optional features,
derived values such as Pounce following `ui.scale`, receiver behavior such as
Perch following system appearance, and submodule defaults that make an explicitly
declared entry useful.

The opinion/mechanism count is reproduced with this exact predicate:

```sh
jq '
  def opinion:
    (.key == "haus.agents.clients") or (.key == "haus.agents.default")
    or (.key | startswith("haus.apps.videoPlayer."))
    or (.key | startswith("haus.collar."))
    or (.key == "haus.developer.enable")
    or (.key == "haus.developer.agents.enable")
    or (.key == "haus.developer.languages")
    or (.key == "haus.fonts.mono.name") or (.key == "haus.fonts.mono.size")
    or (.key == "haus.hearth.editor") or (.key == "haus.hearth.floatBorder")
    or (.key == "haus.hearth.rightClickFullscreen")
    or (.key == "haus.hearth.zellijStartLocked")
    or (.key == "haus.hush.enable")
    or (.key == "haus.keys.leader") or (.key == "haus.keys.palette")
    or (.key == "haus.keys.windowNav")
    or (.key == "haus.perch.enable")
    or (.key == "haus.pounce.enable") or (.key == "haus.pounce.windowMode")
    or (.key == "haus.prowl.enable")
    or (.key == "haus.sill.enable") or (.key == "haus.sill.position")
    or (.key == "haus.sill.clock.mode")
    or (.key == "haus.sill.items.battery") or (.key == "haus.sill.items.clock")
    or (.key == "haus.sill.items.media") or (.key == "haus.sill.items.weather")
    or (.key == "haus.sill.items.wifi")
    or (.key == "haus.sill.logo.gestures") or (.key == "haus.sill.logo.icon")
    or (.key == "haus.sill.logo.size") or (.key == "haus.sill.logo.status")
    or (.key == "haus.sill.logo.sweep")
    or (.key == "haus.theme.accent") or (.key == "haus.theme.contrast")
    or (.key == "haus.theme.flavor") or (.key == "haus.theme.ports.enable")
    or (.key == "haus.tour.enable")
    or (.key == "haus.wallpaper.style") or (.key == "haus.wallpaper.size")
    or (.key == "haus.wallpaper.depth") or (.key == "haus.wallpaper.grain")
    or (.key == "haus.wallpaper.glow.enable")
    or (.key == "haus.wallpaper.glow.spread")
    or (.key == "haus.wallpaper.glow.strength")
    or (.key | startswith("haus.wallpaper.mark."));
  to_entries | {
    nebelhaus_opinion: ([.[] | select(opinion)] | length),
    generic_mechanism: ([.[] | select(opinion | not)] | length),
    total: length
  }
' docs/site-data/options.json
```

## Enable switches and current defaults

The generated surface has these 25 `.enable` paths:

| Path | Current default | Classification |
|---|---|---|
| `haus.apps.videoPlayer.enable` | `true` | nebelhaus opinion |
| `haus.collar.enable` | `true` | nebelhaus opinion |
| `haus.developer.agents.enable` | `config.haus.developer.enable` | nebelhaus opinion; current AI coupling |
| `haus.developer.enable` | `true` | nebelhaus opinion |
| `haus.developer.git.enable` | `config.haus.developer.enable` | Development mechanism |
| `haus.developer.toolbelt.enable` | `config.haus.developer.enable` | Development mechanism |
| `haus.hearth.ghDash.enable` | `false` | conservative mechanism |
| `haus.hush.enable` | `true` | nebelhaus opinion |
| `haus.hush.slack.enable` | `false` | conservative mechanism |
| `haus.perch.enable` | `true` | nebelhaus opinion |
| `haus.pounce.autoQuit.enable` | `false` | conservative mechanism |
| `haus.pounce.enable` | `true` | nebelhaus opinion |
| `haus.prowl.enable` | `true` | nebelhaus opinion |
| `haus.roster.<name>.enable` | `true` | declared-entry mechanism |
| `haus.security.firewall.enable` | `null` | unmanaged mechanism |
| `haus.sill.bottom.enable` | `false` | conservative mechanism |
| `haus.sill.enable` | `true` | nebelhaus opinion |
| `haus.snippets.enable` | `false` | conservative mechanism |
| `haus.theme.ports.enable` | `true` | nebelhaus opinion |
| `haus.tour.enable` | `true` | nebelhaus opinion |
| `haus.wallpaper.debug.enable` | `false` | conservative mechanism |
| `haus.wallpaper.glow.enable` | `true` | nebelhaus opinion |
| `haus.wallpaper.mark.enable` | `true` | nebelhaus opinion |
| `haus.zen.extensions.<name>.enable` | `true` | declared-entry mechanism, host-only subtree |
| `haus.zen.tabBridge.enable` | `false` | conservative built-in integration |

The rooms vision wants one visible switch per room. This inventory deliberately
does not pretend the current 25 paths already supply those 12 switches: several
rooms have no aggregate enable, and several `.enable` leaves are subfeatures or
dynamic-entry controls.

## `config.haus` lexical dependency inventory

This is the exact bounded `rg` scan grouped by source directory and referenced
top-level namespace. Counts include comments and generated prose containing the
literal spelling; the behavioral edges below are the executable subset.

| Source | Referenced namespaces (lexical count) |
|---|---|
| `apps` | `apps(1)` |
| `collar` | `collar(1)` |
| `den` | `accessibility(1)`, `animations(1)`, `developer(1)`, `fonts(1)`, `homebrew(1)`, `hotCorners(2)`, `locale(1)`, `lock(1)`, `menuBar(2)`, `power(1)`, `screenshots(1)`, `security(1)`, `sill(2)`, `sound(1)`, `ui(4)` |
| `displays` | `displays(1)` |
| `hearth` | `_appWorkspace(1)`, `_launchers(1)`, `agents(1)`, `developer(2)`, `fonts(3)`, `git(2)`, `hearth(1)`, `hush(1)`, `keys(3)`, `perch(1)`, `pounce(1)`, `prowl(1)`, `roster(1)`, `sill(1)`, `snippets(1)`, `theme(4)`, `ui(1)`, `zen(2)` |
| `hush` | `hush(1)`, `sill(2)` |
| `lib` | `fonts(1)`, `keys(1)`, `sill(1)`, `ui(2)` |
| `options.nix` | `developer(8)` |
| `perch` | `perch(2)`, `theme(2)` |
| `pounce` | `_launchers(1)`, `agents(4)`, `developer(1)`, `hearth(2)`, `hush(2)`, `keys(2)`, `pounce(10)`, `theme(1)`, `ui(1)` |
| `prowl` | `_appWorkspace(1)`, `_launchers(1)`, `_roster(1)`, `_workspaces(1)`, `keys(2)`, `prowl(1)`, `sill(1)`, `tour(1)`, `ui(1)` |
| `roster` | `_appWorkspace(1)`, `appStore(1)`, `roster(1)` |
| `secrets` | `secrets(1)` |
| `sill` | `_appWorkspace(1)`, `_launchers(1)`, `_pounceCommands(1)`, `_workspaces(1)`, `fonts(1)`, `hush(2)`, `keys(1)`, `pounce(3)`, `prowl(2)`, `sill(8)`, `theme(1)`, `tour(2)`, `ui(1)` |
| `snippets` | `snippets(1)` |
| `theme` | `theme(3)` |
| `wallpaper` | `wallpaper(1)` |
| `workspaces` | `roster(1)`, `workspaces(1)` |

The executable cross-room behavior that must survive extraction into extension
points is:

- Development currently turns its Git/toolbelt/language/AI subfeatures on and
  Den/Hearth consume those decisions.
- AI currently contributes client packages, instruction/skill files, Holt
  lifecycle wiring, Zellij bindings, Pounce commands and Sill agent/usage UI
  through direct reads spread across Hearth, Pounce and Sill.
- Windows, Bar and Launcher all consume the shared roster, workspaces and keymap.
- Bar directly consumes Windows state, Launcher availability, Focus state,
  Appearance tokens/font/scale and Tour state.
- Focus directly updates either Bar instance when present.
- Launcher directly consumes AI, Focus, Development, Hearth and Appearance
  state to filter commands and configure Pounce.
- Shelf consumes Appearance flavor/contrast/accent.
- Windows consumes Bar geometry/enablement, Tour state and UI scale.
- Den hides the native menu bar when Bar is enabled and scales its own defaults
  from `ui.scale`.
- Apps and room modules contribute roster/install metadata; App Store policy is
  applied by the roster implementation.

## Preservation contract for Steps 1–4

Until the atomic Step 4 carve-out, refactors must preserve all of the following:

1. Every generated option address, type, default, description, warning and
   merge priority represented by the 237-entry surface.
2. `mkNebelhaus` composition, including host-written modules and the rule that
   ordinary host assignments beat option defaults without `mkForce`.
3. The complete implementation aggregate and every observable effect in its
   module table above.
4. The `nebelhaus.*` and moved `haus.claude.*` compatibility aliases and their
   warnings.
5. Preset/pack evaluation, pack per-leaf `mkDefault` behavior and the public
   helper functions.
6. Shared roster/workspace/key invariants and every executable cross-room edge
   above, even when the implementation changes to explicit contributions.
7. Standalone export behavior as actually measured: only `default` evaluates
   today. Changing the eight partials from failure to usable Blank-plus-room
   modules is a public bug fix, not behavior preservation, and needs an explicit
   roadmap decision.

## Findings

- **[3/5] All eight partial `darwinModules` exports fail standalone** — Step 3's
  instruction to “retain their current behavior” has no successful behavior to
  preserve. Recommendation: make them self-contained and add one eval fixture
  per export in Step 1, before the desktop seam relies on their classification.
- **[2/5] `zen` is the 35th namespace but the 34-record group data omits it** —
  Step 1's exhaustive registry check should make this impossible.
- **[2/5] `perch` is documented as a cherry-pickable module but is not exported**
  — classify that as stale documentation now; decide whether Shelf gains an
  export when the registry defines the supported public set.

## Step status

```text
Step: 0. Baseline
Status: done
Changed: workshop — committed reproducible inventory of the haus public surface
Why: the room registry and desktop trust boundary need an exhaustive source-of-truth baseline
Verified: recorded commands at haus 66a128957f1dc8687c69a7f6dbbb57d8cb86be8d; site-data cmp clean; counts partition 237 entries
Findings:
- [3/5] eight partial darwinModules exports fail standalone — fix and fixture them in Step 1
- [2/5] zen has no group record — registry completeness check must reject this
- [2/5] perch is documented but not exported — align documentation/public set in Step 1
Watch-outs: classification is baseline design input, not a generated registry yet; Step 1 must make the counts executable
Decisions needed: whether Step 1 fixes the broken partial exports; recommended yes, before desktop selection depends on them
Next: Step 1 expands options-groups.nix into the executable registry and consumes these classifications
```

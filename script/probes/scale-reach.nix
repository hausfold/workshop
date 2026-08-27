# scale-reach — what `haus.ui.scale` actually reaches, and where it stops.
#
# Evidence for options-roadmap.md §5.2. That section carries two claims nobody
# had measured: (1) "any option whose unit is points is silently coupled to
# `haus.displays`, because a display mode changes what a point means —
# worth auditing `fonts.*.size` and prowl's gaps for the same interaction", and
# (2) an "honest scope" paragraph naming what `ui.scale` does and does not move.
# §5.14 lists both as findings that ought to leave a CHECK behind rather than a
# paragraph.
#
#   nix-instantiate --eval --strict --json script/probes/scale-reach.nix \
#     --arg rice /Users/you/code/workshop/hausfold
#
# (Same argument convention as pack-priority.nix / preset-composition.nix: a
# workshop worktree cannot see the sibling repos, and `nix eval --file` ignores
# `--arg`.)
#
# Unlike those two this is NOT pure lib — `numeric` is, but `reach` evaluates
# four whole darwin systems, so it is a macOS-only probe and its rice-side
# descendant is darwin-guarded beside `accent-reach`. Four evaluations run in
# well under a minute warm.
#
# ---- what it found, 2026-08-06 ---------------------------------------------
#
# 1. THE POINT-VALUED SURFACE IS ONE OPTION. Six numeric leaves in the 130 the
#    options page renders, plus four internal mirrors it doesn't (`_roster` /
#    `_launchers`) — and exactly one of the six is in points:
#
#      haus.fonts.mono.size            points     ← the only one
#      haus.ui.scale                   multiplier
#      haus.pounce.scale               multiplier
#      haus.sill.battery.hideOver      percent
#      haus.roster.<name>.order        ordering
#      haus.roster.<name>.appStoreId   an id
#      (plus the internal `_roster` / `_launchers` mirrors of the last two)
#
#    So §5.2's "audit `fonts.*.size` and prowl's gaps" was aimed one layer off:
#    prowl's gaps are not an option at all. Every other point-valued number in
#    the rice — the gaps, the Dock tile, the bar's type, pounce's panel widths —
#    is INTERNAL, computed from `ui.scale` inside a module. A rule about the
#    option surface therefore governs a set of size one.
#
# 2. AND THAT ONE CANNOT CLIP *WHILE PROWL TILES IT* — read from the code, not
#    measured here, and the precondition is load-bearing: a tiled Ghostty at a
#    bigger font buys fewer columns, never a window wider than the screen, but a
#    FLOATING window (prowl's float rules, a zscratch throwaway) or a rice with
#    `prowl.enable = false` has no such guarantee. The failure the coupling
#    actually produces needs something that SIZES ITSELF in points, and the
#    family has three:
#
#      pounce  panels are fixed pt → clamped to the visible frame (pounce#53)
#      perch   shelf is screen.frame.width * 0.42, clamped 360..640 — coupled to
#              the display BY CONSTRUCTION, and blind to ui.scale entirely
#      sill    bounded by the menu-bar band, which is itself in points
#
#    The transferable rule is narrower and more useful than the one §5.2 wrote:
#    **a point-valued number only meets `displays` when something sizes ITSELF
#    from it.** Tiled and OS-managed surfaces absorb the change.
#
# 3. THE REACH TABLE IS PINNABLE, AND IT NEEDS A THIRD VERDICT. `accent-reach`
#    classifies a surface moves / pinned / PARTIAL. `ui.scale` has two surfaces
#    that change and then STOP — the bar's type at 1.25x (the menu-bar band) and
#    pounce at 2.0 (its own clamp) — and under that vocabulary a ceiling reads as
#    PARTIAL while being the deliberate answer §5.2 argued for. Hence four scales
#    (1.0, 1.4, and two past every ceiling) and a `ceiling` verdict.
#
# ✅ The pinnable subset shipped as the rice's `nix flake check` `scale-reach`
# the same day. This file stays the scratch version: it prints the numeric-leaf
# census and the resolved values, which is what you want the first time.
{
  rice ? ../../haus,
  scales ? [
    1.0
    1.4
    2.5
    3.0
  ],
}:

let
  flake = builtins.getFlake (toString rice);
  lib = flake.inputs.nixpkgs.lib;

  # ---- 1. the numeric census (pure lib, no system) ---------------------------
  # The same evaluated option tree the docs render from, so it sees exactly the
  # public surface. Units are not typed anywhere — that is the finding — so the
  # census lists the leaves and a human says which are points.
  surface =
    lib.optionAttrSetToDocList
      (lib.evalModules {
        specialArgs.lib = lib;
        modules = import "${toString rice}/modules/options-modules.nix";
      }).options;
  numeric = map (o: "${o.name} :: ${o.type}") (
    builtins.filter (
      o:
      lib.hasPrefix "haus." o.name
      && builtins.match ".*(integer|floating point|number).*" o.type != null
    ) surface
  );

  # ---- 2. the reach measurement (four darwin evaluations) --------------------
  at =
    scale:
    let
      cfg =
        (flake.mkHaus {
          system = "aarch64-darwin";
          username = "you";
          hostname = "example";
          extraModules = [ { haus.ui.scale = scale; } ];
        }).config;
      hm = cfg.home-manager.users.you;
      text =
        target:
        let
          entry = hm.home.file.${target};
        in
        builtins.unsafeDiscardStringContext (
          if entry.text != null then entry.text else toString entry.source
        );
      grab =
        target: pat:
        let
          hits = builtins.filter (l: builtins.match pat l != null) (lib.splitString "\n" (text target));
        in
        if hits == [ ] then "«no match: ${pat}»" else builtins.head hits;
    in
    {
      files = builtins.mapAttrs (target: _: text target) hm.home.file;
      values = {
        "fonts.mono.size" = toString cfg.haus.fonts.mono.size;
        "pounce.scale" = toString cfg.haus.pounce.scale;
        "dock.tilesize" =
          if cfg.system.defaults.dock.tilesize == null then
            "unset"
          else
            toString cfg.system.defaults.dock.tilesize;
        "finder.sidebar" = toString cfg.system.defaults.NSGlobalDomain.NSTableViewDefaultSizeMode;
        "ghostty" = grab "Library/Application Support/com.mitchellh.ghostty/config" "^font-size.*";
        "sill" = grab ".config/sketchybar/sizes.sh" "^FS_ICON.*";
        "prowl inner" = grab ".config/aerospace/aerospace.toml" "^inner[.]horizontal.*";
        "prowl outer.top" = grab ".config/aerospace/aerospace.toml" "^outer[.]top.*";
      };
    };
  runs = map at scales;

  # moves = different at every scale; ceiling = changed, then held, and never a
  # value that comes back; pinned = the same everywhere. Anything else wants a
  # human, which is what PARTIAL means.
  verdict =
    values:
    let
      squashed = builtins.foldl' (
        acc: v: if acc != [ ] && lib.last acc == v then acc else acc ++ [ v ]
      ) [ ] values;
    in
    if builtins.length squashed == 1 then
      "pinned"
    else if squashed == values && lib.unique values == values then
      "moves"
    # Moved on the FIRST step, never came back to a value it left, and the top
    # two agree. The first-step clause is why `a a b b` is PARTIAL rather than a
    # tidy ceiling: it means the surface is dead across 1.0 -> 1.4, the only
    # stretch anyone actually runs.
    else if
      squashed == lib.unique values
      && builtins.head values != builtins.elemAt values 1
      && lib.last values == lib.last (lib.init values)
    then
      "ceiling"
    else
      "PARTIAL";

  # The UNION of every run's targets: a file written only above 1.0 exists in no
  # other run's attrNames, so taking the first run's would hide exactly the
  # surface this is looking for.
  allFiles = builtins.foldl' (acc: run: acc // run.files) { } runs;
  fileVerdicts = lib.filterAttrs (_: v: v != "pinned") (
    lib.mapAttrs (target: _: verdict (map (run: run.files.${target} or "(absent)") runs)) allFiles
  );
  resolved = lib.mapAttrs (name: _: map (run: run.values.${name}) runs) (builtins.head runs).values;
in
{
  inherit numeric;
  scales = map toString scales;
  # Every home file that is NOT byte-identical across all four scales, so a
  # surface that starts or stops following the scale shows up on its own.
  follows = fileVerdicts;
  # The generated numbers themselves — the ceilings are visible here as a value
  # that repeats (`pounce.scale` at 2.0, `sill` at 21.0).
  values = resolved;
  verdicts = lib.mapAttrs (_: verdict) resolved;
}

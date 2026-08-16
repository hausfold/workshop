# preset-composition — what happens when two RICES meet, and whether the fix
# that worked for packs transfers.
#
# Evidence for options-roadmap.md §6, limit 3. rice#222 closed limit 3 for
# packs: `haus.lib.pack` stamps `mkDefault` per leaf at the import seam, so
# a consumer's own host outranks a pack silently and two packs still collide
# loudly. The gap it left, named in the roadmap, is **preset vs preset** — and
# the gallery a launch produces is a pile of presets, not packs.
#
#   nix-instantiate --eval --strict --json notes/probes/preset-composition.nix \
#     --arg rice /Users/you/code/workshop/hausfold
#
# (Same shape as pack-priority.nix: `nix eval --file` ignores `--arg`, and the
# rice path has to be an argument because a workshop worktree cannot see the
# sibling repos. `nix-instantiate` needs the arg explicitly too — it will not
# auto-call the default.)
#
# Pure lib over modules/options-modules.nix — no darwin system, no build, a few
# seconds, and it would run on Linux CI beside keymap / theme-variants /
# data-only-surface / packs.
#
# ✅ 2026-08-06: it does. The measurements below become `preset-composition` in
# the rice's own `nix flake check` (rice#239, open when this was written) — the six pairs, the three host
# cases and the two silent merges, as a golden table. This file stays the SCRATCH
# version: it prints the whole shape (overlaps, resolved values, option 4's
# ordering experiment) rather than the subset worth pinning, which is what you
# want when the question is new rather than regressing.
#
# ---- what it found, 2026-08-05 ---------------------------------------------
#
#   preset alone (all four)          composes — the readiness test, unchanged
#   [ full minimal ]                 overlap 5, DISAGREE 4 → conflict on 4;
#                                    developer.enable overlaps and merges
#   [ everyday full ]                overlap 5, disagree 2 → conflict on 2
#   [ everyday minimal ]             overlap 5, disagree 4 → conflict on 4;
#                                    they agree prowl is off
#   [ everyday large-print ]         overlap 0 → composes
#   [ full large-print ]             overlap 0 → composes
#   [ large-print minimal ]          overlap 0 → composes
#   preset + host, same value        composes
#   preset + host, plain, differing  conflict
#   preset + host, mkForce           composes, host wins
#   colliding pair + plain host      STILL conflict, on 5 options — the
#                                    pack-vs-pack escape hatch does not transfer
#   colliding pair, both mkDefault   still conflict on 4 — peers stay peers
#   compose [ everyday minimal ]     composes; minimal's rooms win…
#   compose [ minimal everyday ]     …and everyday's win in the other order
#   two rices authoring tour steps   BOTH steps, concatenated, reverse import
#                                    order, no error and no warning
#   two rices naming different apps  both apps, merged
#
# The six lines that changed the roadmap:
#
#   1. OVERLAP IS NOT COLLISION. Two rices that set the same option to the SAME
#      value compose fine — `mergeEqualOption` accepts identical definitions.
#      Every documented "these two happen not to overlap" is really "they never
#      disagree", which is a much weaker requirement and a much better story.
#   2. THE ERROR IS BETTER THAN THE ROADMAP CLAIMED — it names the option, both
#      FILES and `mkForce`, as long as the rice arrives as a path. A seam that
#      transforms a rice (lib.pack does) erases the filename to <unknown-file>,
#      which is a one-line fix (`_file`) — shipped as rice#228, with a third
#      rule in the `packs` check, since nothing locally would notice it regress.
#   3. THE PACK ESCAPE HATCH DOES NOT TRANSFER. A plain host assignment settles
#      a pack-vs-pack collision (both packs are mkDefault, the host outranks
#      them). Between two presets it is a THIRD normal definition and the build
#      still stops. The consumer needs `lib.mkForce`, and nothing says so at the
#      point they hit it.
#   4. PRESETS AT mkDefault WOULD NOT HELP EITHER. Two equal-priority defaults
#      conflict exactly like two equal-priority values. Option 1 fixes
#      host-vs-rice, never rice-vs-rice.
#   5. …but PRIORITY BY LIST POSITION DOES, and it is one `mkOverride` at the
#      seam. Stamping descending priorities across `compose [ a b ]` makes
#      "the later one wins" TRUE — the model rice#203 refuted as a description
#      of the module system is implementable as a mechanism on top of it.
#      Measured both directions, so it is order and not luck. What it yields is
#      a BLEND, not a winner: `compose [ everyday minimal ]` keeps everyday's
#      tour.steps, because minimal never mentions steps.
#   6. AND THE OPTIONS THAT DON'T COLLIDE MERGE, SILENTLY. Scalars fail loudly;
#      lists and attrsets (tour.steps, roster, theme.ports.handled…) blend with
#      no warning at all. Composition has two failure modes, and the roadmap
#      only ever described the loud one.
{
  rice ? ../../haus,
}:
let
  # The rice's pinned nixpkgs, so the module-system semantics under test are the
  # ones the rice actually evaluates with.
  lib = (builtins.getFlake (toString rice)).inputs.nixpkgs.lib;

  optionModules = import (rice + "/modules/options-modules.nix");

  presetNames = [
    "full"
    "minimal"
    "everyday"
    "large-print"
  ];
  preset = n: import (rice + "/presets/${n}.nix");

  surface = lib.evalModules {
    specialArgs.lib = lib;
    modules = optionModules;
  };

  evalWith = mods: (lib.evalModules {
    specialArgs.lib = lib;
    modules = optionModules ++ mods;
  }).config;

  # ---- reading a rice as data ------------------------------------------------
  # The paths a rice actually defines. Stops at anything that isn't a plain
  # attrset, so a list-valued option (everyday's tour.steps) is one path rather
  # than a walk into its elements.
  defPaths =
    prefix: v:
    if builtins.isAttrs v && !(v ? _type) then
      lib.concatMap (n: defPaths (prefix ++ [ n ]) v.${n}) (builtins.attrNames v)
    else
      [ prefix ];

  pathsOf = data: defPaths [ ] data;
  showPath = lib.concatStringsSep ".";

  # Read one path out of an evaluated composition, catching the conflict.
  # Per-path rather than one deepSeq of the whole config: the failures ARE the
  # answer, and a single boolean would say "it broke" without saying where.
  readPath =
    config: path:
    let
      r = builtins.tryEval (
        let
          v = lib.getAttrFromPath path config;
        in
        builtins.deepSeq v v
      );
    in
    if r.success then { ok = true; } else { ok = false; };

  compose =
    mods: paths:
    let
      config = evalWith mods;
      failing = builtins.filter (p: !(readPath config p).ok) (lib.unique paths);
    in
    {
      ok = failing == [ ];
      collidesOn = map showPath failing;
    };

  # ---- priority, applied at the seam ---------------------------------------
  # A rice is data, so it can no more lower its own priority than a pack can
  # (checkRice throws on a file that takes arguments, and mkDefault is
  # lib.mkDefault). Whatever ships is applied TO a rice by whoever imports it.
  #
  # pack-priority.nix hand-rolled two levels of mapAttrs because it only ever
  # had to walk `roster`. A rice sets arbitrary paths, so the wrapper has to
  # find the option boundary rather than count levels — wrap ABOVE it and you
  # replace a value instead of setting a priority, which is the silent
  # three-quarters-of-the-pack-vanishes failure that probe found.
  atPriority =
    prio: data:
    let
      go =
        optNode: value:
        if optNode == null then
          value # not an option at all; leave it alone and let eval complain
        else if optNode ? _type && optNode._type == "option" then
          let
            elemSub =
              if optNode.type.name == "attrsOf" then
                (optNode.type.nestedTypes.elemType.getSubOptions or (_: { })) [ ]
              else
                { };
          in
          # attrsOf submodule (roster is the one that matters) keeps going: the
          # priority has to land on the ENTRY'S FIELDS, not on the family.
          if elemSub != { } && builtins.isAttrs value then
            lib.mapAttrs (_: elem: goAttrs elemSub elem) value
          else
            lib.mkOverride prio value
        else if builtins.isAttrs value then
          goAttrs optNode value
        else
          lib.mkOverride prio value;

      goAttrs = optNode: value: lib.mapAttrs (n: v: go (optNode.${n} or null) v) value;
    in
    { haus = goAttrs surface.options.haus data.haus; };

  # "Imported later wins", implemented rather than asserted: each rice in the
  # list is stamped one priority weaker than the one after it, so the last
  # definition of any option outranks every earlier one and non-overlapping
  # fields all survive.
  composeList =
    rices:
    let
      n = builtins.length rices;
    in
    lib.imap0 (i: r: atPriority (900 + (n - i)) r) rices;

  # ---- the compositions ------------------------------------------------------
  pairs = lib.concatMap (
    a:
    lib.concatMap (
      b:
      if a < b then
        [
          {
            inherit a b;
          }
        ]
      else
        [ ]
    ) presetNames
  ) presetNames;

  overlapOf =
    a: b:
    let
      pa = pathsOf (preset a);
      pb = pathsOf (preset b);
      shared = builtins.filter (p: builtins.elem p pb) pa;
      valueAt = data: p: lib.getAttrFromPath p data;
      disagree = builtins.filter (p: valueAt (preset a) p != valueAt (preset b) p) shared;
    in
    {
      overlap = map showPath shared;
      disagree = map showPath disagree;
    };

  pairProbe =
    { a, b }:
    let
      o = overlapOf a b;
      c = compose [ (preset a) (preset b) ] (pathsOf (preset a) ++ pathsOf (preset b));
    in
    {
      name = "[ ${a} ${b} ]";
      inherit (c) ok collidesOn;
      inherit (o) overlap disagree;
    };

  # A host that restates one value a preset already sets, identically.
  hostAgrees.haus.sill.enable = true;
  # The same option, the other way — the ordinary "I disagree with my preset" case.
  hostDisagrees.haus.prowl.enable = true;
  hostForces.haus.prowl.enable = lib.mkForce true;

  named = name: attrs: { inherit name; } // attrs;

  # ---- the options that DON'T conflict, which is its own hazard -------------
  # Two rices authoring a tour, and two rices naming apps. Neither errors.
  riceTourA.haus.tour.steps = [
    {
      hint = "A";
      detect = "palette";
    }
  ];
  riceTourB.haus.tour.steps = [
    {
      hint = "B";
      detect = "launch";
    }
  ];
  riceRosterA.haus.roster.obsidian = {
    key = "o";
    name = "Obsidian";
    cask = "obsidian";
  };
  riceRosterB.haus.roster.zotero = {
    key = "z";
    name = "Zotero";
    cask = "zotero";
  };
in
{
  # Each rice alone — the readiness test, which is the thing that already passes.
  alone = map (n: named n (compose [ (preset n) ] (pathsOf (preset n)))) presetNames;

  # Every pair of the four shipped presets.
  pairs = map pairProbe pairs;

  extras = [
    (named "full + a host restating sill.enable = true (same value)" (
      compose [ (preset "full") hostAgrees ] (pathsOf (preset "full"))
    ))
    (named "everyday + a host setting prowl.enable = true (plain)" (
      compose [ (preset "everyday") hostDisagrees ] (pathsOf (preset "everyday"))
    ))
    (named "everyday + a host setting prowl.enable with mkForce" (
      compose [ (preset "everyday") hostForces ] (pathsOf (preset "everyday"))
    ))
    (named "[ everyday minimal ] + a plain host assignment (the pack escape hatch)" (
      compose [ (preset "everyday") (preset "minimal") hostDisagrees ] (
        pathsOf (preset "everyday") ++ pathsOf (preset "minimal")
      )
    ))
    (named "[ everyday minimal ] both at mkDefault (option 1, for presets)" (
      compose (map (r: atPriority 1000 r) [ (preset "everyday") (preset "minimal") ]) (
        pathsOf (preset "everyday") ++ pathsOf (preset "minimal")
      )
    ))
  ];

  # The other half of the story: a list- or attrs-typed option doesn't conflict
  # at all, it MERGES. No error is not the same as no surprise.
  merges =
    let
      look =
        name: mods: path:
        let
          config = evalWith mods;
          r = builtins.tryEval (
            let
              v = lib.getAttrFromPath path config;
            in
            builtins.deepSeq v v
          );
        in
        {
          inherit name;
          ok = r.success;
          value = if r.success then r.value else "EVAL FAILED";
        };
    in
    [
      (look "two rices each authoring one tour step"
        [
          riceTourA
          riceTourB
        ]
        [
          "haus"
          "tour"
          "steps"
        ]
      )
      (look "two rices naming DIFFERENT apps"
        [
          riceRosterA
          riceRosterB
        ]
        [
          "haus"
          "roster"
        ]
      )
    ];

  # Option 4: priority by list position, so the LAST rice wins.
  ordered =
    let
      run =
        rices:
        let
          paths = lib.concatMap (r: pathsOf r) rices;
          config = evalWith (composeList rices);
          failing = builtins.filter (p: !(readPath config p).ok) paths;
        in
        {
          ok = failing == [ ];
          collidesOn = map showPath failing;
          resolved = lib.listToAttrs (
            map (p: {
              name = showPath p;
              value = lib.getAttrFromPath p config;
            }) (lib.unique paths)
          );
        };
    in
    [
      (named "compose [ everyday minimal ]" (run [
        (preset "everyday")
        (preset "minimal")
      ]))
      (named "compose [ minimal everyday ]" (run [
        (preset "minimal")
        (preset "everyday")
      ]))
      (named "compose [ everyday large-print ]" (run [
        (preset "everyday")
        (preset "large-print")
      ]))
    ];
}

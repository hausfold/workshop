# pack-priority — what a shared PACK has to ship so a consumer's own host wins.
#
# Evidence for options-roadmap.md §6, limit 3: composing rices is not the free
# operation the roadmap assumed. Import order carries no priority, so a host and
# a pack that both name one app *conflict* rather than one overriding the other.
# The roadmap's option 1 was "ship packs at a lower priority" — this measures it,
# because the obvious implementation of that sentence is the broken one.
#
#   nix-instantiate --eval --strict --json notes/probes/pack-priority.nix
#   nix-instantiate --eval --strict --json notes/probes/pack-priority.nix \
#     --arg rice /Users/you/code/workshop/hausfold     # from a worktree
#
# (`nix eval --file` does not apply `--arg`, and the rice path has to be an
# argument because a workshop worktree cannot see the sibling repos.)
#
# No darwin system, no build: this evaluates the rice's PURE-LIB option surface
# (modules/options-modules.nix — the same thing options-json and
# data-only-surface read) with the real packs/writing.nix and a fake host, so it
# runs in seconds and would run on Linux CI. That is a finding in itself: the
# readiness test evaluates each rice alone, and testing two overlapping ones is
# the same machinery with a second module in the list.
#
# ---- what it found, 2026-08-04 ----------------------------------------------
#
#   pack alone                         four apps, the pack's own letters
#   pack + host, today                 EVAL FAILED — conflict on roster.obsidian.key
#   family-mkDefault pack + host       ONE app, silently: the host's obsidian, no
#                                      workspace, no pill — zotero/anki/calibre gone
#   leaf-mkDefault pack + host         four apps; host's key wins; the pack's
#                                      workspace/barIcon/cask survive
#   two leaf-mkDefault packs           EVAL FAILED — pack-vs-pack still loud
#   …and a host naming that app        four apps, host's letter — a PLAIN host
#                                      assignment settles a pack-vs-pack
#                                      collision; it outranks both packs
#   leaf-mkDefault + host key = null   four apps, no letter claimed, no mkForce
#
# The middle row is the point. `mkDefault` on the whole `nebelhaus.roster`
# attrset attaches the priority AT the option boundary, so one normal-priority
# field in the host outranks the pack's entire roster and three quarters of the
# pack vanishes with no error. Wrap below the option leaf and you set a
# priority; wrap at or above it and you replace a value.
#
# And neither form can be written INSIDE a pack: checkRice throws on a file that
# takes arguments, and mkDefault is lib.mkDefault. Whatever ships has to be
# applied at the import seam.
{
  rice ? ../../haus,
}:
let
  # The rice's pinned nixpkgs, so the module-system semantics under test are the
  # ones the rice actually evaluates with. (getFlake refuses a linked worktree —
  # pass `--arg rice <main checkout>` from one.)
  lib = (builtins.getFlake (toString rice)).inputs.nixpkgs.lib;

  optionModules = import (rice + "/modules/options-modules.nix");
  packData = import (rice + "/packs/writing.nix");

  evalWith =
    mods:
    (lib.evalModules {
      specialArgs.lib = lib;
      modules = optionModules ++ mods;
    }).config.nebelhaus.roster;

  # The consumer: already has Obsidian, on their own letter, and expects the
  # pack's other three apps to arrive anyway. The likely case, not an exotic one
  # — a pack is worth publishing precisely when its apps are popular.
  host.nebelhaus.roster.obsidian = {
    key = "n";
    name = "Obsidian";
    cask = "obsidian";
  };

  # The consumer who wants the app installed but claims no letter for it.
  hostNullKey.nebelhaus.roster.obsidian.key = null;

  # ---- three ways to ship the same pack ------------------------------------
  packAsIs = packData;

  # (a) priority at the FAMILY level — the one-liner a seam would reach for.
  packFamilyDefault.nebelhaus.roster = lib.mkDefault packData.nebelhaus.roster;

  # (b) priority per LEAF — "mkDefault inside every pack", mechanised at the
  #     seam, with the pack file itself still data.
  packLeafDefault.nebelhaus.roster = lib.mapAttrs (
    _: entry: lib.mapAttrs (_: v: lib.mkDefault v) entry
  ) packData.nebelhaus.roster;

  # A second pack that also names Obsidian, shipped the same way.
  otherPackLeafDefault.nebelhaus.roster.obsidian = lib.mapAttrs (_: v: lib.mkDefault v) {
    key = "b";
    name = "Obsidian";
    cask = "obsidian";
  };

  probe =
    name: mods:
    let
      r = builtins.tryEval (
        let
          roster = evalWith mods;
          res = {
            ids = builtins.attrNames roster;
            obsidianKey = roster.obsidian.key or null;
            obsidianCask = roster.obsidian.cask or null;
            obsidianWorkspace = roster.obsidian.workspace or null;
            obsidianBarIcon = roster.obsidian.barIcon or null;
          };
        in
        builtins.deepSeq res res
      );
    in
    {
      inherit name;
      ok = r.success;
      value = if r.success then r.value else "EVAL FAILED (conflicting definitions)";
    };
in
[
  (probe "pack alone" [ packAsIs ])
  (probe "pack + host (today)" [
    packAsIs
    host
  ])
  (probe "family-mkDefault pack + host" [
    packFamilyDefault
    host
  ])
  (probe "leaf-mkDefault pack + host" [
    packLeafDefault
    host
  ])
  (probe "two leaf-mkDefault packs overlapping" [
    packLeafDefault
    otherPackLeafDefault
  ])
  (probe "two overlapping packs + a host naming the app" [
    packLeafDefault
    otherPackLeafDefault
    host
  ])
  (probe "leaf-mkDefault pack + host asking for no letter" [
    packLeafDefault
    hostNullKey
  ])
]

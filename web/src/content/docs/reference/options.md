---
title: haus.* options
description: Every option you can set in your host file — types, defaults, and what each one changes.
tableOfContents:
  maxHeadingLevel: 2
---

<!-- GENERATED FILE — do not edit by hand.

     Rendered from the rice's own module system by web/scripts/gen-options.mjs.
     To change an option's description, edit its declaration in the rice
     (modules/<room>/options.nix) and regenerate:

         node web/scripts/gen-options.mjs --rice ../hausfold

     CI re-renders this and fails if it differs, so a hand edit here is
     guaranteed to be reverted. -->

These are the `haus.*` options you set in your host file at
`~/.config/nix/hosts/<hostname>/default.nix`. Everything here is optional
unless noted; the defaults are a complete, working system.

Apply changes with `haus rebuild`. Each option lists its **type** and
**default** under its name, and links to the file that declares it.

## haus.git

Your commit identity, plus the GitHub owner this machine's work lives under — set your own. It stays in [your host file](/internals/flakes/#your-config-is-a-thin-consumer).

### `haus.git.email`

`string` · default `""`

Git user.email for commits.

Example:

```nix
"ada@example.com"
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

### `haus.git.name`

`string` · default `""`

Git user.name for commits (hearth wires it into home-manager).

Example:

```nix
"Ada Lovelace"
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

### `haus.git.org`

`string` · default `""`

The GitHub owner whose repos this machine works on. An organisation,
or your own account: GitHub's issue search treats `org:<user>` the
same as `user:<user>`, so one option covers both (measured against
both qualifiers, 2026-08-08 — the counts match).

It exists because a gh-dash PR section is a GitHub search filter
scoped by `org:`. Set this **and** `haus.hearth.ghDash.enable` and
Hearth renders four PR tabs for that owner — the open / green / red /
just-shipped work. On its own it does nothing: it is the dashboard's
scope, not a feature of its own.

Leave it empty (the default) and Hearth writes no PR tabs at all, so
gh-dash keeps its own and a host composing a queue in
`programs.gh-dash.settings` never fights one. Empty is the right
answer for a machine that reads several owners at once: there is no
single owner to render. The issue and notification tabs are unaffected
either way — they ask who you are (`@me`, `is:unread`) rather than
where you work, so the dashboard ships them regardless.

Where it earns its keep is a rename: an org that changes name, or a
repo set that moves between orgs, is one word here rather than one per
tab. A host's `repoPaths` can follow the same word instead of
repeating it — read it as `config.haus.git.org` from a darwin-level
module, or as `osConfig.haus.git.org` from inside
`home-manager.users.<user>`, where `config` is home-manager's and
carries no `haus.*` at all.

Example:

```nix
"nebelhaus"
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

### `haus.git.shellAliases`

`attribute set of (null or string)` · default `{ }`

Per-host additions and overrides for Hearth's built-in Git shell
aliases. Values are shell command strings; null removes a built-in.
Hearth deliberately owns a compact, framework-independent default
set, so this changes only Git shortcuts and does not require a shell
plugin manager.

Example:

```nix
{
  gst = "git status --short --branch"; # replace a built-in
  gsync = "git pull --rebase --autostash"; # add one
  gco = null; # remove one
}
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

### `haus.git.signingKey`

`string` · default `""`

GPG key id for signing commits/tags. Empty disables commit signing.
Key material + any YubiKey/smartcard setup live outside Nix
(gpg-agent + pinentry-mac).

Example:

```nix
"6F7BD6F43A7C1420"
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

## haus.roster

One list of everything this machine has — apps, fonts, command-line tools. Each entry drives its launcher key, cheatsheet row, and installs it from whichever source it names: a Homebrew cask or formula, a Nixpkgs package, or the Mac App Store.

### `haus.roster`

`attribute set of (submodule)` · default `{ }`

The one list of things this machine has, keyed by a stable id. It is
the canonical, composable source for AeroSpace launcher keys, the
SketchyBar pills, the pounce cheatsheet, Nebelung theme ports — and
for the install itself, from any of four sources (`cask`, `brew`,
`package`, `appStoreId`).

Every field except the id is optional, and WHICH fields you set is
what the entry means. Set `key` and it joins the launcher; set none
of the launcher/workspace/install fields and it's install-only —
which is how a font or a command-line tool lives in the same list as
Slack instead of in a second one beside it. The rice's own
`homebrew.casks` / `home.packages` still work and still merge; you
just shouldn't need them for an app.

Which WORKSPACE an app owns is not a field here — it's
`haus.workspaces.<id>.apps` naming this entry's id, so one
workspace can hold several apps (a "comms" workspace with Slack,
Mail and Messages) instead of baking "one app, one workspace" into
this schema. See that option.

Attribute-set entries merge across Nix modules, so a host, an imported
file, and pounce's "Install App" command can each contribute one app
without parsing or replacing a monolithic list. Set an entry's enable
field to false to remove it, or override individual fields by app id.

Example:

```nix
{
  # Launcher app: leader s. Own workspace + pill come from putting
  # "slack" in a haus.workspaces entry's `apps` (see below).
  slack = {
    key = "s";
    name = "Slack";
    appId = "com.tinyspeck.slackmacgap";
    cask = "slack";
  };

  # Install-only: no key, so no leader binding and no pill.
  framer = { cask = "framer"; };
  orbstack = { package = pkgs.orbstack; };
  biome = { package = pkgs.biome; scope = "system"; };
  ical-buddy = { brew = "ical-buddy"; };
  xcode = { name = "Xcode"; appStoreId = 497799835; };
}
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.roster.<name>.appId`

`null or string` · default `null`

Bundle id, used for the AeroSpace `on-window-detected` auto-assign
rule (when this app is a member of a `haus.workspaces` entry),
the `float` rule below, and the wake-time re-sort. null skips both
— the app still launches, it just isn't herded anywhere or floated.
Find one with `osascript -e 'id of app "…"'`.

Example:

```nix
"com.tinyspeck.slackmacgap"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.roster.<name>.appStoreId`

`null or signed integer` · default `null`

Mac App Store numeric app id (the digits in its store URL), so an
App Store app is declared in the same roster as everything else
rather than in a comment.

Recording it is always safe; INSTALLING from it is opt-in via
`haus.appStore.install`, because the App Store is the one
source that can't be fully automated: `mas` has no sign-in
command, and it cannot buy a paid app for the first time. Free
apps it can fetch; paid ones you purchase once in App Store.app
and every machine afterwards can install them.

Example:

```nix
497799835
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.roster.<name>.brew`

`null or string` · default `null`

Homebrew FORMULA that installs this entry, appended to
homebrew.brews. For the command-line half of the roster — a tool
with no .app bundle, which usually means `key`, `name` and
`workspace` are all null.

Example:

```nix
"ical-buddy"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.roster.<name>.cask`

`null or string` · default `null`

Homebrew cask that installs this app. When set, it's appended to
homebrew.casks so declaring the app also installs it. null means
"already present / installed some other way" (e.g. Safari, Music).

Example:

```nix
"slack"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.roster.<name>.enable`

`boolean` · default `true`

Whether this app participates in the shared launcher roster.

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.roster.<name>.float`

`boolean` · default `false`

Always float this app's windows instead of tiling them — an
AeroSpace `on-window-detected` rule generated from `appId`
(`run = 'layout floating'`). Right for a picker/dialog/status
window that would otherwise reflow the whole workspace every time
it opens (FaceTime, Trill's Settings/Inbox), not for something you
work inside. Requires `appId`; ignored (with a warning) without it.

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.roster.<name>.installedBy`

`null or string` · default `null`

The nebelhaus module that puts this app on disk, when none of the
four sources above describes it: pounce and perch copy a
notarized bundle into /Applications from their own activation
step, which is neither a cask nor a package you can list.

Set BY the rice, not by you. It exists so the roster can still
answer "who installed this?" for those apps — without it, a host
adding a leader key for Perch had to KNOW the rice already ships
it, leave every source field null, and leave a comment explaining
the hole. This is that comment, as data.

Example:

```nix
"haus.perch"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.roster.<name>.key`

`null or string` · default `null`

The leader letter for this app: tap Caps Lock then this key to
launch/focus it. Must be unique across the roster.

null (the default) means the entry is INSTALL-ONLY: it still
brings its cask/formula/package, but claims no leader key, no
cheatsheet row, and no launch-mode bubble. That is what lets one
roster hold both the apps you reach for by keyboard and the ones
you just want on the machine (and fonts, and CLI tools).

Example:

```nix
"s"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.roster.<name>.label`

`null or string` · default `null`

Cheatsheet caption for the leader key. null uses name.

Example:

```nix
"Slack"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.roster.<name>.name`

`null or string` · default `null`

macOS application name, as passed to `open -a`. Required when
`key` is set (the launcher has nothing to open otherwise);
null is right for an install-only entry — a font, a CLI tool, or
an app you launch some other way.

Example:

```nix
"Slack"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.roster.<name>.order`

`signed integer` · default `1000`

Roster order; lower values appear first. Ties are sorted by app id.

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.roster.<name>.package`

`null or package` · default `null`

Nixpkgs package that installs this entry. Where it lands is
`scope`'s call.

A shared rice or app pack can't set this one — it needs `pkgs`, and a
data-only rice has no arguments. Use `packageName` there.

Example:

```nix
pkgs.orbstack
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.roster.<name>.packageName`

`null or string` · default `null`

The same source as `package`, NAMED rather than evaluated: an
attribute path into nixpkgs, so "orbstack" means `pkgs.orbstack` and
"python3Packages.black" means what it says. `scope` applies to it
identically.

This is the source a shared app pack can use (packs/README.md).
Without it a pack could install from Homebrew and the App Store but
never from Nixpkgs, because reaching `pkgs` is exactly what the
data-only format forbids — the one gap in the four sources.

Set this or `package`, never both; and it counts as a source like any
other, so pairing it with `cask` is the same mistake as pairing
`cask` with `brew`.

Example:

```nix
"orbstack"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.roster.<name>.scope`

`one of "user", "system"` · default `"user"`

Which profile `package` installs into.

- "user" (default): home-manager's `home.packages`. Right for
  anything you run as yourself — apps, editors, CLI tools.
- "system": nix-darwin's `environment.systemPackages`. Installed
  once for the whole machine, so it's on PATH for root, for
  non-login shells, and for launchd jobs — which is what a tool
  invoked by a daemon, a `sudo` workflow, or an activation script
  actually needs. (It is about REACH, not about the package
  needing elevated privileges to install: `darwin-rebuild` runs
  under sudo either way.)

Ignored when `package` is null — Homebrew has no such split.

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.roster.<name>.titleRegex`

`null or string` · default `null`

Scope `float` to windows of this app whose title matches this
regex (AeroSpace's `window-title-regex-substring`), instead of
every window the app opens. null (default) floats all of them.

Some apps' windows report their title only AFTER AeroSpace has
already detected and tiled them once (a race, not a bug this
option can fix) — Ghostty is the known case, which is why this
rice's own Ghostty float rule is hand-written in aerospace.toml
rather than generated from the roster. If a title rule flaps,
that race is almost certainly why. Ignored when `float` is false.

Example:

```nix
"^Picture in Picture$"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

## haus.workspaces

The named AeroSpace workspaces this machine declares, and which roster apps live on each. A workspace, not an app, owns its bar pill and leader throw — so several apps (a whole "comms" role) can share one.

### `haus.workspaces`

`attribute set of (submodule)` · default `{ }`

AeroSpace workspaces this machine names on purpose, keyed by the
workspace id AeroSpace itself will use (any string it accepts as a
workspace name — a single letter like `T`, or a word like `comms`).
First-class rather than a field on an app: an app can only ever own
one workspace if the field lives on the app, which makes a role
workspace ("communication" = Mail + Slack + Messages) or a project
workspace literally unrepresentable. Here, a workspace lists its own
members instead.

The four fixed numbered workspaces (1-4, leader/⇧+digit) are not
part of this option — they always exist, independent of what any
app claims. This option is for the NAMED workspaces app windows get
herded onto.

An entry with no `key` and no `apps` does nothing (a warning says
so); one with `apps` but no `key` still gets a persistent workspace,
a pill (with `icon`) and auto-herds its member windows, it just has
no dedicated leader throw.

Example:

```nix
{
  # Role workspace: three apps, one pill, one throw key.
  comms = {
    key = "c";
    icon = ":slack:";
    apps = [ "slack" "mail" "messages" ];
  };

  # Single-app workspace: the common case, one entry each.
  T = { key = "t"; icon = ":ghostty:"; apps = [ "ghostty" ]; };
}
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.workspaces.<name>.apps`

`list of string` · default `[ ]`

`haus.roster` app ids that live on this workspace: each
one's window auto-moves here (via its `appId`), opening any of
them from the leader lands you here, and this workspace's `key`
throw (above) sends the focused window here regardless of which
member app owns it. An app id may belong to at most one
workspace.

A plain list, not wrapped in `lib.mkDefault` even where the rice
itself contributes to it (ghostty → workspace `T`, say) — list
options MERGE across modules at equal priority but a `mkDefault`
list is dropped whole rather than merged the moment anything else
defines the same option, so a host adding a second app to `T`
would silently lose ghostty's membership if the rice's own
contribution used `mkDefault` here. Override a single membership
by dropping the app's id from your own list instead.

Example:

```nix
[
  "slack"
  "mail"
  "messages"
]
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.workspaces.<name>.icon`

`null or string` · default `null`

The SketchyBar workspace-pill glyph. A sketchybar-app-font
ligature like ":slack:" renders a logo; any other string is
drawn in the bar's Nerd Font. null falls back to the workspace's
own id.

Example:

```nix
":slack:"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.workspaces.<name>.key`

`null or string` · default `null`

Leader then ⇧<key> throws the focused window to this workspace
and follows it there (AeroSpace's `move-node-to-workspace
--focus-follows-window`). There is no bare <key> binding for a
workspace — that namespace belongs to `haus.roster` app
launch keys, one of which can double as this workspace's "open
something here" action by being one of its `apps`. null means the
workspace is reachable only by launching an app that belongs to
it (or not by keyboard at all). Must be unique across workspaces,
and ⇧<key> must not collide with a built-in launch-mode binding
(⇧1-4 are taken).

Example:

```nix
"c"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

## haus.appStore

Whether a rebuild may install the roster's `appStoreId` entries. Off by default: it reaches the network and acts on your Apple Account, and it can never be complete — `mas` cannot sign in, and cannot buy a paid app.

### `haus.appStore.install`

`boolean` · default `false`

Install roster entries that set `appStoreId` from the Mac App
Store during activation, skipping any already installed.

Off by default: this reaches the network and acts on your Apple
ID, which shouldn't happen as a side effect of turning on a
window manager. It also can't be complete — `mas` cannot sign in
(do that once in App Store.app) and cannot make a first-time
PURCHASE, so a paid app you don't already own is reported and
skipped rather than installed.

Deliberately NOT nix-darwin's `homebrew.masApps`: that runs
`mas install` through `brew bundle` as your user, and since
macOS 13 the App Store install path requires root — so it stops
for a password prompt that a rebuild has no terminal to show,
and the rebuild hangs. The activation step this option enables
is already running as root, so it neither prompts nor wedges.

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

## haus.apps

The apps the rice picks for you, and the file types they claim — the ones a finished machine has rather than the ones a room needs to work. Each is one switch you can turn off; what it installs is a roster entry like any other, so you can retune or replace it by app id.

### `haus.apps.videoPlayer.claimFileTypes`

`boolean` · default `true`

Make IINA the default handler for the everyday video extensions —
mp4, m4v, mov, mpg, mpeg, mkv, webm, avi, wmv, flv, 3gp, ogv, vob —
so double-clicking a video opens IINA instead of QuickTime Player, TV
or a browser. Ignored unless the player is installed.

A short list on purpose: it covers what you actually double-click,
not everything IINA can decode. Dead, professional and DRM'd
containers (qt, divx, asf, f4v, 3g2, ogm, rm, rmvb, mxf, dv, …) are
left alone — they still play via Open With, they just don't get the
default, and every extension the rice claims is a binding it
re-asserts on every rebuild.

Video only. Audio (mp3, flac, m4a, wav, …), `.gif` and playlists
keep whatever owns them today, since "open videos in IINA" rarely
means "and my music library too". The transport-stream extensions
`.ts`, `.mts` and `.m2ts` are excluded too: on a developer's machine
they are TypeScript far more often than video, and
`haus.hearth.hijackFileAssociations` claims them for the editor.
Claiming them here as well made macOS stop and ask which app should
win on every single rebuild, because `.mts` and `.m2ts` share one
UTI.

This sets the USER default (via `duti`) — the same record Finder's
Get Info ▸ Change All writes, so it is undoable by hand. Set false to
install the app and leave every association alone.

<small>Declared in [`modules/apps/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/apps/options.nix).</small>

### `haus.apps.videoPlayer.enable`

`boolean` · default `true`

Install IINA — the rice's video player — as the roster entry `iina`.
A nixpkgs build, so it lands in ~/Applications/Home Manager Apps
rather than /Applications.

On by default: macOS ships QuickTime Player, which refuses most of
what you actually double-click (mkv, webm, and anything not in
Apple's codec list), so "a video player that plays videos" is part
of what the rice considers a finished machine.

Set false and nothing is installed or rebound — bring your own
player via the pounce "Install App" palette command or a roster
entry. Once on it is a roster entry like any other: give it a leader
letter with `haus.roster.iina.key`, or pin a different build
with `haus.roster.iina.package`.

<small>Declared in [`modules/apps/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/apps/options.nix).</small>

## haus.theme

Colour and wallpaper.

### `haus.theme.accent`

`one of "rosewater", "flamingo", "pink", "mauve", "red", "maroon", "peach", "yellow", "green", "teal", "sky", "sapphire", "blue", "lavender"` · default `"mauve"`

The accent colour, by Catppuccin name (the Nebelung palette is a
grey-tinted Catppuccin, so the fourteen names are the same in both
flavors — the hue you pick follows haus.theme.flavor). It recolours
the tools nebelhaus injects colours into — lazygit, fzf, yazi (including
glow-rendered Markdown headings), and the Zen browser — via the matching
Nebelung per-accent ports.

perch follows it too, and is the one surface handed the NAME rather than
a hex: the shelf resolves it against whichever half of its dark/light
pair macOS is showing, so the ember under the notch and a pinned tile
wear this accent in both polarities from one key. Left at perch's
default it accents with its own mark green.

Two more things follow it: the `bold` wallpaper (generated from the
accent hex — see haus.theme.wallpaper), and any roster app whose
Nebelung port ships a per-accent matrix (zed, gh-dash, mpv), placed by
haus.theme.ports. Those ports name the theme file after the accent,
so changing the accent renames the file the app's own `theme` key points
at — re-pick it in the app, or it falls back to stock.

Honest scope: this moves the accent on those tools, NOT literally
everything. Single-file dotfiles that bake the palette at their own
theme slot (ghostty, starship, tmux, bat, zellij, …) keep their built-in
colour and don't follow this option. The base palette stays the same
Nebelung grey either way — only the accent hue changes.

Zen means Zen's own UI, and the web is a separate story. The rice places
the Nebelung userChrome/userContent pair, but userContent only styles
`about:` pages — github.com and youtube.com are themed by the Stylus
extension, whose Catppuccin-derived styles carry their OWN `accentColor`
var (default mauve) inside the extension's storage, where no stylesheet
can reach it. Declare `haus.zen.extensions.stylus` and the rice
stamps that var with this accent and tells you, once, when there's a new
bundle to import; the import itself stays a click, because Stylus has no
file interface. Until you make it, the web keeps the accent you last
imported.

Both halves of that are pinned by the `accent-reach` flake check, which
fingerprints every surface under three accents and fails if one starts
or stops following the accent without anyone deciding it should.

Example:

```nix
"sapphire"
```

<small>Declared in [`modules/theme/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/theme/options.nix).</small>

### `haus.theme.contrast`

`one of "normal", "high"` · default `"normal"`

How far the interface separates from its background.

"high" swaps in the Nebelung high-contrast palette: the same hues and
the same accents, with the neutral ramp pulled apart in OKLCH so text
and background separate further at every step. Measured rather than
eyeballed — body text goes from 11.3:1 to 19.9:1 against the base,
clearing WCAG AAA (nebelung's own CI asserts it).

Composes with `flavor`, and the boost is tuned per flavor rather than
shared: light mode has far less room above its background before the ramp
clips to white, so latte goes 7.0:1 → 9.9:1 where mocha goes 11.3 → 19.9.
Both keep all twelve ramp steps distinct, which is the property nebelung's
tests actually assert.

Honest scope. This recolours what the rice injects colours into:
Ghostty, bat, delta, lsd, yazi, zellij, glow, starship, lazygit, the
bar, pounce and perch (at runtime, via ~/.config/{pounce,perch}/themes/ —
and unlike `flavor`, contrast reaches both on BOTH halves of their
light/dark pair), Zen and Obsidian. It does NOT reach:

  - macOS itself. For system-wide contrast see
    haus.accessibility.increaseContrast — a separate, FDA-gated
    setting. The two are complementary, and a genuinely high-contrast
    machine wants both.

Example:

```nix
"high"
```

<small>Declared in [`modules/theme/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/theme/options.nix).</small>

### `haus.theme.flavor`

`one of "mocha", "latte"` · default `"mocha"`

Light or dark. "mocha" (the default) is the rice as it has always been;
"latte" is light mode.

Not an inversion of the dark palette — a different SOURCE palette. Nebelung
is "Catppuccin with the blue stripped out", and those rules say nothing
about dark, so they apply to Catppuccin Latte just as well: same warm-grey
neutral ramp, same calmed accents, the other polarity. Light mode lands at
7.0:1 for body text on its own, so it's legible before you reach for
contrast = "high" (which takes it to 9.9:1).

It composes with `contrast`: the two axes give four palettes, and nebelung's
CI measures each one's contrast ratio rather than eyeballing it.

Honest scope, in two parts.

What follows it: every tool the rice injects colours into or points at a
rendered theme — Ghostty, bat, delta, lsd, yazi, fzf, glow, starship,
lazygit, helix, zellij, opencode, the bar, Zen and Obsidian.
These are genuinely re-rendered for the flavor, not recoloured in place:
whiskers takes different branches for a light flavor (terminal ANSI
0/7/8/15 swap, Zen switches its prefers-color-scheme block, delta sets
`light = true`).

What does NOT follow it:

  - pounce and perch, by default. Both read their palette at runtime and
    can pick per polarity, so haus.pounce.followSystemAppearance
    and haus.perch.followSystemAppearance (default true) hand that
    choice to macOS Light/Dark instead: the rice installs every rendered
    variant into ~/.config/{pounce,perch}/themes/ and writes the
    dark/light PAIR at your `contrast`. Set either option false to pin
    that app to this flavor like everything else.
  - macOS's own Light/Dark appearance, unless you opt in with
    haus.theme.systemAppearance = "flavor". Left at its default the
    rice does not touch system appearance in either direction, so a
    latte rice on a dark macOS looks half-done and that half is yours —
    except in pounce and perch, which read the appearance themselves.
  - the desktop wallpaper (haus.theme.wallpaper). The three hand-made
    looks have the dark palette baked in; only "bold" is generated, and it
    follows theme.accent rather than the flavor.

Example:

```nix
"latte"
```

<small>Declared in [`modules/theme/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/theme/options.nix).</small>

### `haus.theme.ports.enable`

`boolean` · default `true`

Theme the apps in your roster (`haus.roster`) that Nebelung ships a
port for, without wiring each one by hand.

The rice already themes every tool it installs itself — the shell, the
terminal, the git stack, Zen, Obsidian. This covers the other direction:
an app YOU added to the roster that Nebelung happens to have a theme for.
Add `zed`, `warp` or `xcode` to `haus.roster` and its Nebelung theme
lands where that app looks for themes, in the flavor and contrast you
selected, following them on every rebuild. Matching is by roster id, so
the entry has to be named after the port (`zed`, not `zed-editor`).

Honest scope, and it is the whole point of the option: this drops the
theme FILE. Whether that alone makes the theme *active* is the app's
choice, not ours, and Nebelung records which is which per port. Ghostty
reads a config key we own, so it just works. Xcode, Warp, OBS and friends
offer no file interface for picking a theme — the file is put where they
look, and the one click that selects it stays yours. `haus doctor` lists
exactly which apps are waiting on that click, so the difference is
visible rather than something you discover months later.

Ports whose install is a merge into an existing config file, or that need
a compile step first, are reported but never written: silently
half-applying someone's config is worse than saying so.

<small>Declared in [`modules/theme/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/theme/options.nix).</small>

### `haus.theme.systemAppearance`

`one of "unmanaged", "flavor", "light", "dark"` · default `"unmanaged"`

Whether the rice also sets macOS's OWN Light/Dark appearance — the one
in System Settings ▸ Appearance, which paints Finder, the menu bar and
every native app the rice can't reach.

  unmanaged  (default) leave it alone, in both directions. Your Mac's
             appearance stays yours; nothing about a rebuild moves it.
  flavor     follow haus.theme.flavor — latte sets Light, mocha
             sets Dark. This is the one that makes light mode complete
             rather than half-done.
  light      pin Light, whatever the flavor is.
  dark       pin Dark, whatever the flavor is.

Default "unmanaged" on purpose: a managed default would silently revert
an appearance you picked in System Settings on the next rebuild, which
is a worse surprise than a half-light rice.

How it is applied, and why it is not a `system.defaults` key. Measured
on macOS 26.6 (2026-08-08), NOT recalled from docs:
`NSGlobalDomain.AppleInterfaceStyle` is INERT in both directions. Writing
"Dark" from a light session does nothing; deleting the key from a dark
one does nothing; `activateSettings -u` does not help; a process launched
fresh afterwards still reports the old appearance, and no
AppleInterfaceThemeChangedNotification is posted. That key is a mirror
the appearance system writes, not a lever. So the rice drives appearance
through System Events (AppleScript) at each home-manager activation,
which does flip it live in ~0.3s — and confirms the result with `hausax`
(AppKit's effective appearance), never by reading the key back.

Reachability, the same shape as haus.accessibility.increaseContrast:
driving System Events needs an Automation grant for whichever app runs
the rebuild (System Settings ▸ Privacy & Security ▸ Automation). Without
it macOS refuses, the rebuild says so in a named warning and carries on
— the appearance just doesn't move, and nothing else is affected.

One more thing macOS can undo: System Settings ▸ Appearance ▸ **Auto**
switches polarity on its own schedule. The rice sets the appearance at
rebuild time and does not fight it afterwards, so on an Auto machine
this option holds only until the next scheduled switch. Pick Light or
Dark there if you want it to stick.

Interaction worth knowing: haus.{pounce,perch}.followSystemAppearance
hand polarity to macOS. Set this to "flavor" and macOS's polarity is in
turn the rice's, so those two end up following `flavor` transitively —
which is usually what you wanted, but it does mean `followSystemAppearance`
stops being an independent axis on this machine.

Example:

```nix
"flavor"
```

<small>Declared in [`modules/theme/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/theme/options.nix).</small>

### `haus.theme.wallpaper`

`one of "none", "orbits", "constellation", "flow", "bold"` · default `"none"`

The desktop wallpaper, set at each home-manager activation (osascript,
every desktop on the current Space). Four Nebelung looks:

  orbits · constellation · flow  hand-made, the palette baked in
  bold                           generated from theme.accent, so it
                                 follows the accent (a bold pink at
                                 accent = "pink")

Default "none" leaves your current wallpaper alone — changing the
desktop is visible and personal, so nothing moves unless you ask (the
bootstrap interview offers the choice on a fresh install).

Example:

```nix
"orbits"
```

<small>Declared in [`modules/theme/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/theme/options.nix).</small>

## haus.fonts

The terminal font. The bar keeps its own font at its own tuned sizes.

### `haus.fonts.mono.name`

`string` · default `"JetBrainsMono Nerd Font Mono"`

The rice's type family, as Ghostty's `font-family` names it.

It reaches the terminal AND the menu bar: every pill label and icon
sill draws is in this family, at sizes of its own (see
`haus.ui.scale`). The workspace-logo glyphs are the one exception
— those are sketchybar-app-font, which sill installs itself.

This should be a NERD FONT patched build: starship's prompt, lsd's
icons, yazi previews and half the bar's icons draw with glyphs a stock
font renders as tofu. If you change this, set `package` (or
`packageName`) too — the rice can only install a font it's been given,
and it warns when you name a family without one.

The name is taken verbatim, so a "… Nerd Font Mono" family is drawn in
the bar as well: the bar mixes icon glyphs into its labels, which is
the same reason the terminal wants a patched font.

Example:

```nix
"Berkeley Mono"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.fonts.mono.package`

`null or package` · default `null`

The package providing `name`. null (the default) installs the rice's
own JetBrains Mono Nerd Font, which is what `name` defaults to.

Set this whenever you change `name`, or the family simply won't exist
on the machine and Ghostty will silently fall back — the rice warns if
it spots that combination.

A shared rice can't set this one — it needs `pkgs`, and a data-only
rice has no arguments. Use `packageName` there.

Example:

```nix
pkgs.nerd-fonts.fira-code
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.fonts.mono.packageName`

`null or string` · default `null`

The same thing as `package`, NAMED rather than evaluated: an
attribute path into nixpkgs, so "nerd-fonts.fira-code" means
`pkgs.nerd-fonts.fira-code`.

This exists so a data-only rice (presets/README.md) can change the
font FAMILY and not just its size — reaching `pkgs` is precisely what
that format forbids, which made `fonts.mono.package` unreachable to
every shared rice. A name is data; a package is code.

Set one or the other, never both. A name that resolves to nothing, or
to a set of packages rather than a package, fails at eval with the
spelling to try instead.

Example:

```nix
"nerd-fonts.fira-code"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.fonts.mono.size`

`positive integer, meaning >0` · default `19, scaled by haus.ui.scale`

Terminal font size in points. The single most useful knob for a
larger-text machine, since it moves everything the rice actually
lives in.

19 (at ui.scale = 1.0) is the base for a reason worth knowing: the Ghostty window is
tiled to a fixed pixel height by prowl, and sizes that don't divide
that height evenly used to leave a gap under zellij's status bar.
That's since been fixed properly (window-padding-balance +
`extend-always`), so any size is safe now — 19 is simply the tuned
starting point.

Example:

```nix
24
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

## haus.ui

One number for "make the interface bigger", applied across the rice's own surfaces.

### `haus.ui.scale`

`integer or floating point number between 0.5 and 3.0 (both inclusive)` · default `1.0`

One number for "make the interface bigger". 1.0 is the rice as tuned;
1.35 is a comfortable large-print setting; below 1.0 tightens things up.

It sets the DEFAULT of the sizes it drives, so anything you pin by hand
still wins:

  haus.ui.scale = 1.5;          # everything grows
  haus.fonts.mono.size = 18;    # …except the terminal, pinned here

What it currently moves:

  - the terminal font size (haus.fonts.mono.size)
  - the command palette, whole (haus.pounce.scale) — its rows,
    text and icons, and the emoji / clipboard / screenshots / camera /
    Find Files / cheatsheet panels behind it
  - the type in Sill's menu bar — pill labels, icons and popup rows —
    up to a ceiling; see below
  - the Dock icon size (system.defaults.dock.tilesize)
  - Finder's sidebar rows (NSTableViewDefaultSizeMode) — a threshold
    rather than a multiplier, and it is set at every scale: at or below
    1.0 the rice picks SMALL rows (more fits in a tiled window), above
    1.0 it picks Apple's large ones
  - prowl's window gaps

That list is pinned by `nix flake check`'s `scale-reach`, which
fingerprints every surface it names at four scales — so a wire dropped
in a refactor fails a check instead of quietly ceasing to arrive.

Where it stops, and why it isn't a gap waiting to be filled:

  - Sill's bar HEIGHT. The bar is 36pt with 28pt pills so the pills sit
    inside the 32pt menu-bar band that macOS's own hover-reveal covers;
    taller pills poke out below it. That band is macOS's, fixed, and has
    no setting behind it — measured, not assumed. So the bar's type
    follows this option up to the largest that still fits a pill
    (1.25x) and then stops, silently: past that a rice simply gets the
    ceiling. The only way to make the whole bar bigger is to change what
    a point MEANS — the display's scaled resolution, below.
  - perch, the notch shelf. It sizes itself from the SCREEN — a fraction
    of the display's width, clamped — which is the right answer for a
    thing hanging off the notch, and it means NEITHER lever moves it: a
    scaled display shrinks the shelf's width in points by the same
    factor that makes a point bigger, so it stays the same physical
    size while everything around it grows. A large-print rice gets a
    normal-sized shelf, and there is no option here that changes that.
  - anything outside nebelhaus. macOS has no system-wide UI scale, so
    third-party apps follow only a display-resolution change.

Worth knowing if you set both: this and
`haus.displays.<name>.uiScale` MULTIPLY. A larger-text display mode
leaves a smaller desktop in points, and this asks for bigger points
inside it — so 1.4 on an already-scaled display is a bigger jump than
1.4 on the panel's default.

Example:

```nix
1.35
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

## haus.displays

Per-display overrides, keyed by which screen you mean.

### `haus.displays`

`attribute set of (submodule)` · default `{ }`

Per-display settings, keyed by which screen you mean:

  internal   the built-in panel
  main       whichever display is currently main
  <uuid>     a persistent display UUID, for a specific external monitor —
             run `hausdisp list` to print the UUIDs of what's attached

Default is the empty set, and then nothing about your displays is touched.
A key naming a display that isn't plugged in right now is skipped with a
note, not an error, so a `displays.<uuid>` entry for the monitor at the
office can't fail a rebuild on the train.

Why this option exists at all: display scaling is the only lever macOS 26
gives us for "make EVERYTHING bigger", system-wide, including apps the rice
knows nothing about. macOS's own text-size setting writes a value no running
app re-reads, while the accessibility scalars that do work affect contrast
or motion rather than system-wide size — measured, not assumed (the
workshop's notes/macos-settings-matrix.md records the sweep). So
`haus.ui.scale` and `haus.fonts` make the *rice* bigger, and this
makes the *Mac* bigger.

Example:

```nix
{
  "37D8832A-2D66-02CA-B9F7-8F30A301B230" = {
    uiScale = "more-space";
  };
  internal = {
    uiScale = "larger-text";
  };
}
```

<small>Declared in [`modules/displays/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/displays/options.nix).</small>

### `haus.displays.<name>.uiScale`

`null or one of "more-space", "default", "larger-text", "largest-text"` · default `null`

The scaled resolution, as an intent rather than a pixel count — the
same four positions System Settings ▸ Displays offers, named:

  more-space     the largest resolution the panel offers (smallest UI)
  default        the panel's own default mode
  larger-text    between the default and the smallest resolution
  largest-text   the smallest resolution the panel offers (biggest UI)

Resolved per panel from the modes that panel actually reports, so the
same value means the same *thing* on a 14" laptop and a 27" monitor
rather than the same number of pixels. On the 14" MacBook Pro this was
developed on that resolves to 1800x1169 · 1512x982 · 1147x745 ·
1024x665.

Applied at each home-manager activation and set permanently, so it
survives a reboot; re-applying an already-current mode is a no-op, so
a rebuild doesn't flash your screen. null (the default) leaves the
display alone.

When more than one selector names the same attached panel, the more
specific setting wins: UUID over internal over main. This lets a
host-specific display setting refine a broad preset such as
large-print without depending on activation order.

Honest scope: this is a real, system-wide size change — every app gets
bigger, not just the rice's own tools — and the cost is desk space,
because a larger UI means less of it. It also can't run from a rebuild
with no GUI session attached (over SSH, say); the setting applies at
the next activation you run while logged in.

Example:

```nix
"larger-text"
```

<small>Declared in [`modules/displays/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/displays/options.nix).</small>

## haus.hearth

The shell and terminal experience.

### `haus.hearth.editor`

`string` · default `"hx"`

The ONE editor the rice uses everywhere. It's the shell command for
$EDITOR / $VISUAL (git, etc.) AND what every "open in an editor" action
launches — the "Nix Config" palette command, the bar's nix-open item,
and the file-association hijack. Those open the target in a new zellij
tab running this command, so a terminal editor (hx, nvim, vim, nano) is
the natural fit for the rice; a GUI editor's CLI works too (e.g. "code"
or "code -w" to block).

Example:

```nix
"nvim"
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

### `haus.hearth.ghDash.enable`

`boolean` · default `false`

Whether to enable the themed gh-dash GitHub dashboard and its Cmd-G
fullscreen Zellij overlay.

Enabling it gets you the issue and notification tabs (yours, assigned,
unread, participating). The four PR tabs — open / green / red /
shipped — need `haus.git.org` as well, since a PR section is a search
filter scoped to an owner. A host can compose or replace any of it
through home-manager's `programs.gh-dash.settings`: every section list
Hearth writes is a `mkDefault`, per list.

Needs `haus.developer.git.enable` (an assertion enforces it): gh-dash
authenticates out of `gh`'s own credentials, so the Git pack is where
its login comes from.

Example:

```nix
true
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

### `haus.hearth.hijackFileAssociations`

`boolean` · default `false`

When true, build a small opener app and make it the default handler
for ~80 text/code extensions (json, md, ts, nix, rs, go, kdl, …), so
opening or clicking those files opens them in haus.hearth.editor in
a terminal tab. The app declares the types itself (not just `duti`) so
extensions nothing else on the machine declares still bind. Off by
default: silently rewriting your file associations is a jarring,
hard-to-undo change, so it's strictly opt-in. (Extensionless executables
like `bench` are NOT covered — macOS gates the public.unix-executable
handler behind an interactive dialog; set it by hand once if wanted:
`duti -s org.nebelhaus.editoropen public.unix-executable all`.)

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

### `haus.hearth.obsidianVaults`

`list of string` · default `[ ]`

Home-relative paths to existing Obsidian vaults that should use the
Nebelung theme. On each activation, Hearth copies the rendered
theme.css + manifest.json into each vault's .obsidian/themes/Nebelung/
directory, selects Nebelung's dark appearance in appearance.json, and
removes the obsolete "nebelung" CSS snippet from the enabled list.

Empty (the default) leaves every vault untouched. Paths must be
relative to the user's home, may not contain "..", and are skipped
with a warning unless their .obsidian directory already exists.

Example:

```nix
[
  "Library/Mobile Documents/iCloud~md~obsidian/Documents/notes"
]
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

### `haus.hearth.zellijStartLocked`

`boolean` · default `true`

When true (the default), zellij boots into Locked input mode instead of
Normal — its single-key submode leaders (pane, tab, resize, …) stay
inert until you unlock with Ctrl-g, so a stray keystroke can't jump you
into a submode. The `Super`-prefixed launchers (claude / pane / tab /
yazi-peek / fullscreen) are bound in `shared` and keep working while
locked, as do `Alt [` / `Alt ]` (cycle swap layouts) — the rest of
zellij's `Alt` row stays inert while locked, since those keys are
readline/vim word motions the pane's app wants. The bar's bottom-right
quick-hint block only shows in Locked mode. Set false to start in Normal
mode (zellij's own default).

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

## haus.agents

Which coding-agent clients this machine installs, and which one the agent keybinding spawns.

### `haus.agents.clients`

`list of (one of "claude", "codex", "opencode")` · see below

Which coding-agent clients to install. `claude` is Claude Code, `codex`
is OpenAI Codex, `opencode` is OpenCode. The ⌘A terminal binding starts
whichever one `agents.default` names — Claude Code through its own
`--worktree` hook, the others through `holt new`.

A list rather than one bool per client, matching `developer.languages`
— a fourth client later doesn't change this option's shape.

This is the option that makes `agents.default` honest. Naming a client
you have not installed used to fail *at spawn time*, inside the pane,
after the worktree already existed: a flash of
`codex is unavailable`, and litter to reap. `agents.default` must now
be a member of this list, so the same mistake fails the rebuild
instead, with both values named.

Override the package for a client the usual Nix way — an overlay on
`claude-code`, `codex` or `opencode` — rather than dropping the client
here and installing your own copy alongside; two derivations shipping
the same `bin/` name collide in one profile.

Example:

```nix
[
  "claude"
  "codex"
]
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.agents.default`

`one of "claude", "codex", "opencode"` · default `"claude"`

The coding agent started by Pounce's **Spawn Agent** command, by the
⌘A / Super-a zellij binds and the `c` shell alias, and used to reopen
worktrees with no client recorded yet. Each spawned worktree records its
own client, so changing this affects new work but never reopens an
existing Codex or OpenCode task in Claude.

Must be one of `agents.clients` — see there.

Only `claude` can make its own worktree (its native `--worktree` flag,
which fires `holt hook create`); for `codex` and `opencode` ⌘A runs
`holt new` instead, producing the same checkout, branch and registry
entry from the outside. Resuming follows the client too: `codex` reopens
its cwd-filtered `codex resume` picker, `opencode` continues its latest
session for that cwd. All three share one `holt` branch/parking/reap
lifecycle, and all three light up the `agents` bar pill and the zellij
tab-bar badge — the opencode plugin and the codex hooks are written for
you; only Claude Code's stay yours to wire, because Claude owns its own
settings.json (see `haus.sill.items.agents`).

Example:

```nix
"codex"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

## haus.claude

Claude Code integration.

### `haus.claude.globalMd`

`strings concatenated with "\n"` · default `""`

Contents of Claude Code's global memory file, written to
~/.claude/CLAUDE.md (hearth wires it into home-manager). This is your
personal, cross-project operating context. When set, the rice prepends
two short sections of its own — a note that the file is generated and
where to actually edit it, and the `holt` worktree etiquette, since the
rice ships `holt` and that rule is what keeps it working — then your
text. Leave it empty to manage ~/.claude/CLAUDE.md fully by hand
(nothing is written, so the rice never clobbers a by-hand file).

Example:

```nix
''
  # CLAUDE.md — global
  How I like to work across every repo…
''
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

### `haus.claude.skill`

`boolean` · default `true`

Install the `haus` Claude Code skill into
~/.claude/skills/haus, so an agent asked to "install Slack" or
"make everything bigger" edits your host file and runs `haus rebuild`
instead of guessing at dotfiles and `brew install`.

The skill's option reference is GENERATED from the rice revision this
machine is pinned to, so it can only ever describe options that
actually exist here — and it is regenerated by `haus update`. It also
carries this host's current state (which rooms are on, where the host
file is) and a starter AGENTS.md + CLAUDE.md pair for your config repo —
the rules in the first, a one-line import in the second, so a session
opened there is oriented whichever client it runs.

Unrelated to Claude Code's own settings, which follow
haus.developer.agents.enable. This is a plain file drop: a machine
that never runs an agent just carries an unread markdown file. Set
false to leave ~/.claude/skills alone entirely.

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

## haus.accessibility

macOS accessibility keys the rice can actually apply. These write to a TCC-protected domain, so they take effect only when the app you run the rebuild from holds Full Disk Access — otherwise the rice warns and moves on.

### `haus.accessibility.differentiateWithoutColor`

`null or boolean` · default `null`

macOS's "Differentiate without colour" — native UI adds shapes and
text where it would otherwise rely on hue alone. The setting to pair
with a rice built for colour-blind readability.


null (the default) leaves whatever you have alone — this is a
personal setting, so the rice never picks a value for you.

REACHABILITY: `com.apple.universalaccess` is TCC-protected. It writes
only when the app that runs the rebuild holds Full Disk Access
(System Settings ▸ Privacy & Security ▸ Full Disk Access; on macOS 26
a stale grant often needs removing and re-adding with (+)). Without
that grant the rice logs a warning and moves on — it does NOT fail
the rebuild. Worth knowing: an agent-driven `haus rebuild` runs under
a different app than your terminal, so it may skip this while your
own rebuild applies it.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.accessibility.increaseContrast`

`null or boolean` · default `null`

macOS's "Increase contrast" — stronger borders and reduced use of
colour alone to convey state, across native apps. This is the
system-level companion to a high-contrast nebelhaus theme: the theme
restyles the tools nebelhaus colours, this reaches everything else.


null (the default) leaves whatever you have alone — this is a
personal setting, so the rice never picks a value for you.

REACHABILITY: `com.apple.universalaccess` is TCC-protected. It writes
only when the app that runs the rebuild holds Full Disk Access
(System Settings ▸ Privacy & Security ▸ Full Disk Access; on macOS 26
a stale grant often needs removing and re-adding with (+)). Without
that grant the rice logs a warning and moves on — it does NOT fail
the rebuild. Worth knowing: an agent-driven `haus rebuild` runs under
a different app than your terminal, so it may skip this while your
own rebuild applies it.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

## haus.keys

The keys the rice owns — the leader, the palette, the window-chord modifier — and anything extra you hang off the leader.

### `haus.keys.leader`

`one of "caps", "alt-space", "none"` · default `"caps"`

What enters the launcher/leader mode — tap it, then a letter opens an
app, a digit focuses a workspace, ⇧+either throws the focused window
to that workspace and follows it there, an arrow navigates, `-`/`=`
resizes.

  - "caps" (default): Caps Lock. AeroSpace can't bind Caps Lock itself,
    so the rice remaps it to F18 with hidutil and binds that.
  - "alt-space": the leader without giving up Caps Lock. No remap at all.
  - "none": no leader. Caps Lock stays Caps Lock, launch mode is
    unreachable, and nothing is remapped — the setting for a mouse-first
    rice, or for a Mac you are handing to someone else. What the leader
    fronted is still reachable: apps through the palette, window moves
    through service mode's join-with and the palette's own commands.
    Workspace focus and the workspace throws go away with it — they
    live only in launch mode.

The remap is re-applied at every activation and does not survive a
reboot, so moving off "caps" ends it — at the latest, at next boot.

Only meaningful with haus.prowl.enable (AeroSpace owns the modes).

Example:

```nix
"none"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.keys.leaderExtras`

`list of (submodule)` · default `[ ]`

Extra launch-mode (leader) bindings beyond the app roster: tap the leader,
then `key`, to run `command`. Use it for leader actions that aren't
"launch an app" — a script, an AppleScript, opening a URL.

Only meaningful with haus.prowl.enable and keys.leader != "none"
(with no leader there is no launch mode to bind into).

Example:

```nix
[
  {
    key = "enter";
    command = "osascript -e 'tell application \"Things3\" to show quick entry panel'";
    caption = "Things Quick Entry";
  }
]
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.keys.leaderExtras.*.caption`

`null or string` · default `null`

The Launch Mode cheatsheet caption for this action. null falls back
to the raw command, which is rarely what you want — set it.

Example:

```nix
"Things Quick Entry"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.keys.leaderExtras.*.command`

`string` · no default

The shell command run when the leader is followed by `key`; launch
mode exits afterward. It's written verbatim into a small `/bin/sh`
script that AeroSpace execs, so ordinary shell rules apply — `$HOME`
resolves, and single quotes (an `osascript -e '…'`, say) are safe,
which they would not be inlined into AeroSpace's own config.

Example:

```nix
"osascript -e 'tell application \"Things3\" to show quick entry panel'"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.keys.leaderExtras.*.key`

`string` · no default

The AeroSpace key name pressed after the leader (e.g. "enter",
"space", "period", or a letter). Must not collide with a roster
app's key or a built-in launch-mode key (the digits 1-4, the
arrows, `-`/`=`, `v`/`e`/`z`, `,`, `` ` ``, `/`, esc) — nor with
the workspace throws, which are ⇧ + any of those digits or a
roster letter ("shift-1", "shift-b", …). An assertion in
modules/prowl catches a clash rather than letting one binding
silently shadow another.

Example:

```nix
"enter"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.keys.palette`

`one of "cmd-space", "alt-space", "ctrl-space", "none"` · default `"cmd-space"`

What opens the pounce command palette. Registered in-process by the
daemon, so it's near-instant and doesn't go through AeroSpace.

"cmd-space" (default) is the one value that also DISABLES Spotlight's
own ⌘Space, because the two can't share it. Every other value leaves
Spotlight alone — including "none", which hands the palette's job back
to Spotlight entirely. That's a fix as much as an option: the rice used
to take Spotlight's ⌘Space away unconditionally, even where nothing
claimed it.

Only meaningful with haus.pounce.enable.

Example:

```nix
"none"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.keys.windowNav`

`one of "alt", "ctrl-alt", "cmd-alt", "none"` · default `"alt"`

The modifier vocabulary for prowl's window chords — one setting rather
than a bind-per-action, because what people need to move is the
modifier, not the letters. It drives focus (`<mod>` + hjkl), layouts
(`<mod>` + `/` `,`), fullscreen, moving a workspace to the next
monitor (`<mod>⇧⇥`), and entering service mode
(`<mod>⇧;`). Anything that names a workspace — focusing one, or
throwing the focused window there — hangs off `leader` instead, not
this option.

"alt" (default) is ⌥. The alternatives are for **non-US keyboard
layouts**, where ⌥+letter types accented characters — a rice that owns
⌥+letter is unusable on those, which is the concrete reason this option
exists.

Whatever you pick, AeroSpace claims those chords **globally**, so they
stop reaching whatever owned them inside a terminal. The surface is
small now that the workspace throws moved to the leader: only hjkl,
`/` `,`, `f`, `⇧⇥` and `⇧;`, none of which a roster letter can land
on — and `<mod>⇥` is free again, since workspace back-and-forth
retired in favour of pounce's cross-workspace ⌘⇥ switcher. (Under
"ctrl-alt" that used to bite — the throws were `⌃⌥⇧` + an app's roster
letter, so an app on `a` silently ate hearth's zellij
`Ctrl Alt Shift a` in-place-agent bind. That collision is gone.)
Nothing on a stock macOS collides either: the only ⌃⌥ system hotkeys
are input-source switching (⌃⌥Space, off by default) and hyper-F13.

"none" drops the modifier chords entirely: no focus/layout chords, no
service mode. Combined with `leader = "none"` that's a rice where the
tiler tiles and the keyboard is left alone — mouse-first. The cheatsheet
follows, so it never advertises a key that does nothing.

Only meaningful with haus.prowl.enable.

Example:

```nix
"ctrl-alt"
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

## haus.hotCorners

What each corner of the screen does when the pointer reaches it. Every corner is unset by default, so the rice never overwrites one you set yourself.

### `haus.hotCorners.bottomLeft`

`null or one of "disabled", "mission-control", "application-windows", "desktop", "launchpad", "notification-center", "quick-note", "screen-saver", "prevent-screen-saver", "sleep-display", "lock-screen"` · default `null`

What happens when the pointer reaches the bottom-left corner of the main
display.

```
              disabled  nothing happens — the corner is explicitly claimed and left inert
       mission-control  Mission Control: every window and Space, zoomed out
   application-windows  App Exposé: every window of the app you're in
               desktop  push all windows aside and show the desktop
             launchpad  the grid of installed apps (on macOS 26 this opens the Apps view)
   notification-center  slide out Notification Center and its widgets
            quick-note  start a Quick Note — Apple's own default for the bottom-right corner
          screen-saver  start the screen saver immediately
  prevent-screen-saver  hold the screen saver off while the pointer rests here
         sleep-display  put the display to sleep (the machine keeps running)
           lock-screen  lock the screen and return to the login window
```

null (the default) writes nothing at all, which is not the same as
"disabled": corners are a setting people have usually already made by
hand, and a rice that names one it doesn't care about would silently
erase it. Use `"disabled"` to explicitly claim a corner and make it inert.

Setting a corner also clears its MODIFIER key. macOS stores "hold ⌘ for
this corner" separately (`wvous-*-modifier`), and a leftover modifier from
an earlier setup makes a corner the rice just declared look broken —
nothing happens, because you weren't holding the key nobody told you
about. Corners the rice leaves at null keep whatever modifier they have.

Worth knowing if you also run tiling: `mission-control` and `desktop` are
macOS's own window and Space management, which prowl replaces. They still
work, they just show you a view of the windows prowl is arranging.

Example:

```nix
"mission-control"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.hotCorners.bottomRight`

`null or one of "disabled", "mission-control", "application-windows", "desktop", "launchpad", "notification-center", "quick-note", "screen-saver", "prevent-screen-saver", "sleep-display", "lock-screen"` · default `null`

What happens when the pointer reaches the bottom-right corner of the main
display.

```
              disabled  nothing happens — the corner is explicitly claimed and left inert
       mission-control  Mission Control: every window and Space, zoomed out
   application-windows  App Exposé: every window of the app you're in
               desktop  push all windows aside and show the desktop
             launchpad  the grid of installed apps (on macOS 26 this opens the Apps view)
   notification-center  slide out Notification Center and its widgets
            quick-note  start a Quick Note — Apple's own default for the bottom-right corner
          screen-saver  start the screen saver immediately
  prevent-screen-saver  hold the screen saver off while the pointer rests here
         sleep-display  put the display to sleep (the machine keeps running)
           lock-screen  lock the screen and return to the login window
```

null (the default) writes nothing at all, which is not the same as
"disabled": corners are a setting people have usually already made by
hand, and a rice that names one it doesn't care about would silently
erase it. Use `"disabled"` to explicitly claim a corner and make it inert.

Setting a corner also clears its MODIFIER key. macOS stores "hold ⌘ for
this corner" separately (`wvous-*-modifier`), and a leftover modifier from
an earlier setup makes a corner the rice just declared look broken —
nothing happens, because you weren't holding the key nobody told you
about. Corners the rice leaves at null keep whatever modifier they have.

Worth knowing if you also run tiling: `mission-control` and `desktop` are
macOS's own window and Space management, which prowl replaces. They still
work, they just show you a view of the windows prowl is arranging.

Example:

```nix
"mission-control"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.hotCorners.topLeft`

`null or one of "disabled", "mission-control", "application-windows", "desktop", "launchpad", "notification-center", "quick-note", "screen-saver", "prevent-screen-saver", "sleep-display", "lock-screen"` · default `null`

What happens when the pointer reaches the top-left corner of the main
display.

```
              disabled  nothing happens — the corner is explicitly claimed and left inert
       mission-control  Mission Control: every window and Space, zoomed out
   application-windows  App Exposé: every window of the app you're in
               desktop  push all windows aside and show the desktop
             launchpad  the grid of installed apps (on macOS 26 this opens the Apps view)
   notification-center  slide out Notification Center and its widgets
            quick-note  start a Quick Note — Apple's own default for the bottom-right corner
          screen-saver  start the screen saver immediately
  prevent-screen-saver  hold the screen saver off while the pointer rests here
         sleep-display  put the display to sleep (the machine keeps running)
           lock-screen  lock the screen and return to the login window
```

null (the default) writes nothing at all, which is not the same as
"disabled": corners are a setting people have usually already made by
hand, and a rice that names one it doesn't care about would silently
erase it. Use `"disabled"` to explicitly claim a corner and make it inert.

Setting a corner also clears its MODIFIER key. macOS stores "hold ⌘ for
this corner" separately (`wvous-*-modifier`), and a leftover modifier from
an earlier setup makes a corner the rice just declared look broken —
nothing happens, because you weren't holding the key nobody told you
about. Corners the rice leaves at null keep whatever modifier they have.

Worth knowing if you also run tiling: `mission-control` and `desktop` are
macOS's own window and Space management, which prowl replaces. They still
work, they just show you a view of the windows prowl is arranging.

Example:

```nix
"mission-control"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.hotCorners.topRight`

`null or one of "disabled", "mission-control", "application-windows", "desktop", "launchpad", "notification-center", "quick-note", "screen-saver", "prevent-screen-saver", "sleep-display", "lock-screen"` · default `null`

What happens when the pointer reaches the top-right corner of the main
display.

```
              disabled  nothing happens — the corner is explicitly claimed and left inert
       mission-control  Mission Control: every window and Space, zoomed out
   application-windows  App Exposé: every window of the app you're in
               desktop  push all windows aside and show the desktop
             launchpad  the grid of installed apps (on macOS 26 this opens the Apps view)
   notification-center  slide out Notification Center and its widgets
            quick-note  start a Quick Note — Apple's own default for the bottom-right corner
          screen-saver  start the screen saver immediately
  prevent-screen-saver  hold the screen saver off while the pointer rests here
         sleep-display  put the display to sleep (the machine keeps running)
           lock-screen  lock the screen and return to the login window
```

null (the default) writes nothing at all, which is not the same as
"disabled": corners are a setting people have usually already made by
hand, and a rice that names one it doesn't care about would silently
erase it. Use `"disabled"` to explicitly claim a corner and make it inert.

Setting a corner also clears its MODIFIER key. macOS stores "hold ⌘ for
this corner" separately (`wvous-*-modifier`), and a leftover modifier from
an earlier setup makes a corner the rice just declared look broken —
nothing happens, because you weren't holding the key nobody told you
about. Corners the rice leaves at null keep whatever modifier they have.

Worth knowing if you also run tiling: `mission-control` and `desktop` are
macOS's own window and Space management, which prowl replaces. They still
work, they just show you a view of the windows prowl is arranging.

Example:

```nix
"mission-control"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

## haus.screenshots

Where ⇧⌘4 puts its files, in what format, and whether it draws a window shadow or a preview thumbnail. Unset by default, so macOS's own choices stand.

### `haus.screenshots.format`

`null or one of "png", "jpg", "pdf", "tiff", "heic", "gif"` · default `null`

The image format new screenshots are saved in. null (the default)
leaves macOS's own choice alone, which is png.

png is lossless and the right default for UI and text — a jpg
screenshot of a terminal has visible ringing around every glyph. jpg
is worth choosing only when you screenshot photographs often enough
for the file sizes to matter.

Example:

```nix
"png"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.screenshots.includeDate`

`null or boolean` · default `null`

Whether filenames carry the date and time ("Screenshot 2026-08-03 at
13.37.20.png") or just a counter ("Screenshot 1.png"). null (the
default) leaves macOS's own choice alone, which is to include it.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.screenshots.location`

`null or string` · default `null`

Where ⇧⌘3 / ⇧⌘4 / ⇧⌘5 write their files. null (the default) leaves
macOS's own choice alone, which is the Desktop.

Absolute, or starting with `~/` — the rice expands the `~` for you and
CREATES the directory during activation. Both halves matter: macOS
stores this string verbatim and expands nothing, and if the path does
not exist screencapture silently falls back to the Desktop, so a
typo'd or not-yet-created folder looks exactly like the setting having
been ignored.

Example:

```nix
"~/Pictures/Screenshots"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.screenshots.shadow`

`null or boolean` · default `null`

Whether a window capture (⇧⌘4 then Space) keeps macOS's big soft drop
shadow. null (the default) leaves macOS's own choice alone, which is
to include it.

false is the setting to want if screenshots go into documentation: the
shadow is transparent padding, so it adds a wide invisible margin that
every layout then has to fight. Holding ⌥ while you click suppresses
it for one capture either way.

Example:

```nix
false
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.screenshots.thumbnail`

`null or boolean` · default `null`

Whether the floating preview thumbnail appears in the bottom-right
corner after a capture. null (the default) leaves macOS's own choice
alone, which is to show it.

false writes the file immediately instead of after the ~5s the
thumbnail waits around — the setting to want if you screenshot in
quick succession, or if you script anything that reads the file. The
cost is losing the markup/drag affordance the thumbnail offers.

Example:

```nix
false
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

## haus.lock

Whether waking this Mac needs a password, and how long the grace period is. Worth setting on any laptop that leaves the house.

### `haus.lock.requirePassword`

`null or boolean` · default `null`

Require a password to wake this Mac from sleep or the screen saver.
null (the default) leaves macOS's own choice alone.

The one setting in this group worth turning on for ANY shared or
portable machine — a family Mac, a laptop that leaves the house.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.lock.requirePasswordDelay`

`null or (unsigned integer, meaning >=0)` · default `null`

Seconds to wait after sleep/screen-saver starts before
`requirePassword` actually locks the screen — macOS's "grace period".
null (the default) leaves macOS's own choice alone.

0 locks instantly. Has no effect while `requirePassword` is null or
false.

Example:

```nix
5
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

## haus.menuBar

The stock menu bar: what the clock shows, and which Control Center glyphs sit beside it. (The nebelhaus bar itself is `sill`.)

### `haus.menuBar.clock.analog`

`null or boolean` · default `null`

Draw an analog clock face instead of a digital readout. null (the
default) leaves macOS's own choice alone (digital).

Example:

```nix
false
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.menuBar.clock.format`

`null or one of "12h", "24h"` · default `null`

12-hour or 24-hour menu bar clock. null (the default) leaves
macOS's own choice alone (region-dependent, usually 12h in the US).

Example:

```nix
"24h"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.menuBar.clock.showDate`

`null or one of "when-space-allows", "always", "never"` · default `null`

Whether the full date appears next to the time. null (the default)
leaves macOS's own choice alone ("when-space-allows").

Example:

```nix
"always"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.menuBar.clock.showDayOfWeek`

`null or boolean` · default `null`

Show the day of the week next to the clock. null (the default)
leaves macOS's own choice alone.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.menuBar.clock.showSeconds`

`null or boolean` · default `null`

Show the clock to second precision instead of minutes. null (the
default) leaves macOS's own choice alone.

Example:

```nix
false
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.menuBar.controlCenter.airdrop`

`null or boolean` · default `null`

Whether the AirDrop control has a menu bar icon of its own. null (the default) leaves macOS's own choice alone.

Example:

```nix
false
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.menuBar.controlCenter.batteryPercentage`

`null or boolean` · default `null`

Show the battery percentage next to its menu bar icon. null (the
default) leaves macOS's own choice alone.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.menuBar.controlCenter.bluetooth`

`null or boolean` · default `null`

Whether the Bluetooth control has a menu bar icon of its own. null (the default) leaves macOS's own choice alone.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.menuBar.controlCenter.displayBrightness`

`null or boolean` · default `null`

Whether the Screen Brightness control has a menu bar icon of its own. null (the default) leaves macOS's own choice alone.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.menuBar.controlCenter.focus`

`null or boolean` · default `null`

Whether the Focus control has a menu bar icon of its own. null (the default) leaves macOS's own choice alone.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.menuBar.controlCenter.nowPlaying`

`null or boolean` · default `null`

Whether the Now Playing control has a menu bar icon of its own. null (the default) leaves macOS's own choice alone.

Example:

```nix
false
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.menuBar.controlCenter.sound`

`null or boolean` · default `null`

Whether the Sound control has a menu bar icon of its own. null (the default) leaves macOS's own choice alone.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

## haus.security

Security posture: the built-in application firewall and how strict it is. Off on a fresh Mac; the setting to turn on for a laptop that joins networks you don't own.

### `haus.security.firewall.allowSigned`

`null or boolean` · default `null`

Let built-in, Apple-signed software receive incoming connections
without asking. null (the default) leaves macOS's own choice alone.
Has no effect while `enable` is null or false.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.security.firewall.allowSignedApp`

`null or boolean` · default `null`

Let downloaded, signed third-party software receive incoming
connections without asking. null (the default) leaves macOS's own
choice alone. Has no effect while `enable` is null or false.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.security.firewall.blockAllIncoming`

`null or boolean` · default `null`

Block ALL incoming connections, including ones apps ask for (AirDrop,
screen sharing, a dev server on your LAN). null (the default) leaves
macOS's own choice alone. Has no effect while `enable` is null or
false.

Example:

```nix
false
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.security.firewall.enable`

`null or boolean` · default `null`

The built-in application firewall. null (the default) leaves
macOS's own choice alone (off, on a fresh install).

The "public Wi-Fi" setting: worth true for a laptop that leaves
home, closer to unnecessary for a desktop that never does.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.security.firewall.stealthMode`

`null or boolean` · default `null`

Don't respond to network probes (ping, closed-port connection
attempts) at all, instead of replying "connection refused". null
(the default) leaves macOS's own choice alone. Has no effect while
`enable` is null or false.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

## haus.sound

Alert volume and sound, interface sound effects, and the boot chime. Volume is 0–100 the way the slider reads it — macOS stores a curve, and the rice does the conversion.

### `haus.sound.alertSound`

`null or one of "Basso", "Blow", "Bottle", "Frog", "Funk", "Glass", "Hero", "Morse", "Ping", "Pop", "Purr", "Sosumi", "Submarine", "Tink"` · default `null`

Which sound the alert beep plays, by name:

```
  Basso  Blow  Bottle  Frog  Funk  Glass  Hero  Morse  Ping  Pop  Purr  Sosumi  Submarine  Tink
```

null (the default) leaves macOS's own choice alone.

An enum rather than a path on purpose. macOS stores an absolute path
here and validates nothing, and a path that doesn't resolve does not
fall back to the default beep — it goes SILENT (measured by ear,
2026-08-08), while the plist still reads like a working setting. The
rice builds the path from the name and skips the write with a warning
if that file is missing, so a macOS release retiring a sound can't
quietly mute you.

Example:

```nix
"Submarine"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.sound.alertVolume`

`null or integer between 0 and 100 (both inclusive)` · default `null`

How loud the alert beep is, 0–100, exactly as the slider in System
Settings ▸ Sound reads. null (the default) leaves macOS's own choice
alone.

The rice converts to the exponential value macOS actually stores
(`e^(v/100 − 1)`, with 0 meaning silence), because that key is not a
fraction: writing the obvious `0.5` gets you 31%.

TWO WRITERS: the volume keys and the Sound pane write this same key.
Declaring it means every rebuild reasserts your number over anything
you changed by hand since — which is the point of declaring it, but
leave it null if you'd rather the slider win.

Example:

```nix
50
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.sound.startupChime`

`null or boolean` · default `null`

The chime a Mac plays at boot. null (the default) leaves it alone.

The odd one in this group: it is firmware state (`nvram StartupMute`),
not a preference, so it survives an OS reinstall and a wiped home
directory — and it is the only setting here that needs the rebuild to
run as root, which activation already does.

Example:

```nix
false
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.sound.uiSounds`

`null or boolean` · default `null`

Play user-interface sound effects — the Trash whoosh, the screenshot
shutter, the Mail whoosh. null (the default) leaves macOS's own
choice alone.

Example:

```nix
false
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.sound.volumeFeedback`

`null or boolean` · default `null`

Play a sound when the volume keys change the volume. null (the
default) leaves macOS's own choice alone.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

## haus.locale

Language, region, units and keyboard layouts. What a rice in any language other than English needs — and the one room whose settings reach apps you already have open, because the rice posts the change notification macOS itself posts.

### `haus.locale.hourFormat`

`null or one of "12h", "24h"` · default `null`

Force 12- or 24-hour time everywhere, overriding whatever `region`
implies. null (the default) follows the region.

System-wide, unlike `haus.menuBar.clock.format`, which is only the
menu bar clock's own key. Setting both is fine and normal; setting
only this one still changes the menu bar, because the clock has no
opinion of its own until you give it one.

Example:

```nix
"24h"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.locale.inputSources`

`null or (list of string)` · default `null`

The keyboard layouts available in the input menu, by input-source id
(`com.apple.keylayout.*`). null (the default) leaves your layouts
alone. List them with:

```
hausax input-sources --all
```

THIS ONE OWNS THE LIST. Unlike every other option in §5.6's groups, a
non-null value here is exhaustive: layouts you don't name get
disabled, because "add these and keep whatever else was there" makes
a rice that can never remove a layout it once added. Non-keyboard
input methods (emoji picker, press-and-hold) are never touched.

Applied through the documented Text Input Sources API rather than by
writing `com.apple.HIToolbox` directly. The plist route does work, but
it resolves a layout by an English display name (`Swiss French`, not
`SwissFrench`) next to a numeric id that is required and never
validated — a table the rice would have to hardcode and would get
wrong for exactly the layouts nobody here tests.

Example:

```nix
[
  "com.apple.keylayout.US"
  "com.apple.keylayout.German"
]
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.locale.language`

`null or (list of string)` · default `null`

Preferred languages, best first — the order System Settings ▸ General
▸ Language & Region shows. null (the default) leaves macOS's own list
alone.

Apps use the first entry they have a translation for, so a list is a
fallback chain, not a single choice.

TAKES EFFECT ON RELAUNCH: an app picks its language when it starts.
Already-open apps keep the old one until you quit and reopen them,
and the login window follows at next login. Nothing the rice can post
changes that — it is how bundle resources load.

Example:

```nix
[
  "de-DE"
  "en-GB"
]
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.locale.metric`

`null or boolean` · default `null`

Use the metric system, overriding whatever `region` implies. null
(the default) follows the region.

Writes BOTH keys macOS keeps for this (`AppleMetricUnits` and
`AppleMeasurementUnits`), because it writes both itself and only one
of them is load-bearing — setting the friendlier-looking
`AppleMeasurementUnits` alone leaves a plist that reads right and a
machine that ignores it.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.locale.region`

`null or string` · default `null`

The region whose formats macOS uses — dates, number separators, paper
size, the first day of the week. An ICU locale identifier
(`de_DE`, `en_GB`, `fr_CA`). null (the default) leaves macOS's own
choice alone.

This is the lever with the most reach in the group: it moves the hour
format, the measurement system and the first weekday together. Set it
before reaching for the individual overrides below — and note there is
deliberately no `firstWeekday` option, because macOS's own
`AppleFirstWeekday` key is stored and then ignored (measured; it is
the second dict-valued key in this domain found to do that). The
region's own answer is the only one that applies.

Example:

```nix
"de_DE"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.locale.temperature`

`null or one of "celsius", "fahrenheit"` · default `null`

Temperature unit, overriding whatever `region` implies. null (the
default) follows the region. Separate from `metric` because macOS
keeps it separate — a metric machine reporting °F is a real
combination, not a mistake.

Example:

```nix
"celsius"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

## haus.power

Sleep timers and Low Power Mode, said separately for battery and charger — which is the whole point, and why this is built on `pmset` rather than on nix-darwin's own power options.

### `haus.power.computerSleep.battery`

`null or positive integer, meaning >0, or value "never" (singular enum)` · default `null`

Minutes of idleness before the Mac sleeps while on battery, or
`"never"`. null (the default) leaves macOS's own choice alone.

A desktop Mac has no battery profile to write, so `pmset` warns
and the rebuild carries on — set the `charger` half there.

Example:

```nix
10
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.power.computerSleep.charger`

`null or positive integer, meaning >0, or value "never" (singular enum)` · default `null`

Minutes of idleness before the Mac sleeps while on the charger, or
`"never"`. null (the default) leaves macOS's own choice alone.

A desktop Mac has no battery profile to write, so `pmset` warns
and the rebuild carries on — set the `charger` half there.

Example:

```nix
10
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.power.diskSleep.battery`

`null or positive integer, meaning >0, or value "never" (singular enum)` · default `null`

Minutes of idleness before the disk spins down while on battery, or
`"never"`. null (the default) leaves macOS's own choice alone.

A desktop Mac has no battery profile to write, so `pmset` warns
and the rebuild carries on — set the `charger` half there.

Example:

```nix
10
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.power.diskSleep.charger`

`null or positive integer, meaning >0, or value "never" (singular enum)` · default `null`

Minutes of idleness before the disk spins down while on the charger, or
`"never"`. null (the default) leaves macOS's own choice alone.

A desktop Mac has no battery profile to write, so `pmset` warns
and the rebuild carries on — set the `charger` half there.

Example:

```nix
10
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.power.displaySleep.battery`

`null or positive integer, meaning >0, or value "never" (singular enum)` · default `null`

Minutes of idleness before the display sleeps while on battery, or
`"never"`. null (the default) leaves macOS's own choice alone.

A desktop Mac has no battery profile to write, so `pmset` warns
and the rebuild carries on — set the `charger` half there.

Example:

```nix
10
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.power.displaySleep.charger`

`null or positive integer, meaning >0, or value "never" (singular enum)` · default `null`

Minutes of idleness before the display sleeps while on the charger, or
`"never"`. null (the default) leaves macOS's own choice alone.

A desktop Mac has no battery profile to write, so `pmset` warns
and the rebuild carries on — set the `charger` half there.

Example:

```nix
10
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.power.lowPowerMode.battery`

`null or boolean` · default `null`

Low Power Mode while on battery. null (the default) leaves
macOS's own choice alone.

The setting with the clearest opinion in this group for a laptop:
on for battery, off for the charger, is what most people want and
almost nobody sets.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.power.lowPowerMode.charger`

`null or boolean` · default `null`

Low Power Mode while plugged in. null (the default) leaves
macOS's own choice alone.

Example:

```nix
false
```

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

## haus.prowl

Tiling window management and the Caps-Lock leader launcher.

### `haus.prowl.enable`

`boolean` · default `true`

AeroSpace tiling window management + the leader-key launcher.

This is the room switch: off drops AeroSpace, its launch agent, the
wake-time window re-sort and the key remap entirely. To keep the tiler but
leave the keyboard alone, use haus.keys.leader = "none" and
haus.keys.windowNav = "none" instead of turning the room off.

<small>Declared in [`modules/prowl/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/prowl/options.nix).</small>

## haus.sill

The menu bar, and which pills it draws.

### `haus.sill.aiUsage.provider`

`one of "latest", "claude", "codex", "opencode"` · default `"latest"`

Which AI provider to display in the main pill: `latest` (default, automatically
shows whichever provider reported most recently), or one of
`claude`, `codex`, `opencode`.
Clicking the pill always displays the full dropdown with all reporting providers.

Note this is about *usage readouts*, not about which client `holt` can
spawn: a provider reports here whenever it has data for your account —
Codex notably does so from a ChatGPT login alone, with no CLI installed
— so it is deliberately not tied to `haus.agents.clients`.

Example:

```nix
"claude"
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.battery.hideOver`

`null or signed integer` · default `null`

Hide the battery pill when charge percentage is above this threshold
(e.g., set to 80 to show the battery pill only when charge is at or below 80%).

Example:

```nix
80
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.bottom.enable`

`boolean` · default `false`

Draw a SECOND bar along the bottom of the screen, at the same time as
the menu bar one. `haus.sill.bottom.items` picks what goes on it; an
empty set draws an empty strip, which the module warns about.

SketchyBar has no two-bars-in-one-process mode — an instance is named
after `basename(argv[0])` and keys both its lock file and its mach
service on that name — so this is a second launchd agent running the
SAME binary under a second name, `sill-bottom`. That name is also the
CLI for it: `sill-bottom --set cpu label=…` talks to the bottom bar the
way `sketchybar --set` talks to the menu bar one.

Two things macOS does not do for you here. It reserves the top strip of
every display for the menu bar but reserves NOTHING at the bottom, so
windows would sit under this bar: prowl carves the room out of its
outer-bottom gap whenever this is on (with `haus.prowl.enable = false`,
nothing reserves it and your windows will run underneath). And the Dock,
if you keep it at the bottom, shares that edge — move it to a side, or
leave it hidden.

Example:

```nix
true
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.bottom.items`

`submodule` · default `{ }`

Which pills the bottom bar draws, one bool each, all default false. A
pill named here MOVES: it is drawn on the bottom bar and not on the menu
bar, whatever `haus.sill.items` says about it — so there is one switch
per pill per bar and never two copies of the same readout.

The set is the five core pills (`clock`, `weather`, `media`, `battery`,
`wifi`) plus the `haus.sill.items` extras (`cpu`, `memory`, `volume`,
`calendar`, `caffeinate`, `agents`, `aiUsage`, `elgato`, `harvest`). The
whole left side (workspace pills, front app, the leader picker) and the
tour stay on the menu bar. The hush pill stays up top too — it rides
`haus.hush.enable` rather than this table.

Needs `haus.sill.bottom.enable`; without it nothing here is drawn.

Example:

```nix
{
  cpu = true;
  media = true;
  weather = true;
}
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.bottom.items.agents`

`boolean` · default `false`

A paw pill tracking your agent-worktree panes — amber when one is blocked on you, click for the per-agent list, each row marked with the client sitting in it; left-click a row to jump to that pane, ⌥/right-click for a live `zellij subscribe` peek. Fed by each client's own lifecycle hooks, which all call `agent-state` (also installed as ~/.config/sketchybar/plugins/agents-hook.sh): Opencode's plugin and Codex's ~/.codex/hooks.json are written for you (Codex asks you to trust its hooks the first time it sees them), while Claude Code's four agent-state hooks stay yours to point at it in ~/.claude/settings.json — Claude owns that file and rewrites it, so the rice merges in only the keys it must and never touches those four. (The two worktree hooks ARE declared, in hearth: they point at a rice-controlled path and self-heal on rebuild.) A row whose zellij pane is gone drops off by itself, which is what stands in for the session-end event Codex doesn't have. Dormant until a client fires.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.bottom.items.aiUsage`

`boolean` · default `false`

A gauge pill showing AI usage (Claude Code/Codex subscription rate limits as %, or Opencode API token cost as daily $). Automatically shows whichever provider reported most recently. Click for expanded session/weekly limits and daily/monthly API costs with model breakdowns. Claude and Opencode are read off disk; Codex has no local usage data, so its row is polled from your ChatGPT account with the OAuth token in ~/.codex/auth.json (refreshed and rewritten in place) — no Codex login on the machine, no call is made. Claude's row is pushed by its statusline; the Codex and Opencode rows are pulled by the pill itself on a 3-minute TTL, so they stay current on a machine that never opens Claude at all. Claude and Opencode also get a `tokens` block in the dropdown — raw tokens moved today, this week, this month and all time (cache reads and all), two periods to a line so a full set reads as a 2×2, purely for the fun of watching the number climb. A period with nothing in it is left out rather than printed as a zero, so the block simply gets smaller, and a closing `∑ Everything` adds every provider up when more than one is reporting. It is a score, not a limit: nothing acts on it, and it never reaches the pill's own label. Claude's is summed from your transcripts on a 15-minute TTL behind an index, so only sessions that grew since the last pass are re-read; Codex has no row because it keeps no local history to count.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.bottom.items.battery`

`boolean` · default `false`

The battery pill.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.bottom.items.caffeinate`

`boolean` · default `false`

A coffee pill that prevents idle system sleep for 1/2/4/8 hours, a custom whole-hour duration, or indefinitely. The display may still turn off; closing a MacBook lid still sleeps it. Uses macOS's built-in `caffeinate`, so there is no extra package.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.bottom.items.calendar`

`boolean` · default `false`

Your next timed event, with a click-popup of the next five. Pulls in `ical-buddy` automatically and reads Calendar, so macOS prompts for Calendar access on first run.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.bottom.items.clock`

`boolean` · default `false`

The clock pill, pinned to the far right.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.bottom.items.cpu`

`boolean` · default `false`

Total CPU load, as a percentage pill.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.bottom.items.elgato`

`boolean` · default `false`

Toggles an Elgato Key Light on the local network. The light is found over mDNS (or pinned with `haus.sill.elgato.host`), and the pill draws dim when it can't be reached at all — a light that dropped off the wifi is not the same thing as a light that's switched off.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.bottom.items.harvest`

`boolean` · default `false`

A Harvest time-tracking pill; needs a ~/.config/sketchybar/harvest_secrets.sh you provide.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.bottom.items.media`

`boolean` · default `false`

The now-playing track (scrolls; auto-hides when nothing plays, dims when paused, click to play/pause). It reads the same system-wide session Control Center does, so it follows a browser tab as readily as Apple Music or Spotify, and its icon says which app the sound is coming from. SketchyBar's own `media_change` event has been dead since macOS 15.4, where Apple started requiring an entitlement to talk to `mediaremoted`; the pill is fed instead by `media-control`, which does the read from inside the entitled `/usr/bin/perl`. That is a private-framework route Apple could close in any point release — `media-control test` exits non-zero once it has.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.bottom.items.memory`

`boolean` · default `false`

Memory-pressure percentage pill.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.bottom.items.volume`

`boolean` · default `false`

Output volume / mute state.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.bottom.items.weather`

`boolean` · default `false`

The weather pill and its click-to-open forecast popover.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.bottom.items.wifi`

`boolean` · default `false`

The Wi-Fi status pill.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.clock.mode`

`one of "full", "compact"` · default `"full"`

The display mode for the clock pill: `full` (default, e.g. "Fri Jul 31  09:41 AM" with calendar icon)
or `compact` (e.g. "Fri 31/7 9:41" without icon and trimmed spacing).

Example:

```nix
"compact"
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.elgato.host`

`string` · default `""`

Which Elgato Key Light the `elgato` pill toggles — a hostname or IP,
optionally with a `:port` (the light's HTTP API is on 9123).

Empty (the default) means discover it: the pill browses mDNS for
`_elg._tcp`, caches what it found in
`~/.local/state/nebelhaus/elgato-host`, and re-browses at most once a
minute whenever the light stops answering — so a light that took a new
DHCP address comes back on its own, without a rebuild. Pin this when
you have more than one light, when the light has a static lease, or
when mDNS is unreliable on your network.

Example:

```nix
"elgato-key-light-mini-57a3.local"
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.enable`

`boolean` · default `true`

The SketchyBar menu bar. When off, the native macOS menu bar is kept
(nebelhaus stops hiding it) and no bar is drawn.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.items`

`submodule` · default `{ }`

Which SketchyBar pills to draw, one bool each. The core pills —
`clock`, `weather`, `media`, `battery`, `wifi` — default true; the extras
— the readouts `cpu`, `memory`, `volume`, `calendar`, `caffeinate`
and the personal `agents`, `aiUsage`, `elgato`, `harvest` —
default false. Set
only what you want to change:

  haus.sill.items = {
    weather = false;   # drop a default-on core pill
    cpu = true;        # add an off-by-default readout
    caffeinate = true; # add the keep-awake controller
  };

A pill set false is never created (its update script doesn't run either).
The hush (Do-Not-Disturb) pill is separate — it rides
haus.hush.enable, not this set.

This is the MENU BAR's set. `haus.sill.bottom.items` is the same table
for the optional second bar along the bottom of the screen, and a pill
named there moves down rather than being drawn twice.

Example:

```nix
{
  cpu = true;
  weather = false;
}
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.items.agents`

`boolean` · default `false`

A paw pill tracking your agent-worktree panes — amber when one is blocked on you, click for the per-agent list, each row marked with the client sitting in it; left-click a row to jump to that pane, ⌥/right-click for a live `zellij subscribe` peek. Fed by each client's own lifecycle hooks, which all call `agent-state` (also installed as ~/.config/sketchybar/plugins/agents-hook.sh): Opencode's plugin and Codex's ~/.codex/hooks.json are written for you (Codex asks you to trust its hooks the first time it sees them), while Claude Code's four agent-state hooks stay yours to point at it in ~/.claude/settings.json — Claude owns that file and rewrites it, so the rice merges in only the keys it must and never touches those four. (The two worktree hooks ARE declared, in hearth: they point at a rice-controlled path and self-heal on rebuild.) A row whose zellij pane is gone drops off by itself, which is what stands in for the session-end event Codex doesn't have. Dormant until a client fires.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.items.aiUsage`

`boolean` · default `false`

A gauge pill showing AI usage (Claude Code/Codex subscription rate limits as %, or Opencode API token cost as daily $). Automatically shows whichever provider reported most recently. Click for expanded session/weekly limits and daily/monthly API costs with model breakdowns. Claude and Opencode are read off disk; Codex has no local usage data, so its row is polled from your ChatGPT account with the OAuth token in ~/.codex/auth.json (refreshed and rewritten in place) — no Codex login on the machine, no call is made. Claude's row is pushed by its statusline; the Codex and Opencode rows are pulled by the pill itself on a 3-minute TTL, so they stay current on a machine that never opens Claude at all. Claude and Opencode also get a `tokens` block in the dropdown — raw tokens moved today, this week, this month and all time (cache reads and all), two periods to a line so a full set reads as a 2×2, purely for the fun of watching the number climb. A period with nothing in it is left out rather than printed as a zero, so the block simply gets smaller, and a closing `∑ Everything` adds every provider up when more than one is reporting. It is a score, not a limit: nothing acts on it, and it never reaches the pill's own label. Claude's is summed from your transcripts on a 15-minute TTL behind an index, so only sessions that grew since the last pass are re-read; Codex has no row because it keeps no local history to count.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.items.battery`

`boolean` · default `true`

The battery pill.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.items.caffeinate`

`boolean` · default `false`

A coffee pill that prevents idle system sleep for 1/2/4/8 hours, a custom whole-hour duration, or indefinitely. The display may still turn off; closing a MacBook lid still sleeps it. Uses macOS's built-in `caffeinate`, so there is no extra package.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.items.calendar`

`boolean` · default `false`

Your next timed event, with a click-popup of the next five. Pulls in `ical-buddy` automatically and reads Calendar, so macOS prompts for Calendar access on first run.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.items.claudeUsage`

`boolean` · default `false`

Deprecated alias for `aiUsage`.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.items.clock`

`boolean` · default `true`

The clock pill, pinned to the far right.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.items.cpu`

`boolean` · default `false`

Total CPU load, as a percentage pill.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.items.elgato`

`boolean` · default `false`

Toggles an Elgato Key Light on the local network. The light is found over mDNS (or pinned with `haus.sill.elgato.host`), and the pill draws dim when it can't be reached at all — a light that dropped off the wifi is not the same thing as a light that's switched off.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.items.harvest`

`boolean` · default `false`

A Harvest time-tracking pill; needs a ~/.config/sketchybar/harvest_secrets.sh you provide.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.items.media`

`boolean` · default `true`

The now-playing track (scrolls; auto-hides when nothing plays, dims when paused, click to play/pause). It reads the same system-wide session Control Center does, so it follows a browser tab as readily as Apple Music or Spotify, and its icon says which app the sound is coming from. SketchyBar's own `media_change` event has been dead since macOS 15.4, where Apple started requiring an entitlement to talk to `mediaremoted`; the pill is fed instead by `media-control`, which does the read from inside the entitled `/usr/bin/perl`. That is a private-framework route Apple could close in any point release — `media-control test` exits non-zero once it has.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.items.memory`

`boolean` · default `false`

Memory-pressure percentage pill.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.items.volume`

`boolean` · default `false`

Output volume / mute state.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.items.weather`

`boolean` · default `true`

The weather pill and its click-to-open forecast popover.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.items.wifi`

`boolean` · default `true`

The Wi-Fi status pill.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.sill.position`

`one of "top", "bottom", "auto"` · default `"top"`

Where the bar sits. `top` and `bottom` pin it there. `auto` flips it
at runtime — `bottom` whenever an external display is attached (docked
with the lid open, or clamshell), `top` on the built-in display alone —
driven by a `display_change` hook, so the bar moves the moment you dock
or undock, without a rebuild.

The bar's height/pill offsets are tuned for the notch, which only
exists at the top of the built-in display; at `bottom` there's no notch
to tuck under, so `auto` conveniently keeps the notch case (`top`) on
the notched screen and the plain case (`bottom`) on the external.

Example:

```nix
"auto"
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

## haus.pounce

The ⌘Space command palette.

### `haus.pounce.enable`

`boolean` · default `true`

The pounce command palette daemon (⌘Space) + its rice commands.

<small>Declared in [`modules/pounce/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/pounce/options.nix).</small>

### `haus.pounce.followSystemAppearance`

`boolean` · default `true`

Let the palette follow macOS Light/Dark Mode instead of pinning one
polarity: pounce gets the nebelung variant AND its latte counterpart at
your haus.theme.contrast, as its `theme`/`themeLight` pair, and
picks between them per open (no rebuild, no daemon restart).

Honest scope: this makes pounce the one themed tool that does NOT follow
haus.theme.flavor — a flavor pin is a *palette* choice, and asking
to follow the system says the polarity is macOS's call. The contrast
axis still applies to both halves. Everything else on the rice keeps
whatever flavor pins.

false pins pounce to the flavor like every other port, which is exactly
what it did before this option existed.

<small>Declared in [`modules/pounce/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/pounce/options.nix).</small>

### `haus.pounce.items`

`attribute set of (submodule)` · default `{ }`

Per-item palette settings, keyed by the item's own address. One entry is
one row of the palette: hide it, give it a search shorthand, give it a key.

  "cmd:<id>"                       a command, by script name without .sh
  "app:/Applications/Foo.app"      an application, by path
  "mode:<name>"                    a built-in window — launcher, clipboard,
                                   emoji, screenshots, camera, filesearch

Those keys are pounce's own address space (the same strings its frecency
store and `pounce run` use), so a key written here is also what you'd type
to invoke the thing from a script or another tool's binding.

Hotkeys can be a single chord ("opt+e") or a LEADER SEQUENCE — steps
separated by spaces, modifiers by "+", the notation Emacs and VS Code use:

  hotkey = "opt+space e";          # ⌥Space, then E
  hotkey = [ "cmd+k" "cmd+c" ];    # the same thing, step by step

The modifier-only laptop Fn/Globe key is the one special single-step
value: hotkey = "fn". It needs Pounce's Accessibility grant, unlike a
Carbon chord or leader sequence, and fires only when Fn is tapped alone.
The rice uses it for mode:emoji by default; set that item's hotkey to
null to leave the Globe key to macOS.

Sequences are worth knowing about on a tiling rice: they open a namespace
that structurally can't collide with the ⌥/⌘ chords prowl already claims,
and they need no Accessibility grant (pounce grabs the second step as an
ordinary global hotkey for a couple of seconds rather than tapping events).

Two things this checks at build time, because both fail SILENTLY at
runtime: a key that names no real item shape (a "mode:" typo binds
nothing at all), and a chord already claimed by haus.keys.palette,
haus.keys.leader, or a terminal binding (whoever registers first
wins, and it isn't always the same one). What it can't check is whether
`cmd:<id>` names a command that exists — command scripts are discovered
at runtime, so pounce warns about that itself when the daemon starts, and
`pounce doctor` lists any binding that failed to arm.

Example:

```nix
{
  "app:/Applications/Ghostty.app" = {
    hotkey = "opt+t";
  };
  "cmd:brew-services" = {
    listed = false;
  };
  "cmd:emoji" = {
    alias = "emo";
    hotkey = "opt+e";
  };
  "mode:clipboard" = {
    hotkey = "cmd+shift+v";
  };
}
```

<small>Declared in [`modules/pounce/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/pounce/options.nix).</small>

### `haus.pounce.items.<name>.alias`

`null or string` · default `null`

A search shorthand, matched at a bonus over the item's real name —
so "emo" can find the Emoji Picker without renaming it.

Example:

```nix
"emo"
```

<small>Declared in [`modules/pounce/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/pounce/options.nix).</small>

### `haus.pounce.items.<name>.caption`

`null or string` · default `null`

How this item reads on the cheatsheet page that lists your item
hotkeys (⌘Space then ⇥, or the leader's `/`). Only used when the
item has a `hotkey` — a row without a key has nothing to teach.

Defaults to a name derived from the key, which is right often
enough to leave alone: `mode:clipboard` becomes "Clipboard
history", `app:/Applications/Ghostty.app` becomes "Ghostty", and
`cmd:brew-services` becomes "Brew services". Set this when the
derived name isn't what the palette actually calls the row — the
rice can't read a command's own `# pounce: name` header at
evaluation time, so that one is a guess.

Example:

```nix
"Clipboard history"
```

<small>Declared in [`modules/pounce/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/pounce/options.nix).</small>

### `haus.pounce.items.<name>.hotkey`

`null or string or list of string` · default `null`

A global chord, or a leader sequence, that invokes this item
directly without opening the palette first. Modifier names follow
pounce's spelling: cmd/command/super/meta · opt/option/alt ·
ctrl/control · shift.

Whether the KEY name is one pounce can bind is not checked here
(that vocabulary lives in the app); a chord it can't register is
reported by `pounce doctor` rather than silently dropped.

`fn` is the modifier-only exception: it uses Pounce's
Accessibility-gated event tap, fires only on a lone tap, and
suppresses macOS's stock Globe action while armed.

Example:

```nix
"opt+space e"
```

<small>Declared in [`modules/pounce/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/pounce/options.nix).</small>

### `haus.pounce.items.<name>.listed`

`boolean` · default `true`

Whether the item appears in the palette's list.

Named `listed` rather than `enable` because that is precisely what
it does: false removes the ROW, and a `hotkey` on the same item
keeps working. It's how you hide a command you only ever want to
reach by key — or clear the launcher of tools someone else on this
Mac has no use for, which is the closest thing to a "pack" the
surface has today. (It writes pounce's own `enabled` key.)

<small>Declared in [`modules/pounce/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/pounce/options.nix).</small>

### `haus.pounce.scale`

`integer or floating point number between 0.8 and 2.0 (both inclusive)` · default `haus.ui.scale, held inside pounce's 0.8-2.0`

How big the palette is drawn. Multiplies every size in pounce's UI — the
launcher's rows, header, icons and action bar, and the panels behind it:
the emoji grid, clipboard history, recent screenshots, camera peek, Find
Files, the cheatsheet and the window switcher.

Follows haus.ui.scale by default, so you rarely set this directly.
It exists as its own option for the case where the palette wants a
different size from the rest of the rice — the launcher is read at arm's
length for a second, not lived in like the terminal.

pounce's own range is narrower than ui.scale's, so a rice at
`ui.scale = 2.5` gets a palette at 2.0 rather than an evaluation error.

Two things adapt on their own, which is why one number is enough: the
launcher shows fewer rows when the scaled rows stop fitting on screen, and
every panel's width is held inside the visible frame. That matters most
alongside `haus.displays.<name>.uiScale` — a larger-text display mode
and a larger palette multiply, and the palette is the one that would
otherwise run off the edge.

Example:

```nix
1.4
```

<small>Declared in [`modules/pounce/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/pounce/options.nix).</small>

### `haus.pounce.signingIdentity`

`string` · default `""`

A code-signing identity in your login keychain — either its SHA-1 or
(preferred) its full common name. The pounce daemon is re-signed with
it so a macOS Accessibility (TCC) grant survives rebuilds. List yours:
  security find-identity -v -p codesigning

Prefer a "Developer ID Application" identity passed BY NAME (e.g.
"Developer ID Application: Jane Doe (TEAMID)"): its designated
requirement anchors on the stable team OU, so the grant survives even
a certificate renewal (the renewed cert keeps the same name/team but
gets a new SHA — a hardcoded SHA would silently fall back to unsigned).
This is also the identity the Homebrew build is signed with, so both
install paths share one identity. An "Apple Development" cert works too
but expires yearly and pins the specific cert, so it's less durable.

Changing this once invalidates the existing grant (the requirement
changes) — re-approve pounce in Accessibility a single time after.

Leave empty to run pounce unsigned (the palette works, but auto-paste
and other Accessibility-gated features stay off).

Example:

```nix
"Developer ID Application: Jane Doe (ABCDE12345)"
```

<small>Declared in [`modules/pounce/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/pounce/options.nix).</small>

### `haus.pounce.windowMode`

`one of "default", "compact"` · default `"compact"`

The palette's proportions. `compact` is narrower with tighter rows and
keeps its list hidden until you type — the rice's tuned look, and what it
shipped before this option existed. `default` is pounce's roomier layout,
which shows the top results the moment it opens.

This is shape, not size: how BIG the palette is drawn is
haus.pounce.scale. The two compose — a compact palette at scale 1.4
is still the compact layout, just readable from further away.

<small>Declared in [`modules/pounce/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/pounce/options.nix).</small>

### `haus.pounce.windowSwitcher`

`boolean` · default `true`

Replace the stock ⌘Tab app switcher with pounce's MRU *window* switcher:
tap ⌘⇥ to toggle to the last window (across workspaces), hold ⌘ and keep
tapping ⇥ to walk older ones, type while holding to fuzzy-filter
(frecency-ranked). Rows are gathered by AeroSpace workspace under a
header each, and focusing goes through `aerospace focus --window-id` so
a window parked on another workspace surfaces correctly.

Because prowl is tiling here, a bare tap deliberately looks past the
workspace you're on and takes the most recent window on a different
one — with two panes tiled side by side the most recent window is one
you're already looking at, so landing there wouldn't be a switch.
Moving between visible tiles stays windowNav's focus keys; the skipped
siblings are still the rows just below you in the list.

Needs the daemon to hold an Accessibility grant — in practice, set
haus.pounce.signingIdentity so the grant survives rebuilds. Without
the grant the event tap can't install and stock ⌘Tab keeps working, so
this default is safe on a fresh, not-yet-granted install. false leaves
⌘Tab native even when the grant is there.

<small>Declared in [`modules/pounce/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/pounce/options.nix).</small>

## haus.perch

The notch file shelf.

### `haus.perch.enable`

`boolean` · default `true`

The perch notch file shelf, installed via the perch flake (copied to /Applications).

<small>Declared in [`modules/perch/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/perch/options.nix).</small>

### `haus.perch.followSystemAppearance`

`boolean` · default `true`

Let the shelf's palette follow macOS Light/Dark Mode instead of pinning
one polarity: perch gets the nebelung variant AND its latte counterpart
at your haus.theme.contrast, and picks between them itself — no
rebuild, no relaunch.

Same honest scope as the pounce option of the same name: with
this on, perch does NOT follow haus.theme.flavor, because asking to
follow the system says the polarity is macOS's call. The contrast axis
still applies to both halves. Set it false to pin the shelf to
theme.flavor like every other themed tool.

Perch has no theme picker of its own — the shelf is a five-second
surface with nowhere to put one — so this is the only word on its
colors.

<small>Declared in [`modules/perch/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/perch/options.nix).</small>

## haus.hush

One quiet switch: Do Not Disturb, optional Slack status, and your hooks.

### `haus.hush.enable`

`boolean` · default `true`

The hush room: one quiet switch — bar pill, palette command, and a
`hush` CLI — that turns macOS Do Not Disturb on/off (via the
declaratively-bound symbolic hotkey 175, pressed synthetically),
optionally sets your Slack status, and runs your hooks.

Honest scope: hush flips the built-in Do Not Disturb, not named Focus
modes, and it doesn't manage which apps break through — curate that
once in System Settings. The keypress needs an Accessibility grant on
whatever app invokes hush (palette runs inherit pounce's; grant
sketchybar once for the pill). `hush doctor` walks the one-time steps.

<small>Declared in [`modules/hush/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hush/options.nix).</small>

### `haus.hush.hooks`

`list of (absolute path or string)` · default `[ ]`

Extra scripts run on every hush/unhush, each called with a single
argument "on" or "off". Paths are copied into the store; strings are
run as-is (so $HOME paths work). Failures are logged, never fatal —
a broken hook can't wedge the toggle.

Example:

```nix
[ ./onair-light.sh "/Users/ada/bin/pause-music" ]
```

<small>Declared in [`modules/hush/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hush/options.nix).</small>

### `haus.hush.slack.enable`

`boolean` · default `false`

Also set a Slack status and snooze Slack notifications (all devices,
phone included) while hushed. Off by default: it needs a personal
Slack user token (scopes users.profile:write + dnd:write) provided
via tokenCommand. The previous status is saved and restored on
unhush.

<small>Declared in [`modules/hush/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hush/options.nix).</small>

### `haus.hush.slack.snooze`

`boolean` · default `true`

Also pause Slack's own notifications (dnd.setSnooze) while hushed —
this is what silences the phone. Ended on unhush; capped at 24h as
a failsafe if you forget.

<small>Declared in [`modules/hush/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hush/options.nix).</small>

### `haus.hush.slack.statusEmoji`

`string` · default `":no_bell:"`

Slack status emoji while hushed.

<small>Declared in [`modules/hush/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hush/options.nix).</small>

### `haus.hush.slack.statusText`

`string` · default `"heads down"`

Slack status text while hushed.

<small>Declared in [`modules/hush/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hush/options.nix).</small>

### `haus.hush.slack.tokenCommand`

`string` · default `""`

Shell command that prints the Slack user token (xoxp-…) to stdout.
Keychain-first so no secret ever lands in the store or a dotfile:
  security add-generic-password -s hush-slack -a $USER -w 'xoxp-…'

Example:

```nix
"security find-generic-password -s hush-slack -w"
```

<small>Declared in [`modules/hush/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hush/options.nix).</small>

## haus.snippets

Text expansion via espanso.

### `haus.snippets.enable`

`boolean` · default `false`

Text expansion via espanso: type a short trigger (say "@@") and it's
replaced inline with a longer string (your email), in any app —
browsers, Messages, and the terminal. espanso injects keystrokes, so
it works where macOS's own text replacement doesn't (terminals,
many Electron apps).

Off by default: it installs the Espanso.app cask and needs a one-time
macOS Accessibility grant (System Settings → Privacy & Security →
Accessibility → enable Espanso) the first time it runs. The rice runs
the SIGNED app bundle rather than a nix-store binary on purpose, so
that grant is keyed to a stable identity and survives reboots and
nixpkgs bumps — you grant it once, not on every rebuild (and so the
espanso troubleshooting window stops popping up at login, since that
window only ever meant "the grant went missing").

<small>Declared in [`modules/snippets/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/snippets/options.nix).</small>

### `haus.snippets.matches`

`list of (submodule)` · default `[ ]`

The expansion table — one { trigger; replace; } per snippet, written
to ~/.config/espanso/match/default.yml. Only espanso's plain
trigger→replace form is exposed here; for dynamic matches (dates,
shell output, forms) drop a hand-written .yml alongside it in
~/.config/espanso/match/ — espanso loads every file in that dir.

Example:

```nix
[
  { trigger = "@@"; replace = "ada@example.com"; }
  { trigger = "##"; replace = "+1 555 0100"; }
]
```

<small>Declared in [`modules/snippets/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/snippets/options.nix).</small>

### `haus.snippets.matches.*.replace`

`string` · no default

What it expands to.

Example:

```nix
"ada@example.com"
```

<small>Declared in [`modules/snippets/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/snippets/options.nix).</small>

### `haus.snippets.matches.*.trigger`

`string` · no default

What you type.

Example:

```nix
"@@"
```

<small>Declared in [`modules/snippets/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/snippets/options.nix).</small>

## haus.tour

The first-run tutor.

### `haus.tour.enable`

`boolean` · default `true`

The haus tour — a first-run tutor that walks the four moves (launch /
navigate / resize / palette) as ONE quiet pill in the bar, advancing
live as each move is detected. It never opens a window or steals
focus: a fresh machine just shows a dormant "new here?" hint, clicking
it (or `haus tour`, or ⌘Space → tour) starts the lap, right-click
hides it forever. Detection reuses signals the rice already fires (the
leader-mode scripts) — no key logging, no Accessibility.

Needs prowl + sill (it silently stays out of the bar without them);
the ⌘Space step is dropped when pounce is off. Progress lives in
~/.local/state/nebelhaus — `haus tour reset` re-arms a finished tour.

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.tour.steps`

`null or (non-empty (list of (submodule)))` · default `null`

A community-authored tour, in order. null keeps the built-in four-move
nebelhaus tour unchanged; supplying a list replaces it, so a shared rice can
teach its own workflow without shipping scripts or reaching outside the
`haus.*` option surface.

Detection reuses signals the rice already emits. `launch`, `workspace`,
`navigate` and `resize` need prowl; `palette` needs Pounce and its palette
binding. The module warns when a chosen detector's room is disabled.

Authoring a tour is also the ONLY way to have one without prowl: the
built-in lap is three leader moves plus the palette, so `tour.enable` on a
rice with `prowl.enable = false` draws nothing at all. `presets/everyday.nix`
is the worked example — one step, the launcher.

Example:

```nix
[
  {
    detect = "palette";
    hint = "Press {palette}, type tour, then hit ↵";
  }
]
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.tour.steps.*.detect`

`one of "launch", "workspace", "navigate", "resize", "palette"` · no default

The existing rice signal that completes this step: entering launch,
navigate or resize mode; changing workspace; or running the Haus Tour
command from Pounce (`palette`). The tour observes outcomes, never
keystrokes. Clicking the pill still skips a step that cannot be
detected in the current setup.

Example:

```nix
"palette"
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

### `haus.tour.steps.*.hint`

`string` · no default

The instruction shown in the tour pill for this step.

Name keys with the placeholders `{palette}`, `{leader}` and
`{leaderName}` rather than typing a chord: they expand to what
THIS machine resolved, so a tour written once still teaches the
right keys on a rice that moved `keys.palette` or `keys.leader`.
A hardcoded "⌘Space" is wrong on that machine and the author
never sees it — the consumer does.

Example:

```nix
"Press {palette}, type calendar, then hit ↵"
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/sill/options.nix).</small>

## haus.developer

The developer pack: the CLI toolbelt, Git tooling, coding-agent tooling, and language runtimes. Off is a nebelhaus machine for someone who never opens a terminal by choice.

### `haus.developer.agents.enable`

`boolean` · default `config.haus.developer.enable`

Coding-agent *tooling*: `holt` (agent worktrees), `agent-state` (the
pane-status writer behind the `agents` bar pill and the zellij tab
badge), `zscratch`, the agent-worktree statusline, and the client
config hearth writes (Claude Code's settings.json keys, opencode's
agent-state plugin). Which clients get installed is `agents.clients`.

Off is right for any machine not running coding agents — it's a large
surface a non-developer never sees. It also empties `agents.clients`,
since a client with no `holt` to park it is not the deal on offer.

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.developer.enable`

`boolean` · default `true`

The developer pack: the CLI toolbelt, Git tooling, coding-agent
tooling, and language runtimes. On (the default) is the rice as it
has always been.

`false` is what makes a non-developer nebelhaus possible — it strips
those tools rather than merely hiding them. What remains is the
product: `haus`, `awake`, the theme, the terminal, the bar, the tiler
and the palette.

The sub-options below each default to THIS value, so turning it off
turns everything off and you can then re-enable one piece:

  haus.developer.enable = false;
  haus.developer.git.enable = true;  # …but keep git

Example:

```nix
false
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.developer.git.enable`

`boolean` · default `config.haus.developer.enable`

Git and its surroundings: the shell alias vocabulary, the themed git
config, delta (diff pager), lazygit, `gh`, and gnupg for commit
signing. Off drops all of them, and `haus.git.*` then has
nothing to configure.

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.developer.languages`

`list of value "node" (singular enum)` · default `[ "node" ] when developer.enable is true, else [ ]`

Language runtimes to install. Currently only "node" (bun + fnm, with
fnm's `--use-on-cd` shell hook).

Deliberately a list rather than one bool per language, so adding
"rust" or "python" later doesn't change this option's shape.

Example:

```nix
[ ]
```

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

### `haus.developer.toolbelt.enable`

`boolean` · default `config.haus.developer.enable`

The terminal toolbelt: bat, fzf, fd, ripgrep, yazi, zoxide, lsd,
glow, jq, tree, chafa, ttyd and fastfetch — the themed replacements
for cat, find, grep, ls and friends that the rice's shell is built
around.

Off leaves a plain shell. The prompt (starship) and the colour scheme
stay: these are the *tools*, not the appearance.

<small>Declared in [`modules/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/options.nix).</small>

## haus.collar

Touch ID for sudo — including inside a terminal multiplexer — and the passwordless-rebuild rule.

### `haus.collar.enable`

`boolean` · default `true`

The collar room: Touch ID for `sudo`, with `reattach` — the PAM shim
that keeps the prompt working when sudo runs inside a terminal
multiplexer (tmux/zellij/screen), where it otherwise beachballs.

Off means macOS's stock password prompt everywhere, including for the
rebuild below. Nothing else in the rice depends on it.

<small>Declared in [`modules/collar/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/collar/options.nix).</small>

### `haus.collar.passwordlessRebuild`

`boolean` · default `true`

Exempt system activation from authenticating at all: a sudoers rule
granting NOPASSWD to `darwin-rebuild` and `haus-activate` at their
stable /run/current-system paths. This is what makes `haus rebuild`,
`haus rollback` and `bench try switch` a single uninterrupted command
rather than one that stops for a fingerprint you already gave.

Honest scope: this is a real root grant, and both commands take a path
or flake ref you choose — so it means "anything I can build, I can
activate as root, unprompted". That is the whole point (you already
authenticated to build it), but on a shared or managed machine it's the
knob to turn off. With it off, activation prompts via Touch ID (or a
password when `enable` is false) and nothing else changes.

<small>Declared in [`modules/collar/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/collar/options.nix).</small>

## haus.secrets

Where secret values come from on this machine.

### `haus.secrets.provider`

`null or string` · default `"keyring"`

The secretspec provider that supplies secret VALUES on this machine.
The secrets room writes it to ~/.config/secretspec/config.toml as the
default provider, so `secretspec run / check / set` work without
flags. Any provider string secretspec accepts, URIs included:
"keyring" (macOS login keychain — local, no accounts), "onepassword",
"bws" (Bitwarden Secrets Manager), "gcsm" (Google Cloud Secret
Manager), "awssm" (AWS Secrets Manager), "vault", "pass",
"protonpass", "lastpass", "dotenv", "env", or a scoped URI like
"onepassword://account@vault".

WHICH secrets exist is not declared here — that's each project's
committed secretspec.toml. Cloud providers authenticate with their own
credentials, configured outside Nix (e.g. `gcloud auth
application-default login` for gcsm); that login is the one manual
step on a new Mac. null skips writing the config file entirely — run
`secretspec config init` yourself.

Example:

```nix
"gcsm"
```

<small>Declared in [`modules/secrets/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/secrets/options.nix).</small>

## haus.homebrew

How rebuilds treat Homebrew packages you did not declare.

### `haus.homebrew.autoUpdate`

`boolean` · default `false`

Run `brew update` before activating the Homebrew step on every
rebuild. Off by default — reproducible rebuilds shouldn't silently
pull newer formulae. Turn on if you want brew to track upstream.

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.homebrew.cleanup`

`one of "none", "uninstall", "zap"` · default `"none"`

How `darwin-rebuild switch` treats Homebrew casks/brews that are
installed but NOT declared anywhere in your config.

- "none" (default, safe): leave undeclared formulae/casks alone. The
  rice never deletes apps you installed yourself.
- "uninstall": remove undeclared formulae/casks (keeps their data).
- "zap": remove undeclared formulae/casks AND their app data. Fully
  declarative, but a stray cask you forgot to list is deleted — with
  no backup — on the very next rebuild. Only choose this once every
  app you keep is declared (bootstrap can adopt your current casks).

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

### `haus.homebrew.upgrade`

`boolean` · default `false`

Upgrade outdated Homebrew packages on every rebuild. Off by default
for the same reproducibility reason as autoUpdate.

<small>Declared in [`modules/den/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/den/options.nix).</small>

## haus.zen
### `haus.zen.extensions`

`attribute set of (submodule)` · default `{ }`

Browser extensions to deploy into Zen, by a stable id of your choosing.

The mechanism is Firefox's enterprise-policy file — the rice renders
`Zen/distribution/policies.json` with an `ExtensionSettings` block — so
it reaches Zen the way an IT department reaches Firefox, without a
profile to hand-edit. `haus.roster` deliberately cannot do this: a
roster entry installs from a cask, a brew, a nixpkgs package or the App
Store, and a browser add-on is none of those.

The rice knows the id and slug of the extensions it themes
(stylus),
so those need only be named. Everything else needs `id` — see that
option for where to find it.

Naming `stylus` here also turns on the stamped userstyle bundle (see
haus.theme.accent): the Catppuccin-derived styles Stylus imports
carry their own accent and flavor variables, which no palette file can
reach, so the rice stamps the bundle from your theme — accent, flavor,
and the contrast it's rendered for — and tells you when there's a new
one to import.

Example:

```nix
{
  # Known to the rice — id and slug are filled in.
  stylus = { };
  # Anything else: bring the id.
  ublock-origin = {
    id = "uBlock0@raymondhill.net";
    slug = "ublock-origin";
  };
}
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

### `haus.zen.extensions.<name>.enable`

`boolean` · default `true`

Whether to deploy this extension. Set false to remove one an imported rice added.

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

### `haus.zen.extensions.<name>.id`

`null or string` · default `null`

The extension's own id — the key Firefox's policy engine
matches on, NOT its AMO slug. Usually a brace-wrapped UUID,
sometimes an email-shaped string (`addon@example.org`).

Find it by installing the add-on once and reading `Extension
ID` under about:debugging ▸ This Firefox, or from the
`browser_specific_settings` block of its source. Wrong id and
the policy silently installs nothing — which is why this has
no guessable default.

Example:

```nix
"{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}"
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

### `haus.zen.extensions.<name>.mode`

`one of "force_installed", "normal_installed", "allowed", "blocked"` · default `"force_installed"`

Firefox's `installation_mode`. `force_installed` installs it
and stops the user removing it (the point, for a rice that
wants an extension present); `normal_installed` installs it
but leaves it removable.

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

### `haus.zen.extensions.<name>.slug`

`null or string` · default `null`

The add-on's AMO slug — the last path segment of its
addons.mozilla.org URL. Only used to build the default
`url`; set `url` directly and this is ignored.

Example:

```nix
"styl-us"
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

### `haus.zen.extensions.<name>.url`

`string` · default `""`

Where the .xpi comes from. Defaults to AMO's "latest" endpoint
for `slug`, so the add-on updates itself; point it at a pinned
version or a self-hosted file to freeze it.

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

### `haus.zen.extraPolicies`

`attribute set` · default `{ }`

Anything else to put in Zen's policy file, merged beside the
`ExtensionSettings` block `haus.zen.extensions` renders. The rice
OWNS that file, so this is the escape hatch for the rest of the policy
surface rather than a reason to take the file back by hand. Keys here
win over the rice's on a collision.

Example:

```nix
{ DisableTelemetry = true; }
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/hausfold/hausfold/blob/main/modules/hearth/options.nix).</small>

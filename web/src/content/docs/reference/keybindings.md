---
title: Keybindings cheatsheet
description: Every default shortcut across tiling, the launcher, the terminal, and Pounce — in one place.
---

Every default binding in nebelhaus, grouped by where it lives. The same list is
available live in-system: tap **⇪** then **/** to open Pounce's cheatsheet —
generated from your own machine's tables (your app roster, prowl's window
chords, hearth's terminal keys), so it describes the keys you actually have
rather than the ones the docs assume.

Notation: `⌥` Option/Alt · `⌘` Command · `⌃` Control · `⇧` Shift · `⇪` Caps-Lock.

These are the **defaults**. The three keys everything else hangs off are options
— `haus.keys.leader` (what `⇪` is), `haus.keys.windowNav` (what `⌥` is)
and `haus.keys.palette` (what opens Pounce) — so on a rice that has changed
them, read `⇪` and `⌥` below as "the leader" and "the nav modifier". Any of the
three can be `"none"`, which removes its bindings rather than moving them. See
[rebinding](/guides/window-management/#not-fond-of-these-keys); your own live
cheatsheet always reflects the keys you actually have.

## Tiling — main mode (prowl)

| Keys | Action |
|---|---|
| `⌥H` `⌥J` `⌥K` `⌥L` | Focus left / down / up / right (Vim-style twin of ⇪ + arrows) |
| `⌥/` | Tiles layout (toggles horizontal ↔ vertical split) |
| `⌥,` | Accordion layout (toggles horizontal ↔ vertical) |
| `⌥F` | Toggle fullscreen |
| `⌥⇧Tab` | Move workspace to next monitor |
| `⌥⇧;` | Enter service mode |
| `⌘Space` | Open Pounce |
| `fn` *(tap alone)* | Open Pounce's emoji picker |
| `⌘Tab` | MRU **window** switcher, crosses workspaces ([pounce](/guides/pounce/#a-window-switcher-not-an-app-switcher-opt-in)) |

`⌥Tab` is deliberately unbound — workspace back-and-forth retired in favour of
`⌘Tab`, which is most-recently-used rather than a single previous-workspace
pointer, and whose rows are gathered by workspace under a header each.

## Launch mode — tap ⇪ (prowl)

| Keys | Action |
|---|---|
| `<app-key>` | Launch / focus that app (`T` terminal, `B` browser by default) |
| `1`–`4` | Focus workspace 1–4 |
| `⇧1`–`⇧4` | Throw the focused window to workspace 1–4 and follow it there |
| `⇧<app-key>` | Throw the focused window to that app's workspace and follow it there |
| `←↓↑→` | Focus tiled window; drops into **navigate mode** (arrows repeat, `⇧`+arrow *moves* the window, `Esc`/`Return` exits) |
| `-` / `=` | Enter resize mode (shrink / grow) |
| `V` | Clipboard history (Pounce) |
| `E` | Emoji picker (Pounce) |
| `Z` | Reopen the last closed app (the ⌘⇧T analog) |
| `,` | Open macOS System Settings (mirrors the ⌘, convention) |
| `Backtick` | Re-sort every window to its workspace (wake recovery) |
| `/` | Show the cheatsheet |
| `Esc` | Exit launch mode |

## Service mode — ⌥⇧; (prowl)

| Keys | Action |
|---|---|
| `R` | Flatten the workspace tree |
| `F` | Toggle floating ↔ tiling |
| `Backspace` | Close all windows except current |
| `⌥⇧H/J/K/L` | Join with the neighbour |
| `↑` / `↓` | Volume up / down |
| `⇧↓` | Mute |
| `Esc` | Reload config and exit |

## Terminal — zellij (hearth)

| Keys | Action |
|---|---|
| `Super P` | New pane (inherits cwd; hops to the main checkout inside a worktree) |
| `Super ⇧P` | New pane, stay here (inherits cwd, no worktree hop) |
| `Super W` | Close the focused pane — and the tab with it when it's the tab's last pane |
| `Super T` | New tab at `$HOME` (born named `~`) |
| `Super ⇧T` | New tab at the focused pane's directory (same worktree hop as `Super P`) |
| `Super F` | **Find** — full-text search over the focused pane, live as you type |
| `Super ⇧F` | The same overlay, opened across **every pane** in the session |
| `Super G` | **gh-dash** — GitHub review queue in a clean fullscreen overlay (when [`hearth.ghDash.enable`](/reference/options/#haushearthghdashenable) is on; its PR tabs follow [`haus.git.org`](/reference/options/#hausgitorg)) |
| `Super ⏎` | Toggle the focused pane fullscreen (zoom to fill the tab, again to restore) — or **Ctrl-click** the pane body, see below |
| `Super Y` | yazi peek — covers the terminal window it was summoned from (floating previews; `Enter` on a dir opens a new tab there; same worktree hop as `Super P`) |
| `Super ⇧Y` | yazi peek, stay here (no worktree hop) |
| `Super L` | Open Links picker (every URL from focused pane's transcript/scrollback) |
| `Ctrl Tab` / `Ctrl ⇧Tab` | Tab history back / forward (most-recently-used, browser-style) |
| `Alt [` / `Alt ]` | Cycle swap layouts (grid → spiral → columns) — works locked too |
| `Super A` | Spawn an isolated agent (own worktree) in a new pane — your [`agents.default`](/reference/options/) client: Claude Code via its own `--worktree`, Codex or Opencode via `holt new` |
| `Super ⇧A` | The same agent, **in place of** the focused pane instead of beside it — the replaced pane is suspended, not killed, and comes back when the agent quits |
| `Ctrl ⌥⇧A` | Spawn a resident agent (this checkout) |

**Find searches conversations, not just scrollback.** In a shell pane the
overlay searches the full scrollback. In a **Claude Code** or **Opencode** pane
it searches that session's stored conversation instead — which is both necessary
and better: both render in the alt-screen, and the alt-screen has no scrollback
at all, so searching the terminal grid would only ever find what's currently on
display. The stored conversation has all of it, including text inside collapsed
tool output. **Codex** panes fall back to scrollback — they report pane state
like the others but carry no conversation id to search by. Inside the overlay:
`⏎` jumps to the pane the hit came from, `^y` copies the matched line, `^s`
switches between this-pane and every-pane without losing your query, `Esc`
closes.

zellij's own in-place search is still there and unchanged — `Ctrl g` to unlock,
then `s` or `/` — for when you want matches highlighted in the real pane and
`n`/`p` to walk them. It exits back to Locked rather than Normal.

**Locked by default.** zellij boots in **Locked** input mode, so its single-key
submode leaders (pane, tab, resize) stay inert until you press `Ctrl g` — a stray
keystroke can't drop you into a submode. The `Super`-prefixed launchers above work
regardless of the lock, and so do `Alt [` / `Alt ]` — picking a layout is a
workspace act, not a submode. The rest of zellij's `Alt` row stays inert while
locked on purpose: `Alt h/j/k/l` and `Alt`-arrows are word motions the shell and
your editor want. Flip it with [`haus.hearth.zellijStartLocked`](/reference/options/#haushearthzellijstartlocked).

**Ctrl-click a pane body** zooms it fullscreen — the same toggle as `Super ⏎`,
for when your hand's already on the trackpad. Click again (or `Super ⏎`) to drop
back into the tiled layout. Only clicks *inside* the pane zoom; a drag on the
frame still resizes, and the program running in the pane never sees the click.

**Clickable links** work across two modifiers. `⌥`-click a file path (or a
visible URL / bare domain) in the terminal to open it — a path opens a new tab
`cd`'d there, a link opens in the browser. `⌘`-click opens any web link,
including **embedded hyperlinks** whose visible text isn't the URL (e.g. Claude
Code's `/tui` session and PR links) — those only respond to `⌘`-click, since the
URL is hidden in the terminal escape sequence rather than shown on screen.

## Pounce — ⌘Space

| Keys | Action |
|---|---|
| type | Fuzzy-search |
| `↑` / `↓` | Move selection |
| `Return` | Default action |
| `⇧Return` | Insert a newline (the query field is multi-line) |
| `⌘Return` | Modifier action (e.g. Reveal in Finder) |
| `⌥Return` / `⌃Return` | Alternate actions (when shown) |
| `⌥Return` *(Find Files)* | Copy the path |
| `Tab` | Cycle sections / emoji categories |
| `Esc` | Dismiss |

## Ghostty note

Ghostty deliberately **unbinds** `⌘T`, `⌘P`, `⌘⇧P`, `⌘Y`, `⌘⇧Y`, `⌘⇧T`, `⌘F`,
`⌘⇧F`, `⌘⏎`, `⌘R`, `⌘W`, `⌘A` and `⌘⇧A` so zellij owns them — the same keys work
whether or not you're multiplexed. (`⌘⇧A`, `⌘⇧F` and `⌘⏎` are unbound
pre-emptively: Ghostty claims nothing there today, and the unbind keeps it that
way if a future release does. `⌘R` is now unbound on both sides — it used to
reach zellij as a session-reload chord, which a rebuild no longer needs.)

When `haus.hearth.ghDash.enable` is on, Ghostty also hands `⌘G` to
zellij for the dashboard overlay. That intentionally replaces Ghostty's stock
search-next binding; `⌘F` still opens Hearth's full-text search.

`⌘W` is the one where handing the key over is also a **fix**. Ghostty's default
there is `close_surface`, and since the rice sets `confirm-close-surface = false`,
a stray `⌘W` from any pane silently took the whole window — and the zellij client
in it — with no prompt. Now it closes just the focused pane. `⌘⇧W` is left alone
as Ghostty's `close_window`, so closing the real window keeps a key of its own.

`⌘C` is the one that stayed with **Ghostty**: it copies. The agent binds lived on
`⌘C`/`⌘⇧C` back when Claude Code was the only client they could start; moving
them to `⌘A` (*a* for agent, and it starts whichever client `agents.default`
names) handed `⌘C` back to meaning what it means everywhere else. Day to day you
still won't press it — zellij copies a mouse selection to the clipboard the
moment you release it — but a `⇧`-drag makes a Ghostty-level selection, and `⌘C`
copies that.

`Ctrl-Tab` is forwarded to zellij via the kitty keyboard protocol.

`⌘D` and `⌘⇧D` are unbound too, but nothing takes them over: they do **nothing**.
Ghostty's defaults there are its own `new_split:right` / `new_split:down`, which
nest a second terminal surface *inside* the one zellij is driving — invisible to
the multiplexer, so its layout, status bar and pane keys would apply to only half
the window. Since `⌘D` is muscle memory from other terminals, it's an easy
accident; use `Super P` for a pane instead.

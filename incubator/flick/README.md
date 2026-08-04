<div align="center">

<!-- identity banner to come: assets/flick-banner-rounded.png -->

# flick

**no noise, just an ear-flick**

your notifications, without the noise — a native, local, scriptable visual layer for macOS.

![part of nebelhaus](https://img.shields.io/badge/part_of-nebelhaus-f2c4e5?labelColor=202020)
![themed by nebelung](https://img.shields.io/badge/themed_by-nebelung-c9a8f1?labelColor=202020)
![license](https://img.shields.io/badge/license-MIT-d7d7d7?labelColor=202020)

</div>

---

A cat doesn't get up for every sound. An ear swivels, the event is registered,
the nap continues. That's flick: a quiet notification compositor that draws
small, flat, silent banners — and gives every script, tool, and nebelhaus app
one visual language for "something happened."

It is **not** a drop-in replacement for Notification Center, because Apple
doesn't sell that entitlement. It's the honest version: a compositor flick
fully owns, fed by providers — your own tools cleanly today, mirrored system
notifications experimentally tomorrow.

## why flick

- **scriptable end to end** — `flick send --title "deploy landed"` from any
  shell, CI job, or nix rebuild. One JSON line in, one banner out. No SDK.
- **quiet by design** — no sound APIs anywhere in the binary. Flat surface,
  a few points of motion (none under Reduce Motion), hover to hold.
- **rules, not settings mazes** — `~/.config/flick/rules.json`: route a
  source to banner / inbox / digest / drop; quiet hours; critical punches
  through. Hot-reloaded on save.
- **resilient compositor** — panels are disposable; the queue is the truth.
  Unplug a display mid-burst and nothing is lost. A provider dying can't
  take rendering down; it re-probes and backs off on its own.
- **native and tiny** — one Swift `LSUIElement` binary that is both daemon
  and CLI. No Electron, no telemetry, no cloud, no login.

## the shape

```text
flick CLI    trill/pounce    usernoted db (experimental)
    │             │                │ read-only, schema-probed
 SocketProvider   │          SystemMirrorProvider
    └─────────────┴────────────────┘
                  ▼
          EventRepository (actor: normalize · dedupe · persist · supervise)
                  ▼
          PolicyEngine (rules.json: banner / inbox / digest / drop · quiet hours)
                  ▼
          BannerQueue (coalescing · hover-pause · capacity)
                  ▼
          BannerWindowSystem (NSPanel per banner · all Spaces · over fullscreen)
```

## quick taste

```sh
flick send --title "Landing page shipped" \
           --body "Preview promoted to production" \
           --source deploy --symbol checkmark.circle --thread deploys

echo '{"title":"Backup complete","body":"3.8 GB copied","source":"backups","urgency":"low"}' \
  | flick send --json

flick ping   # is the daemon up?

flick doctor            # which listed apps does macOS still notify for itself?
flick doctor --all      # …check every app on the Mac, not just the listed ones
flick doctor --notify   # …and put the findings on screen, click to be walked through
```

```jsonc
// ~/.config/flick/rules.json
{
  "rules": [
    { "match": { "source": "slack", "titleContains": "mentioned" }, "delivery": "banner" },
    { "match": { "source": "slack" }, "delivery": "digest", "digest": "work" },
    { "match": { "source": "ads" }, "delivery": "drop" }
  ],
  "quietHours": { "startMinute": 1320, "endMinute": 420 }
}
```

## what about other apps' notifications?

Three lanes, in order of honesty:

1. **First-party** (shipping): anything local speaks the socket. Nebelhaus
   apps, scripts, CI — clean, supported, forever.
2. **System Mirror** (experimental, off by default): reads the `usernoted`
   store read-only under Full Disk Access and redraws other apps' banners.
   Undocumented surface — a schema probe disables it safely when macOS
   moves. flick stays fully useful without it.
3. **Suppressing Apple's own banners** is Focus + per-app settings — flick
   deep-links you there but never pretends to own that dial.

### `flick doctor` — the duplicate-banner check

Mirroring an app macOS is *also* drawing means seeing everything twice, so
flick can at least tell you which apps those are. `flick doctor` reads Apple's
own per-app notification preferences (read-only, and undocumented — see
`NotificationSettingsAudit`) and reports every listed app that still has
**Desktop** ticked or **Play sound** on. Exit code 4 means it found some, so a
rebuild hook can gate on it.

Those preferences live in an Apple group container, which is TCC-protected —
so **`doctor` needs Full Disk Access**, the same grant System Mirror wants.
Without it there is no answer to give, and flick gives that one: `can't
tell`, exit code **5**. A check that quietly exited 0 while blind would make
every un-granted Mac look clean.

"Listed" means the bundle-id-shaped `source` values in your `rules.json`;
`--all` widens it to every app on the Mac, and naming bundle ids explicitly
narrows it.

`--notify` puts the findings on screen as banners with one action —
**Silence Native Banners**. Clicking one opens System Settings and floats a
helper panel beside it: the app's row as macOS draws it (Apple dropped per-app
anchors from that deep link, so it always lands at the top of the pane and
finding the row is the real work), one sentence naming what's left to change,
and a replica that animates the clicks — untick **Desktop**, turn **Play
sound for notification** off.

**Done** moves to the next app. flick asks rather than watches because it
can't rely on watching: the store needs Full Disk Access, and on a Mac that
hasn't granted it there is nothing to observe. Where flick *can* read, the
panel ticks apps off by itself as macOS agrees — the row's subtitle shortens,
the sentence narrows to what's left, and the replica drops the step you've
already done.

The helper only ever walks the apps the audit that opened it named — the
banner carries them with it, so a summary banner standing for four listed
apps still walks those four and not the sixty-odd others macOS holds
preferences for. flick asks you to silence what you told it to redraw; it
does not ask you to switch macOS's notifications off wholesale. Widening
that is `--all`, and it takes typing `--all`.

Note that the pane changed shape in macOS 26 (Tahoe): the old
None/Banners/Alerts radio is now a **Desktop** checkbox plus a
Temporary/Persistent choice that only applies while Desktop is ticked.
Notification Center and Lock Screen stay ticked — flick redraws the banner,
it doesn't replace the notification. Same panel shape as the Full Disk
Access assistant, and the same promise: **flick opens the pane, it never
writes the setting.** There's no API to change another app's notification
preferences, and silently rewriting a pane the user believes only they control
isn't a trade this app makes.

See [ARCHITECTURE.md](./ARCHITECTURE.md) for the invariants and
[PRD.md](./PRD.md) for the milestones.

## status

Pre-release scaffold. The first-party pipeline (socket → rules → banners →
inbox) is the v1 target; System Mirror ships only after its feasibility
spike answers the questions in the PRD.

MIT. Part of the [nebelhaus](https://github.com/nebelhaus) family.

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

See [ARCHITECTURE.md](./ARCHITECTURE.md) for the invariants and
[PRD.md](./PRD.md) for the milestones.

## status

Pre-release scaffold. The first-party pipeline (socket → rules → banners →
inbox) is the v1 target; System Mirror ships only after its feasibility
spike answers the questions in the PRD.

MIT. Part of the [nebelhaus](https://github.com/nebelhaus) family.

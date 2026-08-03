# Flick architecture

## Invariants

1. The compositor never blocks on a provider; ingestion is async streams end
   to end.
2. A provider failure degrades to "off with a visible reason", never to a
   broken pipeline. Supervision re-probes with capped backoff.
3. Provider-native types stop at the provider boundary; everything past it
   is `NotificationEvent`.
4. Apple-owned stores — the `usernoted` db and the `com.apple.ncprefs`
   preference domain — are read-only or not at all: the former only when its
   schema probe passes, the latter decoding defensively and degrading to
   "nothing to report" rather than to a wrong answer. flick never writes
   either, so it can never quietly change a setting the user believes only
   they control.
5. Banner state lives in `BannerQueue`; panels are disposable and rebuilt on
   every display-topology change without event loss.
6. Banners never take key focus and never make sound.
7. Notification content never appears in logs; persistence is a user choice
   (off = nothing touches disk).
8. Surfaces render only actions the source can honor (capability
   advertisement, no dead buttons).
9. Policy decisions are pure functions of (event, rules, clock).

## Boundaries

```text
flick CLI ──socket──► SocketProvider ─┐
trill / pounce / scripts (same lane)  │        probe() → ProviderHealth
                                      ├──► EventRepository (actor)
usernoted db2 ──read-only──► SystemMirrorProvider   normalize · dedupe
              (quarantined, schema-probed)          persist · supervise
                                      │
                        PolicyEngine (pure) ── rules.json, hot-reloaded
                                      │
              ┌───────────────────────┼─────────────────────┐
              ▼                       ▼                     ▼
        BannerQueue             inbox (sqlite)        digests (M2)
   coalesce · pause · capacity        │
              ▼                       ▼
      BannerWindowSystem          InboxView
   NSPanel per banner · all Spaces · fullscreen aux
              ▼
        ActionRouter ── open app · open URL · (hooks, M2)
```

## The hard cases

### A provider dies, hangs, or floods

Each provider runs in its own supervised task: `probe()` gates entry, a
finished stream triggers re-probe with exponential backoff (1s → 60s cap),
and health is queryable for settings. Ingest is one actor hop; a flooding
provider hits the dedupe window and field caps in `normalized()`, and the
socket server cuts any peer that streams a megabyte without a newline.

### Display topology changes mid-burst

`BannerWindowSystem` rebuilds panels on
`didChangeScreenParametersNotification` (perch's pattern). Because visible
and waiting entries live in `BannerQueue`, a rebuild is pure
re-presentation. Capacity shrink pushes overflow back into the waiting line
— covered by unit test, no display required, thanks to the pure
`ScreenDescriptor`/`BannerGeometry` split.

### Bursts

Thread-mates arriving inside the coalesce window fold into the existing
banner (newest content on the face, "+N more" as the receipt) instead of
stacking. Beyond visible capacity, entries queue; hover pauses rotation so
banners never swap under the cursor.

### The undocumented mirror

`SystemMirrorProvider` treats the usernoted store the way trill treats
advanced automation: independently probed, explicitly enabled, never assumed.
The probe checks existence, readability, and expected tables before any
session; drift produces `unavailable(reason:)` — a settings string, not a
crash. Ingest (WAL-watching vs polling, Focus interaction, per-app field
survival) is deliberately unimplemented until the PRD's spike answers those
questions on real macOS versions.

### Suppressing Apple's banners

There is no public "become the notification renderer" entitlement, so flick
does not claim the capability. The supported route is the Hush-backed mode:
a Focus profile (owned by the rice) silences Apple's rendering while
providers still see events; flick deep-links to Notification and Focus
settings via `SystemIntegration` — the one file allowed to touch Apple's
notification machinery.

What flick *can* do is tell you when Apple is still drawing something it's
also drawing. `NotificationSettingsAudit` reads `com.apple.ncprefs` — the
private domain behind that pane — and decodes four bits per app: alert style
(banners `1<<3`, alerts `1<<4`, neither = None), play-sound (`1<<2`), and
**allow-notifications (`1<<25`)**.

That last one is the one that matters most, and it was learned the expensive
way. macOS leaves the style and sound bits frozen at their last values when
the master switch goes off, so an audit that reads only style and sound
reports every app the user has *already* silenced — the first cut of this
shipped exactly that bug and told the user to go turn off Calendar, ghostty
and Chrome, all long since off. It's now pinned in `NotificationSettingsAudit
Tests` against 19 apps whose real state was read straight off the System
Settings pane, with the single known miss (an app never prompted for
authorization, `auth == 0`) asserted as a miss rather than hidden.

Bits with plausible-but-uncorroborated community meanings are deliberately
**not** read. Bit 29 is the cautionary tale: it looked like a fine candidate
for the allow bit until its set turned out to match the community's
"time-sensitive apps" list almost exactly — corroboration is what ruled it
out, and nothing else would have.

That audit is what `flick doctor` reports and what the stepped helper panel
(`OnboardingAssistantView.Mode.nativeBanners`) polls once a second while the
user works in System Settings. The panel is the Full Disk Access assistant's
shape reused wholesale — non-activating, all-Spaces, deterministic height —
because the constraint is identical: be readable *beside* System Settings
without taking its focus.

## Planned extensions that fit existing seams

- Digest flushing: a scheduler draining `digest(name)` rows from the store
  into summary events — new consumer, no pipeline change.
- Pounce inbox: `flick history --json` over the socket, rendered by a
  pounce command.
- Per-display routing: `BannerWindowSystem` already keys panels by entry;
  a queue per screen descriptor is additive.
- Provider actions (trill reply, calendar open): richer capability sets on
  existing providers.
- Nebelung theming: accent + surface tokens consumed by `BannerView`.
- Command hooks: `ActionRouter.command` gains an allowlisted runner with
  redacted environment.

# MDM-delivered permissions — can a desktop auto-grant TCC?

**Short answer: no, not for a desktop someone downloads. Yes, for an org that
already runs an MDM — and that half is worth building.**

- **Date:** 2026-08-18
- **Status:** design note. **Reasoned from Apple's documented MDM/PPPC
  behaviour, NOT probed on this machine** — unlike
  [`macos-settings-matrix.md`](macos-settings-matrix.md), nothing here has been
  run. §6 lists what a spike would have to settle before any of it is acted on.
- **Prompted by:** wanting `haus.*` to declare an app's Accessibility / Full
  Disk Access grant the way it declares everything else, so a fresh install
  doesn't open with fifteen permission dialogs.

---

## 1. What the gate actually is

macOS records a *source* for every configuration profile payload: user-installed,
MDM-delivered, or MDM-delivered-from-a-user-approved-enrollment (UAMDM). A set of
security-sensitive payloads are **silently dropped** unless the source is the
third one. The enrollment earns that status either through Automated Device
Enrollment or through the user manually clicking **Allow** in System Settings →
Device Management. ADE, supervision and Apple Business Manager are *not*
required for the PPPC tier — one human click is enough.

Two consequences that kill the obvious shortcuts:

- A `.mobileconfig` that Nix writes into the store is user-installed. The gated
  payloads inside it are ignored, with no error.
- `profiles install` from the CLI has been blocked since Big Sur, so even
  *unattended* installation of the ungated payloads isn't available. It's a
  double-click plus an approval, or nothing.

There is no local escape hatch short of disabling SIP.

## 2. What's behind the gate

| Payload | Buys |
|---|---|
| `com.apple.TCC.configuration-profile-policy` (PPPC) | Accessibility, Full Disk Access, AppleEvents, PostEvent — granted **by bundle id + designated code requirement, not by path** |
| `com.apple.servicemanagement` | launchd agents allow-listed; no "Background Items Added" notification, and the user can't toggle them off |
| `com.apple.notificationsettings` | preset an app's alert style and banner behaviour — MDM-only, no `defaults` equivalent |
| `com.apple.system-extension-policy` | pre-approve a network/endpoint system extension |
| `com.apple.syspolicy.kernel-extension-policy` | kext allow-list (legacy) |

**The path-independence in row 1 is the real prize.** A PPPC grant keyed to a
code requirement survives a `/nix/store` path change and a Homebrew version
bump — both of which strand a hand-clicked TCC grant today, and both of which we
have hit.

### The carve-out that spoils it

**Screen Recording, Camera and Microphone are deny-only in PPPC.** No MDM, at
any approval level, can *grant* `kTCCServiceScreenCapture` — Apple only allows
setting it to false. So the bar's screenshot path still needs a human click no
matter how far this goes. Any plan that assumes "MDM fixes permissions" is
wrong by exactly this much.

## 3. Where haus is today

**No profile plumbing anywhere in `modules/`** — nothing writes, signs or
installs a `.mobileconfig`. What does exist is the hand-grant side, all in
`haus/modules/core/haus.sh`: `has_fda()` reads a byte of `TCC.db` to find out
whether the rebuild itself holds Full Disk Access, `plan_permissions()` reports
what a plan is about to need, and `haus doctor`'s Permissions section already
deep-links the exact panes (`?Privacy_Accessibility`, `?Privacy_AllFiles`).

So the consumer half of §5 is mostly built. The profile half is greenfield.

## 4. The two paths, and why only one is real

### Path A — one personal machine (works)

Enroll the Mac in an MDM you control, click Allow once, then push haus-generated
payloads. Self-hosted NanoMDM behind a tunnel, or a hosted free tier. This is a
known hobbyist pattern and there is no reason it wouldn't work.

Cost: an APNs MDM push certificate (see below), renewed yearly. Risk: a UAMDM
channel on your own Mac can install profiles and issue a remote wipe — with a
hosted vendor, that channel belongs to them.

Not proposed for the family. Noted so the option is on the record.

### Path B — ship the MDM inside the desktop (does not work)

The idea: the installer stands up a local MDM on `127.0.0.1`, enrolls the
machine into it, and delivers its own PPPC profiles. Most of it holds:

- **Trust** — ship a CA and `security add-trusted-cert -d -r trustRoot -k
  /Library/Keychains/System.keychain`. The installer already has sudo.
- **Approval** — the user double-clicks the enrollment profile and clicks Allow
  once. One scary click replacing fifteen dialogs is a trade a user would take.
- **Delivery** — the local server sends `InstallProfile`; macOS flags the
  payload MDM-delivered; PPPC applies.

**It dies on push.** Classic MDM has no polling — a device fetches commands only
when woken by an Apple Push Notification, and sending one requires an APNs MDM
push certificate whose topic matches the enrollment profile. A server on the
same machine still has to round-trip through `api.push.apple.com`. There is no
localhost or offline substitute, and DDM doesn't change it.

That certificate requires Apple **MDM vendor** status (Developer Enterprise
Program plus Apple's approval to sign MDM CSRs), and then leaves two options:

| | |
|---|---|
| One shared push cert in the installer | Private key in a public distribution. Works until it's extracted. |
| Each user generates their own | Apple ID sign-in at `identity.apple.com/pushcert`, upload a vendor-signed CSR, feed the result to their local server, **renew annually**. Sound on paper; no consumer completes it. |

Two further nails: a non-supervised enrollment is user-removable, so a curious
user silently drops every grant and every app breaks with no signal; and the
whole construction is precisely what UAMDM was introduced in High Sierra to
prevent — automated enrollment that self-grants TCC. Expect vendor-cert
revocation and notarization trouble, not a warning.

(`mdmcert.download` signs CSRs free for personal use and is explicitly not a
product foundation.)

## 5. What to build instead

**Split the audience.**

**Orgs — worth doing.** A business shipping a desktop to its own staff already runs
Jamf / Mosyle / Kandji. It doesn't need our MDM, it needs our *payload*. So haus
emits one:

```nix
# app names, not room names — PPPC keys on bundle id + designated code
# requirement, and one room can install several apps
haus.permissions.grant = [ "pounce" "perch" "trill" ];
```

→ a `.mobileconfig` carrying PPPC + `com.apple.servicemanagement`, keyed by each
app's bundle id and code requirement, that an admin uploads to whatever they
already run. No Apple relationship, no push cert, no server. It also makes the
grants declarative in the same file as everything else, which is the actual
haus argument. A genuine differentiator for a Nix desktop, and the piece fully
inside our control.

**Consumers — no sanctioned bypass exists,** and the ceiling is already most of
the way built. `haus doctor` names each missing permission and deep-links its
pane; what's missing is only the first-run loop that polls until granted instead
of printing a line and exiting. Unglamorous, and it has to survive Tahoe's
re-prompt behaviour — but it's an extension of `plan_permissions` / `doctor`,
not a new subsystem.

## 6. Unproven — what a spike would have to settle

Nothing below has been run. In rough order of how much each would change the
conclusion:

1. Does a device enroll at all against a topic whose push certificate you don't
   hold, and does `profiles status -type enrollment` then report *User
   Approved*? If enrollment itself fails, Path B is dead earlier than §4 says.
2. Is the deny-only list for `kTCCServiceScreenCapture` / Camera / Microphone
   still current on macOS 26? This is the single fact that most limits the
   payoff of the org path too.
3. Does a PPPC grant keyed to a code requirement actually survive a `/nix/store`
   path change in practice — i.e. is the prize in §2 real?
4. Do our apps' designated requirements stay stable across a `bench release`?
   A DR that changes per build makes the emitted profile stale on every update.
5. Where a `haus.permissions` namespace sits in the room / shared / host
   split ([`rooms-desktops.md`](rooms-desktops.md)). It looks host-leaning — a
   designated code requirement is machine- and signing-identity shaped — but
   every top-level namespace needs that classification decided before it ships.

Settle 2 and 3 before building the §5 emitter — they decide whether it's worth
the option surface.

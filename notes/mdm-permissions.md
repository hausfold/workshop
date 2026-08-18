# MDM-delivered permissions — can a desktop auto-grant TCC?

**Short answer: no, not for a desktop someone downloads. Yes, for an org that
already runs an MDM — and that half is worth building.**

- **Date:** 2026-08-18
- **Status:** design note. §§2–5 are **reasoned from Apple's documented MDM/PPPC
  behaviour, not probed** — the MDM half can't be tested without an enrollment.
  **§1's delivery bullets, §6 and §7 are probed**, to the standard of
  [`macos-settings-matrix.md`](macos-settings-matrix.md): run on this machine
  2026-08-18, with each claim marked probed or reasoned. Read §6 before acting
  on §5 — it is what says the org path is buildable — and §7 for the line
  between a grant and a setting, which is where the only unclicked route lives.
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
- **Probed 2026-08-18: the UNGATED payloads really do apply from a
  user-installed profile.** A managed-preferences payload set
  `com.apple.universalaccess`'s `reduceTransparency` with no Full Disk Access
  anywhere, confirmed against NSWorkspace. What it costs is that approval — and
  the approval is **per profile VERSION**: an in-place update carrying the same
  `PayloadIdentifier` and `PayloadUUID` with the version bumped prompted for the
  entire flow a second time. So "a double-click plus an approval" is a recurring
  cost rather than a one-time one, which is what rules profiles out for anything
  a rebuild regenerates. §7 has the routes this leaves.

There is no local escape hatch short of disabling SIP.

## 2. What's behind the gate

| Payload | Buys |
|---|---|
| `com.apple.TCC.configuration-profile-policy` (PPPC) | Accessibility, Full Disk Access, AppleEvents, PostEvent — granted **by bundle id + designated code requirement, not by path** |
| `com.apple.servicemanagement` | launchd agents allow-listed; no "Background Items Added" notification, and the user can't toggle them off |
| `com.apple.notificationsettings` | preset an app's alert style and banner behaviour — MDM-only, no `defaults` equivalent |
| `com.apple.system-extension-policy` | pre-approve a network/endpoint system extension |
| `com.apple.syspolicy.kernel-extension-policy` | kext allow-list (legacy) |

**The path-independence in row 1 is the real prize** — a PPPC grant keyed to a
code requirement should survive a `/nix/store` path change and a Homebrew
version bump, both of which strand a hand-clicked grant today. **§6 probed this: it holds for
pounce, perch and trill**, all of which run Developer-ID-signed bundles. It does
not hold for a bare CLI out of the store — see §6.

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
# requirement, and one room can install several apps. §6 probed all three:
# key on the SIGNED staged bundle, not the ad-hoc store build.
haus.permissions.grant = [ "pounce" "perch" "trill" ];
```

→ a `.mobileconfig` carrying PPPC + `com.apple.servicemanagement`, keyed by each
app's bundle id and code requirement, that an admin uploads to whatever they
already run. No Apple relationship, no push cert, no server. It also makes the
grants declarative in the same file as everything else, which is the actual
haus argument. A genuine differentiator for a Nix desktop, and the piece fully
inside our control.

**Consumers — no sanctioned bypass exists *for grants*** (settings are a
different question with a much better answer — §7), and the ceiling is already
most of the way built. `haus doctor` names each missing permission and deep-links its
pane; what's missing is only the first-run loop that polls until granted instead
of printing a line and exiting. Unglamorous, and it has to survive Tahoe's
re-prompt behaviour — but it's an extension of `plan_permissions` / `doctor`,
not a new subsystem.

## 6. Probe results — 2026-08-18

`codesign -d -r-` against what is actually installed and running on this machine.
Two questions were asked: does a PPPC grant survive a `/nix/store` path change,
and do our designated requirements survive a `bench release`.

### ✅ Probed — all three of our apps have stable, bundle-id-keyed DRs

The TCC principal is whatever bundle actually runs, which for pounce is **not**
the store copy:

```
$ ps -Ao args= | grep [p]ounce
/Users/julienmartel/.local/state/pounce/Pounce.app/Contents/MacOS/pounce --daemon
```

That staged bundle is Developer ID signed, and its requirement names no hash and
no path:

```
Identifier=com.hausfold.pounce   TeamIdentifier=88M28542LQ
designated => identifier "com.hausfold.pounce" and anchor apple generic
              and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */
              and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */
              and certificate leaf[subject.OU] = "88M28542LQ"
```

Perch (`com.hausfold.perch`) is the same shape, same team. **So both questions
answer yes for our apps**: nothing in those requirements can be invalidated by a
path change or a version bump. Only a bundle-id rename or a signing-identity
change would move them.

> ⚠️ **The trill build on this machine is stale — don't read its id as trill's.**
> The newest `Trill.app` in the store is `trill-2026.08.03-1`, which predates
> both the flick→trill rename and the org decision, and it signs as
> `com.nebelhaus.trill`. The repo declares `com.hausfold.trill` throughout
> today. haus has no trill flake input (by design — AGENTS.md keeps trill out of
> the lock chain), so nothing here installs a current one. Probe a fresh build
> before an emitter keys on trill at all.

### ⚠️ Probed — the *store build* is ad-hoc, and would be unusable as a principal

Worth recording because it is the artifact you'd reach for first, and it is a
trap:

```
/nix/store/…-pounce-2026.08.17/Applications/Pounce.app
  Signature=adhoc   Identifier=pounce   Info.plist=not bound   Sealed Resources=none
  designated => cdhash H"b5efdad9557528234cfd05d02e201f367ddad655"
```

Note the signing identifier is **`pounce`**, not the `CFBundleIdentifier`
`com.hausfold.pounce` — a linker-signed binary with no bound Info.plist. And the
cdhash is not merely per-release but **per-build**: `pounce-2026.07.31-1` alone
has five store paths with five distinct cdhashes. Four sampled releases, four
unrelated hashes (`0ddbd893…`, `25680a45…`, `141fd4d1…`, `589fe3ca…`).

Homebrew's sketchybar is the same shape — `cdhash H"92059d6d…" or cdhash
H"cf2271af…"`, identifier `sketchybar-55554944914eef1d…`. That refines the
folklore about grants dying on `brew upgrade`: the **cdhash** moved, not only
the path, and there is no bundle-id-shaped key that could have named it anyway.

### Reasoned, not probed — the bare-CLI case

PPPC's `IdentifierType` is either `bundleID` or `path`; a requirement string
can't reference a filesystem path, so a client with no bundle can only be keyed
by absolute path. That would make any bare binary haus ships out of the store
stale on every rebuild. **This is payload semantics, unreachable by `codesign`,
and was not tested** — it needs a real profile to settle. It doesn't affect our
three apps, which all have bundles.

### What this does to §5

The emitter is viable as proposed, for pounce, perch and trill alike — the
staging that gives pounce a signed identity is already in place. Two things to
carry into the design rather than discover later:

- **Key on the signed bundle, not the store path.** The obvious `${pkgs.pounce}`
  reference points at the ad-hoc build; the profile has to describe the staged
  app. Getting this wrong produces a profile that looks right and matches
  nothing.
- **Don't key on trill from a local artifact.** The only builds on this machine
  predate the rename; the repo is already on `com.hausfold.trill`, and haus
  doesn't install trill at all. Read the id from the repo, not the store.

There is a third option nobody should take: a loose `CodeRequirement` of just
`identifier "com.hausfold.pounce"` with no certificate anchor, which survives
everything because it constrains nothing. Anything that ad-hoc signs itself with
that identifier would inherit Full Disk Access. (The store builds sign as
`pounce` and so wouldn't match it — the hazard is generic, not one these builds
create.)

### Still unproven

1. Does a device enroll at all against a topic whose push certificate you don't
   hold, and does `profiles status -type enrollment` then report *User
   Approved*? If enrollment itself fails, Path B is dead earlier than §4 says.
2. Is the deny-only list for `kTCCServiceScreenCapture` / Camera / Microphone
   still current on macOS 26?
3. Whether live TCC state keys our apps by bundle id or by path. Not run here —
   Claude Code has no Full Disk Access (it runs under `Claude.app`; Ghostty is
   the identity that holds FDA on this machine, the same asymmetry
   [`macos-settings-matrix.md`](macos-settings-matrix.md) records). Accessibility
   and Full Disk Access rows live in the **system** DB, so from a Ghostty pane:

   ```sh
   sudo sqlite3 -readonly "/Library/Application Support/com.apple.TCC/TCC.db" \
     "select service, client, client_type, auth_value from access
      where client like '%hausfold%' or client like '/nix/store%';"
   ```

   `client_type` 0 = bundle id, 1 = absolute path. Use `-readonly` — a plain
   `sqlite3` opens read-write and drops a journal beside a live TCC.db.
4. Where a `haus.permissions` namespace sits in the room / shared / host
   split ([`rooms-desktops.md`](rooms-desktops.md)). It looks host-leaning — a
   designated code requirement is machine- and signing-identity shaped — but
   every top-level namespace needs that classification decided before it ships.

---

## 7. Grants are not settings — and the settings half has an escape

**Probed 2026-08-18, from a spike in `haus` ([hausfold/haus#391], [#392]). Same
standard as §6: everything below was run on this machine. The per-domain answers
now live in haus's `modules/lib/reachability.nix`; the measurement discipline is
[`macos-settings-matrix.md`](macos-settings-matrix.md).**

[hausfold/haus#391]: https://github.com/hausfold/haus/pull/391
[#392]: https://github.com/hausfold/haus/pull/392

This note is about **grants** — TCC's answer to "may pounce drive the
Accessibility API". A second thing wears the word *permission* and behaves
nothing like it: **settings that live inside a TCC-protected preference
domain**. `com.apple.universalaccess` is the one that matters, because every
accessibility toggle haus ships is written there. §1's gate is real for grants
and does not bind settings.

Three routes to that domain, all measured the same day:

| route | works? | what it costs |
|---|---|---|
| `defaults write` at the user level (what haus ships) | yes | Full Disk Access on the app running the rebuild — one grant per machine, then silent forever |
| managed preferences in a profile | yes | an admin password in System Settings **per profile version** (§1) — so MDM, or a nag |
| root write to `/Library/Preferences` — the any-user level | yes | root, which activation already has; a `universalaccessd` restart; and the user domain shadows it |

The third row is what changes this note's conclusion.
`/Library/Preferences/com.apple.universalaccess.plist` is root-owned rather than
TCC-protected, and CFPreferences searches managed → current user → any-user, so
a root write lands with **no grant anywhere, no profile, and nothing clicked**.
Activation is already root. Reachability, in other words, is a property of
*(domain, level)* rather than of the domain.

So: for **settings**, a downloaded desktop can go all the way down today,
without MDM and without a permission dialog. For **grants**, §1 and §6 stand
unchanged — nothing short of a user-approved MDM hands pounce its Accessibility
grant, and §6 is what says the org emitter is worth building. Keeping the two
apart is the point of this section: `haus.permissions` (§5) is about grants and
must not grow settings, and `haus.accessibility` is about settings and can never
deliver a grant.

Carried from the spike so the table isn't over-read: only `reduceTransparency`
was measured at the any-user level, survival across a reboot is untested, and
the shadowing is **silent** — the moment a person touches that switch in System
Settings their user-domain value wins forever and the root-written value goes
inert, with nothing anywhere to say so. That last one is a product decision
rather than a bug, and it is why haus has not moved its writer to this route.

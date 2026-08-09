# Option-surface roadmap — from "Julien's dev rice" to a shareable rice format

Working doc. The end goal: people publish **nebelhaus configs** of wildly
different kinds — a large-print Mac for a parent, a writer's machine, a
mouse-first creative setup — by changing `nebelhaus.*` and nothing else. When
this was written the option surface could express none of them; `full`,
`everyday` and `large-print` now all pass the readiness test in §6, and what's
left is tracked against it there. (Passing is not finishing — §6 records the
three limits the test exposed, which are the most useful findings in this doc.
Limit 1 is closed; limit 3, composition, is the one a stranger hits first — it is
closed for packs, and its preset half is now measured rather than assumed, which
falsified three of this document's own claims about it.)

This refines an earlier brainstorm against what's actually in the repos as of
2026-07-25. Read §1 first — several things the brainstorm proposed building
already exist, and one it treated as a detail is the actual root blocker.

> **★ Naming banner, 2026-08-08 — read every `nebelhaus.*` below as `haus.*`.**
> The platform is being renamed **hausfold**, its option namespace **`haus.*`**,
> and `nebelhaus` demoted to what this document has always been arguing it
> should be: **one rice among many**, the developer-focused one. The plan is
> [`hausfold-rename.md`](./hausfold-rename.md).
>
> **The body of this file is deliberately NOT rewritten.** §5.14 makes it a
> historical record, and retroactively renaming options in dated findings would
> make ship-dates and PR numbers stop matching what those PRs actually say.
> So: `nebelhaus.roster` below is today's `haus.roster`, and so on throughout.
>
> Two things here the rename leans on, both already shipped: **§3.2**
> (`developer.enable` — "minimal" stopped being a lie, so the rice can be turned
> off) and **§3.3** (presets-as-format + `checkRice` — a rice became a data
> file). They are why the rename can happen now rather than after a refactor.
> And one thing it inherits: **§6's Limit 3 stops being a note and becomes a
> launch blocker**, because `hausfold.co/desktops` is where strangers meet. State
> it the way §6(b) *measured* it, not the way this document first asserted it —
> the "they see a raw trace rather than anything we wrote" version was **this
> file's own claim and it was retracted** (§6(b), and the confession at
> "the falsified claim was one of MINE"): the plain conflict error names the
> option, both files and `lib.mkForce`, so they're told nearly everything.
> What's actually unfixed for a *gallery*: composing two rices is rice-vs-rice,
> §6(d) measured that `mkDefault` "can never be" a fix for it, `checkRice` can't
> catch it because the module system stops first, and a transforming seam prints
> `<unknown-file>` twice. §6(e)'s **priority by list position** (`compose`) is
> the live candidate, and it is what a **second rice in `/desktops`** should wait
> on. ⚠️ **Amended 2026-08-08:** this read "what `/desktops` should wait on", and
> the page shipped that day with a working install command anyway — correctly,
> because every clause above needs *two* rices composed and there is one. The
> blocker is real and it binds the second entry, not the page.
>
> What §7's repo routing means now: `nebelhaus` → `hausfold/hausfold`, and `web`
> → the consolidated site repo.


> **Status, 2026-08-08 (sixteenth pass) — §5.6's last unspiked box is closed:
> Sound, Locale/input sources and Power are all reachable, and the reason given
> for deferring each of them was wrong.**
>
> This is a **notes-and-probes pass, nothing shipped in the rice.** The eleventh
> pass (below) deferred these three groups because "no domain for any of them
> has been spiked for effect on this machine at all (typed or not), so there is
> nothing yet to curate honestly, only to guess at" — a good rule that was
> applied to a false premise. All three have typed nix-darwin surfaces: **Sound
> two keys, Locale four, Power six.** The check that would have caught it is
> `grep mkOption modules/system/defaults/*.nix modules/power/*.nix`, which costs
> less than the spike it was used to postpone. ★ **The transferable bit: a
> deferral needs its premise verified as hard as a shipped option does.** This
> document's own "verified, not remembered" language protects what we build and
> not, until now, what we decline to build.
>
> Three probes and two oracles are on the shelf
> (`notes/probes/{sound,locale,power}-sweep.sh`, `locale-effective.swift`,
> `tis-toggle.swift`); the full results are in
> [`macos-settings-matrix.md`](./macos-settings-matrix.md#sound--localeinput-sources--power--swept-2026-08-08).
> The two `defaults`-based scripts snapshot, restore, and then compare every
> touched key's XML fragment (value *and* type) against the snapshot before
> claiming success; the machine ends byte-identical, as with every sweep in that
> file. `power-sweep.sh` writes nothing at all unless you ask it to
> (`POWER_SWEEP_WRITE=1`), because its write is root-level and per-machine.
>
> **What the spike found, in the order it changes decisions.**
>
> - ★ **The missing piece for Locale is not a key — it is a distributed
>   notification.** A `defaults write` reaches newly launched processes only; a
>   running app never notices, not even through `Locale.autoupdatingCurrent`,
>   the flavour documented to track changes. Posting
>   `AppleDatePreferencesChangedNotification` immediately after the write flips
>   it within one sample, and a made-up notification name does nothing. This is
>   the first setting family whose "restart" is neither a `killall` nor a
>   logout, so `modules/lib/restart-map.nix` (rice#249) needs a **third verb**
>   before this group can ship honestly. That is now the gating work item, and
>   it is small.
> - **`com.apple.sound.beep.volume` is `e^(slider − 1)`, not a fraction** —
>   `0.5` is 31% and anything at or below `e⁻¹ ≈ 0.368` is silence. nix-darwin's
>   docstring lists 75/50/25% as three magic constants and never names the
>   curve. A curated `sound.alertVolume` takes 0–100 and converts; exposing the
>   typed float would ship a lie that reads as a bug in *our* option. Same key
>   is written back by the volume keys, so it is also a two-writers leaf (§5.7's
>   question, inside a settings group).
> - **A bad `beep.sound` path is SILENCE, not a fallback** — settled by ear
>   2026-08-08 (control beeped, Submarine beeped, `/nope/does-not-exist.aiff`
>   did not). So `sound.alertSound` must validate its path at eval time, or take
>   an enum of the 14 names in `/System/Library/Sounds` and build the path
>   itself. Same family as `screencapture.location`'s missing directory, worse
>   consequence: there you find your screenshots on the Desktop, here the
>   machine just stops making the sound you asked for.
> - **`AppleMeasurementUnits` is typed, friendly, and inert.** Of the four typed
>   region keys it is the only one that moves nothing measurable, and it is the
>   one a rice reaches for first (`Inches`/`Centimeters` enum). `AppleMetricUnits`
>   is load-bearing. §5.6's "what second key makes the first a lie", with the
>   roles reversed — here the *decorative* key is the well-typed one.
> - **`AppleFirstWeekday` lands and lies**, the second dict-valued key to do so
>   after `FontSizeCategory`. Promoting that to a rule: **treat structured keys
>   in Apple's global domain as GUI-only until one proves otherwise.** Set
>   `AppleLocale` instead — it moves hour format, measurement system and first
>   weekday together, and is the group's real lever (untyped →
>   `CustomUserPreferences`).
> - **Input sources are settable from a plist, and the authoritative-looking key
>   is the decorative one.** `AppleEnabledInputSources` resolves a layout by
>   `KeyboardLayout Name`; the `KeyboardLayout ID` beside it must merely be
>   *present* and is never validated (`99999` works fine). Exact inverse of the
>   hot-corners finding. And the name isn't derivable from the input-source id
>   (`com.apple.keylayout.SwissFrench` → `"Swiss French"`), so a hand-typed table
>   in Nix would be wrong for precisely the layouts nobody here tests: the option
>   should take the stable `com.apple.keylayout.*` id and resolve it through the
>   documented TIS API at activation.
> - ⚠️ **Power is typed, source-blind, and on this machine it does not work at
>   all.** `power.sleep.*` and `power.restartAfter*` shell out to `systemsetup`,
>   not `system.defaults` — the `security.firewall` family, not the `hotCorners`
>   one. No `systemsetup` verb takes a power source, while macOS stores battery
>   and AC separately, so "sleep at 5 min on battery, never on AC" — the only
>   opinion a laptop rice has — is not expressible. ★ **And the missing selector
>   is not neutral: measured, `systemsetup -setcomputersleep 17` run while the
>   machine was on BATTERY wrote the AC profile and left battery alone.** So
>   `power.sleep.computer` configures a power source the config never named,
>   silently, while `pmset -b`/`-c` does exactly as told. nix-darwin also sends
>   every call to `&> /dev/null`, and `systemsetup` really does emit an
>   Admin-framework `-99` on stderr — even on a write that succeeds — so there
>   is live content in a stream nobody reads. Worth filing upstream. Low Power
>   Mode, lid behaviour and per-source anything are `pmset`, root-only, untyped
>   regardless.
>
> **★ The Power row has now produced three confident wrong answers, and that is
> the most useful thing in this pass.** Section C is opt-in behind
> `POWER_SWEEP_WRITE=1` (an env gate, not a sudo-cache check, so a warm
> timestamp can't make an agent run it by accident).
>
> - **Run 1** — `systemsetup` applied nothing → *"nix-darwin ships six silent
>   no-ops, file it upstream."*
> - **Run 2**, with a `pmset` control — pmset applied nothing either → the
>   *setting* is pinned on this Mac, and run 1 was never evidence about
>   `systemsetup`. **A failed write says nothing about the writer until a second
>   writer has failed the same way and a second setting has succeeded**: the
>   negative-result twin of this document's "the write succeeded ≠ it took
>   effect".
> - **Run 3**, the full 2×2 — four timer writes failed and `pmset -a
>   lowpowermode 1` **landed**, same shell, same run, same root. That clears
>   privileges and `pmset` itself… except the four failures were read from
>   `/Library/Preferences/com.apple.PowerManagement.plist` and the one success
>   from `pmset -g custom`. **Two oracles, opposite verdicts.**
> - **Run 4**, reading `pmset -g custom` — **every write had been landing all
>   along.** The plist is a file `powerd` flushes on its own cadence; the probe
>   caught it in the act on the way out, printing `computer AC=18(file:1)`.
>
> ★ **Four runs, three wrong conclusions, and not one was a macOS surprise —
> all three were measurement errors.** A single row read as a verdict; a
> negative result with no control; and finally two oracles inside one table,
> which is not a cross but two experiments sharing a heading. The rule, which
> generalises well past power: **where a domain exposes two readable states,
> decide which one is the oracle before running anything, and never let one
> table's rows be judged by different readers.** The PowerManagement plist is to
> this section what `com.apple.Accessibility` was to §4 — the thing that reads
> like evidence and isn't.
>
> **And the real limit turns out to be sharper than "source-blind".**
> `systemsetup -setcomputersleep 17`, run while the machine was on **battery**,
> set the **AC** profile and left battery alone. So `power.sleep.computer`
> doesn't merely fail to express battery-vs-AC — it writes a profile the config
> never named, silently, while `pmset -b`/`-c` does exactly as told. That is a
> correctness bug worth filing upstream, and it is the reason a curated group
> must be built on `pmset`.
>
> **What this unblocks.** §5.6's rule — no unspiked domain gets curated — is now
> satisfied for every row in its table except the two deliberately-deferred
> logout-only ones (`loginwindow`, `WindowManager`). Sound is buildable today.
> Locale is buildable once restart-map learns `notify`. Power is buildable as an
> activation step of the rice's own, and should not pretend to be a
> `system.defaults` group.


> **Status, 2026-08-08 (fifteenth pass) — §5.1's macOS Light/Dark box is shipped,
> and the spike falsified the box's own premise: `AppleInterfaceStyle` is inert in
> BOTH directions on macOS 26, not just the "off" one.**
>
> This is the box the fourteenth pass (below) deliberately left open and handed
> to Julien — *"whether that box gets escalated in prose or simply built is
> Julien's call, pending."* It was built. Worth noting which half of that pass's
> reasoning held: it was right that rice#249 cleared the **stated** blocker and
> right that rice#252's palette row made the gap one click deep — and wrong, in
> good faith, to inherit the box's account of *why* the gap existed. The audit
> checked whether the blocker had cleared; nobody had checked whether the blocker
> was real.
>
> **What shipped ([nebelhaus#257](https://github.com/nebelhaus/nebelhaus/pull/257)).**
> `nebelhaus.theme.systemAppearance` — `unmanaged` (default) / `flavor` /
> `light` / `dark`. `"flavor"` is the one that makes light mode complete: latte
> sets macOS to Light, mocha to Dark, so a latte rice stops looking half-done on
> a dark Mac. Applied from home-manager activation via System Events, guarded and
> idempotent; `hausax` grew an `appearance` key and is the oracle.
>
> **★ The finding is the valuable part, and it is the reverse of what this doc
> said for eleven passes.** The box claimed dark-on was one typed setting and
> dark-off was the impossible half. Measured on real hardware with a probe
> watching `NSApp.effectiveAppearance` and subscribed to
> `AppleInterfaceThemeChangedNotification`: **neither direction works.** Writing
> `Dark` from a light session and deleting the key from a dark one both change
> nothing — through `activateSettings -u`, through a `killall SystemUIServer`,
> and for a process launched *fresh* afterwards, with no notification posted
> either time. The key is a mirror the appearance system writes on its way past.
> `system.defaults.NSGlobalDomain.AppleInterfaceStyle` is a dead option on macOS
> 26. A plausible asymmetry story survived this long precisely because it
> explained the observed behaviour ("light rice, dark Mac") correctly while being
> wrong about the mechanism — §5.14 should count "a stated blocker nobody
> re-measured" as its own drift shape.
>
> **Phase 4 was the stated blocker and turned out not to be the enabler.**
> `restart-map.nix` gets a documented entry, but its honest content is "no
> restart can make an inert write live". The map answers *what makes a write
> live*; it has nothing to say about a key macOS doesn't read. Generalisable: an
> unreachable setting has at least two causes, and only one of them is a missing
> restart.
>
> **What this does and doesn't close.** The default is `"unmanaged"` on purpose —
> a managed default would silently revert an appearance picked in System Settings
> on the next rebuild. Which left pounce's one-click "Switch to light mode"
> (§5.7's audience) still landing on a dark macOS — **closed in the follow-up,
> [nebelhaus#258](https://github.com/nebelhaus/nebelhaus/pull/258)**: `haus set`
> takes PAIRS now (`haus set theme.flavor latte theme.systemAppearance flavor`),
> all-or-nothing, one rebuild, and the palette row sets both. The reason it had
> to be one call rather than two lines in the runner is the interesting part —
> `haus set` rebuilds per call, so two calls is two rebuilds *with the machine
> sitting in the half-done state in between*. Driving System Events also needs an
> Automation grant, degrading to a named warning — the same reachability shape as
> `accessibility.increaseContrast`'s FDA caveat, which §5.12 already decided not
> to promote into a typed field.
> **Status, 2026-08-08 (fourteenth pass) — an audit pass, not a shipping one.
> Nothing new was built; two claims in this file were wrong, the phase summary
> had drifted from the sections it summarizes, and this pass's own first finding
> was wrong and had to be retracted before the PR opened.**
>
> Run the §5.14 way — reading every commit across the family since the
> thirteenth pass's work rather than diffing the checkbox list. The window is
> small (rice #254/#255 + the 2026.08.08 release, nebelung#29, pounce#65,
> perch#36/#37, holt's SDK run — nebelung#29 and pounce#65 landed *before*
> rice#253 merged, so "since the thirteenth pass" is by write-up date, not by
> merge order), and the findings that survived all came out of commit *bodies*,
> not diffs.
>
> **★ Finding 1 — RETRACTED, and the retraction is the finding.** This pass
> first reported that `accent-reach`'s `glow` row had been a false green for
> seventeen minutes on 2026-08-07: rice#247 shipped the accent-matrix path
> `glowStyle = "${nebelungRoot}/glow/themes/<flavor>/catppuccin-<flavor>-<accent>.json"`
> at 06:15 while its lock pinned nebelung at `4ea4fa4`, which is not
> nebelung#29's merge commit (`2110fac`, 06:13) — so the JSON looked absent and
> the check looked green anyway. **The pre-PR assurance pass killed it.**
> `4ea4fa4` *is* nebelung#29 — its own PR-branch head, tree-identical to the
> squash (`git diff 4ea4fa4 2110fac` is empty) — and rice#247 bumped the pin in
> the very same commit that introduced the path. glow resolved the whole time;
> the check's green was correct.
>
> **The rule that mistake earns: a lock rev that isn't the upstream's main rev
> is not evidence of a stale pin, and this file's audits keep reaching for revs
> where the question is about trees.** Squash-merge guarantees the rev you
> locked pre-merge never appears on main, so "the lock doesn't point at the
> merge commit" is the *normal* state for anything pinned from a PR branch, not
> a smell. The check is `git diff <lockrev> <mainrev>`; comparing hashes proves
> nothing. That is a cheaper lesson than the one this pass thought it had.
>
> **★ And the same evidence does hold a real hazard, one the retraction
> surfaced.** For those seventeen minutes rice `main`'s lock pinned a nebelung
> rev that existed **only on an unmerged PR branch**. It is still fetchable today
> purely because that branch was never deleted (`origin/worktree-bdab`) — and
> GitHub deletes head branches on merge by default, which is the premise holt's
> whole `reship` story is built on. A merge-and-delete inside that window would
> have left rice `main` unable to fetch nebelung at all: not a silent wrong
> colour, a repo that doesn't evaluate. **Pinning a downstream lock at a rev
> that is not yet on the upstream's `main` is the actual cross-repo hazard
> here**, it is invisible to every check in the family, and §7's ripple story
> doesn't cover it because `bench ship` only ever bumps to merged HEADs — this
> came from a hand-run `nix flake update` inside a PR.
>
> **What survives of the original observation, as design reasoning rather than
> an incident:** Nix does interpolate a store path into a string without
> asserting anything is there, so `accent-reach`'s `glow` row *would* read
> `moves` even with the referent missing — it fingerprints the plugin file's
> text, and the accent varies only inside a path. No such break has happened.
> The cheap belt is one line in the existing `glowPlugin` `runCommand`
> (`[ -f ${glowStyle} ]`), and the file already half-knew: the `zed` row carries
> a comment calling itself "the one row whose fingerprint is a FILENAME rather
> than a file's contents", noticed and then not generalized.
>
> **★ Finding 2 — the tenth pass's own headline claim was half false, and
> rice#255 corrected it.** That block says den's restart commands are
> "read out of `config`, not hardcoded, so a future module gets this for free."
> True of the **domains**, false of the **processes**: #249 then filtered the
> map's values through `restartProcesses = [ "Finder" "ControlCenter"
> "SystemUIServer" ]`, an allowlist that had to be edited in lockstep with the
> map — so the day a domain's value named a process not on the list, the map
> said "restart X" and den silently dropped it. That is precisely the
> hand-maintained gap `restart-map.nix` exists to close, reintroduced one file
> over, and #250's own comment had already noticed the smell ("`restartProcesses`
> has carried ControlCenter unused since rice#249") without drawing the
> conclusion. #255 inverted it to subtract the four sentinels
> (`Dock`/`activateSettings`/`none`/`logout`) instead. The lesson is narrower
> than "check your allowlists": **a table plus a filter over that table is two
> sources of truth wearing one name**, and the tenth pass's own closing
> paragraph had flagged the shape (`haus revert-settings` hand-rolls the same
> triad) while missing this instance inside the file it was describing.
>
> **Finding 3 — §5.1's recommended pattern needs a condition.** That section
> sells `theme.ports.handled` — rooms declaring what they already wire by hand —
> as "the pattern to copy for any future generic-pass-plus-hand-tuned-exceptions
> option." rice#255 found its failure mode: #251 made the gh-dash integration
> opt-in (`hearth.ghDash.enable`, default false) but claimed the port as
> `handled` unconditionally, so a machine with the integration **off** got no
> theme (the roster pass had been told to skip it) *and* no `haus doctor` nudge
> (it had been told a room handles it). A `handled` claim has to be gated on the
> same flag that does the wiring; an unconditional one converts an opt-in
> feature into a silent hole in two systems at once. Noted in §5.1's box.
>
> **Housekeeping — the phase summary was stale, in the doc's own shape 1.**
> Phase 4 and Phase 5 still read fully-unstarted for §5.6 (rice#250 shipped
> three of the seven groups still open after rice#198, taking the table to five
> of nine), §5.9's pounce half (pounce#43) and §5.11 (all four commands shipped
> *and felt*, rice#248 — its own section header says so).
> §5.6's header still carried "gated on §4" after rice#249 removed that gate.
> All corrected below. This is the failure §5.14 was written about, recurring in
> the summary list rather than in a section: **the phase list is a second
> checkbox surface, and nothing was keeping it honest.**
>
> **Not touched this pass, deliberately:** §5.1's macOS Light/Dark box. Its
> stated blocker — "an activation-script `defaults delete -g` plus the restart
> map, i.e. Phase 4" — cleared when rice#249 landed, and rice#252 has since put
> **Switch to light mode** in the palette writing `theme.flavor = latte` alone
> (`modules/pounce/commands/settings.sh:21`), so the asymmetry is now reachable
> by one click from the non-technical user §5.7 exists for. Whether that box
> gets escalated in prose or simply built is Julien's call, pending.
>
> **Status, 2026-08-07 (thirteenth pass) — §5.4's last open box, a real workspace
> model, is shipped: Phase 3 now has no unstarted item.**
>
> **What shipped ([nebelhaus#253](https://github.com/nebelhaus/nebelhaus/pull/253)
> + a paired, currently-draft [nix-config#45](https://github.com/JulienMartel/nix-config/pull/45)).**
> `nebelhaus.workspaces` is a real, first-class option now: `roster.*.workspace`
> and `roster.*.barIcon` are gone — a workspace names its own member apps
> (`apps = [ "slack" "mail" "messages" ]`) instead of one app claiming a
> workspace, so a role or project workspace is representable for the first
> time. `roster.*.float` (+ `titleRegex`) also generalizes the second half of
> this box — window rules beyond assignment — replacing the three hand-hardcoded
> always-float `aerospace.toml` rules with the same data-driven shape
> auto-assignment already used.
>
> **★ No back-compat alias, and that was the risky part §5.4's own text warned
> about — done anyway, on instruction.** The original sketch proposed
> `roster.<id>.workspace` desugaring into the new option so existing hosts
> wouldn't break; Julien is the only consumer of this rice and said explicitly
> not to bother — a clean rename, migrate his own host file, no sugar nobody
> but him would ever use. That's the harder-to-undo version of this migration,
> which is why it stayed §5.4's last box through ten prior passes: "the one
> item here that can break a live host if done carelessly" (this section's own
> earlier words) meant reading the whole section before touching a line, not
> just the open checkboxes — the shift-throw binding namespace had to move off
> the app entirely (a workspace's own `key`, not its one owning app's), which
> the sketch above never mentioned and only surfaced from tracing every
> consumer (prowl, sill, the doc generator, pounce's `add-app.sh`, the shipped
> `packs/writing.nix` example) by hand.
>
> **`center` and `sticky` are checked off as verified-infeasible, not shipped.**
> AeroSpace has no command to position or resize a floating window's geometry,
> and no primitive for a window visible across every workspace — its own docs
> call sticky windows "not yet supported." Confirmed against upstream before
> writing either off, so the box closes on a citation instead of staying open
> because nobody got to it.
>
> **What this does and doesn't close.** A pack still can't claim a workspace
> for its own apps — `checkPack` only carries `nebelhaus.roster` through
> `lib.pack`, and extending it to `nebelhaus.workspaces` (where `apps` needs
> list-merge semantics every other pack field doesn't) is real follow-up work,
> not done here; `packs/writing.nix` and its README now say so explicitly
> rather than silently going stale. `monitor` / `layout` from the original
> sketch didn't ship either — nothing needed them this pass, and per-workspace
> monitor pinning is its own feature with its own risk (bridging AeroSpace's
> monitor matching against `nebelhaus.displays`' UUID vocabulary).
>
> Verified on the real machine, not just through an evaluator: a full build of
> the actual `mbp` host against this branch finished with zero warnings, the
> generated `aerospace.toml` and `sketchybar/workspaces.sh` were read back and
> checked against pre-migration output line-for-line, and `nix flake check
> --all-systems` stayed green throughout (`presets`, `packs`,
> `data-only-surface`, `preset-composition`, `keymap`, `theme-variants`,
> `accent-reach`, `font-reach`, `scale-reach`). §5.4 has the full account,
> including the five new assertions each exercised by hand and why the
> consumer-side PR is deliberately a draft rather than red.
>
> **Status, 2026-08-07 (twelfth pass) — §5.7 is built: the machine-writable
> overlay is ordinary Nix, and the palette has its first settings front door.**
>
> **What shipped ([nebelhaus#252](https://github.com/nebelhaus/nebelhaus/pull/252),
> docs [workshop#247](https://github.com/nebelhaus/workshop/pull/247)).** `mkNebelhaus` now auto-imports
> `hosts/<host>/settings/*.nix` beside the existing `packages/*.nix` seam.
> `haus set theme.accent teal` writes one managed module there, stages it so a
> git-backed flake can see it, evaluates the machine's own option tree to reject
> an unknown path or bad value, then takes the normal build-before-switch
> `haus rebuild` path. There is still one source of truth: the generated Nix file
> IS the setting; no JSON or mutable state database exists beside it.
>
> **★ The priority is part of the feature.** A plain definition would collide
> with `large-print` (and any future preset that names the same option), because
> module import order is not priority. The overlay writes `lib.mkForce`: this is
> the machine owner's explicit answer and it has to beat a rice. `haus reset
> <path>` removes that answer and reveals the host/preset/rice value underneath;
> `haus unset <path>` is deliberately different and writes `null`, so the module
> system accepts it only for nullable options. `haus get <path>` reads the fully
> evaluated declaration, while bare `haus get` lists only overlay-owned values.
>
> **The boundary is executable, not prose.** Both `theme.accent` (short form)
> and `nebelhaus.theme.accent` resolve inside the same namespace; `system.*`, an
> unknown `nebelhaus.*` leaf, unsafe path syntax, and a type-invalid value all
> fail before activation. The integration test raises a real temporary consumer
> flake and proves string + number writes, nullable unset, reset-to-default,
> invalid enum rollback, and the non-nebelhaus guard through evaluation — not by
> grepping the emitted file alone.
>
> **The Pounce last mile came with it.** A `Haus Settings` submenu exposes the
> three §5.7 actions — **Make text bigger**, **Switch to light mode**, and **High
> contrast on** — and delegates all persistence, validation, and rebuilding to
> `haus set`. The palette does not grow a second implementation of settings.
>
> **Proof and the remaining feel-test.** `nix flake check`, the dedicated
> integration test, shellcheck, and a full consumer system build are green. A
> plain `bench try` was also attempted; it reached and built the new `haus` and
> Pounce command derivations, then the unrelated local Holt override failed
> because its newly nested `sdk/go` module is being treated as a root Go package.
> Repeating the same full consumer build with the last pre-Go-SDK Holt revision
> succeeded. Activation stays Julien's call, so the final live proof is still:
> `bench try switch`, make a macOS-backed change with `haus set`, then use the
> already-landed `haus diff` to prove the running generation matches effective
> state rather than merely eyeballing the generated file.
>
> **Status, 2026-08-07 (eleventh pass) — §5.6, unblocked by the tenth pass's
> restart map, ships three curated behaviour groups; four remain unbuilt, two
> of them deliberately.**
>
> **What shipped ([nebelhaus#250](https://github.com/nebelhaus/nebelhaus/pull/250)).**
> `nebelhaus.lock` (screensaver password + delay), `nebelhaus.menuBar.{clock,
> controlCenter}` (clock format/seconds/date/analog + which Control Center
> glyphs show) and `nebelhaus.security.firewall` (wraps nix-darwin's
> `networking.applicationFirewall`) — three of §5.6's seven still-open groups,
> named and scoped the same way `hotCorners`/`screenshots` already were: every
> leaf null by default, action names instead of raw plist values, restart
> behaviour read out of `modules/lib/restart-map.nix` rather than hand-rolled
> per group.
>
> **Two things gated this pass, both from the task brief rather than the code:
> check the restart map landed first, and don't ship a group that silently
> needs a logout.** The first was easy — #249 (the tenth pass, below) landed
> the same day. The second shaped the actual scope more than anything else:
> `com.apple.loginwindow` (the LOGIN half of "Lock / login / screensaver") and
> `com.apple.WindowManager` (all of "Windows") are both declared `"logout"` in
> the restart map, with no live-reload path on macOS 26. Rather than ship them
> anyway with a "requires logout" note in the description — which the codebase
> has no established pattern for yet, unlike `nebelhaus.accessibility`'s FDA
> note — both are left out entirely, and §5.6's table now says so in place of
> the group. **Sound**, **Locale/input sources** and **Power** are left out for
> the opposite reason: no domain for any of them has been spiked for effect on
> this machine at all (typed or not), so there is nothing yet to curate
> honestly, only to guess at.
>
> **★ Not every shipped group could be verified the way hot corners and
> screenshots were.** Both of those inherited a restart nix-darwin already
> performs (Dock) or need no restart at all (screencapture re-reads per
> capture). `lock` and `menuBar` are the first groups here whose restart is
> `killall`-a-process-and-hope — plausible (Finder gets the identical
> treatment), backed by nix-darwin's own precedent, but not measured against an
> effective-state oracle the way `reduceMotion` was in the §4 matrix, because
> no cheap oracle exists for "did the menu bar clock re-render". Recorded
> honestly in `restart-map.nix`'s own comments and as an open box below, rather
> than claimed. `security.firewall` doesn't have this problem at all — it
> isn't a plist write, `socketfilterfw` is a live command nix-darwin already
> runs unconditionally in its own activation script, so none of the
> restart-map's uncertainty applies to it.
>
> **Verified:** `nix flake check` green on the PR branch, including a real
> `presets` darwin-system build (not just an evaluator) — the same bar the
> eighth pass set for limit 3. **Not verified:** `bench try switch` and an
> eye-check that the new groups actually take effect live, both left to
> Julien per this repo's own worktree etiquette; `bench try` (the full `mbp`
> host) is currently blocked by an unrelated, pre-existing break in the local
> `holt` checkout (`sdk/go` package layout), not by anything in this pass.
>
> **Status, 2026-08-07 (tenth pass) — §4's last open box, the restart map, is
> built and generalized past the one hand-rolled fix it started from.**
>
> **What shipped ([nebelhaus#249](https://github.com/nebelhaus/nebelhaus/pull/249),
> `modules/lib/restart-map.nix` + `modules/den/default.nix`).** The matrix's own finding — nix-darwin restarts
> only Dock, and only when a `dock.*` option changed, so Finder/menu-bar/Control
> Center writes silently wait for a logout — had exactly one fix in the repo
> before this pass: rice#181's hardcoded `killall Finder`, called out in §5.2's
> own text as "the first entry in §4's restart map, written by hand rather than
> as the map." It's now a declared table: every plist domain the rice writes
> maps to `killall <process>` / `activateSettings`-only / `none` / `logout`, and
> den's postActivation generates its restart commands from that table against
> whichever domains the built configuration actually has (typed domains the
> rice always sets via `mkDefault`, plus whatever `CustomUserPreferences`
> top-level keys any module or host contributed — read out of `config`, not
> hardcoded, so a future module gets this for free).
>
> *(Corrected on the fourteenth pass: true of the domains, **false of the
> processes**. #249 filtered the map's values through a hardcoded
> `restartProcesses` allowlist, so a future module naming an unlisted process
> got its restart silently dropped — not "for free" at all. rice#255 inverted it
> to subtract sentinels instead. See finding 2 at the top of this file.)*
>
> **★ The generalization has teeth, not just a data file — and the first
> version of those teeth was too sharp.** A first draft made an undeclared
> domain a hard `assertions` failure; the **pre-PR assurance pass caught that
> this breaks a real, documented workflow**: `haus capture <domain>` lets a
> consumer snapshot *any* plist domain into their own host file's
> `CustomUserPreferences`, which the map has no way to know about in advance,
> so the hard assertion would fail their `haus rebuild` over a file inside the
> pinned nebelhaus flake input they cannot edit. Fixed the same PR, one commit
> later: an undeclared domain is now `warnings`, matching the pattern the
> `universalaccess` block already uses just below it in the same file — "don't
> block a config that would otherwise work." **A generalized check still needs
> to ask who it can fail on**, not just whether it fires correctly — the same
> lesson §5.14 has drawn from drift before, from the opposite direction (a
> check too soft to catch anything) rather than this one (a check hard enough
> to break someone else's rebuild).
>
> Proved on the real machine both ways, not just read through: a clean `bench
> try` (real `darwin-system` build, not an evaluator) went green, the generated
> `activate` script's `killall -qu … Finder` line was traced straight to this
> mechanism in the built output, and deliberately deleting a domain from the
> map reproduced the intended signal in both forms — a build failure with the
> hard-assertion draft, then a warning with the build still succeeding after
> the fix. Same mutation-check discipline `accent-reach`/`data-only-surface`
> already use elsewhere in this doc, applied to a spike finding instead of an
> option — and this time the mutation check is also what caught the check's
> own design mistake.
>
> **What this does and doesn't close.** `WindowManager` stays tagged `logout`
> in the map — the matrix found no live-reload path for that domain on macOS
> 26 and this pass didn't find one either, so it's declared rather than
> attempted. `haus revert-settings` (§5.11) still hand-rolls its own
> Dock/Finder/`activateSettings` triad in `haus.sh` rather than reading this
> same map — a second hand-maintained copy of the identical logic, left as-is
> since it's bash reading a Nix table and out of this pass's scope, but it's
> the next place this exact "one fix, not yet the pattern" shape could recur.
> §4 itself is now fully checked; §5.6 (curated settings groups) was gated on
> this landing and can proceed.
>
> **Status, 2026-08-07 (ninth pass) — §5.11 Reversibility built and felt: `haus
> plan`/`capture`/`diff`/`revert-settings` are real subcommands, and the headline
> risk they exist to catch (a settings diff that trusts the plist) was reproduced
> and caught on this machine, not just reasoned about.**
>
> **What shipped.** All four promote exactly what §5.11 named as already existing
> ad hoc: bootstrap.sh's `preflight_audit` → `haus plan`, its `NEBELHAUS_KEEP`
> current-value reader → `haus capture`, plus two genuinely new commands,
> `haus diff` and `haus revert-settings`. The comparison engine underneath
> `plan`/`diff` (`declared_defaults`) does **not** hand-map nix-darwin's ~193
> typed keys to plist domains — the matrix's own count of that surface was a
> warning that a hand-copied table would drift the moment upstream added one.
> Instead it parses the **built activation script itself** (`defaults write
> DOMAIN KEY '<xml…>'`, one uniform shape nix-darwin's own generator emits) —
> ground truth that can't go stale, verified against the real `/run/current-
> system/activate` on this Mac: all 47 `defaults write` calls it currently
> contains parsed correctly, one of them a dict value (`FXInfoPanesExpanded`)
> that the parser correctly flags as un-comparable rather than silently
> mis-reading.
>
> **★ The §4/§8 finding — "diff must compare effective state, not plists" — is
> now executable, not just documented.** A new probe binary, `hausax` (same
> compile-with-xcrun shape as `hausdisp`), wraps the exact `NSWorkspace` read
> the matrix's spike used, and `haus diff`/`haus plan` route the four keys
> measured to have a write-vs-effect gap through it instead of `defaults read`.
> Proved with a synthetic activation script exercising all four verdicts at
> once on the real machine: a plain key mismatch (`dock.orientation`) printed
> as an ordinary change; `universalaccess.reduceMotion` declared `true` against
> `hausax`'s real (false) reading was caught and reported as a **NSWorkspace
> mismatch, not a plist one**; a `com.apple.Accessibility` write was flagged
> **"KNOWN SILENT NO-OP"** without comparing it at all, since the matrix proved
> that domain lies regardless of what the plist says; and
> `mouseDriverCursorSize` (persists, effect never confirmed) was reported as
> **unconfirmed** rather than either a false match or a false mismatch. Four
> distinct, correct verdicts from one real run — this is the concrete
> reproduction of the exact failure mode §4 found (`haus rebuild` succeeding,
> the plist agreeing, the Mac unchanged) that a plist-only diff would have
> silently called "applied."
>
> **★ A `set -e` bug the design itself would have hidden, caught only by
> running it.** `defaults read` on an unset key — the common case for
> `unconfirmed`-class keys like `mouseDriverCursorSize`, which nothing on this
> machine sets — exits non-zero, and under `haus.sh`'s existing
> `set -euo pipefail` that aborted `settings_diff` **silently partway through**,
> before printing anything for the keys after it. Every `defaults read` call
> and the two `grep | while` extractors now have an explicit `|| true`, with a
> comment at each site naming why ("an unset key is the common case, not a
> script error"). This is the sharpest reason to distrust an untested read of
> this exact code: the bug was invisible in the diff, only visible in the
> terminal. A second instance — `revert-settings`'s own `killall Dock/Finder`
> and `activateSettings` calls, the same `[ cond ] && risky-command` shape —
> was caught the other way, by re-reading the diff against `den/default.nix`'s
> own `|| true` convention for the identical calls, not by running it. Neither
> method alone would have found both.
>
> **`haus capture` generalises past the three named categories, not just past
> "runs once at install."** `dock`/`keyboard`/`finder` still emit the same
> typed `system.defaults.<room>.<key>` lines bootstrap.sh always did (ported,
> not reinvented — bootstrap keeps its own copy since it runs before `haus` is
> on PATH). Any other argument containing a `.` is read as a literal plist
> domain and emitted through `system.defaults.CustomUserPreferences` — the
> escape hatch nix-darwin already ships for exactly this — with nested
> (array/dict) values called out as a comment rather than silently emitted,
> since JSON's `[a, b]` isn't valid nix list syntax and a broken generated file
> would be a worse failure than an honest gap. Felt against this machine's real
> `com.apple.screencapture` domain: three scalars captured correctly (a string,
> a bool, a float), one nested key correctly flagged instead of miscompiled.
>
> **`haus revert-settings` was proved to actually revert.** Not a design
> read-through: a scratch domain was set to a known value, `haus capture`
> snapshotted it (`defaults export`, byte-for-byte, not a replay of individual
> key writes), the value was changed again, and `haus revert-settings` put the
> *original* value back — read back and confirmed equal. The FDA-gated skip
> (`com.apple.universalaccess`/`com.apple.Accessibility` need Full Disk Access
> to restore, same as to write) and the partial-failure reporting (one domain
> restored, one missing file correctly reported as "restore failed", overall
> exit code non-zero) were both exercised directly, though with `has_fda`
> stubbed rather than this pane's own real TCC state — the logic is proved, the
> live FDA-denied path from an actual agent pane is not, which matches the
> asymmetry the matrix already named.
>
> **What this does and doesn't clear.** A real `bench try` (darwin-system
> build, not an evaluator) succeeded with these changes, and `nix-store -q
> --references` on the built `system-path.drv` confirms `hausax` lands beside
> `haus`/`haus-activate`/`hausdisp` exactly where `environment.systemPackages`
> puts it — so this is felt through the actual builder, the same bar the eighth
> pass set for limit 3. `nix flake check` is unaffected (still green: presets,
> packs, data-only-surface, preset-composition, keymap, theme-variants,
> accent-reach, font-reach, scale-reach). What is **not** felt: `bench try
> switch` and a real `haus plan`/`haus diff` invocation through the installed
> binary on a running generation — activation is Julien's call, not an agent
> worktree's, so that last mile is still open the way §6 would expect.
>
> **Left open, honestly.** §5.11's other two boxes — `haus doctor` growing a
> System Settings deep-link checklist, and restart/logout/reboot annotations
> from the §4 matrix surfacing anywhere — were not touched this pass. `haus
> plan`'s "packages" section is a bare closure diff (proven correct, reused
> verbatim from `haus rebuild`'s own mechanism) rather than a script-level
> preview of *what will restart* — the restart-map idea §4 raised is still
> unbuilt, and `plan`'s "scripts" promise from §5.11's own line is really just
> "settings + packages + casks" today, not a narrated list of what activation
> scripts will run.
>
> **Status, 2026-08-07 (eighth pass) — limit 3 was felt on a machine, not just
> an evaluator, and it held; plus an audit of everything that landed since the
> seventh pass.**
>
> **Limit 3, felt for real.** Every measurement of the pack/preset priority
> mechanism so far (`probes/pack-priority.nix`, flake.nix's `packCompose`,
> `preset-composition`) ran `lib.evalModules` over `modules/options-modules.nix`
> — the pure option **surface**, deliberately narrow so it's fast and
> Linux-capable. Nobody had run the actual thing a stranger's own flake calls:
> `mkNebelhaus`, full home-manager and all, on a composition nothing here had
> tried — a preset **and** a pack **and** a host that already disagrees with
> the pack, together. Built (not just evaluated) from a nebelhaus child
> worktree: `flake.mkNebelhaus { extraModules = [ flake.presets.everyday
> flake.packs.writing ]; host = <a file declaring roster.obsidian.key = "n">;
> }` — real `darwin-system` derivation, actually realised, not a drvPath.
> Result: **clean.** The host's key won (`"n"`), the pack's other three apps
> (zotero/anki/calibre) and Obsidian's `cask`/`workspace` survived, `everyday`'s
> own settings (`developer.enable = false`, `prowl.enable = false`) held, and
> the built Brewfile lists all four casks. The contrast case — the same
> composition through the **unwrapped** `flake.packFiles.writing` (what a
> stranger gets from a gist, bypassing the `packs.writing` seam) — still
> conflicts, exactly as designed, and with a real file-based host both sides of
> the error name themselves correctly (`.../felt-host.nix` vs
> `.../packs/writing.nix`), confirming rice#228's `_file` fix holds outside the
> synthetic host `packCompose` uses internally.
> **What this changes and what it doesn't.** It moves limit 3 from "proven in
> an evaluator" to "confirmed through the actual builder, including a real
> build" — genuinely new evidence, not a re-run of an existing check. It does
> **not** clear the bar this doc uses elsewhere for "felt" (§5.1's contrast and
> latte flavor were felt by Julien looking at his own screen) — an agent running
> `nix build` is a stronger signal than an evaluator but not the same claim as
> a stranger who writes for a living actually installing this pack. That gap —
> "represented by a pack nobody who writes for a living has installed" — is
> still open, and is the one thing left in limit 3 that only a real outside
> user can close.
>
> **The audit** (§5.14's rule, run first): `nebelhaus` landed #240–#246 since
> the seventh pass (`rice#243`). Two are option-surface-relevant and both
> **already fix** things this file was still calling open:
> **(a)** §5.2's own "follow-up this turned up and did not fix" — the
> `ui.scale` honest-scope list missing Finder's sidebar and perch — was fixed
> the same day, one PR before #243 landed, in **#241** (added the sidebar row,
> named perch as never-reached) and **#242** (corrected #241's own first guess
> — display scaling doesn't move the perch shelf either, a **display's** points
> shrink by exactly the factor that grows them, so the shelf's physical size
> holds and everything around it grows past it). Marked done below.
> **(b)** **perch now follows `theme.accent`** (nebelhaus#244 + perch#31,
> merged the same day as #243) — takes the catppuccin **role name**, not a
> hex, so one key is right in both light and dark and needs no rebuild on a
> flavor change. `accent-reach` moves perch from `pinned` to `moves`; this is
> the boundary move that check exists to force someone to type out. It does
> **not** touch perch's `ui.scale` blindness (§5.2) — that's a different lever
> (size vs colour) and #242 reconfirms it's still a real, if small, gap.
> Everything else since #243 is infra, not option-surface: **#245** retired
> `wt.sh` entirely (holt is the only worktree tool now — a workshop/rice
> concern, nothing here routes through it) and **#246** is a Codex config
> fix. No open box in this doc is affected by either.
> **hausfold** was checked and is, as expected, irrelevant here — it was split
> out of the workshop into its own repo on 2026-08-06, is explicitly **not** a
> flake input and **not** part of `FAMILY` (per the workshop's own `AGENTS.md`),
> and this document never referenced it.
> **One thing worth a line, not a box:** `perch` relicensed MIT →
> FSL-1.1-ALv2 with a 2-tile free tier + paid unlock (perch#26/#27), and grew
> an iPhone/iPad companion (perch#29/#30, ADR 0005) — both genuine direction
> changes for that room, neither one this roadmap's problem to track (perch is
> a shipped product now, per §9), but worth knowing if a future reference rice
> leans on perch: a "free" mouse-first rice that includes it may not be, past
> two pins.
>
> **Status, 2026-08-06 (seventh pass) — the same question asked of the OTHER
> option that fans out, and the answer was worse: `fonts.mono.name` reached ONE
> surface.**
> The sixth pass pinned what `ui.scale` reaches. Asking the same of the font —
> evaluate two rices differing only in `fonts.mono.name`, diff every file — gave
> **Ghostty's config, and nothing else**. The bar named `"Hack Nerd Font"` in its
> rc, four plugins and six generated blocks, so **the default rice already drew
> its bar in a different family than its terminal**, and §5.3's own motivating
> example (Atkinson Hyperlegible for a large-print rice) moved the terminal and
> left the bar alone. Fixed in **rice#243**: `BAR_FONT` joins the generated
> `sizes.sh` beside the `FS_*` sizes, every literal reads it, and sill stops
> installing Hack — den already installs whatever family the rice names.
> **★ The transferable half is what the check needed.** `font-reach` is the third
> reach table, but the bug lived in the **static** rc and plugins — files that are
> byte-identical whatever family the rice names, so *no number of evaluations can
> see them*. So the table carries one row that isn't an evaluation at all: a count
> of font literals still hardcoded in those files, read straight off the source.
> It is 0; the next hardcoded family makes it 1. **A reach table sees only what
> evaluation produces — when the promise also lives in files the rice copies
> verbatim, the check needs a row that reads them.**
> That makes **eight ★ findings in this file that are checks which can break,
> living in six checks.**
>
> **Status, 2026-08-06 (sixth pass) — §5.2's two unmeasured claims were
> measured, and the bigger one was aimed one layer off.**
> The fifth pass left three check candidates. Two of them were §5.2's — "every
> point-valued option is silently coupled to `displays`" and the honest-scope
> paragraph naming what `ui.scale` does *not* reach — and one measurement
> ([`probes/scale-reach.nix`](probes/scale-reach.nix)) answered both, then became
> **`scale-reach`** in the rice's `nix flake check`. Three things worth carrying:
> **★ the point-valued SURFACE is one option.** Six numeric leaves in the 130 the
> options page renders (plus four internal `_roster`/`_launchers` mirrors it
> doesn't), and exactly one is in points (`fonts.mono.size`); the rest are
> multipliers, ids, an ordering and a percent. Every other point-valued number in the rice — prowl's
> gaps, the Dock tile, the bar's type, pounce's panel widths — is *internal to a
> module*, so a rule written about the option surface governs a set of size one,
> and §5.2's "audit `fonts.*.size` and prowl's gaps" was asking about something
> that isn't an option.
> **★ And that one cannot clip *while prowl tiles it*** — a bigger font on a
> `larger-text` display buys fewer columns, never a window wider than the screen.
> (Read off the code, not measured; the precondition is load-bearing, since a
> floating window or a rice with `prowl.enable = false` has no such guarantee —
> which is §5.6's own "what second key makes the first one a lie", one room over.) The sharper rule: **a point-valued number only meets
> `displays` when something SIZES ITSELF from it**, which in this family is
> pounce (clamped, pounce#53), perch (proportional to `screen.frame.width`, so
> guarded by construction — and blind to `ui.scale` entirely) and the bar (bounded
> by a band that is itself in points). Tiled and OS-managed surfaces absorb it.
> **★ A ceiling needs its own verdict.** `accent-reach`'s moves/pinned/PARTIAL
> can't express a surface that changes and then stops, and `ui.scale` has two of
> them — so `scale-reach` evaluates **four** systems (1.0, 1.4, and two past every
> ceiling) and prints the generated numbers rather than a verdict word. A ceiling
> that regressed into a plain multiplier and a multiplier that grew a ceiling both
> fail now; mutation-checked in both directions.
> **The audit was empty again** — rice#239 merged, nothing has landed since, and
> `options-json` built either side of it is **the same store path** (130 leaves,
> unmoved). Two passes in a row where the option surface didn't move.
> **One correction to the pass below:** `nix fmt` with no arguments is a **silent
> no-op** in the rice (the formatter is bare `nixfmt`, which ignores a directory),
> so "I ran the formatter and nothing changed" proves nothing — see §8.
>
> **Status, 2026-08-06 (fifth pass) — the fifth check candidate is written, and
> the audit found no drift at all, which has never happened before.**
> The last pass ended by naming a `presets` check "in the shape of `packs`, with
> the twist that it must assert a **collision** as well as its absence". Built as
> **`preset-composition`** — rice#239, ~~open when this was written~~ **merged
> 2026-08-06**, so nothing in this block is contingent any more. It composes all six pairs of the shipped
> presets, plus a host that agrees, one that disagrees, one that says `mkForce`,
> one that joins an argument two presets are already having, and two rices that
> each add a tour step and an app, and diffs the result against a golden table. It
> is pure lib, so it runs on Linux CI beside `packs`. Three things worth carrying:
> **what it actually pins is `presets/README.md`'s NUMBERS** — "they share
> five options and disagree about four" was a sentence with arithmetic in it that
> nothing kept true, and the table is generated from `presetFiles`, so a fifth
> preset cannot be added without its four new pairs appearing and someone stating
> what they do;
> **★ derive the fixture from the rice, never name it** — the first draft
> hardcoded which option the host contradicts, and the row for "a plain host does
> NOT settle a preset collision" then quietly measured the wrong thing, landing
> on an option `everyday` and `minimal` *already* disagreed about, so the host
> changed nothing and the row read 4 where the finding is 5. Deriving *the option
> those two presets agree on* makes that row impossible to make vacuous, and it
> prints which option it used. **A golden table should print its own subject**;
> otherwise it can keep passing while testing nothing;
> and **the obvious name was taken**, by a check that answers a different
> question — `presets` evaluates each rice **alone** into a real darwin system
> (darwin-only), `preset-composition` asks what happens when one meets another.
> That split is the readiness test's blind spot, named twice in §6, now visible in
> the check list itself.
> **And the audit (§5.14's rule, run first) turned up nothing** — rice#229–#237 are
> hearth/den/pounce surfaces, and the option surface is unmoved. This time that
> was *measured* rather than asserted, and the measurement is better than a count:
> `options-json` built from rice#228 and from HEAD is **the same store path**, so
> the surface is identical rather than merely the same size. It holds **130**
> options (`jq '[keys[]|select(startswith("nebelhaus."))]|length'` over
> `share/doc/nixos/options.json` — the raw file has 131 keys, `_module.args`
> being the extra), which is the number this document has been quoting — worth
> pinning down, because three other defensible ways of counting the same tree
> give 203, 160 and 135, all true. **The number here is the one the options page
> renders, and nothing else**; a count without its method is not a checkable
> claim.
>
> **Status, 2026-08-05 (fourth pass) — limit 3's PRESET half is measured, and
> three of the things this document says about composing rices are wrong.**
> The last pass closed limit 3 for packs and left preset-vs-preset as the gap,
> excused as "colliding is the intended answer". Nobody had run it. Running it
> (`probes/preset-composition.nix` — the four shipped presets, all six pairs, the
> escape hatches, and two candidate seams; same `lib.evalModules` trick as the
> pack probe, seconds, no darwin system) turned up, in §6's limit-3 section:
> **(a)** overlap is **not** collision — `mergeEqualOption` accepts identical
> definitions, so the rule is *two rices compose iff they never disagree*, and
> half the pairs that "happen not to overlap" actually overlap and merge;
> **(b)** the conflict error **names the option, both files and `mkForce`** when
> a rice arrives as a path, which falsifies the "raw trace rather than anything
> this project wrote" premise option 2 was built on — **except through
> `lib.pack`**, whose wrapper erases the filename, so the one collision rice#222
> deliberately kept loud reports ``<unknown-file>`` twice — **fixed the same day
> in rice#228** (`_file`, plus a third `packs` rule, because that failure is
> invisible until two packs a *stranger* installed disagree);
> **(c)** the pack escape hatch (a plain host assignment) does **not** transfer
> to presets — it's a third normal definition and the build still stops;
> **(d)** presets at `mkDefault` wouldn't help either: equal priorities collide;
> **(e) ★** but **priority by list position works** — one `mkOverride` at a
> `compose` seam makes "the later rice wins" true, in both directions. It costs
> a *blend*, not a winner: `compose [ everyday minimal ]` keeps everyday's
> `tour.steps` because minimal never mentions steps;
> **(f) ★** and the options that don't collide **merge silently** — two rices'
> tour steps concatenate, in reverse import order, no warning. **Composing two
> strangers' rices has two failure modes and this doc only described the loud
> one.**
> **✅ Decided the same day: publish the rule, don't build `compose`** — the
> measurement that made the seam buildable also removed the reason for it, since
> the error a colliding consumer meets is already attributed. The rule now ships
> in `presets/README.md` and `guides/sharing-a-rice.mdx`, including the clause
> nobody knew: **a list- or set-valued option never conflicts, it combines,
> silently.** Adding `lib.compose` later is additive; removing it once a gallery
> depends on ordering is not. (Repos re-read first, per §5.14: since
> rice#222 nothing changed the option surface — 130 leaves, unmoved. rice#223–227
> are hearth/den/pounce surfaces, and the one roadmap-adjacent commit is
> §5.7's — the rice now generates `~/.config/holt/config.toml` from
> `nebelhaus.agents.default`, a third instance of the two-writers seam, correctly
> labelled *edit that option, not here*.)
>
> **Status, 2026-08-04 (third pass) — limit 3's proposed fix was RUN, and it has
> exactly one correct implementation.** The two passes below both ended by
> naming the same next step: try option 1 (ship packs at a lower priority) on
> `packs/writing.nix`. Done — the real pack composed against a host that already
> owns Obsidian, through `lib.evalModules` over the pure-lib option surface (§8's
> technique, no darwin system needed). Results in §6's limit-3 section; the
> headline is that **`mkDefault` on the whole `roster` attrset silently drops
> three of the pack's four apps**, while `mkDefault` per leaf does precisely what
> was wanted — and a data-only pack can write *neither*, because `checkRice`
> refuses a file that takes `lib`. So option 1 is a property of the import seam,
> not of the pack file, and the obvious version of it fails silently.
> **Then shipped, same day — rice#222**: `nebelhaus.lib.pack` + `checkPack`, and
> a `packs` check that composes a pack with a conflicting host and fails if the
> host doesn't win — the first check here that pins a *relationship between two
> rices* rather than one rice's table. **Limit 3 is closed for packs**; presets
> still collide, deliberately.
> (Repos re-read first, per §5.14: nothing roadmap-relevant landed after rice#220
> — #219 is a comment fix and #221 is a pounce command.)
>
> **Status, 2026-08-04 — the readiness test's last visible gap is closed, and
> the test found a new one.** Re-audited against the repos first (§5.14's rule),
> which is what turned up everything below.
>
> **The package-type format limit is FIXED (rice#215).** `packageName` — an
> attribute path into nixpkgs written as a string — now sits beside both
> package-typed options, so a data-only rice can change the font *family*
> (§5.3's own motivating example, unexpressible until today) and an app pack can
> install from Nixpkgs (§5.4). Three things worth carrying:
> **(a)** the fix is one convention, not two options: `<option>Name`, resolved by
> `modules/lib/pkg-by-name.nix`, and `nix flake check`'s new
> **`data-only-surface`** fails when a package-typed `nebelhaus.*` leaf is added
> without its string sibling — because the third one gets added by someone who
> never read the note explaining the first two.
> **(b)** the mechanical audit this doc kept asking for was finally run, and the
> answer was small: **three** typed leaves in 128, of which two were the known
> package pair and the third (`hush.hooks`, a path) is *fine* — a rice can ship a
> script beside itself and say `./thing`, which stays data. The audit that
> sounded like a project was a `jq` one-liner.
> **(c)** the trust line got sharper by being written down: naming a package is
> still data (the resolver walks `pkgs` by attribute path — no `import`, no
> string that becomes code), and it was never a claim that the software is
> vetted, since `cask` could always fetch anything. "You can read a rice and know
> what it does" ≠ "a rice can only install safe things."
>
> **★ And the readiness test has a new limit, which is bigger than the one it
> replaces (rice#203): composing rices is NOT the free operation §6 claimed.**
> The module system has no import-order priority — two definitions of one option
> at equal priority *conflict*, they don't override. So `[ everyday minimal ]`
> fails on `pounce.enable`, and a pack naming an app the consumer already has
> fails with a raw conflict error that never reaches the friendly roster
> assertion the pack advertises. `everyday + large-print` composes only because
> the two files happen not to overlap. Three READMEs said otherwise and are
> corrected; the consumer-side fix is `lib.mkForce`. **The composition story is
> now the format's sharpest limit** — it's the one a stranger hits on their first
> real pack, and unlike the package-type limit it has no fix in hand.
>
> Also landed since the last pass, none of it predicted here: **the accent's
> reach is a golden table** (`accent-reach`, rice#208 — seventeen surfaces × three
> accents, so a dropped accent wire fails loudly instead of silently), Zen's
> accent finally reaches **the actual web** via a declared Stylus bundle
> (rice#208/#211 + nebelung#22), and **trill is out of the rice entirely**
> (rice#212 opt-in → rice#213 removed) — "a supported option nobody should turn
> on is a lie in the option reference" is the sentence to reuse.
>
> > **Second 2026-08-04 pass — a parallel audit, and it found what the first one
> > couldn't.** Two sessions read the repos independently the same day. They agree
> > on everything above; these are the items only the second pass turned up, and
> > the *reason* it did is that it went looking at built artifacts rather than at
> > option definitions:
> >
> > **★ `everyday` shipped a tutor that drew nothing (rice#220).** §5.5's box said
> > the tour *hangs* with `prowl.enable = false`. It doesn't any more — it draws
> > **no pill at all**, while the preset still sets `tour.enable = true` and its
> > own comments explain why a tutor is right for exactly that person. It passed
> > `checkRice`, passed `nix flake check`, and taught nobody anything. **This is
> > limit 3's class, from inside a single file: valid parts composing into an
> > experience nobody chose** — see §6's new closing note on what the readiness
> > test can't see. Closed by authoring the step, which made `everyday` the first
> > customer of §5.13's own community-tour mechanism, six days after it shipped.
> > That in turn exposed the mechanism's gap: **data-only means data cannot
> > interpolate**, so an authored hint could never name the keys the machine
> > resolved. Placeholders now do it; any future authored-TEXT option needs the
> > same seam.
> >
> > **The refuted composition model outlived its correction (rice#220).** rice#203
> > corrected "imported after, so it wins" in the three files that prompted it. It
> > survived in `modules/host-template.jq` — *including the header written into
> > every user's `hosts/<host>/options.nix`* — in `bootstrap.sh`, and in one
> > sentence at the bottom of the same `presets/README.md` #203 fixed at the top.
> > **Grep for the claim, not for the file.**
> >
> > **§5.7 splits in two, and its reading half is done** — rice#184 ships an
> > annotated `hosts/<host>/options.nix` + `haus options`, the rice's own version
> > of pounce#54's `config init`. "Configure without opening the docs" is met;
> > "configure without opening an editor" is not, and `haus set` is still what
> > that needs.
> >
> > **Smaller, all corrected below:** §5.1's OS-contrast box read `- [ ] ✅` —
> > drift wearing a tick, with both options long since shipped (§5.14 now lists
> > that as its own failure shape); `sill.items` is 15 bools, not 13;
> > `large-print` is four options, not three; the surface is **130** leaves where
> > §1 counted ~44, and four rooms — `agents`, `apps`, `perch`, `zen` — appear
> > nowhere in this document.
> >
> > **And §5.14's structural reason 1 has an answer now.** It said this file's
> > problem is living in a fifth repo no CI can see, while every other seam here
> > got fixed by making the upstream repo emit something mechanical. Two roadmap
> > findings are now checks that can break: `data-only-surface` and
> > `accent-reach`. **When a finding generalises, leave a check behind, not a
> > paragraph** — with the remaining candidates named in §5.14.
>
> **Status, 2026-08-03 — read §5.14 first.** An audit of every open box against
> the actual repos found **three items that had shipped and were never ticked**
> (§5.9's rice-side `pounce.items` in rice#149, §5.12's FDA detection in rice#128,
> §5.2's Finder sidebar in rice#181) plus one family renamed out from under the
> whole document: **`nebelhaus.apps` is `nebelhaus.roster` since rice#182**, which
> also shipped §5.4's multi-source install. Those are corrected below. §5.14
> records why it drifted and what to do about it — the short version is that this
> header is a summary and the CHECKBOXES are the source of truth, and when they
> disagree the repo settles it.
>
> Also new, both in rice#198: §5.6's first two groups shipped
> (`nebelhaus.hotCorners.*` and `nebelhaus.screenshots.*`), settling that
> section's default policy — null = write nothing, and null ≠ off — and turning up
> two silent failures worth reading before the next group. And **Phase 0 is
> closed**: `nebelhaus.packs.writing` is the shareable app pack that item asked
> for. Writing it found a real bug (roster leader keys were never checked against
> the built-in launch actions, so a pack could silently eat one) and hit §5.3's
> package-type format limit from a second family, which makes that limit worth
> fixing once rather than living with.
>
> **Status, 2026-08-02.** §3 (structure) and §4 (spikes) are **done**, Phase 3 is
> mostly done, and all three reference rices pass the readiness test (§6).
>
> **The sizing pass is DONE — both halves** (pounce#53 + rice#175). `ui.scale`
> reaches the command palette (the launcher and every panel behind it) and the
> menu bar's type. Those were the last two rice-owned surfaces `large-print`
> could not enlarge, so §5.2's fan-out is five targets now instead of three.
> Two findings outlived the change and are the reason to read §5.2:
> **(a) `ui.scale` and `displays.*.uiScale` MULTIPLY**, and nothing in the surface
> said so — every point-valued option is silently coupled to `displays`;
> **(b) the bar is a CEILING, not a multiplier** — its height belongs to macOS's
> menu-bar band, measured and confirmed to have no setting behind it, so the type
> scales to 1.25× and stops. That is the first place the readiness test ran into
> something macOS simply owns.
>
> What moved since the last pass is **pounce**, and it moved somewhere this doc
> didn't predict. The palette reads its theme from **runtime files** now
> (pounce#37 + rice#139), follows macOS Light/Dark **by itself** (pounce#42 +
> rice#142, `pounce.followSystemAppearance`), and has a **per-item settings
> schema** keyed by frecency key (pounce#43) — which is the action vocabulary
> §5.5 said `bindings` was waiting for. Two consequences worth carrying: pounce
> is no longer on the "bakes its own colours" side of §5.1's honest-scope line,
> and `scheme = "auto"` now has one shipped implementation to copy rather than a
> design.
>
> Alongside it, **`theme.ports.enable`** (rice#136 + nebelung#17/#18/#19) themes
> the apps in your roster from **port metadata** — so §5.6's "each setting carries
> a reachability designation" idea now ships as data for 53 ports, in a different
> room than the one that proposed it.
>
> **Still open:** §5.4 apps v2 (the schema migration, deliberately last) — and
> with sizing closed it is the last unstarted item in Phase 3. `density`/`motion`
> (§5.2) remain unbuilt but were never blockers.
> §5.10 displays shipped in rice#147 and the rice-side pounce options in rice#149;
> displays still wants a docked multi-monitor proof before growing profiles, but
> that validation no longer blocks `large-print`.
>
> **Earlier history.** §3's four items landed as nebelhaus#92/#96/#98/#93 +
> workshop#81 and the macOS spikes settled in the matrix; fonts (#91), the two
> working accessibility keys (#90), `ui.scale` (§5.2), the contrast axis
> (nebelung#11 + rice#103), light mode (nebelung#12 + rice#108) and `keys.*`
> (#108, which also ships `presets/large-print.nix`) are all in. Read §6's
> scoreboard and the two limits `large-print` exposed before celebrating.

---

## 1. Ground truth (verified, not remembered)

| Claim | Reality |
|---|---|
| "~40 first-class options" | ✅ ~44 leaves in [`modules/options.nix`](nebelhaus/modules/options.nix) — but 13 of those are the `sill.items` pill bools and 5 are `hush.slack.*`. The *shape* surface is more like 25. |
| "rice sets ~19 macOS defaults" | ✅ 19 keys in [`den/default.nix:144-183`](nebelhaus/modules/den/default.nix:144). nix-darwin types **193** (counted, see the matrix) — not "several hundred" as this doc first said. |
| "replace `prowl.apps` with a general app registry" | ⚠️ **Already done, and since superseded.** It was `nebelhaus.apps`; **rice#182 renamed it `nebelhaus.roster`** and grew it the multi-source install §5.4(a) asked for. `nebelhaus.apps` still exists but means something else now (the apps the rice picks for you). Read `apps` as `roster` everywhere below this line. |
| "add `haus plan` / `capture` / `diff` / `undo`" | ✅ **Promoted, 2026-08-07 (ninth pass, §5.11).** `haus plan`/`capture`/`diff`/`revert-settings` (`undo`'s real name) are real subcommands now, built on a probe of activation-script output rather than a hand-maintained domain map. `bootstrap.sh` keeps its own copy of the capture logic (it runs before `haus` is on PATH). |
| "minimal still imports the developer foundation" | ✅ **Confirmed, and it's the root blocker.** [`modules/default.nix`](nebelhaus/modules/default.nix) unconditionally imports `den`+`theme`+`hearth`+`collar`+`secrets`+`snippets`. Turning off all three optional rooms still installs `bun`, `fnm`, `nixfmt`, `opencode`, `zellij`, `yazi`, `lazygit`, `delta`, `gh`, `jq`, `ttyd`, `wt` (now `holt`), `zscratch`, and a git-alias vocabulary. |

**Two mechanisms already in the repo that the brainstorm missed, and that change the plan:**

1. **Machine-writable config already works.** `mkNebelhaus` auto-imports every
   `.nix` in `hosts/<host>/packages/` ([`flake.nix:76-95`](nebelhaus/flake.nix:76)) —
   that's how pounce's "Install App" command writes config without a parallel
   JSON store. **This is the mechanism for a GUI-editable rice** (§3.7), and
   rice#252 generalizes it to `hosts/<host>/settings/*.nix` + `haus set`.
2. **Registry merging means an app pack is shareable *today*.** A file that only
   sets `nebelhaus.roster.*` composes cleanly across modules. That's a
   zero-architecture v0 of the community (§6, Phase 0).

---

## 2. The reframe

The current options expose **implementation** (Pounce, Sill, AeroSpace, Homebrew).
Community rices want to express **intent**:

- "Make everything easier to see."
- "I use a mouse and hate keyboard launchers."
- "This is a quiet writing machine."
- "This Mac lives docked to two displays."
- "Make this usable by my parents without ever showing them a terminal."

Every option below is judged by: *does it move a rice from the first vocabulary
to the second?*

---

## 3. Structural blockers — land these before adding breadth

Adding 60 options on top of today's structure makes the next refactor 3× worse.
These four are cheap now and expensive later.

### 3.1 Split `options.nix` per room · ✅ **DONE** (nebelhaus#92)
656 lines in one file for every room. Move to `modules/<room>/options.nix`,
keep `modules/options.nix` as the cross-cutting/identity file. Purely
mechanical, no behaviour change. **Do this first or everything else compounds.**

- [x] `modules/{den,hearth,prowl,sill,pounce,hush,theme,trill,secrets,snippets}/options.nix`
      (the room list has moved since: `roster`, `displays`, `apps` and `perch`
      joined it, and `trill` is gone — rice#213 removed the module and its flake
      input, two days after rice#212 made it opt-in. The sentence to reuse: *a
      supported option nobody should turn on is a lie in the option reference.*)
- [x] `modules/options.nix` keeps `apps` + `developer` (752 → 122 lines). `git`/`claude` went to hearth, which owns them.
- [x] Verified as a pure move: the example host's derivation is byte-identical and all 39 leaf option paths are unchanged.

### 3.2 Make `developer` a real pack, not the foundation · ✅ **DONE** (nebelhaus#96)
The single highest-leverage change in this doc. Today "minimal" is a lie.

```nix
nebelhaus.developer = {
  enable = true;          # the whole dev pack — off means a non-dev Mac
  shell.toolbelt = true;  # bat/delta/lazygit/lsd/fzf/zoxide/yazi
  multiplexer = "zellij"; # zellij | none
  agents.enable = true;   # holt (was wt), zscratch, statusline, worktree binds
  git.enable = true;      # aliases, delta, lazygit, signing
  languages = [ "node" ]; # fnm/bun; extensible
};
```

- [x] Audited hearth and den; gated packages, `programs.*`, aliases, the fnm hook, Claude settings and nix-index
- [x] Gated `home.packages` and `environment.systemPackages`
- [x] `haus` / `awake` / `mas` / theme stay unconditional (they're the *product*)
- [x] Proved by measurement: `developer.enable = false` drops 16 system + 17 home packages.
      **Not literally zero** — `gh`/`blueutil`/`switchaudio-osx` remain as pounce
      command-plugin deps, which is correct while pounce is on.

**Non-obvious consequence:** with dev off, `hearth.editor = "hx"` is the wrong
default and Ghostty may not even be wanted. Decide what a non-dev nebelhaus
*terminal story* is (probably: no terminal at all, and `haus` reached only via
pounce).

### 3.3 Presets become the community format, from day one · ✅ **DONE** (nebelhaus#98)
The earlier plan put "define the community rice format" at step 9. Invert it.
Make the repo's own presets use the exact mechanism a stranger's rice would —
otherwise you'll build eight layers and discover the format can't express them.

- [x] `presets/{full,minimal,everyday}.nix` — each sets **only** `nebelhaus.*`.
      `large-print` deferred: it needs §5.1/§5.2/§5.3, which don't exist yet.
- [x] `bootstrap.sh` offers Everyday and emits `extraModules = [ nebelhaus.presets.X ]` —
      the same line a person writes to import a rice found online. "Custom" emits none.
- [x] `nix flake check` runs `checkRice` over every preset **and** evaluates a real
      system with each — trust half and usefulness half
- [x] `nebelhaus.lib.checkRice` exposed, with `presets/README.md` defining the format

### 3.4 Generate the options reference · ✅ **DONE** (nebelhaus#93 + workshop#81)
[`web/src/content/docs/reference/options.md`](web/src/content/docs/reference/options.md)
is 389 hand-written lines. At 5× the surface it rots within a month.

- [x] `nix build .#options-json` → `web/scripts/gen-options.mjs` → the page
- [x] Narrative guides stay hand-written; only the reference is generated
- [x] `options-drift.yml` fails if the page is stale.
- [x] Found on the way: the old page documented `git.shellAliases` **twice** with
      two different descriptions, and covered 33 of 71 options.

---

## 4. Spikes — ✅ RUN 2026-07-25, results in [`macos-settings-matrix.md`](macos-settings-matrix.md)

Run on macOS 26.6 with an `NSWorkspace` effective-state probe (a plist read only
proves the *file* changed). Every domain exported before and byte-compared
after — zero net change to the machine.

**They invalidated part of §5.12 and §5.2, and de-risked §5.10.**

- [x] **`com.apple.universalaccess` writability** → ❌ **hard-locked on 26.6.**
      `Could not write domain`. Control: `dock`/`finder`/`screencapture`/
      `Accessibility` all accept the identical write from the same shell, so
      it's the domain, not a sandbox. **All 5 of nix-darwin's
      `system.defaults.universalaccess.*` options are in that domain.**
- [x] **Is there another backend?** → `com.apple.Accessibility` *is* writable and
      holds the modern keys — but writes are a **silent no-op**: plist flips,
      `NSWorkspace` effective state does not. Worst possible failure mode for a
      shared rice: it reports success and does nothing.
- [x] **Restart behaviour** → nix-darwin restarts **only Dock**, only when a
      `dock` option changed, and never calls `activateSettings`. Finder /
      WindowManager / ControlCenter changes silently wait for a logout. **The
      rice must own a restart map.**
- [x] **Display scaling** → ✅ **de-risked.** `displayplacer` isn't even in
      nixpkgs, but public CoreGraphics covers it: a **persistent display UUID**
      exists (`CGDisplayCreateUUIDFromDisplayID`), 9 distinct HiDPI "looks-like"
      modes are enumerable, and `CGDisplaySetDisplayMode` is public API. A ~40-line
      Swift helper replaces the Homebrew dependency. Stable-ID risk retired.
- [x] **Typed surface** → **193** keys, not "several hundred".
- [x] **Does root punch through?** → ⚠️ **The question was wrong.** A real
      `haus rebuild` did fail from root — but it's **Full Disk Access on the app
      responsible for the rebuild**, not euid, that gates the domain. Every
      command in the spike ran under Claude.app, which lacks FDA, so the whole
      chain lacked it. An earlier revision of this doc concluded "locked even as
      root"; **that was wrong** and is retracted in the matrix.
      → ✅ **Positive case now measured** (Ghostty + FDA, 2026-07-25):
      `reduceMotion` **writes and takes effect** — `motion_reduced=true`. So
      `system.defaults.universalaccess.*` is real on 26, gated on FDA.
      → ⚠️ **Asymmetry that matters here:** the grant is on the *responsible
      app*. Ghostty has FDA; Claude Code does not. Set one of these and Julien's
      own rebuilds work while **every agent rebuild aborts activation partway** —
      "works on my machine" in the most literal sense.
- [x] **The blast radius holds regardless.** That write is emitted *unguarded*
      into an activation script running under `set -e`, at line 559 of 877. So
      *whenever it fails* — missing FDA being the common way — activation
      **aborts** and skips every later step, including all launchd daemon/agent
      setup. The symptom lands nowhere near the cause.
      → nebelhaus **warns** (nebelhaus#89 — a warning, not an assertion: with FDA
      these work, so blocking would be wrong), and it's reported on
      [nix-darwin#1049](https://github.com/nix-darwin/nix-darwin/issues/1049).

---

## 5. The option families, ranked

Ranked by *(unlocks a genuinely different rice) ÷ (effort)*.

### 5.1 `nebelhaus.theme` — break out of the Mocha-grey monopoly · L · risk M · ✅ **flavor + contrast + roster ports shipped**
**★ Biggest miss in the earlier brainstorm.** `theme.accent` is an enum of 14
Catppuccin Mocha names; the base palette is always Nebelung grey-dark
([`options.nix:335`](nebelhaus/modules/options.nix:335)). So:

- ~~There is **no light mode** anywhere in the rice.~~ **(✅ shipped — nebelung#12
  + nebelhaus#108: `theme.flavor = "latte"`.)**
- There is **no high-contrast mode** — the root requirement for the
  "old people" rice that started this whole thread. **(✅ shipped — see boxes.)**
- A community rice cannot ship its own colours at all. **(still true: `palette`
  for `flavor = "custom"` is not built. A rice can pick a flavor, not supply one.)**

Nebelung is whiskers-based, so it can render *any* palette — the ceiling is
the option surface, not the renderer.

```nix
nebelhaus.theme = {
  flavor  = "mocha";        # mocha | latte | high-contrast-dark | high-contrast-light | custom
  scheme  = "auto";         # light | dark | auto (follows macOS appearance)
  palette = null;           # attrs of name → hex, for flavor = "custom"
  accent  = "mauve";
  contrast = "normal";      # normal | high  — a WCAG-checked palette transform
};
```

- [x] nebelung: parameterize the flavor, not just the accent — **nebelung#12**.
      Four variants now: the flavor axis (mocha = dark, latte = light) crossed with
      contrast. Light mode is a different **source palette**, not a transform of the
      dark one, which is what the "point the same two rules at Latte" framing buys —
      and there's a test that fails if anyone later reimplements it as an inverted
      ramp. Plain latte lands at 7.0:1 for body text on its own, so
      `contrast = "high"` (9.9:1) is a sharpening rather than a rescue.

      Two findings worth keeping, both now asserted rather than commented:
      **(a)** each variant has to render as **its own catppuccin flavor**
      (`whiskers -f latte`) — templates branch on `flavor.dark` (Ghostty's ANSI
      0/7/8/15, Kitty's tab colours, Zen's `prefers-color-scheme`, delta's
      `light = true`) and name their output after it, so a latte palette rendered
      `-f mocha` emits light colours wearing dark-mode structure under mocha's
      filenames. **(b)** the two contrast boosts **must differ**: a boost pushes the
      ramp out from its midpoint, and Mocha has ~0.2 of OKLCH headroom below `base`
      where Latte has ~0.04 above its, so Mocha's 0.35 melts Latte's
      base/mantle/crust into one white. Mutation-checked — forcing them equal fails
      the ramp-collapse test.
- [x] rice: the flavor is in the **paths**, not just the colours — **nebelhaus#108**.
      whiskers names its output after the rendered flavor, so `latte` moves ghostty,
      bat, lsd, yazi, zen and zsh-syntax-highlighting filenames as well as hexes.
      The subtlest one: delta's single gitconfig carries **all four** flavor
      sections and only the rendered one holds Nebelung colours, so `features` must
      name the same flavor as the include's root or delta silently themes itself
      stock. Selection is factored into `modules/lib/nebelung.nix` (it had been
      duplicated in hearth/sill/theme; a second axis would have made that six
      blocks) and `nix flake check`'s new `theme-variants` pins the
      flavor/contrast → variant/subdir table as a golden file, because that rule
      mirrors nebelung's `variantDir` across a repo boundary and its failure mode is
      **silent** — a wrong subdir is just a store path that doesn't exist, found at
      activation rather than eval.
- [x] nebelung: a contrast-boost transform with a contrast-ratio assertion in CI
      — **nebelung#11**: OKLCH neutral-ramp transform + `test/palette.test.mjs`.
- [x] rice: honest scope — which tools follow `flavor` vs bake their own
      — **rice#103**: `theme.contrast = normal | high`; the option description names what
      it recolours (Ghostty/bat/…/Zen) vs what bakes its own (pounce, macOS).
      **Half-superseded 2026-07-29: pounce came off that list** (see the two boxes
      below). What's left on the "does not follow" side is macOS's own appearance
      and the three hand-made wallpapers — a much better place for the line to sit,
      because both of those are honestly *not ours*, whereas pounce baking its own
      was only ever a limitation of how it was built.
      **Amended 2026-08-08:** macOS's appearance is now *opt-in* rather than out
      of reach — `theme.systemAppearance = "flavor"` moves it, the default
      `"unmanaged"` keeps this sentence true for anyone who doesn't ask. "Not
      ours" turned out to mean "not ours to take without being asked", which is a
      different line than "unreachable" — and only the spike could tell them
      apart. See this section's macOS Light/Dark box.
      → ✅ **And the line is a GOLDEN TABLE now, not prose — rice#208.**
      `accent-reach` fingerprints seventeen surfaces under **three** accents
      (three, not two, so a fingerprint that merely happens to differ once can't
      pass; anything neither all-different nor all-identical reads `PARTIAL` and
      fails). Seven move, ten hold. This is the answer to the failure mode that
      makes an "honest scope" sentence rot: drop the accent wire from lazygit in
      an unrelated refactor and *nothing errors* — the accent just quietly stops
      arriving. **A documented boundary that isn't executable is a boundary that
      moves without anyone deciding to move it.** Generalise it: every "this
      option reaches exactly these things" claim in the surface is a candidate for
      the same treatment.
      → Two things the table's own construction taught: a roster **port** had to
      be added to the check (zed) or the accent-matrix path had no subject at all,
      and its row pins a real gotcha — the port renames its theme file per accent,
      so the app's own `theme` key ends up naming the old file. And trill's row is
      simply gone with rice#213; pounce and perch cover runtime-palette theming.
      → ✅ **Perch's row moved `pinned` → `moves` (nebelhaus#244 + perch#31,
      2026-08-07).** "Pounce and perch cover runtime-palette theming" above was
      about *following macOS light/dark*, not the accent hue — perch's ember,
      pinned tile and notice button were still nailed to a fixed green until
      this landed. It takes the catppuccin **role name**, not a hex, so one key
      is right in both polarities and a flavor change needs no rebuild — the
      only accent surface here handed a name rather than a colour.
      → ★ **"and the Zen browser" was being read as "and the web", and it wasn't
      true** (rice#208's second half + rice#211 + nebelung#22). Switching to
      sapphire left github.com and youtube.com mauve: the rice places Zen's
      `userChrome`/`userContent` per accent, but `userContent` only styles
      `about:` pages. Real sites are **Stylus's** job, and its Catppuccin-derived
      styles carry their own accent var in the extension's storage, which no file
      the rice writes can reach. Fixed by declaring the extension and stamping a
      bundle (`nebelhaus.zen.extensions.stylus`) — which then also gave
      `high-contrast/` and `latte*/` a stylus dir to read, so flavor and contrast
      reach the web too. The lesson is the wording one: a scope sentence naming an
      *app* implies everything that app shows you, and a browser is the one app
      where that's wrong.
- [x] ✅ **Felt on the real machine, 2026-07-27: 19.9:1 reads CRISP, not harsh.**
      That was the one open question a ratio couldn't answer, and it's the answer
      the high-contrast axis needed before anything could be built on it — so
      `large-print` shipping with `contrast = "high"` is now a felt choice rather
      than a measured guess. Worth recording because the doubt was reasonable:
      AAA-on-paper palettes routinely read as glare.
- [x] ✅ **Latte felt on the real machine, 2026-07-28: reads great.** Flipped
      `theme.flavor = "latte"` on mbp with macOS appearance set to Light, one
      `bench try switch`, and the whole hearth/sill/Zen surface came over — so light
      mode is a felt option now, not just a rendered one.
- [ ] ◐ `scheme = "auto"` — **one consumer shipped it, and it wasn't the one this
      box expected.** No sill-hosted watcher was needed: pounce#42 + rice#142 give the
      palette `theme`/`themeLight` and it picks per open, exposed as
      `nebelhaus.pounce.followSystemAppearance` (default **true**). Three things
      that generalise:
      **(a)** the unit that follows appearance is a *tool*, not the rice — anything
      that can re-read a palette at draw time can opt in on its own, and only tools
      that can't need a watcher;
      **(b)** it needed the **runtime-file seam first** (pounce#37 + rice#139 install
      every rendered variant into `~/.config/pounce/themes/`), so "follow the system"
      turned out to be a cheap consequence of "stop baking the palette into the
      binary" — which is the actual reusable move;
      **(c)** it forced a real product decision into the option: a `flavor` pin is a
      *palette* choice, but asking to follow the system says the *polarity* is
      macOS's call, so the two can't both win. The rice resolves it by letting
      `contrast` reach both halves while `flavor` reaches neither.
      **Amended 2026-08-08:** that resolution holds *at the default only*. With
      `theme.systemAppearance = "flavor"` (see this section's macOS Light/Dark
      box) macOS's polarity is the rice's, so `flavor` reaches both halves
      transitively and `followSystemAppearance` stops being an independent axis
      on that machine. The dichotomy in (c) was real but not permanent — it was
      a consequence of the rice not owning macOS's polarity, which was itself a
      consequence of a measurement nobody had taken. Worth logging as its own
      drift shape: a *closed* item can go stale because a **different** box
      opened a door it assumed was walled.
      Still open: **ghostty**, the other tool that can switch on appearance. Its
      config used to read `theme = dark:nebelung,light:Catppuccin Latte` — i.e. it
      already followed macOS appearance and fell back to **stock** Catppuccin in
      light mode, so a Mac on light appearance never got the Nebelung palette. #108
      collapsed that to a single `theme = nebelung` decided by `theme.flavor`;
      bringing the split back with Nebelung on both sides is now a two-line change
      plus the same policy question (c) already answered, so it should reuse
      `followSystemAppearance`'s shape rather than invent `scheme` as a third axis.
      **Decide before building:** whether `scheme = "auto"` is a rice-wide option at
      all, or just the name for "every appearance-capable tool follows the system",
      which is what shipping it per-tool has quietly made it.
- [x] `theme.ports.enable` — **roster apps theme themselves, from metadata**
      (rice#136 + nebelung#17/#18/#19). Nebelung went 21 → 53 ports and now ships
      `ports.meta.json` describing each one: `dest`, `install`
      (copy 42 / paste 5 / merge 5 / compile 1), how the theme is *selected*, and a
      `tier`. The rice reads that and drops the theme file for any app in
      your roster it has a port for, in your flavor+contrast, on every rebuild.
      Why it matters beyond theming: **this is §5.6's `reachability` designation,
      shipped as data** — the option promises the *file*, not the *effect*, because
      the metadata knows Ghostty reads a config key we own while Xcode/Warp/OBS need
      one human click, and `haus doctor` lists exactly who is waiting on it. Ports
      whose install is a merge or needs a compile are **reported, never written**.
      Two lessons: a designation scheme is worth more when it lives with the thing
      it describes (nebelung, not the rice) than when the consumer maintains a table,
      and `theme.ports.handled` — rooms declaring what they already wire by hand,
      with an assertion that every id is a real port — is the pattern to copy for any
      future "generic pass plus hand-tuned exceptions" option.
- [x] ✅ **macOS's own Light/Dark — SHIPPED as `nebelhaus.theme.systemAppearance`
      (rice#257), and the spike falsified this box's own premise.** This box said
      the asymmetry was the problem: "turning dark mode on is one typed setting,
      turning it off means deleting a default." **Both halves are wrong on macOS
      26.6.** Measured 2026-08-08 on real hardware, with a Swift probe watching
      `NSApp.effectiveAppearance` *and* subscribed to
      `AppleInterfaceThemeChangedNotification`: `defaults write -g
      AppleInterfaceStyle Dark` from a light session changes nothing, `defaults
      delete -g AppleInterfaceStyle` from a dark one changes nothing, before AND
      after `activateSettings -u` and a `killall SystemUIServer`, and **not even
      for a process launched fresh afterwards** — no notification is posted
      either way. The key is a **mirror the appearance system writes on its way
      past, not a lever.** `system.defaults.NSGlobalDomain.AppleInterfaceStyle`
      is a dead option on this OS in *both* directions, so "there is no symmetric
      lever" was right by accident and for the wrong reason — there was no
      asymmetric one either.
      → The working lever is **System Events** (AppleScript): flips it live in
      ~0.3s, posts the notification so running apps repaint, and deletes/writes
      that same plist key on its way past — which is what made the plist look
      like the lever. So the option is applied from home-manager activation
      (same site and same guarded shape as `theme.wallpaper`'s osascript), not
      from `system.defaults`.
      → **`hausax` grew an `appearance` key** and is the oracle, exactly as §4's
      discipline demands: the effect is confirmed against AppKit, never by
      reading the plist back — which would report the inert write and call it
      applied. `haus diff` now flags a hand-declared `AppleInterfaceStyle` the
      way it flags `com.apple.Accessibility`, and says what macOS is *actually*
      showing.
      → **Phase 4 was the stated blocker and turned out not to be the enabler.**
      `restart-map.nix` gets a documented entry, but the honest content of that
      entry is "no restart can make an inert write live" — the map's four
      sentinels (`killall` / `activateSettings` / `none` / `logout`) have no
      value for *this* shape, because the map answers "what makes a write live"
      and here the answer is "nothing; don't write". Worth generalising: a
      restart map is the right table for keys macOS caches, and says nothing
      about keys macOS doesn't read.
      → **The default is `"unmanaged"`, deliberately, and that's the product
      call this box actually needed.** `"flavor"` (latte → Light, mocha → Dark)
      is the value that makes light mode complete; `"light"`/`"dark"` pin it.
      But a *managed default* would silently revert an appearance picked in
      System Settings on the next rebuild, which is a worse surprise than a
      half-light rice — so opting in stays explicit. This also answers the
      policy question (c) two boxes up from the other side: `flavor` still does
      not reach macOS on its own, so `{pounce,perch}.followSystemAppearance`
      keeps meaning "macOS's call" — until a host sets `systemAppearance =
      "flavor"`, at which point macOS's call is transitively the rice's and
      those two follow `flavor` after all. Documented in the option rather than
      prevented; it's the composition someone actually wants.
      → **Reachability caveat, same family as `increaseContrast`'s FDA one:**
      driving System Events needs an **Automation** grant for whichever app runs
      the rebuild. Refusal degrades to "the appearance didn't move" with a named
      warning, never an aborted activation.
      → Verified end-to-end, not inferred: the *generated* activation fragment
      was pulled out of the built `home-manager-generation/activate` and run
      verbatim on this machine — dark → light, a second run correctly skipping
      with "already light" (the guard that stops every rebuild re-posting the
      repaint), then restored to dark.
      → ✅ **And the §5.7 one-click path is closed too (rice#258).** The palette's
      "Switch to light mode" wrote `theme.flavor = latte` alone, i.e. exactly the
      half-done state this box exists to end. Fixed by making `haus set` take
      PAIRS — `haus set theme.flavor latte theme.systemAppearance flavor` — rather
      than by a managed default (rejected above) or two lines in the runner.
      **Why one call and not two:** `haus set` rebuilds per call, so two calls is
      two rebuilds *with the machine sitting in the half-done state in between*.
      It is all-or-nothing: every file is written before anything is validated and
      one rejection rolls all of them back, because validating pair-by-pair leaves
      pairs 1..n-1 applied when pair n is refused — the exact partial write the
      single-pair version's restore-on-failure existed to prevent. Generalisable
      beyond this option: **an "apply" step that costs a rebuild makes multi-key
      intents a transaction problem, not a loop.**
      → ★ **The pattern needs one condition, found the hard way (rice#255,
      2026-08-08).** A `handled` claim must be gated on the *same flag that does
      the wiring*. rice#251 made the gh-dash integration opt-in
      (`hearth.ghDash.enable`, default false) while claiming its port as handled
      unconditionally, so a machine with the integration off got **no theme**
      (the generic roster pass had been told to skip it) **and no `haus doctor`
      nudge** (doctor had been told a room handles it) — an opt-in feature turned
      into a silent hole in both systems at once. The general form: an exception
      list is a claim about the *current* configuration, not about the module,
      and the moment any part of a room becomes conditional its exceptions have
      to become conditional with it.
- [ ] `flavor = "custom"` + `theme.palette` — the "a community rice ships its own
      colours" half. Untouched: a rice can pick a flavor, not supply one. Note the
      **format** wrinkle before designing it — a data-only preset can hold an attrs
      of hexes fine, but nebelung renders ports in a derivation, so a custom palette
      either re-renders at rebuild time or is limited to the Nix-injected tools.
- [x] ✅ **Pair `contrast = "high"` with the OS lever — SHIPPED. This box's
      `- [ ] ✅` was itself drift wearing a tick**, which is a third shape §5.14
      should watch for: not an open box that shipped, not a closed claim that was
      falsified, but a box whose *marker and body disagree with each other*.
      The sweep proved `increaseContrast` (and `differentiateWithoutColor`) write
      *and take effect*, and neither is typed by nix-darwin, so they're reachable
      via `system.defaults.CustomUserPreferences."com.apple.universalaccess"` with
      no upstream change. Both are real options now —
      `nebelhaus.accessibility.increaseContrast` and `.differentiateWithoutColor` —
      and `presets/large-print.nix` sets the first, which is what makes that preset
      reach *native* apps and not only the tools nebelung themes. It degrades
      exactly as required: the palette half works for everyone, the OS half
      sharpens it where FDA is granted, and the option's own description carries
      the reachability caveat in prose (see §5.12 — that designation never became a
      typed field, and on this evidence probably shouldn't).

### 5.2 `nebelhaus.ui` — semantic scale tokens · M · risk M · ◐ **`scale` shipped, sizing pass done**
The missing abstraction. One set of tokens, fanned out with `mkDefault` into
every room, so a rice says "spacious" once instead of tuning nine numbers.

```nix
nebelhaus.ui = {
  scale = 1.35;            # 1.0 = today
  density = "spacious";    # compact | comfortable | spacious
  motion = "reduced";      # full | reduced | none
};
```

Fans out to: Dock icon size · Finder icon/sidebar size · Sill height/padding/
font/icon size · Pounce window width, row height, result count · Ghostty font
size + line height · zellij bar density · prowl gaps and borders · wallpaper
contrast.

- [x] Every consumer reads `ui.*` through `mkDefault` so a host can still pin one
      number — verified end to end while writing `large-print`: `ui.scale = 1.4`
      resolves `fonts.mono.size` to 27, and pinning the font size afterwards wins.
- [x] ✅ **The sizing pass is done — the fan-out is FIVE targets now** (pounce#53
      + rice#175): terminal font size, **the whole command palette**, **the menu
      bar's type**, Dock `tilesize`, prowl gaps. `density` and `motion` still
      don't exist.
      The palette was the higher-value of the two §5.2 gaps for exactly the reason
      this doc kept repeating — on a non-dev Mac it *is* how you launch things —
      and closing it took a seam in the app, not an option in the rice:
      **(a)** every size in pounce is now written for scale 1.0 and read through a
      `pt()` helper, so `"scale": 1.4` in `config.json` multiplies the launcher AND
      the emoji / clipboard / screenshots / camera / Find Files / cheatsheet / ⌘Tab
      panels together. `nebelhaus.pounce.scale` follows `ui.scale`, clamped into
      pounce's narrower 0.8–2.0 so `ui.scale = 2.5` yields a 2.0 palette rather
      than an eval error.
      **(b)** the rejected alternative is the part worth keeping: a `.scaleEffect`
      on the hosting view is one line and scales everything, but it rasterises then
      transforms — **soft text is the one thing a legibility feature must not
      ship**, so resolving sizes before layout was non-negotiable. Any future
      "make this tool bigger" faces the same fork.
      **(c)** `windowMode` became an option on the way (§5.9), which forced the
      distinction the surface was missing: *proportions* (compact vs default) and
      *size* are different questions, and one enum was answering neither well.
- [x] ★ **Finding: `ui.scale` and `displays.*.uiScale` MULTIPLY, and nothing said
      so.** They are documented as separate answers — one makes the *rice* bigger,
      one makes the *Mac* bigger — but `large-print` sets both, and a
      `larger-text` display leaves a **1147pt-wide desktop** while `ui.scale = 1.4`
      asks pounce's 820pt panels to draw at 1148. The window is then wider than the
      screen it is centred on. pounce#53 handles its own half (panel widths clamp
      to the visible frame; the launcher shows fewer rows when the scaled ones stop
      fitting), but the general lesson belongs here: **any option whose unit is
      "points" is silently coupled to `displays`, because a display mode changes
      what a point means.** Worth auditing `fonts.*.size` and prowl's gaps for the
      same interaction, and worth a line in whatever guide covers `large-print`.
      → ★ **Audited 2026-08-06, and the sentence above is aimed one layer off**
      ([`probes/scale-reach.nix`](probes/scale-reach.nix)). The surface holds
      **six numeric leaves in the 130 the options page renders — plus four
      internal `_roster`/`_launchers` mirrors that page never shows — and exactly
      one is in points**: `fonts.mono.size`. `ui.scale` and `pounce.scale` are multipliers,
      `roster.*.order` / `appStoreId` are an ordering and an id, and
      `sill.battery.hideOver` is a percent. **Prowl's gaps are not an option at
      all** — they, the Dock tile, the bar's type and pounce's panel widths are
      internal numbers computed from `ui.scale` inside a module. So the rule as
      written governs a set of size one.
      → ★ **And that one cannot clip *while prowl tiles it*.** A 27pt terminal
      font on a `larger-text` display buys fewer columns, never a window wider
      than the screen — read off the code rather than measured, and the
      precondition is the interesting part: a **floating** window (prowl's float
      rules, a `zscratch` throwaway) or a rice with `prowl.enable = false` has no
      such guarantee. That is §5.6's "what second key or precondition makes the
      first one a lie", arriving in a room that isn't macOS settings. The failure the coupling actually
      produces needs something that **sizes itself** in points, and the family has
      exactly three: **pounce** (fixed pt panels → clamped to the visible frame,
      pounce#53), **perch** (`screen.frame.width * 0.42`, clamped 360–640 — so
      coupled to the display *by construction*, and blind to `ui.scale` entirely:
      a large-print Mac gets a normal-sized shelf, which is a real if small gap),
      and **sill** (bounded by a band that is itself in points). The rule worth
      carrying is the narrow one: *a point-valued number only meets `displays`
      when something sizes itself from it* — tiled and OS-managed surfaces absorb
      the change.
      → ✅ **Fixed the same day, one PR before this pass's own #243 — nebelhaus#241
      + #242 (caught by the eighth pass's audit, §5.14's rule).** #241 added
      Finder's sidebar row and named perch as never-reached by `ui.scale`;
      #242 corrected #241's own first-guess fix — `displays.*.uiScale` doesn't
      move the shelf either, because a display's points shrink by exactly the
      factor that grows them, so the shelf holds its *physical* size while
      everything around it grows past it. Naming a lever that doesn't work was
      caught by the pre-PR assurance pass, one PR later than it should have
      been — the option's description and `presets/large-print.nix` now both
      say neither lever reaches perch, and why.
- ◐ Finder **sidebar** size follows `ui.scale` (`NSTableViewDefaultSizeMode`,
      rice#181); Finder **icon** size is still unwired. The same PR also gave the
      rice its Finder restart — `killall Finder` in postActivation — because
      Finder reads its domain once at launch and nix-darwin restarts only Dock.
      That's the first entry in §4's restart map, written by hand rather than as
      the map.
- [ ] `motion = "none"` is **ours to implement** — kill prowl's animations and
      Sill's transitions directly. The macOS reduce-motion knob is locked
      (§4), so there is nothing to delegate to.
- [ ] ~~`cursorScale`~~ **cut** — `mouseDriverCursorSize` is in the locked
      `universalaccess` domain. Cursor size is `haus doctor` checklist only.
- [x] ✅ **Sill: the type scales to a CEILING and stops — a different shape of
      answer, and the more interesting one.** Everything else here was a multiplier
      a tool was missing; the bar is not that. `sketchybarrc` pins `height=36` with
      28pt pills because the native menu bar auto-reveals on hover even while
      hidden and is only **32pt** on a notched display — den forces that reveal
      opaque so it covers the bar exactly, and that only works while the pills stay
      inside the band. So the bar's height is macOS's, not ours.
      **Measured before deciding, which is what settled it:** safe-area inset
      **32pt**, `NSStatusBar.thickness` **22pt**, menu-bar font **13pt**, and *none
      of the three is a preference*. There is **no menu-bar-size setting on macOS**
      — `NSStatusItemSpacing` / `NSStatusItemSelectionPadding` control spacing
      between items, not size. Display resolution is the only lever, exactly as
      §5.10 concluded for text.
      So: height fixed, type follows `ui.scale` to **1.25×** (the 17pt icon font at
      21pt, ~3.5pt clearance in a 28pt pill) and then silently stops. Chosen over
      "declare sill outside `ui.scale`" because a bar that quietly stops growing
      beats one that never grew — but the ceiling is stated in the option rather
      than discovered.
      Mechanically it was the cheap half: `sizes.sh` is the fourth generated
      fragment the rc sources (after `colors.sh` / `workspaces.sh` /
      `position.sh`), and all 16 font literals across the rc, the Nix-generated
      item blocks and four plugins now read `FS_*` from it — sizes are as
      single-sourced as colours. At `ui.scale = 1.0` the generated numbers are
      byte-identical to the tuned ones, so it's a no-op for anyone not scaling.
      **The general lesson:** when an option can't fully deliver, a stated ceiling
      is a better answer than either a broken multiplier or a refusal — but only
      if the limit is *measured*. The reason this took one pass instead of three is
      that the band was probed rather than reasoned about.
      → ✅ **And the ceiling is a check now (`scale-reach`, 2026-08-06):**
      `FS_ICON` reads `17.0 21.0 21.0 21.0` across four scales, so raising
      `lib/bar.nix`'s ceiling — or losing it in a refactor — fails with three sill
      rows flipping from `ceiling` to `moves`. A stated ceiling is only the better
      answer while it *is* one, and nothing errors the day it stops being.
- [x] ✅ **Honest scope line — and it's a GOLDEN TABLE now, `scale-reach`
      (2026-08-06).** The prose: this changes *nebelhaus's own* UI reliably and
      Dock/Finder sizes reliably. System-wide text size is reachable **only** via
      display mode (§5.10) — macOS 26's per-app `FontSizeCategory` is locked.
      The check is `accent-reach`'s shape applied to the other fan-out option,
      with one word added. Four evaluated systems — 1.0, 1.4 (large-print's) and
      **two past every ceiling** — classify each surface `moves` / `ceiling` /
      `pinned`, PARTIAL failing loudly:
      **(a) a ceiling needs its own verdict.** `accent-reach`'s three-way
      vocabulary reads "changes and then stops" as PARTIAL, and stopping is the
      deliberate answer here twice over — the bar's type at 1.25× (the menu-bar
      band) and pounce at its own 2.0 clamp. Two scales can't tell a ceiling from
      a multiplier at all; four can.
      **(b) the numeric rows print the NUMBER, not a verdict** — `19 27 48 57` is
      checkable by eye and "moves" is not (the same lesson `preset-composition`
      learned about printing a table's own subject). The clamp is legible as a
      value that repeats.
      **(c) the file rows are derived from the whole home-file set** with the
      pinned ones dropped, so a surface that *starts* following the scale appears
      as a new row rather than going unnoticed in a curated list — the failure
      `accent-reach`'s hand-listed surfaces still have.
      Mutation-checked both ways: raising `modules/lib/bar.nix`'s ceiling to 3.0
      flips three sill rows to `moves`; pinning pounce's default at 1.0 flips its
      two rows to `pinned`. Darwin-only, like `accent-reach` — it fingerprints a
      real evaluated system, so it fires on this machine or not at all.

### 5.3 `nebelhaus.fonts` · S · risk L
**Cheapest big win in the doc, and nobody has asked for it because it's
invisible until you try to change it.** JetBrains Mono Nerd Font is hardcoded in
[`den:125`](nebelhaus/modules/den/default.nix:125); Ghostty's size is hardcoded in hearth.

```nix
nebelhaus.fonts = {
  mono = { package = pkgs.nerd-fonts.jetbrains-mono; name = "JetBrainsMono Nerd Font"; size = 14; };
  sans = { name = "SF Pro"; };              # e.g. "Atkinson Hyperlegible" for large-print
  extraPackages = [ ];
};
```

- [x] Assert the mono font is a Nerd Font (or warn loudly) — starship/lsd/yazi tofu
      otherwise. Shipped as a warning when `name` is set without `package`.
- [x] `ui.scale` multiplies `fonts.*.size` by default
- [x] ✅ **The format limit is FIXED — rice#215 — and `sans` is a separate,
      still-open item.** The two were tangled in this box; they're not the same
      thing. The limit: `fonts.mono.package` takes a `types.package` and reaching
      `pkgs` is exactly what a data-only rice forbids (§3.3), so a shared rice
      could make the existing font bigger but never change the family — Atkinson
      Hyperlegible for a large-print machine, the example this section opens with,
      was unexpressible as a preset.
      → ★ **It was a property of the FORMAT, confirmed from a second family
      (2026-08-03):** `roster.*.package` is `types.package` too, so a pack could
      install from Homebrew and the App Store but never from Nixpkgs. Two families
      is where a workaround-per-option stops being cheaper than one fix.
      → **The fix (2026-08-04): name the package, don't evaluate it.**
      `packageName` takes an attribute path into nixpkgs as a string
      (`"nerd-fonts.fira-code"`, `"python3Packages.black"`), resolved by
      `modules/lib/pkg-by-name.nix`. The package-typed option stays — it's still
      the precise way to say it from a module that has `pkgs` — and setting both
      is *refused* rather than ranked, because one source written two ways with a
      silent winner is the failure mode this repo keeps re-finding.
      Four things worth carrying:
      **(a)** the injection question this box flagged has a boring answer: the
      resolver walks `pkgs` by attribute path and does nothing else — no `import`,
      no string that becomes code. The property the format sells is "you can read
      a rice and know what it does", and that survives. It was never "a rice can
      only install vetted software" — `cask` could always fetch anything, and
      naming a nixpkgs attribute is the same trust, not a new one. Worth stating
      in the README rather than leaving as a vibe.
      **(b)** the mechanical audit is **run, and it's a `jq` one-liner**: three
      package/derivation/path-typed leaves out of 128, of which the two package
      ones are now paired and the third (`hush.hooks`) is fine — `types.path`
      accepts `./thing` beside the rice file, which is still data. The thing this
      doc kept describing as an audit to schedule was ten seconds of work.
      **(c)** it's a CHECK now, exactly as this box asked: `data-only-surface` in
      `nix flake check` fails when a package-typed `nebelhaus.*` leaf has no string
      sibling named `<option>Name`. It reads the same evaluated option tree the
      docs render from — so it sees the public surface by construction — and it's
      pure lib, so it runs on Linux CI beside `keymap`/`theme-variants`.
      **(d)** ONE convention beat two names. `nixpkgs` would have fitted roster's
      source vocabulary (`cask`/`brew`/`appStoreId`) better than `packageName`,
      but the rule being enforced is a *format* rule, and a check can only enforce
      a rule that's uniform — `<option>Name` everywhere is what makes the next
      package-typed option a one-line fix instead of a design conversation.
- [x] ★ **The option reached ONE surface, and the bar drew in a different family
      — fixed 2026-08-06 (rice#243).** Measured the way §5.2's reach was: evaluate
      two rices differing only in `fonts.mono.name` and diff every file. Only
      Ghostty's config moved. sill named `"Hack Nerd Font"` in its rc, four
      plugins and six generated blocks, so **the stock rice already ran two type
      families**, and the example this section opens with — Atkinson Hyperlegible
      for a large-print machine — would have changed the terminal and left the bar
      in Hack. The fix is the one `sizes.sh` already demonstrated: `BAR_FONT`
      beside the `FS_*` sizes, every literal reading it, and sill no longer
      installing a font den doesn't. Three things worth carrying:
      **(a)** the family is taken **verbatim**, `Mono` suffix and all — deriving
      the propositional variant by trimming `" Mono"` would silently invent a
      family for any name outside Nerd Font's convention (`Berkeley Mono` →
      `"Berkeley"`), and inventing a font name fails as tofu rather than as an
      error;
      **(b)** an unset shell variable here is not a crash — a font string starting
      with `:` is one sketchybar accepts and draws as **nothing** — so the library
      that four plugins share sources the fragment itself rather than trusting its
      callers;
      **(c) ★** and the check needed a row no evaluation could produce: see §5.14.
- [ ] `sans` still doesn't exist (only `fonts.mono` does). Nothing blocks it now
      that naming a package is possible; it's just unbuilt — and after rice#243
      the question it has to answer first is *which surface would read it*, since
      every surface the rice draws now takes the mono family on purpose (the bar
      mixes Nerd Font icon glyphs into its labels).

### 5.4 registry v2 — install sources + a real workspace model · M · risk M · ✅ **(a) shipped as `roster` (rice#182), (b) shipped (nebelhaus#253)**
The registry is good. Two concrete gaps — and the halves came apart: the install
sources shipped without the workspace model, which is the right order (one is
additive, the other is the schema migration).

**(a) `cask` is the only install source.** ✅ **Shipped, differently than sketched.**
rice#182 renamed `nebelhaus.apps` → **`nebelhaus.roster`** and gave each entry
four parallel nullable source fields — `cask`, `brew`, `package` (+ `scope`),
`appStoreId` — rather than the tagged union proposed here:

```nix
install = { source = "homebrew-cask"; package = "obsidian"; };  # NOT what shipped
```

Worth recording *why* the tagged union lost, because the reasoning generalises:
a discriminated `{ source; package; }` reads better in a doc but is worse to
**merge**, and merging is what a registry is for. Parallel nullable fields let
two modules contribute to the same entry (one names the cask, another sets the
workspace) under the module system's ordinary merge, while a tagged union makes
every contributor restate the discriminator and turns a partial contribution
into a type error. `installedBy` came along for the same reason — an entry needs
to say *who* put it there once the rice itself ships bundles.

**Update 2026-08-04 (rice#215): a fifth field, `packageName`,** which is the same
Nixpkgs source named as a string rather than evaluated — the one an app pack can
actually write (§5.3). It resolves into `package` before any check reads the
entry, deliberately: multi-source detection, the empty-entry warning and the
install path all see one field and never learn which way it arrived, so the
pack-authored half is not a second code path. Only the both-set assertion reads
the raw entries, because after resolution the two would look like agreement.

Still not shipped from this sketch: the `flake` / `pwa` / `manual` sources. `mas`
did land, gated behind `nebelhaus.appStore.install` — off by default, because it
reaches the network and acts on your Apple Account, and `mas` can neither sign in
nor buy a paid app, so it can never be complete.

**(b) `workspace` is a *field on an app*, which bakes "one app per workspace"
into the schema itself.** Role workspaces ("communication" = Mail + Slack +
Messages) and project workspaces are literally unrepresentable. Invert it:

```nix
nebelhaus.workspaces.comms = {
  key = "c"; icon = ":slack:"; monitor = "main"; layout = "tiles";
  apps = [ "slack" "mail" "messages" ];
};
```
…with `roster.<id>.workspace` kept as sugar that desugars into the above, so
existing hosts don't break.

**Update 2026-08-07 (nebelhaus#253): shipped, and NOT the way the sketch above
proposed.** Julien is the only consumer of this rice — he asked explicitly for a
clean rename over a back-compat alias, so `roster.*.workspace` and
`roster.*.barIcon` are **gone**, not deprecated. What shipped is otherwise the
sketch's inversion: `nebelhaus.workspaces.<id>` owns `key`, `icon` and `apps`
(the roster ids that live there); prowl and sill resolve an app's workspace
through a new internal `nebelhaus._appWorkspace` lookup (roster id → workspace
id) rather than reading a field off the app. `monitor` / `layout` from the
sketch did **not** ship — nothing in this pass needed them, and per-workspace
monitor pinning would mean bridging AeroSpace's monitor-pattern matching
against `nebelhaus.displays`' own UUID vocabulary, a separate feature with its
own risk. Left for whoever needs it.

The workspace-throw key moved off the app too: `shift-<key>` used to throw to
*the app's own* workspace, which stops meaning anything once a workspace can
hold several apps. It's `shift-<workspace's-own-key>` now — a NEW binding
namespace, not a renamed one, with its own collision assertions (two
workspaces claiming one key; a workspace key colliding with the fixed
numbered-workspace `⇧` throws). Plain `<key>` stays exactly what it always
was: a roster app's launch letter, never a workspace's.

Also finished the second, previously-unstarted box: `nebelhaus.roster.*.float`
(+ optional `titleRegex`, scoped to AeroSpace's `window-title-regex-substring`)
generalises the "float" half of window rules — the shape the three
hand-hardcoded `aerospace.toml` rules (FaceTime, Flick, Ghostty) were asking to
become. FaceTime and Flick are now ordinary `float = true` roster entries
(`modules/prowl/default.nix`); Ghostty's rule stays hand-written on purpose —
it's genuinely bespoke (assign-once-at-startup vs. float-always-at-runtime),
racing the same AX-title-lands-late problem `titleRegex`'s own docs warn about,
so generating it would just move the bespoke-ness into the generator.

**`center` and `sticky` did not ship, and it's not a scope cut — verified
against AeroSpace's own docs first.** No command exists to position or resize
a floating window's geometry at all (nothing to hang `center` on), and
sticky/pin-across-every-workspace has no primitive either — the upstream docs'
own words are "not yet supported." Closing this the way the doc's own ground-
truth rule asks: a checked box that says "verified infeasible, here's the
citation" beats an unchecked one that looks like nobody got to it.

**A real gap this surfaced, not designed in: a pack can't claim a workspace.**
`checkPack` only lets a pack set `nebelhaus.roster` (packs/README.md), and
`lib.pack` only lowers *that* option's priority on the way into a consumer.
`packs/writing.nix` can no longer give Obsidian or Zotero a workspace itself —
its README now tells the consumer to add the two-line `nebelhaus.workspaces`
entry by hand. Extending `checkPack`/`lib.pack` to carry `nebelhaus.workspaces`
through too — with `apps` needing list-merge semantics where every other field
wants `mkDefault`, per that option's own docs — is follow-up work, not done
here.

**Measured, not assumed:** a full build of the real `mbp` host (this machine)
against nebelhaus#253's branch, `--override-input`'d in for `nebelhaus`,
finished with **zero warnings** (`nix eval
.#darwinConfigurations.mbp.config.warnings` → `[]`) — every one of the seven
migrated single-app workspaces (`N`/`R`/`S`/`H`/`C`/`D`/`X`) still resolves.
The generated `aerospace.toml` (persistent-workspaces, the `shift-<key>`
throws, the `[[on-window-detected]]` auto-assign + float blocks) and
`sketchybar/workspaces.sh` (pill icons, launcher keys) were read back and
checked line-for-line against pre-migration output: byte-for-byte the same
behavior for every existing app. `nix flake check --all-systems` — `presets`,
`packs`, `data-only-surface`, `preset-composition`, `keymap`, `theme-variants`,
`accent-reach`, `font-reach`, `scale-reach` — all green. The five new
assertions (duplicate workspace keys, a workspace key colliding with a
numbered workspace's throw, one roster app named in two workspaces, `float`
with no `appId`, an unknown app id in `apps`) were each exercised by hand
during the eval, not just written and trusted.

The consumer half of the migration (`~/.config/nix`'s `hosts/mbp/default.nix`)
is a **paired, currently-draft PR** (nix-config#45) — it can't bump
`flake.lock`'s `nebelhaus` input until nebelhaus#253 actually merges (a lock
bump computed against an unmerged rev pins nothing real), so it's blocked
rather than red. Same shape every breaking rename here takes: the lock bump
and the config edit that depends on it land together, in one PR, once there's
a real merged rev to point at — never split across the merge boundary.

`holt` currently fails to build from the workshop's own main checkout
independent of any of this (`sdk/go`'s nested `go.mod` collides with the root
module under `buildGoModule` — reproduced building `holt` alone, zero
nebelhaus involvement) — worked around for verification by overriding
`nebelhaus/holt` to a pre-SDK rev. Not this pass's bug to fix; flagging it
here so it isn't mistaken for fallout of this migration.

- [x] Multi-source install — shipped as `roster`'s parallel source fields, not a
      tagged union (see above)
- [x] First-class `workspaces` — shipped nebelhaus#253, **no** back-compat
      alias (single-user rice, clean rename per instruction — see above).
      **§5.4 is now fully checked off.**
- [x] Window rules beyond assignment — shipped nebelhaus#253 as `float` +
      `titleRegex`. `center` and `sticky` are verified-infeasible against
      AeroSpace itself (see above), not shipped, and that's the closed state
      for both — there's no upstream primitive to build them on.
- ◐ Non-app installables the registry can't express: fonts, browser extensions,
      Quick Look / Finder / Share extensions, printers, network shares, VSTs.
      **Two of the five have answers now and NEITHER went into the registry:**
      fonts are `fonts.mono.packageName` (rice#215) and browser extensions are
      `nebelhaus.zen.extensions` (rice#211), each its own surface.
      ★ That's three losses in a row for the instinct behind this bullet — the
      third being §5.9's command metadata, which landed in nebelung's
      `ports.meta.json` rather than a rice-side table. **The registry is for
      apps.** Read this line as "each of these will get its own room", not "the
      roster must grow to swallow them" — and note that both answers were
      *cheaper* than the schema migration would have been, which is the argument.

### 5.5 `nebelhaus.keys` — the keymap is currently closed · M · risk M · ✅ **shipped (nebelhaus#108)**
Caps-Lock leader, ⌘Space, and every zellij bind are generated or baked. This
single-handedly makes **mouse-first**, **one-handed**, and **non-QWERTY /
international layout** rices impossible — a real accessibility *and*
internationalization gap the earlier brainstorm didn't name.

```nix
nebelhaus.keys = {
  leader = "caps";           # caps | hyper | none  (none = mouse-first rice)
  palette = "cmd-space";     # or "none" to keep Spotlight
  windowNav = "alt";         # the modifier vocabulary, not individual binds
  bindings = { };            # per-action overrides
};
```

- [x] `keys.{leader,palette,windowNav}` shipped, resolved once in
      `modules/lib/keys.nix`, with `"none"` a real value on all three. `windowNav`
      is a **modifier vocabulary** rather than a bind-per-action: what people need
      to move is the modifier, not the letters, and one value moves all fifteen main-mode
      chords plus service-mode entry. `bindings` (per-action overrides) is still
      open — it needs an action vocabulary first, and none of the motivating cases
      needed it.
      **Update 2026-07-30: half that vocabulary now exists, from pounce.** pounce#43
      addresses every palette row by its frecency key — `cmd:emoji`,
      `app:/Applications/Ghostty.app`, `mode:clipboard` — and takes per-item
      `alias` / `hotkey` / `enabled`, with `hotkey` accepting **leader sequences**
      (`"opt+space e"`: whitespace separates steps, `+` separates modifiers, the
      Emacs/VS Code notation). So `bindings` should be designed as *two* namespaces,
      not one: pounce items already have stable ids, prowl actions still don't.
      Three constraints that came with it and would otherwise be discovered late:
      a second step is registered as an ordinary modifier-less global hotkey for
      ~2s rather than a CGEventTap, so **sequences need no Accessibility grant**
      (worth preserving — it's why the palette key needs none either);
      `enabled = false` hides a row but does **not** disarm its hotkey, so an option
      that means "turn this off" has to say which of the two it does; and
      `pounce run <item-key>` exists as the escape hatch for keys another tool
      already owns, which is the honest answer for a rice whose leader is `"none"`.
- [ ] ~~Split `prowl.enable` into `prowl.tiling.enable` / `prowl.launcher.enable` /
      `prowl.capsRemap.enable`~~ — **superseded, not done.** `keys.leader = "none"`
      is capsRemap-off + launcher-off and `keys.windowNav = "none"` is
      tiling-chords-off, which covers every case that motivated the split, from the
      keymap side rather than by multiplying room switches. Revisit only if someone
      wants AeroSpace to *stop tiling* while keeping its launcher.
- [x] Assertion on duplicate leader letters *and* cross-room conflicts. The
      cross-room one was the real gap: `keys.leader` is prowl's AeroSpace chord and
      `keys.palette` is pounce's in-process hotkey, so **nothing compared them** and
      a clash is silent — whoever registers first wins. `leader = "alt-space"` with
      `palette = "alt-space"` is the reachable case; asserted, and pinned in
      `nix flake check`'s new `keymap` golden table.
- [x] Ship the generated cheatsheet from the same data — the modifier was the LAST
      part of a `wm-bindings.nix` row still written twice ("⌥ hjkl" as a caption
      beside `alt-h` as a chord, in a table whose entire purpose is that those can't
      drift). Both now come from the resolved keymap, and `"none"` empties the
      cheatsheet page along with the bindings so it never advertises an unbound key.
      The first-run tour's prompts follow too, via the generated `tour_config.sh`.
- [x] A binding was **retired** rather than rebound, and the surface handled it
      (rice#210): ⌥⇥ workspace back-and-forth is gone, because pounce's ⌘⇥
      switcher answers the same question better (its rows carry the window's
      AeroSpace workspace, so it crosses workspaces on its own) and the
      single-previous-workspace pointer was what stranded you on a space you'd
      just emptied. Left deliberately **unbound**, not refilled. Relevant here
      only because it's the first removal since the keymap became generated: the
      cheatsheet, the tour prompts and the docs all followed from the data with
      nothing to hand-edit, which is what §5.5's last box was for.
- [ ] **Non-QWERTY is addressed but not TESTED.** `windowNav = "ctrl-alt"` exists
      precisely because ⌥+letter types accented characters on many layouts, but
      nobody has run the rice on such a layout. The launch-mode LETTERS
      (`roster.*.key`) are still assumed to be where QWERTY puts them, which is the
      next thing an international rice would hit.
- [x] ★ **`everyday`'s tour — this box was wrong in BOTH directions, now closed
      (rice#220).** It said the tour *hangs* at step 1 when `prowl.enable = false`.
      It doesn't: #156's `tourWired` gates the pill on prowl-or-authored-steps, so
      nothing hangs. What it did instead was draw **nothing at all** — the
      generated `tour_item.sh` was its header comment and no item — while
      `everyday` still set `tour.enable = true` and its own comment block explained
      at length why a first-run tutor was right for exactly that person. **A preset
      asking for a tutor and shipping none, silently.** (Measured both ways:
      `everyday`'s generated `tour_item.sh` before and after.)
      ★ **The transferable finding is the shape: a "can't work here" that degrades
      to silence still reads as a broken option.** §5.6 states this rule for
      *macOS* settings — look for the second key or precondition that makes the
      first one a lie — and it binds the rice's own options just as hard. A
      degrade path needs a destination, not just an exit.
      Closed from the data side, which made `everyday` the **first customer of
      §5.13's own community-tour mechanism** — shipped six days earlier, and nobody
      noticed the rice's own preset was the case it fixed.
      → **Second-order finding, and it generalises past tours:** an authored hint
      is a literal string, so a community tour could not name the keys the machine
      resolved. The built-in lap interpolates `$TOUR_PALETTE`; an authored one
      could only hardcode "⌘ Space" — wrong on any rice that moved `keys.palette`,
      and wrong *invisibly*, because the author never sees the consumer's bar.
      §5.13 called "the community file remains data-only" a virtue; the cost of
      data-only is that **data cannot interpolate**. Fixed with placeholders
      (`{palette}` / `{leader}` / `{leaderName}`, expanded at render time from
      values `tour_config.sh` already carried) plus an eval warning for unknown
      ones — verified by rendering a rice that imports `everyday` and moves
      `keys.palette`, which now teaches ⌥ Space. **Any future option taking
      authored user-facing TEXT needs the same seam.**
      (#108's warning for `tour.enable` + `keys.leader = "none"` still stands.)

### 5.6 Curate macOS settings into behaviour groups · M · risk M · ◐ **five of nine groups shipped or part-shipped; every row is now spiked (Sound/Locale/Power, 2026-08-08). Four rows remain unbuilt: Windows (logout-only, by choice) plus Sound, Locale and Power — Sound needs nothing new, Locale is gated on a `notify` verb, Power belongs in a `pmset` activation step**
Do **not** mirror every nix-darwin default into `nebelhaus.*`; `system.defaults`
stays the escape hatch. Curate the groups where a *rice* has an opinion:

| Group | Notable gaps today |
|---|---|
| **Hot corners** | ✅ **`nebelhaus.hotCorners.*` — rice#198.** Action by name, not the integer macOS stores |
| **Screenshots** | ✅ **`nebelhaus.screenshots.*` — rice#198.** Folder, format, shadow, thumbnail, date |
| **Lock / login / screensaver** | ◐ **`nebelhaus.lock.*` — rice#250.** The LOCK half only (`requirePassword`, `requirePasswordDelay`, `com.apple.screensaver`). The LOGIN half (guest account, login window text) is `com.apple.loginwindow` — read once at boot, no live-reload path, and killing `loginwindow` to force one would end the current session — so it stays out until this group has an honest way to say "takes effect at next login" instead of shipping a setting that silently doesn't apply. |
| **Menu bar & Control Center** | ✅ **`nebelhaus.menuBar.{clock,controlCenter}.*` — rice#250.** Clock format/seconds/date/day-of-week/analog (`com.apple.menuExtraClock`, restarts `SystemUIServer`) + which Control Center glyphs show (battery %, sound, bluetooth, AirDrop, display, Focus, Now Playing — `com.apple.controlcenter`, restarts `ControlCenter`, a whitelisted process since rice#249 that nothing had written into until now) |
| **Sound** | ◻️ **spiked 2026-08-08, buildable — nothing blocking it.** Two keys ARE typed (`com.apple.sound.beep.{volume,feedback}`); alert sound + UI sounds route through `CustomUserPreferences`; the startup chime is `nvram`, not a plist. Writes are live, need no restart and no FDA. The trap: the volume leaf is `e^(slider − 1)`, so `0.5` is 31% — curate 0–100 and convert. Also a two-writers key (the volume keys write it back) |
| **Locale / input sources** | ◻️ **spiked 2026-08-08, buildable once restart-map learns `notify`.** Four typed keys (`AppleICUForce24HourTime`, `AppleMetricUnits`, `AppleTemperatureUnit`, and the inert `AppleMeasurementUnits`); `AppleLocale`/`AppleLanguages`/input sources via `CustomUserPreferences`. **Blocker: a running app only sees the change if `AppleDatePreferencesChangedNotification` is posted** — the first family whose "restart" is a notification. UI language remains relaunch-only |
| **Power** | ⚠️ **spiked 2026-08-08 — typed after all, and the typed path writes the wrong power source.** Six typed options (`power.sleep.*`, `power.restartAfter*`) that shell out to `systemsetup` in nix-darwin's own activation script, `security.firewall`-style. They work — but no verb takes a power source, and measured on 26.6.1, `-setcomputersleep 17` run **on battery** wrote the **AC** profile and left battery alone. So the option configures a source the config never named; `pmset -b`/`-c` does as told. Every call also ends in `&> /dev/null`, over a stderr that carries a real `-99`. **Build this group on `pmset`**, and file the asymmetry upstream. Low Power Mode / lid / per-source are `pmset`, root-only, untyped |
| **Security posture** | ◐ **`nebelhaus.security.firewall.*` — rice#250.** The firewall half (`networking.applicationFirewall`, a *different* mechanism entirely — nix-darwin runs `socketfilterfw` directly in its own activation script, no plist, no restart-map entry needed, no logout). Guest user and remote login are not built: guest user is the same `loginwindow` domain `lock` deferred above, and remote login has no nix-darwin option at all. |
| **Windows** | Stage Manager, native tiling, edge drag (must interlock with prowl) — `com.apple.WindowManager`, declared `"logout"` in restart-map.nix (rice#249), no live-reload path exists on macOS 26. Deliberately not built this pass: this is exactly the "curated group whose setting silently needs a logout" this section exists to avoid, and unlike `lock`/`loginwindow` there's no smaller live-effect half to ship instead — the whole domain is logout-only. |

The first two shipped settled the group's **default policy**, which was the real
open question and is worth stating once for every group after it: every leaf
defaults to **null = write nothing**, and null is deliberately not the same as
"off". Hot corners made that concrete — the machine this was developed on had
three corners already set by hand, so a rice naming a corner it didn't care about
would have erased one silently. A curated setting group is a place to make an
opinion *available*, not to impose one; a preset is where an opinion belongs.
`lock`/`menuBar`/`security.firewall` (2026-08-07) inherit the same policy without
re-deriving it.

They also each turned up one silent failure that reads as "the option doesn't
work", which is the failure mode this whole section exists to avoid:

- **A corner's MODIFIER is a separate key** (`wvous-*-modifier`) that nix-darwin
  doesn't type, so a corner the rice declares inherits whatever modifier the
  machine already had — correct corner, nothing happens, and you aren't holding
  the key nobody mentioned. Setting a corner now clears it.
- **`screencapture.location` is stored verbatim and the folder is not created.**
  No `~` expansion, and a missing directory makes screencapture fall back to the
  Desktop without a word — indistinguishable from the write being ignored.

Generalising: for each remaining group, the thing to look for is not "is the key
typed" but **"what second key or precondition makes the first one a lie"**. Both
of these cost one probe to find and would have cost a bug report to discover.

**What the third pass (`lock`/`menuBar`/`security.firewall`) added, and what it
deliberately didn't.** Unlike hot corners and screenshots, neither `lock` nor
`menuBar` has an NSWorkspace-style effective-state probe available — there's no
cheap oracle for "did the menu bar clock actually re-render" the way
`reduceMotion` has one. Both rest on nix-darwin's own restart precedent
(Finder/Dock: killall re-reads the domain at launch) rather than a spike on this
machine, and modules/lib/restart-map.nix says so in a comment rather than
claiming `support = "tested-macos-26"` for something that isn't. `security.firewall`
is the one exception worth trusting more: it isn't a plist write at all, it's
nix-darwin calling `socketfilterfw` directly in its own activation script, so
none of the restart-map machinery — or its risk — applies to it.
**Deferred on purpose, not forgotten:** the LOGIN half of "Lock / login /
screensaver" (`com.apple.loginwindow` — guest account, login window text) and
all of **Windows** (`com.apple.WindowManager`) are both logout-only per the §4
matrix and modules/lib/restart-map.nix, which is precisely the shape this
section's own guardrail rules out — a group that silently needs a logout is
worse than no group. **Sound**, **Locale/input sources** and **Power** were
deferred for the opposite reason: no domain for them had been spiked for effect
at all, typed or not, so building on top of them would be a guess wearing this
document's own "verified, not remembered" language.

★ **That deferral has since been closed, and its premise was false** (sixteenth
pass, 2026-08-08). All three groups do have typed nix-darwin surfaces — Sound
two keys, Locale four, Power six — so the sentence above was itself an
unverified claim, in a section whose whole subject is unverified claims. The
generalisation, and the reason it is written here rather than only in the status
log: **a deferral needs its premise checked as hard as a shipped option does.**
The check was one `grep mkOption` over `modules/system/defaults/*.nix` and
`modules/power/`.

- [ ] Confirm `lock`/`menuBar` by eye — set a value, `bench try switch`, and see
  it happen without a restart. This is the same class of open box as the
  matrix's `mouseDriverCursorSize`/`closeViewScrollWheelToggle` rows: wired and
  plausible, not yet watched.
- [ ] Give the login half of "Lock / login / screensaver" and Windows an honest
  way to say "takes effect at next login" (the way `nebelhaus.accessibility`
  says "needs Full Disk Access") — that's what unblocks building them, not a
  fix to the domain itself, since neither has a live-reload path on macOS 26.
- [x] Spike Sound, Locale/input sources and Power the way §4 spiked
      universalaccess/dock/finder/etc — **done 2026-08-08**, three probes on the
      shelf (`notes/probes/{sound,locale,power}-sweep.sh`) plus two oracles
      (`locale-effective.swift`, `tis-toggle.swift`), results in
      [`macos-settings-matrix.md`](./macos-settings-matrix.md#sound--localeinput-sources--power--swept-2026-08-08).
      All three are reachable. One row is honestly open: the `systemsetup` write
      test needs root (Touch ID), so `power.sleep.*` is *unverified on 26*
      rather than proven.
- [ ] Teach `modules/lib/restart-map.nix` a third verb — **`notify`**, a
      distributed notification post — before building the Locale group. It is
      the whole difference between a locale setting that lands today and one
      that lands at next login, and neither `killall` nor `logout` can express
      it. `AppleDatePreferencesChangedNotification` is the name; a bogus name
      does nothing, so it must be the real one.
- [ ] Build **Sound** first of the three — it is fully settled and needs nothing
      new: live writes, no FDA, no restart. Curate `alertVolume` as 0–100 with
      the `e^(p−1)` conversion in the module (never the raw float); make
      `alertSound` an enum over `/System/Library/Sounds` (or validate the path
      at eval time — a bad path is silence, not a fallback); and decide the
      two-writers question the way §5.7 decided it for `haus set`.
- [ ] Build **Power** as an activation step of the rice's own (`pmset`, per
      power source), not as a `system.defaults` group and **not** on top of
      `power.sleep.*` — those six typed options cannot say "battery", cannot
      report a failure, and on 26.6.1 the one that was tested did not apply at
      all (exit 0, a confirmation line, an internal `-99`, nothing moved).
- [x] Cross setting × caller with a live oracle — **done, run 4.** Every write
      lands; `systemsetup` writes one profile (AC) and `pmset` writes the one
      you name. Runs 1–3 were reading a stale plist.
- [ ] File upstream against `LnL7/nix-darwin`: `power.sleep.*` writes only one
      power profile on macOS 26 — `-setcomputersleep` moved AC while the machine
      was on battery — and `system.activationScripts.power` discards the stderr
      that would show it. `notes/probes/power-sweep.sh` is the reproducer.

Each entry carries metadata from the §4 matrix:

```nix
{ domain = "com.apple.finder"; key = "FXDefaultSearchScope"; value = "SCcf";
  restart = [ "Finder" ]; support = "tested-macos-26"; risk = "low"; }
```

### 5.7 `haus set` + a machine-writable settings overlay · ✅ **shipped** · M · risk M
**The mechanism that makes a non-technical rice possible**, and it's a small
generalization of something that already ships.

`hosts/<host>/packages/*.nix` is already auto-imported and already written by a
pounce command. Extend that to a general `hosts/<host>/settings/*.nix`, and:

**Prior art arrived from pounce while this waited — pounce#54.** `pounce config
init` writes `~/.config/pounce/config.json` with **every** setting present at its
default and commented out, AeroSpace-style: you learn the surface by reading your
own config and make it minimal by deleting lines. Three details that transfer
directly to `haus set`, all of them non-obvious:
**(a)** each entry reads its default off a live settings object rather than a
written-down table, because *a confident wrong number in a file that looks
authoritative* is the one drift a template makes worse than no template;
**(b)** it refuses outright when the target is a symlink into the Nix store —
under the rice that file is generated from `nebelhaus.pounce.*`, so a copy
written beside it would be silently reverted by the next rebuild. `haus set`
faces the identical two-writers question from the other side;
**(c)** every commented line carries its own trailing comma (the config is read
as JSONC now), so *any subset* can be uncommented without fixing punctuation —
otherwise the file's promise breaks on your second edit.

★ **The rice shipped the reading half first — rice#184 — which split this item
in two before #252 closed it.** A fresh
install now gets `hosts/<host>/options.nix` beside its host file: every settable
option at its default, with description, type and docs anchor, all commented
out, rendered from the same `options.json` nebelhaus.com and the agent skill are
rendered from, and refreshed by `haus options` after `haus update`. Two
independent repos reached the same shape within days of each other, which is
about as strong a signal as this document gets that the shape is right.

**A third instance landed 2026-08-04, from the other direction:** the rice now
generates `~/.config/holt/config.toml` from `nebelhaus.agents.default`, because a
zellij server or a launchd daemon outlives the environment that started it, so
`holt new` has to resolve a file rather than inherit a stale selection. Holt owns
that file when installed standalone — so this is the same two-writers question as
(b), answered the third way: the rice writes it, and the file's first line says
*edit that option, not here*. Three instances now (pounce's `config init`, the
host's `options.nix`, holt's config), and the pattern across all of them is that
**whoever generates the file has to say so IN the file** — the store symlink only
protects the cases where Nix is the writer.

But note what that means for the goal: §5.7 framed it as *writing* config from
the palette, and what arrived first was being able to *read* the surface out of
your own file. **"Configure without opening the docs" and "configure without
opening an editor" are different bars.** At that point only the first was met;
`haus set` was still exactly what the palette-as-settings-app needed. Rice#252
now meets the second with the ordinary-Nix overlay described in the twelfth-pass
status above.

⚠️ **Where this touched a live bug — and the lesson is about corrections, not
templates.** The one deliberate departure from AeroSpace is that every line is
commented out; rice#184 justified that as "your host file is applied AFTER any
preset, so a file stating every default would silently beat it". That is the
model rice#203 refuted (§6's limit 3): it's a **conflict**, not a silent win.
The conclusion survives — for two *better* reasons, both now stated in the
file: it would collide with every preset, and a plain restatement outranks the
rice's own `mkDefault`s permanently, so a later rice that retunes a default
could never reach you. Corrected in rice#220, along with `bootstrap.sh` and one
surviving sentence at the bottom of the very `presets/README.md` that #203 fixed
at the top. **A refuted model outlives its correction wherever the correction
was scoped to the files that prompted it — grep for the claim, not for the
file.** The worst copy was the header written into *every user's* host file.

- [x] `haus set theme.accent teal` → writes one small ordinary Nix file → rebuild
- [x] `haus get` / `haus unset` / `haus reset <path>`
- [x] Pounce commands wrapping it: **"Make text bigger"**, "Switch to light mode",
      "High contrast on" — the palette becomes the settings app
- [x] Guard: only `nebelhaus.*` paths are settable this way (same boundary as §3.3)

This is what lets someone use a nebelhaus rice for a year without ever opening
a text editor — the actual bar for "a Mac for my parents".

### 5.8 Generalize `hush` into scenes · M · risk M
`hush` is already a scene with one member: it has hooks, an external
integration (Slack), a bar pill, a CLI, and transient state. Generalize rather
than invent:

```nix
nebelhaus.scenes.recording = {
  dnd = true; preventSleep = true;
  audio.input = "Studio Mic";
  apps.open = [ "OBS" ];
  hooks = [ ./key-light-on.sh ];
  restorePreviousState = true;
};
```
with `hush` shipped as the built-in `quiet` scene (keep `nebelhaus.hush.*` as
an alias so no host breaks).

Good scenes: meeting · recording · presentation · reading · travel · docked ·
deep-work · away. Triggers worth having: Pounce command, time, Wi-Fi SSID,
power source, display attach.

- [ ] Only build the trigger engine *after* one hand-written scene proves useful —
      the declarative half is cheap, the trigger daemon is not

### 5.9 Open up Sill widgets and Pounce commands · M · risk M · ◐ **pounce's half done**
`sill.items` is a closed submodule of 15 bools (13 when this was written — it
grows by one every time a pill lands, which is the argument this box makes).
Pounce commands were
script-discovery only with **no Nix option at all**; as of pounce#43 the
*app* has the schema and the **rice** is what's missing — which flips this item
from "design a surface" to "generate a file", the cheapest it will ever be.

```nix
nebelhaus.sill.widgets.backup = {
  command = ./backup-status.sh; interval = 300;
  icon = "󰁯"; placement = "right"; permissions = [ "full-disk-access" ];
};

nebelhaus.pounce.commands.callAnna = {
  name = "Call Anna"; run = "open facetime://+15550100";
  mutates = false; needsConfirm = false;
};
nebelhaus.pounce.packs = [ "everyday" "people" ];   # vs the dev pack
```

Non-dev widget ideas the current set has no room for: Time Machine health ·
mic/camera-in-use · VPN state · Bluetooth device battery · next reminder ·
break timer · storage pressure · NAS reachability · world clocks.

- [ ] `sill.items` becomes sugar over `sill.widgets` (bundled widgets pre-declared)
- [x] ✅ **Pounce's window sizing is an option now** (pounce#53 + rice#175).
      `windowMode` had been written straight into `config.json` with no option at
      all; it is `nebelhaus.pounce.windowMode` now, and it gained a sibling —
      `nebelhaus.pounce.scale`, following `ui.scale` — because writing the option
      exposed that one enum was answering two questions. `windowMode` is the
      layout's *proportions*; `scale` is how big it's drawn; they compose. See
      §5.2 for the app-side seam that made the second one possible.
- [x] **pounce side: `config.json` grew an `items` map** (pounce#43), keyed by the
      frecency key so commands, apps and built-in modes share **one address space**
      (`cmd:` / `app:` / `mode:`), each taking `enabled` / `alias` / `hotkey`. The
      design fork recorded there was *one schema now* vs *a key per stage*, resolved
      to one **because these ripple into `nebelhaus/modules/pounce` either way** —
      i.e. the rice-side option was a known consequence, not an afterthought.
- [x] ✅ **rice side shipped — rice#149.** `nebelhaus.pounce.items` generates that
      map, keyed by the same `cmd:`/`app:`/`mode:` addresses, with `listed` /
      `alias` / `caption` / `hotkey` per row. (This box sat unticked for four
      days while the status block above already credited #149 — see §5.14.)
      Three things about the shipped shape worth carrying:
      **(a)** the option is named `listed`, not `enable`, precisely because of the
      asymmetry this box predicted: pounce's `enabled = false` removes the ROW and
      leaves the hotkey armed. Naming it `listed` makes the option say what it
      does instead of documenting a surprise underneath a misleading name — the
      cheaper of the two ways to handle a leaky abstraction.
      **(b)** it validates at **eval** time what fails **silently** at runtime: a
      key that names no real item shape (a `mode:` typo binds nothing at all),
      and a chord already claimed by `keys.palette` or `keys.leader` (whoever
      registers first wins, and it isn't always the same one). What it cannot
      check is whether `cmd:<id>` names a command that exists, because command
      scripts are discovered at runtime — so that half stayed pounce's job.
      **(c)** the rice generates the WHOLE map and never round-trips: on the rice
      `config.json` is a `/nix/store` symlink so Nix is the only writer, but under
      Homebrew it's a plain writable file a future settings UI edits. Designing
      for the read-only case and refusing to merge is what keeps those two futures
      from needing different code.
- [ ] Pounce command packs, with the *dev* commands moved into an opt-in pack. Now
      partly expressible without new mechanism: a pack is a set of `items.*.enabled`
      values, which is data — so "packs" may reduce to shipping preset fragments
      (§3.3) rather than a `packs` enum. Decide that before adding the enum.
- [ ] Commands declare: mutates state? needs confirm? needs network/permission?
      Unbuilt, and the metadata that *did* ship went to nebelung's ports instead
      (§5.1) — same idea, other room. Copy that shape: the declaration lives with the
      command, the consumer reads it.

### 5.10 `nebelhaus.displays` — ✅ **shipped in nebelhaus#147** · M · risk M
The spike de-risked this and the accessibility spike gutted its alternative, so
it moves up sharply. It is the **only** working path to "make everything bigger"
on macOS 26. Don't expose `1920×1200`; expose intent:

```nix
nebelhaus.displays.internal.uiScale = "larger-text";
# more-space | default | larger-text | largest-text
```

- [x] Persistent display UUID exists → key profiles by UUID, not index
- [x] `CGDisplaySetDisplayMode` is public API → ship a small Swift helper,
      **no `displayplacer` / Homebrew dependency** (it isn't in nixpkgs anyway)
- [x] Helper dedupes modes by point size (they repeat ~6× across refresh
      rate × colour depth) and prefer the highest refresh
- [x] Applying a mode is proven end-to-end on the internal panel: `default`
      (`1512×982`) → `larger-text` (`1147×745`) → `default`, with CoreGraphics
      reporting the requested mode current after each change (2026-07-30)
- [ ] Multi-display arrangement is still untested (only one display was attached).
      Test on the dock before designing `profiles.docked`

### 5.11 Reversibility — the trust prerequisite for *any* community · M · risk M · ◐ **the four commands shipped and were felt; two boxes remain**
Before strangers' configs run arbitrary `defaults write` and activation scripts:

- [x] `haus plan` — promote bootstrap's preflight audit; show exact settings,
      packages, and scripts that will change. **Settings and packages**, felt
      through a real `bench try` build; the "scripts" half (a restart-map
      preview) is still just "what packages and casks change" — see the ninth
      pass above.
- [x] `haus capture` — promote the `NEBELHAUS_KEEP` current-value reader into a
      general "turn this Mac into config" command. Generalised past the three
      named categories via `system.defaults.CustomUserPreferences` for any
      literal plist domain; felt against this machine's real
      `com.apple.screencapture` domain.
- [x] `haus diff` — declared vs live. Routes the four keys with a measured
      write-vs-effect gap through `hausax` (a new `NSWorkspace` probe), not the
      plist — reproduced and caught the exact "writes, no effect" failure §4
      found, on this machine, with a synthetic activation script exercising
      all four verdicts (match / effective mismatch / known no-op /
      unconfirmed).
- [x] `haus revert-settings` — restore the pre-activation preference snapshot
      (the installer already admits Nix rollback doesn't undo macOS defaults).
      Proved end-to-end: captured a scratch domain, changed it, reverted it,
      read back the original value.
- [ ] `haus doctor` grows a permission checklist with System Settings deep links
- [ ] Restart/logout/reboot annotations from the §4 matrix. **The data half is
      done and this is now a rendering job** — `modules/lib/restart-map.nix`
      (rice#249) is the table, and `modules/den/default.nix` already derives
      `processesToRestart` from it against whichever domains the built
      configuration actually has. Nothing reads it back for the *user*: `haus
      plan` still previews packages and casks only, which is exactly the "scripts
      half" its own box above admits is missing, and a plan that doesn't say
      "this rebuild will restart Finder" or "this setting waits for a logout" is
      the reversibility gap this section exists to close. One consumer, not a new
      mechanism.

### 5.12 Accessibility — ✅ **back on the table, with an FDA caveat** · M
Twice-corrected. It's buildable: `universalaccess` writes and takes effect —
**if the app invoking the rebuild holds Full Disk Access**. So the option tree is
viable, but the caveat is load-bearing and has to be designed *into* it.

- [ ] Model these as **`reachability = "needs-fda"`** options (§5.6's designation
      scheme), not as ordinary settings. A rice that silently behaves differently
      on two machines is exactly the failure a shared-rice format must not have.
- [x] ✅ **`haus doctor` detects FDA — shipped in rice#128** (`has_fda()`, a
      strict `head -c1` read of the TCC database; no `ls` fallback, which is the
      bug that cost a whole spike). It went further than this box asked: the same
      predicate guards `haus rebuild`, so the warning arrives *before* the
      activation it would abort rather than after.
- [ ] **Do not** add options that write `com.apple.Accessibility` — that domain
      writes and does nothing. Still true, still the worst failure mode.
- [ ] ⚠️ **Agent asymmetry:** Claude Code lacks FDA, Ghostty has it. Any of these
      options set in a host makes agent-driven `haus rebuild` abort activation
      while manual rebuilds succeed. Whatever `haus doctor` says, this needs to be
      impossible to hit by accident — it's the sharpest edge in the whole set.
- [x] Swept 2026-07-25. **`increaseContrast` and `differentiateWithoutColor`
      write and take effect**, and neither is nix-darwin-typed → reach them via
      `CustomUserPreferences`. `increaseContrast` is the OS-level half of the
      high-contrast rice (§5.1), available with no upstream change.
- [ ] `mouseDriverCursorSize` / `closeView*` persist but their **effect is
      unconfirmed** — no oracle exists, so they need an eyeball before
      `ui.cursorScale` comes back.
- [x] **`FontSizeCategory` resolved, and it's narrower than hoped.** Real
      vocabulary is `DEFAULT` / `AX1`… (read back after setting Text size in
      System Settings — my earlier `LARGE` guess would have been stored and
      ignored). But it only affects apps that adopted Dynamic Type — a short
      all-Apple list (Mail, Messages, Notes, Calendar, Finder, Reminders,
      Books, News, Stocks, Weather, Journal, Magnifier). With `AX1` live, a
      non-participant still reports 13pt body text.
      → ❌ **And it is not declarable at all.** Writing it lands in the plist but
      posts no change notification: running apps never re-read it, and System
      Settings renders a desynced view of its own rows. Only dragging the slider
      by hand works. An option backed by this ships a Mac where Settings says
      20 pt, every app renders 13 pt, and the pane looks broken. **Don't wire it.**
      → **Heuristic:** in this domain the **scalar** keys work and notify; the
      **structured** (dict) one lands and lies. Treat dict-valued accessibility
      keys as GUI-only until proven otherwise.

**But the large-print rice still shouldn't be built on it.** Display mode
(§5.10), fonts (§5.3), `ui.*` tokens (§5.2), a high-contrast flavor (§5.1) and
Dock/Finder sizes work for everyone, unconditionally. Treat `universalaccess` as
a **bonus layer** that sharpens the result when FDA happens to be granted — never
as the foundation. That ranking survived all three revisions of this finding,
which is the main argument for it.

### 5.13 Authorable tour steps · ✅ **shipped in nebelhaus#156** · docs workshop#135/#137 · S · risk L
Small, and **nobody else can ship this**. `tour.enable` teaches the four moves
of *this* rice. A community rice teaches its own:

```nix
nebelhaus.tour.steps = [
  { hint = "Press ⌘Space to find anything"; detect = "pounce-opened"; }
];
```
The detection signals already exist (the leader-mode scripts). This is the
difference between downloading someone's config and *learning* it.

nebelhaus#156 kept `steps = null` as the unchanged built-in lap; supplying a
non-empty list replaces it. `detect` is deliberately the existing outcome
vocabulary (`launch`, `workspace`, `navigate`, `resize`, `palette`), so the
community file remains data-only, and the module warns when a step names a
signal whose room is disabled.

The hand-written authoring guide shipped in workshop#135; the generated public
option family followed in workshop#137.

### 5.14 How this doc drifts, and the one rule that fixes it

Not an option family — a finding about the doc itself, recorded here because it
cost real work. An audit on 2026-08-03 checked every open `- [ ]` in §5 against
the actual repos. **Three had shipped and were never ticked**, and a fourth
family had been renamed out from under the whole document:

| Box | Actually shipped |
|---|---|
| §5.9 rice-side `pounce.items` | rice#149, 2026-07-30 |
| §5.12 `haus doctor` detects FDA | rice#128 |
| §5.2 Finder sidebar size | rice#181 |
| §5.4(a) multi-source install | rice#182 — and it **renamed `nebelhaus.apps` → `nebelhaus.roster`** |

The §5.9 one is the instructive case, because the doc **already knew**: the
status block at the top credits rice#149 by number, while the checkbox 600 lines
below still said "the next cheap win in this section". A reader picking work off
the checkboxes — the way you actually use this file — would have rebuilt
something that existed. That is exactly what happened.

**The rule this leaves: a status-block edit is not a substitute for ticking the
box, and the box is the source of truth.** The header summarises; the checkbox
decides. When they disagree, believe the checkbox and then go check the repo,
because the header is written by whoever last did a pass and the checkbox is
written by whoever did the work.

Two structural reasons this drifts more than a normal TODO list, both worth
designing around rather than resolving to try harder:

1. **The work happens in four repos and the doc lives in a fifth.** Nothing in
   `nebelhaus`, `nebelung` or `pounce` CI can see this file, so a PR that closes
   an item has no mechanical way to say so. Every other cross-repo seam in this
   project got fixed by making the upstream repo emit data (`options-json`,
   `wm-bindings-json`, `ports.meta.json` — see §7); this one is still prose on
   both sides.
2. **Items ship out of phase, from the app side.** §5.1's port metadata and
   §5.9's item schema both arrived from downstream repos that wanted the data
   structure for their own reasons — noted in Phase 4 as a good thing, and it is,
   but it means the rice-side box goes stale without anyone in the rice touching
   the item.

The cheap mitigation, given both: **re-audit against the repos, not against
memory, before treating any `- [ ]` as work to do.** The full pass took one
session and would have been cheaper than the half-rebuild that prompted it.

**Second pass, 2026-08-04 — the rule held, and it found a failure it doesn't
cover.** Re-auditing first this time cost ten minutes and turned up no
shipped-but-unticked box (one day of drift, so that's expected). What it *did*
turn up is a different shape of staleness the checkbox rule can't catch: **a
shipped PR that falsifies a CLAIM in the prose.** rice#203 didn't close any item
here — it corrected the composition story §6 and Phase 0 were built on, and both
of those are ticked boxes and running text, not open ones. So:

- an open `- [ ]` goes stale when work ships → fixed by auditing the repos;
- a **closed** item goes stale when someone learns the thing it asserted was
  wrong → nothing catches that but reading the commit messages.

Both were found by the same act — reading every commit since the last pass rather
than diffing the checkbox list — which is the actual rule worth keeping. The
commit bodies in these repos are long on purpose; **the audit is reading them,
not grepping them.**

**A third shape, found by a parallel pass the same day.** Two sessions audited
this file independently on 2026-08-04 and overlapped on most of it — but each
found things the other didn't, and one of them is a category the two rules above
still miss: **a box whose marker and body disagree with each other.** §5.1's
"pair `contrast` with the OS lever" read `- [ ] ✅` — an open checkbox with a
tick inside it — and both options had in fact shipped. Nothing catches that but
looking at the marker and the prose as two separate claims. §5.5's tour box was
the fourth shape again: not stale, not falsified, but describing a failure mode
(*hangs at step 1*) that had been **replaced by a different one** (*draws
nothing at all*) — worse, and invisible to anyone re-reading the doc.

So the full list of ways an entry here goes wrong, none of which the others
catch:

| Shape | Caught by |
|---|---|
| open box, work shipped | auditing the repos |
| closed claim, later falsified | reading the commit messages |
| marker and body disagree | reading the two as separate claims |
| description replaced by a *different* truth | building the thing and looking |
| claim true, but about the wrong **layer** *(added on the sixth pass — see below)* | trying to write the check it implies |

★ **The structural fix for reason 1, and it exists now.** §5.14 observed that
every other cross-repo seam here got fixed by making the upstream repo emit
something mechanical, while this one stayed prose on both sides. Two roadmap
findings are now **checks in the repo that can break them**: `data-only-surface`
fails when a package-typed `nebelhaus.*` leaf has no string sibling (§5.3), and
`accent-reach` fingerprints seventeen surfaces under three accents so §5.1's
honest-scope paragraph can't silently stop being true. Both cost one PR each.
*(Corrected on the fifth pass: only `data-only-surface` is pure `lib` and runs on
Linux CI. `accent-reach` fingerprints a real evaluated system, so it is
darwin-guarded and runs on nobody's CI — it fires on this machine, or not at
all. Worth knowing before counting it as a tripwire.)*

★ **Noted on the fourteenth pass, as reasoning and not as an incident: a check
can pass on the pointer while the referent is missing.** `accent-reach`'s `glow`
row fingerprints `yazi/plugins/glow.yazi`, whose accent-varying content is a
*path* into nebelung's output. Nix interpolates a store path into a string
without asserting anything is there, so the row would read `moves` with the JSON
absent. **This has not happened** — the fourteenth pass first reported that it
had, and the pre-PR assurance pass proved otherwise (see the retraction at the
top of this file). The reasoning stands on its own: **a golden-table check needs
to ask what layer its fingerprint lives at**, because for anything whose
accent/flavor axis is a *reference* across a repo boundary, fingerprinting the
reference is free and proves nothing. `zed`'s row already carries a comment
calling itself the one fingerprint that is a FILENAME rather than a file's
contents — the same shape, noticed and then not generalized.

- [ ] Assert the referent exists for every cross-repo reference `accent-reach`
      pins — one line (`[ -f ${glowStyle} ]`) in the existing `glowPlugin`
      `runCommand` in `modules/hearth/default.nix`, then audit the roster-port
      rows for the same pointer-vs-referent gap. Low priority: no break has
      occurred, and this is a belt on a check rather than a check on the surface.
- [x] ✅ **A downstream lock pinned at an upstream rev that is not on the
      upstream's `main`** — fetchable only until the PR branch is deleted, and
      nothing in the family noticed. Found in the fourteenth pass's retraction:
      rice#247's lock pointed at nebelung#29's PR-branch head for seventeen
      minutes. `bench ship` can't cause it (it bumps to merged HEADs); a
      hand-run `nix flake update` inside a PR can. **Shipped as an `OFF-MAIN`
      lock edge in `bench status` (workshop#252)**, reported separately from
      `STALE` because the fix is different — STALE says *ship it*, and there is
      nothing to ship. Three details that were not obvious before writing it:
      **(a)** the answer has to be three-valued, not boolean — a rev nix fetched
      but git never did isn't in the local clone at all, and calling that
      "off-main" would cry wolf on every machine that hasn't fetched, so
      `unknown` stays silent; **(b)** it checks `origin/main` *and* local
      `main`, since a checkout behind its remote would otherwise report landed
      revs as off-main — but `HEAD` is consulted **only** when neither resolves,
      because every extra ref widens the yes-set, and reading `HEAD` always
      would let a main checkout parked on a branch (the in-place agent mode does
      exactly that) declare every rev on that branch landed, silencing the
      warning where it is most likely to be earned; **(c)** it only runs on
      edges that already failed the equal-to-HEAD test, so the common path costs
      nothing. The assurance pass found (b) and the closing-verdict line, which
      still said *everything is current* when OFF-MAIN was the only problem —
      **a new warning has to be ranked in the summary that prints under it**, or
      the one line a reader treats as the verdict contradicts it.
      → ★ **This is the first tripwire in this file that is a *warning in a
      CLI*, not a check that fails a build.** §5.14's rule says leave a check
      behind; the honest footnote is that a `bench status` line only fires when
      someone runs `bench status`. It was still the right shape here — the
      condition is about a lock, and locks are what that command exists to
      report — but it does not belong in the "checks that can break" ledger.

**So the rule gains a second half: when a finding generalises, leave a CHECK
behind, not a paragraph.** Ask of every ★ in this file — *what would fail if
someone did this wrong tomorrow?* If the answer is "nothing, they'd have to have
read the roadmap", the finding isn't finished. The remaining candidates: §5.2's
point-valued options silently coupled to `displays`, §5.6's "what second key
makes the first one a lie", and every "what this does NOT reach" paragraph in
§5.1 and §5.2.

**A fourth candidate arrived with limit 3's measurements, and closed within the
hour: a pack's SURFACE.** Nothing enforced that a pack touches only
`nebelhaus.roster` — `checkRice` bounds it to `nebelhaus.*` and stopped there,
which is why `packs/writing.nix` opened with a comment explaining the narrower
rule instead of a check enforcing it. It cost nothing until §6's seam existed,
and would have cost real confusion the moment it did, because the wrapper
silently drops whatever it wasn't written to carry. `checkPack` (rice#222) is
the same shape as `checkRice`, one level in. **Two ★ findings in this file are
now checks that can break, and this is the third** — the rule is holding.

**Fourth pass, 2026-08-05 — the falsified-claim shape fired again, and this time
the falsified claim was one of MINE.** §6's limit 3 asserted that a colliding
consumer "meets a raw nix conflict trace rather than anything this project
wrote". Nobody had read the trace. It names the option, both files and the fix
(§6). The rule from the second pass — *a closed claim goes stale when someone
learns the thing it asserted was wrong* — was written about other people's
commits; the sharper version is that **this document's own unmeasured
justifications are the most likely thing in it to be false**, because nothing
downstream ever executes them. Both of the last two passes ended by naming a
measurement as the next step, and both times the measurement contradicted the
paragraph that proposed it.

A fifth check candidate, from the same pass: **a `presets` check** in the shape
of `packs`, with the twist that it must assert a **collision** as well as its
absence — the pairs the docs advertise as stackable have to keep composing, and
the pairs advertised as alternatives have to keep failing. And a **fourth
finding that became a check the same day** (rice#228): *a wrapper applied to
someone else's module owes it a `_file`* — `lib.pack` dropped it, so the
collision it deliberately preserves was anonymous, and rule 3 of the `packs`
check now fails if it goes missing again. **Four ★ findings in this file are
now checks that can break.**

**Fifth pass, 2026-08-06 — the fifth candidate is written, and the audit was
empty.** `preset-composition` (rice#239, **merged the same day**) is that
check; §6's limit-3 section has
what it pins. **That makes five ★ findings in this file that are checks which can break.**
The remaining candidates, unchanged and now the whole list: §5.2's point-valued
options silently coupled to `displays`, §5.6's "what second key makes the first
one a lie", and §5.2's "what this does NOT reach" paragraph (§5.1's is covered by
`accent-reach`).

Two things this pass adds to the drift rule itself:

- **The audit found nothing, for the first time in five passes.** Not because the
  repos were quiet — eight rice PRs landed — but because none of them touched the
  option surface. That is worth writing down as a *result*: the rule's cost is
  one session, and a clean pass is the outcome that tells you the document has
  stopped being the family's slowest-moving artifact.
- **★ A number in this file is a claim, and a claim needs its method.** The fourth
  pass asserted "130 leaves, unmoved". Re-deriving it, three defensible ways of
  counting the same option tree give **203** (every doc-list leaf, including
  submodule sub-options), **160** (visible only) and **135** (visible, no
  `<name>` placeholders) — and **130** is what `nix build .#options-json` emits,
  which is the surface the options page renders. All four are true; only one is
  the number this document means. So the rule gains a small third clause:
  **when the doc quotes a count, quote the command that produced it** — otherwise
  the next pass either reproduces it by luck or "corrects" it to something else
  true. And where a derivation exists, prefer it to a count outright: building
  `options-json` at two revisions and comparing **store paths** answers "did the
  surface move" exactly, with no counting convention to get wrong.

**Sixth pass, 2026-08-06 — two of the three remaining candidates fell to one
measurement, and the larger one was aimed at the wrong layer.** §5.2's coupling
warning and §5.2's honest-scope paragraph were both answered by
[`probes/scale-reach.nix`](probes/scale-reach.nix) and are now the rice's
`scale-reach` check. **Seven ★ findings in this file are checks that can break,
living in five checks** — the two counts have drifted apart because `packs`
carries two findings and `scale-reach` closes two candidates, and the fifth
pass's own rule applies to this number as much as to a leaf count: say which
one you mean. The whole remaining list is §5.6's "what second key or precondition makes the
first one a lie", which is the one candidate here that is a *design rule for
options not yet written* rather than a property of one that exists — worth saying
out loud, because that is why it has outlived every other candidate. This pass
also hit a fresh instance of it outside macOS settings: "the terminal font can't
clip" is true only *while prowl tiles the window* (§5.2), which is the same
shape — a claim whose second precondition is the thing that makes it a lie.

**A fifth shape, added as a row to the table above rather than kept beside it** —
a one-row table nobody consults is the same hazard the table exists to fix:
*a claim that is true, but about the wrong layer.*

§5.2 said "every point-valued option is silently coupled to `displays` — worth
auditing `fonts.*.size` and prowl's gaps". Nothing in it is false; it is simply
about numbers *inside modules*, while the sentence is phrased as a rule about the
option surface, where the set has one member and prowl's gaps aren't in it. **The
thing that exposed the mismatch was trying to turn the paragraph into a check** —
you cannot write a golden table without deciding what its rows are, and the rows
were not where the paragraph said. That is a second argument for §5.14's "leave a
check behind, not a paragraph" beyond regression-catching: **the check is a
type-check on the finding.** Prose can be true at no particular altitude; a table
cannot.

**Seventh pass, 2026-08-06 — a reach table can only see what evaluation
produces.** The sixth pass's technique, pointed at `fonts.mono.name`, found an
option reaching exactly one surface while the bar drew in a hardcoded family of
its own (§5.3, closed by rice#243). `font-reach` is the third of these tables and
the first that had to look somewhere else as well:

- the **generated** half — `sizes.sh`, `workspaces.sh`, ghostty's config — is
  visible by evaluating two rices and diffing, which is all `accent-reach` and
  `scale-reach` ever needed;
- the **static** half — the rc and the plugins, copied to the machine verbatim
  and read at runtime — is *invisible* that way: those files are byte-identical
  whatever the rice names, so the bug lived exactly where the technique was
  blind. The row that catches it reads the source files and counts font literals
  (0, and the next hardcode makes it 1).

**Generalise it: when a promise is kept partly by files the rice copies rather
than computes, a differential check cannot see that half.** The candidates with
the same shape are every other verbatim-copied config the rice ships — the
sketchybar plugins, the zellij scripts, `aerospace.toml`'s prose. Ask of each
table: *if someone re-hardcoded the thing this option promises, in a file we
copy, would this fail?*

**Eight ★ findings, six checks** (`data-only-surface`, `accent-reach`, `packs`
carrying two, `preset-composition`, `scale-reach` carrying two, `font-reach`).
The remaining candidate list is still §5.6's alone.

**Fourteenth pass, 2026-08-08 — the first pure audit since the fifth, and this
ledger had itself gone stale.** Passes eight through thirteen all *shipped*
something, wrote it up in a status block at the top of this file, and none of
them appended here — so §5.14, the section about drift, silently stopped
recording six consecutive passes. Nothing was lost (the status blocks are
thorough), but the section that exists to catch staleness is not exempt from it,
and a reader looking for "when was this last audited" would have found
2026-08-06.

One finding in a shape already on the table — the tenth pass's own "read out of
`config`, not hardcoded" claim, falsified by rice#255 (shape 2). One thing this
pass corrected that has no shape on the table yet, because it isn't a *finding*:
**the phase summary in §6 is a second checkbox surface, and §5.14's rule was
only ever pointed at §5.** Three of its lines described work that had shipped.
The rule's cheapest extension: *when you tick a box in §5, read the phase line
that names it* — they are the same claim written twice, which is the standing
condition for drift.

**And a sixth shape, which this pass produced rather than found: an audit that
invents a regression.** Finding 1 as first written described a seventeen-minute
false green in `accent-reach` that never happened; it was built on comparing a
lock *rev* against a *merge* rev without diffing the trees, which squash-merge
makes meaningless. The pre-PR assurance pass — a clean-context subagent reading
the diff against the repos — caught it before the PR opened, which is precisely
the job that step exists for and the first time it has overruled a finding in
this file rather than a line of code. The shape belongs on the table because it
is the most expensive kind: every other row here describes a *true thing going
stale*, while this one puts a false thing in a document whose whole authority is
that its claims were checked.

| Shape | Caught by |
|---|---|
| audit invents a regression | a clean-context reader who re-derives the evidence |

Still **eight ★ findings, six checks** — and one *warning*, which is a new
category the ledger should keep separate. The more valuable of the two
candidates this pass raised shipped immediately (workshop#252: `bench status`
reports an `OFF-MAIN` lock edge), but it fires only when someone runs
`bench status`, where all six checks fire on `nix flake check`. Counting it as a
seventh check would overstate the guarantee. The other candidate — assert the
referent exists behind `accent-reach`'s cross-repo references — stays open and
low priority, since no break has occurred.

---

## 6. Phasing

> **These lines are a second checkbox surface, and they drift** — three of them
> described shipped work until the fourteenth pass. Two conventions, so a reader
> picking work off them isn't misled: a line here **summarises a §5 section and
> never overrides it**, and `- ◐` means part-shipped, so `grep '- \[ \]'` alone
> under-reports what is open. When a §5 box is ticked, read the phase line that
> names it in the same edit.

**Phase 0 — ship this week, no architecture required**
- [x] `nebelhaus.fonts` (§5.3) — nebelhaus#91. Turned up a real bug on the way:
      sill named `Hack Nerd Font` in seven places and **nothing installed it**,
      so every fresh install had been drawing tofu across the whole bar.
- [x] ✅ **Shareable app pack — rice#198.** `packs/writing.nix` +
      `packs/README.md`, exposed as `nebelhaus.packs.<name>` and run through the
      same `nix flake check` the presets are. **Phase 0 is now closed.**
      A pack is a preset that touches ONE family (`roster`), which is why it
      composes rather than competes: `[ everyday large-print writing ]` is a
      sentence — what kind of machine, how you see it, what's on it — and none of
      the three files knows about the other two.
      → ⚠️ **That sentence was too strong, and rice#203 corrected it.** Touching
      one family makes an *overlap* unlikely, not impossible, and an overlap is a
      **conflict**, not an override — see the composition finding in §6. The
      three above compose because they don't collide; `[ everyday minimal ]`
      doesn't compose at all.
      Three things it taught, all of which needed writing one to find:
      **(a) it found a real bug.** `z` is the obvious letter for Zotero and also a
      built-in leader action; the rice ACCEPTED that and emitted two `z =`
      bindings into one AeroSpace table, silently keeping whichever parsed last.
      `leaderExtras` had been checked against the built-ins since forever —
      roster keys never were, because `roster` asserts uniqueness among its own
      entries and knows nothing about window management. **The check existed in
      one direction only**, and a shared rice is exactly what makes the other
      direction likely: a pack author doesn't know the leader vocabulary.
      → **★ Sequel, rice#236 (2026-08-06): the assertion was right and a UI still
      offered the collision.** Pounce's "Install App" picker proposed a free
      leader letter by reading the *cheatsheet*, where the built-in actions render
      as display glyphs (`v / e`), so no bare letter ever matched them — it
      offered `v`, wrote the roster entry, and the rebuild it had just started
      died on the very assertion above. Fixed by reading the generated
      `aerospace.toml`'s `[mode.launch.binding]` table, i.e. **the same artifact
      the assertion guards**. The rule generalises past this bug and is the
      offering-side twin of §5.14's "leave a check behind": *anything that OFFERS
      a choice must read the table the check reads, not a rendering of it* — a
      rendering is lossy in exactly the places a human reader doesn't notice, and
      the cost lands after the write, mid-rebuild.
      **(b) `appId` is the field a pack structurally can't fill in** — it isn't in
      Homebrew's cask metadata and a guessed bundle id produces a rule that
      silently never matches. Leaving it null costs *only* auto-assignment, so the
      honest shape is to ship null and name the one-liner that closes it.
      **(c) it hit the §5.3 format limit again, from a second family.** A pack can
      install from Homebrew and the App Store but NOT from Nixpkgs, because
      `roster.*.package` is `types.package`. That's now two families where
      data-only meets a package type, which upgrades it from a fonts quirk to a
      property of the format worth fixing once.
      Worth recording for the phase list: the item that closed had been open the
      longest and needed **no new mechanism at all** — only a file to point at.
- [x] Hot corners + screenshot settings (§5.6) — **rice#198**. Nine leaves, all
      defaulting to write-nothing; see §5.6 for the two silent failures they
      turned up.

**Phase 1 — structure (blocks everything else)** ✅ **done 2026-07-26**
- [x] §3.1 split options (nebelhaus#92) — 752 → 122 lines, byte-identical derivation
- [x] §3.2 `developer.enable` (nebelhaus#96) — "minimal" is no longer a lie
- [x] §3.3 presets-as-format (nebelhaus#98) — `checkRice` + `nix flake check`
- [x] §3.4 generated docs (nebelhaus#93 + workshop#81) — page rendered from the module system

  Worth recording: **§3.1 paid for §3.4 immediately.** Splitting options into
  pure `{ lib, ... }` modules is what let the docs generator evaluate them
  standalone on Linux CI, with no darwin system. That dependency wasn't
  predicted here — it's now a comment in the flake, because it's load-bearing
  and its failure mode (docs CI breaks) points nowhere near its cause.

**Phase 2 — know what's possible** ✅ **done 2026-07-25**
- [x] §4 spikes → [`macos-settings-matrix.md`](macos-settings-matrix.md)
- [x] `universalaccess` confirmed dead via a real `darwin-rebuild` — fails as
      root, and aborts activation when set
- [x] Guardrail shipped: nebelhaus **warns** when `system.defaults.universalaccess.*`
      is set (nebelhaus#89), and it's reported upstream on nix-darwin#1049.
- [x] **Positive case settled** (Ghostty + FDA): `reduceMotion` writes *and*
      takes effect. The sweep then proved `reduceTransparency`,
      `increaseContrast` and `differentiateWithoutColor` too — the last two
      aren't nix-darwin-typed, so they ship via `CustomUserPreferences`
      (nebelhaus#90) and give §5.1 an OS-level high-contrast lever.
- [x] `FontSizeCategory` resolved and **rejected**: writes land but post no
      change notification, so apps never re-read them and System Settings
      renders a desynced view. Third member of the write-that-lies family.

**Phase 3 — the expression layer** *(the spike raised this phase's priority: it's
everything macOS can't veto)* — **mostly done 2026-07-27**
- [x] §5.3 fonts (nebelhaus#91)
- [x] §5.2 `ui.scale` — shipped; the sizing pass closed it out at five targets
      (`density`/`motion` still unbuilt). **Pounce and sill both reached**
      (pounce#53 + rice#175): the palette and every panel behind it scale freely,
      the bar's type scales to the menu-bar band's ceiling and stops
- [x] §5.1 theme: **contrast** (nebelung#11 + nebelhaus#103) and **flavor / light
      mode** (nebelung#12 + nebelhaus#108), then **roster theming from port
      metadata** (nebelung#17/#18/#19 + nebelhaus#136) and **pounce off the
      "bakes its own" list** (pounce#37/#42 + nebelhaus#139/#142). `scheme = "auto"`
      is now *partly* shipped — per-tool rather than rice-wide, which is a design
      answer as much as progress; `flavor = "custom"` remains untouched.
- [x] §5.5 `keys.*` (nebelhaus#108) — leader / palette / windowNav, each with a real
      `"none"`. Per-action `bindings` deferred; it wants an action vocabulary first.
- [x] §5.4 registry v2 — **fully shipped 2026-08-07 (nebelhaus#253).** The
      multi-source install landed first as `nebelhaus.roster` (rice#182); the
      risky half — `workspaces` — landed as a **clean rename, no back-compat
      alias** (single-user rice, Julien's explicit call), not the
      `roster.*.workspace`-desugars-into-`workspaces` sketch this line
      originally described. See §5.4 for what was measured before calling the
      live host safe.
- [x] §5.10 displays (nebelhaus#147) — the only working system-wide "make it
      bigger" lever, now part of `large-print`; docked multi-display validation
      remains before any `profiles.docked` design

**Phase 3.5 — the docs debt Phase 3 created** *(found while shipping it, 2026-07-27)*

Every user-facing option family needs a hand-written guide; only
`reference/options.md` is generated. Landing four option families at once made
that visible, and turned up two things that were already broken:

- [x] `reference/options.md` regenerated — it was **already stale from #103**, so
      `options-drift.yml` was red before this phase even started. `theme.contrast`
      had never reached the page.
- [x] `guides/theming.mdx` gains contrast + light mode; it still described nebelung
      as "low-contrast" and documented neither. Same phrase corrected in
      `start/what-is-nebelhaus.md` and `reference/palette.mdx`.
- [x] `guides/window-management.mdx` + `reference/keybindings.md` say the keymap is
      configurable, and that `⇪`/`⌥` in the tables mean "the leader" and "the nav
      modifier" on a rice that moved them.
- [x] ⚠️ **The keybinding tripwire was BROKEN by #108** and nothing in the rice
      could have caught it: `web/scripts/check-rice-bindings.mjs` did
      `nix eval --json --file modules/prowl/wm-bindings.nix`, which stopped working
      the moment that file became a function ("cannot convert a function to JSON").
      It runs on a weekly cron, so it would have surfaced as a mystery Monday
      failure in a different repo. Fixed by exposing `wm-bindings-json` from the
      rice's flake — the same seam `options-json` already uses, and the general
      lesson: **when the docs repo reads the rice's internals directly, a rice
      refactor is a cross-repo break with no local signal.** Worth auditing for
      other direct reads.
- [x] **Presets and community rices have their own guide — workshop#138.**
      `guides/sharing-a-rice.mdx` covers the data-only boundary, `checkRice`,
      composition testing, publishing, and the line between a rice and a power
      module; `guides/making-it-yours.mdx` keeps the shorter consumer story.

**Phase 4 — the non-dev Mac**
- [x] §5.7 `haus set` — done 2026-08-07; see the twelfth-pass status note.
- ◐ §5.6 curated settings groups — **five of the table's nine rows now carry a
      shipped marker:** hot corners + screenshots (rice#198), then `lock` (lock
      half only), `menuBar.{clock,controlCenter}` and `security.firewall`
      (rice#250) — i.e. three of the seven that were still open after rice#198.
      Of the four rows left, **one is deferred on a reason** (Windows is
      logout-only) and **three are now spiked and unbuilt** (Sound, Locale/input
      sources, Power — 2026-08-08; the "blocked on a spike that doesn't exist
      yet" this line used to say is closed, and the spike found all three
      reachable). Sound needs nothing new; Locale is gated on restart-map
      learning a `notify` verb; Power should be built as a `pmset` activation
      step rather than a `system.defaults` group. Two *halves* inside shipped
      groups are deferred on the same logout reason: `lock`'s login half and
      `security`'s guest-user/remote-login half.
- ◐ §5.9 — **pounce's half arrived from the app side (pounce#43), the rice-side
      item generator shipped in rice#149.** Three boxes remain: sill widgets,
      pounce command packs, and commands declaring what they do (mutates state?
      needs confirm? needs network or a permission?).
- [x] the restart map (§4) — nix-darwin only restarts Dock, so this is ours.
      **Done, 2026-08-07 — see the tenth-pass status note at the top of this
      file.**
- ◐ **§5.9's pounce half arrived early, from the app side** (pounce#43), because
  pounce wanted a Raycast-style settings list for its own reasons. That's the second
  time an app shipped a piece of this roadmap ahead of its phase (the first:
  nebelung's port metadata, §5.1) — both times because the app needed the data
  structure anyway and the rice was the *downstream* consumer. So read these phases
  as an ordering of **rice** work; the family's other repos will keep landing pieces
  out of order, and the cheap move is to notice and consume them rather than to
  design the option first.

**Phase 5 — trust and breadth**
- [x] §5.11 plan/capture/diff/revert — **all four shipped and were felt
      (rice#248).** The warning this line carried before it was built —
      **`diff` must compare effective state, not plists**; a plist-only diff
      would have called both no-op writes "applied" — is what `haus diff`
      actually does, routing the four keys with a measured write-vs-effect gap
      through an `NSWorkspace` probe. Two boxes remain inside §5.11, both `haus
      doctor`/`haus plan` rendering rather than new mechanism.
- [ ] §5.8 scenes · §5.12 accessibility doctor checklist
- [x] §5.13 authorable tour steps — shipped in nebelhaus#156; documented in
      workshop#135/#137

**The readiness test:** three reference rices that are deliberately far apart —
today's developer rice, `large-print` + `everyday`, and a mouse-first
writer/creative setup — each expressible **without reaching around
`nebelhaus.*` even once.**

Scoreboard, 2026-07-27: **all three now exist and pass.** `full`, `everyday` and
`large-print` are data-only (`nix flake check` proves they touch nothing outside
`nebelhaus.*`), and none needed a `system.defaults` escape hatch or a
hand-written activation script — which was the whole point of not faking it.

`presets/large-print.nix` is four options (`ui.scale`, `theme.contrast`,
`accessibility.increaseContrast`, `displays.main.uiScale` — it was three before
§5.10 landed) and it is a **layer, not a whole rice**: it
describes seeing, not the person, so `[ everyday large-print ]` composes with
nothing lost either way (measured: stock `1.0 / 19pt` → large-print `1.4 / 27pt /
contrast high` → stacked, plus developer off, prowl off, pounce on). That layer
shape needed no new mechanism, and it's a better answer than a monolithic preset:
had large-print been forced to restate `everyday`, the surface still couldn't
separate "a Mac for someone who doesn't write code" from "a Mac you can read".

**Passing is not the same as finished, and the test's real value was the two
limits it exposed:**

1. ~~**A shared rice cannot change the font family.**~~ ✅ **Closed 2026-08-04
   (rice#215).** It was a **format** limit rather than a missing option —
   `fonts.mono.package` is a `types.package` and reaching `pkgs` is precisely what
   data-only forbids — and it generalised exactly as predicted: `roster.*.package`
   had it too. `packageName` (a nixpkgs attribute path, as a string) answers both,
   and `data-only-surface` in `nix flake check` now fails on the next
   package-typed option added without one. The surface audit it asked for came out
   at **three typed leaves in 128**, two of them the pair just fixed and the third
   a `types.path` that a data-only rice can legitimately satisfy with `./thing`.
   The scary-sounding audit was a one-liner; the part worth the work was making it
   a check.
2. **There was no system-wide size lever in the preset.** macOS's own workable
   lever is display resolution (§5.10), not its broken declarative text-size
   setting. That gap is now closed by `displays.main.uiScale = "larger-text"` in
   rice#147. It is deliberately coarse — everything grows and desktop space
   shrinks — but it reaches third-party apps that `ui.scale` cannot.

So the honest reading now: the option surface can express all three reference
rices, and `large-print` reaches both the rice and the whole Mac. Its one
remaining visible gap is the font-package format limit above — not §5.2, and not
§5.4. *(Superseded 2026-08-04: that gap is closed, and a third limit — composition
— took its place. See below.)*

**Re-checked 2026-07-30 after rice#147/#149.** Displays and the rice-side pounce
item generator both landed. That left the sizing pass as the next coherent piece:
the menu bar and palette were the two rice-owned surfaces `large-print` could not
enlarge. The dock is now a validation dependency only for future multi-display
profiles, not an ordering dependency for the shipped scale option.

**Updated 2026-08-02 after pounce#53 + rice#175 — the sizing pass is done.**
`large-print` now enlarges both surfaces a non-developer actually touches: the
palette they launch things with, and the bar they read. Two things it taught,
both bigger than the change:

1. **The two "make it bigger" levers multiply.** `ui.scale` and
   `displays.*.uiScale` are documented as answers to different questions — the
   rice vs the Mac — and `large-print` sets both, so a tool sized in points has to
   be told where the (now smaller) screen ends. Every point-valued option in the
   surface is coupled to `displays` this way; only pounce's is guarded so far.
   `fonts.*.size` and prowl's gaps want the same audit.
2. **A stated ceiling is a legitimate third answer.** The bar can't scale
   proportionally — its height belongs to the macOS menu-bar band, which was
   *measured* to have no setting behind it — so it grows its type to 1.25× and
   stops, with the limit written into `ui.scale`'s own description. That's better
   than either a multiplier that clips or a refusal that leaves the bar alone, and
   it is the first place the readiness test's "expressible without reaching around
   `nebelhaus.*`" ran into something macOS simply owns. The reason it took one
   pass rather than three: the band was probed before anything was designed
   against it. **Measure the limit before deciding the option's shape.**

**Re-audited 2026-08-03 against the repos rather than against this file** (§5.14
has the method and why it was needed). Nothing in the readiness verdict moves —
all three reference rices still pass, and the font-package format limit is still
the one visible gap — but the count of what's *left* was overstated, and where
the remaining work sits changed shape:

- Phase 3 is closer to done than the boxes said: §5.4's install half shipped as
  `roster`, leaving `workspaces` alone as the last Phase 3 item.
- Phase 4 is emptier than it looks: §5.9's pounce half is fully landed on both
  sides now, so what's left there is `sill.widgets` and command metadata.
- Phase 5's §5.12 has its doctor half, so the accessibility line item is now
  purely about the remaining unmeasured keys.
- **Phase 0 was the one genuinely stalled phase, and it is now closed** (rice#198).
  Worth naming why it had stalled: its last item needed no code at all — the
  format, the guide and the four install sources all existed — which is precisely
  why it kept losing to items that did. It was the cheapest thing in the document
  and had been open the longest. **Cheap and unblocked is not the same as
  likely-to-happen**; if anything it's the opposite, because nothing forces the
  issue. The lesson for whatever ends up last in Phase 5.

**Updated 2026-08-04 — limit 1 is closed (rice#215) and limit 3 is worse than
limit 1 ever was.**

### ★ Limit 3: composing rices is not the free operation this document assumed

Found by rice#203, while composing `packs.writing` onto a real host that already
had Obsidian — *the likely case, not an exotic one*, since a pack is worth
publishing precisely when its apps are popular.

**Import order carries no priority in the module system.** Two definitions of the
same option at the same priority *conflict*; the build stops. Everything this
doc (and three READMEs) said about "later ones win" was false:

- `[ everyday minimal ]` doesn't compose at all — they collide on
  `pounce.enable`.
- `[ everyday large-print ]` composes **only because the two files happen not to
  overlap**, which is luck the format was taking credit for.
- A pack naming an app the consumer already has fails with a raw module-system
  conflict error — and it never reaches the friendly roster assertion the pack
  advertises, because the module system stops first, per field. The suggested fix
  (`lib.mkForce`) appeared in none of the docs.

The consumer-side fix is one line (`nebelhaus.roster.zotero.key = lib.mkForce
"y";`) and the pack-author-side guidance is "leave optional fields null — every
field you set is one a consumer may have to force". Both are now written down.
But note what remains unsolved: **a stranger's first real pack collides with a
stranger's existing rice, and the error they see is a nix conflict trace rather
than anything this project wrote.** That is the format's sharpest limit now, and
unlike the package-type limit it has no fix in hand — only three candidates worth
weighing before publishing the format:

1. **Ship packs at a lower priority** (`mkDefault` inside every pack) so a host
   wins by default. Cheap; costs the ability to say "this pack *means* it".
2. **Detect and translate** — an assertion that turns the raw conflict into "your
   host and pack X both set `roster.obsidian.key`; add `lib.mkForce`". The module
   system stops before our assertions run, so this needs the conflict caught
   somewhere earlier, which may not be possible from inside the module system at
   all.
3. **Accept it and document it**, which is where rice#203 left things.

#### ★ Option 1, measured (2026-08-04) — it works, at exactly one depth, and only from the seam

The trial the previous revision of this section asked for. The real
`packs/writing.nix`, composed against a host that already declares
`roster.obsidian` on its own letter, evaluated through `lib.evalModules` over
`modules/options-modules.nix` — the pure-lib option surface, no darwin system,
the same trick §8 uses to diff the surface without a build. Re-runnable, in
seconds: [`probes/pack-priority.nix`](probes/pack-priority.nix). Five
compositions:

| what the pack ships | `[ pack host ]` evaluates to |
|---|---|
| today — plain values | **conflict error** on `roster.obsidian.key` |
| `mkDefault` on the whole `roster` attrset | **one app, silently.** Obsidian only, on the host's letter, with the pack's `workspace` and `barIcon` gone — and Zotero, Anki, calibre never installed. No error, no warning. |
| `mkDefault` on every leaf | all four apps; the host's `key = "n"` wins; the pack's `workspace` / `barIcon` / `cask` survive intact |
| two leaf-`mkDefault` packs naming one app | **conflict error** — still loud |
| leaf-`mkDefault` + a host that wants the app with `key = null` | all four apps, no letter claimed, no `mkForce` needed |

Three things fall out, and the middle one is why this had to be run rather than
reasoned about:

**(a) A pack cannot lower its own priority — so option 1 is a property of the
IMPORT PATH, not of the file.** `checkRice` throws on a file that is a function,
and the data-only rule is precisely "takes no arguments"; `mkDefault` is
`lib.mkDefault`. So "ship packs at `mkDefault`" can only ever be done *to* a
pack, at the seam that imports it, never *in* one. `nebelhaus.packs.writing`
could carry it; a stranger's pack fetched as a gist and dropped straight into
`extraModules` would not, and would behave differently from the identical file
consumed through the flake — the worst kind of difference, because the file is
byte-identical. Shipping option 1 therefore means shipping the seam as public
API too (`nebelhaus.lib.pack ./their-pack.nix`, beside `checkRice`), and
`packs.<name>` stops being a path — today it is one, and
`checkRice nebelhaus.packs.writing` works on it.

**(b) The obvious implementation is the broken one, and it fails silently.**
`mkDefault` on the whole `nebelhaus.roster` attrset is the one-line version of
the same idea, and it *deletes three quarters of the pack*: `roster` is where
the option boundary sits, so the priority attaches to the entire definition, and
one normal-priority field anywhere in the host outranks all of it. The consumer
gets no error — just a Mac missing three apps they asked for. **Wrap below the
option leaf and you are setting a priority; wrap at or above it and you are
replacing a value.** That boundary is invisible from a pack, which only ever
sees an attribute path. This is limit 3's own class one level down: valid parts
composing into an outcome nobody chose.
→ The corollary generalises past packs: the leaf trick is safe for `roster`
because it is `attrsOf submodule` the whole way down. It is **not** a general
preset mechanism — an option whose value is a plain list or attrset
(`hearth.obsidianVaults`, `theme.ports.handled`, `agents.clients`, and
`theme.palette` when §5.1 builds it) would end up with override markers buried
*inside* its value, which is a type error rather than a priority.

**(c) The asymmetry it produces is the right one.** A host outranks a pack
silently; two packs stay peers and still collide loudly. That is what you would
design if asked: the consumer is the party who can't be expected to know what a
pack contains, while two pack authors are equals whose collision nobody else can
resolve for them.

So option 1 is buildable and cheap — a `mapAttrs` at the seam, plus a
`checkPack`-shaped guard that a pack sets nothing outside `roster`, because the
wrapper would silently drop anything else it found (§5.14's rule: the finding
leaves a check, not a paragraph). What it costs is what this section predicted:
a pack can no longer *mean* a field, and a consumer who deliberately set the
same letter the pack wanted is no longer told they agreed.

**★ Shipped the same day — rice#222, and the seam turned out to be public API.**
Option 1, per leaf, as `nebelhaus.lib.pack`: `packs.<name>` arrives pre-wrapped,
a vendored pack gets the same by being imported through it, and `packFiles.<name>`
keeps the raw paths for tooling (`packs.<name>` was a path and is a module now —
the one breaking change). `checkPack` joins `checkRice` for the narrower rule a
pack has to obey, because the wrapper carries only `roster` through and would
drop the rest without a word.

Two things worth carrying out of building it:

**The check that came with it composes TWO rices, which nothing here had done.**
`nix flake check`'s new `packs` evaluates the shipped pack against a host that
redefines one field and reads three properties back — host won, other entries
survived, rest of the entry survived. It is **mutation-checked**: swapping the
per-leaf `mkDefault` for the family-level one fails it with *"left 1 of 4
entries"*, which is the whole finding turned into a failure message. Every check
in this repo that pins a table pins one rice; this one pins a **relationship**,
and the readiness test's blind spot was always relationships.

**A plain host assignment settles a pack-vs-pack collision too** — measured
while writing the docs, not predicted. Two packs at `mkDefault` naming one app
still conflict, but a host that names the same app outranks both at once and the
conflict never arises. So the escape hatch for the one case that still stops the
build is "say what you want", not "learn `mkForce`".

What it costs, stated in the option's own docs rather than discovered: a pack
author is no longer told when a consumer disagrees with them. A pack proposes;
the machine's owner decides.

#### ★ The preset half, measured (2026-08-05) — and three of this section's own claims were wrong

rice#222 closed limit 3 for **packs** and left preset-vs-preset named as the
remaining gap, with "colliding is the intended answer" as the reason to leave it.
That reason was never measured. It is now, by the same machinery one file over:
[`probes/preset-composition.nix`](probes/preset-composition.nix) — the four
shipped presets, all six pairs, plus the escape hatches, through `lib.evalModules`
over the pure-lib option surface. Seconds, no darwin system, Linux-CI-capable.

| pair | overlap | disagree | verdict |
|---|---|---|---|
| `[ full minimal ]` | 5 | 4 | conflict on pounce/prowl/sill/tour — **`developer.enable` overlaps and does not collide** |
| `[ everyday full ]` | 5 | 2 | conflict on `developer.enable`, `prowl.enable` only |
| `[ everyday minimal ]` | 5 | 4 | conflict on developer/pounce/sill/tour — they **agree** prowl is off |
| `[ everyday large-print ]` | 0 | 0 | composes |
| `[ full large-print ]` | 0 | 0 | composes |
| `[ large-print minimal ]` | 0 | 0 | composes |

**(a) Overlap is not collision — `mergeEqualOption` accepts identical
definitions.** Every sentence in this document about two rices "happening not to
overlap" was describing the wrong property. The real rule is **two rices compose
iff they never *disagree***, which is a far weaker requirement and a far better
story to publish: a gallery rice that restates a value you already hold costs you
nothing. Three of the six pairs above overlap and still compose *partially* — the
conflict is per option, not per file.

**(b) ★ The error is better than this section said, and the fix made it worse.**
Limit 3 was written as "the error they see is a nix conflict trace rather than
anything this project wrote". Measured, with the rices imported **as paths** —
which is exactly what `extraModules = [ nebelhaus.presets.everyday … ]` is:

```
error: The option `nebelhaus.sill.enable' has conflicting definition values:
       - In `…/presets/minimal.nix': false
       - In `…/presets/everyday.nix': true
       Use `lib.mkForce value` or `lib.mkDefault value` to change the priority…
```

That names the option, both files and the fix. It is not friendly, but the
premise for option 2 ("detect and translate") was that the consumer is told
nothing — and they are told nearly everything.
→ **But a seam that TRANSFORMS a rice erases the filename.** `lib.pack` builds a
new attrset out of the pack's data, so its definitions have no file, and the one
case rice#222 deliberately left loud — two packs naming one app — reports
``- In `<unknown-file>'`` **twice**: loud and anonymous, with nothing to tell the
consumer which two packs disagreed. Measured, then **shipped in rice#228** —
`_file = toString path` in the module `pack` returns, verified end to end, with
a third rule in the `packs` check because nothing on this machine would ever
notice it regress. **Any wrapper applied to someone else's module owes it a
`_file`.** So the seam built to improve the collision story had, for four days,
made the one collision it deliberately keeps strictly worse than doing nothing —
which is the argument for measuring a fix's *failure* path, not only its success
path.

**(c) The pack escape hatch does not transfer.** rice#222 found that a plain host
assignment settles a *pack-vs-pack* collision, because both packs sit at
`mkDefault` and a normal definition outranks them both. Between two **presets**
the same host line is a *third* normal definition and the build still stops — on
all five options, one more than before. The consumer needs `lib.mkForce`, at the
exact moment they are least equipped to know it.

**(d) Presets at `mkDefault` would not help either** — two equal-priority
defaults conflict exactly like two equal-priority values (measured: still four
collisions). Option 1 is a fix for **host-vs-rice**, and can never be one for
rice-vs-rice.

**(e) ★ Option 4, which this section never considered: priority by LIST
POSITION.** The refuted model — *imported later wins* — is false as a
description of the module system and perfectly implementable as a mechanism on
top of it. `compose [ a b ]` stamps each rice one `mkOverride` weaker than the
one after it; the last definition of any option outranks every earlier one and
everything non-overlapping survives. Measured in both directions, so it is order
rather than luck: `compose [ everyday minimal ]` resolves the rooms to minimal's,
`compose [ minimal everyday ]` to everyday's, and `compose [ everyday
large-print ]` keeps all nine values.

Two costs, both measured rather than predicted:

- **It composes at the OPTION level, not the RICE level, so you get a blend.**
  `compose [ everyday minimal ]` yields minimal's rooms **plus everyday's
  `tour.steps`**, because minimal never mentions steps — a machine with the tour
  off carrying the other rice's authored tour step. That is limit 3's own class
  again: valid parts composing into something nobody chose.
- **The wrapper has to find the option boundary, not count levels.**
  `pack-priority.nix` hand-rolled two `mapAttrs` because it only ever walked
  `roster`; a preset sets arbitrary paths, so the wrapper must walk the data
  against the evaluated `options` tree and descend through `attrsOf` submodules.
  Wrap above the boundary and you replace a value instead of setting a priority
  — the silent three-quarters-of-the-pack failure, one family up.

**(f) ★ And some options never conflict at all — they MERGE, silently.** Two
rices each authoring one `tour.steps` entry produce **both**, concatenated, in
*reverse* import order, with no error and no warning. So composing two strangers'
rices has two failure modes and this document only ever described one: a **loud
conflict** on scalar options, and a **silent blend** on every list- or
attrs-valued one — `tour.steps` (§5.13's whole mechanism), `roster`,
`theme.ports.handled`, `agents.clients`, and `theme.palette` when §5.1 builds it.
The loud one is the one we have been designing against, and it is the one that
can't hurt anybody.

**✅ Decided 2026-08-05: publish the rule, don't build `compose`.** The seam is
cheap and would make the sentence three READMEs already believed true — but the
measurement that made it buildable is the same measurement that removed the
reason to build it. Option 4 was proposed while limit 3 believed a colliding
consumer got an unattributed trace; they get a named option, two named files and
the fix. What the seam would add on top of that is a *blend nobody chose* —
exactly the failure class this document keeps re-finding — in a format whose
whole pitch is that you can read a rice and know what it does. **The rule
shipped instead, in both places a stranger meets it** (rice `presets/README.md`,
`guides/sharing-a-rice.mdx`):

> **Two rices compose unless they disagree.** Same option, same value: merges.
> Same option, different values: the build stops, naming the option, both files
> and `lib.mkForce`. And an option holding a list or a set never conflicts at
> all — those definitions are **combined**, silently.

The asymmetry is what settled it rather than the argument: adding `lib.compose`
later is additive and breaks nobody, while removing it after a gallery has rices
that depend on ordering breaks strangers' configs. Waiting costs a line of docs;
shipping early costs the option to change our mind.

The last clause is the half nobody knew, and it is now the more useful warning
of the two: the loud failure mode is the one that can't hurt anybody.

#### ★ And the rule is a check now — `preset-composition` (rice#239, 2026-08-06)

Deciding not to build `compose` left the rule as prose in two READMEs, which is
exactly the shape §5.14 says a finding should not be left in. It is a golden
table now, in `nix flake check`, pure lib beside `packs`:

```
[ everyday full ] overlap 5 disagree 2 stops on developer.enable, prowl.enable
[ everyday large-print ] overlap 0 disagree 0 composes
[ everyday minimal ] overlap 5 disagree 4 stops on developer.enable, pounce.enable, sill.enable, tour.enable
[ full large-print ] overlap 0 disagree 0 composes
[ full minimal ] overlap 5 disagree 4 stops on pounce.enable, prowl.enable, sill.enable, tour.enable
[ large-print minimal ] overlap 0 disagree 0 composes
a host restating full's developer.enable composes
a host contradicting full's developer.enable stops on developer.enable
the same, with lib.mkForce composes, host wins (developer.enable = false)
[ everyday minimal ] plus a plain host contradicting the prowl.enable they agree on
    stops on developer.enable, pounce.enable, prowl.enable, sill.enable, tour.enable
two rices, one tour step each: B, A (merged, no error)
two rices, one app each: obsidian, zotero (merged, no error)
```

(The tenth row is one line, wrapped here.) Every clause of the published rule is
a row: overlap-without-disagreement composes — row 1 shares five options and
stops on two, and row 7 is a host restating what a preset already holds —
disagreement stops the build and names the
option, `mkForce` settles it, a plain host does **not** settle a *preset*
collision — and it makes it worse by one, which is finding (c) of the 2026-08-05
measurement above turned into a number — and the list-valued options blend with
no error, in reverse import
order. The pairs are generated from `presetFiles`, so a fifth preset arrives with
four new rows that somebody has to fill in.

Three things from building it, none of them predicted:

**(a) ★ Derive the fixture from the rice; never name it.** The first draft
hardcoded which option the host contradicts. The "a plain host does not settle
it" row then measured the wrong thing — the option it picked was one `everyday`
and `minimal` *already* disagreed about, so the host joined an argument instead
of starting one, and the row read 4 where the finding is 5. Deriving *the option
those two presets agree on* fixes it permanently and prints the option into the
row. **A golden table should print its own subject**, or it can go on passing
while testing nothing — the vacuous-check failure mode, which is the same class
as everything else limit 3 keeps turning up.

**(b) The obvious name was taken, and by something that answers a different
question.** `presets` already existed: it evaluates each rice **alone** into a
real darwin system, and it's darwin-only. `preset-composition` asks what happens
when one meets another, and is pure lib. §6 has said twice that the readiness
test's blind spot is relationships; the check list now shows that split at a
glance instead of only in this file.

**(c) The rice's pinned `nixfmt` still reformats what it didn't touch** — 50
unrelated lines in `flake.nix` at HEAD. Same trap as §8's, from the other side:
`nix fmt` on a repo that isn't fmt-clean buries the change. Format, keep only the
new region, restore the rest.

### What the readiness test can and can't see, after limit 1 closed

Three things fall out of running the audit twice in one day, and they're really
one thing: **the test proves the surface can EXPRESS a rice, and every limit
found so far came from BUILDING one.**

- **Limit 1 was found by writing `large-print`. Limit 3 was found by composing
  `packs.writing` onto a real host.** Neither is visible from the option surface
  — both files pass `checkRice` and `nix flake check` in isolation.
- **The sharpest case yet is §5.5's tour, and it passed everything.** `everyday`
  is data-only, `checkRice` returns true, `nix flake check` evaluates a real
  system from it, and the preset shipped **no tour pill at all** while setting
  `tour.enable = true`. No check in the repo could have caught it, because
  nothing was wrong with the *configuration* — the rice simply had nothing to
  draw and said so to nobody. That is the same class as limit 3: a composition of
  valid parts producing an experience nobody chose.
- **But composition itself is cheap to test, which nothing here had noticed.**
  Limit 3's five compositions were answered by `lib.evalModules` over
  `modules/options-modules.nix` and the pack file — seconds, no darwin system,
  and pure lib, so it runs on Linux CI beside `keymap` / `theme-variants` /
  `data-only-surface`. The readiness test evaluates each rice **alone**; a
  compose-two-and-look check is the same machinery with a second module in the
  list, and it is the one thing that would have caught limit 3 before a real
  host did. ✅ **It exists now** — `nix flake check`'s `packs` (rice#222)
  composes each pack with a host that fights it. "We've never run the test with
  two overlapping files" has stopped being true; the remaining gap was
  preset-vs-preset, where colliding was assumed to be the intended answer.
  ✅ **Measured 2026-08-05** (`probes/preset-composition.nix`, all six pairs of
  the shipped presets) — and the assumption was three-quarters wrong: overlap
  isn't collision, the error names both files, the pack escape hatch doesn't
  transfer, and the options that *don't* collide blend silently. See limit 3's
  preset half above. **A `presets` check has the same shape as `packs` and one
  extra requirement: it has to assert a collision as well as its absence**, so
  it pins which pairs are advertised as stackable (`[ everyday large-print ]`)
  and which are advertised as alternatives (`[ everyday minimal ]`) — ~~today
  nothing would notice a preset growing a field that quietly breaks the pair
  the README tells people to use.~~
  ✅ **Answered 2026-08-06 — `preset-composition`, rice#239** — see the
  subsection below. Mutation-checked the way `packs` is: adding one line to
  `everyday` that `large-print` also sets fails it with
  `[ everyday large-print ] overlap 1 disagree 1 stops on ui.scale`, which is
  precisely the sentence the README would have quietly stopped meaning.
- So the honest scoreboard reads: **the surface is no longer the constraint.**
  What's left is breadth (§5.6's seven uncurated groups), ~~one schema
  migration (§5.4's `workspaces`, still the last unstarted Phase 3 item)~~,
  trust (§5.11) — and limit 3, which is the only one a stranger hits on day
  one. ✅ **§5.4 shipped 2026-08-07 (nebelhaus#253)** — see that section; Phase
  3 has no unstarted item left.

**The next real finding is on a machine, not in this file.** Limit 3's option 1
has since been tried on `packs/writing.nix` — in an evaluator, which was enough
to settle the *mechanism* (see the measurements above) and is not enough to
settle whether a stranger prefers it. What is still only on paper: the third
reference rice — the mouse-first writer — is represented by a pack nobody who
writes for a living has installed.
→ ✅ **2026-08-07: run one rung up from the evaluator, and it held.** Not on
paper any more, but not a stranger's machine either — the middle rung. A real
`mkNebelhaus` build (home-manager and all, not `lib.evalModules` over the pure
option surface) composing `presets.everyday` + `packs.writing` against a host
that already owns Obsidian on its own letter produces a real `darwin-system`
derivation, actually realised: host's key wins, the pack's other three apps
and Obsidian's `workspace`/`cask` survive, the built Brewfile lists all four
casks. The unwrapped-path contrast case (`packFiles.writing` dropped straight
into `extraModules`, skipping the `packs.writing` seam) still conflicts, and
with a real file-based host both sides of the error name themselves correctly
— rice#228's `_file` fix confirmed outside `packCompose`'s synthetic host. What
this doesn't settle: everything above was run by the same agent that can read
the fix, not a person meeting the mechanism cold. The mouse-first writer
reference rice — a `presets/*.nix` a stranger would actually pick, not
`packs/writing.nix` composed by hand — is still unwritten, and "a pack nobody
who writes for a living has installed" is still literally true. That's the one
rung left, and it needs an outside person, not another eval.

**Surface drift worth knowing when reading the rest of this document.** §1
counted ~44 leaves; there are **130** now. Four rooms appear nowhere above:
`agents.*` (which client ⌘A spawns), `apps.*` (the rice's editorial picks and
their file types), `perch.*`, `zen.*` — the last of which exists *because* of
§5.1's accent finding. Going the other way, **`trill` is out of the rice
entirely** (rice#212 made it opt-in, rice#213 removed the module and the flake
input): development is frozen, perch is the bet, and a supported option nobody
should turn on was a lie in the option reference.

---

## 7. Repo routing

Per the workshop's routing table, this work is **not** one repo:

| Work | Repo |
|---|---|
| every `nebelhaus.*` option, `developer.enable`, presets, packs, `haus` | `nebelhaus` |
| theme flavors, light mode, high-contrast palette, port metadata, contrast CI | `nebelung` |
| command packs, typed commands, per-item settings, palette-as-settings-app | `pounce` |
| generated options reference, community rice gallery, the guides | `web` |

**Not `trill`, any more.** It was in this table's orbit through §5.1's "bakes its
own colours" list; rice#212/#213 removed the module and the flake input outright,
so nothing in this roadmap routes there. `perch` inherited the prose — it's the
example of a bundle-copying room now.

Breaking option renames (e.g. `roster.*.workspace` → `workspaces`, or the
`apps` → `roster` rename itself in rice#182) couple a
consumer lock-bump and a config edit into one PR — `bench ship` can't split
them without breaking main mid-ripple.

**Ordering, learned on §5.1.** A rice change that consumes a new nebelung output
can't carry its own lock bump — the bump isn't computable until nebelung's PR
lands. The way to keep the rice PR independently reviewable is to make the
**default path** need nothing new: `modules/lib/nebelung.nix` re-derives the
variant-subdir rule rather than reading nebelung's `variants` output, so
`flavor = "mocha"` still evaluates against the old lock and CI stays green, while
`flavor = "latte"` throws a message naming `nix flake update nebelung`. The cost
is one rule mirrored across the repo boundary; the mitigation is that both sides
hold it in exactly one place and `nix flake check`'s `theme-variants` pins the
table, because that mirror's failure mode is silent (a wrong subdir is a store
path that doesn't exist, discovered at activation).

**The better answer to the same problem, found on §5.1's next PR: ship the rule as
DATA from the upstream repo.** `theme.ports` needed far more cross-boundary
knowledge than `variantDir` did — 53 ports × where each theme goes, how it
installs, whether dropping the file is enough — and mirroring *that* would have
been unmaintainable. nebelung#19 ships `ports.meta.json` instead and the rice
reads it, so there is no second copy to drift and a port rename surfaces as an
eval-time assertion (`theme.ports.handled` checks every id is real) rather than a
missing store path at activation. The rule of thumb this leaves: **mirror only what
fits in one expression and can be pinned by a golden test; anything table-shaped
becomes an output of the repo that owns it.** Phase 3.5's tripwire break is the
same lesson from the failure side — when a downstream repo reads an upstream's
internals directly, a refactor upstream is a break with no local signal, so the
seam should be a declared output (`options-json`, `wm-bindings-json`,
`ports.meta.json`) every time.

---

## 8. What a cloud session can actually verify here

Recorded because §5.1/§5.5 were done from Claude Code on the web, and the house
rule is to *diff derivations rather than assert no-change* — which needs some
care when a full `nix eval` is off the table.

**Doesn't work** (as the workshop CLAUDE.md says): a darwin evaluation, `bench
try`, `nix flake check`, or nebelung's `nix build`. nixpkgs, nix-darwin,
home-manager and catppuccin all resolve through the session's GitHub gate and
only nebelhaus-org repos are in scope.

**Does work, and was enough for real proofs:**

- **nixpkgs via the channel tarball.** `https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz`
  is not GitHub, so it fetches, and `cache.nixos.org` is reachable. That gives
  `pkgs`/`lib`, `nixfmt`, `shellcheck` and `runCommand` — everything except the
  darwin module set.
- **The options surface, diffed as a derivation.** `packages.<linux>.options-json`
  evaluates only the per-room `options.nix` files (that's why §3.1 mattered), so it
  can be built standalone before and after a change and every leaf's type +
  default compared. "Exactly four new options and nothing else moved" is a diff,
  not a claim.
- **The generated artifacts, diffed.** `aerospace.toml` and the pounce cheatsheet
  are pure functions of a few config values, so a harness can call the real tables
  and render both revisions. That's what proved the §5.5 refactor byte-identical at
  the default keymap — and it earned its keep by catching two bugs a patch read
  wouldn't have: token names written in `aerospace.toml`'s own **prose** (the
  substitution is blind to comments, so generated bindings landed mid-sentence),
  and a stray blank line from a newline-terminated token above a blank template
  line.
- **nebelung end to end.** `node --test` runs natively, and `whiskers` builds from
  crates.io (`index.crates.io` bypasses the proxy). Version 2.9.0 reproduces the
  committed `dist/` byte-for-byte, which is what makes "the latte variants are a
  pure addition" a `git status` observation rather than an assertion.
- **New checks written to be Linux-capable on purpose.** `theme-variants` and
  `keymap` are pure `lib`, like `options-json`, so they run in this environment AND
  in the docs repo's Linux CI. Anything needing a darwin system stays guarded
  behind `optionalAttrs isDarwin`.

**One trap.** `nixfmt` from the tarball is 1.4.0 and the repo is formatted with an
older one — 137 lines of churn on `flake.nix` at `HEAD` alone. *(Re-measured
2026-08-06: 108 lines, and with the rice's OWN pinned 1.4.0 — so the version gap
was never the whole story. The real cause is the paragraph below: the tree has
never actually been formatted, because the command everyone runs doesn't.)*
Running it would
bury a change in reformatting, so: check new files for cleanliness, match the
surrounding style by hand, and don't reformat existing ones.

★ **And the obvious way to check that is a false green: `nix fmt` with no
arguments formats NOTHING in the rice.** The flake's `formatter` is bare
`nixfmt`, which ignores a directory argument and exits 0, so `nix fmt` on the
tree is a silent no-op while `nix fmt path/to/file.nix` really formats. Anyone
concluding "the formatter changed nothing, so my hunk is clean" has measured the
no-op. The way to check one region without reformatting the file: copy it, run
`nixfmt` on the copy, `diff`, and hand-apply only the hunks inside your own
region. (Making `nix fmt` recurse is a one-line formatter change plus a ~108-line
reformat commit — worth doing deliberately, not inside another change.)

---

## 9. Naming (optional, low stakes)

The family speaks cat-and-house (`nebelung`, `pounce`, `prowl`, `sill`, `den`,
`hearth`, `collar`, `hush`, `perch`, `haus`, `holt`). New rooms could keep it —
minus two names this table can no longer have: **`perch` is a shipped product**
(the notch file shelf), and `trill` left the rice entirely in rice#213. Names in
this family get taken while a table like this sits still:

| Room | Candidate | Why |
|---|---|---|
| accessibility — vision | `eyes` | cats' defining sense; `nebelhaus-ears.png` already exists in sill |
| accessibility — motor | `paws` | |
| accessibility — hearing | `ears` | |
| keymap | `claws` | what the leader key is |
| displays / multi-monitor | ~~`perch`~~ | taken — it's the notch file shelf now, and the room shipped as `nebelhaus.displays` anyway (§5.10) |
| scenes | `moods` | the states the cat is in; `hush` becomes one |
| dev pack extracted from hearth | `quarry` / `kit` | weakest of the set — probably just call it `developer` |

Not a blocker. `nebelhaus.accessibility.vision.*` is clearer to a stranger than
`nebelhaus.eyes.*`, and strangers are the point.

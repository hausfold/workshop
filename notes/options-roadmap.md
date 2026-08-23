# Option-surface roadmap — from "Julien's dev rice" to a shareable rice format

Working doc. The end goal: people publish **haus configs** of wildly
different kinds — a large-print Mac for a parent, a writer's machine, a
mouse-first creative setup — by changing `haus.*` and nothing else. When
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

> **⏹ CLOSED 2026-08-23 (forty-first pass). Read this before §1.**
>
> **This document is done as a working doc, and the reason is not that the
> boxes ran out — it is that the ones left are no longer the kind of thing
> writing haus can close.** Forty passes and the last three builds took it
> from ten open boxes to **seven**, and every one of those seven is blocked on
> something outside a session's reach:
>
> | § | Box | What it is actually waiting on |
> |---|---|---|
> | 5.1 | `scheme = "auto"` ◐ | a **resolution rule** between `flavor` and system polarity, already settled at the default; the open half is a design call, not code |
> | 5.1 | `flavor = "custom"` + `theme.palette` | **nothing** — it is buildable today, and is deliberately not built: closing the document was chosen over opening its last feature |
> | 5.3 | the app-side `sans` | **three other repos.** pounce takes it in a line, perch is a notarized zip, trill has no seam at all — the blocker is a consumer that can be told, and it is not haus's to add |
> | 5.5 | non-QWERTY untested | **a keyboard nobody here has.** The option exists; what is missing is a person on an AZERTY layout |
> | 5.9 | pounce command packs | **a decision** — whether a "pack" reduces to preset fragments — and then pounce's repo |
> | 5.9 | commands declare mutates / confirm / network | **pounce's repo**, to a shape nebelung's `ports.meta.json` already set |
> | 5.10 | multi-display arrangement ◐ | **a cable.** The design is written and the read half shipped; the arithmetic needs two panels attached |
>
> One of those seven is an exception worth naming rather than hiding: **§5.1's
> `flavor = "custom"` is not blocked on anything.** It is the last feature this
> document proposed, it is buildable, and the call was made to stop here
> instead. A roadmap that closes by quietly re-classifying its remaining work
> as impossible is worse than one that says which line it chose not to cross.
>
> **What "done" means: this file stops being a plan and becomes a record.** The
> passes that kept it honest do not stop — they moved to
> [`drift.md`](drift.md) three passes ago, which is where a shape found in any
> repo now goes. Nothing here should be re-opened by editing a checkbox; a box
> that comes back to life comes back as a PR, and this file records what it
> found.
>
> **Two findings from the closing pass itself, both of which outlive it:**
>
> **(a) A box whose precondition is a PERIPHERAL has no stable state.** Every
> other blocker this file tracks is monotonic — a bug is fixed, an option
> ships, a lock moves — so a pass can write "no longer blocked" and be believed.
> §5.10's precondition went away on 2026-08-23 and came *back* four hours
> later, because a Studio Display was unplugged. Nothing was wrong with either
> note. Re-derive a peripheral precondition at the start of the session that
> depends on it, never off the file.
>
> **(b) The instruction that opened this pass was already stale in two of its
> three parts, and the file was what said otherwise.** §5.9's check had merged;
> §5.10's dock had gone. Both were re-derived against the repos and the machine
> inside the first ten minutes, which is the only reason the work landed where
> the work was. **A roadmap describes when it was written; a repo describes
> now** — and a document being declared finished is exactly when that gap is
> widest, because nobody is re-reading it any more.

> **★ Naming banner, 2026-08-08 — read every `haus.*` below as `haus.*`.**
> The platform is **`haus`** — its own name since 2026-08-10 (decision 8), and
> also its CLI and its option namespace — shipped by the org **hausfold**,
> and `haus` demoted to what this document has always been arguing it
> should be: **one rice among many**, the developer-focused one.
>
> **The body of this file is deliberately NOT rewritten.** §5.14 makes it a
> historical record, and retroactively renaming options in dated findings would
> make ship-dates and PR numbers stop matching what those PRs actually say.
> So: `haus.roster` below is today's `haus.roster`, and so on throughout.
>
> **⚠️ Every `trill` below is the archived Messages client** (`hausfold/messages`
> since 2026-08-08), so "**`trill` is out of the rice entirely**" — the claim
> recurs five times, in the preamble's progress log, §3.1, §6's tail, §7 and §9,
> spelled differently each time — stays true *about that app*: rice#212 made it
> opt-in, rice#213 deleted the module and the flake input. It is **not** true of
> the name. The notification compositor took `trill` on 2026-08-08, and the
> rice's roster
> carries a `haus.roster.trill` entry for it (renamed from `haus.roster.flick`,
> haus#264) — metadata-only, a `float` rule for its Settings/Inbox windows
> in `modules/windows/default.nix`; the rice installs nothing and the app has no
> repo yet. So a reader who greps this file for what the rice declares concludes
> the opposite of what's live — read the app, not the word. §9's "names this
> table can no longer have" is the one line here that is about the *name*, and it
> is now doubly true.
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
> `<unknown-file>` twice. ⚠️ **Corrected 2026-08-14:** this used to name §6(e)'s
> **priority by list position** (`compose`) as "the live candidate" — it is not,
> and §6(e) itself says so. **`compose` was decided against on 2026-08-05**, in
> the same pass that measured it buildable: the measurement that made the seam
> possible removed the reason for it, because a colliding consumer gets a named
> option, two named files and the fix, and what the seam would add on top is *a
> blend nobody chose*. The rule shipped instead, in both places a stranger meets
> it (rice `presets/README.md`, `guides/sharing-a-rice.mdx` — **all three of
> those are gone now**: the presets dir survives only as `compat/presets.nix`,
> the Astro guide is deleted, and `preset-composition` retired with its subject;
> see the ⚠️ at §6(f)), and it is a golden
> table in `nix flake check` since rice#239 (`preset-composition`). Adding
> `lib.compose` later is additive and breaks nobody; removing it after a gallery
> depends on ordering breaks strangers — so waiting is the decision, not the
> backlog. **What actually binds a second rice in `/desktops` is §6(f): the
> silent blend.** List- and attrs-valued options (`tour.steps`, `roster`,
> `theme.ports.handled`, `agents.clients`) never conflict — they concatenate, in
> reverse import order, with no error and no warning. The loud failure mode is
> the one that can't hurt anybody; the quiet one has no check and no story yet.
> ⚠️ **Amended 2026-08-08:** an earlier version of this paragraph read "what
> `/desktops` should wait on", and the page shipped that day with a working
> install command anyway — correctly, because every clause above needs *two*
> rices composed and there is one. The blocker is real and it binds the second
> entry, not the page.
> ★ **Repealed for desktops 2026-08-14, hours after the correction above.** The
> correction re-pointed the gate from §6(e) to §6(f) and left it standing; the
> **desktop seam** retires it. A host selects *exactly one* desktop and a second
> is rejected at the seam ([`rooms-desktops.md`](./rooms-desktops.md), step 3,
> shipped), so the two rices §6(f) needs can never both arrive; and where the
> blend could still have bitten — desktop vs host — the seam answers it by rule:
> a desktop's leaves land at priority **900**, and a host naming a list
> *replaces* the desktop's list rather than appending to it. **The silent blend
> survives exactly where the model still allows two of something**: two packs,
> or two raw `extraModules` fragments. Those rows are why `preset-composition`'s
> generalisable half moved into `fragment-compat` instead of retiring with its
> subject. So §6(f) stays open as a *format* limit and is no longer a gate on a
> `/desktops` entry — `everyday` and `minimal` were listed on 2026-08-14 and
> nothing composed. What a third-party entry waits on now is acquisition and
> trust, which is [`go-to-market.md` §5](./go-to-market.md#5-the-gallery--marketplace-question--answered)'s
> problem, not this file's.
>
> ⚠️ **And "exactly" is the wrong word as of 2026-08-20.** The two-member list
> above is complete for *definitions* — two authors each setting a value — and
> misses the **declaration** layer entirely, where two modules sharing a
> namespace merge into silent co-ownership with no stranger involved and no
> desktop in sight. Measured; see §6(f)'s amendment and the thirty-first pass.
>
> What §7's repo routing means now: `haus` → `hausfold/haus`, and `web`
> → the consolidated site repo.
>
> ★ **Amended 2026-08-15 (decision 10, haus#364): the desktop this document is
> about is called `hacker` now, and the banner's translation rule cannot reach
> the word that moved.** The rule above is *"read every `haus.*` below as
> `haus.*`"* — keyed on the dot, because in August the thing being renamed was an
> option namespace. Decision 10 renamed the **bare** word: the desktop
> `haus` is `desktops/hacker.nix` / `haus.desktops.hacker`, and every other
> surviving `haus` in the layer became `haus` (`mkHaus`→`mkHaus`, the
> env vars, the state dirs). Counted over the body proper — §1 onward, so the
> number doesn't grow every time a pass writes the word — **it appears 137 times
> and the dotted rule translates 63 of them correctly**, plus two it matches and
> gets *wrong* (`hausfold.co` and a `.md` filename, both of which stay). Read
> the remaining seventy-odd in three senses, none of which that
> rule covers: **the repo** (`haus/modules/…`,
> `haus#NNN`) → `hausfold/haus`, unchanged as a citation; **the desktop**
> ("a non-dev haus", "publish haus configs") → `hacker`; and **the org
> or the domain** (`github.com/hausfold`, `hausfold.co`) → *stays*, forever.
> `mkHaus`, `desktopFiles.haus` and the four state-dir symlinks were
> deliberate compatibility seams at the time (all four are gone as of
> 2026-08-16), so nothing here was broken by the rename — it
> is only mis-named. The body stays un-rewritten for the reason given above.
>
> ★ **Amended 2026-08-16 (haus#367): the rooms are named for what they do now,
> and for the eight addresses that touches, applying the rule above is WORSE than
> ignoring it.** `haus.sill`→`haus.bar`, `prowl`→`windows`, `hearth`→`terminal`,
> `pounce`→`launcher`, `perch`→`shelf`, `hush`→`focus`,
> `collar`→`security.touchId` ([`rooms-desktops.md`](./rooms-desktops.md#the-names-2026-08-16)),
> **with no aliases** — the old `haus.*` spellings are gone, not deprecated.
> `modules/renamed.nix` is untouched, and that is the whole point: its left-hand
> sides are the frozen `haus.*` names, so the literal `haus.pounce.items`
> printed below **still evaluates**, now onto `haus.launcher.items`, while the
> banner's own instruction turns it into `haus.pounce.items`, which is an unknown
> option and a hard eval failure. A translation rule aged into a trap: the
> untranslated text is the one that works. Run over §1 onward,
> `grep -oE '\b(haus|haus)\.(hearth|prowl|sill|pounce|perch|hush|collar|den)\b'`
> returns **ten**: eight `haus.pounce`, which are addresses — read them as
> `haus.launcher.*` — and two `haus.sill`, which are **not**: they sit
> inside §6(b)'s quoted error transcript, where the whole point is what the
> option was called on 2026-08-05, so they must not be translated at all. ⚠️
> Those two were added by the very pass that wrote this paragraph, whose first
> draft said "eight, all `haus.pounce`" and was falsified by its own commit
> — caught by the assurance read. Every other `haus.<x>` below takes the
> 2026-08-08 rule unchanged.
>
> The reason there are only eight is worth a sentence, because it inverts the
> usual complaint about this file: **where §5 sketched a room that had a code
> name, it wrote the room's own word, and the rename arrived at that word.**
> §5.9 is `haus.bar.widgets` / `bar.items` against a tree that said `sill`,
> and §5.8 is titled *Generalize `focus` into scenes* against a tree that said
> `hush` — both live addresses since 2026-08-16. (The rest of §5's namespaces —
> `keys`, `displays`, `lock`, `security.firewall`, `roster` — were never
> code-named, so they were never a proposal about anything.) Two sketches is a
> small sample and the point is not that this file predicted the rename; it is
> that **the document and the code used different words for the same room, for
> long enough that nobody experienced it as a contradiction**, because a sketch
> reads as pseudocode. That is also how a doctored quote got in — see §6(b),
> where the same word appears inside a fenced block presented as measured output.
>
> ⚠️ **The sentence above said "for six weeks" until 2026-08-20, and the number
> is dropped rather than corrected** — it was measured from the wrong end (this
> file dates itself 2026-07-25, three weeks before the rename) and only the
> "earlier brainstorm" it refines could reach six, whose own date nobody has. An
> interval no one can re-derive is worth less than the claim without it; see the
> twenty-fifth pass's flag, below. ⚠️ The note sits *after* the §6(b) sentence
> rather than before it, because its first draft cut the antecedent of "That" in
> half — an insertion that changes what a pronoun points at is a way to break a
> paragraph that no diff reads as a change to it.


> **The passes, and the drift catalogue they feed, are in
> [`drift.md`](drift.md).** Split out on 2026-08-23, after the thirty-eighth:
> the three most recent status blocks and §5.14's table of shapes live there,
> and the ones before them stay in
> [`options-roadmap-log.md`](options-roadmap-log.md) — **thirty-eight** dated
> entries, 2026-08-23 back to 2026-08-02, COUNTED at every move (`grep -c '^>
> \*\*Status, '`) and never incremented. ⚠️ **It read thirty-six until the
> fortieth pass**, which is what the rule is for: the thirty-ninth rotated one
> entry in and closed with *"both pointer counts re-COUNTED rather than
> incremented (37)"* — `drift.md`'s tail moved and this one did not.
>
> Read `drift.md` before treating any `- [ ] ` below as work: the first rule
> under *How this doc drifts* is that a box goes stale in ways this file cannot
> show you, and the audit is reading the repos, not this text.
>
> **Why the split, in one line, as measured on the day it happened:** the
> option surface had been 318 leaves for four consecutive readings while the
> drift table took a row in each of the last four passes. They had stopped
> being one subject. (Both streaks have run on since: six readings and six
> rows as of the fortieth pass.)

---

## 1. Ground truth (verified, not remembered)

| Claim | Reality |
|---|---|
| "~40 first-class options" | ✅ ~44 leaves in [`modules/options.nix`](haus/modules/options.nix) — but 13 of those are the `bar.items` pill bools and 5 are `focus.slack.*`. The *shape* surface is more like 25. |
| "rice sets ~19 macOS defaults" | ✅ 19 keys in [`core/default.nix:144-183`](haus/modules/core/default.nix:144). nix-darwin types **193** (counted, see the matrix) — not "several hundred" as this doc first said. |
| "replace `windows.apps` with a general app registry" | ⚠️ **Already done, and since superseded.** It was `haus.apps`; **rice#182 renamed it `haus.roster`** and grew it the multi-source install §5.4(a) asked for. `haus.apps` still exists but means something else now (the apps the rice picks for you). Read `apps` as `roster` everywhere below this line. |
| "add `haus plan` / `capture` / `diff` / `undo`" | ✅ **Promoted, 2026-08-07 (ninth pass, §5.11).** `haus plan`/`capture`/`diff`/`revert-settings` (`undo`'s real name) are real subcommands now, built on a probe of activation-script output rather than a hand-maintained domain map. `bootstrap.sh` keeps its own copy of the capture logic (it runs before `haus` is on PATH). |
| "minimal still imports the developer foundation" | ✅ **Confirmed, and it's the root blocker.** [`modules/default.nix`](haus/modules/default.nix) unconditionally imports `core`+`theme`+`terminal`+`security`+`secrets`+`snippets`. Turning off all three optional rooms still installs `bun`, `fnm`, `nixfmt`, `opencode`, `zellij`, `yazi`, `lazygit`, `delta`, `gh`, `jq`, `ttyd`, `wt` (now `holt`), `zscratch`, and a git-alias vocabulary. |

**Two mechanisms already in the repo that the brainstorm missed, and that change the plan:**

1. **Machine-writable config already works.** `mkHaus` auto-imports every
   `.nix` in `hosts/<host>/packages/` ([`flake.nix:76-95`](haus/flake.nix:76)) —
   that's how pounce's "Install App" command writes config without a parallel
   JSON store. **This is the mechanism for a GUI-editable rice** (§3.7), and
   rice#252 generalizes it to `hosts/<host>/settings/*.nix` + `haus set`.
2. **Registry merging means an app pack is shareable *today*.** A file that only
   sets `haus.roster.*` composes cleanly across modules. That's a
   zero-architecture v0 of the community (§6, Phase 0).

---

## 2. The reframe

The current options expose **implementation** (Pounce, Bar, AeroSpace, Homebrew).
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

### 3.1 Split `options.nix` per room · ✅ **DONE** (haus#92)
656 lines in one file for every room. Move to `modules/<room>/options.nix`,
keep `modules/options.nix` as the cross-cutting/identity file. Purely
mechanical, no behaviour change. **Do this first or everything else compounds.**

- [x] `modules/{core,terminal,windows,bar,pounce,focus,theme,trill,secrets,snippets}/options.nix`
      (the room list has moved since: `roster`, `displays`, `apps` and `perch`
      joined it, and `trill` is gone — rice#213 removed the module and its flake
      input, two days after rice#212 made it opt-in. The sentence to reuse: *a
      supported option nobody should turn on is a lie in the option reference.*)
- [x] `modules/options.nix` keeps `apps` + `developer` (752 → 122 lines). `git`/`claude` went to terminal, which owns them.
- [x] Verified as a pure move: the example host's derivation is byte-identical and all 39 leaf option paths are unchanged.

### 3.2 Make `developer` a real pack, not the foundation · ✅ **DONE** (haus#96)
The single highest-leverage change in this doc. Today "minimal" is a lie.

```nix
haus.developer = {
  enable = true;          # the whole dev pack — off means a non-dev Mac
  shell.toolbelt = true;  # bat/delta/lazygit/lsd/fzf/zoxide/yazi
  multiplexer = "zellij"; # zellij | none
  agents.enable = true;   # holt (was wt), zscratch, statusline, worktree binds
  git.enable = true;      # aliases, delta, lazygit, signing
  languages = [ "node" ]; # fnm/bun; extensible
};
```

- [x] Audited terminal and core; gated packages, `programs.*`, aliases, the fnm hook, Claude settings and nix-index
- [x] Gated `home.packages` and `environment.systemPackages`
- [x] `haus` / `awake` / `mas` / theme stay unconditional (they're the *product*)
- [x] Proved by measurement: `developer.enable = false` drops 16 system + 17 home packages.
      **Not literally zero** — `gh`/`blueutil`/`switchaudio-osx` remain as pounce
      command-plugin deps, which is correct while pounce is on.

**Non-obvious consequence:** with dev off, `terminal.editor = "hx"` is the wrong
default and Ghostty may not even be wanted. Decide what a non-dev haus
*terminal story* is (probably: no terminal at all, and `haus` reached only via
pounce).

### 3.3 Presets become the community format, from day one · ✅ **DONE** (haus#98)
The earlier plan put "define the community rice format" at step 9. Invert it.
Make the repo's own presets use the exact mechanism a stranger's rice would —
otherwise you'll build eight layers and discover the format can't express them.

- [x] `presets/{full,minimal,everyday}.nix` — each sets **only** `haus.*`.
      `large-print` deferred: it needs §5.1/§5.2/§5.3, which don't exist yet.
- [x] `bootstrap.sh` offers Everyday and emits `extraModules = [ haus.presets.X ]` —
      the same line a person writes to import a rice found online. "Custom" emits none.
- [x] `nix flake check` runs `checkRice` over every preset **and** evaluates a real
      system with each — trust half and usefulness half
- [x] `haus.lib.checkRice` exposed, with `presets/README.md` defining the format
      ⚠️ **Both are gone as of haus#386 (`mergedAt 2026-08-17T06:36:00Z`), and
      the box stays ticked because it records what shipped.** The preset dir
      survives only as `compat/presets.nix` (a warning, byte-for-byte the old
      values), and the *format* half was retired with the pack format beside it:
      `haus.lib.pack`, `checkPack`, `checkRice`, `riceBody` and `packFiles` all
      came off the public surface, leaving **two** shareable things, one per
      trust class — a **desktop** (data, closed schema, validated leaf by leaf by
      `lib.checkDesktop`, which haus can prove is inert) and a **room** (code, an
      ordinary nix-darwin module, which haus can prove nothing about and says
      so). So the self-test a stranger runs is `lib.checkDesktop ./my-desktop.nix`
      now, and `checkRice` in the prose below means the thing that used to do
      this job.

### 3.4 Generate the options reference · ✅ **DONE** (haus#93 + workshop#81)
[`web/src/content/docs/reference/options.md`](web/src/content/docs/reference/options.md)
is 389 hand-written lines. At 5× the surface it rots within a month.

- [x] `nix build .#options-json` → `web/scripts/gen-options.mjs` → the page
- [x] Narrative guides stay hand-written; only the reference is generated
- [x] `options-drift.yml` fails if the page is stale.
- [x] Found on the way: the old page documented `git.shellAliases` **twice** with
      two different descriptions, and covered 33 of 71 options.

⚠️ **Amended 2026-08-22 (thirty-fourth pass): the reference is faithful, which
is the whole problem, twice over.** Two things a generated page structurally
cannot say, found one day apart:

**(a) It publishes stale prose perfectly.** haus#398 regenerated `options.json`
in the same commit that freed the letter `e`, and changed two *other*
descriptions — the two enumerating launch mode's reserved keys had no diff to
carry, so the page advertised the wrong set for four more days (§5.5's
amendment). `options-drift.yml` compares the page to the options. Nothing
compares an option's prose to the data the same repo publishes beside it.

**(b) It cannot show that an option does nothing.** `haus.homebrew.adopt` —
one of the four leaves added since the last pass — is declared in
`modules/core/options.nix` with a type, a default of `true`, eighteen lines of
description and an entry in `modules/options-groups.nix`, and
**`config.haus.homebrew.adopt` is read by nothing.** `modules/core/default.nix`
inherits `autoUpdate`, `upgrade` and `cleanup` out of that namespace and
deliberately not this one: current Homebrew removed `brew bundle install
--adopt` and `bundle/cask.rb` now adopts unconditionally, so the option's own
last paragraph says setting it to `false` "is a no-op until Homebrew grows a
real way back". Honest, and invisible exactly where it would matter —
`modules/options-catalogue.jq`'s `summary` is the description's **first
physical line**, trimmed and cut at 78 columns, so `haus set`'s picker row
reads *"Whether a cask haus declares that is already sitting in"*: a fragment
that stops mid-clause, over a switch with no wire behind it. It is not a bug in
the PR — the option is there so the *intent* survives a Homebrew that grows the
flag back — it is a shape this section has no answer for. The check surface has
`data-only-surface` for "an option a data file cannot set" and nothing for "an
option nothing reads", and those are one grep apart.
⚠️ **How many other leaves are in that position was NOT measured.** `inherit
(config.haus.X) a b;` and per-module `cfg` aliases defeat a grep for the full
path, and a count derived from that grep would be this document's own row ten —
a negative claim proved by a pattern that cannot match what it is looking for.
The claim here is about one option, verified by reading its two call sites.

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
      → haus **warns** (haus#89 — a warning, not an assertion: with FDA
      these work, so blocking would be wrong), and it's reported on
      [nix-darwin#1049](https://github.com/nix-darwin/nix-darwin/issues/1049).
      → ◐ **Amended 2026-08-14 (§5.12).** The eval-time warning stands, unchanged
      and for exactly this reason. What was added beside it is a check at a
      different moment: `haus rebuild` now refuses to *run* when the config sets
      this domain raw and the current app can't write it. Not a contradiction —
      the warning is right that blocking a config that WORKS would be wrong, and
      the refusal only ever fires on the machines where it demonstrably doesn't.
      Escape hatch: `HAUS_FDA_ANYWAY=1`.

---

## 5. The option families, ranked

Ranked by *(unlocks a genuinely different rice) ÷ (effort)*.

### 5.1 `haus.theme` — break out of the Mocha-grey monopoly · L · risk M · ✅ **flavor + contrast + roster ports shipped**
**★ Biggest miss in the earlier brainstorm.** `theme.accent` is an enum of 14
Catppuccin Mocha names; the base palette is always Nebelung grey-dark
([`options.nix:335`](haus/modules/options.nix:335)). So:

- ~~There is **no light mode** anywhere in the rice.~~ **(✅ shipped — nebelung#12
  + haus#108: `theme.flavor = "latte"`.)**
- There is **no high-contrast mode** — the root requirement for the
  "old people" rice that started this whole thread. **(✅ shipped — see boxes.)**
- A community rice cannot ship its own colours at all. **(still true: `palette`
  for `flavor = "custom"` is not built. A rice can pick a flavor, not supply one.)**

Nebelung is whiskers-based, so it can render *any* palette — the ceiling is
the option surface, not the renderer.

```nix
haus.theme = {
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
- [x] rice: the flavor is in the **paths**, not just the colours — **haus#108**.
      whiskers names its output after the rendered flavor, so `latte` moves ghostty,
      bat, lsd, yazi, zen and zsh-syntax-highlighting filenames as well as hexes.
      The subtlest one: delta's single gitconfig carries **all four** flavor
      sections and only the rendered one holds Nebelung colours, so `features` must
      name the same flavor as the include's root or delta silently themes itself
      stock. Selection is factored into `modules/lib/nebelung.nix` (it had been
      duplicated in terminal/bar/theme; a second axis would have made that six
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
      → ✅ **Perch's row moved `pinned` → `moves` (haus#244 + perch#31,
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
      `about:` pages **⟨as placed — see the 2026-08-20 amendment below: haus#416
      appends compiled `@-moz-document` sections to that same file, so this
      clause is true only of a machine that leaves `haus.zen.userStyles` at its
      default `[ ]`⟩**. Real sites are **Stylus's** job, and its Catppuccin-derived
      styles carry their own accent var in the extension's storage, which no file
      the rice writes can reach. Fixed by declaring the extension and stamping a
      bundle (`haus.zen.extensions.stylus`) — which then also gave
      `high-contrast/` and `latte*/` a stylus dir to read, so flavor and contrast
      reach the web too. The lesson is the wording one: a scope sentence naming an
      *app* implies everything that app shows you, and a browser is the one app
      where that's wrong.
      → ⚠️ **Falsified 2026-08-20 — not the parenthetical, the conclusion.**
      [haus#416](https://github.com/hausfold/haus/pull/416) (`d6e8622`,
      2026-08-20T02:53:14Z) adds `haus.zen.userStyles`: name nebelung's
      userstyle slugs and the layer compiles them at build time, appending the
      result to the `userContent.css` it already symlinks into every Zen
      profile. The accent reaches github.com and youtube.com on a rebuild (and a
      Zen restart, which is when Gecko reads that file), with **no extension and
      no import click**. The clause above — the Catppuccin styles carry their
      accent var in the extension's storage, which no file the rice writes can
      reach — is still true *of Stylus*; what fell is the sentence it was there
      to support, **"Real sites are Stylus's job"**, because ruling out one
      route is not ruling out the space. ⚠️ The box's *other* premise did not
      survive: "`userContent` only styles `about:` pages" was falsified outright
      by the same PR, and is scoped in place above rather than left standing
      fourteen lines from the sentence that contradicts it — found by this
      pass's assurance read, which is the second time that step has caught this
      file asserting and denying one thing in a single box.
      → ★ **The generalisable half: an impossibility claim that is really a
      description of how the incumbent works.** The reason the accent stopped at
      `about:` pages was that Catppuccin's userstyles are LESS which **Stylus
      compiles in the browser** — 134 usercss styles, zero compiled sections,
      measured in that PR rather than assumed. Nobody had asked what doing that
      compile ourselves would cost: vendoring the catppuccin standard library
      every style imports (a Nix build has no network) and emitting every
      declared `@var`, since less dies on the first undefined one — YouTube's
      `@sponsorBlock` is how that was found. Two substitutions and a vendored
      lib, against a paragraph that read as a boundary. New row on §5.14's
      shapes table, and it is the only row there whose entry is wrong on the day
      it is written rather than decaying into wrongness.
      → Three things that stay true, so the box isn't over-corrected:
      `haus.zen.extensions.stylus` is untouched and is still the answer for
      per-site toggles, self-updating styles and adding a site without a
      rebuild — the room's callout carries both routes now and says what each is
      FOR (hausfold.co#92), which is the shape this file keeps asking for when a
      claim splits in two; the compiled sheet is opt-in and a **list**, because
      a user sheet applies to every document and github + youtube alone are
      ~320 KB against 7.1 MB for the whole bundle; and it is Gecko-only,
      permanently, since Chromium deleted user stylesheets in Chrome 33.
      → And one thing about the *check*, which is the twenty-second pass's
      question answered inside the PR that created the conditional:
      `accent-reach`'s fixture had to name a style
      (`haus.zen.userStyles = [ "github" ]`), because with an empty list the
      `zen` row fingerprints nebelung's own `userContent.css` and would never
      notice the accent dropping out of the compiled half.
- [x] ✅ **Felt on the real machine, 2026-07-27: 19.9:1 reads CRISP, not harsh.**
      That was the one open question a ratio couldn't answer, and it's the answer
      the high-contrast axis needed before anything could be built on it — so
      `large-print` shipping with `contrast = "high"` is now a felt choice rather
      than a measured guess. Worth recording because the doubt was reasonable:
      AAA-on-paper palettes routinely read as glare.
- [x] ✅ **Latte felt on the real machine, 2026-07-28: reads great.** Flipped
      `theme.flavor = "latte"` on mbp with macOS appearance set to Light, one
      `bench try switch`, and the whole terminal/bar/Zen surface came over — so light
      mode is a felt option now, not just a rendered one.
- [ ] ◐ `scheme = "auto"` — **one consumer shipped it, and it wasn't the one this
      box expected.** No bar-hosted watcher was needed: pounce#42 + rice#142 give the
      palette `theme`/`themeLight` and it picks per open, exposed as
      `haus.pounce.followSystemAppearance` (default **true**). Three things
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
      ⚠️ **Amended 2026-08-20 (thirty-third pass): there is a second candidate
      now, and it arrived by a room being retired rather than built.** haus#445
      dropped the Stylus half of Zen's web theming, so the palette reaches real
      websites through `haus.zen.userStyles` alone — compiled by
      `modules/terminal/default.nix` into a single
      `zen-userContent-<flavor>-<accent>.css` and installed into the profile's
      `chrome/`. That is a *file* picked at build time, and Gecko reads it once
      at startup, so the web half is pinned twice over: to `theme.flavor`, and
      to when the browser last launched. Nothing regressed — the Stylus bundle
      it replaced was flavor-stamped too, and the PR's own list of what the
      click bought and the sheet gives up (per-site toggles, self-updating
      styles, adding a style without a rebuild) is accurate as far as it goes.
      What changed is the SHAPE of the remaining fix. Under an extension it
      would have meant handing a second bundle to somebody else's settings;
      under a compiled sheet it is two compiles concatenated under
      `@media (prefers-color-scheme: dark)`, in the `runCommand` haus already
      writes, with no watcher and no second option — which would make the web
      the cheapest instance of (a) in this section rather than an exception to
      it. **Unmeasured, and it is the whole question:** whether Zen honours
      `prefers-color-scheme` from macOS appearance inside a *user* sheet
      (Firefox has `layout.css.prefers-color-scheme.content-override`,
      default follow-system; not run here). Ghostty is still the other
      candidate and is still a two-line change. Two candidates, both cheap, and
      the decision this box asks for is unchanged by either.
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
- [x] ✅ **macOS's own Light/Dark — SHIPPED as `haus.theme.systemAppearance`
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
      (`terminal.ghDash.enable`, default false) while claiming its port as handled
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
      with no upstream change (~~via
      `system.defaults.CustomUserPreferences."com.apple.universalaccess"`~~ — as
      it turned out, via a guarded write of the layer's own; see §5.12's sweep
      box for why that route and not this one). Both are real options now —
      `haus.accessibility.increaseContrast` and `.differentiateWithoutColor` —
      and `presets/large-print.nix` sets the first, which is what makes that preset
      reach *native* apps and not only the tools nebelung themes. It degrades
      exactly as required: the palette half works for everyone, the OS half
      sharpens it where FDA is granted, and the option's own description carries
      the reachability caveat in prose.
      → ~~"That designation never became a typed field, and on this evidence
      probably shouldn't."~~ ❌ **Reversed 2026-08-14 (haus#356, §5.12)** — it is
      a table now, and the evidence this rested on was the wrong evidence. Prose
      in one description genuinely *was* enough for one option; the cost only
      appeared at six copies (core's warning, core's domain list, terminal's skill,
      `haus rebuild`'s guard, `haus doctor`'s row, and the paragraph itself), and
      nothing about writing the second one tells you which of those two worlds
      you are in. **A fact stated twice is a style choice; the same fact stated
      six times is a table you haven't written yet.** Worth keeping as a
      counter-example to this document's own instinct to defer structure until
      it's obviously needed — by then the copies exist and each is separately
      true and separately maintained.

### 5.2 `haus.ui` — semantic scale tokens · M · risk M · ◐ **`scale` shipped, sizing pass done; `motion` shipped 2026-08-19 — as `haus.appearance.reduceMotion`, a bool in the Appearance room rather than a `ui.*` enum, for the reason its box gives. `density` is the last unbuilt member, and Finder's icon size the last unwired surface**
The missing abstraction. One set of tokens, fanned out with `mkDefault` into
every room, so a rice says "spacious" once instead of tuning nine numbers.

```nix
haus.ui = {
  scale = 1.35;            # 1.0 = today
  density = "spacious";    # compact | comfortable | spacious
  motion = "reduced";      # full | reduced | none
};
```

Fans out to: Dock icon size · Finder icon/sidebar size · Bar height/padding/
font/icon size · Pounce window width, row height, result count · Ghostty font
size + line height · zellij bar density · windows gaps and borders · wallpaper
contrast.

- [x] Every consumer reads `ui.*` through `mkDefault` so a host can still pin one
      number — verified end to end while writing `large-print`: `ui.scale = 1.4`
      resolves `fonts.mono.size` to 27, and pinning the font size afterwards wins.
- [x] ✅ **The sizing pass is done — the fan-out is FIVE targets now** (pounce#53
      + rice#175): terminal font size, **the whole command palette**, **the menu
      bar's type**, Dock `tilesize`, windows gaps. `density` and `motion` still
      don't exist.
      The palette was the higher-value of the two §5.2 gaps for exactly the reason
      this doc kept repeating — on a non-dev Mac it *is* how you launch things —
      and closing it took a seam in the app, not an option in the rice:
      **(a)** every size in pounce is now written for scale 1.0 and read through a
      `pt()` helper, so `"scale": 1.4` in `config.json` multiplies the launcher AND
      the emoji / clipboard / screenshots / camera / Find Files / cheatsheet / ⌘Tab
      panels together. `haus.pounce.scale` follows `ui.scale`, clamped into
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
      what a point means.** Worth auditing `fonts.*.size` and the tiler's gaps for the
      same interaction, and worth a line in whatever guide covers `large-print`.
      → ★ **Audited 2026-08-06, and the sentence above is aimed one layer off**
      ([`probes/scale-reach.nix`](probes/scale-reach.nix)). The surface holds
      **six numeric leaves in the 130 the options page renders — plus four
      internal `_roster`/`_launchers` mirrors that page never shows — and exactly
      one is in points**: `fonts.mono.size`. `ui.scale` and `pounce.scale` are multipliers,
      `roster.*.order` / `appStoreId` are an ordering and an id, and
      `bar.battery.hideOver` is a percent. **The tiler's gaps are not an option at
      all** — they, the Dock tile, the bar's type and pounce's panel widths are
      internal numbers computed from `ui.scale` inside a module. So the rule as
      written governs a set of size one.
      → ★ **And that one cannot clip *while windows tiles it*.** A 27pt terminal
      font on a `larger-text` display buys fewer columns, never a window wider
      than the screen — read off the code rather than measured, and the
      precondition is the interesting part: a **floating** window (the tiler's float
      rules, a `zscratch` throwaway) or a rice with `windows.enable = false` has no
      such guarantee. That is §5.6's "what second key or precondition makes the
      first one a lie", arriving in a room that isn't macOS settings. The failure the coupling actually
      produces needs something that **sizes itself** in points, and the family has
      exactly three: **pounce** (fixed pt panels → clamped to the visible frame,
      pounce#53), **perch** (`screen.frame.width * 0.42`, clamped 360–640 — so
      coupled to the display *by construction*, and blind to `ui.scale` entirely:
      a large-print Mac gets a normal-sized shelf, which is a real if small gap),
      and **bar** (bounded by a band that is itself in points). The rule worth
      carrying is the narrow one: *a point-valued number only meets `displays`
      when something sizes itself from it* — tiled and OS-managed surfaces absorb
      the change.
      → ✅ **Fixed the same day, one PR before this pass's own #243 — haus#241
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
- [x] ✅ `motion = "none"` is **ours to implement** — kill the tiler's animations and
      Bar's transitions directly. ~~The macOS reduce-motion knob is locked
      (§4), so there is nothing to delegate to.~~ ❌ **The rationale is dead**
      (§5.12, 2026-08-14): the domain was never locked, only FDA-gated, and
      `haus.accessibility.reduceMotion` is a shipped option. So there IS
      something to delegate the OS half to — which changes what this box is
      for rather than closing it: the tiler's and bar's own animations are still
      ours alone, and the token's job becomes *composing* the two (does
      `motion = "none"` set the macOS flag, or only say it pairs well with it?).
      Note the flag's blast radius before deciding — it is what every browser
      reads as `prefers-reduced-motion`, so a semantic token switching it on is
      a bigger promise than it looks.
      → ✅ **Shipped 2026-08-19 as `haus.appearance.reduceMotion`, and the
      NAME is the first answer.** Not a `ui.motion` enum: `full | reduced |
      none` promises a middle rung, and the honest inventory of haus's own
      motion is five hover-or-unasked movements with no ordering between them —
      there is no "half a workspace pull". A bool in the room that already owns
      `largePrint` says what it does, and sits beside the other whole-machine
      profile rather than inside a token family whose other member is a
      multiplier.
      → ★ **The inventory is the work; the fan-out was the easy half.** Five
      surfaces, and only two of them had an option to set — `bar.logo.sweep` and
      `windows.mouseFollowsFocus`. Three had to be BUILT before the profile had
      anything to name: `bar.media.marquee`, `bar.calendar.marquee`, and
      `windows.gravity`. That ratio is the finding. A "compose the existing
      dials" feature that turns out to be 3/5 new dials means the dials were
      never the design — what was missing was anybody having asked "what does
      this machine move that the user did not ask it to move", which is a
      question no room asks about itself.
      → ★ **The two most bothersome ones were the two nobody would have listed.**
      The media DROPDOWN's title rows carry `scroll_texts=on` for as long as the
      popup is open, which makes them the only unbounded motion on the bar — a
      hover sweep at least ends by itself. And `gravity` is not an animation at
      all, it is a whole display's worth of content replaced in a blink because
      an app quit, which is exactly the shape of a vestibular trigger and was
      filed in nobody's head as "motion". Enumerate by *what moves on screen*,
      never by what the code calls an animation.
      → ★ **The composition question this box asked has a general answer, and it
      is about DEPENDENCE rather than about whether to set the flag.** It does
      set `haus.accessibility.reduceMotion` — quietening five pills while Spaces
      keep sliding answers the question halfway, and Apple's flag is the only
      lever that reaches apps haus never heard of. What matters is the arrow:
      the flag is FDA-gated, so a machine without the grant loses it with a
      warning and every haus-owned leaf still applies. The tempting factoring —
      have the bar READ `NSWorkspace.accessibilityDisplayShouldReduceMotion` and
      follow it — would have been less code and would have made an accessibility
      feature contingent on a TCC grant. That is §5.2's own `cursorScale` rule
      (*a semantic token may only be derived from keys that are reachable
      unconditionally*) arriving from the other direction: there it stopped a
      token from PULLING an FDA key in, here it stops one from LEANING on it.
      `haus.animations` is deliberately not set — `"fast"` speeds the Dock up
      rather than removing motion, and coming back from it only stops writing.
      → **The one deliberate asymmetry, and it is a room-boundary result.**
      `windows.gravity` is windows's option implemented entirely by a bar item
      (`front_app_switched` is the only cheap ⌘Q signal, and aerospace.toml has
      no hook for it), so the rc gates the ITEM'S EXISTENCE on a generated
      fragment rather than having the plugin exit early. An item subscribed to
      every app switch on the machine should cost no process when off, not a
      cheap one. A behaviour's option belongs to the room that OWNS the
      behaviour, wherever the code that implements it had to land.
      → **Whether a desktop should imply it: no, and the PR says why.** `hacker`
      does not set it and neither does any shipped desktop. Two of the five
      leaves (`mouseFollowsFocus`, the sweeps) are things a desktop chose ON as
      character, and the flag's macOS half rewrites the web on a machine whose
      owner asked for a look rather than for an accommodation. A desktop that
      wants a still machine names the option, which is one line and legible in
      the file — the whole point of the desktop being data.
- [x] ~~`cursorScale`~~ ~~**cut** — `mouseDriverCursorSize` is in the locked
      `universalaccess` domain.~~ ❌ **Cut for a false reason** (§5.12,
      2026-08-14). The domain isn't locked, `mouseDriverCursorSize` is typed by
      nix-darwin, and `modules/lib/reachability.nix` carries it as
      `"unconfirmed"` — the write persists, nobody has ever watched the cursor
      afterwards, and no oracle exists to watch it for you. So this is **blocked
      on a 👤 eye-check, not cut**: look at the cursor at `3.0`, and promoting
      the key in the table is then a one-word edit that generates the option.
      → ★ **Eye-checked 2026-08-14: the key works, and the one-word edit is no
      longer the whole change.** `3.0` does enlarge the pointer — but only after
      `killall universalaccessd`, which the layer never ran
      (`restart-map.nix` had this domain as `"none"`). So `cursorScale` is
      un-cut and unblocked on *effect*, and was newly blocked on the restart map:
      ship the promotion alone and the option writes a plist the user sees
      nothing come of until their next logout. §5.12's box carries the detail;
      [haus#360](https://github.com/hausfold/haus/pull/360) does both halves.
      → ❌ **But it ships as `haus.accessibility.mouseDriverCursorSize`, NOT as a
      `ui.*` token, and the reason generalises to this whole section.**
      Deriving the pointer from `ui.scale` — the obvious move, and what the
      name `cursorScale` implied — would make `ui.scale = 1.4` pull an
      **FDA-gated** write into the one option family every machine sets. A Mac
      whose rebuilding app lacks the grant would then warn about TCC because
      the user asked for larger text, for a write that gets skipped anyway.
      §5.12's own conclusion already said it: treat `universalaccess` as a
      **bonus layer that sharpens the result when the grant happens to be
      there, never as the foundation** — and `ui.scale` is foundation. **A
      semantic token may only be derived from keys that are reachable
      unconditionally.** That is the rule this box actually produced, and it
      applies to every future `ui.*` member, not just this one.
      → ✅ **Closed 2026-08-14 with haus#360**, as `haus.accessibility.
      mouseDriverCursorSize` (a float, `1.0`–`4.0`, the range enforced at eval
      from `reachability.nix`'s `keyTypes` rather than written in prose), and
      the option's own description carries the reason it is not a `ui.*` token.
      So the box closes **answered rather than built** — which is the honest
      outcome for a `ui.*` item whose whole content turned out to be "this
      belongs in the other family."
- [x] ✅ **Bar: the type scales to a CEILING and stops — a different shape of
      answer, and the more interesting one.** Everything else here was a multiplier
      a tool was missing; the bar is not that. `sketchybarrc` pins `height=36` with
      28pt pills because the native menu bar auto-reveals on hover even while
      hidden and is only **32pt** on a notched display — core forces that reveal
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
      "declare bar outside `ui.scale`" because a bar that quietly stops growing
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
      `lib/bar.nix`'s ceiling — or losing it in a refactor — fails with three bar
      rows flipping from `ceiling` to `moves`. A stated ceiling is only the better
      answer while it *is* one, and nothing errors the day it stops being.
- [x] ✅ **Honest scope line — and it's a GOLDEN TABLE now, `scale-reach`
      (2026-08-06).** The prose: this changes *haus's own* UI reliably and
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
      flips three bar rows to `moves`; pinning pounce's default at 1.0 flips its
      two rows to `pinned`. Darwin-only, like `accent-reach` — it fingerprints a
      real evaluated system, so it fires on this machine or not at all.

### 5.3 `haus.fonts` · S · risk L · ◐ **`mono` shipped and its reach fixed (rice#243); the S-sized `sans` — one option, one label — shipped 2026-08-15 (haus#363). What stays open is the ·M app-side half across three repos, which needs a seam built before it needs a font. See the ship box and the open one after it; the header is the summary and the box decides (§5.14)**
**Cheapest big win in the doc, and nobody has asked for it because it's
invisible until you try to change it.** JetBrains Mono Nerd Font is hardcoded in
[`core:125`](haus/modules/core/default.nix:125); Ghostty's size is hardcoded in terminal.

```nix
haus.fonts = {
  mono = { package = pkgs.nerd-fonts.jetbrains-mono; name = "JetBrainsMono Nerd Font"; size = 14; };
  sans = { name = "SF Pro"; };              # e.g. "Atkinson Hyperlegible" for large-print
  extraPackages = [ ];
};
```

⚠️ **The `sans` line of that sketch is retired by the measurement box below
(2026-08-14) and kept here as the original proposal, not as a plan.** Both halves
of its comment moved: Atkinson-for-large-print ships today through `fonts.mono`
(Atkynson Mono), and the only value `sans` would carry is `".AppleSystemUIFont"`,
because that is the one proportional family the layer emits. `"SF Pro"` as a
settable *family name* was the thing measurement removed — and the option that
shipped on 2026-08-15 is exactly the sketch minus that: `sans.name`, defaulting
to the family the bar was already hardcoding.

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
      ones are now paired and the third (`focus.hooks`) is fine — `types.path`
      accepts `./thing` beside the rice file, which is still data. The thing this
      doc kept describing as an audit to schedule was ten seconds of work.
      **(c)** it's a CHECK now, exactly as this box asked: `data-only-surface` in
      `nix flake check` fails when a package-typed `haus.*` leaf has no string
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
      Ghostty's config moved. bar named `"Hack Nerd Font"` in its rc, four
      plugins and six generated blocks, so **the stock rice already ran two type
      families**, and the example this section opens with — Atkinson Hyperlegible
      for a large-print machine — would have changed the terminal and left the bar
      in Hack. The fix is the one `sizes.sh` already demonstrated: `BAR_FONT`
      beside the `FS_*` sizes, every literal reading it, and bar no longer
      installing a font core doesn't. Three things worth carrying:
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
- [x] ✅ **`sans` exists now, at the honest size — `haus.fonts.sans.name`,
      shipped 2026-08-15 in haus#363**, defaulting to `".AppleSystemUIFont"` and
      read by `clockLabelFont` and nothing else. No `sans.size`, no
      `sans.package`. Ticked as the measurement + decision this box asked for;
      what it decided AGAINST building is the box below. The measurement that
      produced it is kept verbatim underneath, in a blockquote rather than a
      second checkbox — ⚠️ **read its line numbers and its quoted
      `clockLabelFont` as the PRE-haus#363 ones.** Four of its citations moved
      when the option landed (`modules/bar/default.nix:161` → `:167`, and the
      line no longer ends in a literal; `:168` → `:174`; `modules/core/options.nix:409`
      → `:412`; and `bar.clock.monoFont`'s description gained "by default"),
      which is the ordinary cost of quoting a file by line — worth leaving
      visible rather than silently re-numbering, since the argument is about
      what was there.
      → **What shipping it actually changed, which is smaller than the option
      and bigger than the label**: `bar.clock.monoFont` stopped being a family
      switch with its second value welded in. **What the machine DRAWS does not
      move** — the default is byte-for-byte the old literal — so the value is
      entirely that a second consumer is now a line rather than a design
      conversation, and that the family is in the option tree where `haus set`,
      the desktop projection and the options page can all see it. (Those three
      *do* move, which is the point of them and is why "nothing moves" was the
      wrong sentence: a public option always moves the generated option surface,
      including `options.md` in every agent's skill directory.)
      → ★ **And the reason the welded family survived is not that nobody
      looked** — it is that `font-reach`, the check whose whole job is finding
      hardcoded families, evaluates two systems that both leave
      `bar.clock.monoFont` at its default, so the branch holding the literal was
      never taken in either. **A reach table that varies one option is blind to
      anything behind a second one.** Fixed in the same PR with a third pair of
      systems, which makes this the first instance of §5.14's oldest check
      candidate to become an actual check — see the twenty-second pass's box.
> **The measurement that decided it, written 2026-08-14 and kept verbatim.**
> A blockquote and not a checkbox: as a ticked box its first sentence would
> read "`sans` still doesn't exist", and as an open one it would read as work
> nobody had done — §5.14's third shape either way. Line numbers are pre-haus#363.
>
> `sans` still doesn't exist (only `fonts.mono` does) — and **the gating
> question this box asked is now answered by measurement (2026-08-14, no code
> written): exactly ONE surface would read it, and that surface is one
> label.** The audit is the same shape as rice#243's, run over the whole
> layer rather than one room: every `font-family` the layer emits
> (`modules/core/options.nix:409`, `modules/wallpaper/package.nix:200`,
> `modules/terminal/ghostty/config`) plus every hardcoded family literal under
> `modules/`. All of them are mono, and the wallpaper's only text is its
> debug band. (Two families are hardcoded, not one — `sketchybar-app-font`
> at `modules/bar/default.nix:168` is the other, pinned on purpose:
> `font-reach`'s own comment calls it the row that must NOT follow the
> desktop. It's an icon font, so it is not proportional type and not a
> candidate reader.) The desktop's entire proportional-type surface is
> `modules/bar/default.nix:161`:
> `clockLabelFont = if cfg.clock.monoFont then barFont else ".AppleSystemUIFont"`.
> → ★ **So `fonts.sans` already shipped. It is spelled `bar.clock.monoFont
> = false`, it is a `bool`, it lives in another room, and its value is welded
> in.** And its description argues for it on *legibility* — "macOS's system
> UI font, whose zero has no dot and is easier to distinguish from an 8"
> (`modules/bar/options.nix:454-463`) — which is this section's own opening
> argument, arriving in a room that had one label to fix and fixed it. A
> one-value family switch shipped while this box tracked "sans doesn't
> exist"; both statements are true, and only one of them is useful.
> **(a) the motivating example is already served, by the OTHER half of the
> family.** Atkinson Hyperlegible for a parent's Mac — the case the section
> opens with — is expressible today as `fonts.mono.packageName =
> "nerd-fonts.atkynson-mono"`, and `modules/appearance/options.nix:65-73`
> ships it as `largePrint`'s documented non-move (a typeface is taste, so the
> profile names one and sets none). Whatever `sans` is still for, it is not
> that.
> **(b) ★ this box named a blocker it had already removed, which is how it
> kept reading as ready-to-build.** "Nothing blocks it now that naming a
> package is possible" points at `packageName` — §5.3's own fixed format
> limit — and that was never the dependency. `.AppleSystemUIFont` needs no
> package at all, and a third-party sans needs *a consumer that can be told
> to use it*, which is the thing that's missing. **A box whose stated blocker
> is one you've since fixed promotes itself**, and this doc has no mechanism
> that catches it: §5.14's rule re-audits open boxes against the repos, but
> the prose that says WHY a box is open is the same running text §5.14's
> second pass found nothing catches.
> **(c) the surface the option's NAME promises — every proportional glyph on
> the machine — is not the surface it would reach.** macOS exposes no
> supported knob for the system UI font family, so the menus, Finder and
> Safari a reader pictures when they read `fonts.sans` stay SF Pro whatever
> the option says. ⚠️ Do not cite `appearance/options.nix` for this: its
> "what largePrint does NOT move" list declines the family on **taste**
> grounds ("a typeface is taste and a legibility profile should not decide
> yours") and then shows you how to change it — the unreachability entries
> beside it are about text *size* (`FontSizeCategory` posts no change
> notification) and third-party apps. Two different reasons for the same
> non-move, and conflating them would make the layer look like it had
> measured something it didn't. An option called `fonts.sans` would change one
> clock pill and nothing the user is actually reading — the "quietly
> under-delivers" failure that same description exists to prevent.
> **(d) ★ the real proportional type is in the APPS, and the seam to reach
> them already exists — which re-sizes this box out of S.** pounce, perch and
> trill draw their whole UI in SwiftUI's `.system(…)`
> (`pounce/pkgs/pounce/Rows.swift`, `trill/Trill/UI/*`), i.e. a family chosen
> by a design token rather than named — and not even one token: six of the
> nine calls in `Rows.swift` pass `design: .rounded`, so the palette is
> already drawn in SF Rounded, not SF Pro. **The three are reachable to three
> different degrees, which is the actual cost here and is worth stating
> precisely rather than as "three repos":** pounce is a flake input the layer
> builds from source (`haus/flake.nix:33`, `pounce.overlays.default`), so a
> new config key is a lock bump away; perch is consumed as its notarized
> release zip (`haus/flake.nix:38-46`) but has a `home.activation.perchTheme`
> seam to hand things through; **trill is not a haus input at all** and has
> no `modules/trill`, so for it the seam doesn't exist yet and would have to
> be built before a font could travel it. The layer
> already hands pounce a typography key through its generated config —
> `modules/launcher/default.nix:892`, `scale = config.haus.launcher.scale`, with
> the "an older pounce ignores the key rather than failing" tolerance
> established there — so a `fontFamily` beside `scale` is the identical
> shape. That makes a *real* `sans` a three-repo Swift item (·M, risk M),
> not the S this section has carried it as.
> → **What to build, if anything: the small one.** Give `fonts.sans.name` a
> default of `".AppleSystemUIFont"` and have `clockLabelFont` read it. One
> option, one consumer, no lie — it turns a bool that hardcodes a family into
> a bool that selects a *named* one, and makes the second consumer a line
> instead of a design conversation. Explicitly **no `sans.size`**: nothing
> here sizes proportional text by name (`ui.scale` and `pounce.scale` do),
> and a field with no reader is precisely the drift §5.14 is about.
> → **The ordering rule this leaves, which generalises past fonts: don't
> ship a family option before the surface that reads it.** `fonts.mono` was
> right on day one because the terminal read it, and rice#243 was the bill
> for the ten surfaces that didn't. `sans` inverts the order — the option
> would land first and its surfaces later — and an option that is true of one
> pill is worse than no option, because a desktop that sets it believes
> something.
> → ⚠️ **Read that rule against what shipped, because the two look like they
> disagree and don't.** haus#363 did not invert the order: the surface
> (`clockLabelFont`) existed first and the option was named for it, which is
> the rule being obeyed rather than broken. What the rule forbids is the
> *app-side* `sans` in the box below — one option, three consumers that
> can't read it yet — and that is still forbidden.

- [ ] **The app-side `sans` — ·M, risk M, and it needs a seam before it needs a
      font.** The machine's real proportional type is pounce's, perch's and
      trill's, all drawing SwiftUI `.system(…)`; measurement (2026-08-14, the
      box above, (d)) put them at three different reachable depths, and nothing
      about that changed when the small `sans` shipped. **This box is the only
      thing left in §5.3, and its blocker is named on purpose** — §5.14's sixth
      shape is a box whose stated blocker has since been fixed, which is how the
      last one promoted itself to looking ready. The blocker here is *a consumer
      that can be told which family to use*, in three apps that each need a
      different amount of plumbing to be told anything:
      **(a)** pounce is a flake input built from source and already takes a
      typography key through its generated config (`scale`), so `fontFamily`
      beside it is the identical seam — the one-line end;
      **(b)** perch is consumed as a notarized zip, with `home.activation.perchTheme`
      as the only channel that reaches it;
      **(c)** trill is not a haus input at all and has no `modules/trill` — for it
      the seam does not exist, so a font is at least two PRs behind a decision
      nobody has made.
      → **Don't take this box as staged work.** The honest form of "what would
      make this worth building" is a *reader* asking for it: a desktop that wants
      its palette rows in a legibility face, not a roadmap that wants the option
      surface symmetrical. `fonts.mono` earned its place from the terminal
      backwards; there is no equivalent pull here yet, and inventing one is how
      an option surface grows things nobody sets.

### 5.4 registry v2 — install sources + a real workspace model · M · risk M · ◐ **(a) shipped as `roster` (rice#182), (b) shipped (haus#253) — and reopened 2026-08-23 by the first entry to MIGRATE between two of those sources: `scope` is documented as reach and is load-bearing as a path (the last box)**
The registry is good. Two concrete gaps — and the halves came apart: the install
sources shipped without the workspace model, which is the right order (one is
additive, the other is the schema migration).

**(a) `cask` is the only install source.** ✅ **Shipped, differently than sketched.**
rice#182 renamed `haus.apps` → **`haus.roster`** and gave each entry
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
did land, gated behind `haus.appStore.install` — off by default, because it
reaches the network and acts on your Apple Account, and `mas` can neither sign in
nor buy a paid app, so it can never be complete.

**(b) `workspace` is a *field on an app*, which bakes "one app per workspace"
into the schema itself.** Role workspaces ("communication" = Mail + Slack +
Messages) and project workspaces are literally unrepresentable. Invert it:

```nix
haus.workspaces.comms = {
  key = "c"; icon = ":slack:"; monitor = "main"; layout = "tiles";
  apps = [ "slack" "mail" "messages" ];
};
```
…with `roster.<id>.workspace` kept as sugar that desugars into the above, so
existing hosts don't break.

**Update 2026-08-07 (haus#253): shipped, and NOT the way the sketch above
proposed.** Julien is the only consumer of this rice — he asked explicitly for a
clean rename over a back-compat alias, so `roster.*.workspace` and
`roster.*.barIcon` are **gone**, not deprecated. What shipped is otherwise the
sketch's inversion: `haus.workspaces.<id>` owns `key`, `icon` and `apps`
(the roster ids that live there); windows and bar resolve an app's workspace
through a new internal `haus._appWorkspace` lookup (roster id → workspace
id) rather than reading a field off the app. `monitor` / `layout` from the
sketch did **not** ship — nothing in this pass needed them, and per-workspace
monitor pinning would mean bridging AeroSpace's monitor-pattern matching
against `haus.displays`' own UUID vocabulary, a separate feature with its
own risk. Left for whoever needs it.

The workspace-throw key moved off the app too: `shift-<key>` used to throw to
*the app's own* workspace, which stops meaning anything once a workspace can
hold several apps. It's `shift-<workspace's-own-key>` now — a NEW binding
namespace, not a renamed one, with its own collision assertions (two
workspaces claiming one key; a workspace key colliding with the fixed
numbered-workspace `⇧` throws). Plain `<key>` stays exactly what it always
was: a roster app's launch letter, never a workspace's.

Also finished the second, previously-unstarted box: `haus.roster.*.float`
(+ optional `titleRegex`, scoped to AeroSpace's `window-title-regex-substring`)
generalises the "float" half of window rules — the shape the three
hand-hardcoded `aerospace.toml` rules (FaceTime, Flick, Ghostty) were asking to
become. FaceTime and Flick are now ordinary `float = true` roster entries
(`modules/windows/default.nix` — the live entry is `haus.roster.trill`, Flick
having been renamed by haus#264; see the naming banner at the top); Ghostty's rule stays hand-written on purpose —
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
`checkPack` only lets a pack set `haus.roster` (packs/README.md), and
`lib.pack` only lowers *that* option's priority on the way into a consumer.
`packs/writing.nix` can no longer give Obsidian or Zotero a workspace itself —
its README now tells the consumer to add the two-line `haus.workspaces`
entry by hand. Extending `checkPack`/`lib.pack` to carry `haus.workspaces`
through too — with `apps` needing list-merge semantics where every other field
wants `mkDefault`, per that option's own docs — is follow-up work, not done
here.

**Measured, not assumed:** a full build of the real `mbp` host (this machine)
against haus#253's branch, `--override-input`'d in for `haus`,
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
`flake.lock`'s `haus` input until haus#253 actually merges (a lock
bump computed against an unmerged rev pins nothing real), so it's blocked
rather than red. Same shape every breaking rename here takes: the lock bump
and the config edit that depends on it land together, in one PR, once there's
a real merged rev to point at — never split across the merge boundary.

`holt` currently fails to build from the workshop's own main checkout
independent of any of this (`sdk/go`'s nested `go.mod` collides with the root
module under `buildGoModule` — reproduced building `holt` alone, zero
haus involvement) — worked around for verification by overriding
`hausfold/holt` to a pre-SDK rev. Not this pass's bug to fix; flagging it
here so it isn't mistaken for fallout of this migration.

- [x] Multi-source install — shipped as `roster`'s parallel source fields, not a
      tagged union (see above)
- [x] First-class `workspaces` — shipped haus#253, **no** back-compat
      alias (single-user rice, clean rename per instruction — see above).
      ⚠️ This used to end *"§5.4 is now fully checked off"*, true of the two
      gaps the section opened with and no longer true of the section: the last
      box below was opened 2026-08-23. The clause is struck rather than moved
      because it was making a claim about the SECTION from inside a bullet about
      one gap — the shape §5.14 calls marker-and-body disagreement, one level up.
- [x] Window rules beyond assignment — shipped haus#253 as `float` +
      `titleRegex`. `center` and `sticky` are verified-infeasible against
      AeroSpace itself (see above), not shipped, and that's the closed state
      for both — there's no upstream primitive to build them on.
- ◐ Non-app installables the registry can't express: fonts, browser extensions,
      Quick Look / Finder / Share extensions, printers, network shares, VSTs.
      **Two of the five have answers now and NEITHER went into the registry:**
      fonts are `fonts.mono.packageName` (rice#215) and browser extensions are
      `haus.zen.extensions` (rice#211), each its own surface.
      ★ That's three losses in a row for the instinct behind this bullet — the
      third being §5.9's command metadata, which landed in nebelung's
      `ports.meta.json` rather than a rice-side table. **The registry is for
      apps.** Read this line as "each of these will get its own room", not "the
      roster must grow to swallow them" — and note that both answers were
      *cheaper* than the schema migration would have been, which is the argument.
- [x] **`scope` is documented as REACH and is load-bearing as a PATH.** Opened
      2026-08-23, on the first entry ever to MIGRATE between two of the four
      sources this section shipped. haus#468 moved sketchybar from
      `brew = "FelixKratz/formulae/sketchybar"` to `package = pkgs.sketchybar`
      with `scope = lib.mkDefault "system"` — because the tap has no bottle for
      macOS 26 and a fresh Tahoe Mac was building it from source, whose parallel
      make races and kills the very first `darwin-rebuild switch`. Correct fix,
      and it turned a metadata field into a filesystem contract: `scope =
      "system"` is what puts the binary in `/run/current-system/sw/bin`, a
      literal string **fifteen call sites in nine files across three rooms** now
      hardcode (bar's `default.nix`, `barpop.swift`, `aerospace-notify.sh` and
      three `sketchybar/plugins/` scripts;
      focus's `default.nix` and `focus.sh`; core's `awake.sh`).
      **The option says none of this.** Its description frames the choice as
      availability — *"'system': …on PATH for root, for non-login shells, and
      for launchd jobs… It is about REACH, not about the package needing
      elevated privileges to install"* — which is true and is not the whole
      contract. A host writing `haus.roster.sketchybar.scope = "user"` picks the
      DEFAULT every other entry uses and a documented in-range value; the binary
      lands in the user profile, the launchd agent's `ProgramArguments` points
      at nothing, and the bar never draws. Same for a host that goes back to
      Homebrew: `scope` is *"ignored when `package` is null"*, so the profile
      path is simply empty.
      **Nothing catches it.** `grep -rn 'roster\.sketchybar\|sketchybar\.scope'
      modules/` at `b1e263a` returns nothing, while the bar room's own assertion
      block — in the same file — exists for exactly this class and says so:
      *"each of these is a pill that cannot work, as opposed to one that merely
      won't draw."* The room reasoned carefully about the neighbouring risk (it
      resolves through the profile rather than `${pkgs.sketchybar}` precisely so
      a host CAN swap the package) and the scope one level over went unstated.
      **Why it belongs here and not in §5.9.** This is not a bar bug; it is what
      registry v2's shape costs. Four parallel nullable source fields won on
      MERGEABILITY (see above, and the reasoning still holds), and the price is
      that no single field says "this entry is installed" — so a consumer that
      needs a path has nowhere to ask for one and hardcodes the profile. The
      generalisable form: **any roster entry another module addresses by path
      has a scope precondition, and the roster has no way to express it.** An
      assertion on the one live case is a line; the question this box is open on
      is whether the registry should carry the precondition itself — a
      `requiresScope`, or a read-only `haus.roster.<name>.binPath` the rooms
      name instead of a string. The second is the one that scales, and it is
      also the one that would have made haus#468 a one-line change instead of a
      sixteen-spelling sweep.
      ⚠️ **Amended 2026-08-23 (fortieth pass): fifteen is sixteen, four hours
      and fifteen minutes after this box was written.** At haus `7968b7f` the
      literal is hardcoded at **sixteen call sites**, still nine files, still
      three rooms: haus#484 (`a6d1474`, 09:40:29Z) added
      `bar/sketchybar/aerospace-notify.sh:26`, an `aerospace_tiling_change`
      trigger — in the **bar** room, so the three-room count holds; added by a
      **windows**-room PR, for a reason with nothing to do with `scope`. The
      box's thesis is that the literal spreads; it spread once inside the box's
      first afternoon, from a PR that has no reason to know the box exists, and
      nothing but this box would notice. Derive it at a rev, never off the
      working tree: `git grep -c '/run/current-system/sw/bin/sketchybar'
      7968b7f -- modules` sums to 18, **minus the two occurrences that are
      prose** — `modules/bar/default.nix:1692` and
      `:1799` are comments *about* the path, which is why the raw sum reads 18
      and why fifteen was exactly right when written (17 − 2 at `b1e263a`).
      ★ **The line half is in review 2026-08-23 (haus#491, `09cdf5e`), and the box
      stays open on the half it was actually open on.** With `haus.bar.enable`
      on, the bar room now asserts that `haus.roster.sketchybar` is enabled,
      installs from nixpkgs (`package` or `packageName`), and does so at
      `scope = "system"` — in the same assertion block whose header already
      says what it is for: *"a pill that cannot work, as opposed to one that
      merely won't draw"*. The `scope` option's description gains the path half
      too, so the precondition is readable where the option is rather than
      where the bug is. It moves the count above by exactly nothing and the raw
      sum by one: at haus#491's head the `git grep -c` sums to **19**, still
      **sixteen** call sites, because the third occurrence it adds is the new
      block's own comment — prose is now three (`modules/bar/default.nix:1582`,
      `:1743`, `:1850`), which is the amendment's own subtraction rule surviving
      first contact with a change that knew about it.
      → ⚠️ **The first version of that check was wrong in three ways, and that
      is the part worth keeping.** Written in one sitting against this box's own
      description of the bug, it (i) tested the RAW
      `config.haus.roster.sketchybar.package` while roster resolves
      `packageName` → `package` in its own `let` before anything reads it — so
      it **refused a working bar**, and specifically the one a data-only
      desktop has to build, `packageName` being the only nixpkgs source such a
      file can name; (ii) missed `enable = false`, the *documented* way to drop
      a roster entry, which filters out before `packagesFor` ever runs while
      `package` and `scope` still read fine — verbatim the failure the message
      claims nothing else would say; and (iii) carried prose, in both the room
      and the option, saying that moving the entry "back to a `brew`" breaks
      the bar, when the room sets `package` at `mkDefault`, so merely adding a
      brew installs the tool twice and leaves the bar working. All three came
      back from the pre-PR assurance read and **none from the build — the clean
      host built green with the broken check in place, twice.**
      ★ The general form is drift.md's, not this section's: *a check written
      from a description of the bug inherits that description's blind spots,
      and the only thing that finds them is running the check against the cases
      it is supposed to ALLOW.* Four branches were exercised in the end — three
      that must fail, one that must build — because *"leave a check behind"* is
      not satisfied by a check nobody has seen fail, and is not satisfied
      either by one nobody has seen pass.
      → **What did NOT ship is the question, and it is the same question.**
      `binPath` (or `requiresScope`) is still unbuilt, so the second roster
      entry a room addresses by path gets no help from this: it gets an
      assertion written by hand, in that room, if whoever writes it happens to
      know. The assertion is a fix for one entry; the box is about a format
      that cannot express the precondition. Keep it open until the registry
      answers, and read this tick as evidence that the cheap half is now cheap
      enough to have been done — not as progress on the expensive one.
      ✅ **Closed 2026-08-23 (forty-first pass) — [haus#493](https://github.com/hausfold/haus/pull/493)
      builds the registry half this box chose between two designs for, and
      picks the one the box said would scale.** `haus.roster.<name>.binPath` is
      read-only and computed from the entry's own source and `scope`:
      `/run/current-system/sw/bin/<bin>` at `scope = "system"`,
      `/etc/profiles/per-user/<you>/bin/<bin>` at `"user"`,
      `/opt/homebrew/bin/<bin>` for a `brew`, and **null** for a `cask`, an
      `appStoreId` or an `installedBy` — a bundle rather than a binary, and a
      path haus cannot name. A `bin` leaf beside it covers the entry whose
      executable is not its roster key (`ical-buddy` ships `icalBuddy`).
      Sixteen call sites became **two**, both exempted by name and by reason.
      → ★ **The null is the load-bearing half, and the box's own framing
      understated it.** This box argued `binPath` over `requiresScope` on
      SCALE — "the one that would have made haus#468 a one-line change". The
      better argument only appears once it is built: a computed path can be
      **absent**, and a room can assert on an absence. A hardcoded string has
      no absent state at all; it is simply wrong, and stays wrong, and that is
      exactly why the failure this box opened on had no symptom. `requiresScope`
      would have re-stated the precondition; `binPath` makes the precondition
      *checkable by the consumer that has it*.
      → 😐 **`/etc/profiles/per-user/<you>/bin`, not `~/.nix-profile/bin`** —
      home-manager runs as a nix-darwin module with `useUserPackages`, which
      moves the per-user profile under `/etc`. Getting that wrong would have
      evaluated fine and been a dead path at runtime, which is this box's own
      disease reproduced inside its cure. Verified against the live machine
      before it was written down, not after.
      → ★ **Deriving the path silently rewrote a neighbouring assertion's
      REASON, and nothing about the diff said so.** The bar's `scope` guard
      (haus#491) refused `"user"` because "the bar addresses
      /run/current-system/sw/bin/sketchybar — a path only the system profile
      provides". Once `barTopPath` IS `binPath`, the whole room follows `scope`,
      so that sentence became self-contradictory: the message would have named
      the per-user path and then called it unreachable. The guard is kept and
      the reason corrected — no bar has ever been run out of the per-user
      profile, and refusing an *untested* arrangement is a different claim from
      refusing a *broken* one. **A derived value can turn a true assertion
      message into a false one without touching the assertion**, and the
      condition still passing is what hides it. Settling it is one
      `bench try switch` away, and the comment now says so rather than
      implying the answer is known.
      → ✅ **`nix flake check`'s `roster-bin-paths` is the point rather than
      the garnish**, because this box's whole evidence is that the literal
      SPREADS: it grew by one from an unrelated room's PR inside the box's
      first afternoon. Any file under `modules/` naming an owned path outside
      the allowlist fails, **and an allowlist entry that no longer names it
      fails too** — an exemption cannot outlive its reason, which is the shape
      §5.9's `pounce-command-keys` paragraph warns about from the other side
      (a check going blind rather than red). Mutation-checked both ways.
      → **The two survivors, and why each earns its line.**
      `modules/options.nix` is the option's own documentation — the definition
      site, where the string is the subject. `modules/bar/barpop.swift` is a
      runtime **fallback chain**, not an address: it tries `$SKETCHYBAR_BIN`
      (which the bar passes from `binPath`) first and only then walks a list
      that still holds two Homebrew paths, so a barpop from a new generation
      finds the bar on a machine mid-migration. **A search is not a mirror**,
      and a check that cannot tell them apart would have deleted the one thing
      making the migration this box is about survivable.
      → 😐 **The three PROSE lines the amendment above taught itself to
      subtract were swept too, and the subtraction rule is why they nearly
      weren't.** They are not part of the sixteen — that is the amendment's
      whole point, and at haus#491's head the raw `git grep -c` reads **19**
      for sixteen call sites plus three comments. But a rule for excluding
      something from a COUNT reads, on the next pass, as a rule for excluding
      it from the WORK, and the three would have been left spelling a path
      that no longer exists anywhere else. They now name `barTopPath`, on the
      grounds this file states everywhere else and had not applied here: **a
      comment holding a derived value is a copy that rots exactly like a `let`
      binding does**, and it rots more quietly, because nothing evaluates it.
      Which also settles the tick: haus#491 merged as `1e92e15` the same
      morning, so the line half above is shipped, not in review.

### 5.5 `haus.keys` — the keymap is currently closed · M · risk M · ✅ **shipped (haus#108)**
Caps-Lock leader, ⌘Space, and every zellij bind are generated or baked. This
single-handedly makes **mouse-first**, **one-handed**, and **non-QWERTY /
international layout** rices impossible — a real accessibility *and*
internationalization gap the earlier brainstorm didn't name.

```nix
haus.keys = {
  leader = "caps";           # caps | hyper | none  (none = mouse-first rice)
  palette = "cmd-space";     # or "none" to keep Spotlight
  windowNav = "alt";         # the modifier vocabulary, not individual binds
  bindings = { };            # per-action overrides
};
```

- [x] `keys.{leader,palette,windowNav}` shipped, resolved once in
      `modules/lib/keys.nix`, with `"none"` a real value on all three. `windowNav`
      is a **modifier vocabulary** rather than a bind-per-action: what people need
      to move is the modifier, not the letters, and one value moves every chord
      that carries it. ⚠️ **That count was fifteen main-mode chords plus
      service-mode entry when this shipped and is NINE today** (twenty-fourth
      pass, re-derived rather than adjusted: `grep -cE '\$\{m(s)? "'
      modules/windows/wm-bindings.nix` → 8, plus `serviceEntry` at
      `modules/windows/default.nix:193`). Four are main-mode — `<mod>/`,
      `<mod>,`, `<mod>f`, `<mod>⇧⇥` — four are service mode's join-with arrows,
      and one is service-mode entry. The other six didn't move to another
      modifier, they **left**: `⌥⇥` retired (rice#210, the box four below),
      `⌥hjkl` unbound with nothing in its place (haus#366 — no Vim direction is
      bound by default anywhere in haus now), and the workspace digits became
      leader actions in launch mode, which `windowNav` doesn't reach. The claim
      the number was making still holds — one value still moves everything on
      that modifier — but a *shrinking* surface makes "one value moves fifteen
      chords" read as an argument that gets weaker every time the keymap gets
      better, which is backwards. Count the chords it moves, or don't count. `bindings` (per-action overrides) is still
      open — it needs an action vocabulary first, and none of the motivating cases
      needed it.
      **Update 2026-07-30: half that vocabulary now exists, from pounce.** pounce#43
      addresses every palette row by its frecency key — `cmd:emoji`,
      `app:/Applications/Ghostty.app`, `mode:clipboard` — and takes per-item
      `alias` / `hotkey` / `enabled`, with `hotkey` accepting **leader sequences**
      (`"opt+space e"`: whitespace separates steps, `+` separates modifiers, the
      Emacs/VS Code notation). So `bindings` should be designed as *two* namespaces,
      not one: pounce items already have stable ids, windows actions still don't.
      Three constraints that came with it and would otherwise be discovered late:
      a second step is registered as an ordinary modifier-less global hotkey for
      ~2s rather than a CGEventTap, so **sequences need no Accessibility grant**
      (worth preserving — it's why the palette key needs none either);
      `enabled = false` hides a row but does **not** disarm its hotkey, so an option
      that means "turn this off" has to say which of the two it does; and
      `pounce run <item-key>` exists as the escape hatch for keys another tool
      already owns, which is the honest answer for a rice whose leader is `"none"`.
- ~~Split `windows.enable` into `windows.tiling.enable` / `windows.launcher.enable` /
      `windows.capsRemap.enable`~~ — **superseded, not done.** *(Un-boxed
      2026-08-23: a superseded line is not an open task, and while it wore a
      `- [ ]` it inflated every count this file takes of itself — the last one
      by ten percent. §5.14's marker-and-body disagreement, in the marker this
      time.)* `keys.leader = "none"`
      is capsRemap-off + launcher-off and `keys.windowNav = "none"` is
      tiling-chords-off, which covers every case that motivated the split, from the
      keymap side rather than by multiplying room switches. Revisit only if someone
      wants AeroSpace to *stop tiling* while keeping its launcher.
- [x] Assertion on duplicate leader letters *and* cross-room conflicts. The
      cross-room one was the real gap: `keys.leader` is the tiler's AeroSpace chord and
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
      ⚠️ **Amended 2026-08-22 (thirty-fourth pass): "the same data" reaches the
      cheatsheet, the tour and the docs repo, and stops one file short of the
      surface a stranger reads BEFORE any of them.** The keys launch mode
      reserves have a single authority — `modules/windows/launch-keys.nix`,
      whose own header says *"two things render this list and neither may guess
      at it"* — published as `docs/site-data/launch-keys.json` and tripwired
      from the other repo by `scripts/check-rice-bindings.mjs`. Both consumers
      it names are honest. The copies it does not name are **prose enumerating
      the same set by hand**, and two of them are option descriptions:
      `haus.roster.<name>.key` and `haus.keys.leaderExtras.*.key` — the
      published spellings, from `options.json`. (haus#463's own PR body calls
      them `haus.roster.<app>.key` and `haus.keys.leaderExtras`; the first does
      not exist, and the second is a different leaf whose description was never
      stale. A PR body is not a rev.)
      haus#398 (`41b84a8`, 2026-08-18T10:17:38Z) moved the authority `e` → `f`
      (Find Files) and took the cheatsheet row, the collision assertion's
      message and comment blocks in four files with it in the same commit — one
      of those comments *says* "`e` went back to the roster". **The two descriptions were
      not touched, and stayed wrong until haus#463 (`698d3f8`) at
      2026-08-22T10:21:17Z: four days and three minutes**, telling every reader
      of the published reference that a free letter was taken and that the
      taken one was free. Generation did not help, because generation is
      faithful: #398 rebuilt `options.json` in that very commit and changed two
      *other* descriptions, since the two carrying the stale list had no diff to
      carry. hausfold.co's `rooms/apps.mdx` held a third hand-copy of the set
      and was fixed at 10:23:54Z ("wrong twice", hausfold.co#127). Separately,
      and on the haus side, `haus.keys.leaderExtras.*.key`'s description offered
      `"period"` as an example key for **28 minutes 16 seconds** — haus#460
      (`b72f51c`, 09:53:01Z) reserved it, haus#463 (10:21:17Z) reworded it to
      `"backslash"` — so the published reference spent that window recommending
      a value a rebuild refuses. The site's copy of that example is the
      *generated* page, last regenerated before #460 (hausfold.co#123,
      00:12:28Z), so it never re-published the mistake; it carried it.
      ★ **The direction is the finding: for `e`/`f`, the surface that REFUSES
      you was current the whole time, and the surface you read before writing
      the line was four days stale.** The scoping clause is load-bearing —
      haus#460's `.` inverted it for 28 minutes, and #463's own message says so
      ("a host that picked `period` was refused by a sentence that didn't list
      the key it hit"): the same enumeration failing at the loud end instead of
      the quiet one. A host that typed `key = "f"` was stopped by an assertion
      whose message listed `f` correctly; a host that typed `key = "e"` — on the
      published reference's own advice — got a letter the layer had handed back.
      A published set with a check on it is not the same as a checked set, and
      §5.14's reason 1 has been recommending the first as though it were the
      second. The check that exists, and what it does not compare, is the
      thirty-fourth pass's §5.14 row.
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
      (rice#220).** It said the tour *hangs* at step 1 when `windows.enable = false`.
      It doesn't: #156's `tourWired` gates the pill on windows-or-authored-steps, so
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

### 5.6 Curate macOS settings into behaviour groups · M · risk M · ✅ **all ten groups shipped (rice#198, #250, #267, #286; the last three — Windows, `lock`'s login half, `security`'s guest half — 2026-08-19). Every row is spiked except `animations`, which ships unspiked on purpose (below), and the null-default policy held across all ten without exception until 2026-08-22, when it was breached from OUTSIDE the section — a room supplying one of these leaves a value at `mkDefault`, so the declaration is still `null` and two of the four shipping desktops write the key anyway (the ⚠️ under the policy note). The check that would make that product visible rather than described is BUILT and MERGED — `settings-writes`, haus#472 (`6bb294c`, `mergedAt 2026-08-23T05:25:17Z`), resolving all 66 leaves on all four desktops — and its first result is that no desktop names any of the 66 at all, so every future breach arrives, as this one did, from a room. The three logout-only groups were unblocked by the third fact table, `modules/lib/login-map.nix`, not by anything changing about the domains. One key is still deliberately unbuilt and says so in its own box: remote login, which is not a `defaults` key at all**
Do **not** mirror every nix-darwin default into `haus.*`; `system.defaults`
stays the escape hatch. Curate the groups where a *rice* has an opinion:

| Group | Notable gaps today |
|---|---|
| **Hot corners** | ✅ **`haus.hotCorners.*` — rice#198.** Action by name, not the integer macOS stores |
| **Screenshots** | ✅ **`haus.screenshots.*` — rice#198.** Folder, format, shadow, thumbnail, date |
| **Lock / login / screensaver** | ✅ **`haus.lock.*` — rice#250 (lock half) + 2026-08-19 (login half).** The lock half is `requirePassword` / `requirePasswordDelay` on `com.apple.screensaver`; the login half is `haus.lock.login.{showNameField,message,hideShutDown,hideRestart,hideSleep}` on `com.apple.loginwindow`. That domain is still read once at session creation with no live-reload path — nothing about it changed. What changed is that the wait is now stated AT THE OPTION, generated from `modules/lib/login-map.nix`, so it no longer "silently doesn't apply". |
| **Menu bar & Control Center** | ✅ **`haus.menuBar.{clock,controlCenter}.*` — rice#250.** Clock format/seconds/date/day-of-week/analog (`com.apple.menuExtraClock`, restarts `SystemUIServer`) + which Control Center glyphs show (battery %, sound, bluetooth, AirDrop, display, Focus, Now Playing — `com.apple.controlcenter`, restarts `ControlCenter`, a whitelisted process since rice#249 that nothing had written into until now) |
| **Sound** | ✅ **`haus.sound.*` — rice#267.** `alertVolume` (0–100, converted from the `e^(v/100−1)` macOS actually stores), `alertSound` (an enum over `/System/Library/Sounds`, because a bad path is silence not a fallback), `volumeFeedback`, `uiSounds`, `startupChime` (`nvram`, so it survives a reinstall). Live writes, no FDA, no restart. The volume curve is pinned by a `nix flake check` against numbers CoreAudio reported |
| **Locale / input sources** | ✅ **`haus.locale.*` — rice#267.** `language`, `region`, `metric` (writes both unit keys), `temperature`, `hourFormat`, `inputSources` (exhaustive; via the TIS API). Needed restart-map's third verb, `notify:<name>` — this family has no daemon to kill, so a write reaches newly launched processes only until `AppleDatePreferencesChangedNotification` is posted. No `firstWeekday`: that key is stored and ignored |
| **Power** | ✅ **`haus.power.*` — rice#267.** Sleep timers and Low Power Mode, per power source, as a `pmset` activation step — the `security.firewall` family rather than the `system.defaults` one. Deliberately NOT on nix-darwin's typed `power.sleep.*`: measured on 26.6.1, `systemsetup -setcomputersleep` wrote the AC profile while the machine was on battery, with its stderr discarded upstream (reported) |
| **Security posture** | ✅ **`haus.security.firewall.*` — rice#250; `haus.security.guestAccount` — 2026-08-19.** The firewall half is `networking.applicationFirewall`, a *different* mechanism entirely (nix-darwin runs `socketfilterfw` directly in its own activation script — no plist, no restart-map entry, no logout). `guestAccount` rides the same `loginwindow` unblock as `lock`'s login half, and is the one key in the group that is a real boundary rather than a preference: fresh Macs ship Guest ON. **Remote login stays out, and the reason is now recorded in the option file rather than here**: it is not a `defaults` key at all (`systemsetup -setremotelogin`, needing a guarded activation step of its own and FDA), and opening an SSH port is a different class of decision — deliberately not smuggled in behind a logout-note PR. |
| **Animations** | ✅ **`haus.animations` — rice#286.** Five keys across two already-verified domains: the Dock's `autohide-time-modifier` / `expose-animation-duration` / `launchanim` / `mineffect`, plus `NSGlobalDomain.NSAutomaticWindowAnimationsEnabled`. Defaults to `"system"` = write nothing, same as every other row — it was drafted the other way round and reversed before merge; see the policy note below for what that cost would have been. Two firsts worth knowing: it's the only group with no per-key spike (there is no oracle for "did the Dock slide faster" — the keys are felt, not measured), and its NSGlobalDomain half is read by each app AT LAUNCH, so running apps keep animating until relaunched. What it deliberately is NOT is `universalaccess reduceMotion`: that flag is what every browser reads as `prefers-reduced-motion`, via the same `NSWorkspace` property `hausax` prints — so the negative claim is checkable (`hausax \| jq .reduceMotion` stays `false` — on a machine that hasn't also set `haus.accessibility.reduceMotion`, which is the option that DOES move it, added in §5.12) even though the positive ones aren't |
| **Windows** | ✅ **`haus.windows.{stageManager,nativeTiling,desktop}.*` — 2026-08-19.** Twelve keys on `com.apple.WindowManager`, still `"logout"` in restart-map.nix (rice#249) with no live-reload path on macOS 26 — the domain is unchanged and the whole of it is logout-only, which is exactly why it went last. It ships now because `login-map.nix` makes the wait something the option says rather than something you discover. Built in the **windows room, not core**: it is the one settings group that interlocks with what a room does, and it warns when AeroSpace and Stage Manager / edge-drag tiling are both on, naming both switches — the symptom ("windows won't stay where I put them") indicts neither on its own. |

The first two shipped settled the group's **default policy**, which was the real
open question and is worth stating once for every group after it: every leaf
defaults to **null = write nothing**, and null is deliberately not the same as
"off". Hot corners made that concrete — the machine this was developed on had
three corners already set by hand, so a rice naming a corner it didn't care about
would have erased one silently. A curated setting group is a place to make an
opinion *available*, not to impose one; a preset is where an opinion belongs.
`lock`/`menuBar`/`security.firewall` (2026-08-07) inherit the same policy without
re-deriving it.

**`animations` (rice#286) tested that policy and it held.** The group was drafted
defaulting to `"fast"` — writing on a machine that didn't ask — with what looked
like a decent argument: the rice already holds three opinions in the same
`com.apple.dock` domain a few lines away (`autohide`, `mru-spaces`,
`orientation`), so there was no "naming a key it doesn't care about" problem to
have, and desktop motion is a whole-feel decision of exactly the kind a rice
exists to have already made. It was reversed before merge anyway, and the
deciding fact is one worth keeping for the next group that makes the same case:
**the write is one-way.** `"system"` stops writing, it cannot restore, because a
`defaults` write is sticky and macOS keeps no memory of the prior value — so an
on-by-default group doesn't just express an opinion, it *destroys* the setting it
overwrote, on machines that were already running. That's the hot-corners
argument again, one domain over, and it's what makes null-by-default a rule
rather than a habit. The opinion still exists; it lives in a host file (and could
live in a preset), which is where §5.6 said opinions belong all along.

⚠️ **And on 2026-08-22 it was breached — from outside this section, by a room,
and the ten groups had nothing to do with it.** `haus.shelf.watchScreenshots`
(haus#461), a `bool` defaulting **`true`**, sets
`haus.screenshots.thumbnail = lib.mkDefault false` from
`modules/shelf/default.nix:236`, so a capture reaches the shelf without waiting
five seconds for macOS's floating thumbnail to expire. Evaluated at `ff8ecf3`
over all four shipping desktops, `hacker` and `everyday` come out
`thumbnail = false` with every other `com.apple.screencapture` key `null`;
`minimal` and `blank` come out `null`, because both leave the shelf off:

```sh
nix eval --impure --json --expr '
  let f = builtins.getFlake (toString ./.);
      g = n: (f.mkHaus { system = "aarch64-darwin"; username = "you";
                         hostname = "example"; desktop = f.desktops.${n}; })
             .config.haus.screenshots.thumbnail;
  in builtins.listToAttrs (map (n: { name = n; value = g n; })
                               (builtins.attrNames f.desktops))'
# {"blank":null,"everyday":false,"hacker":false,"minimal":null}
```

**Every clause of the policy above still holds and the outcome it exists to
prevent happened anyway.** The leaf still *declares* `null`; the reference still
renders `null or boolean · default null` over *"null (the default) leaves
macOS's own choice alone"*; nothing in the Screenshots group changed. The value
arrives from a module the policy was never addressed to — and the one-way
argument applies to it unchanged: turning the shelf or the switch off stops the
write, it cannot put the thumbnail back. haus#461's own comment reaches that
fact independently (*"disabling this room stops the write, it does not put the
thumbnail back"*) and spends it describing the behaviour rather than choosing
the default, which is the whole distance between this and `animations`.

The mechanical reason is worth more than the instance. **`§5.6` is cited 33
times in haus's source at `ff8ecf3`, and 29 of them are in the machinery that
already obeys it** — `core/options.nix` 11, `core/default.nix` 6,
`lib/restart-map.nix` 4, `lib/login-map.nix` 3, `flake.nix` 2, one each in
`core/loginwindow-keys.nix`, `options-groups.nix` and `lib/reachability.nix`.
The other four are in the `windows` room, and they are there because `windows`
**is** one of these ten groups, built in a room rather than in core for the
reason its row above gives; `windows/options.nix:312` even restates the policy
(*"Every option is null-by-default like every other §5.6 group"*). So the rule
reaches exactly one room, the one that hosts a group. **A room that merely
consumes one of these leaves has never cited it, and that is the only place it
can now be broken from.** Nothing enforces it either. Of the thirty-three
`nix flake check` entries at `ff8ecf3`, exactly one reads resolved values —
`desktop-projection`, 55 `haus.*` paths from `darwinConfigurations.example`
against `test/projections/example.json` — and **none of those 55 is a leaf of
any of these ten groups**.

Two separable questions. **The first is answered; only the second is open, and
only the second was ever this document's:**

- **Should the desktops hold this opinion?** ✅ **Decided 2026-08-22: yes, and
  the shipped shape is already the right one.** `watchScreenshots` keeps
  defaulting `true`, gated on `shelf.enable` — which is not an extra condition
  to add but the one the module already has, since every line of
  `modules/shelf/default.nix` sits inside `lib.mkIf config.haus.shelf.enable`.
  So the thumbnail is only ever written on a machine that asked for a shelf,
  and the trade is the shelf's own: its whole promise is "drag it somewhere
  *now*", and five seconds is most of that. **This does not retire the finding
  above** — a policy still says one thing and two desktops still do another,
  and the write is still one-way for anyone who rebuilt before reading this.
  It retires the *decision*, so a later pass re-deriving §5.6's exception
  finds a choice rather than an oversight. One loose end, cosmetic (1/5) and
  **already closed**: with the shelf off the leaf still *read* `true` on
  `minimal` and `blank`, because the default was unconditional and only its
  effect is gated, so `haus get`, the `haus set` picker and the annotated host
  file each offered a switch with nothing behind it.
  [haus#467](https://github.com/hausfold/haus/pull/467) makes the default
  `config.haus.shelf.enable` — the `developer.git.enable` shape — the same day.
  ⚠️ This note first named **`haus show`**, which is the wrong surface for the
  argument — it reports the leaves a desktop FILE names, and no file names this
  leaf. ⚠️⚠️ **The reason printed here until the thirty-sixth pass was itself
  false** and read *"reads a desktop FILE and never a machine's resolved
  values"*: `haus show` does read them, for every leaf it reports. Struck rather
  than rebutted, because this is box content later passes quote. The same wrong
  surface was already load-bearing in `modules/shelf/default.nix`, where the
  argument for routing
  the write through a named option rested on it, and haus#467 corrects it
  there too. Twice in one section, from two authors, about a command whose own
  footer says what it does not do — worth §5.14's attention if it happens a
  third time.
  ★ **It already had.** The thirty-sixth pass found the third instance sitting
  in `modules/shelf/default.nix` itself — twelve lines under the correction,
  same comment, same commit (`e7fd997`), untouched by haus#467 — and the
  fourth is the sentence above, which is the fourth statement of a reason that
  is **itself wrong**: `haus show` does read this machine's resolved values,
  for every leaf a FILE names (23 of them on `hacker.nix`, three of them
  `overridden`, measured at haus `8c1fa43`). What it cannot do is report a
  leaf no file names, which is why `haus.screenshots.thumbnail` is absent.
  `haus get` remains the right surface, so nothing built on this changes; the
  repetition, and the width of the reason that made it repeatable, are §5.14
  row twenty-two.
- **Should the policy be stated over VALUES rather than declarations, and
  checked?** That one is structural, still open, and it is the box below.

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
`reduceMotion` has one. Both rested on nix-darwin's own restart precedent
(Finder/Dock: killall re-reads the domain at launch) rather than a spike on this
machine, and modules/lib/restart-map.nix said so in a comment rather than
claiming `support = "tested-macos-26"` for something that isn't. **Watched
2026-08-14 (box below); the comment says "no logout needed, measured 26.6.1" as
of haus#362, **merged** — for the pair, not for each entry.** `com.apple.screensaver = "none"`
is confirmed on its own; the `SystemUIServer` and `ControlCenter` entries are
not, and can't be by watching a rebuild — see the box. `security.firewall`
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

- [x] **Watched 2026-08-14 — both take effect live, with no logout, and the one
  that could have gone wrong (`lock`) is the one that came back clean.**
  `haus.menuBar.clock.showSeconds =
  true` + `haus.lock.requirePasswordDelay = 60` in the host file, one
  `bench try switch`, no logout: the menu bar clock was ticking seconds
  immediately, and starting the screen saver then waking inside the grace
  period went **straight to the desktop with no password prompt**, where the
  same machine had always asked. So `com.apple.screensaver = "none"` holds:
  there is no persistent process, the setting is read at the next lock, and
  Apple's move of this setting to `sysadminctl -screenLock` did **not** make the
  plist key inert on 26 — which was the live worry, and the reason a group with
  no oracle still had to be watched rather than reasoned about.
  → **What this does NOT prove, stated so nobody upgrades it later by
  misreading the box:** the clock re-rendered, but this run can't say the
  `SystemUIServer` entry is what did it. `haus plan` reports that **every**
  rebuild restarts ControlCenter, Dock, Finder and SystemUIServer and broadcasts
  `activateSettings`, so the per-domain entry was never the only thing firing —
  and macOS 26 draws the clock from ControlCenter, which is in that unconditional
  set. The claim earned here is "no logout needed", which is what the box asked.
  Isolating the entry needs a build that writes `com.apple.menuExtraClock` with
  the unconditional restarts suppressed, and nobody needs that today.
  → Both domains are now **spiked on this machine**, which the §5.6 prose above
  (and `restart-map.nix`'s own comment) then still denied — both said these rows
  rest on nix-darwin's Finder/Dock precedent rather than a local measurement, and
  both invited exactly this confirmation. ~~The comment can be upgraded when the
  restart-map PR in §5.12 opens it anyway~~; per the caveat above, upgrade it to
  "no logout needed, measured 26.6.1", **not** to `support = "tested-macos-26"`
  for the entry itself, which is the stronger claim this run didn't make.
  → ❌ **Piggybacking it on §5.12's PR was the mistake, and it is the twentieth
  pass's finding.** haus#360 opened `restart-map.nix`, rewrote a different
  domain's entry, and left this comment untouched — correctly, for a PR scoped
  to accessibility. **A follow-up parked on somebody else's PR has no owner and
  no trigger**; it is a note wearing a plan's clothes. Done properly on its
  own — ✅ **[haus#362](https://github.com/hausfold/haus/pull/362), merged
  2026-08-14**, hours after it was named, so the follow-up-with-an-owner
  experiment closed the same day. One data point, and it shows the cheap half:
  a follow-up carrying a repo, a PR and an owner lands. It does not show that
  the parked one never would have.
  → ★ **And doing it turned up something stronger than "nobody needs the
  isolation today": the `SystemUIServer` entry is untestable in place.**
  `com.apple.menuExtraClock` and `com.apple.controlcenter` are in core's
  `typedDomainsWritten` **unconditionally** (only `com.apple.universalaccess`
  has a `restartDeclaredBy` gate), so both processes are killed on every rebuild
  of every machine whether or not a clock option is set. No observation of a
  rebuild can ever attribute the clock's re-render to *this row*; the only
  experiment that isolates it is deleting the entry and seeing what stops.
  Generalises to the whole table: **an always-fired entry in a table of triggers
  is falsifiable only by removal.** `com.apple.screensaver = "none"` has no such
  problem, which is why it is the one that genuinely got confirmed.
  → ★ **The eye-check that mattered was the one that came back boring.** This
  box and the matrix's `mouseDriverCursorSize` row were filed as the same class
  of open item — "wired and plausible, not yet watched" — and were resolved in
  the same hour with opposite results: this pair needed nothing, that pair
  needed a daemon kill nobody had modelled (§5.12). **Being in the same class of
  unverified is not evidence of being in the same state**, which is exactly the
  inference a shared "not yet watched" label invites. Both cost one look.
  → Test state reverted afterwards: the host-file block was temporary, and
  `askForPasswordDelay` was deleted rather than left at 60 — a `defaults` write
  outlives the option that made it, so an eye-check that weakens a security
  setting has to clean up after itself by hand.
- [x] Give the login half of "Lock / login / screensaver" and Windows an honest
  way to say "takes effect at next login" (the way `haus.accessibility`
  says "needs Full Disk Access") — that's what unblocks building them, not a
  fix to the domain itself, since neither has a live-reload path on macOS 26.
  → ✅ **Done 2026-08-19, and all three groups shipped in the same change** —
  `modules/lib/login-map.nix`, the third table beside `restart-map.nix` and
  `reachability.nix`, plus `haus.windows.{stageManager,nativeTiling,desktop}.*`,
  `haus.lock.login.*` and `haus.security.guestAccount`. Building the mechanism
  and the groups together was deliberate: a table with no consumer is a
  proposal, and the previous bullet in this very box is what a follow-up with
  no owner looks like.
  → ★ **It is a RENDERER over restart-map, not a fourth list of domains.** The
  domain-level fact ("`com.apple.WindowManager` waits for a logout") already
  existed as the `logout` verb; copying it would have been the fourteenth
  pass's "a table plus a filter over that table is two sources of truth wearing
  one name". So `login-map.nix` READS that verb and adds only what a verb can't
  carry — what the wait costs, in the words the person setting the option
  needs. One fact, three renderings: the option's description, activation's
  announcement, `haus plan`'s warning.
  → ★ **The generalisable half is which direction the check runs.** The obvious
  build is a table checked against the options; this one fails the build when a
  domain becomes `logout` with NO sentence, and again when a sentence outlives
  its domain's logout-only status. A third check (`login-note` in flake.nix)
  covers the step neither table can see: whether the options actually
  interpolate the paragraph, read off the EVALUATED option tree rather than the
  source, so it passes whatever route the prose arrives by and fails only on a
  person meeting the option and not being told. Confirmed red by deleting one
  interpolation — an unfalsified check is a comment.
  → ★ **And the gate matters as much as the message.** `logout` fires no
  process, so an unconditional entry costs no Dock bounce — it costs the signal
  itself. A "waits for a logout" line on every rebuild of every machine is one
  people learn to skip, and then the rebuild that genuinely waits says nothing
  anyone reads. `restartDeclaredBy` now covers both domains, read off the
  resolved `system.defaults.<domain>` block so it stays true for a host writing
  the domain directly. Restated for a verb that prints rather than kills:
  **"which restart" is data; "does this rebuild need one" sometimes isn't** —
  which is now the third time that sentence has earned its place.
  → **◐ Half of it existed since haus#353** (§5.11) — the other half is the one
  the entry above closed; both bullets below are kept as written, because how
  the second half was *found* is the useful part: activation announces every
  logout-only domain the built configuration writes and `haus plan` reports it,
  so the *machine* now says "this waits for a logout". What's still missing is
  the half this box is really about — saying it at the **option**, in its
  description, before anyone builds anything. The FDA note it points at is a
  property of the option; this is a property of the rebuild. Building these two
  groups needs both.
  → ✅ Both exist now. Worth noting what the finished thing did with this
  framing: the two halves turned out to be one fact rendered twice, not two
  facts, which is why `login-map.nix` reads the restart map instead of sitting
  beside it.
  → ★ **And the other half now has a worked example to copy, from the analogy
  this box was already drawing.** §5.12 (haus#356) built exactly that shape for
  Full Disk Access: one table
  ([`modules/lib/reachability.nix`](https://github.com/hausfold/haus/blob/main/modules/lib/reachability.nix)),
  which *generates* the affected options rather than being checked against them,
  and which core also renders into the built activation script for `haus plan`
  and `haus doctor` to read back. `restart-map.nix` could carry `logout` the same
  way — the missing piece was never the data, it was a description that can't
  drift from it. What §5.12 additionally proves is the failure mode to design
  against: the FDA note lived as prose in six places before it lived in a table,
  and every one of them was separately true and separately maintained.
- [x] Spike Sound, Locale/input sources and Power the way §4 spiked
      universalaccess/dock/finder/etc — **done 2026-08-08**, three probes on the
      shelf (`notes/probes/{sound,locale,power}-sweep.sh`) plus two oracles
      (`locale-effective.swift`, `tis-toggle.swift`), results in
      [`macos-settings-matrix.md`](./macos-settings-matrix.md#sound--localeinput-sources--power--swept-2026-08-08).
      All three are reachable, and all three are now BUILT (rice#267).
- [x] Teach `modules/lib/restart-map.nix` a third verb — **`notify:<name>`**,
      a distributed notification post — **rice#267**. A map value may now be a
      LIST, because NSGlobalDomain is the first domain to need two verbs
      (activateSettings for the input keys, the notification for the locale
      ones). ★ **The trigger could not come from the map.** NSGlobalDomain is
      written on every rebuild of every machine, so domain membership alone
      would have told every app on every Mac that its locale changed, forever —
      the map owns the notification NAME (the load-bearing half; a made-up one
      does nothing) and the group names its own trigger. Worth remembering the
      next time this table looks like it wants to be pure data: **"which restart"
      is data, "does this rebuild need one" sometimes isn't.**
- [x] Build **Sound** — **rice#267**. `haus.sound.{alertVolume,alertSound,
      volumeFeedback,uiSounds,startupChime}`. `alertVolume` is 0–100 with the
      `e^(p−1)` conversion in `modules/lib/alert-volume.nix` (a Taylor series —
      Nix has no `exp`), pinned by a `nix flake check` whose expected column is
      what CoreAudio *reported*, not a second derivation of the same maths.
      `alertSound` is an enum over `/System/Library/Sounds`, and the write is
      guarded at ACTIVATION rather than eval: ★ **in pure evaluation
      `builtins.pathExists "/System/…"` is `false`, not an error** — an
      eval-time existence check would have skipped the write on every machine
      and passed CI while doing it. That trap generalises to any option that
      wants to check for a file outside the store.
- [x] Build **Power** — **rice#267**. `haus.power.{displaySleep,computerSleep,
      diskSleep,lowPowerMode}.{battery,charger}`, a `pmset` activation step of
      the rice's own, not `system.defaults` and not on top of nix-darwin's
      `power.sleep.*`.
- [x] Cross setting × caller with a live oracle — **done, run 4.** Every write
      lands; `systemsetup` writes one profile (AC) and `pmset` writes the one
      you name. Runs 1–3 were reading a stale plist.
- [x] Build **Locale** — **rice#267**. `haus.locale.{language,region,metric,
      temperature,hourFormat,inputSources}`. `metric` writes both unit keys;
      there is deliberately no `firstWeekday`; `inputSources` goes through the
      TIS API (`hausax input-source enable|disable`) rather than
      `com.apple.HIToolbox`. ★ **It is the first option in these groups that is
      EXHAUSTIVE** — a list is the whole set of layouts — and the assurance pass
      caught that costing a machine its keyboard: `[ ]` type-checked and meant
      "no layouts at all", and a list of typo'd ids warned once each and then
      disabled everything that worked. Three guards now (an assertion, a
      disable pass gated on a declared layout actually being enabled, and
      `hausax` refusing to remove the last one). **A group whose options are
      all "leave it alone by default" can still contain one that owns a list,
      and that one needs a different kind of care.**
- [x] File upstream against nix-darwin — **[nix-darwin#1850](https://github.com/nix-darwin/nix-darwin/issues/1850)**,
      2026-08-08. `power.sleep.*` writes only one power profile on macOS 26
      (`-setcomputersleep` moved AC while the machine was on battery) and
      `system.activationScripts.power` discards the stderr that would show it;
      `notes/probes/power-sweep.sh` is the reproducer. Cross-referenced
      nix-darwin#1421, an open request for `pmset`-based options — this is the
      evidence that the existing ones can't stand in for it.
- [x] ✅ **State §5.6's policy over effective VALUES, and check it** —
      **merged as [haus#472](https://github.com/hausfold/haus/pull/472),
      `mergedAt 2026-08-23T05:25:17Z` (`6bb294c`)**. It was written here as
      `- [ ] ◐ built and open, mergedAt null` for **fifteen minutes** — the
      thirty-seventh pass committed that wording at 05:25:26Z, this tick at
      05:40:25Z — and the promise the previous wording refused to make is the
      one this tick keeps.
      ⚠️ **It did not go stale. It was false when written**, by nine seconds:
      haus#472 merged at 05:25:17Z and the sentence reading *"as of
      2026-08-23T05:30Z, `mergedAt` null"* was committed at 05:25:26Z. The box
      was right to refuse the tick and wrong about why — and a wrong "as of"
      timestamp is caught by nothing here, because the surrounding discipline
      (date it, don't tick it) was followed to the letter. Second time in three
      passes that a status claim was overtaken inside a minute by the very PR it
      is about; the first was the twelve seconds.
      The policy is written about declarations (*"every leaf
      defaults to null"*) and read as a promise about machines (*"a desktop
      writes no macOS key you didn't ask for"*); since 2026-08-22 those differ —
      see the ⚠️ above. The check evaluates each shipping desktop, walks all 66
      leaves of the ten groups, and diffs the non-quiet ones against an expected
      table naming the file that supplied each. It sits beside
      `desktop-projection` in `flake.nix`'s checks and is that check's own idea
      pointed at the leaves it skips: `desktop-projection` pins 55 resolved
      `haus.*` paths and not one of them is in these ten groups. Mutation-tested
      both ways — a room write added to `modules/shelf` reddens both desktops,
      and `sound.uiSounds` added to `desktops/minimal.nix` reddens as
      `desktop:`. It would have caught #461 on the day it merged.
      ★ **What building it turned up, which the sketch did not predict: there
      are no `desktop:` rows at all, and there never have been.** Not one of the
      four shipping desktops names a single one of the 66 leaves. The whole
      curated surface — hot corners, the clock, sound, locale, power, the
      firewall, animations, Stage Manager — is offered and unexercised by the
      product, which is precisely what this section argued for ("a place to make
      an opinion *available*, not to impose one"). The consequence is sharper
      than the intent: **every row this check will ever gain starts life as a
      `room:` row**, because a desktop has never produced one. The thirty-fifth
      pass's topological tell — 29 of §5.6's 33 citations sit inside its own
      implementation, so the rule has never been addressed to a room that merely
      consumes one of these leaves — is now a mechanical fact rather than an
      observation about where text lives.
      ⚠️ Deliberately an expected TABLE in `flake.nix`, not a golden snapshot
      file. §5.14's row twenty is that a drift check whose remedy is *re-bless
      the snapshot* turns "the docs are wrong" into "the docs are current"
      faster than anyone can read which of the two happened; here a new row is a
      code edit that has to carry its argument in the comment beside it.

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
under the rice that file is generated from `haus.pounce.*`, so a copy
written beside it would be silently reverted by the next rebuild. `haus set`
faces the identical two-writers question from the other side;
**(c)** every commented line carries its own trailing comma (the config is read
as JSONC now), so *any subset* can be uncommented without fixing punctuation —
otherwise the file's promise breaks on your second edit.

★ **The rice shipped the reading half first — rice#184 — which split this item
in two before #252 closed it.** A fresh
install now gets `hosts/<host>/options.nix` beside its host file: every settable
option at its default, with description, type and docs anchor, all commented
out, rendered from the same `options.json` hausfold.co and the agent skill are
rendered from, and refreshed by `haus options` after `haus update`. Two
independent repos reached the same shape within days of each other, which is
about as strong a signal as this document gets that the shape is right.

**A third instance landed 2026-08-04, from the other direction:** the rice now
generates `~/.config/holt/config.toml` from `haus.agents.default`, because a
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
- [x] Guard: only `haus.*` paths are settable this way (same boundary as §3.3)

This is what lets someone use a hacker desktop for a year without ever opening
a text editor — the actual bar for "a Mac for my parents".

### 5.8 Generalize `focus` into scenes · M · risk M · ✅ **CLOSED 2026-08-20.** The declarative half merged in haus#376 (`mergedAt 2026-08-16T18:06:39Z`), the reachability gap it exposed in haus#381 (20:10:48Z), and the trigger daemon this section deferred from its first draft in [haus#423](https://github.com/hausfold/haus/pull/423) (`mergedAt 2026-08-20T05:45:03Z`, `da94efd`) — `scenes.<name>.when` plus `focus auto`. Nothing here is open
`focus` is already a scene with one member: it has hooks, an external
integration (Slack), a bar pill, a CLI, and transient state. Generalize rather
than invent:

```nix
haus.scenes.recording = {
  dnd = true; preventSleep = true;
  audio.input = "Studio Mic";
  apps.open = [ "OBS" ];
  hooks = [ ./key-light-on.sh ];
  restorePreviousState = true;
};
```
with `focus` shipped as the built-in `quiet` scene (keep `haus.focus.*` as
an alias so no host breaks).

Good scenes: meeting · recording · presentation · reading · travel · docked ·
deep-work · away. Triggers worth having: Pounce command, time, Wi-Fi SSID,
power source, display attach.

- [x] ✅ **The declarative half is MERGED — haus#376, `mergedAt
      2026-08-16T18:06:39Z`, merge commit `3690be1`.** Verified against the
      repo, not a checkout: `haus.focus.scenes.<name>` reads back off main's
      own `docs/site-data/options.json` with exactly the six fields below, and
      the room's page (hausfold.co#64, merged 18:07:04Z) serves scenes on the
      live site. The tick's history stays, because it earned a rule: the
      twenty-fifth pass first wrote this box `[x]` while the PR was open, its
      assurance pass reverted it with `"state":"OPEN"` in hand and coined *a PR
      number inside a `[x]` is a promise; only `mergedAt` keeps it* — and then
      haus#376 merged **38 seconds before** the notes PR carrying the open box
      did (18:06:39Z against workshop#385's 18:07:17Z), so the box was born
      stale in the same minute its rule was written. That is not the rule
      failing; it is why the rule keys on `mergedAt` rather than on any pass's
      memory of state. Everything below describes what landed.
      `haus.focus.scenes.<name>` takes the six fields sketched above under
      exactly those names (`dnd` · `preventSleep` · `apps.open` ·
      `audio.input` · `hooks` · `restorePreviousState`, plus a `description`
      the CLI prints); `focus scene <name>` enters one, `focus scene off`
      leaves it, `focus scene list` shows them. One at a time. The existing
      surfaces — `focus on/off/toggle`, the bar pill, the palette command — run
      the code they ran before, so this is additive rather than a rewrite of the
      engine every one of them shares.
      Four things about the shipped shape, three of which reverse a line above:
      **(a) ★ the namespace moved, because the ROOM RENAME took the word this
      sketch was borrowing.** The block above proposes `haus.scenes.*` as a
      new namespace with `focus.*` demoted to an alias — written in July, when
      the room was `hush` and `focus` was a free word this document had picked
      up (the naming banner's own paragraph on §5.8 notices the coincidence and
      reads it as a happy one). [haus#367](https://github.com/hausfold/haus/pull/367)
      made it the room's actual name **this morning** (merged 10:08 UTC), and at
      that moment the sketch's central move inverted: a `haus.scenes` room beside
      a `haus.focus` room is **two rooms for one job**, which the room doctrine
      ([`rooms-desktops.md`](rooms-desktops.md)) exists to forbid, and the alias
      that was supposed to protect hosts would instead **retire a room name on
      the day it was given**. So scenes ship *inside* the room, as
      `haus.focus.scenes.<name>`, and no alias is needed because nothing moved.
      The generalisable half is not about scenes: **a sketch that borrows a
      plain English word is fine until the codebase adopts that word, and then
      the sketch reads as a proposal about the thing now called that.** Nothing
      in §5.14's table catches it — the entry didn't go stale, get falsified, or
      disagree with its marker; the *tree* moved underneath a sentence that
      stayed true and stopped meaning the same thing. New row added there.
      **(b) `quiet` is reserved rather than declared.** The sketch says "`focus`
      shipped as the built-in `quiet` scene"; what shipped is `focus scene
      quiet` as an alias of `focus on`, with a module assertion refusing a
      host-declared `scenes.quiet`. Quiet's state is read from the OS
      (`Assertions.json`, or the signed pounce), not from a state file, so a
      second thing called quiet would be one the pill and the palette could
      never reach — the pill lying is this room's oldest failure mode and the
      one its whole design note is organised around. `off`, `list` and `status`
      are reserved beside it for a duller reason: they are the words after
      `focus scene`, so a scene named for one would build, validate, appear in
      `focus scene list` and never be enterable.
      **(c) a scene is DATA read at runtime**, a JSON file the module writes,
      not a generated shell fragment — otherwise every field is a place where a
      desktop's string becomes code, the same reason `bar.media.icons` has a key
      rule in the desktop walk. `scenes.<name>.hooks` is host-only for the
      reason `focus.hooks` already was; everything else is desktop-safe behind a
      new `scene-entries` validator, so a **published desktop may ship a
      scene** — which is the only version of this item that serves §6's
      readiness test rather than just Julien's Mac.
      **(d) it left no scene behind.** The box below wants one hand-written
      scene to prove useful before the daemon; a scene shipped in `hacker`
      would be this file marking its own homework, so the layer ships the
      mechanism and the proof is a host edit.
      ⚠️ **Amended 2026-08-20: the six fields are seven, and the CLI this box
      describes was not on anyone's `PATH`.** Both from the first feel-test of
      what shipped, both in
      [haus#408](https://github.com/hausfold/haus/pull/408) (`6510aa6`,
      2026-08-19T09:50:02Z). `scenes.<name>.apps.closeOnExit` (default `false`)
      is the other half of `apps.open` — a work mode that opens OBS can take it
      away again — and it follows the room's existing rule that a scene only
      ever reverses a lever it actually pulled: it quits exactly the apps that
      entry started, recorded in `scene-prev.json` beside `tookDnd`/`tookAudio`,
      leaves alone one you already had open, and still closes what it opened
      after the host has deleted the scene and rebuilt. Re-derived rather than
      counted off the commit, per the fifth pass's rule:
      `jq -r 'keys[]' docs/site-data/options.json | grep -E
      '^haus\.focus\.scenes\.<name>\.'` at haus `148c303` returns **eight**
      leaves — those seven plus `description`. ⚠️ **Thirteen on haus#423**,
      which adds five under `when.`: the count above is dated at a rev, which is
      this file's whole mitigation for a number that moves, and the pass that
      moves it is the cheapest place to leave the pointer.
      The same PR moved the engine to
      `$out/bin/focus` on `home.packages` (the `~/.local/bin/focus` link stays,
      pointed at the same store path, because the pounce daemon and sketchybar
      run with minimal environments and get no profile bin dir): every doc
      example reads `focus scene list` and until then only the full path
      answered. **A room whose whole surface is a verb has to answer to that
      verb in a shell**, and nothing in this box's design half would ever have
      caught that it didn't.
- [x] Only build the trigger engine *after* one hand-written scene proves useful —
      the declarative half is cheap, the trigger daemon is not.
      **Still open and still correct** — and now cheap to act on, since a scene
      exists to trigger. The daemon is what remains: time, Wi-Fi SSID, power
      source, display attach. ⚠️ One thing the build learned that this box
      can't see: a scene has **no surface but the CLI**. Quiet has a pill and a
      palette row; `focus scene recording` has a terminal and whatever
      `keys.leaderExtras` chord a host writes. That is a *reachability* gap, not
      a trigger gap, and it is the cheaper of the two — no daemon, no new
      mechanism. ⚠️ But not as cheap as this box first said: `modules/launcher`
      builds both the installed scripts (`cp ${./commands}/*.sh`) and the
      cheatsheet rows (`readDir ./commands`, then `readFile` each header) from a
      **static directory**, with a comment beside the second explaining that
      reading a *generated* command's header would be IFD on every eval. So the
      staticness is the obstacle, not the reason it's easy: both halves have to
      be fed from `config.haus.focus.scenes` instead. Still modest — the names
      come from config, so nothing is imported from a derivation — and still the
      thing to do before the triggers, because an unreachable scene can't prove
      itself useful, which is this box's own precondition. ✅ **Done**
      ([haus#381](https://github.com/hausfold/haus/pull/381), `mergedAt
      2026-08-16T20:10:48Z`): `modules/launcher/default.nix:224` reads
      `config.haus.focus.scenes` instead of `./commands`, so every scene
      generates a `Scene: <name>` palette command plus a shared `Leave Scene`,
      and the cheatsheet's Palette Commands page grows a row per scene — both
      halves fed from config exactly as the ⚠️ above prescribed, and with no
      IFD, because the names come from the option rather than from a
      derivation. The trigger daemon is the whole of what this box still
      holds.
      ⚠️ **And that ✅ is false about its mechanism three days and four hours
      later — `mergedAt 2026-08-16T20:10:48Z` against `82894a4`
      2026-08-20T00:22:41Z — which is worth more than the correction.** Since
      [haus#413](https://github.com/hausfold/haus/pull/413) (`82894a4`,
      2026-08-20T00:22:41Z) the launcher does **not** read
      `config.haus.focus.scenes`: Focus *contributes* two declared points —
      `_contrib.bar.focus` (a switch, because the pill's click script is a
      binary only that room installs) and `_contrib.launcher.focus`, which
      carries the scenes but only the one field the launcher renders, while
      `hooks`, `apps`, `audio` and `dnd` never cross. `modules/lib/contrib.nix`
      gives the reasoning: a direct read makes the receiver depend on the
      source's option surface, so every renamed source option breaks every
      receiver and nothing in the tree records that the contribution exists.
      Five reads across two rooms went that way; `modules/launcher/default.nix`
      reads `config.haus._contrib.launcher.focus` at `:260-261` as of
      `148c303`. Everything this box wanted is intact — a scene is still a
      palette command and a cheatsheet row — and the sentence above is wrong
      twice over: the read is gone, and the line number moved. ★ **A `file:line`
      in prose is a mirror of another file's formatting**, which is the
      twenty-seventh pass's `pounce-item-grammar` finding in a place with no
      guard to fire; the durable citation is the identifier
      (`_contrib.launcher.focus`), never the line.
      ✅ **MERGED — [haus#423](https://github.com/hausfold/haus/pull/423),
      `mergedAt 2026-08-20T05:45:03Z`, merge commit `da94efd`**, with its docs
      half at [hausfold.co#98](https://github.com/hausfold/hausfold.co/pull/98).
      **§5.8 has no open box left, and neither does Phase 5.** The tick waited
      for that timestamp and nothing else, which is this file's
      own rule is that *a PR number inside a `[x]` is a promise and only
      `mergedAt` keeps it* (the twenty-fifth pass, which tripped on exactly
      this), and neither PR is merged as this is written. What shipped, against
      the four triggers this box has named since July: `scenes.<name>.when` with
      `time` · `days` · `wifi` · `power` · `displays`, ANDed, and `focus auto`
      as one launchd tick every `haus.focus.triggers.interval` (30s). The Pounce
      command from the original list is **not** a fifth member and never was one
      — a palette row that enters a scene has existed since haus#381, so
      "trigger" there only ever meant "a person pressed something".
      ★ **The finding is that the daemon's whole design is one promise —
      it never overrides a state you chose — and that promise is what picks
      every mechanism.** Entry is EDGE-triggered because level-triggering is
      unusable rather than merely different: leave an auto-entered scene at
      09:10 and a level daemon returns it at 09:10:30, forever, with no way to
      refuse short of a rebuild. Entry happens only from a neutral Mac, and the
      edge is spent whether or not it was acted on, so the daemon can't pounce
      half an hour later when you go neutral. And it leaves only what it
      entered — which is the scene engine's own *reverse only the levers you
      pulled* rule (§5.8's own (c), and the assurance finding behind it) holding
      one level up, unchanged. **A rule discovered for one layer paid for the
      layer above it**, which is the opposite of how this document usually finds
      out that two layers disagree.
      ⚠️ Two things it can't see from here, both stated in the PR rather than
      hidden: **nothing in it has run on a Mac** — the decisions are covered by
      53 assertions in `test/focus-auto.sh` over stubbed probes, and the four
      real reads (`pmset`, `networksetup`, `hausdisp`/`system_profiler`) are
      what `focus auto --probe` exists to check in one command — and
      `docs/site-data/` was regenerated **by hand**, because a cloud session
      can't reach nixpkgs (§8), so `site-data-current` is the check that decides
      whether that guess was right.

### 5.9 Open up Bar widgets and Pounce commands · M · risk M · ◐ **pounce's half done, and now the bar's — `haus.bar.widgets` shipped 2026-08-19 (haus#404, `0dec9e8`), field-for-field off the sketch below. What stays open is THREE boxes in this room, not the two this header said until the thirty-second pass: command packs, commands declaring what they do, and — new on 2026-08-20 — the silent failure haus#427's `workspaces` predicate added twenty lines above the comment enumerating "the two ways an items entry fails silently"**
`bar.items` is a closed submodule of 15 bools (13 when this was written — it
grows by one every time a pill lands, which is the argument this box makes).
*(Re-derived on the twenty-fourth pass and the number survived, which is worth
one line because it is the outcome nobody records: `jq -r 'keys[]'
docs/site-data/options.json | grep -cE '^haus\.bar\.items\.'` says **16**, one of
which is the deprecated `claudeUsage` alias for `aiUsage` — so 15 pills, as
written. A count that stays true does so only with its scope attached; the same
re-derivation on §5.5's line above found it six short.)*
⚠️ **And it stopped being true two days later — 17 keys, 16 pills, at haus
`6ba56c8`** (twenty-seventh pass). haus#396 added the `page` pill
(`mergedAt 2026-08-18T08:36:08Z`). The scope sentence above held perfectly and
the number still went stale, which is this box's own argument arriving as
evidence: the closed submodule grows by one every time a pill ships, and a
document quoting its size is signing up to re-derive it every pass. The header
line's "15 bools (13 when this was written)" reads **16 (13 when this was
written)** now, and will be wrong again.
★ **Re-derived again at haus `148c303` (twenty-eighth pass): still 17 keys, 16
pills — and the number has stopped being the argument.** Same command, same
scope, and this time it survived, which matters less than what happened
underneath it: `bar.items` is **sugar** since haus#404, so the closed submodule
still lists sixteen bools and is no longer the only door — `bar.widgets.<name>`
takes a seventeenth from any **host**, and from a shared **desktop** for
everything except the `command`, which stays host-only. The count will keep needing re-derivation and will stop being
evidence of anything; a number that outlives the claim it was recruited for is
the cheapest thing in this file to keep and the easiest to keep believing.
★ **Re-derived at haus `ffcdb0a` (thirtieth pass): 16 keys, 15 pills — the
count went DOWN, and the correction two paragraphs up was never applied.** Two
separate things, and both matter more than the number. **The count fell**
because haus#422 (`206bc0e`) removed `haus.bar.items.page` *and*
`haus.bar.bottom.items.page`: `page` was not deleted, it was promoted out of the
item list into the menu bar's left group, gated by `haus.windows.enable` through
`$BAR_PAGES` like gravity, on the grounds that a page is a property of the
workspace you are on rather than a readout you place. So this submodule counts
**placeable** pills, and the sentence above — *"it grows by one every time a pill
lands, which is the argument this box makes"* — is falsified in the one
direction the box never considered. Over the life of the `haus.bar.items.*`
namespace — the artifact itself dates to 2026-08-09 (`33b5d63`), the namespace
to the rooms rename: 16 from `653d834` (2026-08-16), 17 from haus#396
(`a49a48d`), 16 again at `206bc0e`.
**And the correction above never happened.** "The header line's *15 bools (13
when this was written)* reads **16** now" is a sentence about an edit that was
not made: the line still says 15, and `f449cc9`'s only hunk in this region
(`@@ -3778,6 +3880,14 @@`) never touches it — the nearest context line is the
re-derivation parenthetical above, and the diff's only `15 bools` is the
quotation inside the correction being added. (`git log -S'16 bools'` confirmed
it too, and stopped being able to the moment this paragraph was committed.)
It is left at 15 deliberately, because haus#422 made 15 true again —
the unmade edit had a correctness window of **1 d 21 h 33 m** and applying it
today would run the correction backwards. The shape is in §5.14's table now; the
local lesson is smaller and worth having beside the number it damaged: **when a
pass writes what a line "now reads", the line is the thing to change, and the
paragraph is not evidence that anything was.**
Pounce commands were
script-discovery only with **no Nix option at all**; as of pounce#43 the
*app* has the schema and the **rice** is what's missing — which flips this item
from "design a surface" to "generate a file", the cheapest it will ever be.

```nix
haus.bar.widgets.backup = {
  command = ./backup-status.sh; interval = 300;
  icon = "󰁯"; placement = "right"; permissions = [ "full-disk-access" ];
};

haus.pounce.commands.callAnna = {
  name = "Call Anna"; run = "open facetime://+15550100";
  mutates = false; needsConfirm = false;
};
haus.pounce.packs = [ "everyday" "people" ];   # vs the dev pack
```

Non-dev widget ideas the current set has no room for: Time Machine health ·
mic/camera-in-use · VPN state · Bluetooth device battery · next reminder ·
break timer · storage pressure · NAS reachability · world clocks.

- [x] ✅ **`bar.items` becomes sugar over `bar.widgets` (bundled widgets
      pre-declared)** — [haus#404](https://github.com/hausfold/haus/pull/404),
      merge commit `0dec9e8`, 2026-08-19T08:34:54Z, and the commit body names
      this box. `haus.bar.widgets.<name>` takes `command` · `interval` · `icon` ·
      `placement` · `permissions`, plus an `enable`; all sixteen bundled pills
      are pre-declared into it from one new data table
      (`modules/bar/widgets.nix`, now the single source for a pill's name,
      default, description, rate and grants), so `bar.items.<name>` is
      `.enable`, `bar.bottom.items.<name>` is `.placement`, and nothing a rice
      set yesterday means something else today. Seven new leaves, nothing
      removed, every pre-existing `docs/site-data` entry byte-identical, and six
      bar configurations — stock, focus, bottom-bar spread, everything-on, the
      `claudeUsage` alias, a moved focus pill — generating byte-identical
      SketchyBar files apart from header comments.
      Four things worth carrying:
      **(a) the July sketch above shipped field-for-field — the FIELD NAMES,
      and not one of the values.** Those five names are the ones in the block,
      unchanged. That is the naming banner's observation about this section
      arriving as evidence: **where this file sketched in a room's own
      vocabulary it aged well**, and where it borrowed a plain English word
      (§5.8's `scenes`) the tree took the word and the sketch quietly started
      proposing something else.
      ⚠️ **And the first draft of this paragraph over-claimed by one word,
      caught by the assurance read: `placement = "right"` is a real value of a
      real enum and it does not mean what the sketch meant.** Per the shipped
      option's own text, `"menu-bar"` is the top bar and where every pill goes
      unless something says otherwise; a bare `"right"` is the **bottom** bar's
      right group, the spelling `haus.bar.bottom.items` uses, and it needs
      `haus.bar.bottom.enable` — which #404 asserts on, so the sketch's `backup`
      pill copied out of this file lands on a bar the reader may not have
      turned on. The sketch's own shape, in other words: a name survives a
      three-week gap and a **value** doesn't, because a value is only meaningful
      against an enum that didn't exist when it was written. Sketches are cheap;
      the vocabulary they're written in decides whether they survive contact,
      and their example values don't survive at all.
      **(b) the desktop seam splits the open form down the middle.**
      `widgets.<name>.command` is **host-only** — a desktop that can add a timer
      running arbitrary shell is no longer a file you can read to know what it
      does, the same reasoning as `keys.leaderExtras.*.command` — while
      placement, icon, interval and enable are desktop data behind a new
      `widget-entries` validator (in `modules/lib/desktop.nix`, with its rule
      sentence rendered onto the options page by hausfold.co#86). So a published
      desktop rearranges and retunes the whole bar and brings **no code**, which
      is the version of this box §6's readiness test wanted rather than the
      version this machine wanted.
      **(c) opening a closed submodule is how you find the invariants it never
      stated.** `bar-bottom-groups` caught the real one: naming a pill in
      `bar.bottom.items` has always DRAWN it, so placement implies enablement,
      and deriving `enable` from `bar.items` alone silently emptied the bottom
      bar of every default-off pill. Two more came out of the PR's own assurance
      pass, both silent in the same way — a widget name SketchyBar can't address
      (`widgets."my widget"` emits `--add item my widget right`, read as item
      `my` in group `widget`: no error, no log line, no pill), and a name the
      hand-written rc already claims (the logo, the front app, the tour's pill,
      `aiUsage` drawn as `ai_usage`). **A closed enum is a place an invariant
      can hide unstated, and opening it is the act that asks.**
      **(d) one promise was removed rather than kept**, which is the honest half:
      the first draft's prose named `haus doctor` and a generated
      `widgets_config.sh` as today's reader of `permissions`. Neither exists, so
      the commit says the field is a declaration and nothing more. See the
      `Commands declare:` box — the last one in this section — which is the same
      shape and has a sibling now.
- [x] ✅ **Pounce's window sizing is an option now** (pounce#53 + rice#175).
      `windowMode` had been written straight into `config.json` with no option at
      all; it is `haus.pounce.windowMode` now, and it gained a sibling —
      `haus.pounce.scale`, following `ui.scale` — because writing the option
      exposed that one enum was answering two questions. `windowMode` is the
      layout's *proportions*; `scale` is how big it's drawn; they compose. See
      §5.2 for the app-side seam that made the second one possible.
- [x] **pounce side: `config.json` grew an `items` map** (pounce#43), keyed by the
      frecency key so commands, apps and built-in modes share **one address space**
      (`cmd:` / `app:` / `mode:` — **four prefixes since pounce#80, 2026-08-14**:
      `shortcut:<uuid>` addresses a Shortcuts-library entry), each taking
      `enabled` / `alias` / `hotkey`. The
      design fork recorded there was *one schema now* vs *a key per stage*, resolved
      to one **because these ripple into `haus/modules/launcher` either way** —
      i.e. the rice-side option was a known consequence, not an afterthought.
- [x] ✅ **rice side shipped — rice#149.** `haus.pounce.items` generates that
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
      ⚠️ **Amended on the twenty-third pass, and it is shape 2 (a closed claim
      falsified) at its most expensive: that validation is a MIRROR, and a mirror
      of another repo's grammar fails in the direction this box never considered.**
      pounce grew a fourth prefix (`shortcut:<uuid>`, pounce#80) and haus's lock
      moved to it two minutes later, so the layer spent a day asserting that a key its
      own daemon accepts *"is not an item key"* — validation whose failure mode
      is not a missed typo but a **refused valid key**, in the user's face, at
      build time. Fixed and pinned to the *locked* pounce's source by
      `pounce-item-grammar` ([haus#365](https://github.com/hausfold/haus/pull/365);
      see the twenty-third pass's block at the top). The
      generalisable half is in §5.14: this box argued the risk of the small
      mirror beside it (`mode:` names) and never the risk of the enumeration
      itself.
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
      ⚠️ **Amended 2026-08-20: it landed a second time, in a third room, and the
      half that didn't come with it is the second clause of that sentence.**
      `haus.bar.widgets.<name>.permissions` (haus#404, `0dec9e8`) enumerates
      eleven values — accessibility, automation, calendar, contacts,
      full-disk-access, location, microphone, network, photos, reminders,
      screen-recording — of which **ten are macOS grants**: the option's own text
      says `network` "is not a macOS grant at all, and is here because 'this
      pill talks to the internet' is the property people actually want to see on
      a widget they didn't write". The layer requests none of them, nothing
      reads the list, and the description says that out loud too. ★ **And it
      says it by quoting this box.** Its closing line — *"the declaration lives
      with the thing, the consumer reads it"* — is the sentence three lines
      above, arriving in a generated options page by way of a PR, which is the
      friendliest version of reason 1 this file has recorded: the prose crossed
      the repo boundary even though nothing mechanical could carry it. What
      didn't cross is that the second clause is true of nebelung's ports and not
      yet of this field. So the
      shape exists twice and only nebelung's ports have a consumer. That is not
      a complaint about #404: a widget you didn't write can be read for what it
      reaches for, which earns the field on its own, and naming a reader that
      doesn't exist is the thing that PR deliberately backed out of. What it
      does is move this box's cost — **the schema is no longer the open
      question, the reader is**, and whoever builds the pounce half should build
      one reader for both surfaces, or the third instance will declare into the
      same void.
      ⚠️ **Amended 2026-08-20 (thirty-second pass): the third instance
      arrived four hours after that sentence merged, it did NOT declare into a
      void, and the box is still open — because this list has been counting
      declarations when the hazard belongs to one kind of them.** The chain, all
      `mergedAt`: the prediction merged in workshop#406 at 04:08:32Z;
      [pounce#92](https://github.com/hausfold/pounce/pull/92) at 08:15:24Z gave
      `items` two per-item predicates, `workspaces` and `bundleIds`, deciding
      where a row is LISTED; [haus#427](https://github.com/hausfold/haus/pull/427)
      mirrored both into `haus.launcher.items` **25 seconds later**, at
      08:15:49Z. It shipped with three readers in two repos — pounce filters the
      rows at summon time, `pounce doctor` names every scoped item and which
      rows the current page leaves out, and haus's own cheatsheet card appends
      `· on T` to a scoped row's caption — `workspaces` only; that caption has
      never read `bundleIds` — because, in the PR's own words, "The palette
      can't explain an absent row; this can."
      **The two kinds this box had been adding together:** *descriptive* —
      nebelung's port metadata and `bar.widgets.<name>.permissions`, which state
      a property of the thing, where a reader is optional and one of the two
      hasn't got one; and *operative* — `workspaces` / `bundleIds`, where the
      declaration IS the behaviour, so a reader cannot be missing, because a
      missing reader means the field does nothing and the feature was never
      built. The void is a hazard of the descriptive kind alone. This box's own
      three questions — mutates? needs confirm? needs network? — are all
      descriptive, and all still unbuilt (checked at pounce `10fd02f`: no
      `mutates`, no `needsConfirm`, one unrelated comment). So the instances
      that bear on this box are still **two**, with one reader between them, and
      the prediction stands unfalsified rather than confirmed. What #92 does
      supply is the cheapest filling for the reader-shaped hole: `pounce doctor`
      is now a surface where a per-item declaration is explained to a person,
      and it is the one place that could read all three fields at once.
      ⚠️ **Amended 2026-08-20 (thirty-third pass): the fourth field landed the
      same day and the split held.** `whenFile` — pounce#93 at 16:00:30Z, a
      command header key rather than an `items` leaf — is *operative*, and it
      arrived with its reader inside its own PR: `pounce doctor` names every
      command that declares one, the file it watches, and whether that file is
      hiding the row right now. So the operative fields are three, with three
      readers between them, and the descriptive pair still has one. The three
      questions this box asks — mutates? needs confirm? needs network? — are
      descriptive and are still unbuilt at pounce `0c0c3aa`: the instance count
      that bears on the box is **two** for the second pass running, while the
      room around it gained two more fields. The one thing that changed for
      whoever builds this: the reader no longer has to be invented. `pounce
      doctor` reads three per-item declarations already, so a fourth is a line
      in a report that exists.
- [x] **A `workspaces` entry naming a page nothing produces fails silently,
      and the check for it needs no repo boundary.** `modules/launcher/default.nix`
      carries a section header — `---- validation: the two ways an items entry
      fails silently ----` — over the two checks (b) above is about: a key that
      names nothing, and a hotkey already claimed. haus#427 added a **third**
      way twenty lines above that header and did not touch it. `workspaces =
      [ "Q" ]` is an error nowhere: haus writes it, and on a machine that can
      answer "which page am I on" the row is never listed, while on one that
      cannot — no tiler, no recency file — pounce fails OPEN and lists it
      everywhere. Two opposite silences from one typo. The only surfaces that
      mention it at all are `pounce doctor`, which you run after you have
      already noticed, and the cheatsheet caption, which renders `· on Q` as
      confidently as it renders `· on T`. Every member of that enumeration is
      still true and the list is no longer complete — §5.14's newest row, in a
      comment, in the module the pass that wrote the row was reading, added
      **66 minutes before that row merged**.
      **Why it is uncaught looks like the right call, though nothing records
      it as a call.** haus did not mirror pounce's matching grammar — haus#427's
      commit message never mentions the question — and the option is `listOf str`
      with no validator, which is the twenty-third pass's lesson applied — the
      `shortcut:` disaster happened because haus held a closed ENUMERATION of
      pounce's prefixes and the app added one. It paid off unplanned here.
      haus#427 shipped at 08:15:49Z writing a field the LOCKED pounce
      (`adf03c5`) had never heard of, and the lock did not move to `10fd02f`
      until `3b75c7a` at 09:32Z — **1 h 16 m** of generated config carrying an
      unknown key, harmless because `ItemSettings.parse` reads the fields it
      knows and ignores the rest, the same tolerance haus's command headers
      already rely on ("pounce ignores header fields it doesn't know"). **A
      mirror that enumerates breaks on the app's next addition; a mirror that
      only writes degrades.**
      **But the checkable half was never pounce's grammar.** `haus.workspaces`
      and `haus.windows.numberedWorkspaces` are this layer's own declarations,
      already normalized into `haus._workspaces` and `haus._numberedWorkspaces`
      by `modules/workspaces/default.nix` — ungated, and read by three rooms —
      so the BASE segment of a `workspaces` entry (everything before the first
      `/`) checks against a list haus itself owns, with no repo boundary in it.
      The precedent is in that same file and is the identical shape:
      `unknownMembers` warns when `haus.workspaces` names a roster app id that
      doesn't exist, on its own stated grounds that "the ONE thing that's
      supposed to happen … just never fires, with nothing to say why." A
      **warning**, not an assertion, for two reasons the field's own description
      supplies without drawing: the page suffix (`T/haus`) is created at runtime
      by lanes, so it cannot be enumerated at eval, and pounce fails open by
      design, so
      refusing a build over it would be stricter than the behaviour it guards.
      ⚠️ **Amended 2026-08-20 (thirty-third pass): there is a FOURTH way, the
      header is untouched again, and this time the header is not wrong — its
      frame is.** pounce#93 (16:00:30Z) gave a command a `whenFile`: while that
      file's first line is exactly `0`, the row is not listed. haus#436
      (16:09:22Z) is its only consumer — `commands/pages.sh` declares `whenFile
      = ~/.local/state/haus/any-page` plus a haus-only `cheatWhen = while a page
      exists`, and `windows/scripts/workspace-mru.sh` writes that byte on every
      workspace change. `whenFile` is **not an items entry**, so *the two ways
      an items entry fails silently* is still true and still incomplete about
      the thing a person actually experiences, which is a row that is not there.
      **Two checkable halves, neither with a repo boundary in it:**
      **(1)** the state path is a literal in two rooms — `pages.sh:6` and
      `workspace-mru.sh:71` — joined by a prose cross-reference each way and by
      nothing mechanical; a rename in either room hides the row forever or shows
      it forever, silently, and both files are haus's.
      **(2)** the header grammar has **three** parsers that disagree about
      whitespace, and the two keys only haus reads sit behind the strictest.
      Measured (the Nix and awk columns run, the Swift one read off
      `value(of:)` + `field()`): `# pounce: k  = v` and `# pounce: k= v` are
      read by both pounce parsers and missed by haus's
      `"# pounce: ${field} = (.*)"`; an INDENTED header line is read only by
      Swift, while a second space after the `#` is read by nobody — `value(of:)`
      drops leading whitespace and then wants the literal `# pounce:`; a
      trailing space survives into haus's value and is trimmed by Swift. haus's two private keys are `cheat` and `cheatWhen`, and
      they are the ones that degrade quietly — the key box falls back to the
      name's first word, the caption loses its ` · while a page exists` — while
      the two keys haus shares with pounce (`name`, `description`) stop the
      rebuild instead. So the cheapest typo available, one extra space in a
      comment, disarms the caption whose whole job is explaining an absent row,
      for the newest way of making one absent. The fix is one regex or one
      shared parser, and it is smaller than the check this box already asks
      for.
      ✅ **[haus#449](https://github.com/hausfold/haus/pull/449) merged
      2026-08-21T01:25:04Z, closing the original finding** — the base-segment
      check this box's own middle paragraph designed, unchanged from the sketch
      (`haus._workspaces` / `haus._numberedWorkspaces`, case-insensitive, a
      `warnings` entry mirroring `unknownMembers`). Verified against
      `darwinConfigurations.example`: a bogus base (`"Q"`) is flagged, a real
      page's lane child (`"T/main"`) and a real numbered workspace (`"1/lane"`)
      are not, matching is case-insensitive, and the existing 198 assertions
      stay green. **`◐`, not `[x]`, because the box is bigger than the finding
      it started from**: the two checkable halves the thirty-third pass found
      in `whenFile` — the shared state-path literal and the three-parser header
      grammar — are untouched by #449 and still fully open.
      → **The header-grammar half has two PRs open, neither merged yet**
      ([pounce#95](https://github.com/hausfold/pounce/pull/95),
      [haus#459](https://github.com/hausfold/haus/pull/459), both 2026-08-22)
      **— and the first thing they found is that the thirty-third pass
      undercounted the parsers.** It said three. There are **four**: the awk in
      `pounce-palette`, `CommandRegistry.swift`, haus's `commandField`, and the
      `grep -o '^# pounce: …'` inside haus's own `pounce-command-keys` check.
      The fourth is the one worth the paragraph, because widening the first
      three without it is how a check goes **blind rather than red**: that grep
      exists to catch a header key pounce silently ignores, it was the
      narrowest pattern of the four, and a key sitting in a newly-legal
      indented header would never have reached the comparison at all. The check
      would have passed *because it could not see the thing it is looking for*
      — its own comment already warns about this shape ("passing vacuously on
      `when-file`") one column over. **Widening a reader is not done until its
      checker is widened too**, and nothing about the reader's diff says so.
      → ★ **Converging N hand-mirrored copies IS the act that produced the
      drift, so the first attempt reproduced it — twice, in the same commit
      that claimed to have ended it.** The first pass at these PRs fixed the
      `#`-whitespace divergence by editing three regexes, exactly as haus#451
      had fixed the `=`-whitespace divergence by editing one, and its commit
      message said "converge the three header parsers". It had missed two live
      divergences, one of them **named in this very box** two paragraphs above
      (*"a trailing space survives into haus's value and is trimmed by
      Swift"*):
      **(a)** haus's reader kept a value's trailing whitespace where both of
      pounce's trim it — so one stray space in a comment put a stray space
      inside a rendered cheatsheet caption, in the surface whose entire job is
      explaining why a row is absent;
      **(b) the one nobody had written down anywhere, and the only one that is
      behavioural rather than cosmetic**: `submenu` is the single field the
      awk's `END` block never trailing-trimmed, while Swift's `field()` ends in
      `.trimmingCharacters`. So `# pounce: submenu = true ` was a **submenu
      under the daemon and a LEAF under the shell launcher** — the same command
      doing two different things depending on which path summoned it, its only
      symptom a picker that does not open. Present since `submenu` shipped.
      → ✅ **So both PRs now carry a golden table instead of only a fix**,
      which is §5.14's *"when a finding generalises, leave a check behind, not
      a paragraph"* applied to a finding this file had already written down
      once and still lost. pounce gains
      `pkgs/pounce/tests/fixtures/header-grammar/` — one command script per
      whitespace shape — and `header-grammar.tsv`, what parsing that directory
      must produce. The comparison surface is `Entry.registryLine`, chosen
      because it is *already* byte-for-byte the TSV the awk emits, so "the two
      parsers agree" needs no mapping layer that could itself be wrong.
      `tests/palette_header_test.sh` pins the awk by running the **real**
      `pounce-palette` over those fixtures (a stub `pounce` earlier on `PATH`
      captures the registry), so editing that regex in place is what fails.
      haus gains `modules/launcher/header-grammar.nix` — the parser in its own
      file, pure `builtins`, no `lib`, importable by both the module and the
      check without a fixed point, which is `item-grammar.nix`'s shape exactly
      one layer up — pinned by a new `pounce-header-grammar` check over twelve
      cases whose **names are pounce's fixture filenames**, so two repos pin
      the same decisions under the same words even though their tables differ
      in shape.
      → ★ **The table caught (b) on its first run, and would not have if it had
      been written the other way round.** It was written *from the spec* and
      then run; had it been blessed from the parsers' output, `submenu-spaced`
      would have been recorded as `0` and the check would have shipped
      **ratifying** the bug, green forever, wearing the same green as a correct
      one. That is the sharpest version of a trap this file keeps meeting from
      the other side (§5.2's `accent-reach`, `preset-composition` "printing a
      table's own subject"), and it generalises past golden tables to every
      test whose expected value someone obtained by running the code: **a
      fixture you had to execute the code to fill in is a test that ratifies
      whatever the code did.** Both directions were mutation-checked, which is
      the other half of the same discipline.
      → **Three decisions the table now holds that no prose did.** `#pounce:`
      with no space does NOT parse (no parser ever accepted it; accepting it
      would *widen* the grammar rather than converge it) · a key is whole, not
      a prefix, so `names` never satisfies `name` · `NONE` is a **result**, not
      an absence, because three of the twelve cases must fail and a table
      listing only successes goes green on a regex matching everything.
      → 😐 **And one more instance of the family's oldest comment hazard, in
      the fix for it.** A `''` written inside a Nix indented string — in a
      **comment**, explaining that `''` is that string's escape character —
      killed the whole `flake.nix` parse. That is `pages.sh`'s apostrophe bug
      (§5.9's own box, the one word that meant the Pages command "had never
      once parsed on a stock macOS") in a second language: **a comment is not
      inert inside a quoting context**, and both times the character that broke
      it was the one the comment was about. `[[:blank:]]` avoids the quoting
      entirely and is more precise than a hand-spelled space-and-tab class
      anyway.
      → ★ **The assurance pass then found the direction the whole exercise had
      backwards, and it is the generalisable half of this box.** Tolerance is
      not symmetric, because **haus is the PRODUCER of these headers and pounce
      is the consumer.** Widening haus's reader past the *locked* pounce's does
      not make haus more forgiving — it makes haus able to write headers the
      daemon **drops**, losing the row's name, its description, and its
      `whenFile`, which lists a gated row (Pages, of all things) unconditionally.
      The tolerance is still right, because it is for a header a **user**
      hand-types in their own command dir; it is simply not a licence to use it
      in the commands this layer ships. `pounce-command-headers` now enforces
      that ours stay canonical — wide pattern finds every line meaning to be a
      header, narrow pattern is what every parser in both repos agrees on, a
      line in the first and not the second fails the build. **The rule:
      *a mirror may be more tolerant than its source only where it READS what
      strangers wrote; never where it WRITES what the source must read.*** This
      file has the reverse rule already (§5.9's `shortcut:` disaster — don't
      enumerate what the app may extend); this is its other face, and nothing
      here had stated it.
      → **And two more splits in pounce, both the trailing-space bug's shape,
      both found only because the table existed to put them in.** `submenu` was
      **first-wins in the awk and last-wins in Swift** (the one field of five
      with no `isEmpty` guard), so two `submenu` lines gave the daemon a submenu
      and the launcher a leaf; and Swift's `.trimmingCharacters(in: .whitespaces)`
      trims **U+00A0** where awk's `[ \t]` cannot follow, so `submenu = true`
      plus a non-breaking space split the two again — **in a character you
      cannot see, that ⌥Space types on macOS.** Converged narrow (space and tab
      only) rather than wide, because the awk cannot be taught Unicode classes
      and a grammar that agrees is worth more than one that forgives.
      → 😐 **The fixtures can defuse themselves, and five of them silently.**
      Strip the trailing spaces from `trailing-space` or `submenu-spaced`, or
      turn `tab-hash`'s tab into a space, and the expected value **does not
      change** — the table still matches while the case tests nothing. There is
      no `.editorconfig` or `.gitattributes` in either repo standing between
      those bytes and any reformat. The harness checks the fixture bytes before
      it checks the table now. `nbsp-tail` is deliberately *not* guarded, and
      the distinction is the transferable part: **guard exactly those fixtures
      whose corruption would not change the expected value** — for the rest the
      table is already the guard, and a guard that duplicates one is noise
      wearing the shape of rigour.
      → ✅ **Both merged 2026-08-22, eight seconds apart** — pounce#95
      (`ecd7a26`, 10:31:12Z) and haus#459 (`4712700`, 10:31:20Z) — with the lock
      bump behind them (`0f3a61c`, 10:31:39Z) pinning pounce at exactly
      `ecd7a26`. Verified present on `main`:
      `modules/launcher/header-grammar.nix`, the `pounce-header-grammar` and
      `pounce-command-headers` checks in `flake.nix`, and pounce's sixteen
      fixtures under `pkgs/pounce/tests/fixtures/header-grammar/`. ⚠️ **Both
      "twelve" counts above are eleven** — the `pounce-header-grammar` paragraph
      and the `NONE`-is-a-result one. Counted at `0f3a61c`:
      `headerGrammarTable`'s fixture-named `cases` list holds **eleven** entries
      (`canonical` … `not-a-comment`), of which three must miss, and the golden
      text's other five rows are `cheatWhen-trailing` plus **four** `fieldOf`
      rows — sixteen rows over eleven shared names, and five `NONE`s in total.
      So "three of the twelve cases must fail" is right about the three and
      wrong about the twelve. Written from the open PRs and never re-derived
      against the merged file, which is this section's own subject turning up
      inside the paragraphs about it. The last number is
      worth keeping for a different reason: #459's own comment says *"when the
      lock moves past pounce#95 this can read those fixture files directly, the
      way `pounce-item-grammar` reads ItemSettings.swift"* — **a conditional
      TODO whose condition was met 19 seconds after it was written**, by the
      lock bump in the same minute. Nothing is wrong; the twelve case names are
      still hand-mirrored filenames at `0f3a61c`, which is the same
      hand-mirroring one layer up, now with the seam to end it already open.
      ✅ **The other checkable half closed 2026-08-23 (forty-first pass) —
      [haus#493](https://github.com/hausfold/haus/pull/493).** The
      `~/.local/state/haus/any-page` literal shared by `pages.sh:6` and
      `workspace-mru.sh:71` is now declared in `modules/lib/state-files.nix`
      and pinned by `nix flake check`'s `state-files`: every file listed for a
      shared name must exist and must still contain both the name and the
      directory, and no `.nix` under `modules/` may hand-spell a registered
      path. Mutation-checked in all three directions (rename in the writer
      alone, a listed file moved, a `.nix` hand-spelling one).
      → ★ **It was never one pair, and the second one was a `let` block away
      from the first.** Auditing for the SHAPE rather than for the finding
      turned up five files under `~/.local/state/haus` written by one room and
      read by another, across four rooms and in both directions — including
      `workspace-mru` itself, whose absolute path the launcher spells at
      `default.nix:1616` for pounce's `pages.mruFile`, in the same room and
      forty lines from the `any-page` it also names. Two passes wrote this box
      and neither saw it, because both were looking for the instance they had
      already been handed. The others: `aerospace-tiling-mode` (windows writes
      the format, the bar's pill re-reads it with the same awk), `zen-tabs`
      (terminal writes, the bar's media pill reads), and `lidawake/holds`,
      which crosses a **privilege** boundary as well as a room — the bar's
      agent hook creates a hold as the user, core's root daemon reads the
      directory.
      → **What the registry is FOR is the contrast it is written against, and
      `awake` supplies it.** core owns `~/.local/state/haus/awake`, core's
      `awake` CLI is its only toucher, and the bar's caffeinate pill asks by
      **running that CLI** rather than by stat-ing its file — so nothing can
      drift, because there is one spelling. That is the good case and it needs
      no registry at all. The five entries are the pairs where it wasn't
      available: a hook that must not fork, a daemon reading what a user-side
      script writes, a header field pounce stats on the ⌘Space keystroke.
      **Register the ones you couldn't collapse; don't register the ones you
      could have.**
      → 😐 **`grep -q` on a path that does not exist is an ERROR, not a miss**,
      so existence is tested separately from the content grep. Without that
      split a *moved* file reads as a passing check rather than a broken one —
      the same "blind rather than red" trap this box's `pounce-command-keys`
      paragraph found one layer up, met again while writing the fix for it.
      → **And the header this box opened on is fixed by deleting its number.**
      `validation: the two ways an items entry fails silently` said "two" from
      the day it was written, through a third way added twenty lines ABOVE it
      and a fourth that is not an items entry at all. Neither PR touched the
      count and neither had reason to: **a count in a section header is a claim
      about code nobody editing that code is reading.** It names the shape now
      and stops counting — which is the only version of that header that
      survives its next amendment.

### 5.10 `haus.displays` — ✅ **shipped in haus#147** · M · risk M
The spike de-risked this and the accessibility spike gutted its alternative, so
it moves up sharply. It is the **only** working path to "make everything bigger"
on macOS 26. Don't expose `1920×1200`; expose intent:

```nix
haus.displays.internal.uiScale = "larger-text";
# more-space | default | slightly-larger-text | larger-text | largest-text
```
⚠️ **The fence read four values until 2026-08-23** — every one of them still
legal, and the list no longer complete. haus#478 (`mergedAt 07:48:54Z`) added
`slightly-larger-text` because the four assumed a ladder as short as the 14"
MacBook Pro's: a 27" 5K reports nine rungs, so `larger-text` landed four below
the default. §5.14's eighteenth shape, second instance, and it rotted here
rather than in a box because a ✅ header tells a reader nothing in the section
needs checking — a fence is neither a §5 checkbox nor a §6 phase line.

- [x] Persistent display UUID exists → key profiles by UUID, not index
- [x] `CGDisplaySetDisplayMode` is public API → ship a small Swift helper,
      **no `displayplacer` / Homebrew dependency** (it isn't in nixpkgs anyway)
- [x] Helper dedupes modes by point size (they repeat ~6× across refresh
      rate × colour depth) and prefer the highest refresh
- [x] Applying a mode is proven end-to-end on the internal panel: `default`
      (`1512×982`) → `larger-text` (`1147×745`) → `default`, with CoreGraphics
      reporting the requested mode current after each change (2026-07-30)
- [ ] ◐ Multi-display arrangement is still untested. ~~(only one display was
      attached)~~ ~~Test on the dock before designing `profiles.docked`~~ —
      **the design is written (below) and the READ half shipped; what is left
      is the arithmetic, and it needs two panels.**
      ⚠️ **The blocker went away and this box did not move (2026-08-23,
      thirty-ninth pass).** haus#478 was *"verified against both attached
      panels"*, and at haus `56697b7` `hausdisp list` reports `active displays:
      2` — a Studio Display (**main**, nine rungs) beside the internal panel's
      five. So the dock is here; what is still untested is *arrangement*, and
      `profiles.docked` remains undesigned (`git grep -ni
      'profiles\.docked\|arrangement' -- modules/displays` is empty). The box
      keeps its subject and loses its precondition — §5.14's sixth shape,
      second instance.
      ⚠️ **The setup this box names is more expensive than the failure beside
      it (thirty-first pass).** Two rooms answer "is this the built-in?" with the
      literal `"Built-in Retina Display"` — `windows`, in six rows of the
      generated `aerospace.toml` (four in the template, two more written by
      `monLine`), and `terminal` since haus#424, at ~~`float-term.sh:233`~~
      `float-term.sh:364` (the line moved; `:233` was true at `4e2dd61`),
      where a popup's geometry turns on `name === "Built-in Retina Display"`
      (AeroSpace treats the same key as a **regex**; the file prices the
      divergence at 20/36 instead of 10/10). Neither goes through
      `haus.displays`, which shipped the vocabulary for exactly this question —
      `internal`, `main`, `<uuid>`, most-specific-wins. Three rooms do reach for
      that room at `4e2dd61` and none as a selector: `appearance`, `launcher`
      and `focus` cite it in descriptions, and `focus/focus.sh:45` calls its
      binary for a screen count. So the gap numbers ride
      `haus.ui.scale`, a publishable option, while the column they land in is a
      product name: a desktop is portable and its gap selector is not. That
      reproduces on **one** display, on any Mac whose built-in panel reports a
      different `localizedName` — identity, not arrangement, and no dock
      required. ~~`hausdisp list` settles which Macs diverge in one command.~~
      ⚠️ **It does not, and cannot as written (thirty-ninth pass).** `hausdisp
      list` prints a kind, a UUID and a mode ladder; `localizedName` appears
      nowhere in `modules/displays/hausdisp.swift` at `56697b7`. The command
      that answers it belongs to the room with the problem — `aerospace
      list-monitors --json`, which on this Mac returns `Studio Display` and
      `Built-in Retina Display`, so the literal holds here and the divergence
      stays unproven. A box naming its own remedy reads as cheap; a reader
      would have discovered this one wasn't runnable only after committing the
      session to it.
      ⚠️ **The precondition came BACK, four hours later (2026-08-23,
      forty-first pass).** At haus `1e92e15`, on the same machine, `hausdisp
      list` reports `active displays: 1` — the Studio Display is unplugged and
      only the internal panel's five rungs are there. The thirty-ninth pass's
      *"the blocker went away and this box did not move"* was true when written
      and is not true now, and nothing was wrong with it. **That is the
      finding, and it is a new shape for §5.14: a box whose precondition is a
      PERIPHERAL has no stable state at all.** Every other blocker this file
      tracks is monotonic — a bug is fixed, an option ships, a lock moves — so
      a pass can record "no longer blocked" and be believed by the next one.
      A cable is not monotonic. Recording its state dates the note rather than
      advancing the box, and a session that plans around the record instead of
      re-running the command plans around a desk that has since been tidied.
      **Re-derive a peripheral precondition at the start of the session that
      depends on it, never off the file.**
      ✅ **So the half that does NOT need the dock shipped instead
      ([haus#493](https://github.com/hausfold/haus/pull/493)): `hausdisp list`
      now reports what each panel is CALLED and where it SITS** —
      `name="Built-in Retina Display"` from `NSScreen.localizedName`, and
      `at x,y  WxHpt` from `CGDisplayBounds`, beside the UUID. Two things at
      once. It makes this box's own stated remedy runnable at last — the
      thirty-ninth pass struck out *"`hausdisp list` settles which Macs
      diverge"* because `localizedName` appeared nowhere in the file — and it
      is the read half of arrangement, which is what any `profiles.docked` has
      to have before it can write one.
      → **Measured while adding it, which settles the identity half of this box
      on ONE display.** `NSScreen.localizedName` here is
      `Built-in Retina Display` and `aerospace list-monitors --json` reports
      the identical string, so the literal the windows and terminal rooms match
      against holds on this Mac and the two rooms agree. `system_profiler`
      calls the same panel `Color LCD` / `Built-in Liquid Retina XDR Display` —
      a **third** spelling of one panel, which is exactly why the command that
      answers this had to belong to the room with the problem rather than to
      whichever tool was nearest. And the tempting fix is not available:
      AeroSpace 0.21.3's monitor patterns are `main`, `secondary`, a regex or
      an id — **there is no `built-in` keyword** (checked against the shipped
      binary, not the docs), so the product name cannot simply be replaced by
      the vocabulary. It can be *seen*, which is the difference between a
      divergence someone hits and one someone can check for.
      → **`profiles.docked`, designed rather than shipped, and the reason is
      the paragraph above.** Arrangement is untestable on one panel, and this
      box's own instruction — test on the dock BEFORE designing — is right.
      What the design has to be is now constrained by what was measured:
      **(1)** Arrangement is a RELATION, not a per-display fact. `uiScale`
      composes per display because each panel answers independently; two
      origins do not — they can overlap or leave a gap, and macOS silently
      normalises whatever you hand it. So a profile should state
      `rightOf` / `below` / `align`, and `hausdisp` should compute origins from
      each panel's current point size, the way the mode ladder is DERIVED
      rather than tabulated. Same taste, one option over.
      **(2)** The trigger is the attached SET. `haus.displays.<uuid>` is
      already conditional by accident — an absent display exits 2 and is
      skipped — but a profile is a statement about a whole desk, so its
      predicate is "exactly these UUIDs are attached", and `main` is part of
      what it asserts (`CGConfigureDisplayOrigin(…, 0, 0)` is how a display
      BECOMES main; there is no separate call).
      **(3)** The ordering constraint that only exists once both features are
      on: origins are in POINTS, so a `uiScale` change moves every origin. A
      profile must apply scale FIRST and arrangement SECOND or it computes
      against a stale point size — invisible with either feature alone, and
      the kind of thing that would have been found by a user rather than by a
      test.
      **(4)** The apply path is one call inside the transaction `apply`
      already uses (`CGBeginDisplayConfiguration` →
      `CGConfigureDisplayOrigin` → `CGCompleteDisplayConfiguration
      .permanently`), so the mechanism is proven and only the *arithmetic* is
      new — which is the half that needs two panels to test.
      **(5)** A mis-arranged profile is felt instantly and cannot be undone
      blind: the pointer stops crossing between screens. `hausdisp arrange`
      needs a dry run printing the computed origins before it needs anything
      else, and the `at x,y` that shipped today is exactly the input a person
      compares that against.
      → **What is left here is one command with the Studio Display plugged in**
      — `hausdisp list`, read the two origins — and then the arithmetic in (1).
      The box keeps its subject; it has lost its second remedy-that-wasn't-
      runnable and gained the read half it needed.

### 5.11 Reversibility — the trust prerequisite for *any* community · M · risk M · ✅ **closed 2026-08-14 — the four commands shipped and were felt (rice#248), and the last two rendering boxes landed in haus#353**
Before strangers' configs run arbitrary `defaults write` and activation scripts:

- [x] `haus plan` — promote bootstrap's preflight audit; show exact settings,
      packages, and scripts that will change. **Settings and packages**, felt
      through a real `bench try` build; the "scripts" half was still just "what
      packages and casks change" at the ninth pass. **✅ Closed since:
      `plan_restarts` reads the killalls, `activateSettings` and the notification
      posts out of the built script, and haus#353 added the half a restart can't
      cover — the domains that wait for a logout.** See the two boxes at the end
      of this section.
- [x] `haus capture` — promote the `HAUS_KEEP` current-value reader into a
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
- [x] ✅ **`haus doctor` grows a permission checklist with System Settings deep
      links** — shipped 2026-08-14 (haus#353). One `Permissions` section carries
      Accessibility, Full Disk Access and Automation, each with its
      `x-apple.systempreferences:` URL. **What the box didn't say, and is the
      reason it was worth doing: they were three grants reported in three
      different sections and none of them linked.** FDA moved here out of
      `Agents` rather than being stated twice — the fourteenth pass's "a table
      plus a filter over that table is two sources of truth wearing one name",
      in prose instead of Nix.
      ★ **Automation is the first row with no readable state at all.** Every API
      that answers "is Automation granted" *prompts*, and prompting from a health
      check is worse than not knowing — so the row reports whether anything on
      this machine will **ask** (detected from the running home-manager
      generation's `hausSystemAppearance` block) and links the pane either
      way. A checklist may not be able to check; it can still always say where.
      The detection is an `if`, not an `&&` chain: under `haus.sh`'s `set -euo
      pipefail` a chain ending false aborts doctor partway through, printing
      nothing after it — the ninth pass's `settings_diff` bug, and here the
      common case (appearance unmanaged) is the false one.
- [x] ✅ **Restart/logout/reboot annotations** — closed 2026-08-14 (haus#353),
      in two halves that landed a week apart. The restart half was already live
      (`plan_restarts` reads killalls, `activateSettings` and the notification
      posts straight out of the built script). **The half still missing was the
      map's `logout` sentinel: it was subtracted in core and then vanished** — no
      signal at build, none in `plan`, nothing anywhere saying why a write landed
      and did nothing, which is precisely the silence §5.6 refuses to ship a
      settings *group* into while leaving the same silence open to a domain
      arriving via `haus capture`. Activation now announces those domains and
      `haus plan` reads the announcement back out of the **built script**, so the
      reader stays "grep what a rebuild actually runs" and no second copy of the
      map comes into existence. Dormant by construction: no `haus.*` option is
      backed by a logout-only domain today, so it is the signal waiting for the
      first one.
      *(The box as originally written, for the record: "**The data half is done
      and this is now a rendering job** — `modules/lib/restart-map.nix`
      (rice#249) is the table, and `modules/core/default.nix` already derives
      `processesToRestart` from it against whichever domains the built
      configuration actually has. Nothing reads it back for the user: `haus plan`
      still previews packages and casks only … a plan that doesn't say 'this
      rebuild will restart Finder' or 'this setting waits for a logout' is the
      reversibility gap this section exists to close. One consumer, not a new
      mechanism." It was right that no new mechanism was needed for the first
      sentence and wrong that none was needed for the second: a verb that renders
      to nothing has nothing for a reader to find.)*

### 5.12 Accessibility — ✅ **closed 2026-08-14. Designed and built in haus#356; the last 👤 eye-check came back the same day, reopened one smaller thing (all three `unconfirmed` keys work, but only after `killall universalaccessd`), and haus#360 shipped it — the restart-map entry, the three promotions as a new `by-eye` class, and the float key's type. No open box left** · M
Twice-corrected. It's buildable: `universalaccess` writes and takes effect —
**if the app invoking the rebuild holds Full Disk Access**. So the option tree is
viable, but the caveat is load-bearing and has to be designed *into* it.

- [x] ✅ Model these as **`reachability = "needs-fda"`** options (§5.6's
      designation scheme — the box's own words, though §5.6 never names one;
      what it has is the metadata block at the end of the section and
      `restart-map.nix` as its realisation, and *that* is what got copied), not
      as ordinary settings. A rice that silently behaves
      differently on two machines is exactly the failure a shared-rice format must
      not have. **Shipped as `modules/lib/reachability.nix`**, deliberately the
      same shape as `restart-map.nix` and read the same way: restart-map answers
      "what makes this write felt", this one answers "can the write land, and does
      it mean anything" (`reachability` = open / needs-fda, `guardedBy` = which
      option route survives a refusal, and a per-key `effect` of
      effective / unconfirmed / gui-only / noop). Three consumers, no second copy:
      core derives from it, core's activation script **announces the verdict**, and
      `haus plan` / `haus doctor` / `haus rebuild`'s guard grep that announcement
      out of the built script — §5.11's discipline, applied to a second table.
      ★ **The table doesn't just describe the option surface, it generates it.**
      `haus.accessibility` is `lib.genAttrs` over the `effective` keys, so the two
      cannot disagree in either direction: a key promoted in the table with no
      prose fails at eval saying so, and prose for a key the table doesn't back is
      refused the same way. The one thing left by hand is the description, which
      is the one thing a table can't hold. That is what a designation scheme buys
      over a comment — the six hand-copies of "this domain needs FDA" that existed
      before (core's warning, core's domain list, terminal's skill section, the
      guard, doctor's row, and the paragraph pasted into every description) are
      one fact now.
      → **It also went the other way, and that was the point.** The surface grew
      from two options to four — `reduceMotion` and `reduceTransparency` join
      `increaseContrast` and `differentiateWithoutColor` — not for completeness
      but for safety: both are nix-darwin-**typed**, so until now the documented
      way to set them was `system.defaults.universalaccess.*`, the unguarded route
      that aborts activation. **The reason anyone writes the dangerous form is
      that the safe form didn't reach their key**, which is what made the guard
      below un-strictenable. Every measured-working key having a guarded option is
      the precondition for refusing the raw one, not a separate nicety.
      *(One shipped decision reversed on the way: `haus.animations`' description
      said reduced motion was "deliberately not a rice option". The scope
      argument it was making — that five Dock timing keys are not the
      accessibility flag — survives intact and is now easier to make, because the
      flag has an option of its own to point at.)*
- [x] ✅ **`haus doctor` detects FDA — shipped in rice#128** (`has_fda()`, a
      strict `head -c1` read of the TCC database; no `ls` fallback, which is the
      bug that cost a whole spike). It went further than this box asked: the same
      predicate guards `haus rebuild`, so the warning arrives *before* the
      activation it would abort rather than after.
- [x] **Do not** add options that write `com.apple.Accessibility` — that domain
      writes and does nothing. Still true, still the worst failure mode — and
      **as of haus#356 it is encoded rather than remembered**: the table carries
      the domain with `effect = "noop"`, the option generator refuses any key the
      table doesn't call `effective`, and a host that reaches the domain anyway
      (only possible through `haus capture` into its own `CustomUserPreferences`)
      gets a build warning plus a `writes-but-does-nothing` line in `haus plan`.
      Worth stating why it needed more than the prohibition: this is the one
      failure a read-back check *cannot* catch, because the plist reads back
      exactly right on a machine that never moved. A rule nobody can verify by
      looking is a rule that needs a table.
- [x] ✅ ⚠️ **Agent asymmetry** — the sharpest edge in the set, and **closed by
      deleting the question the guard was asking**. Any of these options set in a
      host used to make an agent-driven `haus rebuild` abort activation while a
      manual one succeeded; `haus rebuild` had grown a guard for it, and the guard
      was wrong in **both** directions:
      - **It let three quarters of the agents through.** Its first line was
        `under_agent || return 0`, and `under_agent` tested `CLAUDECODE`. ⌘A
        spawns whichever client `haus.ai.default` names — Codex and OpenCode set
        no such variable, so the one config shape that breaks a machine sailed
        straight past the check written to catch it.
      - **It waved through the human it was protecting.** A person in a terminal
        nobody has granted FDA hits the identical abort and got no warning at
        all — while a Claude pane *inside* an FDA-holding terminal, which was
        always going to work, was the case it stopped. (Measured while closing
        this: the pane that wrote it holds FDA by inheritance, so the guard's own
        author was in the class it refused.)
      ★ **The predicate that matters names no client and no persona:** does this
      configuration write an unguarded TCC-protected domain, and can *this
      process* write it. Agent or human, terminal or `.app`, same question, same
      answer — and it is the same answer the machine is about to give anyway.
      That is the general lesson, and it is not about accessibility: **a guard
      that identifies its caller is guessing; a guard that tests the capability
      is checking.** The old shape came from a true observation ("the agent
      broke it") turned into the wrong predicate ("agents break it").
      → What made strictness *affordable* is the first box above: with every
      measured-working key reachable through a guarded option, refusing the raw
      form almost never refuses a setting that had no safer spelling. Strictness
      and coverage had to ship together — either alone would have been worse
      than neither.
      → **"Almost" is load-bearing, and it is the right residue.** nix-darwin
      also types the three keys the box below leaves `unconfirmed`
      (`mouseDriverCursorSize`, `closeViewScrollWheelToggle`,
      `closeViewZoomFollowsFocus`), so the raw form still reaches something the
      options don't, and the guard still refuses it without the grant. The
      alternative was shipping an option whose only claim is that the plist held
      the value — which is the thing this section has refused three times. So the
      friction sits on the unmeasured keys, costs one rebuild from a granted
      terminal, and disappears the moment someone looks at a cursor.
      ❗ **Someone looked (2026-08-14) and it didn't disappear** — all three keys
      are effective, but only after `killall universalaccessd`, so
      `reachability.nix` correctly still read `"unconfirmed"` for them until
      the restart-map entry landed (box below). The raw form still reached
      something the options didn't; the sentence about what ends that is what was
      wrong.
      ✅ **And then it did disappear, hours later, in haus#360.** The three keys
      are `by-eye` options now, so nix-darwin's five typed keys in this domain
      are five guarded options — the raw route reaches **strictly less** than the
      safe one and the guard costs nobody a setting. Worth keeping the shape:
      the residue was defended here as "the right residue", and it was, but it
      was never a property of the guard. It was three unmeasured keys wearing a
      policy argument. The warning
      and the refusal both name those three rather than implying full coverage;
      the first draft of both claimed it, which is why this bullet exists.
      → And "impossible to hit by accident" is now three layers, none of which
      is a doc: the safe route covers every key, the hazardous one is refused
      before anything is built, and `haus plan` says which grant a rebuild wants
      *before you run it* — a reader that greps the built script without
      executing it, which is the only honest place to report a permission you
      may not have.
- [x] Swept 2026-07-25. **`increaseContrast` and `differentiateWithoutColor`
      write and take effect**, and neither is nix-darwin-typed → ~~reach them
      via `CustomUserPreferences`~~. `increaseContrast` is the OS-level half of
      the high-contrast desktop (§5.1), available with no upstream change. All
      four keys the sweep proved are options now (`reduceMotion` and
      `reduceTransparency` joined in §5.12).
      → ❌ **The route is not `CustomUserPreferences`, and typed-vs-untyped was
      the wrong axis to pick it on.** *None* of the four goes through
      `system.defaults` at all: the layer emits its own `defaults write` for the
      whole domain, in `modules/core/default.nix`'s `hausAccessibility`
      block. `CustomUserPreferences` would have funnelled through the identical
      nix-darwin generator as a typed option — an **unguarded** write inside a
      script running under `set -e` — so the untyped route carries exactly the
      hazard the typed one does. What actually decides the route is **whether a
      refusal is survivable**, which no amount of looking at nix-darwin's option
      list would have told you.
- [x] **Watched 2026-08-14 — all three DO work, and the eyeball found what an
      oracle would have hidden: they need a daemon restart the layer doesn't
      do.** Written bare from an FDA-granted terminal — which is exactly what
      activation does, since `restart-map.nix` carried
      `"com.apple.universalaccess" = "none"` — `mouseDriverCursorSize = 3.0` and
      `closeViewScrollWheelToggle = true` changed **nothing on screen**. One
      `killall universalaccessd` later (same plist, every value intact across the
      restart) the pointer was visibly larger and ⌃+scroll zoomed the display.
      So the keys are **effective and the restart map was wrong about this
      domain** (fixed hours later, haus#360) — the opposite of the failure this
      section kept expecting, where a
      key lands and lies (`FontSizeCategory`, below).
      → ★ **"No restart needed" had been generalised from the wrong four keys.**
      `"none"` is true of `reduceMotion`, `reduceTransparency`,
      `increaseContrast` and `differentiateWithoutColor` — the four with an
      NSWorkspace oracle, which is *why* they are the four that ever got
      measured. Extending their restart behaviour to the domain is what made the
      two unmeasurable keys look dead. **An oracle doesn't just tell you whether
      a key works; it silently selects which keys you learn from, and the
      generalisation you draw is about that sample, not the domain.**
      → `closeViewZoomFollowsFocus` is **effective too, and it took a second
      look to say so honestly.** The first observation — pointer to a screen
      edge, view pans — proves nothing: that is zoom's default *pointer*
      panning, which happens with this key off. Isolating it means parking the
      pointer and moving **keyboard** focus: ⇥ to an input outside the viewport
      and the view snaps to it. It *snaps* rather than glides, which is the
      feature working, not a glitch — expect the option's description to say so,
      because the first thing anyone will report is that it looks janky.
      → **What this unblocks, and what it now costs.** `ui.cursorScale` is no
      longer blocked on "does the key do anything". It was blocked on
      `restart-map.nix` learning `universalaccessd` for this domain — a new
      process kill, fired only on a rebuild that writes `haus.accessibility.*`.
      (Both landed in haus#360, and the promotion class turned out to be
      `by-eye` rather than `effective` — see the box below.)
      Promoting the three keys to `"effective"` *without* that ships an option
      which writes the plist and shows the user nothing until their next logout:
      the exact shape §5.12 has refused three times. **The one-word promotion is
      still one word; it just isn't the whole change any more.** The map value
      is also the place to record that the four oracle-backed keys don't need
      the kill and the three new ones do — one domain, two behaviours, which is
      the first time that has come up.
      → **Byproduct worth knowing before `haus capture` meets this domain:**
      deleting the three test keys afterwards did not return the plist to its
      prior contents. Using zoom once left `universalaccessd`'s own bookkeeping
      behind (`closeViewDesiredZoomFactor`, `closeViewZoomedIn`,
      `closeViewZoomFactorBeforeTermination`, …). **This domain grows keys on
      its own, from ordinary use, with nobody writing them** — so a capture that
      diffs it will report drift that was never configuration, and the
      reachability table is where the distinction has to live.
- [x] ✅ **Teach `modules/lib/restart-map.nix` `universalaccessd` for
      `com.apple.universalaccess`, then promote the three keys in
      `modules/lib/reachability.nix` and write their descriptions.** One PR, not
      two, and in that order: the promotion is what makes the options exist, the
      map entry is what makes them mean anything, and either alone is a
      regression on this section's own bar. Then `ui.cursorScale` (§5.2)
      unblocks.
      → ✅ **Shipped as [haus#360](https://github.com/hausfold/haus/pull/360)**,
      with [hausfold.co#43](https://github.com/hausfold/hausfold.co/pull/43)
      behind it — both merged 2026-08-14, docs second because its `options:check`
      re-renders from haus's `main`. `haus.accessibility` is seven options,
      still `genAttrs`-generated from the table; `ui.cursorScale` is
      unblocked-and-declined, for a reason worth reading in §5.2. It answered
      the question below in a
      way worth reading before the next promotion: a fifth class, `by-eye`,
      because `effective` promises an oracle can re-check the key on YOUR Mac
      and nothing can re-check these anywhere. And it needed a per-KEY restart
      trigger, not a per-family one — `haus.appearance.largePrint` sets
      `increaseContrast`, so the simple version would have bounced the daemon
      on every rebuild of every large-print machine, which is the population
      most likely to have VoiceOver or Zoom actually running.
      → **The question that PR has to answer rather than assume:** the map is
      one process (or list of verbs) per *domain*, and this domain now wants a
      kill for three of its keys and demonstrably doesn't need one for the other
      four. Simplest honest answer is to kill `universalaccessd` on any
      `haus.accessibility.*` write — it costs the four nothing, since they were
      already live before the restart — and to say in the comment *why* the
      entry exists, so the next person doesn't re-derive `"none"` from the
      oracle-backed four the way this section already did once.
      → ✅ **That is what shipped, plus the half this box didn't see.** The map
      value is one verb for the whole domain, as guessed, and the comment says
      why. What the guess missed is that the *trigger* couldn't live in the map
      at all: `com.apple.universalaccess` sits in core's `typedDomainsWritten`
      unconditionally so every lookup finds an answer, so a domain-level trigger
      would bounce `universalaccessd` on **every rebuild of every machine** —
      and `haus.appearance.largePrint` sets `increaseContrast`, so the
      option-family version would still bounce it on exactly the machines
      likeliest to have VoiceOver or Zoom running. core's `restartDeclaredBy`
      gates it on the three `by-eye` keys specifically, read out of the table.
      Third instance of the same rule, now well past coincidence: **"which
      restart" is data, "does this rebuild need one" often isn't** (the locale
      notification, `fdaDeclaredBy`, this).
      → The description for `closeViewZoomFollowsFocus` should say the viewport
      **snaps** rather than glides. That is the feature, and it is the first
      thing anyone will report as a bug.
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

### 5.13 Authorable tour steps · ✅ **shipped in haus#156** · docs workshop#135/#137 · S · risk L
Small, and **nobody else can ship this**. `tour.enable` teaches the four moves
of *this* rice. A community rice teaches its own:

```nix
haus.tour.steps = [
  { hint = "Press ⌘Space to find anything"; detect = "pounce-opened"; }
];
```
The detection signals already exist (the leader-mode scripts). This is the
difference between downloading someone's config and *learning* it.

haus#156 kept `steps = null` as the unchanged built-in lap; supplying a
non-empty list replaces it. `detect` is deliberately the existing outcome
vocabulary (`launch`, `workspace`, `navigate`, `resize`, `palette`), so the
community file remains data-only, and the module warns when a step names a
signal whose room is disabled.

The hand-written authoring guide shipped in workshop#135; the generated public
option family followed in workshop#137.

### 5.14 How this doc drifts — moved to [`drift.md`](drift.md)

**Moved on 2026-08-23**, whole and unedited, to
[`drift.md`](drift.md) — the standing catalogue of the shapes a claim in this
family goes wrong in, and what catches each. **Thirty** rows as of
2026-08-23, numbered by position, **numbering frozen** (and RE-COUNTED here
rather than incremented — the number went stale twice in one day, which is the
shape it is a count of): "row eleven" still means row eleven, and this
section's own findings still read as findings about *this* file, which is what
they were written about.

**The heading stays** for two reasons, both mechanical. `options-roadmap.md
§5.14` is cited by number from outside this file — `haus`'s
`notes/focus-design.md`, four `haus` commit messages including `6bb294c`
(*"§5.14 row twenty"*), and several boxes below — so a rename that leaves no
forwarding address is row fifteen, in a section whose job is to catalogue row
fifteen. (Not from haus's *source*: an earlier draft of this paragraph said
"source comments" and no `.nix` or `.sh` in that repo mentions §5.14 at all.
Its comments cite §5.2, §5.4, §5.6, §5.9, §5.11 and §5.12 — every section that
describes an option, and never the one that describes the document.) And the command that measures this file's open
boxes terminates on this line:

```sh
sed -n '/^## 5\. The option families/,/^### 5.14/p' notes/options-roadmap.md \
  | grep -c '^- \[ \]'
```

The three rules it left behind, restated here because they govern every box
above and a reader should not have to leave the file to meet them:

- **A status-block edit is not a substitute for ticking the box, and the box is
  the source of truth.** The header summarises; the checkbox decides. When they
  disagree, believe the checkbox and go check the repo.
- **Re-audit against the repos, not against memory,** before treating any
  `- [ ]` as work to do — and read the *reason* beside an open box, not just the
  box, because a stale reason is what makes a closed blocker read as ready to
  build.
- **Neither surface above covers a code fence.** §5's boxes and §6's phase lines
  are the two the rules police; a `nix` block inside a ✅ section is read by
  nobody, which is where drift.md's row eighteen landed for the second time
  (§5.10, 2026-08-23). And when an option's *type* moves, nothing here moves at
  all — that is row twenty-six — so grep this file for the option's NAME, not
  for its box.

---

## 6. Phasing

> **These lines are a second checkbox surface, and they drift** — three of them
> described shipped work until the fourteenth pass. Two conventions, so a reader
> picking work off them isn't misled: a line here **summarises a §5 section and
> never overrides it**, and `- ◐` means part-shipped, so `grep '- \[ \]'` alone
> under-reports what is open. When a §5 box is ticked, read the phase line that
> names it in the same edit.

**Phase 0 — ship this week, no architecture required**
- ◐ `haus.fonts` (§5.3) — haus#91. Turned up a real bug on the way:
      bar named `Hack Nerd Font` in seven places and **nothing installed it**,
      so every fresh install had been drawing tofu across the whole bar.
      Phase 0's part is done; §5.3 is `◐` because of the app-side `sans` box,
      which is not Phase-0-shaped work.
- [x] ✅ **Shareable app pack — rice#198.** `packs/writing.nix` +
      `packs/README.md`, exposed as `haus.packs.<name>` and run through the
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
- [x] §3.1 split options (haus#92) — 752 → 122 lines, byte-identical derivation
- [x] §3.2 `developer.enable` (haus#96) — "minimal" is no longer a lie
- [x] §3.3 presets-as-format (haus#98) — `checkRice` + `nix flake check`
- [x] §3.4 generated docs (haus#93 + workshop#81) — page rendered from the module system

  Worth recording: **§3.1 paid for §3.4 immediately.** Splitting options into
  pure `{ lib, ... }` modules is what let the docs generator evaluate them
  standalone on Linux CI, with no darwin system. That dependency wasn't
  predicted here — it's now a comment in the flake, because it's load-bearing
  and its failure mode (docs CI breaks) points nowhere near its cause.

**Phase 2 — know what's possible** ✅ **done 2026-07-25**
- [x] §4 spikes → [`macos-settings-matrix.md`](macos-settings-matrix.md)
- [x] `universalaccess` confirmed dead via a real `darwin-rebuild` — fails as
      root, and aborts activation when set
- [x] Guardrail shipped: haus **warns** when `system.defaults.universalaccess.*`
      is set (haus#89), and it's reported upstream on nix-darwin#1049.
- [x] **Positive case settled** (Ghostty + FDA): `reduceMotion` writes *and*
      takes effect. The sweep then proved `reduceTransparency`,
      `increaseContrast` and `differentiateWithoutColor` too — the last two
      aren't nix-darwin-typed, so they ship via `CustomUserPreferences`
      (haus#90) and give §5.1 an OS-level high-contrast lever.
- [x] `FontSizeCategory` resolved and **rejected**: writes land but post no
      change notification, so apps never re-read them and System Settings
      renders a desynced view. Third member of the write-that-lies family.

**Phase 3 — the expression layer** *(the spike raised this phase's priority: it's
everything macOS can't veto)* — **mostly done 2026-07-27**
- ◐ §5.3 fonts (haus#91) — **the mono half**, plus its reach fixed
      (rice#243) and the proportional half named (haus#363, 2026-08-15). Open:
      the app-side `sans` across pounce/perch/trill, which needs a config seam
      before it needs a font. *(Ticked `[x]` until the twenty-second pass, on
      §5.3's Phase-0 line as well — the phase list is a second checkbox surface
      and this is the drift its own preamble warns about.)*
- [x] §5.2 `ui.scale` — shipped; the sizing pass closed it out at five targets
      (`density`/`motion` still unbuilt). **Pounce and bar both reached**
      (pounce#53 + rice#175): the palette and every panel behind it scale freely,
      the bar's type scales to the menu-bar band's ceiling and stops
- [x] §5.1 theme: **contrast** (nebelung#11 + haus#103) and **flavor / light
      mode** (nebelung#12 + haus#108), then **roster theming from port
      metadata** (nebelung#17/#18/#19 + haus#136) and **pounce off the
      "bakes its own" list** (pounce#37/#42 + haus#139/#142). `scheme = "auto"`
      is now *partly* shipped — per-tool rather than rice-wide, which is a design
      answer as much as progress; `flavor = "custom"` remains untouched.
- [x] §5.5 `keys.*` (haus#108) — leader / palette / windowNav, each with a real
      `"none"`. Per-action `bindings` deferred; it wants an action vocabulary first.
- [x] §5.4 registry v2 — **fully shipped 2026-08-07 (haus#253).** The
      multi-source install landed first as `haus.roster` (rice#182); the
      risky half — `workspaces` — landed as a **clean rename, no back-compat
      alias** (single-user rice, Julien's explicit call), not the
      `roster.*.workspace`-desugars-into-`workspaces` sketch this line
      originally described. See §5.4 for what was measured before calling the
      live host safe.
      ⚠️ The tick stands and the word **"fully"** does not, as of 2026-08-23:
      both gaps this Phase item names did ship, and §5.4 has since opened a
      third that neither of them implied — `scope` is documented as reach and
      is load-bearing as a path. A Phase box tracks a deliverable, not a
      section's future, so it is not reopened here; the pointer is so a reader
      following the tick meets the section's `◐` rather than being surprised
      by it.
- [x] §5.10 displays (haus#147) — the only working system-wide "make it
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
      `start/what-is-haus.md` and `reference/palette.mdx`.
- [x] `guides/window-management.mdx` + `reference/keybindings.md` say the keymap is
      configurable, and that `⇪`/`⌥` in the tables mean "the leader" and "the nav
      modifier" on a rice that moved them.
- [x] ⚠️ **The keybinding tripwire was BROKEN by #108** and nothing in the rice
      could have caught it: `web/scripts/check-rice-bindings.mjs` did
      `nix eval --json --file modules/windows/wm-bindings.nix`, which stopped working
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
- [x] §5.6 curated settings groups — **all ten rows carry a shipped marker, and
      since 2026-08-23 the policy under them has a check**: `settings-writes`
      (haus#472, `mergedAt 05:25:17Z`) resolves all 66 leaves on all four
      shipping desktops, so the rule is enforced over VALUES and not only stated
      over declarations — read that line here as well as in §5.6's box, since
      this list is the surface with no reader (below).
      The ten rows:
      hot corners + screenshots (rice#198), then `lock` (lock half only),
      `menuBar.{clock,controlCenter}` and `security.firewall` (rice#250), then
      `sound`, `locale` and `power` (rice#267), then the tenth group (rice#286),
      then **Windows, `lock`'s login half and `security`'s guest half**
      (haus#405, 2026-08-19T07:31:33Z), which were the three deferred on one
      shared reason — their domains are logout-only — and shipped on a third
      fact table, `modules/lib/login-map.nix`, that renders the wait into each
      option's own description. Nothing is deferred here any more; what stays
      deliberately unbuilt is not a row but a key, remote login, which is not a
      `defaults` key at all. *(This line read "eight of nine" until the
      seventeenth pass and "nine of ten … the one row left is deferred" until
      2026-08-20, both times while §5.6's own header already said otherwise —
      **the same line, drifting from the same section, for the third time**, and
      the fourteenth pass's finding was first found here. `77f23ed` ticked the
      section header and the box and did not touch this line; the twenty-eighth
      pass's assurance read is what caught it. That the same sentence rots three
      times says the mitigation — *when you tick a box, read the phase line that
      names it* — is a habit nobody can be relied on to keep, which is an
      argument for §5.14's other rule: the phase list is a second checkbox
      surface and it is the one with no reader.)*
- ◐ §5.9 — **pounce's half arrived from the app side (pounce#43), the rice-side
      item generator shipped in rice#149, and the bar half shipped 2026-08-19
      (`haus.bar.widgets`, haus#404).** **Two** boxes remain, both pounce's:
      command packs, and commands declaring what they do (mutates state? needs
      confirm? needs network or a permission?). *(This line read "three boxes …
      bar widgets" until 2026-08-20; edited in the same pass that ticked the
      box, which is the fourteenth pass's rule — a phase line and a checkbox are
      one claim written twice.)*
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
      through an `NSWorkspace` probe. ~~Two boxes remain inside §5.11, both `haus
      doctor`/`haus plan` rendering rather than new mechanism.~~ **Both closed
      2026-08-14 (haus#353)** — and one of them was not rendering: the restart
      map's `logout` verb rendered to nothing, so core had to emit the line before
      `plan` could read one. §5.11 has no open box left.
- [x] §5.8 scenes · ~~§5.12 accessibility~~ — **§5.8's declarative half is merged
      (haus#376, `mergedAt 2026-08-16T18:06:39Z`): `haus.focus.scenes.<name>`,
      entered with `focus scene <name>`, desktop-safe except its hooks.** Two
      things stay open behind it, in this order: a scene has **no surface but
      the CLI** (found while building it, and the cheaper of the two), then the
      trigger daemon §5.8's one box has said to defer since it was written.
      **§5.12 is closed as of
      2026-08-14.** The doctor half was already in (rice#128); the designation,
      the option coverage and the guard landed in haus#356; the 👤 eye-check came
      back the same day and turned itself back into code (a `restart-map.nix`
      entry for `universalaccessd` plus the promotions it gates), which shipped
      hours later in haus#360. ~~**So §5.8 is once again the only thing on this
      line needing code**~~ — it was briefly not, because a "just needs a human
      to look" item became work by being looked at, and then stopped being work
      by being built the same day. **And on 2026-08-16 §5.8 stopped being that
      too**, two days later: this line is `◐` rather than `[ ]` because the
      declarative half is merged and the two follow-ups above are not
      started. **Both are since: the reachability gap merged (haus#381) and the
      trigger daemon merged as haus#423, `mergedAt 2026-08-20T05:45:03Z`.** So
      this line is `[x]` as of that timestamp, moved in the same edit as §5.8's
      box per the convention at the top of this section — **and Phase 5 has
      nothing left needing code.** ⚠️ The first draft of this
      sentence went further and said Phase 5 *"now has no item whose next step is
      write the thing"* — which the same pass's own §5.8 box contradicts, since
      it recommends building the palette surface **before** the triggers. Phase 5
      does still have code in front of it; what it no longer has is an item
      nobody has started.
- [x] §5.13 authorable tour steps — shipped in haus#156; documented in
      workshop#135/#137

**The readiness test:** three reference rices that are deliberately far apart —
today's developer rice, `large-print` + `everyday`, and a mouse-first
writer/creative setup — each expressible **without reaching around
`haus.*` even once.**

Scoreboard, 2026-07-27: **all three now exist and pass.** `full`, `everyday` and
`large-print` are data-only (`nix flake check` proves they touch nothing outside
`haus.*`), and none needed a `system.defaults` escape hatch or a
hand-written activation script — which was the whole point of not faking it.

`presets/large-print.nix` is four options (`ui.scale`, `theme.contrast`,
`accessibility.increaseContrast`, `displays.main.uiScale` — it was three before
§5.10 landed) and it is a **layer, not a whole rice**: it
describes seeing, not the person, so `[ everyday large-print ]` composes with
nothing lost either way (measured: stock `1.0 / 19pt` → large-print `1.4 / 27pt /
contrast high` → stacked, plus developer off, windows off, pounce on). That layer
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
   `fonts.*.size` and the tiler's gaps want the same audit.
2. **A stated ceiling is a legitimate third answer.** The bar can't scale
   proportionally — its height belongs to the macOS menu-bar band, which was
   *measured* to have no setting behind it — so it grows its type to 1.25× and
   stops, with the limit written into `ui.scale`'s own description. That's better
   than either a multiplier that clips or a refusal that leaves the bar alone, and
   it is the first place the readiness test's "expressible without reaching around
   `haus.*`" ran into something macOS simply owns. The reason it took one
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
  sides now, so what's left there is `bar.widgets` and command metadata.
  *(Emptier again, 2026-08-20: `bar.widgets` shipped in haus#404, so Phase 4
  holds pounce command packs and command metadata — and the metadata half now
  exists twice as a **declaration with no reader**, in nebelung's ports and in
  the bar's new `widgets.<name>.permissions`. See §5.9's last box, `Commands
  declare:` — what's left to build there is the consumer, not the schema.)*
- Phase 5's §5.12 has its doctor half, so the accessibility line item is now
  purely about the remaining unmeasured keys. **Built out since (haus#356,
  2026-08-14), down to those keys and nothing else**, and the sentence above was
  the tell: "purely about the remaining
  unmeasured keys" skipped the box that mattered, the one that said the whole
  thing had to be *impossible to hit by accident*. A phase summary that
  paraphrases a section can quietly drop the hard box and read as progress —
  §5.14's drift shapes, one level up from the checkboxes.
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

The consumer-side fix is one line (`haus.roster.zotero.key = lib.mkForce
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
pack, at the seam that imports it, never *in* one. `haus.packs.writing`
could carry it; a stranger's pack fetched as a gist and dropped straight into
`extraModules` would not, and would behave differently from the identical file
consumed through the flake — the worst kind of difference, because the file is
byte-identical. Shipping option 1 therefore means shipping the seam as public
API too (`haus.lib.pack ./their-pack.nix`, beside `checkRice`), and
`packs.<name>` stops being a path — today it is one, and
`checkRice haus.packs.writing` works on it.

**(b) The obvious implementation is the broken one, and it fails silently.**
`mkDefault` on the whole `haus.roster` attrset is the one-line version of
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
(`terminal.obsidianVaults`, `theme.ports.handled`, `agents.clients`, and
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
Option 1, per leaf, as `haus.lib.pack`: `packs.<name>` arrives pre-wrapped,
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
| `[ full minimal ]` | 5 | 4 | conflict on pounce/windows/bar/tour — **`developer.enable` overlaps and does not collide** |
| `[ everyday full ]` | 5 | 2 | conflict on `developer.enable`, `windows.enable` only |
| `[ everyday minimal ]` | 5 | 4 | conflict on developer/pounce/bar/tour — they **agree** windows is off |
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
which is exactly what `extraModules = [ haus.presets.everyday … ]` is:

```
error: The option `haus.sill.enable' has conflicting definition values:
       - In `…/presets/minimal.nix': false
       - In `…/presets/everyday.nix': true
       Use `lib.mkForce value` or `lib.mkDefault value` to change the priority…
```

⚠️ **The option name in that block was corrected on the twenty-fourth pass, and
the correction is a finding rather than a typo fix.** It read
`haus.bar.enable`, which **never existed**: on 2026-08-05 the bar room was
`sill`, and `modules/renamed.nix` — generated by enumerating the entire option
tree at the `haus`→`haus` rename — maps `haus.sill.enable` →
`haus.bar.enable` and holds no `haus.bar.*` leaf at all. So a fenced block
introduced by the word *Measured* carried a name the measurement cannot have
printed. Nothing the paragraph concludes changes; what changed is what the block
is evidence OF. The mechanism is the one the naming banner credits at the top of
this file: §5 had been writing `bar` for that room since long before the code
did, so transcribing a real error into the document's own dialect felt like
tidying. ★ **A paraphrase inside a fenced block inherits the authority of a
paste** — and this one became uncatchable on 2026-08-16, when haus#367 made the
string a real option name. The table above it is mixed dialect for the same
reason ("conflict on developer/pounce/bar/tour" — `pounce` was the live
namespace then, `bar` was not), left as-is because it reads as prose.

That names the option, both files and the fix. It is not friendly, but the
premise for option 2 ("detect and translate") was that the consumer is told
nothing — and they are told nearly everything.
⚠️ **And that whole argument is about a printed message, which stops being ours
the moment the input has a publisher.** haus#435 (2026-08-20) measured it while
building `haus show <src>`: `toJSON` escapes quotes, backslashes and three
whitespace controls and nothing else, so `ESC` survives a stranger's desktop —
its values *and its attribute names* — through `jq -r` and back to a raw byte,
and the class line prints before the values, so a file that can move the cursor
can repaint *"not a desktop"* as *"a desktop — data only, and haus checked it."*
Stripped in that PR; the hole predated it, and what changed was that the input
acquired an author. Recorded where it belongs, in
[`rooms-desktops.md`](./rooms-desktops.md)'s step-B findings, not re-told here.
The claim above survives — the consumer IS told nearly everything — with the
qualifier this section never carried: *told*, in a terminal, by a renderer that
has to own every byte it prints.
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
`guides/sharing-a-rice.mdx` — both since deleted; the format doc a stranger
meets today is hausfold.co's `content/docs/haus/desktops/creating.mdx`):

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
[ everyday full ] overlap 5 disagree 2 stops on developer.enable, windows.enable
[ everyday large-print ] overlap 0 disagree 0 composes
[ everyday minimal ] overlap 5 disagree 4 stops on developer.enable, pounce.enable, bar.enable, tour.enable
[ full large-print ] overlap 0 disagree 0 composes
[ full minimal ] overlap 5 disagree 4 stops on pounce.enable, windows.enable, bar.enable, tour.enable
[ large-print minimal ] overlap 0 disagree 0 composes
a host restating full's developer.enable composes
a host contradicting full's developer.enable stops on developer.enable
the same, with lib.mkForce composes, host wins (developer.enable = false)
[ everyday minimal ] plus a plain host contradicting the windows.enable they agree on
    stops on developer.enable, pounce.enable, windows.enable, bar.enable, tour.enable
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

**⚠️ The check is gone, and two of its rows aren't (2026-08-14).** The rooms
refactor's step 5 retired presets as a top-level format, and
`preset-composition` retired with its subject — *"which two presets stack"* is a
question about a property the model now forbids, since a host takes exactly one
desktop. Two rows were never about presets: **a list-typed option merges
silently** and **an `attrsOf` merges per key**. Those moved into
`fragment-compat` intact, because they still bite two **packs** or two
`extraModules` entries. Worth generalising from: a golden table should be read
for the rows that outlive its subject before it is deleted. What (f) still
describes is therefore live for fragments and dead for desktops — the naming
banner at the top of this file carries the same split.

★ **Amended 2026-08-20 (thirty-first pass): that split is an ENUMERATION, and
it has a third member the seam does not reach.** "Live for fragments" was drawn
at the layer this section has always worked at — **definitions**, two authors
each setting a value — and the module system merges at a second one:
**declarations**, two modules each saying an option exists. Measured by
[`probes/namespace-collision.nix`](./probes/namespace-collision.nix) (written
for [`rooms-desktops.md`](./rooms-desktops.md) step E, re-run for this pass at
haus `4e2dd61` with nixpkgs `lib` at `391b592e`), two modules declaring
**different leaves under one namespace** evaluate clean, the namespace holds
both leaves, and one author's `config` line steers the other's switch while
`declarations` names only the other. Two corrections to (f) fall out. The
dichotomy is **not about the option's type**: a `bool` merges silently too when
one of the two declarations is bare (`type` with no `default`/`description`), so
"loud on scalars" describes a declaration shape rather than a value shape. And
this row **blends nothing** — it is co-ownership, which is worse than a blend
and commoner, being what two independently written rooms look like. It also
needs **no strangers**: a desktop seam bounds desktops, a module is not a
desktop, and the second claimant need not be a person at all — `rooms/creating`
sends a my-machine-only reader off with *"write a plain module in your own
config and stop reading"* and no namespace rule, so the other end of the
collision can be a future haus release. (That page's order is the opposite of
what step E reports — see the thirty-first pass; what the correction costs is
the invitation, not the hazard.) What (f) describes is therefore live for
fragments, live for **any two modules**, and dead for desktops. The design that answers it is step E's and
stays there; what belongs here is the layer.

★ **And half of it is built, hours after this amendment was written**:
[haus#429](https://github.com/hausfold/haus/pull/429) reserves `haus.my.*` and
warns a machine that declares a `haus.<name>` which is neither haus's nor
reserved (docs half, [hausfold.co#107](https://github.com/hausfold/hausfold.co/pull/107);
both merged 2026-08-20). That does not close (f) — it covers the *namespace*
layer, and the case where the second claimant is haus itself. Two modules
sharing a namespace haus already ships, or a leaf added inside one, are still
silent and still need E1's per-leaf `declarations` walk. What the build learned
is in [`rooms-desktops.md`](./rooms-desktops.md#findings-carried-out-of-step-e0),
including the one this document would have predicted: the design said
"assertion" throughout *and* said it must not refuse, and only one of those can
be built.

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
  one. ✅ **§5.4 shipped 2026-08-07 (haus#253)** — see that section; Phase
  3 has no unstarted item left.

**The next real finding is on a machine, not in this file.** Limit 3's option 1
has since been tried on `packs/writing.nix` — in an evaluator, which was enough
to settle the *mechanism* (see the measurements above) and is not enough to
settle whether a stranger prefers it. What is still only on paper: the third
reference rice — the mouse-first writer — is represented by a pack nobody who
writes for a living has installed.
→ ✅ **2026-08-07: run one rung up from the evaluator, and it held.** Not on
paper any more, but not a stranger's machine either — the middle rung. A real
`mkHaus` build (home-manager and all, not `lib.evalModules` over the pure
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
| every `haus.*` option, `developer.enable`, presets, packs, `haus` | `haus` |
| theme flavors, light mode, high-contrast palette, port metadata, contrast CI | `nebelung` |
| command packs, typed commands, per-item settings, palette-as-settings-app | `pounce` |
| generated options reference, community rice gallery, the guides | `web` |

⚠️ **Three PR prefixes, one repo.** `haus#N`, `rice#N` and `haus#N`
throughout this file all mean the same repo — the layer, at
`github.com/hausfold/haus` since §10 of the rename plan. The spelling records
*when* the line was written, not a different repo: `haus#` is oldest,
`rice#` is the middle period, `haus#` is what to write now. Only the link target
is authoritative.

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

**And the same ordering constraint binds the generated DOCUMENT, in the other
direction — learned on hausfold.co#98, the docs half of §5.8's daemon.** That PR
describes `haus.focus.scenes.<name>.when` in prose and deliberately does *not*
regenerate `content/docs/haus/reference/options.mdx`, because the site's
`options-drift` check renders that page against **haus's default branch**: a
render carrying options that exist only on a haus PR branch fails the site's own
CI until the upstream PR lands. So a docs PR written alongside an unmerged
feature can carry the words and cannot carry the artifact, and the regeneration
job owns the page the moment the feature is on `main` — hausfold.co#99, 22
minutes after haus#423, with the prose half (#98) in at 17. That run was the
`workflow_dispatch` arm rather than the schedule (`options-drift`'s cron is
Mondays; this was a Thursday), opened by `github-actions[bot]`. The rule of
thumb: **a hand-written page may describe an unlanded upstream; a generated one
may not, and the check that enforces it is what makes the split safe rather than
a nuisance.**

---

## 8. What a cloud session can actually verify here

Recorded because §5.1/§5.5 were done from Claude Code on the web, and the house
rule is to *diff derivations rather than assert no-change* — which needs some
care when a full `nix eval` is off the table.

**Doesn't work** (as the workshop CLAUDE.md says): a darwin evaluation, `bench
try`, `nix flake check`, or nebelung's `nix build`. nixpkgs, nix-darwin,
home-manager and catppuccin all resolve through the session's GitHub gate and
only hausfold-org repos are in scope.

★ **Corrected 2026-08-20 (thirty-first pass): the gate is `api.github.com`, not
github.com — and the difference is a `lib` you can pin.** Both ends measured
from this session: `nix flake metadata github:NixOS/nixpkgs` 403s with the
proxy's `add_repo` message, exactly as the paragraph above says, while `nix
flake metadata git+https://github.com/numtide/flake-utils` **resolves** — a
third-party org, fetched from github.com, in a cloud container. A `github:`
flakeref goes through the API; `git+https` is the same anonymous git read the
proxy already serves for the "every other repo in the family, read at a rev"
bullet below, which was never restricted to our org — only ever tested there.
The practical gain over the channel tarball is a **rev**: nixpkgs' pure `lib/`
in one 15 MB sparse clone (`--depth 1 --filter=blob:none --sparse`, then
`sparse-checkout set lib`), which is enough to run haus's own
`modules/lib/desktop.nix` and `modules/options-groups.nix` through
`lib.evalModules` — its real validator over its real registry, in seconds, on
Linux. That is how [`probes/namespace-collision.nix`](./probes/namespace-collision.nix)
runs from here, and how §6(f)'s amendment was measured rather than borrowed.
*(Reasoning, not a measurement: this does not put `nix flake check` in reach.
haus pins all nine of its inputs as `github:`, so a full eval needs every one
rewritten, and the darwin half stays out however they are spelled. And
flake-utils' printed `systems` input is not evidence that transitive `github:`
refs resolve — `flake metadata` reads that from the committed lock rather than
fetching it.)*

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
- **A generated artifact, hand-written — but only where a check builds the
  generator.** The twenty-ninth pass could not run Nix and hand-wrote
  `docs/site-data/` anyway; the thirtieth measured that it held, by diffing the
  next machine regeneration (haus#422, 24 minutes later) key by key and finding
  nothing in it but that PR's own subject. What makes this a technique rather
  than a gamble is `site-data-current`, one of the twelve portable checks haus's
  `check.yml` runs on a Linux runner: had the guess been wrong, the refusal
  would have come from GitHub rather than from the author. **Hand-writing a
  generated file with no such check is not a guess with a check behind it, it is
  just a guess** — and the same holds where the check exists but is
  darwin-guarded, which is half of them: `check.yml`'s census names twelve
  portable checks and twelve darwin-only ones.
- **nebelung end to end.** `node --test` runs natively, and `whiskers` builds from
  crates.io (`index.crates.io` bypasses the proxy). Version 2.9.0 reproduces the
  committed `dist/` byte-for-byte, which is what makes "the latte variants are a
  pure addition" a `git status` observation rather than an assertion.
- **Every other repo in the family, read at a rev.** The proxy serves anonymous
  git reads of public GitHub repos, so `git clone --filter=blob:none
  --no-checkout` puts haus, pounce, holt, perch, nebelung, trill and
  hausfold.co in reach for `git log` and `git show` even though only the
  workshop is an *attached* repo — which is the whole of what a §5.14 audit
  needs, since the audit is reading commit bodies and re-deriving counts out of
  committed artifacts (`docs/site-data/options.json`, `flake.nix`). Two caveats
  worth knowing before relying on it: the GitHub API tools do **not** cover an
  unattached repo, so `mergedAt` and PR state are unavailable and a merge
  commit's committer date is the closest stand-in (identical for a squash
  merge); and a broad `git grep` over a blobless clone re-fetches every blob it
  touches and will time out — reach for `git show <rev>:<path>` instead.
  ⚠️ **And `add_repo` does not lift that ceiling.** Calling it on a public
  hausfold repo answers `read_available` and attaches nothing — the proxy was
  already serving the anonymous read — so the API tools stay closed and there is
  no way from here to see whether a check went green, only what a commit says
  and what its diff contains. Worth knowing before a pass plans around
  `mergedAt`: it is one call to confirm, and it always ends the same way.
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

★ **The first recorded cost of that advice, and it landed on the pass that
followed it.** haus's `df8b269`: *"`nix fmt` had never run on #422 or #423.
focus's whole `lib.mkIf cfg.enable` body sat two columns short; terminal's
`replaceStrings` call had been hand-wrapped across three lines where the
formatter wants one."* One file from each PR, and only `modules/focus/default.nix`
is the cloud pass's — the `replaceStrings` wrap is haus#422's, written on a Mac
that could have run the formatter and didn't, which is the wider version of the
same gap. Whitespace-only, proven rather than asserted — `nix flake
check` resolved every check to its previously-built derivation — and the six
files that were already unformatted were left alone, because this repo isn't
fmt-clean and CI doesn't check it. The lesson is not "run the formatter after
all": it is that **the advice above protects the DIFF and says nothing about the
FILE**, and the two come apart exactly when a cloud session hand-matches an
indentation it cannot run the formatter against. The fix is one command and its
own commit, after the change lands: format the files that PR touched, alone, and
say in the message that nothing but whitespace moved.
*(Reasoning, not a measurement: §8's own recipe — "copy it, run `nixfmt` on the
copy, `diff`" — cannot catch this failure if "it" is read as the REGION. A
region's expected indentation is a function of what encloses it, so nixfmt on a
detached fragment formats it as though it were top-level and agrees happily with
a hunk that is two columns short in the file. Read "it" as the whole FILE — `cp
f.nix /tmp/f.nix && nixfmt /tmp/f.nix && diff -u f.nix /tmp/f.nix`, then
hand-apply only the hunks inside your own region. Same cost, and it is the only
reading that can see the enclosing block.)*

---

## 9. Naming (optional, low stakes)

The family speaks cat-and-house (`nebelung`, `pounce`, `windows`, `bar`, `core`,
`terminal`, `security`, `focus`, `perch`, `haus`, `holt`). New rooms could keep it —
minus two names this table can no longer have: **`perch` is a shipped product**
(the notch file shelf), and `trill` left the rice entirely in rice#213. Names in
this family get taken while a table like this sits still:

| Room | Candidate | Why |
|---|---|---|
| accessibility — vision | `eyes` | cats' defining sense; `haus-ears.png` already exists in bar |
| accessibility — motor | `paws` | |
| accessibility — hearing | `ears` | |
| keymap | `claws` | what the leader key is |
| displays / multi-monitor | ~~`perch`~~ | taken — it's the notch file shelf now, and the room shipped as `haus.displays` anyway (§5.10) |
| scenes | `moods` | the states the cat is in; `focus` becomes one |
| dev pack extracted from terminal | `quarry` / `kit` | weakest of the set — probably just call it `developer` |

Not a blocker. `haus.accessibility.vision.*` is clearer to a stranger than
`haus.eyes.*`, and strangers are the point. (Settled the other way in the end:
§5.12 shipped `haus.accessibility.<key>` flat, with no `vision` tier — four keys
did not need a sub-namespace, and the names macOS uses are the names people
search for.)

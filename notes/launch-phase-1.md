# Launch Phase 1 — house inspection

The private tester round that gates every public launch in
[`go-to-market.md`](./go-to-market.md). Two weeks, small on purpose.

**What this round is testing: not whether people like it — where the
instructions stop making sense on a Mac you don't own.** Everything downstream
(the Show HN, the Discourse thread, every free launch) assumes a stranger can get
from `curl` to a working desktop unattended. Nobody has ever proven that.

**Size, honestly calibrated.** The research plan said 16 testers / 8 whole-house
installs. That's a recruiting job, not a testing job, for one person with no
audience yet. **Target 8 testers, 4 completed whole-house installs.** Four
independent installs on hardware you don't own will surface the bootstrap bugs;
the 5th through 8th mostly re-find them. If recruiting goes better than
expected, take the extras — but don't let the number gate the launch.

---

## 0. Before you invite anyone

Nothing below works if a tester hits a wall on step one.

- [x] **A documented exit path exists** — `hausfold.co`'s
      `content/docs/haus/leaving.mdx` is live (it was
      `web/src/content/docs/guides/leaving.mdx` when this was ticked; the docs
      tree moved into the site repo on 2026-08-14). Re-read it as a stranger before the invites go out; "how do I
      undo this" is the first question a cautious tester asks.
- [x] ~~**perch Phase 0 (FSL relicense) is done**~~ — **reversed 2026-08-15,
      and there is no Phase 0 any more.** perch#26 relicensed MIT →
      FSL-1.1-ALv2 and perch#27 landed the offline-Ed25519 layer with a 2-tile
      free tier; it stayed inert (the production key was never minted) and
      perch went back to free + MIT, retroactively over `v2026.08.04` through
      `v2026.08.14-1`. **Testers install an MIT perch, and no licence question
      reaches them at all** — which is a simpler answer than this box was
      after. The paid plan this gated is gone with `notes/perch-monetization.md`.
      **The finding underneath it survives, and is the reason to keep the box:**
      hausfold.co still said *"All of haus is MIT-licensed"* while the repo
      said otherwise, four days after org-profile#14 corrected the identical
      claim in the GitHub footer — because the docs site was never grepped.
      **Grep for the claim, not for the file.**
- [x] ✅ **The trill question is settled — it was decided by removal, not by a
      note.** ("trill" here, and everywhere else in this file, is the **archived
      Messages client**, `hausfold/messages` since 2026-08-08. The notification
      compositor took the name that day and the rice now declares a
      metadata-only `haus.roster.trill` float rule for it — a different app, and
      no tester question of its own is answered here.)
      rice#212 made it opt-in, rice#213 deleted the module and the flake
      input, homebrew-tap#10/#11 deprecated the cask, workshop#204 and
      org-profile#14 took it out of the family lists, and the repo is
      **archived on GitHub**. So no tester is handed it at all, which is a
      better answer than the "no longer maintained, and why" note this box
      asked for.
      The sentence worth keeping, from rice#213: *a supported option nobody
      should turn on is a lie in the option reference.*
- [x] ~~**Carry-over, unresolved:** an earlier session flagged a "`.bak`
      discrepancy" with no detail.~~ **Closed 2026-08-20 — the sentence it was
      about no longer exists.** The `.bak` claim lived at
      `web/src/content/docs/guides/the-bar.mdx:128`; that whole tree was
      replaced by `hausfold.co/content/docs/` on 2026-08-14, and `.bak` appears
      nowhere in the current docs. Nothing to confirm and nothing to fix.
- [x] **Reshoot the desktop hero** — **shot and staged 2026-08-26**, replacing
      the 2026-07-09 frame. It was never a placeholder: that file matched the
      scene exactly and was retired for carrying the **nebelhaus** wordmark and
      org, a username, an 8-day uptime and a 36% battery — wrong under
      `AGENTS.md`'s naming rules rather than merely dense, which is why it was
      reshot and not cropped.

      **The old frame could not have been reproduced anyway, and that is the
      finding worth keeping.** zellij left `haus` on 2026-08-19
      (`haus/notes/zellij-exit.md`), taking the tab bar, the `SPIRAL` badge and
      the `Ctrl + <g> LOCK` hint strip that gave the old shot's left window all
      of its structure. A Ghostty window **is** a pane now, tiled by the
      `windows` room, so a bare shell reads as an empty rectangle. What
      replaces that chrome is a TUI: the shipped frame runs lazygit over an
      unstaged `haus.focus.scenes` tree in `~/.config/nix`, which turns the
      largest panel in the shot into the option surface itself. Two lessons
      priced on the way: lazygit's **Log/Commits** panel renders
      `Author: … <email>` and is disqualifying for a public asset — its
      **Files** panel is not; and a ~34-column pane wraps anything past ~40
      characters, so the config being shown off has to be written short.

      The other half is Zen on `github.com/hausfold`, grey and pink because
      `github` is in `haus.zen.userStyles` — the one element that proves the
      palette crosses the terminal-to-GUI boundary. Pounce sits mid-search on
      **Spawn Agent**, a command rather than an app, which is the row that
      advertises the lane workflow.

      **The staging list in `SHOTLIST.md` is a trap now, and was not run.**
      `haus set bar.bottom.enable false` does **not** remove the eight pills
      that live down there: `modules/bar/default.nix:1254` wraps `bottomGroup`
      in `lib.optionals cfg.bottom.enable`, so `bottomItems` goes empty and the
      menu-bar filter — `name: elem name liveWidgets && !(elem name
      bottomItems)` — lets every one of them back onto the top bar. Turning the
      second bar off *collapses two bars into one crowded one*. To actually
      thin the frame you switch the pills off in `haus.bar.items` as well:

      ```sh
      haus set bar.bottom.enable false \
        bar.items.aiUsage false bar.items.elgato false \
        bar.items.cpu false bar.items.memory false \
        bar.items.calendar false bar.items.caffeinate false
      # …shoot…
      haus reset bar.bottom.enable bar.items.aiUsage bar.items.elgato \
        bar.items.cpu bar.items.memory bar.items.calendar bar.items.caffeinate
      ```

      ⚠️ **Two things in the frame are this machine, not the desktop.**
      `haus.zen.userStyles` defaults to `[ ]` and `haus.bar.bottom.enable` to
      `false`, and `haus`'s `desktops/hacker.nix` sets neither — so a fresh
      install has an unthemed browser and one bar, not a themed GitHub and two.
      The launch-post copy has to say so, or the first reply under it is "I
      installed it and it doesn't look like that."

      **The shipped frame ran none of it** — both bars are on, the battery
      reads 73% and the clock is not 9:41. A deliberate call: the shot is for
      launch posts, and a desktop visibly doing work sells better than a
      staged one. The judgement call this box used to leave open — whether the
      `agents` and `github` pills stay in shot — is answered the same way, in
      the affirmative. `haus reset` remains the undo, because it inherits the
      host file's values instead of pinning the old ones into the writable
      overlay.

## 1. The missions, and what each one is for

One tester, one mission. Never "have a look around" — an unscoped tester reports
taste, and taste isn't what this round buys.

| # | Who | Mission | Proves |
|---|---|---|---|
| 1 | Existing Nix/nix-darwin user | Whole house on a secondary Mac | The bootstrap survives an opinionated existing setup |
| 2 | Existing Nix user | Whole house, then migrate the host file to a second machine | Reproducibility is real, not local |
| 3 | Technical Mac user, no Nix | Whole house, cold | The hard one. Every assumption you can't see |
| 4 | Technical Mac user, no Nix | Whole house, then **deliberately break it and roll back** | `haus rollback` / `haus doctor` under a stranger's hands |
| 5 | Nix user who doesn't want the whole desktop | Import **only `windows`** into their own config | The "steal one room" claim |
| 6 | Launcher/utility person | pounce via Homebrew, then author one command | The standalone door, and the funnel's core promise |
| 7 | Theme person | Install three **existing** nebelung ports into tools they already use | The taste door. ⚠️ Not *authoring* three ports — `docs/install.md` and `docs/ports.md` are written for a stranger, but how to add a NEW port lives only in nebelung's `AGENTS.md`, which assumes an agent with a checkout. Authoring is a different mission and it needs a contributor doc first |
| 8 | Any dev with a git repo | holt in a repo that isn't yours | The only door with no macOS prerequisite |
| 9 | **Non-technical** Mac user | perch from the release zip — no Homebrew, no Terminal | The only door with no command line at all, and [`go-to-market.md`](./go-to-market.md) door 5, which had no tester |

Missions 6–9 need no Mac rebuild, and 6–8 ask for no trust either, so they're the
easiest to recruit and the fastest to report. **9 does ask for trust** — dragging
an unvetted zip into Applications is precisely the ask — which is why its report
is the most valuable of the four and the one to read first. Start there if recruiting stalls — a completed small
mission is worth more than a promised big one.

**Nine missions, still eight testers.** Row 9 was added 2026-08-26 because a
volunteer turned up for it and because perch is a launch door with nobody walking
through it. The target in the header didn't move: 8 testers, 4 whole-house
installs — and **rows 1–4 _are_ that target**, one for one, so none of them is
ever the row to drop. If only eight people show up, the odd one out has to come
out of the doors (5–9), and which door goes unrun is a launch-order question for
[`go-to-market.md`](./go-to-market.md), not a testing one. Don't answer it here.

**Placed so far** — two of nine, as of 2026-08-26.

⚠️ **The names live in [`hausfold/ops`](https://github.com/hausfold/ops), never
in this file.** The workshop is public. Someone who agreed to try something for
you did not agree to be described, by name, in a repo strangers read — and
"semi-technical" or "non-technical" is a characterisation, not a fact about
software. Keep the roster in `ops`; keep here only what changes the plan:

| # | What placing it changed |
|---|---|
| 6 | Placed — with a tester who has already run standalone pounce for months. ⚠️ **The install half of this mission is spent**: nobody can re-walk a door they're already through. Scope the ask to *authoring one command*, the half §1 calls the funnel's core promise, and get the install half retroactively — how did you install it, did anything fight you, did you know it was a formula and not a cask. This moves a §4 gate; see the note there |
| 9 | Placed, and the reason row 9 exists at all — the volunteer wants perch for its own sake rather than as a favour, which makes him worth more than a recruited tester: he has a reason to still have it open a month later, and that's the only way you learn whether it survives past the novelty |

Seven slots open. Of the three §5 wants placed first — 3, 6, 8 — one is done.

**Ask for a desktop.** Anyone completing missions 1–5 has, by definition, a host
file. Ask them for the `haus.*` part of it as a shareable desktop — the format is
[Creating a desktop](https://hausfold.co/docs/haus/desktops/creating), which is
where the old `web/` guide's URL now 301s, and
[Sharing one](https://hausfold.co/docs/haus/desktops/sharing) is the publishing
half. That collection is the seed
inventory for the gallery in [`go-to-market.md` §5](./go-to-market.md#5-the-gallery--marketplace-question--answered) —
it is the single most valuable byproduct of this round and it evaporates if you
don't ask at the time.

## 2. The invite

Send individually. Never a broadcast — a broadcast gets promises, a personal ask
gets reports.

> Hey — I'm doing a quiet pre-launch inspection of haus, an opinionated,
> reproducible macOS setup built around Nix, native tools, and a slightly
> unreasonable amount of grey.
>
> I'm looking for a few people to complete one focused test without me guiding
> them live. Depending on your setup that might be installing the whole
> environment on a secondary Mac, trying the launcher through Homebrew, or
> importing just the tiling module.
>
> The useful part isn't whether you like it. It's where the instructions stop
> making sense.
>
> 30–90 minutes, one narrow mission, short report form. Interested?

**Every mission swaps the middle paragraph.** Keep the opening, the *useful part
isn't whether you like it* line and the closing ask — that frame is what makes it
read as a personal request. Replace only the middle. The generic middle above
describes a whole-house install and oversells a 30-minute one, so nobody should
receive it verbatim.

**1–5 are rebuilds**: they cost a real afternoon on a real Mac, so the paragraph
has to say what it costs and stay honest about the blast radius. **6–9 are
doors**: the whole of the mission fits in a sentence, the first command rides
along in the message, and none of them needs anything of mine installed first.

| # | The paragraph, and the command that goes with it |
|---|---|
| **1** | *You already run nix-darwin, which is exactly why I want you. haus is a layer of options on top of it, not a replacement for it, and I have never once watched it land on a config that already had opinions. Secondary Mac, please — not the one you work on.* → `curl -fsSL https://hausfold.co/hacker.sh \| bash` |
| **2** | *Two Macs, one host file. Install it on the first, then carry the file to the second and tell me whether you got the same desktop or merely a similar one. Reproducible-off-my-hardware is the claim I can't test alone, and you're the kind of person who can call the bluff.* → same one-liner, then [Creating a desktop](https://hausfold.co/docs/haus/desktops/creating) |
| **3** | *You've never touched Nix and that is the entire point. One command, a Mac you can afford to reshape, and a note every single time you had to guess what something meant. I won't be there while you do it — that's deliberate, and the notes are the whole deliverable.* → `curl -fsSL https://hausfold.co/hacker.sh \| bash` |
| **4** | *Install it, then break it on purpose — bad option, wrong value, whatever looks most fragile to you — and get yourself back out with `haus rollback`. What I need to know is whether the undo works in hands that didn't write it. Breaking it is the mission, not an accident.* → `curl -fsSL https://hausfold.co/hacker.sh \| bash`, then `haus rollback` and `haus doctor` |
| **5** | *Don't install my desktop. Take one room out of it — `windows`, the tiling — into the config you already have, and tell me whether "steal one room" is a real claim or a slogan I should stop making.* → [Creating a desktop](https://hausfold.co/docs/haus/desktops/creating) |
| **6** | *pounce is a ⌘Space launcher for macOS — native, no Electron. Install it, live with it for a day, then write it one command of your own. What I need is where the command-authoring docs stop making sense.* → `brew tap hausfold/tap && brew install pounce && brew services start pounce` |
| **7** | *nebelung is a silver-grey Catppuccin flavour with 54 ports. Pick three tools you actually use, install its port for each, and tell me which of the three fought you.* → [ports table](https://github.com/hausfold/nebelung/blob/main/docs/ports.md), [installing](https://github.com/hausfold/nebelung/blob/main/docs/install.md) |
| **8** | *holt manages git worktrees for parallel coding agents — one branch, one checkout, one pane, from create to reaped. Use it on a repo of your own that has nothing to do with me. Linux is fine; there's no Mac in this one.* → `go install github.com/hausfold/holt/cmd/holt@latest`, or `nix run github:hausfold/holt` |
| **9** | *perch is a little shelf that lives in the notch at the top of your screen — you drag files onto it, they wait there, you drag them out somewhere else. There's no Terminal in this one: download the zip, unzip it, drag it into Applications. Tell me every moment you weren't sure what to click, including the macOS warnings — especially those.* → [latest release](https://github.com/hausfold/perch/releases/latest), the `perch-…-macos.zip` file |

⚠️ **Mission 9 gets the zip, not the cask.** perch ships both, and
`brew tap hausfold/tap && brew install --cask perch` is the faster instruction for anyone who already has
Homebrew — which is exactly why it's the wrong one here. A tester who opens a
terminal isn't testing the door that a non-technical Mac user actually walks
through, and that door has never been walked by anyone but you.

Two rules for yourself: **don't watch, and don't rescue.** A tester you talk
through the install teaches you nothing about the install. Answer after they
report, not during.

## 3. The report form

Five questions. Longer forms come back empty.

1. Where did you stop, get confused, or have to guess? (verbatim, please)
2. What did you expect to happen that didn't?
3. Anything that felt unsafe, or that you didn't want to approve?
4. How long did it actually take, wall clock?
5. Screenshot of the end state — good or bad.

Severity, applied by you not them:

| | |
|---|---|
| **S1** | Blocked, couldn't finish, or lost/broke something of theirs |
| **S2** | Finished but had to guess, ask, or work around |
| **S3** | Confusing wording, missing doc, cosmetic surprise |

S1s are launch blockers. S2s are the docs backlog. S3s go in a list and get done
in one sweep.

## 4. Exit gates — all must be true before anything goes public

- [ ] 4 whole-house installs completed by people who don't own your machine
- [ ] pounce installed cleanly by at least one non-Nix user — ⚠️ **mission 6's
      tester can't clear this**, he installed it months ago (§1). A retrospective
      account clears it only if he can still name the command he ran; otherwise
      this gate needs a second, cold pounce tester and mission 6 keeps only the
      authoring half
- [ ] holt used successfully in a repo that isn't in this family
- [ ] **perch installed by someone who never opened a Terminal** — from the
      release zip, not the cask (§1 row 9). It is door 5 in `go-to-market.md`;
      without this the launch has no evidence for a whole door
- [ ] rollback exercised by someone other than you, successfully
- [ ] zero open S1s
- [ ] the top five S2 questions answered in the docs, not in DMs
- [ ] no ambiguous security or permission prompts left unexplained
- [ ] the uninstall path followed end to end by at least one tester
- [ ] **three pieces of public proof from other people** — a screenshot, a
      quote, a contributed rice, a pounce command. Not testimonials; evidence.

## 5. Two weeks

⚠️ **This block never ran.** It was written for a 2026-08-05 start and no invite
has been sent as of 2026-08-25 — the calendar below is a *shape* (clear §0, send
all eight at once, then a hard no-help week, then S1s, then the gates), not a
live schedule. Re-date it from the day the first invite actually goes out. What
slid it is visible in §0: every box there closed by something being deleted or
reversed rather than by the round starting.

| Days | |
|---|---|
| **Aug 5–6** | Clear §0. Perch Phase 0 lands, trill decided. *(Phase 0 was the FSL relicense — landed, then reversed on 2026-08-15; see §0.)* |
| **Aug 7–8** | Send 8 invites. Aim to place missions 3, 6, 8 first — the cold Mac user, the launcher, the dev. |
| **Aug 9–13** | Testers run. You do not help. Triage each report same-day into S1/S2/S3. |
| **Aug 14–16** | Fix every S1. Write the docs for the top five S2s. |
| **Aug 17** | Re-test each S1 with the tester who found it. |
| **Aug 18** | Walk the exit gates. Anything unticked either gets fixed or explicitly waived in writing. |

## 6. What comes out of it

Beyond the fixes — these are the launch inputs that only exist if you collect
them now:

- the seed rices (§1)
- the first pounce commands, for "things people taught the cat"
- three pieces of public proof, for the launch posts
- the real install wall-clock time, for the honest timelapse
- a list of the five questions strangers actually ask, which becomes the FAQ and
  half your Show HN comment replies

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
- [ ] **Capture the rice hero shot** (`haus/assets/hero.png`). Not a
      blocker for testers, but it's the asset every later phase waits on, and
      it's a single good desktop away from done.

## 1. The eight, and what each one is for

One tester, one mission. Never "have a look around" — an unscoped tester reports
taste, and taste isn't what this round buys.

| # | Who | Mission | Proves |
|---|---|---|---|
| 1 | Existing Nix/nix-darwin user | Whole house on a secondary Mac | The bootstrap survives an opinionated existing setup |
| 2 | Existing Nix user | Whole house, then migrate the host file to a second machine | Reproducibility is real, not local |
| 3 | Technical Mac user, no Nix | Whole house, cold | The hard one. Every assumption you can't see |
| 4 | Technical Mac user, no Nix | Whole house, then **deliberately break it and roll back** | `haus rollback` / `haus doctor` under a stranger's hands |
| 5 | Mac user, no Nix | Import **only `windows`** into their own config | The "steal one room" claim |
| 6 | Launcher/utility person | pounce via Homebrew, then author one command | The standalone door, and the funnel's core promise |
| 7 | Theme person | Three nebelung ports | The taste door, and port instructions |
| 8 | Any dev with a git repo | holt in a repo that isn't yours | The only door with no macOS prerequisite |

Missions 6–8 need no Mac rebuild and no trust, so they're the easiest to recruit
and the fastest to report. Start there if recruiting stalls — a completed small
mission is worth more than a promised big one.

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
- [ ] pounce installed cleanly by at least one non-Nix user
- [ ] holt used successfully in a repo that isn't in this family
- [ ] rollback exercised by someone other than you, successfully
- [ ] zero open S1s
- [ ] the top five S2 questions answered in the docs, not in DMs
- [ ] no ambiguous security or permission prompts left unexplained
- [ ] the uninstall path followed end to end by at least one tester
- [ ] **three pieces of public proof from other people** — a screenshot, a
      quote, a contributed rice, a pounce command. Not testimonials; evidence.

## 5. Two weeks

Dates assume a 2026-08-05 start; slide the whole block if it slips.

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

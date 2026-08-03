# Passoff prompt — Trill aggregation foundation (Beeper client refactor, phase 1)

*Paste the whole "Prompt" section below into a fresh Claude session in a **trill**
worktree. It is written to be self-contained: it re-derives the ground truth so the
session doesn't have to trust a stale summary, and it front-loads the traps that are
invisible until you've already broken something. Phases 2–5 of
`docs/beeper-client-refactor.md` get their own prompts later — see "Deliberately out
of scope".*

---

## Prompt

You're picking up `docs/beeper-client-refactor.md` in **`nebelhaus/trill`** — the
plan to turn Trill from a single-provider Messages client into an always-aggregated
one (native iMessage/SMS/RCS **plus** Beeper's non-iMessage networks, merged into one
inbox). Read that doc first; it's the spec, and it's short.

**This session implements section 1 of its task list only — the aggregation
foundation — plus an ADR recording the design.** No Beeper dependency, no network
code, no Keychain. Everything you build must be provable against `FixtureProvider`
with no permissions granted.

If you are in a workshop worktree rather than a trill one, make a trill child
worktree (`cd "$(wt child "$workshop_root/trill")"`) and work there.

### Why phase 1 first

Sections 2–4 of the doc (the Beeper REST adapter, product integration, writes) all
land on top of an abstraction that doesn't exist yet: Trill today is *structurally*
single-provider in four places, and every one of them has to move before a second
provider can exist at all. Doing phase 1 alone yields a PR that changes no user-visible
behavior, ships with the app still passing its whole suite in fixture mode, and makes
phase 2 a mostly-additive file drop. Doing them together yields a PR nobody can review.

### Ground truth — what the code actually looks like today

Verify these rather than trusting the list; they were read at commit `1c4e1df`.

**The provider seam.** `Trill/Providers/MessagesProvider.swift:3` — one protocol,
~15 requirements plus 8 defaulted extension methods (`sendDirect`,
`contactSuggestions`, `media`, `libraryItems`, `messages(ids:)`, `statSamples`,
`myMessages`, `exportMessages`, and the `messages(in:around:limit:)` fallback). Three
conformers: `FixtureProvider` (id `"fixture"`), `LiveIMessageProvider` (id
`"imessage"`), `PlatformIMessageProvider` (id `"platform-imessage"`, dormant).

**The repository holds exactly one.** `Trill/Repositories/MessagesRepository.swift:17`
— `private let provider: any MessagesProvider`. It logs, dedupes events, persists
cursors, and assembles the saved-messages library tab. It has no concept of a second
provider anywhere.

**The UI holds exactly one set of capabilities and one health.**
`Trill/Features/Inbox/InboxModel.swift:56` (`capabilities`), `:55` (`health`), fed
once per load at `:367–368` and handed wholesale to the composer at `:720`/`:724`.
`CapabilityGate.canSend` (`Trill/Domain/ProviderHealth.swift:81`) is the single gate.

**Provider selection is a two-case enum.** `InboxModel.swift:4` `ProviderMode`
(`.fixture` / `.messages`), constructed at `:286`, switched at `:439`, built at
`:354`. Persisted in `UserDefaults` under `"providerMode"`.

**Service is a closed enum.** `Trill/Domain/Models.swift:3` `MessageServiceKind`
(`iMessage`/`sms`/`rcs`/`unknown`, with `.togglable` excluding `.unknown`). It's a
field on both `Conversation` (`:40`) and `Message` (`:142`). Its display comes from
`Trill/DesignSystem/Components.swift:89` (`displayLabel`, `chipColor`, `ServiceChip`),
consumed at `InboxView.swift:921`/`:943`, `CommandPaletteView.swift:369`,
`ConversationView.swift:309`, `MenuBarInboxView.swift:190`.

**The service filter is a UserDefaults CSV.** `InboxModel.swift:169` — `hiddenServices`
is a `Set<MessageServiceKind>` persisted as a comma-joined rawValue string under the
key `"hiddenServices"`, loaded at `:273`, applied at `:496`, driven by the menu at
`InboxView.swift:529`. **There is no database row for it.** (The task doc's "migrate
persisted filters" reads like a schema migration; it isn't one.)

**Identity is already provider-qualified.** `Trill/Domain/Identifiers.swift:43`/`:72`
— `ConversationID`/`MessageID` are `(ProviderID, externalGUID)` pairs whose
`persistenceKey` is a base64url encoding of both. That key is the primary key of
*every* overlay table in `Trill/Persistence/AppDatabase.swift` (pins, drafts, read
marks, folders, folder members, VIP, archive, mute, snooze, saved messages) and of the
persisted tab list. Schema is at version 13 (`AppDatabase.swift:19`).

**Cursors, as they stand.** `provider_cursors` is keyed by `provider_id`
(migration 3, `AppDatabase.swift:537`); the repository saves into it at
`MessagesRepository.swift:136` and reads at `:124`. Page cursors are per-provider
private strings: Fixture uses integer offsets (`FixtureProvider.swift:213`, which
*throws* `MessagesProviderError.invalidCursor` on anything non-integer), Live uses a
min-rowID for message paging (`LiveIMessageProvider.swift:77`) and **doesn't paginate
conversations or search at all** — both return `nextCursor: nil` (`:63`, `:176`) and
`InboxModel` just asks for 100 conversations in one shot.

**What does not exist yet.** No Keychain code anywhere (`Trill/Platform/` has only
`Logging/` and `Permissions/`). `URLSession` appears only in `UpdateCheck.swift:295`
and `LinkPreviewLoader.swift`. Tests are XCTest under `TrillTests/`, fixture-only by
policy (`docs/testing.md`).

### Name collision — read this before you name a single type

`Trill/Providers/PlatformIMessageProvider/` **is** Beeper code: the
`beeper/platform-imessage` Swift package, pinned and compiled but never instantiated,
gated on the vetting pass in `docs/architecture-decisions/0001-messages-provider.md`.
It is a *local iMessage* library that opens `chat.db` **read-write**.

The `BeeperProvider` this refactor introduces is an entirely different thing: an HTTP
client against a local-or-remote headless **Beeper Server**'s REST Client API, serving
*non*-iMessage networks, touching no database at all.

Do not merge them, rename one into the other, or let a reader think they're related
beyond a shared vendor. Say which one you mean, every time.

### What to build

Four things, in one PR.

**1. Provider-scoped capabilities and health.** Capability and health lookup must
become answerable *per conversation* (equivalently: per owning provider), because with
two providers the composer's send gate depends on which thread is open. Keep the
whole-app aggregate too — `InboxModel` needs something to render in the health screen.
Pick a shape (`capabilities(for: ConversationID)` on the protocol with a defaulted
whole-provider fallback is the obvious one) and justify it in the ADR.

**2. Dynamic service/account identity.** Replace the closed `MessageServiceKind` with
a stable string-backed identity carrying display metadata — enough for "WhatsApp",
"Signal", and *two different Signal accounts* to be distinct filterable things, which
the enum structurally cannot express. Keep iMessage/SMS/RCS as well-known constants so
`ServiceChip`'s colors and labels survive unchanged. Migrate the `hiddenServices`
UserDefaults CSV in place, on read, without losing a user's existing filter state.

**3. `CompositeMessagesProvider`.** Conforms to `MessagesProvider`, owns an ordered
list of children, and implements: routing by `ConversationID.provider` /
`MessageID.provider` for every per-conversation call; timestamp-merged conversation and
search paging behind one opaque cursor; merged event streams with independent
per-child cursors and reconnect policy; fan-out-and-merge for the global reads
(`libraryItems`, `myMessages`, `contactSuggestions`, `messages(ids:)`); and
fail-soft partial results throughout.

**4. Tests, in `TrillTests/`.** At minimum: deterministic merged paging across two
fixture children with interleaved timestamps; correct routing (a call for provider A's
conversation never reaches provider B); merged search ordering; merged event stream
with dedup; composite cursor round-trip *and* graceful handling of a cursor naming a
child that's since gone; partial failure (one child throws, the other's results still
arrive); and the `hiddenServices` migration.

Plus `docs/architecture-decisions/0003-*.md` recording the decisions, and the doc
updates listed at the bottom.

### Landmines

These are the ones that are silent, not loud. Every one of them compiles.

**Never re-qualify an ID.** The composite must pass child `ConversationID`s and
`MessageID`s through *verbatim*. Its own `ProviderID` exists for protocol conformance
and must never appear inside an ID that reaches the domain models. If a conversation
that was `("imessage", guid)` starts arriving as `("composite", …)`, its
`persistenceKey` changes, and every pin, draft, folder membership, VIP mark, snooze,
archive flag, saved message, read mark, and restored tab for that thread is orphaned
— with no error, just silently missing state on next launch.

**Don't collapse event cursors.** `provider_cursors` is one row per `provider_id`. If
the composite saves a merged cursor under its own id, both children resume from the
wrong place after a relaunch — replaying or skipping messages, and the skip is the
one you won't notice. Persist per child. Either push cursor persistence down into the
composite or teach `MessagesRepository.eventStream` (`:123–147`) about multiple
cursors; decide which, and say why in the ADR.

**A Beeper outage must not blank the inbox.** `InboxModel.load` (`:370–382`) switches
on `health.messagesDatabase.reason` and turns `.permissionMissing` /
`.unsupportedSchema` / `.providerFailure` / `.databaseMissing` into a full-screen
error state that replaces the conversation list. That's correct when the *native*
provider can't read `chat.db`. It is catastrophic when a remote Beeper Server is
merely unreachable — the doc's stated requirement is that a Beeper outage must not
hide native Messages. So aggregation is not a min() over health dimensions: decide
explicitly which child's failures are blocking (native) and which degrade to a
non-blocking banner plus a degraded health row (Beeper), and encode that rather than
letting it fall out of a fold.

**Merged paging needs over-fetch, not interleaving.** Taking N/2 from each child and
zipping loses conversations whenever the children's activity rates differ. Fetch at
least the full limit from each child, merge by `lastActivity`, and cut the page at the
**earliest of the children's last-returned timestamps** — past that point you can't
know whether an unfetched item from the other child belongs first. Carry the unemitted
remainder plus each child's native cursor in your composite cursor. Also tolerate a
child that simply never paginates: `LiveIMessageProvider.conversations` returns
`nextCursor: nil` always.

**Make the composite cursor opaque, versioned, and forgiving.** It encodes a map of
child-provider → child cursor. Children can be added, removed, or disabled between two
calls. An unknown or missing child in a decoded cursor should restart *that child*, not
throw the page away — note that `FixtureProvider.offset` throws `.invalidCursor` on
anything it doesn't recognize, so a naive pass-through of the wrong child's cursor
becomes a hard error.

**Fail soft, and decide the reporting shape once.** One child throwing must not fail
the merged call. But a partial page that looks identical to a complete one is how "half
my messages vanished" bugs get shipped. Pick one mechanism — a `failures:
[ProviderID: Error]` sidecar on the page types is the least invasive — and use it
everywhere, rather than inventing a different convention per method.

**Fixture mode stays pure.** The dev default, the entire test suite, and every
permission-free workflow run on `.fixture`. It must remain a single provider with no
composite wrapper, no network, no Keychain access, and no Beeper code path reachable
from it.

**Migration discipline, if you touch the DB at all.** Phase 1 most likely needs no new
table — if that holds, say so explicitly in the PR. If you do add one, it's migration
14, and you must also bump `currentSchemaVersion` (`AppDatabase.swift:19`) and the
`AppDatabaseTests` assertion. Parallel branches collide on migration numbers; the
second PR to land renumbers.

**The house rules that don't bend.** Trill's own code never writes `chat.db` (nothing
in phase 1 goes near it — keep it that way). Provider DTOs never escape `Providers/`
— that's `ARCHITECTURE.md §20`, an acceptance criterion, not a style note. No real
message data in fixtures, tests, logs, or the PR body; `OSLog` carries counts and
durations, never content.

### Deliberately out of scope

Do not start these; if phase 1 turns out to genuinely need a piece of one, note it in
the PR rather than pulling it in.

- Any Beeper REST client, DTO, Keychain entry, or endpoint setting (doc §2).
- Connection settings UI, onboarding, or reconnect UI (doc §3).
- Sends, reactions, mark-read, WebSocket events (doc §4).
- The ship gate (doc §5).

### Two things to confirm before you go far

1. **Provider-mode naming.** The doc says the dropdown stays "fixtures vs. live". Once
   live *is* the composite, the current label "Messages" is misleading. That's
   user-visible — propose a rename in the PR, don't just make one.
2. **Whether the repository should stay single-provider-shaped.** The cheap, correct
   answer is yes: a `CompositeMessagesProvider` conforming to `MessagesProvider` means
   `MessagesRepository`, `ConversationModel`, and most of `InboxModel` need no change
   at all, and the seam stays where it already is. If you find a reason to give the
   repository real multi-provider awareness instead, that's a legitimate call — but
   make it deliberately, in the ADR, with the reason.

### Verify

```sh
xcodebuild -skipMacroValidation -project Trill.xcodeproj -scheme Trill \
  -configuration Debug -destination 'platform=macOS' \
  -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO test
```

Then run the app (⌘R, fixture mode) and confirm the sidebar, service filter menu,
chips, tabs, and composer gating are **unchanged** — phase 1 is a refactor; a
user-visible difference in fixture mode is a bug. Nothing here requires Full Disk
Access, a signed-in Messages account, or a Beeper Server. Trill is an Xcode project,
not a Nix build, so `bench try` is not the verification path — `xcodebuild test` is.

### Docs to update in the same PR

- `docs/architecture-decisions/0003-*.md` — new ADR, the decisions above.
- `docs/beeper-client-refactor.md` — tick section 1, and fix two things while you're
  in there: "migrate persisted filters" is a `UserDefaults` CSV migration, not a
  schema one; and the doc is currently **orphaned** — nothing in `ARCHITECTURE.md`,
  `README.md`, or `docs/ideas.md` links to it.
- `ARCHITECTURE.md` — add the composite to §5/§6 and a roadmap entry in §22. Also
  reconcile the conflict this refactor creates: §6.4 and §11 currently describe
  **BlueBubbles** as the future second provider and the relay story, which Beeper now
  displaces. Don't leave two competing second-provider plans in one document.
- `docs/ideas.md` — a row for the aggregation work with its status.
- `docs/testing.md` — the new composite conformance tests.

### Workflow

Commit on your `worktree-*` branch, push, and open a PR against `main` with a **What
/ Why / Verify / Watch-out** body — you have standing permission for all three, no
need to ask. Do not merge it, and don't run `bench try switch` from a worktree. Report
the PR link when you're done.

---

## Notes for me (not part of the prompt)

Two questions I'd have liked answered before writing this; the prompt assumes the
first option in each:

- **Scope** — assumed phase 1 + ADR only. Phases 1+2 together, or a phase-per-PR
  marathon, would need a different prompt.
- **Beeper reachability** — irrelevant for phase 1 (nothing here touches a server),
  but phase 2's prompt has to say whether the agent can hit a live headless Server to
  capture contract fixtures, or must write them from the spec.

Also worth knowing: the spike result in the task doc (dated 2026-07-30) is what kills
the simpler design — headless Beeper exposes no iMessage bridge (`404 Bridge not
found`), so the native provider can't be retired and aggregation is mandatory rather
than optional. That's the load-bearing fact behind the whole refactor.

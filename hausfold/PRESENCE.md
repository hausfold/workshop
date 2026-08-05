# hausfold — name & channel register

Every account, handle and namespace claimed under the **hausfold** name, in one
place, so a launch never stalls on "wait, do we have a TikTok?" and nobody
re-registers something we already hold.

The site itself is still [a placeholder](./README.md) — this file exists ahead of
it, because names are claimed defensively long before there's anything to post.

**What hausfold is, decided 2026-08-04: the umbrella — the commercial identity
behind the products, not a product brand of its own.** nebelhaus is what
customers love and where support lives; hausfold is the seller on a receipt,
the name on terms and refunds, the press contact, and the home for anything
later that isn't macOS ricing. It is explicitly **not** the nebelhaus rice
gallery — that belongs on nebelhaus.com, one domain away from `haus rebuild`.
The reasoning and its consequences are
[`notes/go-to-market.md` §6](../notes/go-to-market.md).

**Status of this file:** handles were recorded from memory on 2026-08-04 and are
**not yet verified against the live platforms**. Treat the Handle column as "what
we believe we took" until someone walks the list and ticks it off. Anything marked
`—` was claimed but the exact handle wasn't written down at the time.

## The register

| Channel | Handle / namespace | Verified | Notes |
|---|---|---|---|
| **Domain** | `hausfold.co` (+ `www.`) | ✅ live | Cloudflare Worker, placeholder page. `.com` **not** held. |
| **Email** | `*@hausfold.co` | ✅ live | Catch-all on the zone — any local part works, so per-channel addresses (`press@`, `hi@`, `noreply@`) cost nothing. Use a distinct one per signup; it's free spam attribution. |
| **Bluesky** | `hausfold.co` | ✅ | Domain-as-handle, proven by a DNS TXT record on the zone (`_atproto`). **Don't delete that record** — the handle reverts to a `*.bsky.social` one if the TXT ever goes. |
| **Instagram** | `hausfold.co` | — | `hausfold` itself was unavailable, hence the `.co` suffix. Keep the suffix consistent wherever IG is linked. |
| **Tumblr** | `hausfold` | — | Clean name. |
| **LinkedIn** | `hausfold` | — | Recorded as "got hausfold"; confirm whether it's a *Company Page* or a personal/showcase page — they behave very differently for posting and for ads. |
| **Facebook** | Page created | — | Page exists; exact page name/vanity URL not recorded. Mostly held for the IG↔FB link (Meta Business Suite) rather than for posting. |
| **X / Twitter** | — | — | Claimed; handle not recorded. |
| **TikTok** | — | — | Claimed; handle not recorded. |
| **Pinterest** | — | — | Claimed; handle not recorded. |
| **YouTube** | — | — | Claimed; channel handle (`@…`) not recorded. |
| **Reddit** | — | — | Account (not a subreddit) unless noted otherwise — confirm which. |
| **Discord** | Server created | — | Server exists; no permanent invite / vanity URL recorded. |
| **Product Hunt** | — | — | Maker/account only; no product posted. |
| **GitHub** | org `hausfold` | — | Separate from the `nebelhaus` org — nothing in the nebelhaus family belongs here. |
| **npm** | scope `hausfold` | — | Org/scope reservation. Nothing published. |
| **PyPI** | account only | — | **Account, not a project name.** PyPI has no namespace reservation — a package name is only yours once you publish it, and squatting-by-placeholder is against policy. So `hausfold` on PyPI is *not* secured; if a Python package is ever the plan, publish a real `0.0.1` to hold it. |

## Which channel for what

Most of these channels are held, not fed — an umbrella identity has little to
announce in its own voice, and product news goes out under nebelhaus. Keep the
table for the day something *is* hausfold's to say, and pick by *what you're
announcing*, never by "post everywhere":

| If the thing is… | Reach for | Skip |
|---|---|---|
| A software launch | Product Hunt, X, Reddit (the one relevant sub, as a participant not a poster), GitHub | Pinterest, Tumblr |
| A developer tool / library | GitHub org, npm or PyPI, X, Reddit | Facebook, Pinterest, TikTok |
| Anything visual — objects, spaces, design, before/after | Instagram, Pinterest, TikTok | npm, PyPI, Product Hunt |
| A story, essay, or long build log | Tumblr, LinkedIn, Bluesky | TikTok, Pinterest |
| B2B / hiring / partnerships | LinkedIn | everything else |
| Ongoing community, support, early users | Discord | broadcast-only channels |
| A demo or walkthrough that needs motion | YouTube (canonical), TikTok (clip), Instagram (clip) | text-only channels |
| Just holding the name | do nothing — that's what the register is for | — |

Two rules that save the most grief:

- **A dormant account is fine; an abandoned-looking one is not.** Holding a
  handle with zero posts reads as "reserved". Three posts from a year ago reads
  as "dead project". If you're not going to sustain a channel, post nothing on
  it rather than a little.
- **One canonical home, everything else points at it.** Every bio links
  `hausfold.co`. That way a channel you stop feeding still routes people
  somewhere current.

## Gaps worth knowing

- **`hausfold.com` is not held.** If the brand matters commercially, this is the
  one real exposure in the list — a `.co` brand with someone else's `.com` is a
  permanent tax on every verbal mention.
- **PyPI is unsecured** (see the table note). Same is broadly true of any
  registry that only recognises published artifacts.
- **No trademark work** has been done; this register is name-squatting hygiene,
  not brand protection.

## Housekeeping

1. Walk the list, log into each, and fill every `—` with the real handle + tick
   the Verified column.
2. Record where the credentials live (password manager entry name) — not the
   credentials themselves, and never in this repo.
3. Note the signup email used per channel once the catch-all convention is set.
4. Re-check annually: platforms reclaim handles that never post, and a lapsed
   handle is the one thing this file can't warn you about.

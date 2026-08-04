// The site's information architecture, in one place.
//
// Two things render from it: Starlight's sidebar (astro.config.mjs) and
// /llms.txt (src/pages/llms.txt.ts), which is the same table of contents written
// for a model instead of a person. Keeping them on one array is what stops the
// machine-readable index from quietly falling behind the human one — a page
// added to the sidebar appears in llms.txt automatically, and llms.txt's build
// fails loudly if a docs page is missing from here entirely.
export const sidebar = [
  {
    label: 'Start here',
    items: [
      { label: 'What is nebelhaus?', slug: 'start/what-is-nebelhaus' },
      { label: 'Install', slug: 'start/install' },
      { label: 'First run', slug: 'start/first-run' },
      { label: 'The family', slug: 'start/the-family' },
    ],
  },
  {
    label: 'Guides',
    items: [
      { label: 'Making it yours', slug: 'guides/making-it-yours' },
      { label: 'Sharing a rice', slug: 'guides/sharing-a-rice' },
      { label: 'Changing it with an agent', slug: 'guides/ai-agent' },
      { label: 'Adding apps & tools', slug: 'guides/adding-apps' },
      { label: 'Window management (prowl)', slug: 'guides/window-management' },
      { label: 'The bar (sill)', slug: 'guides/the-bar' },
      { label: 'The shell (hearth)', slug: 'guides/the-shell' },
      { label: 'Coding agents (holt)', slug: 'guides/claude-agents' },
      { label: 'Touch ID for sudo (collar)', slug: 'guides/touch-id' },
      { label: 'Focus & DND (hush)', slug: 'guides/hush' },
      { label: 'Pounce — the launcher', slug: 'guides/pounce' },
      { label: 'Writing pounce commands', slug: 'guides/pounce-commands' },
      { label: 'Theming & accents (nebelung)', slug: 'guides/theming' },
      { label: 'Keeping in sync (haus)', slug: 'guides/staying-in-sync' },
      { label: 'Moving to a new Mac', slug: 'guides/new-mac' },
      { label: 'Leaving nebelhaus', slug: 'guides/leaving' },
    ],
  },
  {
    label: 'Reference',
    items: [
      { label: 'nebelhaus.* options', slug: 'reference/options' },
      { label: 'Keybindings cheatsheet', slug: 'reference/keybindings' },
      { label: 'Pounce config & CLI', slug: 'reference/pounce' },
      { label: 'The nebelung palette', slug: 'reference/palette' },
      { label: 'The haus CLI', slug: 'reference/haus' },
      { label: 'Troubleshooting', slug: 'reference/troubleshooting' },
    ],
  },
  {
    label: 'Under the hood',
    items: [
      { label: 'How the flakes fit together', slug: 'internals/flakes' },
      { label: 'Contributing & worktrees', slug: 'internals/contributing' },
    ],
  },
];

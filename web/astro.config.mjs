// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
  site: 'https://nebelhaus.com',
  // Inline ALL CSS into each page's <head> instead of linking one content-hashed
  // /_astro/index.<hash>.css. This is the durable cure for the recurring "no CSS
  // on iOS" bug: every deploy publishes a new hash and deletes the old file, so a
  // browser holding a stale cached HTML document (iOS WebKit / in-app WebViews
  // cache top-level HTML hard) points its one <link> at a since-deleted stylesheet
  // → 404 → a completely unstyled page. Inlining removes that single point of
  // failure entirely — the styles travel with the document, so even a stale HTML
  // page renders fully styled without fetching anything. public/_headers still
  // keeps HTML revalidating (belt-and-suspenders, and it freshens hashed JS), but
  // rendering no longer depends on any cache header being honored by any client.
  build: { inlineStylesheets: 'always' },
  // Custom landing page lives at src/pages/index.astro; Starlight owns the rest.
  integrations: [
    starlight({
      title: 'nebelhaus',
      description:
        'An opinionated macOS, raised in the fog — silver-grey, keyboard-first, reproducible, Nix-native. One curl and one flake raise the whole house.',
      logo: {
        light: './src/assets/logos/nebelhaus-mark-fill.png',
        dark: './src/assets/logos/nebelhaus-mark-fill.png',
        alt: 'nebelhaus',
        replacesTitle: false,
      },
      favicon: '/favicon.png',
      customCss: ['./src/styles/nebelung.css'],
      // Inline Expressive Code's code-block styles into each page instead of
      // linking one shared /_astro/ec.<ver>.css. Same durability reasoning as
      // build.inlineStylesheets above: that external sheet was the LAST
      // stylesheet a doc page fetched, and when it fails to load in a
      // memory-constrained iOS in-app WebView (Instagram/Facebook), code blocks
      // render as bare, unstyled monospace — no frame, no background, no syntax
      // colors. Inlining removes the last external stylesheet on doc pages, so
      // code-block styling travels with the document and can never 404. Delivery
      // only — the theme/rendering is unchanged.
      expressiveCode: { emitExternalStylesheet: false },
      social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/nebelhaus' },
      ],
      editLink: {
        baseUrl: 'https://github.com/nebelhaus/workshop/edit/main/web/',
      },
      head: [
        {
          tag: 'meta',
          attrs: { property: 'og:image', content: 'https://nebelhaus.com/social/og.png' },
        },
        {
          tag: 'meta',
          attrs: { name: 'twitter:card', content: 'summary_large_image' },
        },
        {
          tag: 'meta',
          attrs: { name: 'twitter:image', content: 'https://nebelhaus.com/social/og.png' },
        },
      ],
      sidebar: [
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
            { label: 'Changing it with an agent', slug: 'guides/ai-agent' },
            { label: 'Adding apps & tools', slug: 'guides/adding-apps' },
            { label: 'Window management (prowl)', slug: 'guides/window-management' },
            { label: 'The bar (sill)', slug: 'guides/the-bar' },
            { label: 'The shell (hearth)', slug: 'guides/the-shell' },
            { label: 'Claude Code agents (wt)', slug: 'guides/claude-agents' },
            { label: 'Touch ID for sudo (collar)', slug: 'guides/touch-id' },
            { label: 'Focus & DND (hush)', slug: 'guides/hush' },
            { label: 'Pounce — the launcher', slug: 'guides/pounce' },
            { label: 'Writing pounce commands', slug: 'guides/pounce-commands' },
            { label: 'Messages (trill)', slug: 'guides/trill' },
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
      ],
    }),
  ],
});

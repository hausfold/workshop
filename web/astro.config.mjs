// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import { sidebar } from './src/lib/sidebar.js';

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
  // The site presents the living family only. The archived Messages client
  // (called trill until 2026-08-08, now nebelhaus/messages) had four
  // `/trill*` redirects here pointing at its repo; they were removed with the
  // rest of its public surface. Consequence, accepted knowingly: the URL its
  // about box prints, and the two /guides/trill/ links frozen into its
  // archived README, now 404. Nothing else referenced them — the Homebrew
  // cask that also printed one was deleted the same day, and the app has no
  // install base. This is also what frees `/trill` for the notification
  // compositor's own docs page.
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
      // Shared with /llms.txt — see src/lib/sidebar.js.
      sidebar,
    }),
  ],
});

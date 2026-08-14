import { defineConfig } from 'vitest/config';

// The worker tests are plain Node unit tests — Node 22 gives us global Request,
// Response and URL, and the redirect map needs nothing else: it makes no network
// calls, so there is no `fetch` or `caches` left to stub.
export default defineConfig({
  test: {
    include: ['test/**/*.test.js'],
    environment: 'node',
  },
});

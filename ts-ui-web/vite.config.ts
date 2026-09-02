import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vitest/config'
import type { ProxyOptions } from 'vite'
import vue from '@vitejs/plugin-vue'

/**
 * Dev proxy targets.
 * Default: all traffic → gateway (Track B).
 * Polyglot-direct: set VITE_POLYGLOT_DIRECT=1 to hit news/office/voucher
 * without the Java gateway (Track B non-Java first).
 */
const gateway = process.env.VITE_GATEWAY_URL ?? 'http://localhost:18888'
const polyglotDirect = process.env.VITE_POLYGLOT_DIRECT === '1'
const newsUrl = process.env.VITE_NEWS_URL ?? 'http://localhost:12862'
const officeUrl = process.env.VITE_OFFICE_URL ?? 'http://localhost:16108'
const voucherUrl = process.env.VITE_VOUCHER_URL ?? 'http://localhost:16101'

const proxy: Record<string, ProxyOptions> = polyglotDirect
  ? {
      '/api/v1/newsservice': {
        target: newsUrl,
        changeOrigin: true,
        rewrite: () => '/',
      },
      '/news-service': {
        target: newsUrl,
        changeOrigin: true,
        rewrite: () => '/',
      },
      '/office': { target: officeUrl, changeOrigin: true },
      '/api/v1/ticketofficeservice': {
        target: officeUrl,
        changeOrigin: true,
        rewrite: (p: string) => p.replace(/^\/api\/v1\/ticketofficeservice/, '/office'),
      },
      '/getVoucher': { target: voucherUrl, changeOrigin: true },
      '/api/v1/voucherservice/voucher': {
        target: voucherUrl,
        changeOrigin: true,
        rewrite: () => '/getVoucher',
      },
      // Remaining /api (Java) still via gateway when available
      '/api': { target: gateway, changeOrigin: true },
    }
  : {
      '/api': { target: gateway, changeOrigin: true },
      '/getVoucher': { target: gateway, changeOrigin: true },
      '/office': { target: gateway, changeOrigin: true },
      '/news-service': { target: gateway, changeOrigin: true },
    }

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  server: {
    port: 5173,
    proxy,
  },
  test: {
    // Hermetic: don't rely on a local (gitignored) .env for mock mode — CI has none.
    env: {
      VITE_USE_MOCK: 'true',
    },
    environment: 'happy-dom',
    globals: true,
    include: ['src/**/*.{test,spec}.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      include: ['src/api/**', 'src/stores/**', 'src/utils/**', 'src/composables/**'],
    },
  },
})

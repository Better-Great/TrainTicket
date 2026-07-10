import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

const gateway = process.env.VITE_GATEWAY_URL ?? 'http://localhost:18888'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: gateway,
        changeOrigin: true,
      },
      '/getVoucher': { target: gateway, changeOrigin: true },
      '/office': { target: gateway, changeOrigin: true },
      '/news-service': { target: gateway, changeOrigin: true },
    },
  },
  test: {
    environment: 'happy-dom',
    globals: true,
    include: ['src/**/*.{test,spec}.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      include: ['src/api/**', 'src/stores/**', 'src/utils/**', 'src/composables/**'],
    },
  },
})

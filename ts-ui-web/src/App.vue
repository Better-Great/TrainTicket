<script setup lang="ts">
import { onMounted } from 'vue'
import { RouterView } from 'vue-router'
import AppHeader from '@/components/AppHeader.vue'
import AppFooter from '@/components/AppFooter.vue'
import { isMockMode } from '@/api/client'

onMounted(async () => {
  try {
    const res = await fetch('/ld-website.json')
    const data = await res.json()
    const script = document.createElement('script')
    script.type = 'application/ld+json'
    script.id = 'ld-website'
    script.textContent = JSON.stringify(data)
    document.getElementById('ld-website')?.remove()
    document.head.appendChild(script)
  } catch {
    // SEO JSON-LD is best-effort in local/mock
  }
})
</script>

<template>
  <a class="skip" href="#main">Skip to content</a>
  <AppHeader />
  <p v-if="isMockMode()" class="mock-banner" role="status">
    Local mock API — UI runs without Docker. Set
    <code>VITE_USE_MOCK=false</code> to hit the gateway.
  </p>
  <main id="main" class="main" tabindex="-1">
    <RouterView />
  </main>
  <AppFooter />
</template>

<style scoped>
.skip {
  position: absolute;
  left: 1rem;
  top: -3rem;
  z-index: 100;
  background: var(--signal);
  color: var(--signal-ink);
  padding: 0.5rem 0.85rem;
  font-weight: 700;
}

.skip:focus {
  top: 0.75rem;
}

.main {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.mock-banner {
  margin: 0;
  background: var(--ink);
  color: var(--mist);
  font-size: 0.8125rem;
  padding: 0.5rem 1.25rem;
  text-align: center;
}

.mock-banner code {
  color: var(--signal);
}
</style>

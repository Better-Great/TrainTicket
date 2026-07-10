<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const route = useRoute()
const router = useRouter()
const open = ref(false)

const displayName = computed(() =>
  auth.isAuthenticated ? auth.username : 'Guest',
)

const links = [
  { to: '/search', label: 'Search' },
  { to: '/advanced', label: 'Advanced' },
  { to: '/orders', label: 'Orders' },
  { to: '/collect', label: 'Collect' },
  { to: '/contacts', label: 'Passengers' },
  { to: '/wallet', label: 'Wallet' },
  { to: '/waitlist', label: 'Wait-list' },
  { to: '/offices', label: 'Offices' },
  { to: '/admin/login', label: 'Admin' },
]

function logout() {
  auth.logout()
  open.value = false
  router.push({ name: 'login' })
}

watch(
  () => route.fullPath,
  () => {
    open.value = false
  },
)
</script>

<template>
  <header class="header">
    <div class="inner">
      <RouterLink class="brand" to="/" aria-label="TrainTicket home">
        <span class="mark" aria-hidden="true" />
        <span class="name">TrainTicket</span>
      </RouterLink>

      <nav class="nav" aria-label="Primary">
        <RouterLink
          v-for="l in links"
          :key="l.to"
          :to="l.to"
          :class="{ active: route.path === l.to }"
        >
          {{ l.label }}
        </RouterLink>
      </nav>

      <div class="account">
        <span class="user">{{ displayName }}</span>
        <button v-if="auth.isAuthenticated" type="button" class="linkish" @click="logout">
          Sign out
        </button>
        <RouterLink v-else class="cta" to="/login">Sign in</RouterLink>
        <button
          type="button"
          class="menu-btn"
          :aria-expanded="open"
          aria-controls="mobile-nav"
          @click="open = !open"
        >
          {{ open ? 'Close' : 'Menu' }}
        </button>
      </div>
    </div>

    <nav
      id="mobile-nav"
      class="mobile"
      :class="{ open }"
      aria-label="Mobile"
      :hidden="!open"
    >
      <RouterLink v-for="l in links" :key="l.to" :to="l.to">{{ l.label }}</RouterLink>
      <RouterLink v-if="!auth.isAuthenticated" to="/login">Sign in</RouterLink>
      <button v-else type="button" @click="logout">Sign out</button>
    </nav>
  </header>
</template>

<style scoped>
.header {
  position: sticky;
  top: 0;
  z-index: 20;
  background: rgba(244, 247, 249, 0.92);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid var(--line);
}

.inner {
  max-width: var(--max);
  margin: 0 auto;
  min-height: var(--header-h);
  padding: 0 1.25rem;
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.brand {
  display: flex;
  align-items: center;
  gap: 0.65rem;
  flex-shrink: 0;
}

.mark {
  width: 1.35rem;
  height: 1.35rem;
  background: linear-gradient(135deg, var(--rail), var(--ink));
  box-shadow: inset 0 -2px 0 var(--signal);
}

.name {
  font-family: var(--font-display);
  font-weight: 800;
  font-size: 1.15rem;
  letter-spacing: -0.03em;
}

.nav {
  display: flex;
  gap: 1.1rem;
  flex: 1;
  flex-wrap: wrap;
}

.nav a {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--muted);
  padding: 0.25rem 0;
  border-bottom: 2px solid transparent;
}

.nav a:hover,
.nav a.active,
.nav a.router-link-active {
  color: var(--ink);
  border-bottom-color: var(--signal);
}

.account {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.user {
  font-size: 0.875rem;
  color: var(--muted);
}

.linkish,
.menu-btn {
  background: none;
  border: none;
  color: var(--rail);
  font-weight: 600;
  cursor: pointer;
  padding: 0;
}

.menu-btn {
  display: none;
  border: 1px solid var(--line);
  padding: 0.35rem 0.65rem;
  color: var(--ink);
}

.cta {
  background: var(--ink);
  color: var(--paper);
  padding: 0.45rem 0.9rem;
  font-weight: 700;
  font-size: 0.875rem;
}

.mobile {
  display: none;
  flex-direction: column;
  gap: 0.25rem;
  padding: 0.5rem 1.25rem 1rem;
  border-top: 1px solid var(--line);
  background: var(--paper);
}

.mobile a,
.mobile button {
  text-align: left;
  padding: 0.75rem 0;
  font-weight: 700;
  border: none;
  background: none;
  color: var(--ink);
  border-bottom: 1px solid var(--line);
  cursor: pointer;
  font-size: 1rem;
}

@media (max-width: 860px) {
  .nav {
    display: none;
  }

  .menu-btn {
    display: inline-flex;
  }

  .user {
    display: none;
  }

  .mobile.open {
    display: flex;
  }
}

@media (prefers-reduced-motion: reduce) {
  * {
    animation: none !important;
    transition: none !important;
  }
}
</style>

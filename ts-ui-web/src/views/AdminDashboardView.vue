<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import AdminNav from '@/components/AdminNav.vue'
import { getAdminDashboardMetrics } from '@/api/services'
import type { AdminDashboardMetrics } from '@/api/types'
import { useAdminStore } from '@/stores/admin'

const admin = useAdminStore()
const router = useRouter()

const metrics = ref<AdminDashboardMetrics | null>(null)
const loading = ref(false)
const error = ref('')

const cards: { key: keyof AdminDashboardMetrics; label: string; to: string }[] = [
  { key: 'orders', label: 'Orders', to: '/admin/orders' },
  { key: 'users', label: 'Users', to: '/admin/users' },
  { key: 'travels', label: 'Travels', to: '/admin/travels' },
  { key: 'stations', label: 'Stations', to: '/admin/stations' },
  { key: 'routes', label: 'Routes', to: '/admin/routes' },
  { key: 'trains', label: 'Trains', to: '/admin/trains' },
  { key: 'prices', label: 'Prices', to: '/admin/prices' },
  { key: 'configs', label: 'Config', to: '/admin/config' },
  { key: 'contacts', label: 'Contacts', to: '/admin/contacts' },
  { key: 'securityConfigs', label: 'Security', to: '/admin/security' },
  { key: 'waitList', label: 'Wait-list', to: '/waitlist' },
  { key: 'foodDeliveries', label: 'Food', to: '/food' },
]

async function refresh() {
  loading.value = true
  error.value = ''
  try {
    metrics.value = (await getAdminDashboardMetrics()).data
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load metrics'
  } finally {
    loading.value = false
  }
}

function logout() {
  admin.logout()
  router.push({ name: 'admin-login' })
}

onMounted(() => {
  void refresh()
})
</script>

<template>
  <section class="page">
    <header class="head">
      <div>
        <p class="eyebrow">Admin</p>
        <h1>Dashboard</h1>
        <p class="lede">
          Live counts across admin resources · signed in as
          <strong>{{ admin.username }}</strong>
        </p>
      </div>
      <div class="head-actions">
        <RouterLink class="link" to="/">Client app</RouterLink>
        <button type="button" class="ghost" @click="logout">Sign out</button>
        <button type="button" class="ghost" :disabled="loading" @click="refresh">
          {{ loading ? 'Refreshing…' : 'Refresh' }}
        </button>
      </div>
    </header>

    <AdminNav />

    <p v-if="error" class="error" role="alert">{{ error }}</p>

    <ul v-if="metrics" class="grid" aria-live="polite">
      <li v-for="c in cards" :key="c.key">
        <RouterLink :to="c.to" class="tile">
          <span class="num">{{ metrics[c.key] }}</span>
          <span class="label">{{ c.label }}</span>
        </RouterLink>
      </li>
    </ul>
    <p v-else-if="loading" class="empty">Loading metrics…</p>
  </section>
</template>

<style scoped>
.page {
  max-width: var(--max);
  margin: 0 auto;
  padding: 2rem 1.25rem 3rem;
  width: 100%;
}
.head {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
  align-items: end;
  margin-bottom: 1rem;
}
.eyebrow {
  text-transform: uppercase;
  letter-spacing: 0.12em;
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--rail);
}
h1 {
  font-size: clamp(2rem, 4vw, 2.6rem);
  margin: 0.25rem 0 0.5rem;
}
.lede {
  color: var(--muted);
  max-width: 48ch;
}
.lede strong {
  color: var(--rail);
}
.head-actions {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}
.link {
  font-weight: 700;
  color: var(--rail);
  font-size: 0.9rem;
}
.grid {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(9.5rem, 1fr));
  gap: 0.75rem;
}
.tile {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  padding: 1rem;
  border: 1px solid var(--line);
  text-decoration: none;
  color: inherit;
  background: linear-gradient(160deg, #fff, var(--mist));
  transition: border-color 0.2s ease, transform 0.2s ease;
}
.tile:hover {
  border-color: var(--rail);
  transform: translateY(-2px);
}
.num {
  font-family: var(--font-display);
  font-size: 1.75rem;
  font-weight: 700;
  color: var(--rail);
}
.label {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--muted);
}
button {
  border: 1px solid var(--line);
  background: white;
  padding: 0.65rem 0.75rem;
  font-weight: 700;
  cursor: pointer;
}
.ghost {
  background: white;
  color: var(--ink);
}
.error {
  color: var(--danger);
}
.empty {
  color: var(--muted);
}
@media (prefers-reduced-motion: reduce) {
  .tile {
    transition: none;
  }
  .tile:hover {
    transform: none;
  }
}
</style>

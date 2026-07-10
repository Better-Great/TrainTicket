<script setup lang="ts">
import { RouterLink, useRoute } from 'vue-router'

const route = useRoute()

const links = [
  { to: '/admin/stations', label: 'Stations' },
  { to: '/admin/routes', label: 'Routes' },
  { to: '/admin/trains', label: 'Trains' },
  { to: '/admin/prices', label: 'Prices' },
  { to: '/admin/config', label: 'Config' },
  { to: '/admin/contacts', label: 'Contacts' },
  { to: '/admin/users', label: 'Users' },
]
</script>

<template>
  <nav class="admin-nav" aria-label="Admin sections">
    <RouterLink
      v-for="l in links"
      :key="l.to"
      :to="l.to"
      class="item"
      :class="{ active: route.path === l.to }"
    >
      {{ l.label }}
    </RouterLink>
  </nav>
</template>

<style scoped>
.admin-nav {
  display: flex;
  gap: 0.35rem;
  flex-wrap: wrap;
  margin: 0 0 1.25rem;
  padding-bottom: 0.75rem;
  border-bottom: 1px solid var(--line);
}

.item {
  padding: 0.4rem 0.75rem;
  font-weight: 700;
  font-size: 0.9rem;
  color: var(--muted);
  text-decoration: none;
  border-bottom: 2px solid transparent;
}

.item.active,
.item:hover {
  color: var(--rail);
}

.item.active {
  border-bottom-color: var(--rail);
}
</style>

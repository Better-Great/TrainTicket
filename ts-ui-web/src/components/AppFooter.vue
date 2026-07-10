<script setup lang="ts">
import { RouterLink } from 'vue-router'
</script>

<template>
  <footer class="footer">
    <div class="inner">
      <div class="brand-block">
        <p class="brand">TrainTicket</p>
        <p class="tag">Modern client for the Train Ticket microservice benchmark.</p>
      </div>
      <nav aria-label="Footer">
        <RouterLink to="/search">Search</RouterLink>
        <RouterLink to="/advanced">Advanced</RouterLink>
        <RouterLink to="/wallet">Wallet</RouterLink>
        <RouterLink to="/waitlist">Wait-list</RouterLink>
        <RouterLink to="/offices">Offices</RouterLink>
        <RouterLink to="/admin/login">Admin</RouterLink>
        <RouterLink to="/register">Register</RouterLink>
        <a href="/robots.txt">Robots</a>
        <a href="/sitemap.xml">Sitemap</a>
      </nav>
    </div>
    <p class="legal">© {{ new Date().getFullYear() }} TrainTicket · Local-first SPA</p>
  </footer>
</template>

<style scoped>
.footer {
  border-top: 1px solid var(--line);
  background: var(--mist);
  padding: 2rem 1.25rem 1.25rem;
  margin-top: auto;
}

.inner {
  max-width: var(--max);
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  gap: 2rem;
  flex-wrap: wrap;
}

.brand {
  font-family: var(--font-display);
  font-weight: 800;
  font-size: 1.25rem;
  margin-bottom: 0.35rem;
}

.tag {
  color: var(--muted);
  max-width: 28ch;
  font-size: 0.9rem;
}

nav {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: start;
}

nav a {
  font-weight: 600;
  color: var(--rail);
  font-size: 0.9rem;
}

.legal {
  max-width: var(--max);
  margin: 1.5rem auto 0;
  color: var(--muted);
  font-size: 0.8rem;
}
</style>

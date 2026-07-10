<script setup lang="ts">
import { RouterLink } from 'vue-router'
import { tomorrowIso } from '@/utils/format'
</script>

<template>
  <section class="hero">
    <div class="hero-bg" aria-hidden="true" />
    <div class="hero-inner">
      <p class="brand">TrainTicket</p>
      <h1>Book the next departure with a quieter interface.</h1>
      <p class="support">
        Search high-speed and conventional trains, reserve seats, pay, and collect — rebuilt for
        local-first development.
      </p>
      <div class="actions">
        <RouterLink class="primary" :to="{ name: 'search', query: { date: tomorrowIso() } }">
          Search trips
        </RouterLink>
        <RouterLink class="ghost" to="/advanced">Advanced search</RouterLink>
      </div>
    </div>
  </section>

  <section class="strip">
    <div class="strip-inner">
      <div>
        <h2>One flow</h2>
        <p>Search → book → pay → collect, without the legacy multi-framework clutter.</p>
      </div>
      <div>
        <h2>Local first</h2>
        <p>Mock API by default. Point at the gateway only when you are ready to integrate.</p>
      </div>
      <div>
        <h2>Same contracts</h2>
        <p>Uses the existing <code>/api/v1/*</code> paths so the SPA stays gateway-compatible.</p>
      </div>
    </div>
  </section>
</template>

<style scoped>
.hero {
  position: relative;
  min-height: calc(100vh - var(--header-h) - 2rem);
  display: flex;
  align-items: flex-end;
  overflow: hidden;
  color: var(--paper);
}

.hero-bg {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(120deg, rgba(14, 36, 51, 0.92) 0%, rgba(14, 36, 51, 0.55) 48%, rgba(30, 77, 107, 0.35) 100%),
    repeating-linear-gradient(
      90deg,
      transparent 0,
      transparent 48px,
      rgba(232, 163, 23, 0.08) 48px,
      rgba(232, 163, 23, 0.08) 50px
    ),
    linear-gradient(160deg, #0e2433, #1e4d6b 55%, #7eb8c9);
  animation: drift 18s ease-in-out infinite alternate;
}

@keyframes drift {
  from {
    transform: scale(1);
  }
  to {
    transform: scale(1.04);
  }
}

.hero-inner {
  position: relative;
  z-index: 1;
  max-width: var(--max);
  width: 100%;
  margin: 0 auto;
  padding: 4rem 1.25rem 3.5rem;
  animation: rise 0.7s ease both;
}

@keyframes rise {
  from {
    opacity: 0;
    transform: translateY(18px);
  }
  to {
    opacity: 1;
    transform: none;
  }
}

.brand {
  font-family: var(--font-display);
  font-weight: 800;
  font-size: clamp(2.4rem, 6vw, 4rem);
  letter-spacing: -0.04em;
  margin-bottom: 1rem;
  color: var(--signal);
}

h1 {
  max-width: 16ch;
  font-size: clamp(1.6rem, 3.5vw, 2.35rem);
  font-weight: 700;
  margin-bottom: 1rem;
}

.support {
  max-width: 38ch;
  color: rgba(244, 247, 249, 0.82);
  margin-bottom: 1.75rem;
  font-size: 1.05rem;
}

.actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
}

.primary,
.ghost {
  display: inline-flex;
  align-items: center;
  padding: 0.85rem 1.25rem;
  font-weight: 700;
}

.primary {
  background: var(--signal);
  color: var(--signal-ink);
}

.ghost {
  border: 1px solid rgba(244, 247, 249, 0.45);
  color: var(--paper);
}

.strip {
  background: var(--mist);
  border-top: 1px solid var(--line);
}

.strip-inner {
  max-width: var(--max);
  margin: 0 auto;
  padding: 2.5rem 1.25rem;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2rem;
}

.strip h2 {
  font-size: 1.15rem;
  margin-bottom: 0.5rem;
}

.strip p {
  color: var(--muted);
  font-size: 0.95rem;
}

.strip code {
  font-size: 0.85em;
  color: var(--rail);
}

@media (max-width: 800px) {
  .strip-inner {
    grid-template-columns: 1fr;
  }
}
</style>

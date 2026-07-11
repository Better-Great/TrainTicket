<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { getNews } from '@/api/services'
import type { NewsItem } from '@/api/types'

const items = ref<NewsItem[]>([])
const loading = ref(false)
const error = ref('')

async function refresh() {
  loading.value = true
  error.value = ''
  try {
    items.value = await getNews()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load news'
    items.value = []
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  void refresh()
})
</script>

<template>
  <section class="page">
    <header class="head">
      <div>
        <p class="eyebrow">Updates</p>
        <h1>News</h1>
        <p class="lede">
          From <code>ts-news-service</code> via gateway
          <code>/api/v1/newsservice</code> or legacy <code>/news-service/news</code>.
        </p>
      </div>
      <button type="button" :disabled="loading" @click="refresh">
        {{ loading ? 'Refreshing…' : 'Refresh' }}
      </button>
    </header>

    <p v-if="error" class="error" role="alert">{{ error }}</p>

    <div v-if="loading && !items.length" class="skeleton" aria-hidden="true">
      <div /><div />
    </div>

    <ul v-else class="list" aria-live="polite">
      <li v-for="(n, i) in items" :key="n.Title + i" class="row">
        <article>
          <h2>{{ n.Title }}</h2>
          <p>{{ n.Content }}</p>
        </article>
      </li>
      <li v-if="!items.length && !loading" class="empty">No news items.</li>
    </ul>
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
  align-items: end;
  flex-wrap: wrap;
  margin-bottom: 1.25rem;
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

h2 {
  font-family: var(--font-display);
  font-size: 1.25rem;
  margin: 0 0 0.4rem;
}

.lede {
  color: var(--muted);
  max-width: 52ch;
}

.lede code {
  color: var(--rail);
  font-size: 0.9em;
}

button {
  border: 1px solid var(--ink);
  background: var(--ink);
  color: var(--paper);
  padding: 0.65rem 1rem;
  font-weight: 700;
  cursor: pointer;
}

.list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.row {
  padding: 1.15rem 0;
  border-bottom: 1px solid var(--line);
  animation: rise 0.4s ease both;
}

.row p {
  color: var(--muted);
  max-width: 60ch;
}

.empty,
.error {
  color: var(--muted);
}

.error {
  color: var(--danger);
}

.skeleton {
  display: grid;
  gap: 0.65rem;
}

.skeleton div {
  height: 4.5rem;
  background: linear-gradient(90deg, var(--mist), #fff, var(--mist));
  background-size: 200% 100%;
  animation: shimmer 1.2s linear infinite;
}

@keyframes rise {
  from {
    opacity: 0;
    transform: translateY(6px);
  }
  to {
    opacity: 1;
    transform: none;
  }
}

@keyframes shimmer {
  to {
    background-position: -200% 0;
  }
}

@media (prefers-reduced-motion: reduce) {
  .row,
  .skeleton div {
    animation: none;
  }
}
</style>

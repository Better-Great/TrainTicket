<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { advancedSearch } from '@/api/services'
import { formatMoney, tomorrowIso } from '@/utils/format'

const router = useRouter()
const form = reactive({
  from: 'Shang Hai',
  to: 'Su Zhou',
  date: tomorrowIso(),
  strategy: 'cheapest' as 'cheapest' | 'quickest' | 'minStation',
})
const loading = ref(false)
const error = ref('')
const results = ref<
  Array<{
    id: string
    startTime: string
    endTime: string
    startStation?: string
    terminalStation?: string
    priceForEconomyClass: string | number
    strategy: string
  }>
>([])

async function run() {
  loading.value = true
  error.value = ''
  try {
    results.value = await advancedSearch(
      {
        startPlace: form.from,
        endPlace: form.to,
        departureTime: `${form.date} 00:00:00`,
      },
      form.strategy,
    )
    if (!results.value.length) error.value = 'No itineraries matched.'
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Advanced search failed'
    results.value = []
  } finally {
    loading.value = false
  }
}

function book(row: (typeof results.value)[number]) {
  router.push({
    name: 'book',
    query: {
      tripId: row.id,
      from: row.startStation ?? form.from,
      to: row.terminalStation ?? form.to,
      seatType: '3',
      seatPrice: String(row.priceForEconomyClass),
      date: form.date,
    },
  })
}
</script>

<template>
  <section class="page">
    <p class="eyebrow">Planning</p>
    <h1>Advanced search</h1>
    <p class="lede">
      Rank trips by cheapest fare, earliest departure, or alternate stop patterns — same contracts as
      <code>travelplanservice</code>.
    </p>

    <form class="filters" @submit.prevent="run">
      <label>
        <span>From</span>
        <input v-model="form.from" required />
      </label>
      <label>
        <span>To</span>
        <input v-model="form.to" required />
      </label>
      <label>
        <span>Date</span>
        <input v-model="form.date" type="date" required />
      </label>
      <label>
        <span>Strategy</span>
        <select v-model="form.strategy">
          <option value="cheapest">Cheapest</option>
          <option value="quickest">Quickest</option>
          <option value="minStation">Min stations</option>
        </select>
      </label>
      <button type="submit" :disabled="loading">
        {{ loading ? 'Searching…' : 'Find itineraries' }}
      </button>
    </form>

    <p v-if="error" class="error" role="alert">{{ error }}</p>

    <ol class="results">
      <li v-for="(r, i) in results" :key="r.id + i">
        <div>
          <strong>{{ r.id }}</strong>
          <p>
            {{ r.startTime }} → {{ r.endTime }} · {{ r.startStation ?? form.from }} to
            {{ r.terminalStation ?? form.to }}
          </p>
          <p class="meta">{{ r.strategy }} · from {{ formatMoney(r.priceForEconomyClass) }}</p>
        </div>
        <button type="button" @click="book(r)">Book</button>
      </li>
    </ol>
  </section>
</template>

<style scoped>
.page {
  max-width: var(--max);
  margin: 0 auto;
  padding: 2rem 1.25rem 3rem;
  width: 100%;
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
  max-width: 54ch;
  margin-bottom: 1.5rem;
}

.lede code {
  color: var(--rail);
  font-size: 0.9em;
}

.filters {
  display: grid;
  grid-template-columns: repeat(4, 1fr) auto;
  gap: 0.75rem;
  align-items: end;
  padding-bottom: 1.25rem;
  border-bottom: 1px solid var(--line);
}

label {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  font-size: 0.8rem;
  font-weight: 700;
  color: var(--muted);
}

input,
select,
button {
  border: 1px solid var(--line);
  background: white;
  padding: 0.7rem 0.75rem;
}

button {
  background: var(--ink);
  color: var(--paper);
  border-color: var(--ink);
  font-weight: 700;
  cursor: pointer;
}

.results {
  list-style: none;
  margin: 1rem 0 0;
  padding: 0;
}

.results li {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  align-items: center;
  padding: 1rem 0;
  border-bottom: 1px solid var(--line);
  animation: rise 0.4s ease both;
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

.meta,
.error {
  color: var(--muted);
  font-size: 0.9rem;
}

.error {
  color: var(--danger);
  margin-top: 1rem;
}

@media (max-width: 900px) {
  .filters {
    grid-template-columns: 1fr 1fr;
  }
}

@media (prefers-reduced-motion: reduce) {
  .results li {
    animation: none;
  }
}
</style>

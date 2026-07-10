<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import TripRow from '@/components/TripRow.vue'
import { searchTrips } from '@/api/services'
import { tomorrowIso } from '@/utils/format'

const route = useRoute()
const router = useRouter()

const form = reactive({
  from: 'Shang Hai',
  to: 'Su Zhou',
  date: tomorrowIso(),
  trainType: 0 as 0 | 1 | 2,
})

const loading = ref(false)
const error = ref('')
const trips = ref<
  Array<{
    id: string
    startTime: string
    endTime: string
    startStation?: string
    terminalStation?: string
    economyClass: number
    confortClass: number
    priceForEconomyClass: string | number
    priceForConfortClass: string | number
    selectedSeat: 2 | 3
  }>
>([])

async function runSearch() {
  loading.value = true
  error.value = ''
  try {
    const data = await searchTrips(
      {
        startPlace: form.from,
        endPlace: form.to,
        departureTime: `${form.date} 00:00:00`,
      },
      form.trainType,
    )
    trips.value = data.map((t) => ({
      ...t,
      selectedSeat: 3 as 2 | 3,
    }))
    if (!trips.value.length) error.value = 'No trips found for that query.'
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Search failed'
    trips.value = []
  } finally {
    loading.value = false
  }
}

function book(index: number) {
  const t = trips.value[index]
  if (!t) return
  router.push({
    name: 'book',
    query: {
      tripId: t.id,
      from: t.startStation ?? form.from,
      to: t.terminalStation ?? form.to,
      seatType: String(t.selectedSeat),
      seatPrice:
        t.selectedSeat === 2
          ? String(t.priceForConfortClass)
          : String(t.priceForEconomyClass),
      date: form.date,
    },
  })
}

onMounted(() => {
  if (typeof route.query.date === 'string') form.date = route.query.date
  void runSearch()
})
</script>

<template>
  <section class="page">
    <header class="head">
      <div>
        <p class="eyebrow">Trips</p>
        <h1>Search</h1>
      </div>
      <RouterLink class="adv" :to="{ name: 'advanced' }">Advanced search</RouterLink>
    </header>

    <form class="filters" @submit.prevent="runSearch">
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
        <span>Train type</span>
        <select v-model.number="form.trainType">
          <option :value="0">All</option>
          <option :value="1">G / D</option>
          <option :value="2">Other</option>
        </select>
      </label>
      <button type="submit" :disabled="loading">
        {{ loading ? 'Searching…' : 'Search' }}
      </button>
    </form>

    <p v-if="error" class="error" role="alert">{{ error }}</p>

    <div v-if="loading" class="skeleton" aria-hidden="true">
      <div /><div /><div />
    </div>

    <div v-else class="results">
      <TripRow
        v-for="(t, i) in trips"
        :key="t.id + i"
        :trip-id="t.id"
        :start-time="t.startTime"
        :end-time="t.endTime"
        :from="t.startStation ?? form.from"
        :to="t.terminalStation ?? form.to"
        :economy-seats="t.economyClass"
        :comfort-seats="t.confortClass"
        :economy-price="t.priceForEconomyClass"
        :comfort-price="t.priceForConfortClass"
        :selected-seat="t.selectedSeat"
        @update:selected-seat="(v) => (t.selectedSeat = v)"
        @book="book(i)"
      />
      <p v-if="!trips.length && !error" class="empty">No results yet.</p>
    </div>
  </section>
</template>

<style scoped>
.page {
  max-width: var(--max);
  width: 100%;
  margin: 0 auto;
  padding: 2rem 1.25rem 3rem;
}

.eyebrow {
  text-transform: uppercase;
  letter-spacing: 0.12em;
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--rail);
}

.head {
  display: flex;
  justify-content: space-between;
  align-items: end;
  gap: 1rem;
  margin-bottom: 0.25rem;
}

.adv {
  font-weight: 700;
  color: var(--rail);
  font-size: 0.9rem;
}

h1 {
  font-size: clamp(2rem, 4vw, 2.75rem);
  margin-top: 0.25rem;
}

.filters {
  margin-top: 1.5rem;
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
  color: var(--ink);
}

button {
  background: var(--ink);
  color: var(--paper);
  border-color: var(--ink);
  font-weight: 700;
  cursor: pointer;
}

.error {
  color: var(--danger);
  margin-top: 1rem;
}

.skeleton {
  margin-top: 1.5rem;
  display: grid;
  gap: 0.75rem;
}

.skeleton div {
  height: 5rem;
  background: linear-gradient(90deg, var(--mist), #fff, var(--mist));
  background-size: 200% 100%;
  animation: shimmer 1.2s linear infinite;
}

@keyframes shimmer {
  to {
    background-position: -200% 0;
  }
}

.empty {
  color: var(--muted);
  padding: 2rem 0;
}

@media (max-width: 900px) {
  .filters {
    grid-template-columns: 1fr 1fr;
  }
}
</style>

<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { getOfficeRegions, getSpecificOffices } from '@/api/services'
import type { OfficeProvince, TicketOffice } from '@/api/types'

const regions = ref<OfficeProvince[]>([])
const offices = ref<TicketOffice[]>([])
const loadingRegions = ref(false)
const loadingOffices = ref(false)
const error = ref('')
const searched = ref(false)

const form = reactive({
  province: '',
  city: '',
  region: '',
})

const cities = computed(() => {
  const p = regions.value.find((r) => r.province === form.province)
  return p?.cities ?? []
})

const districts = computed(() => {
  const c = cities.value.find((x) => x.city === form.city)
  return c?.regions ?? []
})

watch(
  () => form.province,
  () => {
    form.city = ''
    form.region = ''
    offices.value = []
    searched.value = false
  },
)

watch(
  () => form.city,
  () => {
    form.region = ''
    offices.value = []
    searched.value = false
  },
)

async function loadRegions() {
  loadingRegions.value = true
  error.value = ''
  try {
    regions.value = await getOfficeRegions()
    if (regions.value[0]) form.province = regions.value[0].province
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load regions'
  } finally {
    loadingRegions.value = false
  }
}

async function search() {
  if (!form.province || !form.city || !form.region) {
    error.value = 'Select province, city, and district first.'
    return
  }
  loadingOffices.value = true
  error.value = ''
  searched.value = true
  try {
    offices.value = await getSpecificOffices({ ...form })
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load ticket offices'
    offices.value = []
  } finally {
    loadingOffices.value = false
  }
}

onMounted(() => {
  void loadRegions()
})
</script>

<template>
  <section class="page">
    <header class="head">
      <div>
        <p class="eyebrow">Stations</p>
        <h1>Ticket offices</h1>
        <p class="lede">
          Find counters by province → city → district via
          <code>ts-ticket-office-service</code>.
        </p>
      </div>
    </header>

    <p v-if="error" class="error" role="alert">{{ error }}</p>

    <form class="filters" @submit.prevent="search">
      <label>
        <span>Province</span>
        <select v-model="form.province" :disabled="loadingRegions" required>
          <option disabled value="">Select province</option>
          <option v-for="p in regions" :key="p.province" :value="p.province">
            {{ p.province }}
          </option>
        </select>
      </label>
      <label>
        <span>City</span>
        <select v-model="form.city" :disabled="!form.province" required>
          <option disabled value="">Select city</option>
          <option v-for="c in cities" :key="c.city" :value="c.city">{{ c.city }}</option>
        </select>
      </label>
      <label>
        <span>District</span>
        <select v-model="form.region" :disabled="!form.city" required>
          <option disabled value="">Select district</option>
          <option v-for="r in districts" :key="r.region" :value="r.region">
            {{ r.region }}
          </option>
        </select>
      </label>
      <button type="submit" :disabled="loadingOffices || !form.region">
        {{ loadingOffices ? 'Searching…' : 'Find offices' }}
      </button>
    </form>

    <div v-if="loadingOffices" class="skeleton" aria-hidden="true">
      <div /><div />
    </div>

    <ul v-else class="list" aria-live="polite">
      <li v-for="(o, i) in offices" :key="o.officeName + i" class="row">
        <div>
          <strong>{{ o.officeName }}</strong>
          <p>{{ o.address }}</p>
          <p class="meta">Hours {{ o.workTime }} · {{ o.windowNum }} windows</p>
        </div>
      </li>
      <li v-if="searched && !offices.length" class="empty">
        No ticket offices for that district.
      </li>
      <li v-if="!searched && !loadingRegions" class="empty">
        Choose a location and search.
      </li>
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

.lede code {
  color: var(--rail);
}

.filters {
  margin-top: 1.5rem;
  display: grid;
  grid-template-columns: 1fr 1fr 1fr auto;
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

button:disabled {
  opacity: 0.55;
  cursor: wait;
}

.list {
  list-style: none;
  margin: 1rem 0 0;
  padding: 0;
}

.row {
  padding: 1rem 0;
  border-bottom: 1px solid var(--line);
  animation: rise 0.4s ease both;
}

.meta,
.empty,
.error {
  color: var(--muted);
  font-size: 0.9rem;
}

.error {
  color: var(--danger);
  margin-top: 1rem;
}

.skeleton {
  margin-top: 1rem;
  display: grid;
  gap: 0.65rem;
}

.skeleton div {
  height: 4.25rem;
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

@media (max-width: 800px) {
  .filters {
    grid-template-columns: 1fr;
  }
}

@media (prefers-reduced-motion: reduce) {
  .row,
  .skeleton div {
    animation: none;
  }
}
</style>

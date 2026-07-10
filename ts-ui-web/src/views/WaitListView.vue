<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { RouterLink } from 'vue-router'
import {
  cancelWaitOrder,
  createWaitOrder,
  listContacts,
  listWaitOrders,
} from '@/api/services'
import type { Contact, WaitListOrder } from '@/api/types'
import { WAIT_LIST_STATUS } from '@/api/types'
import { useAuthStore } from '@/stores/auth'
import {
  filterActiveWaitList,
  formatMoney,
  seatTypeLabel,
  swapStations,
  tomorrowIso,
} from '@/utils/format'

const auth = useAuthStore()
const items = ref<WaitListOrder[]>([])
const contacts = ref<Contact[]>([])
const loading = ref(false)
const submitting = ref(false)
const busyId = ref('')
const error = ref('')
const ok = ref('')
const showCancelled = ref(false)

const form = reactive({
  tripId: '',
  from: 'Shang Hai',
  to: 'Nan Jing',
  date: tomorrowIso(),
  seatType: 3,
  price: '',
  contactsId: '',
})

const visible = computed(() =>
  showCancelled.value ? items.value : filterActiveWaitList(items.value),
)

const activeCount = computed(() => filterActiveWaitList(items.value).length)

async function refresh() {
  loading.value = true
  error.value = ''
  try {
    const [waitRes, contactRes] = await Promise.all([
      listWaitOrders(auth.userId),
      listContacts(auth.userId),
    ])
    items.value = waitRes.data ?? []
    contacts.value = contactRes.data ?? []
    if (!form.contactsId && contacts.value[0]) form.contactsId = contacts.value[0].id
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load wait-list'
  } finally {
    loading.value = false
  }
}

function validateForm(): string | null {
  if (!form.tripId.trim()) return 'Trip ID is required.'
  if (!form.from.trim() || !form.to.trim()) return 'Both stations are required.'
  if (form.from.trim().toLowerCase() === form.to.trim().toLowerCase()) {
    return 'From and to stations must be different.'
  }
  if (!form.date) return 'Travel date is required.'
  if (!form.contactsId) return 'Select a passenger contact.'
  const price = Number(form.price)
  if (!Number.isFinite(price) || price <= 0) return 'Enter a valid positive price.'
  return null
}

async function submit() {
  const problem = validateForm()
  if (problem) {
    error.value = problem
    return
  }
  submitting.value = true
  error.value = ''
  ok.value = ''
  try {
    const res = await createWaitOrder({
      accountId: auth.userId,
      contactsId: form.contactsId,
      tripId: form.tripId.trim(),
      seatType: form.seatType,
      date: form.date,
      from: form.from.trim(),
      to: form.to.trim(),
      price: String(Number(form.price)),
    })
    if (res.status !== 1 || !res.data) throw new Error(res.msg ?? 'Could not create wait-list order')
    ok.value = `Wait-list ${res.data.id} created — we’ll hold until ${res.data.waitUtilTime}`
    form.tripId = ''
    form.price = ''
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Could not create wait-list order'
  } finally {
    submitting.value = false
  }
}

async function cancel(id: string) {
  busyId.value = id
  error.value = ''
  ok.value = ''
  try {
    const res = await cancelWaitOrder(id, auth.userId)
    if (res.status !== 1) throw new Error(res.msg ?? 'Cancel failed')
    ok.value = 'Wait-list entry cancelled'
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Cancel failed'
  } finally {
    busyId.value = ''
  }
}

function statusClass(status: number): string {
  if (status === 0) return 'chip warn'
  if (status === 1) return 'chip ok'
  if (status === 3 || status === 5) return 'chip muted'
  return 'chip'
}

onMounted(() => {
  void refresh()
})
</script>

<template>
  <section class="page">
    <header class="head">
      <div>
        <p class="eyebrow">Demand</p>
        <h1>Wait-list</h1>
        <p class="lede">
          Queue for sold-out seats via <code>ts-wait-order-service</code>. Active:
          <strong>{{ activeCount }}</strong>
        </p>
      </div>
      <div class="head-actions">
        <RouterLink class="link" to="/contacts">Manage passengers</RouterLink>
        <button type="button" class="ghost" :disabled="loading" @click="refresh">
          {{ loading ? 'Refreshing…' : 'Refresh' }}
        </button>
      </div>
    </header>

    <p v-if="error" class="error" role="alert">{{ error }}</p>
    <p v-if="ok" class="ok" role="status">{{ ok }}</p>

    <div class="toolbar">
      <h2>Your entries</h2>
      <label class="toggle">
        <input v-model="showCancelled" type="checkbox" />
        Show cancelled / expired
      </label>
    </div>

    <div v-if="loading && !items.length" class="skeleton" aria-hidden="true">
      <div /><div />
    </div>

    <ul v-else class="list" aria-live="polite">
      <li v-for="w in visible" :key="w.id" class="row">
        <div class="main">
          <div class="title-row">
            <strong>{{ w.trainNumber }}</strong>
            <span :class="statusClass(w.status)">
              {{ WAIT_LIST_STATUS[w.status] ?? `Status ${w.status}` }}
            </span>
          </div>
          <p>{{ w.from }} → {{ w.to }} · {{ w.contactsName ?? 'Passenger' }}</p>
          <p class="meta">
            {{ seatTypeLabel(w.seatType) }} · {{ formatMoney(w.price) }} · until
            {{ w.waitUtilTime }} · created {{ w.createdTime }}
          </p>
        </div>
        <button
          v-if="w.status === 0 || w.status === 1"
          type="button"
          class="cancel"
          :disabled="busyId === w.id"
          @click="cancel(w.id)"
        >
          {{ busyId === w.id ? 'Cancelling…' : 'Cancel' }}
        </button>
      </li>
      <li v-if="!visible.length" class="empty">
        {{ showCancelled ? 'No wait-list history yet.' : 'No active wait-list entries.' }}
      </li>
    </ul>

    <h2>Join wait-list</h2>
    <form class="form" @submit.prevent="submit">
      <label>
        <span>Trip ID</span>
        <input v-model="form.tripId" placeholder="e.g. G1890" required autocomplete="off" />
      </label>
      <label>
        <span>Travel date</span>
        <input v-model="form.date" type="date" required />
      </label>
      <label>
        <span>From</span>
        <input v-model="form.from" required />
      </label>
      <div class="swap-wrap">
        <button type="button" class="swap" aria-label="Swap stations" @click="swapStations(form)">
          ⇄
        </button>
      </div>
      <label>
        <span>To</span>
        <input v-model="form.to" required />
      </label>
      <label>
        <span>Seat</span>
        <select v-model.number="form.seatType">
          <option :value="3">Economy</option>
          <option :value="2">Comfort</option>
        </select>
      </label>
      <label>
        <span>Expected price</span>
        <input v-model="form.price" type="number" min="0.1" step="0.1" placeholder="93.5" required />
      </label>
      <label class="wide">
        <span>Passenger</span>
        <select v-model="form.contactsId" required>
          <option disabled value="">Select contact</option>
          <option v-for="c in contacts" :key="c.id" :value="c.id">{{ c.name }}</option>
        </select>
      </label>
      <p v-if="!contacts.length" class="hint wide">
        No passengers yet —
        <RouterLink to="/contacts">add one</RouterLink>
        before joining the wait-list.
      </p>
      <button class="submit" type="submit" :disabled="submitting || !contacts.length">
        {{ submitting ? 'Joining…' : 'Add to wait-list' }}
      </button>
    </form>
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
  gap: 1.5rem;
  align-items: end;
  flex-wrap: wrap;
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

h2 {
  font-size: 1.15rem;
  margin: 0;
}

.lede {
  color: var(--muted);
  max-width: 48ch;
}

.lede code,
.lede strong {
  color: var(--rail);
}

.head-actions {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.link {
  font-weight: 700;
  color: var(--rail);
  font-size: 0.9rem;
}

.ghost,
.cancel,
.submit,
.swap {
  border: 1px solid var(--line);
  background: white;
  padding: 0.55rem 0.85rem;
  font-weight: 700;
  cursor: pointer;
}

.ghost:disabled,
.cancel:disabled,
.submit:disabled {
  opacity: 0.55;
  cursor: wait;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  margin: 1.5rem 0 0.75rem;
  flex-wrap: wrap;
}

.toggle {
  display: flex;
  gap: 0.45rem;
  align-items: center;
  font-size: 0.875rem;
  color: var(--muted);
  font-weight: 600;
}

.list {
  list-style: none;
  margin: 0 0 1.75rem;
  padding: 0;
}

.row {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  align-items: center;
  padding: 1rem 0;
  border-bottom: 1px solid var(--line);
  animation: rise 0.4s ease both;
}

.title-row {
  display: flex;
  gap: 0.65rem;
  align-items: center;
  flex-wrap: wrap;
  margin-bottom: 0.25rem;
}

.chip {
  font-size: 0.7rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  padding: 0.2rem 0.45rem;
  background: var(--mist);
  color: var(--ink);
}

.chip.warn {
  background: #f3e2b8;
  color: var(--signal-ink);
}

.chip.ok {
  background: #d7eee2;
  color: var(--ok);
}

.chip.muted {
  background: var(--line);
  color: var(--muted);
}

.meta,
.empty,
.hint {
  color: var(--muted);
  font-size: 0.9rem;
}

.cancel {
  color: var(--danger);
  border-color: color-mix(in srgb, var(--danger) 35%, white);
}

.form {
  display: grid;
  grid-template-columns: 1.2fr 1fr auto 1fr 1fr 1fr;
  gap: 0.75rem;
  align-items: end;
  max-width: 960px;
}

label {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  font-size: 0.85rem;
  font-weight: 600;
}

.wide {
  grid-column: 1 / -1;
}

.swap-wrap {
  display: flex;
  align-items: end;
  padding-bottom: 0.1rem;
}

.swap {
  min-width: 2.5rem;
  color: var(--rail);
}

input,
select {
  border: 1px solid var(--line);
  background: white;
  padding: 0.7rem 0.75rem;
}

.submit {
  grid-column: 1 / -1;
  background: var(--ink);
  color: var(--paper);
  border-color: var(--ink);
  padding: 0.85rem 1rem;
}

.error {
  color: var(--danger);
}

.ok {
  color: var(--ok);
}

.skeleton {
  display: grid;
  gap: 0.65rem;
  margin-bottom: 1rem;
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

@media (max-width: 900px) {
  .form {
    grid-template-columns: 1fr 1fr;
  }

  .swap-wrap {
    display: none;
  }
}

@media (prefers-reduced-motion: reduce) {
  .row,
  .skeleton div {
    animation: none;
  }
}
</style>

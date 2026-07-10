<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import {
  createFoodDelivery,
  deleteFoodDelivery,
  listFoodDeliveries,
  updateFoodDeliverySeat,
  updateFoodDeliveryTime,
  updateFoodDeliveryTrip,
} from '@/api/services'
import type { FoodDeliveryOrder } from '@/api/types'

const orders = ref<FoodDeliveryOrder[]>([])
const loading = ref(false)
const busyId = ref('')
const error = ref('')
const ok = ref('')
const query = ref('')

const form = reactive({
  stationFoodStoreId: 'store-shanghai-1',
  tripId: 'G1234',
  seatNo: 12,
  deliveryTime: '2026-07-20 10:00:00',
  deliveryFee: 5,
  foodName: 'Beef Noodle',
  foodPrice: 28,
})

const edit = reactive({
  id: '',
  tripId: '',
  seatNo: 0,
  deliveryTime: '',
})

const filtered = computed(() => {
  const q = query.value.trim().toLowerCase()
  if (!q) return orders.value
  return orders.value.filter(
    (o) =>
      o.id.toLowerCase().includes(q) ||
      o.tripId.toLowerCase().includes(q) ||
      o.stationFoodStoreId.toLowerCase().includes(q) ||
      o.foodList.some((f) => f.foodName.toLowerCase().includes(q)),
  )
})

function foodTotal(o: FoodDeliveryOrder) {
  const items = o.foodList.reduce((sum, f) => sum + Number(f.price), 0)
  return items + Number(o.deliveryFee)
}

async function refresh() {
  loading.value = true
  error.value = ''
  try {
    orders.value = (await listFoodDeliveries()).data ?? []
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load deliveries'
  } finally {
    loading.value = false
  }
}

async function add() {
  error.value = ''
  ok.value = ''
  try {
    const res = await createFoodDelivery({
      stationFoodStoreId: form.stationFoodStoreId.trim(),
      tripId: form.tripId.trim(),
      seatNo: Number(form.seatNo),
      deliveryTime: form.deliveryTime.trim(),
      deliveryFee: Number(form.deliveryFee),
      foodList: [{ foodName: form.foodName.trim(), price: Number(form.foodPrice) }],
    })
    if (res.status !== 1) throw new Error(res.msg ?? 'Create failed')
    ok.value = `Ordered for trip ${res.data.tripId}`
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Create failed'
  }
}

function startEdit(o: FoodDeliveryOrder) {
  edit.id = o.id
  edit.tripId = o.tripId
  edit.seatNo = o.seatNo
  edit.deliveryTime = o.deliveryTime
}

async function saveEdit() {
  if (!edit.id) return
  busyId.value = edit.id
  error.value = ''
  ok.value = ''
  try {
    const trip = await updateFoodDeliveryTrip(edit.id, edit.tripId)
    if (trip.status !== 1) throw new Error(trip.msg ?? 'Trip update failed')
    const seat = await updateFoodDeliverySeat(edit.id, Number(edit.seatNo))
    if (seat.status !== 1) throw new Error(seat.msg ?? 'Seat update failed')
    const time = await updateFoodDeliveryTime(edit.id, edit.deliveryTime)
    if (time.status !== 1) throw new Error(time.msg ?? 'Time update failed')
    ok.value = 'Delivery updated'
    edit.id = ''
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Update failed'
  } finally {
    busyId.value = ''
  }
}

async function remove(id: string) {
  busyId.value = id
  error.value = ''
  ok.value = ''
  try {
    const res = await deleteFoodDelivery(id)
    if (res.status !== 1) throw new Error(res.msg ?? 'Delete failed')
    ok.value = 'Delivery cancelled'
    if (edit.id === id) edit.id = ''
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Delete failed'
  } finally {
    busyId.value = ''
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
        <p class="eyebrow">Onboard</p>
        <h1>Food delivery</h1>
        <p class="lede">
          Track seat deliveries via <code>fooddeliveryservice</code> — update trip, seat, or
          delivery time.
        </p>
      </div>
      <button type="button" class="ghost" :disabled="loading" @click="refresh">
        {{ loading ? 'Refreshing…' : 'Refresh' }}
      </button>
    </header>

    <p v-if="error" class="error" role="alert">{{ error }}</p>
    <p v-if="ok" class="ok" role="status">{{ ok }}</p>

    <label class="search">
      <span>Search</span>
      <input v-model="query" type="search" placeholder="Trip, store, food, id…" />
    </label>

    <h2>Your deliveries</h2>
    <ul class="list" aria-live="polite">
      <li v-for="o in filtered" :key="o.id" class="row">
        <template v-if="edit.id === o.id">
          <div class="edit-grid">
            <label>
              <span>Trip</span>
              <input v-model="edit.tripId" />
            </label>
            <label>
              <span>Seat</span>
              <input v-model.number="edit.seatNo" type="number" min="1" />
            </label>
            <label>
              <span>Delivery time</span>
              <input v-model="edit.deliveryTime" />
            </label>
            <div class="actions">
              <button type="button" :disabled="busyId === o.id" @click="saveEdit">Save</button>
              <button type="button" class="ghost" @click="edit.id = ''">Cancel</button>
            </div>
          </div>
        </template>
        <template v-else>
          <div class="row-view">
            <div>
              <strong>{{ o.tripId }}</strong>
              <span class="badge">Seat {{ o.seatNo }}</span>
              <p class="meta">
                {{ o.foodList.map((f) => f.foodName).join(', ') }} · deliver
                {{ o.deliveryTime }} · store {{ o.stationFoodStoreId }} · ¥{{ foodTotal(o).toFixed(2) }}
              </p>
            </div>
            <div class="actions">
              <button type="button" class="ghost" @click="startEdit(o)">Update</button>
              <button type="button" class="danger" :disabled="busyId === o.id" @click="remove(o.id)">
                {{ busyId === o.id ? '…' : 'Cancel' }}
              </button>
            </div>
          </div>
        </template>
      </li>
      <li v-if="!filtered.length && !loading" class="empty">No food deliveries yet.</li>
    </ul>

    <h2>Order food to seat</h2>
    <form class="form" @submit.prevent="add">
      <label>
        <span>Store ID</span>
        <input v-model="form.stationFoodStoreId" required />
      </label>
      <label>
        <span>Trip ID</span>
        <input v-model="form.tripId" required />
      </label>
      <label>
        <span>Seat no.</span>
        <input v-model.number="form.seatNo" type="number" min="1" required />
      </label>
      <label>
        <span>Delivery time</span>
        <input v-model="form.deliveryTime" required />
      </label>
      <label>
        <span>Food</span>
        <input v-model="form.foodName" required />
      </label>
      <label>
        <span>Food price</span>
        <input v-model.number="form.foodPrice" type="number" min="0" step="0.01" required />
      </label>
      <label>
        <span>Delivery fee</span>
        <input v-model.number="form.deliveryFee" type="number" min="0" step="0.01" required />
      </label>
      <button type="submit">Place order</button>
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
h2 {
  font-size: 1.15rem;
  margin: 1.5rem 0 0.75rem;
}
.lede {
  color: var(--muted);
  max-width: 52ch;
}
.lede code {
  color: var(--rail);
}
.search {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  font-size: 0.85rem;
  font-weight: 600;
  max-width: 28rem;
  margin-bottom: 0.5rem;
}
.list {
  list-style: none;
  margin: 0;
  padding: 0;
}
.row {
  padding: 0.9rem 0;
  border-bottom: 1px solid var(--line);
}
.row-view {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 0.65rem;
  align-items: center;
}
.badge {
  display: inline-block;
  margin-left: 0.5rem;
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--rail);
}
.edit-grid,
.form {
  display: grid;
  gap: 0.65rem;
  max-width: 720px;
}
.actions {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}
label {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  font-size: 0.85rem;
  font-weight: 600;
}
input,
button {
  border: 1px solid var(--line);
  background: white;
  padding: 0.65rem 0.75rem;
}
button {
  background: var(--ink);
  color: var(--paper);
  border-color: var(--ink);
  font-weight: 700;
  cursor: pointer;
}
.ghost {
  background: white;
  color: var(--ink);
}
.danger {
  background: white;
  color: var(--danger);
  border-color: color-mix(in srgb, var(--danger) 35%, white);
}
.meta,
.empty {
  color: var(--muted);
  font-size: 0.875rem;
}
.error {
  color: var(--danger);
}
.ok {
  color: var(--ok);
}
@media (max-width: 720px) {
  .row-view {
    grid-template-columns: 1fr;
  }
}
</style>

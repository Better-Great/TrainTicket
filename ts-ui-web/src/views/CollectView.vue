<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { collectTicket, enterStation, listOrders } from '@/api/services'
import type { Order } from '@/api/types'
import { ORDER_STATUS } from '@/api/types'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const orders = ref<Order[]>([])
const error = ref('')
const busyId = ref('')

const actionable = computed(() =>
  orders.value.filter((o) => o.status === 1 || o.status === 2),
)

async function refresh() {
  const res = await listOrders(auth.userId)
  orders.value = res.data ?? []
}

async function collect(id: string) {
  busyId.value = id
  error.value = ''
  try {
    await collectTicket(id)
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Collect failed'
  } finally {
    busyId.value = ''
  }
}

async function enter(id: string) {
  busyId.value = id
  error.value = ''
  try {
    await enterStation(id)
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Enter failed'
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
    <p class="eyebrow">Station</p>
    <h1>Collect & enter</h1>
    <p class="lede">Paid tickets can be collected, then used to enter the station.</p>

    <p v-if="error" class="error" role="alert">{{ error }}</p>
    <p v-if="!actionable.length" class="empty">No paid or collected tickets waiting.</p>

    <ul class="list">
      <li v-for="o in actionable" :key="o.id">
        <div>
          <strong>{{ o.trainNumber }}</strong>
          <p>{{ o.from }} → {{ o.to }} · {{ ORDER_STATUS[o.status] }}</p>
        </div>
        <div class="actions">
          <button
            v-if="o.status === 1"
            type="button"
            :disabled="busyId === o.id"
            @click="collect(o.id)"
          >
            Collect
          </button>
          <button
            v-if="o.status === 2"
            type="button"
            :disabled="busyId === o.id"
            @click="enter(o.id)"
          >
            Enter station
          </button>
        </div>
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

.lede,
.empty {
  color: var(--muted);
  margin-bottom: 1.5rem;
}

.list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.list li {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  align-items: center;
  padding: 1rem 0;
  border-bottom: 1px solid var(--line);
}

.actions {
  display: flex;
  gap: 0.5rem;
}

button {
  border: none;
  background: var(--rail);
  color: white;
  padding: 0.65rem 0.9rem;
  font-weight: 700;
  cursor: pointer;
}

.error {
  color: var(--danger);
}
</style>

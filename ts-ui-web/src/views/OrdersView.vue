<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { listOrders, payOrder } from '@/api/services'
import type { Order } from '@/api/types'
import { ORDER_STATUS } from '@/api/types'
import { useAuthStore } from '@/stores/auth'
import { formatMoney } from '@/utils/format'

const auth = useAuthStore()
const orders = ref<Order[]>([])
const loading = ref(false)
const error = ref('')
const busyId = ref('')

async function refresh() {
  loading.value = true
  error.value = ''
  try {
    const res = await listOrders(auth.userId)
    orders.value = res.data ?? []
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load orders'
  } finally {
    loading.value = false
  }
}

async function pay(order: Order) {
  busyId.value = order.id
  error.value = ''
  try {
    const res = await payOrder(order.id, order.trainNumber)
    if (res.status !== 1) throw new Error(res.msg ?? 'Payment failed')
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Payment failed'
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
        <p class="eyebrow">Account</p>
        <h1>Orders</h1>
      </div>
      <div class="head-actions">
        <RouterLink class="link" to="/wallet">Wallet</RouterLink>
        <button type="button" class="refresh" :disabled="loading" @click="refresh">
          {{ loading ? 'Refreshing…' : 'Refresh' }}
        </button>
      </div>
    </header>

    <p v-if="error" class="error" role="alert">{{ error }}</p>

    <div v-if="!orders.length && !loading" class="empty">No orders yet. Search and book a trip.</div>

    <ul class="list">
      <li v-for="o in orders" :key="o.id">
        <div>
          <strong>{{ o.trainNumber }}</strong>
          <p>{{ o.from }} → {{ o.to }} · {{ o.travelDate }}</p>
          <p class="meta">
            {{ o.contactsName ?? 'Passenger' }} · {{ formatMoney(o.price) }} ·
            {{ ORDER_STATUS[o.status] ?? `Status ${o.status}` }}
          </p>
        </div>
        <div class="actions">
          <button
            v-if="o.status === 0"
            type="button"
            :disabled="busyId === o.id"
            @click="pay(o)"
          >
            {{ busyId === o.id ? 'Paying…' : 'Pay' }}
          </button>
          <RouterLink v-if="o.status === 1" class="next" to="/collect">Collect</RouterLink>
          <RouterLink
            v-if="o.status >= 1"
            class="next"
            :to="{ name: 'voucher', query: { orderId: o.id, train_number: o.trainNumber } }"
          >
            Voucher
          </RouterLink>
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

.head {
  display: flex;
  justify-content: space-between;
  align-items: end;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.head-actions {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.link,
.next {
  font-weight: 700;
  color: var(--rail);
  font-size: 0.9rem;
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
  margin-top: 0.25rem;
}

.refresh,
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

.list li {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  align-items: center;
  padding: 1.1rem 0;
  border-bottom: 1px solid var(--line);
  animation: rise 0.4s ease both;
}

.actions {
  display: flex;
  gap: 0.75rem;
  align-items: center;
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
.empty,
.error {
  color: var(--muted);
  font-size: 0.9rem;
}

.error {
  color: var(--danger);
}
</style>

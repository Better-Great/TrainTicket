<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { getVoucher } from '@/api/services'
import type { Voucher } from '@/api/types'

const route = useRoute()
const voucher = ref<Voucher | null>(null)
const loading = ref(false)
const error = ref('')

function tripType(trainNumber: string): 0 | 1 {
  const c = trainNumber.charAt(0).toUpperCase()
  return c === 'G' || c === 'D' ? 1 : 0
}

async function load() {
  const orderId = String(route.query.orderId ?? '')
  const trainNumber = String(route.query.train_number ?? route.query.trainNumber ?? '')
  if (!orderId) {
    error.value = 'Add ?orderId=…&train_number=G1234 to the URL'
    return
  }
  loading.value = true
  error.value = ''
  try {
    voucher.value = await getVoucher({
      orderId,
      type: tripType(trainNumber || 'G'),
    })
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load voucher'
    voucher.value = null
  } finally {
    loading.value = false
  }
}

function printPage() {
  window.print()
}

onMounted(() => {
  void load()
})
</script>

<template>
  <section class="page">
    <header class="head no-print">
      <div>
        <p class="eyebrow">Receipt</p>
        <h1>Voucher</h1>
        <p class="lede">Printable travel voucher from <code>voucherservice</code>.</p>
      </div>
      <div class="actions">
        <button type="button" class="ghost" :disabled="loading" @click="load">
          {{ loading ? 'Loading…' : 'Reload' }}
        </button>
        <button type="button" :disabled="!voucher" @click="printPage">Print</button>
      </div>
    </header>

    <p v-if="error" class="error" role="alert">{{ error }}</p>

    <article v-if="voucher" class="slip" aria-live="polite">
      <h2>TrainTicket Voucher</h2>
      <dl>
        <div>
          <dt>Voucher ID</dt>
          <dd>10000{{ voucher.voucher_id }}</dd>
        </div>
        <div>
          <dt>Order</dt>
          <dd>{{ voucher.order_id }}</dd>
        </div>
        <div>
          <dt>Travel date</dt>
          <dd>{{ voucher.travelDate }}</dd>
        </div>
        <div>
          <dt>Passenger</dt>
          <dd>{{ voucher.contactName }}</dd>
        </div>
        <div>
          <dt>Train</dt>
          <dd>{{ voucher.train_number }}</dd>
        </div>
        <div>
          <dt>Seat</dt>
          <dd>{{ voucher.seat_number }}</dd>
        </div>
        <div>
          <dt>From</dt>
          <dd>{{ voucher.start_station }}</dd>
        </div>
        <div>
          <dt>To</dt>
          <dd>{{ voucher.dest_station }}</dd>
        </div>
        <div>
          <dt>Price</dt>
          <dd>¥{{ voucher.price }}</dd>
        </div>
      </dl>
    </article>
  </section>
</template>

<style scoped>
.page {
  max-width: 40rem;
  margin: 0 auto;
  padding: 2rem 1.25rem 3rem;
}
.head {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
  align-items: end;
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
  font-size: clamp(2rem, 4vw, 2.4rem);
  margin: 0.25rem 0 0.5rem;
}
.lede {
  color: var(--muted);
}
.lede code {
  color: var(--rail);
}
.actions {
  display: flex;
  gap: 0.5rem;
}
.slip {
  border: 1px solid var(--ink);
  padding: 1.5rem;
  background: #fff;
}
.slip h2 {
  font-family: var(--font-display);
  margin: 0 0 1rem;
  font-size: 1.35rem;
}
dl {
  margin: 0;
  display: grid;
  gap: 0.65rem;
}
dl div {
  display: grid;
  grid-template-columns: 8rem 1fr;
  gap: 0.5rem;
  border-bottom: 1px dashed var(--line);
  padding-bottom: 0.4rem;
}
dt {
  color: var(--muted);
  font-size: 0.85rem;
}
dd {
  margin: 0;
  font-weight: 700;
}
button {
  border: 1px solid var(--ink);
  background: var(--ink);
  color: var(--paper);
  padding: 0.65rem 0.9rem;
  font-weight: 700;
  cursor: pointer;
}
.ghost {
  background: white;
  color: var(--ink);
}
.error {
  color: var(--danger);
}
@media print {
  .no-print {
    display: none !important;
  }
  .page {
    padding: 0;
  }
  .slip {
    border: none;
  }
}
</style>

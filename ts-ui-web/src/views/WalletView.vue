<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { getWallet, topUpWallet } from '@/api/services'
import { useAuthStore } from '@/stores/auth'
import { formatMoney } from '@/utils/format'

const auth = useAuthStore()
const balance = ref<number | null>(null)
const amount = ref('100')
const loading = ref(false)
const error = ref('')
const ok = ref('')

async function refresh() {
  loading.value = true
  error.value = ''
  try {
    const res = await getWallet(auth.userId)
    balance.value = res.data.balance
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Could not load wallet'
  } finally {
    loading.value = false
  }
}

async function topUp() {
  ok.value = ''
  error.value = ''
  loading.value = true
  try {
    const res = await topUpWallet(auth.userId, amount.value)
    if (res.status !== 1 || !res.data) throw new Error(res.msg ?? 'Top-up failed')
    balance.value = res.data.balance
    ok.value = `Added ${formatMoney(amount.value)}`
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Top-up failed'
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
    <p class="eyebrow">Account</p>
    <h1>Wallet</h1>
    <p class="lede">Inside-payment balance used when you pay for reserved tickets.</p>

    <div class="balance" aria-live="polite">
      <span>Available</span>
      <strong>{{ balance === null ? '—' : formatMoney(balance) }}</strong>
    </div>

    <form class="form" @submit.prevent="topUp">
      <label>
        <span>Top-up amount</span>
        <input v-model="amount" type="number" min="1" step="1" required />
      </label>
      <button type="submit" :disabled="loading">
        {{ loading ? 'Working…' : 'Add funds' }}
      </button>
    </form>

    <p v-if="error" class="error" role="alert">{{ error }}</p>
    <p v-if="ok" class="ok" role="status">{{ ok }}</p>
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
  margin-bottom: 1.5rem;
}

.balance {
  padding: 1.25rem 0 1.5rem;
  border-bottom: 1px solid var(--line);
  margin-bottom: 1.5rem;
}

.balance span {
  display: block;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--muted);
  margin-bottom: 0.35rem;
}

.balance strong {
  font-family: var(--font-display);
  font-size: clamp(2.2rem, 5vw, 3rem);
}

.form {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  align-items: end;
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
  padding: 0.7rem 0.85rem;
}

button {
  background: var(--signal);
  color: var(--signal-ink);
  border-color: var(--signal);
  font-weight: 800;
  cursor: pointer;
}

.error {
  color: var(--danger);
  margin-top: 1rem;
}

.ok {
  color: var(--ok);
  margin-top: 1rem;
}
</style>

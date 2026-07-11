<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import AdminNav from '@/components/AdminNav.vue'
import { createPrice, deletePrice, listPrices, updatePrice } from '@/api/services'
import type { Price } from '@/api/types'
import { useAdminStore } from '@/stores/admin'

const admin = useAdminStore()
const router = useRouter()

const prices = ref<Price[]>([])
const loading = ref(false)
const busyId = ref('')
const error = ref('')
const ok = ref('')

const form = reactive({
  routeId: 'route-1',
  trainType: 'GaoTie',
  basicPriceRate: 0.28,
  firstClassPriceRate: 0.45,
})

const edit = reactive({
  id: '',
  routeId: '',
  trainType: '',
  basicPriceRate: 0,
  firstClassPriceRate: 0,
})

async function refresh() {
  loading.value = true
  error.value = ''
  try {
    prices.value = (await listPrices()).data ?? []
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load prices'
  } finally {
    loading.value = false
  }
}

async function add() {
  error.value = ''
  ok.value = ''
  try {
    const res = await createPrice({
      routeId: form.routeId.trim(),
      trainType: form.trainType.trim(),
      basicPriceRate: Number(form.basicPriceRate),
      firstClassPriceRate: Number(form.firstClassPriceRate),
    })
    if (res.status !== 1) throw new Error(res.msg ?? 'Create failed')
    ok.value = `Added price for ${res.data.trainType}`
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Create failed'
  }
}

function startEdit(p: Price) {
  Object.assign(edit, p)
}

async function saveEdit() {
  if (!edit.id) return
  busyId.value = edit.id
  error.value = ''
  ok.value = ''
  try {
    const res = await updatePrice({
      id: edit.id,
      routeId: edit.routeId.trim(),
      trainType: edit.trainType.trim(),
      basicPriceRate: Number(edit.basicPriceRate),
      firstClassPriceRate: Number(edit.firstClassPriceRate),
    })
    if (res.status !== 1) throw new Error(res.msg ?? 'Update failed')
    ok.value = 'Price updated'
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
    const res = await deletePrice(id)
    if (res.status !== 1) throw new Error(res.msg ?? 'Delete failed')
    ok.value = 'Price deleted'
    if (edit.id === id) edit.id = ''
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Delete failed'
  } finally {
    busyId.value = ''
  }
}

function logout() {
  admin.logout()
  router.push({ name: 'admin-login' })
}

onMounted(() => {
  void refresh()
})
</script>

<template>
  <section class="page">
    <header class="head">
      <div>
        <p class="eyebrow">Admin</p>
        <h1>Prices</h1>
        <p class="lede">
          CRUD via <code>adminbasicservice/adminbasic/prices</code> ·
          <strong>{{ admin.username }}</strong>
        </p>
      </div>
      <div class="head-actions">
        <RouterLink class="link" to="/">Client app</RouterLink>
        <button type="button" class="ghost" @click="logout">Sign out</button>
        <button type="button" class="ghost" :disabled="loading" @click="refresh">
          {{ loading ? 'Refreshing…' : 'Refresh' }}
        </button>
      </div>
    </header>

    <AdminNav />

    <p v-if="error" class="error" role="alert">{{ error }}</p>
    <p v-if="ok" class="ok" role="status">{{ ok }}</p>

    <h2>Price rates</h2>
    <ul class="list" aria-live="polite">
      <li v-for="p in prices" :key="p.id" class="row">
        <template v-if="edit.id === p.id">
          <div class="edit-grid">
            <input v-model="edit.routeId" aria-label="Route ID" />
            <input v-model="edit.trainType" aria-label="Train type" />
            <input v-model.number="edit.basicPriceRate" type="number" step="0.01" min="0.01" aria-label="Basic rate" />
            <input
              v-model.number="edit.firstClassPriceRate"
              type="number"
              step="0.01"
              min="0.01"
              aria-label="First class rate"
            />
            <div class="actions">
              <button type="button" :disabled="busyId === p.id" @click="saveEdit">Save</button>
              <button type="button" class="ghost" @click="edit.id = ''">Cancel</button>
            </div>
          </div>
        </template>
        <template v-else>
          <div class="row-view">
            <div>
              <strong>{{ p.trainType }}</strong>
              <p class="meta">
                Route {{ p.routeId }} · basic {{ p.basicPriceRate }} · first
                {{ p.firstClassPriceRate }} · {{ p.id }}
              </p>
            </div>
            <div class="actions">
              <button type="button" class="ghost" @click="startEdit(p)">Edit</button>
              <button type="button" class="danger" :disabled="busyId === p.id" @click="remove(p.id)">
                {{ busyId === p.id ? '…' : 'Delete' }}
              </button>
            </div>
          </div>
        </template>
      </li>
      <li v-if="!prices.length && !loading" class="empty">No prices yet.</li>
    </ul>

    <h2>Add price</h2>
    <form class="form" @submit.prevent="add">
      <label>
        <span>Route ID</span>
        <input v-model="form.routeId" required />
      </label>
      <label>
        <span>Train type</span>
        <input v-model="form.trainType" required />
      </label>
      <label>
        <span>Basic rate</span>
        <input v-model.number="form.basicPriceRate" type="number" step="0.01" min="0.01" required />
      </label>
      <label>
        <span>First-class rate</span>
        <input
          v-model.number="form.firstClassPriceRate"
          type="number"
          step="0.01"
          min="0.01"
          required
        />
      </label>
      <button type="submit">Create</button>
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
.lede code,
.lede strong {
  color: var(--rail);
}
.head-actions,
.actions {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
  align-items: center;
}
.link {
  font-weight: 700;
  color: var(--rail);
  font-size: 0.9rem;
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
.edit-grid,
.form {
  display: grid;
  gap: 0.65rem;
  max-width: 720px;
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

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import AdminNav from '@/components/AdminNav.vue'
import {
  createAdminOrder,
  deleteAdminOrder,
  listAdminOrders,
  listUsers,
  updateAdminOrder,
} from '@/api/services'
import type { AdminOrder } from '@/api/types'
import { ORDER_STATUS } from '@/api/types'
import { useAdminStore } from '@/stores/admin'

const admin = useAdminStore()
const router = useRouter()

const orders = ref<AdminOrder[]>([])
const accountOptions = ref<string[]>([])
const loading = ref(false)
const busyId = ref('')
const error = ref('')
const ok = ref('')
const statusFilter = ref<string>('all')
const query = ref('')

const form = reactive({
  boughtDate: '2026-07-10',
  travelDate: '2026-07-20',
  travelTime: '09:00:00',
  accountId: '4d2a46c7-71ce-4cf1-b5bb-b68406a1fd6a',
  contactsName: 'Alex Rider',
  documentType: 1,
  contactsDocumentNumber: 'A12345678',
  trainNumber: 'G1234',
  coachNumber: 5,
  seatClass: 2,
  seatNumber: '1A',
  from: 'Shang Hai',
  to: 'Nan Jing',
  status: 0,
  price: '75.5',
})

const edit = reactive<AdminOrder & { editing: boolean }>({
  id: '',
  boughtDate: '',
  travelDate: '',
  travelTime: '',
  accountId: '',
  contactsName: '',
  documentType: 1,
  contactsDocumentNumber: '',
  trainNumber: '',
  coachNumber: 1,
  seatClass: 2,
  seatNumber: '',
  from: '',
  to: '',
  status: 0,
  price: '',
  editing: false,
})

const filtered = computed(() => {
  const q = query.value.trim().toLowerCase()
  return orders.value.filter((o) => {
    if (statusFilter.value !== 'all' && Number(o.status) !== Number(statusFilter.value)) {
      return false
    }
    if (!q) return true
    return (
      o.id.toLowerCase().includes(q) ||
      o.trainNumber.toLowerCase().includes(q) ||
      o.contactsName.toLowerCase().includes(q) ||
      o.accountId.toLowerCase().includes(q) ||
      o.from.toLowerCase().includes(q) ||
      o.to.toLowerCase().includes(q)
    )
  })
})

function statusLabel(status: number | string) {
  return ORDER_STATUS[Number(status)] ?? `Status ${status}`
}

async function refresh() {
  loading.value = true
  error.value = ''
  try {
    const [orderRes, usersRes] = await Promise.all([listAdminOrders(), listUsers()])
    orders.value = orderRes.data ?? []
    accountOptions.value = (usersRes.data ?? []).map((u) => u.userId)
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load orders'
  } finally {
    loading.value = false
  }
}

async function add() {
  error.value = ''
  ok.value = ''
  try {
    const res = await createAdminOrder({ ...form })
    if (res.status !== 1) throw new Error(res.msg ?? 'Create failed')
    ok.value = `Added order ${res.data.id}`
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Create failed'
  }
}

function startEdit(o: AdminOrder) {
  Object.assign(edit, o, { editing: true })
}

async function saveEdit() {
  if (!edit.editing) return
  busyId.value = edit.id
  error.value = ''
  ok.value = ''
  try {
    const { editing: _, ...body } = edit
    const res = await updateAdminOrder(body)
    if (res.status !== 1) throw new Error(res.msg ?? 'Update failed')
    ok.value = `Updated ${res.data.id}`
    edit.editing = false
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Update failed'
  } finally {
    busyId.value = ''
  }
}

async function remove(o: AdminOrder) {
  busyId.value = o.id
  error.value = ''
  ok.value = ''
  try {
    const res = await deleteAdminOrder(o.id, o.trainNumber)
    if (res.status !== 1) throw new Error(res.msg ?? 'Delete failed')
    ok.value = 'Order deleted'
    if (edit.id === o.id) edit.editing = false
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
        <h1>Orders</h1>
        <p class="lede">
          Aggregated BFF <code>adminorderservice/adminorder</code> ·
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

    <div class="filters">
      <label>
        <span>Status</span>
        <select v-model="statusFilter">
          <option value="all">All</option>
          <option v-for="(label, code) in ORDER_STATUS" :key="code" :value="String(code)">
            {{ label }}
          </option>
        </select>
      </label>
      <label class="grow">
        <span>Search</span>
        <input
          v-model="query"
          type="search"
          placeholder="ID, train, passenger, account, stations…"
        />
      </label>
      <p class="count" aria-live="polite">{{ filtered.length }} / {{ orders.length }}</p>
    </div>

    <h2>All orders</h2>
    <ul class="list" aria-live="polite">
      <li v-for="o in filtered" :key="o.id" class="row">
        <template v-if="edit.editing && edit.id === o.id">
          <div class="edit-grid">
            <input v-model="edit.trainNumber" aria-label="Train" />
            <input v-model="edit.from" aria-label="From" />
            <input v-model="edit.to" aria-label="To" />
            <input v-model="edit.travelDate" aria-label="Travel date" />
            <input v-model="edit.contactsName" aria-label="Passenger" />
            <select v-model.number="edit.status" aria-label="Status">
              <option v-for="(label, code) in ORDER_STATUS" :key="code" :value="Number(code)">
                {{ label }}
              </option>
            </select>
            <input v-model="edit.price" aria-label="Price" />
            <div class="actions">
              <button type="button" :disabled="busyId === o.id" @click="saveEdit">Save</button>
              <button type="button" class="ghost" @click="edit.editing = false">Cancel</button>
            </div>
          </div>
        </template>
        <template v-else>
          <div class="row-view">
            <div>
              <strong>{{ o.trainNumber }}</strong>
              <span class="badge">{{ statusLabel(o.status) }}</span>
              <p class="meta">
                {{ o.from }} → {{ o.to }} · {{ o.travelDate }} {{ o.travelTime }} ·
                {{ o.contactsName }} · ¥{{ o.price }} · {{ o.id }}
              </p>
            </div>
            <div class="actions">
              <button type="button" class="ghost" @click="startEdit(o)">Edit</button>
              <button type="button" class="danger" :disabled="busyId === o.id" @click="remove(o)">
                {{ busyId === o.id ? '…' : 'Delete' }}
              </button>
            </div>
          </div>
        </template>
      </li>
      <li v-if="!filtered.length && !loading" class="empty">No matching orders.</li>
    </ul>

    <h2>Add order</h2>
    <form class="form" @submit.prevent="add">
      <label>
        <span>Account</span>
        <select v-model="form.accountId">
          <option v-for="id in accountOptions" :key="id" :value="id">{{ id }}</option>
          <option value="4d2a46c7-71ce-4cf1-b5bb-b68406a1fd6a">
            4d2a46c7-71ce-4cf1-b5bb-b68406a1fd6a
          </option>
        </select>
      </label>
      <label>
        <span>Passenger</span>
        <input v-model="form.contactsName" required />
      </label>
      <label>
        <span>Train</span>
        <input v-model="form.trainNumber" required />
      </label>
      <label>
        <span>From</span>
        <input v-model="form.from" required />
      </label>
      <label>
        <span>To</span>
        <input v-model="form.to" required />
      </label>
      <label>
        <span>Travel date</span>
        <input v-model="form.travelDate" required />
      </label>
      <label>
        <span>Travel time</span>
        <input v-model="form.travelTime" required />
      </label>
      <label>
        <span>Status</span>
        <select v-model.number="form.status">
          <option v-for="(label, code) in ORDER_STATUS" :key="code" :value="Number(code)">
            {{ label }}
          </option>
        </select>
      </label>
      <label>
        <span>Price</span>
        <input v-model="form.price" required />
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
.filters {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
  align-items: end;
  margin-bottom: 0.5rem;
}
.filters .grow {
  flex: 1;
  min-width: 12rem;
}
.count {
  color: var(--muted);
  font-size: 0.875rem;
  margin: 0 0 0.35rem;
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
label {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  font-size: 0.85rem;
  font-weight: 600;
}
input,
select,
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

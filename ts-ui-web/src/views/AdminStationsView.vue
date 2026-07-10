<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import {
  createStation,
  deleteStation,
  listStations,
  updateStation,
} from '@/api/services'
import type { Station } from '@/api/types'
import { useAdminStore } from '@/stores/admin'

const admin = useAdminStore()
const router = useRouter()

const stations = ref<Station[]>([])
const loading = ref(false)
const busyId = ref('')
const error = ref('')
const ok = ref('')

const form = reactive({
  name: '',
  stayTime: 5,
})

const edit = reactive({
  id: '',
  name: '',
  stayTime: 5,
})

async function refresh() {
  loading.value = true
  error.value = ''
  try {
    const res = await listStations()
    stations.value = res.data ?? []
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load stations'
  } finally {
    loading.value = false
  }
}

async function add() {
  error.value = ''
  ok.value = ''
  try {
    const res = await createStation({
      name: form.name.trim(),
      stayTime: Number(form.stayTime),
    })
    if (res.status !== 1) throw new Error(res.msg ?? 'Create failed')
    form.name = ''
    form.stayTime = 5
    ok.value = `Added ${res.data.name}`
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Create failed'
  }
}

function startEdit(s: Station) {
  edit.id = s.id
  edit.name = s.name
  edit.stayTime = s.stayTime
}

async function saveEdit() {
  if (!edit.id) return
  busyId.value = edit.id
  error.value = ''
  ok.value = ''
  try {
    const res = await updateStation({
      id: edit.id,
      name: edit.name.trim(),
      stayTime: Number(edit.stayTime),
    })
    if (res.status !== 1) throw new Error(res.msg ?? 'Update failed')
    ok.value = `Updated ${res.data.name}`
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
    const res = await deleteStation(id)
    if (res.status !== 1) throw new Error(res.msg ?? 'Delete failed')
    ok.value = 'Station deleted'
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
        <h1>Stations</h1>
        <p class="lede">
          CRUD via <code>adminbasicservice/adminbasic/stations</code> · signed in as
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

    <p v-if="error" class="error" role="alert">{{ error }}</p>
    <p v-if="ok" class="ok" role="status">{{ ok }}</p>

    <h2>Station list</h2>
    <ul class="list" aria-live="polite">
      <li v-for="s in stations" :key="s.id" class="row">
        <template v-if="edit.id === s.id">
          <input v-model="edit.name" aria-label="Station name" />
          <input
            v-model.number="edit.stayTime"
            type="number"
            min="1"
            step="1"
            aria-label="Stay time"
          />
          <div class="actions">
            <button type="button" :disabled="busyId === s.id" @click="saveEdit">Save</button>
            <button type="button" class="ghost" @click="edit.id = ''">Cancel</button>
          </div>
        </template>
        <template v-else>
          <div>
            <strong>{{ s.name }}</strong>
            <p class="meta">Stay {{ s.stayTime }} min · {{ s.id }}</p>
          </div>
          <div class="actions">
            <button type="button" class="ghost" @click="startEdit(s)">Edit</button>
            <button
              type="button"
              class="danger"
              :disabled="busyId === s.id"
              @click="remove(s.id)"
            >
              {{ busyId === s.id ? '…' : 'Delete' }}
            </button>
          </div>
        </template>
      </li>
      <li v-if="!stations.length && !loading" class="empty">No stations yet.</li>
    </ul>

    <h2>Add station</h2>
    <form class="form" @submit.prevent="add">
      <label>
        <span>Name</span>
        <input v-model="form.name" required />
      </label>
      <label>
        <span>Stay time (min)</span>
        <input v-model.number="form.stayTime" type="number" min="1" step="1" required />
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
  max-width: 48ch;
}

.lede code,
.lede strong {
  color: var(--rail);
}

.head-actions,
.actions {
  display: flex;
  gap: 0.5rem;
  align-items: center;
  flex-wrap: wrap;
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
  display: grid;
  grid-template-columns: 1.4fr 0.6fr auto;
  gap: 0.75rem;
  align-items: center;
  padding: 0.9rem 0;
  border-bottom: 1px solid var(--line);
}

.form {
  display: grid;
  grid-template-columns: 1fr 160px auto;
  gap: 0.75rem;
  align-items: end;
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
  .row,
  .form {
    grid-template-columns: 1fr;
  }
}
</style>

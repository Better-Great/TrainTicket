<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import AdminNav from '@/components/AdminNav.vue'
import { deleteRoute, listRoutes, upsertRoute } from '@/api/services'
import type { Route } from '@/api/types'
import { useAdminStore } from '@/stores/admin'

const admin = useAdminStore()
const router = useRouter()

const routes = ref<Route[]>([])
const loading = ref(false)
const busyId = ref('')
const error = ref('')
const ok = ref('')

const form = reactive({
  stationList: 'Shang Hai,Su Zhou,Nan Jing',
  distanceList: '0,84,301',
  startStation: 'Shang Hai',
  endStation: 'Nan Jing',
})

const edit = reactive({
  id: '',
  stationList: '',
  distanceList: '',
  startStation: '',
  endStation: '',
})

function asLists(r: Route) {
  return {
    stationList: r.stations.join(','),
    distanceList: r.distances.join(','),
    startStation: r.startStation || r.startStationId || r.stations[0] || '',
    endStation: r.endStation || r.terminalStationId || r.stations[r.stations.length - 1] || '',
  }
}

async function refresh() {
  loading.value = true
  error.value = ''
  try {
    const res = await listRoutes()
    routes.value = res.data ?? []
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load routes'
  } finally {
    loading.value = false
  }
}

async function add() {
  error.value = ''
  ok.value = ''
  try {
    const res = await upsertRoute({ ...form })
    if (res.status !== 1) throw new Error(res.msg ?? 'Create failed')
    ok.value = `Saved route ${res.data.startStation} → ${res.data.endStation}`
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Create failed'
  }
}

function startEdit(r: Route) {
  const lists = asLists(r)
  edit.id = r.id
  edit.stationList = lists.stationList
  edit.distanceList = lists.distanceList
  edit.startStation = lists.startStation
  edit.endStation = lists.endStation
}

async function saveEdit() {
  if (!edit.id) return
  busyId.value = edit.id
  error.value = ''
  ok.value = ''
  try {
    const res = await upsertRoute({
      id: edit.id,
      stationList: edit.stationList,
      distanceList: edit.distanceList,
      startStation: edit.startStation,
      endStation: edit.endStation,
    })
    if (res.status !== 1) throw new Error(res.msg ?? 'Update failed')
    ok.value = `Updated ${res.data.id}`
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
    const res = await deleteRoute(id)
    if (res.status !== 1) throw new Error(res.msg ?? 'Delete failed')
    ok.value = 'Route deleted'
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
        <h1>Routes</h1>
        <p class="lede">
          CRUD via <code>adminrouteservice/adminroute</code> · signed in as
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

    <h2>Route list</h2>
    <ul class="list" aria-live="polite">
      <li v-for="r in routes" :key="r.id" class="row">
        <template v-if="edit.id === r.id">
          <div class="edit-grid">
          <label>
            <span>Stations (comma-separated)</span>
            <input v-model="edit.stationList" aria-label="Stations" />
          </label>
          <label>
            <span>Distances</span>
            <input v-model="edit.distanceList" aria-label="Distances" />
          </label>
          <label>
            <span>Start</span>
            <input v-model="edit.startStation" aria-label="Start station" />
          </label>
          <label>
            <span>End</span>
            <input v-model="edit.endStation" aria-label="End station" />
          </label>
          <div class="actions">
            <button type="button" :disabled="busyId === r.id" @click="saveEdit">Save</button>
            <button type="button" class="ghost" @click="edit.id = ''">Cancel</button>
          </div>
          </div>
        </template>
        <template v-else>
          <div class="row-view">
          <div>
            <strong>{{ r.startStation || r.startStationId }} → {{ r.endStation || r.terminalStationId }}</strong>
            <p class="meta">
              {{ r.stations.join(' · ') }} · km {{ r.distances.join('/') }} · {{ r.id }}
            </p>
          </div>
          <div class="actions">
            <button type="button" class="ghost" @click="startEdit(r)">Edit</button>
            <button
              type="button"
              class="danger"
              :disabled="busyId === r.id"
              @click="remove(r.id)"
            >
              {{ busyId === r.id ? '…' : 'Delete' }}
            </button>
          </div>
          </div>
        </template>
      </li>
      <li v-if="!routes.length && !loading" class="empty">No routes yet.</li>
    </ul>

    <h2>Add route</h2>
    <form class="form" @submit.prevent="add">
      <label>
        <span>Stations (comma-separated)</span>
        <input v-model="form.stationList" required placeholder="A,B,C" />
      </label>
      <label>
        <span>Distances (same count)</span>
        <input v-model="form.distanceList" required placeholder="0,100,250" />
      </label>
      <label>
        <span>Start station</span>
        <input v-model="form.startStation" required />
      </label>
      <label>
        <span>End station</span>
        <input v-model="form.endStation" required />
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
  padding: 0.9rem 0;
  border-bottom: 1px solid var(--line);
}

.row-view {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 0.65rem;
  align-items: center;
}

.edit-grid {
  display: grid;
  gap: 0.65rem;
}

.form {
  display: grid;
  gap: 0.75rem;
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

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import AdminNav from '@/components/AdminNav.vue'
import {
  createTravel,
  deleteTravel,
  listRoutes,
  listStations,
  listTrains,
  listTravels,
  updateTravel,
} from '@/api/services'
import type { TravelRecord, TravelUpsertRequest } from '@/api/types'
import { travelTripIdString } from '@/api/types'
import { useAdminStore } from '@/stores/admin'

const admin = useAdminStore()
const router = useRouter()

const travels = ref<TravelRecord[]>([])
const trainNames = ref<string[]>([])
const routeIds = ref<string[]>([])
const stationNames = ref<string[]>([])
const loading = ref(false)
const busyId = ref('')
const error = ref('')
const ok = ref('')

const form = reactive<TravelUpsertRequest>({
  tripId: 'G1890',
  trainTypeName: 'GaoTie',
  routeId: 'route-1',
  startStationName: 'Shang Hai',
  stationsName: 'Su Zhou',
  terminalStationName: 'Nan Jing',
  startTime: '2026-07-16 09:00:00',
  endTime: '2026-07-16 11:30:00',
})

const edit = reactive<TravelUpsertRequest & { editing: boolean }>({
  tripId: '',
  trainTypeName: '',
  routeId: '',
  startStationName: '',
  stationsName: '',
  terminalStationName: '',
  startTime: '',
  endTime: '',
  editing: false,
})

const trainOptions = computed(() =>
  trainNames.value.length ? trainNames.value : ['GaoTie', 'ZhiDa'],
)
const routeOptions = computed(() =>
  routeIds.value.length ? routeIds.value : ['route-1', 'route-2'],
)
const stationOptions = computed(() =>
  stationNames.value.length
    ? stationNames.value
    : ['Shang Hai', 'Su Zhou', 'Nan Jing', 'Hang Zhou'],
)

async function refresh() {
  loading.value = true
  error.value = ''
  try {
    const [travelRes, trainsRes, routesRes, stationsRes] = await Promise.all([
      listTravels(),
      listTrains(),
      listRoutes(),
      listStations(),
    ])
    travels.value = travelRes.data ?? []
    trainNames.value = (trainsRes.data ?? []).map((t) => t.name)
    routeIds.value = (routesRes.data ?? []).map((r) => r.id)
    stationNames.value = (stationsRes.data ?? []).map((s) => s.name)
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load travels'
  } finally {
    loading.value = false
  }
}

async function add() {
  error.value = ''
  ok.value = ''
  try {
    const res = await createTravel({ ...form })
    if (res.status !== 1) throw new Error(res.msg ?? 'Create failed')
    ok.value = `Added ${travelTripIdString(res.data.trip.tripId)}`
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Create failed'
  }
}

function startEdit(rec: TravelRecord) {
  const t = rec.trip
  edit.tripId = travelTripIdString(t.tripId)
  edit.trainTypeName = t.trainTypeName || t.trainTypeId || ''
  edit.routeId = t.routeId
  edit.startStationName = t.startStationName
  edit.stationsName = t.stationsName
  edit.terminalStationName = t.terminalStationName
  edit.startTime = t.startTime
  edit.endTime = t.endTime
  edit.editing = true
}

async function saveEdit() {
  if (!edit.editing) return
  busyId.value = edit.tripId
  error.value = ''
  ok.value = ''
  try {
    const { editing: _, ...body } = edit
    const res = await updateTravel(body)
    if (res.status !== 1) throw new Error(res.msg ?? 'Update failed')
    ok.value = `Updated ${edit.tripId}`
    edit.editing = false
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Update failed'
  } finally {
    busyId.value = ''
  }
}

async function remove(tripId: string) {
  busyId.value = tripId
  error.value = ''
  ok.value = ''
  try {
    const res = await deleteTravel(tripId)
    if (res.status !== 1) throw new Error(res.msg ?? 'Delete failed')
    ok.value = 'Travel deleted'
    if (edit.tripId === tripId) edit.editing = false
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
        <h1>Travels</h1>
        <p class="lede">
          CRUD via <code>admintravelservice/admintravel</code> ·
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

    <h2>Trips</h2>
    <ul class="list" aria-live="polite">
      <li v-for="rec in travels" :key="travelTripIdString(rec.trip.tripId)" class="row">
        <template v-if="edit.editing && edit.tripId === travelTripIdString(rec.trip.tripId)">
          <div class="edit-grid">
            <input :value="edit.tripId" disabled aria-label="Trip ID" />
            <select v-model="edit.trainTypeName" aria-label="Train type">
              <option v-for="n in trainOptions" :key="n" :value="n">{{ n }}</option>
            </select>
            <select v-model="edit.routeId" aria-label="Route">
              <option v-for="id in routeOptions" :key="id" :value="id">{{ id }}</option>
            </select>
            <select v-model="edit.startStationName" aria-label="Start">
              <option v-for="s in stationOptions" :key="'s' + s" :value="s">{{ s }}</option>
            </select>
            <select v-model="edit.stationsName" aria-label="Via">
              <option v-for="s in stationOptions" :key="'v' + s" :value="s">{{ s }}</option>
            </select>
            <select v-model="edit.terminalStationName" aria-label="End">
              <option v-for="s in stationOptions" :key="'e' + s" :value="s">{{ s }}</option>
            </select>
            <input v-model="edit.startTime" aria-label="Start time" />
            <input v-model="edit.endTime" aria-label="End time" />
            <div class="actions">
              <button
                type="button"
                :disabled="busyId === edit.tripId"
                @click="saveEdit"
              >
                Save
              </button>
              <button type="button" class="ghost" @click="edit.editing = false">Cancel</button>
            </div>
          </div>
        </template>
        <template v-else>
          <div class="row-view">
            <div>
              <strong>{{ travelTripIdString(rec.trip.tripId) }}</strong>
              <p class="meta">
                {{ rec.trip.trainTypeName || rec.trip.trainTypeId }} ·
                {{ rec.trip.startStationName }} → {{ rec.trip.terminalStationName }} ·
                {{ rec.trip.startTime }}–{{ rec.trip.endTime }} · route {{ rec.trip.routeId }}
              </p>
            </div>
            <div class="actions">
              <button type="button" class="ghost" @click="startEdit(rec)">Edit</button>
              <button
                type="button"
                class="danger"
                :disabled="busyId === travelTripIdString(rec.trip.tripId)"
                @click="remove(travelTripIdString(rec.trip.tripId))"
              >
                {{ busyId === travelTripIdString(rec.trip.tripId) ? '…' : 'Delete' }}
              </button>
            </div>
          </div>
        </template>
      </li>
      <li v-if="!travels.length && !loading" class="empty">No travels yet.</li>
    </ul>

    <h2>Add travel</h2>
    <form class="form" @submit.prevent="add">
      <label>
        <span>Trip ID</span>
        <input v-model="form.tripId" required placeholder="G1234" />
      </label>
      <label>
        <span>Train type</span>
        <select v-model="form.trainTypeName">
          <option v-for="n in trainOptions" :key="n" :value="n">{{ n }}</option>
        </select>
      </label>
      <label>
        <span>Route</span>
        <select v-model="form.routeId">
          <option v-for="id in routeOptions" :key="id" :value="id">{{ id }}</option>
        </select>
      </label>
      <label>
        <span>Start</span>
        <select v-model="form.startStationName">
          <option v-for="s in stationOptions" :key="'fs' + s" :value="s">{{ s }}</option>
        </select>
      </label>
      <label>
        <span>Via</span>
        <select v-model="form.stationsName">
          <option v-for="s in stationOptions" :key="'fv' + s" :value="s">{{ s }}</option>
        </select>
      </label>
      <label>
        <span>End</span>
        <select v-model="form.terminalStationName">
          <option v-for="s in stationOptions" :key="'fe' + s" :value="s">{{ s }}</option>
        </select>
      </label>
      <label>
        <span>Start time</span>
        <input v-model="form.startTime" required />
      </label>
      <label>
        <span>End time</span>
        <input v-model="form.endTime" required />
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

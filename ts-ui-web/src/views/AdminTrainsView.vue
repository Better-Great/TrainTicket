<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import AdminNav from '@/components/AdminNav.vue'
import { createTrain, deleteTrain, listTrains, updateTrain } from '@/api/services'
import type { TrainType } from '@/api/types'
import { useAdminStore } from '@/stores/admin'

const admin = useAdminStore()
const router = useRouter()

const trains = ref<TrainType[]>([])
const loading = ref(false)
const busyId = ref('')
const error = ref('')
const ok = ref('')

const form = reactive({
  name: '',
  economyClass: 200,
  confortClass: 100,
  averageSpeed: 250,
})

const edit = reactive({
  id: '',
  name: '',
  economyClass: 0,
  confortClass: 0,
  averageSpeed: 0,
})

async function refresh() {
  loading.value = true
  error.value = ''
  try {
    const res = await listTrains()
    trains.value = res.data ?? []
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load trains'
  } finally {
    loading.value = false
  }
}

async function add() {
  error.value = ''
  ok.value = ''
  try {
    const res = await createTrain({
      name: form.name.trim(),
      economyClass: Number(form.economyClass),
      confortClass: Number(form.confortClass),
      averageSpeed: Number(form.averageSpeed),
    })
    if (res.status !== 1) throw new Error(res.msg ?? 'Create failed')
    form.name = ''
    ok.value = `Added ${res.data.name}`
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Create failed'
  }
}

function startEdit(t: TrainType) {
  edit.id = t.id
  edit.name = t.name
  edit.economyClass = t.economyClass
  edit.confortClass = t.confortClass
  edit.averageSpeed = t.averageSpeed
}

async function saveEdit() {
  if (!edit.id) return
  busyId.value = edit.id
  error.value = ''
  ok.value = ''
  try {
    const res = await updateTrain({
      id: edit.id,
      name: edit.name.trim(),
      economyClass: Number(edit.economyClass),
      confortClass: Number(edit.confortClass),
      averageSpeed: Number(edit.averageSpeed),
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
    const res = await deleteTrain(id)
    if (res.status !== 1) throw new Error(res.msg ?? 'Delete failed')
    ok.value = 'Train deleted'
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
        <h1>Trains</h1>
        <p class="lede">
          CRUD via <code>adminbasicservice/adminbasic/trains</code> · signed in as
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

    <h2>Train types</h2>
    <ul class="list" aria-live="polite">
      <li v-for="t in trains" :key="t.id" class="row">
        <template v-if="edit.id === t.id">
          <div class="edit-grid">
            <input v-model="edit.name" aria-label="Train name" />
            <input
              v-model.number="edit.economyClass"
              type="number"
              min="1"
              aria-label="Economy seats"
            />
            <input
              v-model.number="edit.confortClass"
              type="number"
              min="1"
              aria-label="Comfort seats"
            />
            <input
              v-model.number="edit.averageSpeed"
              type="number"
              min="1"
              aria-label="Average speed"
            />
            <div class="actions">
              <button type="button" :disabled="busyId === t.id" @click="saveEdit">Save</button>
              <button type="button" class="ghost" @click="edit.id = ''">Cancel</button>
            </div>
          </div>
        </template>
        <template v-else>
          <div class="row-view">
            <div>
              <strong>{{ t.name }}</strong>
              <p class="meta">
                Economy {{ t.economyClass }} · Comfort {{ t.confortClass }} ·
                {{ t.averageSpeed }} km/h · {{ t.id }}
              </p>
            </div>
            <div class="actions">
              <button type="button" class="ghost" @click="startEdit(t)">Edit</button>
              <button
                type="button"
                class="danger"
                :disabled="busyId === t.id"
                @click="remove(t.id)"
              >
                {{ busyId === t.id ? '…' : 'Delete' }}
              </button>
            </div>
          </div>
        </template>
      </li>
      <li v-if="!trains.length && !loading" class="empty">No train types yet.</li>
    </ul>

    <h2>Add train type</h2>
    <form class="form" @submit.prevent="add">
      <label>
        <span>Name</span>
        <input v-model="form.name" required />
      </label>
      <label>
        <span>Economy seats</span>
        <input v-model.number="form.economyClass" type="number" min="1" required />
      </label>
      <label>
        <span>Comfort seats</span>
        <input v-model.number="form.confortClass" type="number" min="1" required />
      </label>
      <label>
        <span>Avg speed (km/h)</span>
        <input v-model.number="form.averageSpeed" type="number" min="1" required />
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
  grid-template-columns: 1.2fr repeat(3, 0.5fr) auto;
  gap: 0.65rem;
  align-items: center;
}

.form {
  display: grid;
  grid-template-columns: 1fr repeat(3, 110px) auto;
  gap: 0.75rem;
  align-items: end;
  max-width: 900px;
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

@media (max-width: 900px) {
  .row-view,
  .edit-grid,
  .form {
    grid-template-columns: 1fr;
  }
}
</style>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import AdminNav from '@/components/AdminNav.vue'
import { createConfig, deleteConfig, listConfigs, updateConfig } from '@/api/services'
import type { ConfigEntry } from '@/api/types'
import { useAdminStore } from '@/stores/admin'

const admin = useAdminStore()
const router = useRouter()

const configs = ref<ConfigEntry[]>([])
const loading = ref(false)
const busyName = ref('')
const error = ref('')
const ok = ref('')

const form = reactive({
  name: '',
  value: '',
  description: '',
})

const edit = reactive({
  name: '',
  value: '',
  description: '',
  editing: false,
})

async function refresh() {
  loading.value = true
  error.value = ''
  try {
    configs.value = (await listConfigs()).data ?? []
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load configs'
  } finally {
    loading.value = false
  }
}

async function add() {
  error.value = ''
  ok.value = ''
  try {
    const res = await createConfig({ ...form })
    if (res.status !== 1) throw new Error(res.msg ?? 'Create failed')
    form.name = ''
    form.value = ''
    form.description = ''
    ok.value = `Added ${res.data.name}`
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Create failed'
  }
}

function startEdit(c: ConfigEntry) {
  edit.name = c.name
  edit.value = c.value
  edit.description = c.description
  edit.editing = true
}

async function saveEdit() {
  if (!edit.editing) return
  busyName.value = edit.name
  error.value = ''
  ok.value = ''
  try {
    const res = await updateConfig({
      name: edit.name,
      value: edit.value,
      description: edit.description,
    })
    if (res.status !== 1) throw new Error(res.msg ?? 'Update failed')
    ok.value = `Updated ${res.data.name}`
    edit.editing = false
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Update failed'
  } finally {
    busyName.value = ''
  }
}

async function remove(name: string) {
  busyName.value = name
  error.value = ''
  ok.value = ''
  try {
    const res = await deleteConfig(name)
    if (res.status !== 1) throw new Error(res.msg ?? 'Delete failed')
    ok.value = 'Config deleted'
    if (edit.name === name) edit.editing = false
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Delete failed'
  } finally {
    busyName.value = ''
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
        <h1>Config</h1>
        <p class="lede">
          CRUD via <code>adminbasicservice/adminbasic/configs</code> ·
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

    <h2>Entries</h2>
    <ul class="list" aria-live="polite">
      <li v-for="c in configs" :key="c.name" class="row">
        <template v-if="edit.editing && edit.name === c.name">
          <div class="edit-grid">
            <input :value="edit.name" disabled aria-label="Config name" />
            <input v-model="edit.value" aria-label="Value" />
            <input v-model="edit.description" aria-label="Description" />
            <div class="actions">
              <button type="button" :disabled="busyName === c.name" @click="saveEdit">Save</button>
              <button type="button" class="ghost" @click="edit.editing = false">Cancel</button>
            </div>
          </div>
        </template>
        <template v-else>
          <div class="row-view">
            <div>
              <strong>{{ c.name }}</strong>
              <p class="meta">{{ c.value }} · {{ c.description || 'no description' }}</p>
            </div>
            <div class="actions">
              <button type="button" class="ghost" @click="startEdit(c)">Edit</button>
              <button
                type="button"
                class="danger"
                :disabled="busyName === c.name"
                @click="remove(c.name)"
              >
                {{ busyName === c.name ? '…' : 'Delete' }}
              </button>
            </div>
          </div>
        </template>
      </li>
      <li v-if="!configs.length && !loading" class="empty">No configs yet.</li>
    </ul>

    <h2>Add config</h2>
    <form class="form" @submit.prevent="add">
      <label>
        <span>Name</span>
        <input v-model="form.name" required />
      </label>
      <label>
        <span>Value</span>
        <input v-model="form.value" required />
      </label>
      <label>
        <span>Description</span>
        <input v-model="form.description" />
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

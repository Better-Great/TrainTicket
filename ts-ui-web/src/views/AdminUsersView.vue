<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import AdminNav from '@/components/AdminNav.vue'
import { createUser, deleteUser, listUsers, updateUser } from '@/api/services'
import type { AdminUser } from '@/api/types'
import { useAdminStore } from '@/stores/admin'

const admin = useAdminStore()
const router = useRouter()

const users = ref<AdminUser[]>([])
const loading = ref(false)
const busyId = ref('')
const error = ref('')
const ok = ref('')

const form = reactive({
  userName: '',
  password: '',
  gender: 1,
  email: '',
  documentType: 1,
  documentNum: '',
})

const edit = reactive({
  userId: '',
  userName: '',
  password: '',
  gender: 1 as number | string,
  email: '',
  documentType: 1 as number | string,
  documentNum: '',
})

async function refresh() {
  loading.value = true
  error.value = ''
  try {
    const res = await listUsers()
    users.value = res.data ?? []
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load users'
  } finally {
    loading.value = false
  }
}

async function add() {
  error.value = ''
  ok.value = ''
  try {
    const res = await createUser({ ...form })
    if (res.status !== 1) throw new Error(res.msg ?? 'Create failed')
    form.userName = ''
    form.password = ''
    form.email = ''
    form.documentNum = ''
    ok.value = `Added ${res.data.userName}`
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Create failed'
  }
}

function startEdit(u: AdminUser) {
  edit.userId = u.userId
  edit.userName = u.userName
  edit.password = u.password
  edit.gender = u.gender
  edit.email = u.email
  edit.documentType = u.documentType
  edit.documentNum = u.documentNum
}

async function saveEdit() {
  if (!edit.userId) return
  busyId.value = edit.userId
  error.value = ''
  ok.value = ''
  try {
    const res = await updateUser({ ...edit })
    if (res.status !== 1) throw new Error(res.msg ?? 'Update failed')
    ok.value = `Updated ${res.data.userName}`
    edit.userId = ''
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Update failed'
  } finally {
    busyId.value = ''
  }
}

async function remove(userId: string) {
  busyId.value = userId
  error.value = ''
  ok.value = ''
  try {
    const res = await deleteUser(userId)
    if (res.status !== 1) throw new Error(res.msg ?? 'Delete failed')
    ok.value = 'User deleted'
    if (edit.userId === userId) edit.userId = ''
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
        <h1>Users</h1>
        <p class="lede">
          CRUD via <code>adminuserservice/users</code> · signed in as
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

    <h2>Accounts</h2>
    <ul class="list" aria-live="polite">
      <li v-for="u in users" :key="u.userId" class="row">
        <template v-if="edit.userId === u.userId">
          <div class="edit-grid">
            <input v-model="edit.userName" aria-label="Username" />
            <input v-model="edit.password" type="password" aria-label="Password" />
            <select v-model.number="edit.gender" aria-label="Gender">
              <option :value="0">Other</option>
              <option :value="1">Male</option>
              <option :value="2">Female</option>
            </select>
            <input v-model="edit.email" type="email" aria-label="Email" />
            <select v-model.number="edit.documentType" aria-label="Document type">
              <option :value="1">ID card</option>
              <option :value="2">Passport</option>
              <option :value="3">Other</option>
            </select>
            <input v-model="edit.documentNum" aria-label="Document number" />
            <div class="actions">
              <button type="button" :disabled="busyId === u.userId" @click="saveEdit">Save</button>
              <button type="button" class="ghost" @click="edit.userId = ''">Cancel</button>
            </div>
          </div>
        </template>
        <template v-else>
          <div class="row-view">
            <div>
              <strong>{{ u.userName }}</strong>
              <p class="meta">
                {{ u.email || 'no email' }} · doc {{ u.documentType }}/{{ u.documentNum }} ·
                {{ u.userId }}
              </p>
            </div>
            <div class="actions">
              <button type="button" class="ghost" @click="startEdit(u)">Edit</button>
              <button
                type="button"
                class="danger"
                :disabled="busyId === u.userId"
                @click="remove(u.userId)"
              >
                {{ busyId === u.userId ? '…' : 'Delete' }}
              </button>
            </div>
          </div>
        </template>
      </li>
      <li v-if="!users.length && !loading" class="empty">No users yet.</li>
    </ul>

    <h2>Add user</h2>
    <form class="form" @submit.prevent="add">
      <label>
        <span>Username</span>
        <input v-model="form.userName" required autocomplete="off" />
      </label>
      <label>
        <span>Password</span>
        <input v-model="form.password" type="password" required autocomplete="new-password" />
      </label>
      <label>
        <span>Gender</span>
        <select v-model.number="form.gender">
          <option :value="0">Other</option>
          <option :value="1">Male</option>
          <option :value="2">Female</option>
        </select>
      </label>
      <label>
        <span>Email</span>
        <input v-model="form.email" type="email" />
      </label>
      <label>
        <span>Document type</span>
        <select v-model.number="form.documentType">
          <option :value="1">ID card</option>
          <option :value="2">Passport</option>
          <option :value="3">Other</option>
        </select>
      </label>
      <label>
        <span>Document number</span>
        <input v-model="form.documentNum" />
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

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import AdminNav from '@/components/AdminNav.vue'
import {
  createAdminContact,
  deleteAdminContact,
  listAdminContacts,
  updateAdminContact,
} from '@/api/services'
import type { Contact } from '@/api/types'
import { useAdminStore } from '@/stores/admin'

const admin = useAdminStore()
const router = useRouter()

const contacts = ref<Contact[]>([])
const loading = ref(false)
const busyId = ref('')
const error = ref('')
const ok = ref('')

const form = reactive({
  accountId: '4d2a46c7-71ce-4cf1-b5bb-b68406a1fd6a',
  name: '',
  documentType: 1,
  documentNumber: '',
  phoneNumber: '',
})

const edit = reactive({
  id: '',
  accountId: '',
  name: '',
  documentType: 1,
  documentNumber: '',
  phoneNumber: '',
})

async function refresh() {
  loading.value = true
  error.value = ''
  try {
    contacts.value = (await listAdminContacts()).data ?? []
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load contacts'
  } finally {
    loading.value = false
  }
}

async function add() {
  error.value = ''
  ok.value = ''
  try {
    const res = await createAdminContact({ ...form })
    if (res.status !== 1) throw new Error(res.msg ?? 'Create failed')
    form.name = ''
    form.documentNumber = ''
    form.phoneNumber = ''
    ok.value = `Added ${res.data.name}`
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Create failed'
  }
}

function startEdit(c: Contact) {
  edit.id = c.id
  edit.accountId = c.accountId ?? ''
  edit.name = c.name
  edit.documentType = c.documentType
  edit.documentNumber = c.documentNumber
  edit.phoneNumber = c.phoneNumber
}

async function saveEdit() {
  if (!edit.id) return
  busyId.value = edit.id
  error.value = ''
  ok.value = ''
  try {
    const res = await updateAdminContact({
      id: edit.id,
      accountId: edit.accountId || undefined,
      name: edit.name,
      documentType: Number(edit.documentType),
      documentNumber: edit.documentNumber,
      phoneNumber: edit.phoneNumber,
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
    const res = await deleteAdminContact(id)
    if (res.status !== 1) throw new Error(res.msg ?? 'Delete failed')
    ok.value = 'Contact deleted'
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
        <h1>Contacts</h1>
        <p class="lede">
          CRUD via <code>adminbasicservice/adminbasic/contacts</code> ·
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

    <h2>All contacts</h2>
    <ul class="list" aria-live="polite">
      <li v-for="c in contacts" :key="c.id" class="row">
        <template v-if="edit.id === c.id">
          <div class="edit-grid">
            <input v-model="edit.name" aria-label="Name" />
            <select v-model.number="edit.documentType" aria-label="Document type">
              <option :value="1">ID card</option>
              <option :value="2">Passport</option>
              <option :value="3">Other</option>
            </select>
            <input v-model="edit.documentNumber" aria-label="Document number" />
            <input v-model="edit.phoneNumber" aria-label="Phone" />
            <div class="actions">
              <button type="button" :disabled="busyId === c.id" @click="saveEdit">Save</button>
              <button type="button" class="ghost" @click="edit.id = ''">Cancel</button>
            </div>
          </div>
        </template>
        <template v-else>
          <div class="row-view">
            <div>
              <strong>{{ c.name }}</strong>
              <p class="meta">
                Doc {{ c.documentType }}/{{ c.documentNumber }} · {{ c.phoneNumber }}
                <span v-if="c.accountId"> · acct {{ c.accountId }}</span>
                · {{ c.id }}
              </p>
            </div>
            <div class="actions">
              <button type="button" class="ghost" @click="startEdit(c)">Edit</button>
              <button type="button" class="danger" :disabled="busyId === c.id" @click="remove(c.id)">
                {{ busyId === c.id ? '…' : 'Delete' }}
              </button>
            </div>
          </div>
        </template>
      </li>
      <li v-if="!contacts.length && !loading" class="empty">No contacts yet.</li>
    </ul>

    <h2>Add contact</h2>
    <form class="form" @submit.prevent="add">
      <label>
        <span>Account ID</span>
        <input v-model="form.accountId" required />
      </label>
      <label>
        <span>Name</span>
        <input v-model="form.name" required />
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
        <input v-model="form.documentNumber" required />
      </label>
      <label>
        <span>Phone</span>
        <input v-model="form.phoneNumber" required />
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

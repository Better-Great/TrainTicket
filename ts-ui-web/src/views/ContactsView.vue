<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { createContact, listContacts } from '@/api/services'
import type { Contact } from '@/api/types'
import { useAuthStore } from '@/stores/auth'
import { documentTypeLabel } from '@/utils/format'

const auth = useAuthStore()
const contacts = ref<Contact[]>([])
const loading = ref(false)
const error = ref('')
const form = reactive({
  name: '',
  documentType: 1,
  documentNumber: '',
  phoneNumber: '',
})

async function refresh() {
  loading.value = true
  error.value = ''
  try {
    const res = await listContacts(auth.userId)
    contacts.value = res.data ?? []
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load contacts'
  } finally {
    loading.value = false
  }
}

async function add() {
  error.value = ''
  try {
    await createContact({ ...form, accountId: auth.userId })
    form.name = ''
    form.documentNumber = ''
    form.phoneNumber = ''
    form.documentType = 1
    await refresh()
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Could not save contact'
  }
}

onMounted(() => {
  void refresh()
})
</script>

<template>
  <section class="page">
    <p class="eyebrow">Account</p>
    <h1>Passengers</h1>
    <p class="lede">Contacts used when booking — synced with <code>contactservice</code>.</p>

    <p v-if="error" class="error" role="alert">{{ error }}</p>

    <ul class="list" aria-live="polite">
      <li v-for="c in contacts" :key="c.id">
        <strong>{{ c.name }}</strong>
        <p>
          {{ documentTypeLabel(c.documentType) }} · {{ c.documentNumber }} · {{ c.phoneNumber }}
        </p>
      </li>
      <li v-if="!contacts.length && !loading" class="empty">No passengers yet.</li>
    </ul>

    <h2>Add passenger</h2>
    <form class="form" @submit.prevent="add">
      <label>
        <span>Name</span>
        <input v-model="form.name" required />
      </label>
      <label>
        <span>Document type</span>
        <select v-model.number="form.documentType">
          <option :value="1">ID Card</option>
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
      <button type="submit">Save passenger</button>
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
  margin: 1.75rem 0 0.75rem;
}

.lede {
  color: var(--muted);
  margin-bottom: 1.25rem;
}

.lede code {
  color: var(--rail);
}

.list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.list li {
  padding: 0.9rem 0;
  border-bottom: 1px solid var(--line);
}

.list p,
.empty {
  color: var(--muted);
  font-size: 0.9rem;
}

.form {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.75rem;
  max-width: 640px;
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
  padding: 0.7rem 0.75rem;
}

button {
  grid-column: 1 / -1;
  background: var(--ink);
  color: var(--paper);
  border-color: var(--ink);
  font-weight: 700;
  cursor: pointer;
}

.error {
  color: var(--danger);
}

@media (max-width: 640px) {
  .form {
    grid-template-columns: 1fr;
  }
}
</style>

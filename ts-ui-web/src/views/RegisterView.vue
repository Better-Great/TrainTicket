<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { register } from '@/api/services'

const router = useRouter()
const error = ref('')
const loading = ref(false)
const form = reactive({
  userName: '',
  password: '',
  email: '',
  documentNum: '',
  gender: 1,
  documentType: 1,
})

async function submit() {
  loading.value = true
  error.value = ''
  try {
    await register({ ...form })
    router.push({ name: 'login' })
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Registration failed'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <section class="page">
    <div class="panel">
      <p class="eyebrow">Account</p>
      <h1>Create account</h1>
      <p class="lede">Register with the same user-service contract as the legacy UI.</p>

      <form class="form" @submit.prevent="submit">
        <label>
          <span>Username</span>
          <input v-model="form.userName" required />
        </label>
        <label>
          <span>Password</span>
          <input v-model="form.password" type="password" required minlength="6" />
        </label>
        <label>
          <span>Email</span>
          <input v-model="form.email" type="email" required />
        </label>
        <label>
          <span>Document number</span>
          <input v-model="form.documentNum" required />
        </label>
        <div class="row">
          <label>
            <span>Gender</span>
            <select v-model.number="form.gender">
              <option :value="1">Male</option>
              <option :value="0">Female</option>
            </select>
          </label>
          <label>
            <span>Document type</span>
            <select v-model.number="form.documentType">
              <option :value="1">ID Card</option>
              <option :value="2">Passport</option>
              <option :value="3">Other</option>
            </select>
          </label>
        </div>

        <p v-if="error" class="error" role="alert">{{ error }}</p>
        <button class="submit" type="submit" :disabled="loading">
          {{ loading ? 'Creating…' : 'Create account' }}
        </button>
      </form>
    </div>
  </section>
</template>

<style scoped>
.page {
  flex: 1;
  display: grid;
  place-items: center;
  padding: 2rem 1.25rem 3rem;
}

.panel {
  width: min(480px, 100%);
}

.eyebrow {
  text-transform: uppercase;
  letter-spacing: 0.12em;
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--rail);
  margin-bottom: 0.5rem;
}

h1 {
  font-size: clamp(2rem, 4vw, 2.5rem);
  margin-bottom: 0.5rem;
}

.lede {
  color: var(--muted);
  margin-bottom: 1.5rem;
}

.form {
  display: flex;
  flex-direction: column;
  gap: 0.9rem;
}

label {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  font-size: 0.875rem;
  font-weight: 600;
}

input,
select {
  border: 1px solid var(--line);
  background: white;
  padding: 0.7rem 0.8rem;
}

.row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.75rem;
}

.submit {
  background: var(--ink);
  color: var(--paper);
  border: none;
  padding: 0.85rem 1rem;
  font-weight: 700;
  cursor: pointer;
}

.error {
  color: var(--danger);
  font-size: 0.875rem;
}
</style>

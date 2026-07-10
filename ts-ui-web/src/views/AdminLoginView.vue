<script setup lang="ts">
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { captchaUrl } from '@/api/services'
import { useAdminStore } from '@/stores/admin'

const admin = useAdminStore()
const router = useRouter()
const route = useRoute()

const username = ref('')
const password = ref('')
const verificationCode = ref('')
const captcha = ref(captchaUrl())

function refreshCaptcha() {
  captcha.value = captchaUrl()
}

async function submit() {
  const ok = await admin.login({
    username: username.value.trim(),
    password: password.value,
    verificationCode: verificationCode.value.trim(),
  })
  if (ok) {
    const redirect =
      typeof route.query.redirect === 'string' ? route.query.redirect : '/admin/stations'
    router.push(redirect)
  } else {
    refreshCaptcha()
  }
}
</script>

<template>
  <section class="page">
    <div class="panel">
      <p class="eyebrow">Operations</p>
      <h1>Admin sign in</h1>
      <p class="lede">Manage stations and other admin resources. Separate session from client login.</p>

      <form class="form" @submit.prevent="submit">
        <label>
          <span>Username</span>
          <input v-model="username" autocomplete="username" required />
        </label>
        <label>
          <span>Password</span>
          <input v-model="password" type="password" autocomplete="current-password" required />
        </label>
        <div class="captcha-row">
          <label class="grow">
            <span>Captcha</span>
            <input v-model="verificationCode" required maxlength="8" />
          </label>
          <button type="button" class="captcha" aria-label="Refresh captcha" @click="refreshCaptcha">
            <img :src="captcha" alt="Captcha" width="120" height="40" />
          </button>
        </div>
        <p v-if="admin.error" class="error" role="alert">{{ admin.error }}</p>
        <button class="submit" type="submit" :disabled="admin.loading">
          {{ admin.loading ? 'Signing in…' : 'Enter admin' }}
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
  background:
    radial-gradient(ellipse 70% 45% at 90% 0%, rgba(232, 163, 23, 0.12), transparent),
    var(--paper);
}

.panel {
  width: min(420px, 100%);
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
  gap: 1rem;
}

label {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  font-size: 0.875rem;
  font-weight: 600;
}

input {
  border: 1px solid var(--line);
  background: white;
  padding: 0.7rem 0.8rem;
}

.captcha-row {
  display: flex;
  gap: 0.75rem;
  align-items: end;
}

.grow {
  flex: 1;
}

.captcha {
  border: 1px solid var(--line);
  background: white;
  padding: 0;
  height: 42px;
  cursor: pointer;
}

.submit {
  background: var(--rail);
  color: white;
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

<script setup lang="ts">
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { captchaUrl } from '@/api/services'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
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
  const ok = await auth.login({
    username: username.value.trim(),
    password: password.value,
    verificationCode: verificationCode.value.trim(),
  })
  if (ok) {
    const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : '/search'
    router.push(redirect)
  } else {
    refreshCaptcha()
  }
}
</script>

<template>
  <section class="page">
    <div class="panel">
      <p class="eyebrow">Account</p>
      <h1>Sign in</h1>
      <p class="lede">Continue to search, book, and manage tickets.</p>

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
          <button type="button" class="captcha" @click="refreshCaptcha" aria-label="Refresh captcha">
            <img :src="captcha" alt="Captcha" width="120" height="40" />
          </button>
        </div>

        <p v-if="auth.error" class="error" role="alert">{{ auth.error }}</p>

        <button class="submit" type="submit" :disabled="auth.loading">
          {{ auth.loading ? 'Signing in…' : 'Sign in' }}
        </button>
      </form>

      <p class="foot">
        New here?
        <RouterLink to="/register">Create an account</RouterLink>
      </p>
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
    radial-gradient(ellipse 80% 50% at 10% 0%, rgba(30, 77, 107, 0.12), transparent),
    var(--paper);
}

.panel {
  width: min(420px, 100%);
  animation: in 0.5s ease both;
}

@keyframes in {
  from {
    opacity: 0;
    transform: translateY(12px);
  }
  to {
    opacity: 1;
    transform: none;
  }
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
  font-size: clamp(2rem, 4vw, 2.6rem);
  margin-bottom: 0.5rem;
}

.lede {
  color: var(--muted);
  margin-bottom: 1.75rem;
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
  color: var(--ink);
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
  cursor: pointer;
  height: 42px;
}

.captcha img {
  display: block;
}

.submit {
  margin-top: 0.5rem;
  background: var(--ink);
  color: var(--paper);
  border: none;
  padding: 0.85rem 1rem;
  font-weight: 700;
  cursor: pointer;
}

.submit:disabled {
  opacity: 0.6;
  cursor: wait;
}

.error {
  color: var(--danger);
  font-size: 0.875rem;
}

.foot {
  margin-top: 1.25rem;
  color: var(--muted);
  font-size: 0.9rem;
}

.foot a {
  color: var(--rail);
  font-weight: 700;
}
</style>

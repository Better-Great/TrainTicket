import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { login as loginApi } from '@/api/services'
import type { LoginRequest } from '@/api/types'

const TOKEN_KEY = 'client_token'
const ID_KEY = 'client_id'
const NAME_KEY = 'client_name'

export const useAuthStore = defineStore('auth', () => {
  const token = ref(sessionStorage.getItem(TOKEN_KEY) ?? '')
  const userId = ref(sessionStorage.getItem(ID_KEY) ?? '')
  const username = ref(sessionStorage.getItem(NAME_KEY) ?? '')
  const error = ref('')
  const loading = ref(false)

  const isAuthenticated = computed(() => {
    return Boolean(token.value && token.value !== '-1' && username.value && username.value !== 'Not Login')
  })

  function persist(next: { token: string; userId: string; username: string }) {
    token.value = next.token
    userId.value = next.userId
    username.value = next.username
    sessionStorage.setItem(TOKEN_KEY, next.token)
    sessionStorage.setItem(ID_KEY, next.userId)
    sessionStorage.setItem(NAME_KEY, next.username)
  }

  async function login(payload: LoginRequest) {
    loading.value = true
    error.value = ''
    try {
      const res = await loginApi(payload)
      if (res.status !== 1 || !res.data?.token) {
        throw new Error(res.msg ?? res.message ?? 'Login failed')
      }
      persist({
        token: res.data.token,
        userId: res.data.userId,
        username: res.data.username,
      })
      return true
    } catch (e) {
      error.value = e instanceof Error ? e.message : 'Login failed'
      persist({ token: '-1', userId: '', username: 'Not Login' })
      return false
    } finally {
      loading.value = false
    }
  }

  function logout() {
    persist({ token: '-1', userId: '', username: 'Not Login' })
    error.value = ''
  }

  return {
    token,
    userId,
    username,
    error,
    loading,
    isAuthenticated,
    login,
    logout,
  }
})

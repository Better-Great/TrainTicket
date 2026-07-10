import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { login as loginApi } from '@/api/services'
import type { LoginRequest } from '@/api/types'

const TOKEN_KEY = 'admin_token'
const NAME_KEY = 'admin_name'

export const useAdminStore = defineStore('admin', () => {
  const token = ref(sessionStorage.getItem(TOKEN_KEY) ?? '')
  const username = ref(sessionStorage.getItem(NAME_KEY) ?? '')
  const error = ref('')
  const loading = ref(false)

  const isAdmin = computed(() => Boolean(token.value && token.value !== '-1' && username.value))

  function persist(next: { token: string; username: string }) {
    token.value = next.token
    username.value = next.username
    sessionStorage.setItem(TOKEN_KEY, next.token)
    sessionStorage.setItem(NAME_KEY, next.username)
  }

  async function login(payload: LoginRequest) {
    loading.value = true
    error.value = ''
    try {
      const res = await loginApi(payload)
      if (res.status !== 1 || !res.data?.token) {
        throw new Error(res.msg ?? res.message ?? 'Admin login failed')
      }
      persist({ token: res.data.token, username: res.data.username })
      return true
    } catch (e) {
      error.value = e instanceof Error ? e.message : 'Admin login failed'
      persist({ token: '-1', username: '' })
      return false
    } finally {
      loading.value = false
    }
  }

  function logout() {
    persist({ token: '-1', username: '' })
    error.value = ''
  }

  return { token, username, error, loading, isAdmin, login, logout }
})

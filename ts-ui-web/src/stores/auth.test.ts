import { beforeEach, describe, expect, it } from 'vitest'
import { createPinia, setActivePinia } from 'pinia'
import { resetMockState } from '@/api/mock'
import { useAuthStore } from '@/stores/auth'

describe('useAuthStore', () => {
  beforeEach(() => {
    sessionStorage.clear()
    resetMockState()
    setActivePinia(createPinia())
  })

  it('logs in with mock API and persists session', async () => {
    const auth = useAuthStore()
    const ok = await auth.login({
      username: 'traveler',
      password: 'secret',
      verificationCode: '1234',
    })
    expect(ok).toBe(true)
    expect(auth.isAuthenticated).toBe(true)
    expect(auth.username).toBe('traveler')
    expect(sessionStorage.getItem('client_token')).toBe('mock-jwt-token')
  })

  it('rejects empty captcha via mock failure path', async () => {
    const auth = useAuthStore()
    const ok = await auth.login({
      username: 'traveler',
      password: 'secret',
      verificationCode: '',
    })
    expect(ok).toBe(false)
    expect(auth.isAuthenticated).toBe(false)
  })

  it('clears session on logout', async () => {
    const auth = useAuthStore()
    await auth.login({
      username: 'traveler',
      password: 'secret',
      verificationCode: '1234',
    })
    auth.logout()
    expect(auth.isAuthenticated).toBe(false)
    expect(sessionStorage.getItem('client_name')).toBe('Not Login')
  })
})

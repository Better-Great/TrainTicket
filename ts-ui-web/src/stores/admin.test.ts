import { beforeEach, describe, expect, it } from 'vitest'
import { createPinia, setActivePinia } from 'pinia'
import { resetMockState } from '@/api/mock'
import { useAdminStore } from '@/stores/admin'

describe('useAdminStore', () => {
  beforeEach(() => {
    sessionStorage.clear()
    resetMockState()
    setActivePinia(createPinia())
  })

  it('logs in to admin session keys', async () => {
    const admin = useAdminStore()
    const ok = await admin.login({
      username: 'admin',
      password: 'secret',
      verificationCode: '1234',
    })
    expect(ok).toBe(true)
    expect(admin.isAdmin).toBe(true)
    expect(sessionStorage.getItem('admin_token')).toBe('mock-jwt-token')
    expect(sessionStorage.getItem('admin_name')).toBe('admin')
  })

  it('clears admin session on logout', async () => {
    const admin = useAdminStore()
    await admin.login({
      username: 'admin',
      password: 'secret',
      verificationCode: '1234',
    })
    admin.logout()
    expect(admin.isAdmin).toBe(false)
    expect(sessionStorage.getItem('admin_token')).toBe('-1')
  })
})

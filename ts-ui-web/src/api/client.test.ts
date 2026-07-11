import { describe, expect, it } from 'vitest'
import { ApiError, apiRequest } from '@/api/client'

describe('api client', () => {
  it('constructs ApiError with status and body', () => {
    const err = new ApiError('boom', 503, { detail: 'down' })
    expect(err.name).toBe('ApiError')
    expect(err.status).toBe(503)
    expect(err.body).toEqual({ detail: 'down' })
  })

  it('apiRequest throws ApiError on HTTP failure', async () => {
    const original = globalThis.fetch
    globalThis.fetch = (async () =>
      new Response(JSON.stringify({ status: 0, msg: 'Nope' }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      })) as typeof fetch

    await expect(apiRequest('/api/v1/x')).rejects.toBeInstanceOf(ApiError)
    globalThis.fetch = original
  })

  it('apiRequest throws when business status is not 1', async () => {
    const original = globalThis.fetch
    globalThis.fetch = (async () =>
      new Response(JSON.stringify({ status: 0, msg: 'Denied', data: null }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      })) as typeof fetch

    await expect(apiRequest('/api/v1/y')).rejects.toMatchObject({ message: 'Denied' })
    globalThis.fetch = original
  })
})

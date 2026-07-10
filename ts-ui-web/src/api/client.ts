import type { ApiResponse } from './types'

const USE_MOCK = import.meta.env.VITE_USE_MOCK === 'true'

export function isMockMode(): boolean {
  return USE_MOCK
}

export class ApiError extends Error {
  status: number
  body?: unknown

  constructor(message: string, status = 0, body?: unknown) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.body = body
  }
}

function authHeader(): HeadersInit {
  const token = sessionStorage.getItem('client_token')
  if (!token || token === '-1') return {}
  return { Authorization: `Bearer ${token}` }
}

export async function apiRequest<T>(
  path: string,
  init: RequestInit = {},
): Promise<ApiResponse<T>> {
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...authHeader(),
    ...(init.headers ?? {}),
  }

  const res = await fetch(path, {
    ...init,
    headers,
    credentials: 'include',
  })

  let body: ApiResponse<T> | undefined
  try {
    body = (await res.json()) as ApiResponse<T>
  } catch {
    body = undefined
  }

  if (!res.ok) {
    throw new ApiError(body?.msg ?? body?.message ?? `HTTP ${res.status}`, res.status, body)
  }

  if (body && typeof body.status === 'number' && body.status !== 1) {
    throw new ApiError(body.msg ?? body.message ?? 'Request failed', body.status, body)
  }

  return body as ApiResponse<T>
}

export async function apiGet<T>(path: string): Promise<ApiResponse<T>> {
  return apiRequest<T>(path, { method: 'GET' })
}

export async function apiPost<T>(path: string, data?: unknown): Promise<ApiResponse<T>> {
  return apiRequest<T>(path, {
    method: 'POST',
    body: data === undefined ? undefined : JSON.stringify(data),
  })
}

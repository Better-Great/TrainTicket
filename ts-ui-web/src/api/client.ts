import type { ApiResponse } from './types'

const USE_MOCK = import.meta.env.VITE_USE_MOCK === 'true'

export function isMockMode(): boolean {
  return USE_MOCK
}

export type AuthRole = 'client' | 'admin'

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

function authHeader(role: AuthRole = 'client'): HeadersInit {
  const key = role === 'admin' ? 'admin_token' : 'client_token'
  const token = sessionStorage.getItem(key)
  if (!token || token === '-1') return {}
  return { Authorization: `Bearer ${token}` }
}

export async function apiRequest<T>(
  path: string,
  init: RequestInit = {},
  role: AuthRole = 'client',
): Promise<ApiResponse<T>> {
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...authHeader(role),
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

export async function apiGet<T>(path: string, role: AuthRole = 'client'): Promise<ApiResponse<T>> {
  return apiRequest<T>(path, { method: 'GET' }, role)
}

export async function apiPost<T>(
  path: string,
  data?: unknown,
  role: AuthRole = 'client',
): Promise<ApiResponse<T>> {
  return apiRequest<T>(
    path,
    {
      method: 'POST',
      body: data === undefined ? undefined : JSON.stringify(data),
    },
    role,
  )
}

export async function apiPut<T>(
  path: string,
  data?: unknown,
  role: AuthRole = 'admin',
): Promise<ApiResponse<T>> {
  return apiRequest<T>(
    path,
    {
      method: 'PUT',
      body: data === undefined ? undefined : JSON.stringify(data),
    },
    role,
  )
}

export async function apiDelete<T>(path: string, role: AuthRole = 'admin'): Promise<ApiResponse<T>> {
  return apiRequest<T>(path, { method: 'DELETE' }, role)
}

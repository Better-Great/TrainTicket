import { apiDelete, apiGet, apiPost, apiPut, isMockMode } from './client'
import { mockApi } from './mock'
import type {
  Contact,
  LoginData,
  LoginRequest,
  Order,
  PreserveRequest,
  RegisterRequest,
  TravelQuery,
  Trip,
  WaitListCreateRequest,
  WaitListOrder,
  OfficeProvince,
  SpecificOfficesQuery,
  TicketOffice,
  Station,
  NewsItem,
  Route,
  RouteUpsertRequest,
  TrainType,
  AdminUser,
  AdminUserCreate,
} from './types'

export function captchaUrl(): string {
  if (isMockMode()) {
    return `data:image/svg+xml,${encodeURIComponent(
      `<svg xmlns="http://www.w3.org/2000/svg" width="120" height="40"><rect fill="#e8eef2" width="120" height="40"/><text x="20" y="26" font-family="monospace" font-size="18" fill="#0e2433">1234</text></svg>`,
    )}`
  }
  return `/api/v1/verifycode/generate?${Date.now()}`
}

export async function login(body: LoginRequest) {
  if (isMockMode()) return mockApi.login(body)
  return apiPost<LoginData>('/api/v1/users/login', body)
}

export async function register(body: RegisterRequest) {
  if (isMockMode()) return mockApi.register(body)
  return apiPost('/api/v1/userservice/users/register', body)
}

function normalizeTrip(raw: Trip): Trip & { id: string } {
  const id =
    typeof raw.tripId === 'string'
      ? raw.tripId
      : `${raw.tripId.type}${raw.tripId.number}`
  return { ...raw, id }
}

export async function searchTrips(
  query: TravelQuery,
  trainType: 0 | 1 | 2 = 0,
): Promise<(Trip & { id: string })[]> {
  if (isMockMode()) {
    const mode = trainType === 0 ? 'all' : trainType === 1 ? 'gd' : 'other'
    const trips = await mockApi.searchTrips(query, mode)
    return trips.map(normalizeTrip)
  }

  const paths: string[] = []
  if (trainType === 0 || trainType === 1) paths.push('/api/v1/travelservice/trips/left')
  if (trainType === 0 || trainType === 2) paths.push('/api/v1/travel2service/trips/left')

  const results = await Promise.all(
    paths.map(async (path) => {
      try {
        const res = await apiPost<Trip[]>(path, query)
        return (res.data ?? []).map(normalizeTrip)
      } catch {
        return []
      }
    }),
  )
  return results.flat()
}

export async function advancedSearch(
  query: TravelQuery,
  strategy: 'cheapest' | 'quickest' | 'minStation',
): Promise<(Trip & { id: string; strategy: string })[]> {
  if (isMockMode()) {
    const trips = await mockApi.searchTrips(query, 'all')
    const ranked = [...trips].map(normalizeTrip)
    if (strategy === 'cheapest') {
      ranked.sort(
        (a, b) => Number(a.priceForEconomyClass) - Number(b.priceForEconomyClass),
      )
    } else if (strategy === 'quickest') {
      ranked.sort((a, b) => String(a.startTime).localeCompare(String(b.startTime)))
    } else {
      ranked.reverse()
    }
    return ranked.map((t) => ({ ...t, strategy }))
  }

  const path =
    strategy === 'cheapest'
      ? '/api/v1/travelplanservice/travelPlan/cheapest'
      : strategy === 'quickest'
        ? '/api/v1/travelplanservice/travelPlan/quickest'
        : '/api/v1/travelplanservice/travelPlan/minStation'
  const res = await apiPost<Trip[]>(path, query)
  return (res.data ?? []).map((t) => ({ ...normalizeTrip(t), strategy }))
}

export async function listContacts(accountId: string) {
  if (isMockMode()) return mockApi.contacts(accountId)
  return apiGet<Contact[]>(`/api/v1/contactservice/contacts/account/${accountId}`)
}

export async function createContact(contact: Omit<Contact, 'id'> & { accountId: string }) {
  if (isMockMode()) return mockApi.createContact(contact)
  return apiPost<Contact>('/api/v1/contactservice/contacts', contact)
}

export async function preserveTicket(body: PreserveRequest) {
  if (isMockMode()) return mockApi.preserve(body)
  const highSpeed = /^[GD]/.test(body.tripId)
  const path = highSpeed
    ? '/api/v1/preserveservice/preserve'
    : '/api/v1/preserveotherservice/preserveOther'
  return apiPost<{ orderId?: string }>(path, body)
}

export async function listOrders(accountId: string) {
  if (isMockMode()) return mockApi.orders(accountId)
  const body = {
    loginId: accountId,
    enableStateQuery: false,
    enableTravelDateQuery: false,
    enableBoughtDateQuery: false,
  }
  const [a, b] = await Promise.all([
    apiPost<Order[]>('/api/v1/orderservice/order/refresh', body).catch(() => ({
      status: 1,
      data: [] as Order[],
    })),
    apiPost<Order[]>('/api/v1/orderOtherService/orderOther/refresh', body).catch(() => ({
      status: 1,
      data: [] as Order[],
    })),
  ])
  return { status: 1 as const, data: [...(a.data ?? []), ...(b.data ?? [])] }
}

export async function payOrder(orderId: string, tripId: string) {
  if (isMockMode()) return mockApi.pay(orderId)
  return apiPost('/api/v1/inside_pay_service/inside_payment', {
    orderId,
    tripId,
  })
}

export async function getWallet(userId: string) {
  if (isMockMode()) return mockApi.getWallet()
  return apiGet<{ balance: number }>(`/api/v1/inside_pay_service/account/${userId}`)
}

export async function topUpWallet(userId: string, money: string) {
  if (isMockMode()) return mockApi.topUp(Number(money))
  return apiPost<{ balance: number }>('/api/v1/inside_pay_service/drawback', {
    userId,
    money,
  })
}

export async function collectTicket(orderId: string) {
  if (isMockMode()) return mockApi.collect(orderId)
  return apiGet(`/api/v1/executeservice/execute/collected/${orderId}`)
}

export async function enterStation(orderId: string) {
  if (isMockMode()) return mockApi.enter(orderId)
  return apiGet(`/api/v1/executeservice/execute/execute/${orderId}`)
}

export async function listWaitOrders(accountId: string) {
  if (isMockMode()) return mockApi.waitListOrders(accountId)
  return apiGet<WaitListOrder[]>('/api/v1/waitorderservice/waitlistorders')
}

export async function createWaitOrder(body: WaitListCreateRequest) {
  if (isMockMode()) return mockApi.createWaitList(body)
  return apiPost<WaitListOrder>('/api/v1/waitorderservice/order', body)
}

export async function cancelWaitOrder(id: string, accountId: string) {
  if (isMockMode()) return mockApi.cancelWaitList(id, accountId)
  // Backend has no dedicated cancel route yet — keep client API ready
  return apiPost<WaitListOrder>(`/api/v1/waitorderservice/order/${id}/cancel`, { accountId })
}

/** Ticket-office service returns raw JSON (not ApiResponse wrapper). */
async function rawJson<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(path, {
    credentials: 'include',
    headers: { 'Content-Type': 'application/json', ...(init?.headers ?? {}) },
    ...init,
  })
  if (!res.ok) throw new Error(`HTTP ${res.status}`)
  return (await res.json()) as T
}

export async function getOfficeRegions(): Promise<OfficeProvince[]> {
  if (isMockMode()) return mockApi.regionList()
  return rawJson<OfficeProvince[]>('/office/getRegionList')
}

export async function getSpecificOffices(query: SpecificOfficesQuery): Promise<TicketOffice[]> {
  if (isMockMode()) return mockApi.specificOffices(query)
  const raw = await rawJson<Array<{ offices?: TicketOffice[] }>>('/office/getSpecificOffices', {
    method: 'POST',
    body: JSON.stringify(query),
  })
  if (Array.isArray(raw) && raw[0]?.offices) return raw[0].offices
  if (Array.isArray(raw) && raw.length && 'officeName' in (raw[0] as object)) {
    return raw as unknown as TicketOffice[]
  }
  return []
}

export async function listStations() {
  if (isMockMode()) return mockApi.listStations()
  return apiGet<Station[]>('/api/v1/adminbasicservice/adminbasic/stations', 'admin')
}

export async function createStation(body: { name: string; stayTime: number }) {
  if (isMockMode()) return mockApi.createStation(body)
  return apiPost<Station>('/api/v1/adminbasicservice/adminbasic/stations', body, 'admin')
}

export async function updateStation(body: Station) {
  if (isMockMode()) return mockApi.updateStation(body)
  return apiPut<Station>('/api/v1/adminbasicservice/adminbasic/stations', body, 'admin')
}

export async function deleteStation(id: string) {
  if (isMockMode()) return mockApi.deleteStation(id)
  return apiDelete(`/api/v1/adminbasicservice/adminbasic/stations/${id}`, 'admin')
}

export async function getNews(): Promise<NewsItem[]> {
  if (isMockMode()) return mockApi.news()
  // Prefer normalized gateway path; fall back to legacy /news-service/news
  try {
    return await rawJson<NewsItem[]>('/api/v1/newsservice/news')
  } catch {
    return rawJson<NewsItem[]>('/news-service/news')
  }
}

export async function listRoutes() {
  if (isMockMode()) return mockApi.listRoutes()
  return apiGet<Route[]>('/api/v1/adminrouteservice/adminroute', 'admin')
}

export async function upsertRoute(body: RouteUpsertRequest) {
  if (isMockMode()) return mockApi.upsertRoute(body)
  return apiPost<Route>('/api/v1/adminrouteservice/adminroute', body, 'admin')
}

export async function deleteRoute(id: string) {
  if (isMockMode()) return mockApi.deleteRoute(id)
  return apiDelete(`/api/v1/adminrouteservice/adminroute/${id}`, 'admin')
}

export async function listTrains() {
  if (isMockMode()) return mockApi.listTrains()
  return apiGet<TrainType[]>('/api/v1/adminbasicservice/adminbasic/trains', 'admin')
}

export async function createTrain(body: Omit<TrainType, 'id'>) {
  if (isMockMode()) return mockApi.createTrain(body)
  return apiPost<TrainType>('/api/v1/adminbasicservice/adminbasic/trains', body, 'admin')
}

export async function updateTrain(body: TrainType) {
  if (isMockMode()) return mockApi.updateTrain(body)
  return apiPut<TrainType>('/api/v1/adminbasicservice/adminbasic/trains', body, 'admin')
}

export async function deleteTrain(id: string) {
  if (isMockMode()) return mockApi.deleteTrain(id)
  return apiDelete(`/api/v1/adminbasicservice/adminbasic/trains/${id}`, 'admin')
}

export async function listUsers() {
  if (isMockMode()) return mockApi.listUsers()
  return apiGet<AdminUser[]>('/api/v1/adminuserservice/users', 'admin')
}

export async function createUser(body: AdminUserCreate) {
  if (isMockMode()) return mockApi.createUser(body)
  return apiPost<AdminUser>('/api/v1/adminuserservice/users', body, 'admin')
}

export async function updateUser(body: AdminUser) {
  if (isMockMode()) return mockApi.updateUser(body)
  return apiPut<AdminUser>('/api/v1/adminuserservice/users', body, 'admin')
}

export async function deleteUser(userId: string) {
  if (isMockMode()) return mockApi.deleteUser(userId)
  return apiDelete(`/api/v1/adminuserservice/users/${userId}`, 'admin')
}

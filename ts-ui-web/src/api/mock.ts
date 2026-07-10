import type {
  ApiResponse,
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

const delay = (ms = 40) => new Promise((r) => setTimeout(r, ms))

const seedContacts: Contact[] = [
  {
    id: 'c-1',
    name: 'Alex Rider',
    documentType: 1,
    documentNumber: 'A12345678',
    phoneNumber: '555-0100',
  },
  {
    id: 'c-2',
    name: 'Sam Chen',
    documentType: 2,
    documentNumber: 'P99887766',
    phoneNumber: '555-0199',
  },
]

const seedOrders: Order[] = [
  {
    id: 'ord-demo-1',
    trainNumber: 'G1234',
    from: 'Shang Hai',
    to: 'Su Zhou',
    travelDate: '2026-07-15',
    status: 0,
    price: '75.5',
    seatClass: 'economy',
    contactsName: 'Alex Rider',
  },
]

const seedWaitList: WaitListOrder[] = [
  {
    id: 'wl-demo-1',
    accountId: '4d2a46c7-71ce-4cf1-b5bb-b68406a1fd6a',
    contactsId: 'c-1',
    contactsName: 'Alex Rider',
    trainNumber: 'G1890',
    seatType: 3,
    from: 'Shang Hai',
    to: 'Nan Jing',
    price: '93.5',
    waitUtilTime: '2026-07-16 09:00:00',
    createdTime: '2026-07-10 20:00:00',
    status: 1,
  },
]

const seedStations: Station[] = [
  { id: 'st-1', name: 'Shang Hai', stayTime: 10 },
  { id: 'st-2', name: 'Su Zhou', stayTime: 5 },
  { id: 'st-3', name: 'Nan Jing', stayTime: 8 },
]

const seedRoutes: Route[] = [
  {
    id: 'route-1',
    stations: ['Shang Hai', 'Su Zhou', 'Nan Jing'],
    distances: [0, 84, 301],
    startStation: 'Shang Hai',
    endStation: 'Nan Jing',
  },
  {
    id: 'route-2',
    stations: ['Shang Hai', 'Hang Zhou'],
    distances: [0, 169],
    startStation: 'Shang Hai',
    endStation: 'Hang Zhou',
  },
]

const seedTrains: TrainType[] = [
  { id: 'tr-1', name: 'GaoTie', economyClass: 200, confortClass: 100, averageSpeed: 250 },
  { id: 'tr-2', name: 'ZhiDa', economyClass: 180, confortClass: 80, averageSpeed: 120 },
]

const seedAdminUsers: AdminUser[] = [
  {
    userId: '4d2a46c7-71ce-4cf1-b5bb-b68406a1fd6a',
    userName: 'fdse_microservice',
    password: '111111',
    gender: 1,
    email: 'fdse@example.com',
    documentType: 1,
    documentNum: '1234567890',
  },
  {
    userId: 'user-admin-demo',
    userName: 'admin',
    password: '222222',
    gender: 1,
    email: 'admin@trainticket.local',
    documentType: 1,
    documentNum: '9999999999',
  },
]

let mockContacts = structuredClone(seedContacts)
let mockOrders = structuredClone(seedOrders)
let mockWaitList = structuredClone(seedWaitList)
let mockStations = structuredClone(seedStations)
let mockRoutes = structuredClone(seedRoutes)
let mockTrains = structuredClone(seedTrains)
let mockAdminUsers = structuredClone(seedAdminUsers)
let walletBalance = 2000

export function resetMockState() {
  mockContacts = structuredClone(seedContacts)
  mockOrders = structuredClone(seedOrders)
  mockWaitList = structuredClone(seedWaitList)
  mockStations = structuredClone(seedStations)
  mockRoutes = structuredClone(seedRoutes)
  mockTrains = structuredClone(seedTrains)
  mockAdminUsers = structuredClone(seedAdminUsers)
  walletBalance = 2000
}

function tripIdString(t: Trip): string {
  if (typeof t.tripId === 'string') return t.tripId
  return `${t.tripId.type}${t.tripId.number}`
}

function buildTrips(q: TravelQuery, highSpeed: boolean): Trip[] {
  const prefix = highSpeed ? 'G' : 'Z'
  return [
    {
      tripId: { type: prefix, number: highSpeed ? '1234' : '2345' },
      trainTypeName: highSpeed ? 'GaoTie' : 'ZhiDa',
      startStation: q.startPlace,
      terminalStation: q.endPlace,
      startTime: '09:00',
      endTime: '11:20',
      economyClass: 42,
      confortClass: 12,
      priceForEconomyClass: highSpeed ? '75.5' : '48.0',
      priceForConfortClass: highSpeed ? '120.0' : '88.0',
    },
    {
      tripId: { type: prefix, number: highSpeed ? '1567' : '2789' },
      trainTypeName: highSpeed ? 'GaoTie' : 'ZhiDa',
      startStation: q.startPlace,
      terminalStation: q.endPlace,
      startTime: '14:30',
      endTime: '16:45',
      economyClass: 18,
      confortClass: 4,
      priceForEconomyClass: highSpeed ? '82.0' : '52.0',
      priceForConfortClass: highSpeed ? '135.0' : '95.0',
    },
  ]
}

export const mockApi = {
  async login(body: LoginRequest): Promise<ApiResponse<LoginData>> {
    await delay()
    if (!body.username || !body.password || !body.verificationCode) {
      return { status: 0, msg: 'Missing fields', data: null as unknown as LoginData }
    }
    if (body.verificationCode.length < 4) {
      return { status: 0, msg: 'Invalid captcha', data: null as unknown as LoginData }
    }
    return {
      status: 1,
      msg: 'Success',
      data: {
        userId: '4d2a46c7-71ce-4cf1-b5bb-b68406a1fd6a',
        username: body.username,
        token: 'mock-jwt-token',
      },
    }
  },

  async register(body: RegisterRequest): Promise<ApiResponse<unknown>> {
    await delay()
    if (!body.userName || !body.password) {
      return { status: 0, msg: 'Username and password required', data: null }
    }
    if (body.password.length < 6) {
      return { status: 0, msg: 'Password must be at least 6 characters', data: null }
    }
    return { status: 1, msg: 'Registered', data: { userName: body.userName } }
  },

  async searchTrips(query: TravelQuery, mode: 'all' | 'gd' | 'other'): Promise<Trip[]> {
    await delay()
    if (!query.startPlace || !query.endPlace || !query.departureTime) return []
    const gd = mode === 'all' || mode === 'gd' ? buildTrips(query, true) : []
    const other = mode === 'all' || mode === 'other' ? buildTrips(query, false) : []
    return [...gd, ...other]
  },

  async contacts(accountId: string): Promise<ApiResponse<Contact[]>> {
    await delay()
    return {
      status: 1,
      data: mockContacts.map((c) => ({ ...c, accountId })),
    }
  },

  async createContact(contact: Omit<Contact, 'id'>): Promise<ApiResponse<Contact>> {
    await delay()
    if (!contact.name?.trim() || !contact.documentNumber?.trim() || !contact.phoneNumber?.trim()) {
      return { status: 0, msg: 'Name, document, and phone are required', data: null as unknown as Contact }
    }
    const created = { ...contact, id: `c-${Date.now()}` }
    mockContacts.push(created)
    return { status: 1, data: created }
  },

  async preserve(body: PreserveRequest): Promise<ApiResponse<{ orderId: string }>> {
    await delay()
    if (!body.accountId || !body.contactsId || !body.tripId) {
      return { status: 0, msg: 'Incomplete booking', data: null as unknown as { orderId: string } }
    }
    const contact = mockContacts.find((c) => c.id === body.contactsId)
    const order: Order = {
      id: `ord-${Date.now()}`,
      trainNumber: body.tripId,
      from: body.from,
      to: body.to,
      travelDate: body.date,
      status: 0,
      price: body.seatType === '2' ? '120.0' : '75.5',
      seatClass: body.seatType === '2' ? 'comfort' : 'economy',
      contactsName: contact?.name ?? 'Passenger',
    }
    mockOrders = [order, ...mockOrders]
    return { status: 1, msg: 'Success', data: { orderId: order.id } }
  },

  async orders(_accountId: string): Promise<ApiResponse<Order[]>> {
    await delay()
    return { status: 1, data: [...mockOrders] }
  },

  async pay(orderId: string): Promise<ApiResponse<unknown>> {
    await delay()
    const order = mockOrders.find((o) => o.id === orderId)
    if (!order) return { status: 0, msg: 'Order not found', data: null }
    if (order.status !== 0) return { status: 0, msg: 'Order is not payable', data: null }
    const price = Number(order.price)
    if (walletBalance < price) return { status: 0, msg: 'Insufficient wallet balance', data: null }
    walletBalance -= price
    mockOrders = mockOrders.map((o) => (o.id === orderId ? { ...o, status: 1 } : o))
    return { status: 1, msg: 'Paid', data: null }
  },

  async getWallet(): Promise<ApiResponse<{ balance: number }>> {
    await delay()
    return { status: 1, data: { balance: walletBalance } }
  },

  async topUp(amount: number): Promise<ApiResponse<{ balance: number }>> {
    await delay()
    if (!Number.isFinite(amount) || amount <= 0) {
      return { status: 0, msg: 'Amount must be positive', data: { balance: walletBalance } }
    }
    walletBalance += amount
    return { status: 1, msg: 'Topped up', data: { balance: walletBalance } }
  },

  async collect(orderId: string): Promise<ApiResponse<unknown>> {
    await delay()
    const order = mockOrders.find((o) => o.id === orderId)
    if (!order) return { status: 0, msg: 'Order not found', data: null }
    if (order.status !== 1) return { status: 0, msg: 'Order must be paid first', data: null }
    mockOrders = mockOrders.map((o) => (o.id === orderId ? { ...o, status: 2 } : o))
    return { status: 1, msg: 'Collected', data: null }
  },

  async enter(orderId: string): Promise<ApiResponse<unknown>> {
    await delay()
    const order = mockOrders.find((o) => o.id === orderId)
    if (!order) return { status: 0, msg: 'Order not found', data: null }
    if (order.status !== 2) return { status: 0, msg: 'Collect ticket before entering', data: null }
    mockOrders = mockOrders.map((o) => (o.id === orderId ? { ...o, status: 3 } : o))
    return { status: 1, msg: 'Entered', data: null }
  },

  async waitListOrders(accountId?: string): Promise<ApiResponse<WaitListOrder[]>> {
    await delay()
    const list = accountId
      ? mockWaitList.filter((w) => w.accountId === accountId)
      : [...mockWaitList]
    return { status: 1, data: [...list] }
  },

  async createWaitList(body: WaitListCreateRequest): Promise<ApiResponse<WaitListOrder>> {
    await delay()
    if (!body.accountId || !body.contactsId || !body.tripId?.trim()) {
      return { status: 0, msg: 'Account, contact, and trip are required', data: null as unknown as WaitListOrder }
    }
    if (!body.from?.trim() || !body.to?.trim()) {
      return { status: 0, msg: 'From and to stations are required', data: null as unknown as WaitListOrder }
    }
    if (body.from.trim().toLowerCase() === body.to.trim().toLowerCase()) {
      return { status: 0, msg: 'From and to must differ', data: null as unknown as WaitListOrder }
    }
    if (!body.date) {
      return { status: 0, msg: 'Travel date is required', data: null as unknown as WaitListOrder }
    }
    const price = Number(body.price)
    if (!Number.isFinite(price) || price <= 0) {
      return { status: 0, msg: 'Price must be a positive number', data: null as unknown as WaitListOrder }
    }
    const duplicate = mockWaitList.find(
      (w) =>
        w.accountId === body.accountId &&
        w.trainNumber === body.tripId &&
        w.from === body.from &&
        w.to === body.to &&
        w.status <= 1,
    )
    if (duplicate) {
      return {
        status: 0,
        msg: 'An active wait-list already exists for this trip',
        data: null as unknown as WaitListOrder,
      }
    }

    const contact = mockContacts.find((c) => c.id === body.contactsId)
    const created: WaitListOrder = {
      id: `wl-${Date.now()}`,
      accountId: body.accountId,
      contactsId: body.contactsId,
      contactsName: contact?.name ?? 'Passenger',
      trainNumber: body.tripId.trim(),
      seatType: body.seatType,
      from: body.from.trim(),
      to: body.to.trim(),
      price: String(price),
      waitUtilTime: `${body.date} 23:59:59`,
      createdTime: new Date().toISOString().slice(0, 19).replace('T', ' '),
      status: 0,
    }
    mockWaitList = [created, ...mockWaitList]
    return { status: 1, msg: 'Wait-list created', data: created }
  },

  async cancelWaitList(id: string, accountId: string): Promise<ApiResponse<WaitListOrder>> {
    await delay()
    const idx = mockWaitList.findIndex((w) => w.id === id && w.accountId === accountId)
    if (idx < 0) return { status: 0, msg: 'Wait-list entry not found', data: null as unknown as WaitListOrder }
    const current = mockWaitList[idx]!
    if (current.status >= 2) {
      return { status: 0, msg: 'Only unpaid or waiting entries can be cancelled', data: current }
    }
    const updated = { ...current, status: 3 }
    mockWaitList = mockWaitList.map((w) => (w.id === id ? updated : w))
    return { status: 1, msg: 'Cancelled', data: updated }
  },

  async regionList(): Promise<OfficeProvince[]> {
    await delay()
    return structuredClone(seedRegions)
  },

  async specificOffices(query: SpecificOfficesQuery): Promise<TicketOffice[]> {
    await delay()
    if (!query.province || !query.city || !query.region) return []
    const key = `${query.province}|${query.city}|${query.region}`
    return structuredClone(seedOffices[key] ?? [])
  },

  async listStations(): Promise<ApiResponse<Station[]>> {
    await delay()
    return { status: 1, data: [...mockStations] }
  },

  async createStation(body: { name: string; stayTime: number }): Promise<ApiResponse<Station>> {
    await delay()
    if (!body.name?.trim()) {
      return { status: 0, msg: 'Station name is required', data: null as unknown as Station }
    }
    if (!Number.isInteger(body.stayTime) || body.stayTime <= 0) {
      return { status: 0, msg: 'Stay time must be a positive integer', data: null as unknown as Station }
    }
    if (mockStations.some((s) => s.name.toLowerCase() === body.name.trim().toLowerCase())) {
      return { status: 0, msg: 'Station already exists', data: null as unknown as Station }
    }
    const created = {
      id: `st-${Date.now()}`,
      name: body.name.trim(),
      stayTime: body.stayTime,
    }
    mockStations = [...mockStations, created]
    return { status: 1, msg: 'Created', data: created }
  },

  async updateStation(body: Station): Promise<ApiResponse<Station>> {
    await delay()
    const idx = mockStations.findIndex((s) => s.id === body.id)
    if (idx < 0) return { status: 0, msg: 'Station not found', data: null as unknown as Station }
    if (!body.name?.trim()) {
      return { status: 0, msg: 'Station name is required', data: null as unknown as Station }
    }
    if (!Number.isInteger(body.stayTime) || body.stayTime <= 0) {
      return { status: 0, msg: 'Stay time must be a positive integer', data: null as unknown as Station }
    }
    const updated = { ...body, name: body.name.trim() }
    mockStations = mockStations.map((s) => (s.id === body.id ? updated : s))
    return { status: 1, msg: 'Updated', data: updated }
  },

  async deleteStation(id: string): Promise<ApiResponse<unknown>> {
    await delay()
    if (!mockStations.some((s) => s.id === id)) {
      return { status: 0, msg: 'Station not found', data: null }
    }
    mockStations = mockStations.filter((s) => s.id !== id)
    return { status: 1, msg: 'Deleted', data: null }
  },

  async news(): Promise<NewsItem[]> {
    await delay()
    return structuredClone(seedNews)
  },

  async listRoutes(): Promise<ApiResponse<Route[]>> {
    await delay()
    return { status: 1, data: structuredClone(mockRoutes) }
  },

  async upsertRoute(body: RouteUpsertRequest): Promise<ApiResponse<Route>> {
    await delay()
    const stations = body.stationList
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean)
    const distances = body.distanceList.split(',').map((d) => Number(d.trim()))
    if (stations.length < 2) {
      return { status: 0, msg: 'At least two stations required', data: null as unknown as Route }
    }
    if (stations.length !== distances.length || distances.some((n) => Number.isNaN(n))) {
      return {
        status: 0,
        msg: 'Station Number Not Equal To Distance Number',
        data: null as unknown as Route,
      }
    }
    if (!body.startStation?.trim() || !body.endStation?.trim()) {
      return { status: 0, msg: 'Start and end stations are required', data: null as unknown as Route }
    }
    const startStation = body.startStation.trim()
    const endStation = body.endStation.trim()
    if (stations[0] !== startStation || stations[stations.length - 1] !== endStation) {
      return {
        status: 0,
        msg: 'Start/end must match first and last stations in the list',
        data: null as unknown as Route,
      }
    }

    const existingId = body.id?.trim()
    if (existingId && mockRoutes.some((r) => r.id === existingId)) {
      const updated: Route = {
        id: existingId,
        stations,
        distances,
        startStation,
        endStation,
      }
      mockRoutes = mockRoutes.map((r) => (r.id === existingId ? updated : r))
      return { status: 1, msg: 'Save and Modify success', data: updated }
    }

    const created: Route = {
      id: existingId && existingId.length >= 32 ? existingId : `route-${Date.now()}`,
      stations,
      distances,
      startStation,
      endStation,
    }
    mockRoutes = [...mockRoutes, created]
    return { status: 1, msg: 'Save and Modify success', data: created }
  },

  async deleteRoute(id: string): Promise<ApiResponse<string>> {
    await delay()
    if (!mockRoutes.some((r) => r.id === id)) {
      return { status: 0, msg: 'Route not found', data: id }
    }
    mockRoutes = mockRoutes.filter((r) => r.id !== id)
    return { status: 1, msg: 'Delete Success', data: id }
  },

  async listTrains(): Promise<ApiResponse<TrainType[]>> {
    await delay()
    return { status: 1, data: structuredClone(mockTrains) }
  },

  async createTrain(body: Omit<TrainType, 'id'>): Promise<ApiResponse<TrainType>> {
    await delay()
    if (!body.name?.trim()) {
      return { status: 0, msg: 'Train name is required', data: null as unknown as TrainType }
    }
    if (
      !Number.isInteger(body.economyClass) ||
      body.economyClass <= 0 ||
      !Number.isInteger(body.confortClass) ||
      body.confortClass <= 0 ||
      !Number.isInteger(body.averageSpeed) ||
      body.averageSpeed <= 0
    ) {
      return {
        status: 0,
        msg: 'economyClass, confortClass and averageSpeed must be positive integers',
        data: null as unknown as TrainType,
      }
    }
    if (mockTrains.some((t) => t.name.toLowerCase() === body.name.trim().toLowerCase())) {
      return { status: 0, msg: 'Train type already exists', data: null as unknown as TrainType }
    }
    const created: TrainType = {
      id: `tr-${Date.now()}`,
      name: body.name.trim(),
      economyClass: body.economyClass,
      confortClass: body.confortClass,
      averageSpeed: body.averageSpeed,
    }
    mockTrains = [...mockTrains, created]
    return { status: 1, msg: 'Created', data: created }
  },

  async updateTrain(body: TrainType): Promise<ApiResponse<TrainType>> {
    await delay()
    if (!mockTrains.some((t) => t.id === body.id)) {
      return { status: 0, msg: 'Train not found', data: null as unknown as TrainType }
    }
    if (!body.name?.trim()) {
      return { status: 0, msg: 'Train name is required', data: null as unknown as TrainType }
    }
    if (
      !Number.isInteger(body.economyClass) ||
      body.economyClass <= 0 ||
      !Number.isInteger(body.confortClass) ||
      body.confortClass <= 0 ||
      !Number.isInteger(body.averageSpeed) ||
      body.averageSpeed <= 0
    ) {
      return {
        status: 0,
        msg: 'economyClass, confortClass and averageSpeed must be positive integers',
        data: null as unknown as TrainType,
      }
    }
    const updated: TrainType = {
      ...body,
      name: body.name.trim(),
    }
    mockTrains = mockTrains.map((t) => (t.id === body.id ? updated : t))
    return { status: 1, msg: 'Updated', data: updated }
  },

  async deleteTrain(id: string): Promise<ApiResponse<unknown>> {
    await delay()
    if (!mockTrains.some((t) => t.id === id)) {
      return { status: 0, msg: 'Train not found', data: null }
    }
    mockTrains = mockTrains.filter((t) => t.id !== id)
    return { status: 1, msg: 'Deleted', data: null }
  },

  async listUsers(): Promise<ApiResponse<AdminUser[]>> {
    await delay()
    return { status: 1, data: structuredClone(mockAdminUsers) }
  },

  async createUser(body: AdminUserCreate): Promise<ApiResponse<AdminUser>> {
    await delay()
    if (!body.userName?.trim() || !body.password?.trim()) {
      return { status: 0, msg: 'Username and password are required', data: null as unknown as AdminUser }
    }
    if (mockAdminUsers.some((u) => u.userName.toLowerCase() === body.userName.trim().toLowerCase())) {
      return { status: 0, msg: 'Username already exists', data: null as unknown as AdminUser }
    }
    const created: AdminUser = {
      userId: `user-${Date.now()}`,
      userName: body.userName.trim(),
      password: body.password,
      gender: Number(body.gender) || 0,
      email: body.email?.trim() ?? '',
      documentType: Number(body.documentType) || 1,
      documentNum: body.documentNum?.trim() ?? '',
    }
    mockAdminUsers = [...mockAdminUsers, created]
    return { status: 1, msg: 'Created', data: created }
  },

  async updateUser(body: AdminUser): Promise<ApiResponse<AdminUser>> {
    await delay()
    if (!mockAdminUsers.some((u) => u.userId === body.userId)) {
      return { status: 0, msg: 'User not found', data: null as unknown as AdminUser }
    }
    if (!body.userName?.trim() || !body.password?.trim()) {
      return { status: 0, msg: 'Username and password are required', data: null as unknown as AdminUser }
    }
    const updated: AdminUser = {
      ...body,
      userName: body.userName.trim(),
      email: body.email?.trim() ?? '',
      documentNum: body.documentNum?.trim() ?? '',
      gender: Number(body.gender) || 0,
      documentType: Number(body.documentType) || 1,
    }
    mockAdminUsers = mockAdminUsers.map((u) => (u.userId === body.userId ? updated : u))
    return { status: 1, msg: 'Updated', data: updated }
  },

  async deleteUser(userId: string): Promise<ApiResponse<unknown>> {
    await delay()
    if (!mockAdminUsers.some((u) => u.userId === userId)) {
      return { status: 0, msg: 'User not found', data: null }
    }
    mockAdminUsers = mockAdminUsers.filter((u) => u.userId !== userId)
    return { status: 1, msg: 'Deleted', data: null }
  },

  tripIdString,
}

const seedNews: NewsItem[] = [
  {
    Title: 'News Service Complete',
    Content: 'Congratulations: Your News Service Complete',
  },
  {
    Title: 'Total Ticket System Complete',
    Content: 'Just a total test',
  },
  {
    Title: 'SPA modernization',
    Content: 'TrainTicket UI now ships as a Bun + Vue 3 client with local mock APIs.',
  },
]

const seedRegions: OfficeProvince[] = [
  {
    province: 'Shanghai',
    cities: [
      {
        city: 'Shanghai',
        regions: [{ region: 'Pudong New Area' }, { region: 'Huangpu District' }],
      },
    ],
  },
  {
    province: 'Anhui',
    cities: [
      {
        city: 'Hefei',
        regions: [{ region: 'Hefei Downtown Area' }, { region: 'Feixi County' }],
      },
      {
        city: 'Anqing',
        regions: [{ region: 'Anqing Downtown Area' }],
      },
    ],
  },
]

const seedOffices: Record<string, TicketOffice[]> = {
  'Shanghai|Shanghai|Pudong New Area': [
    {
      officeName: 'Century Avenue Ticket Office',
      address: '100 Century Ave',
      workTime: '08:00-20:00',
      windowNum: 6,
    },
    {
      officeName: 'Lujiazui Counter',
      address: '1 Lujiazui Ring Rd',
      workTime: '09:00-18:00',
      windowNum: 3,
    },
  ],
  'Shanghai|Shanghai|Huangpu District': [
    {
      officeName: 'People Square Office',
      address: '200 Nanjing Rd E',
      workTime: '08:30-19:30',
      windowNum: 8,
    },
  ],
  'Anhui|Hefei|Hefei Downtown Area': [
    {
      officeName: 'Hefei Station Plaza',
      address: '1 Zhanqian Rd',
      workTime: '07:30-21:00',
      windowNum: 10,
    },
  ],
}

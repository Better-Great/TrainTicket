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

let mockContacts = structuredClone(seedContacts)
let mockOrders = structuredClone(seedOrders)
let mockWaitList = structuredClone(seedWaitList)
let walletBalance = 2000

export function resetMockState() {
  mockContacts = structuredClone(seedContacts)
  mockOrders = structuredClone(seedOrders)
  mockWaitList = structuredClone(seedWaitList)
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

  tripIdString,
}

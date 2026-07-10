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
} from './types'

const delay = (ms = 180) => new Promise((r) => setTimeout(r, ms))

const mockContacts: Contact[] = [
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

let mockOrders: Order[] = [
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
    return { status: 1, msg: 'Registered', data: { userName: body.userName } }
  },

  async searchTrips(query: TravelQuery, mode: 'all' | 'gd' | 'other'): Promise<Trip[]> {
    await delay(220)
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
    const created = { ...contact, id: `c-${Date.now()}` }
    mockContacts.push(created)
    return { status: 1, data: created }
  },

  async preserve(body: PreserveRequest): Promise<ApiResponse<{ orderId: string }>> {
    await delay(300)
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
    await delay(250)
    mockOrders = mockOrders.map((o) => (o.id === orderId ? { ...o, status: 1 } : o))
    return { status: 1, msg: 'Paid', data: null }
  },

  wallet: {
    balance: 2000,
  },

  async getWallet(): Promise<ApiResponse<{ balance: number }>> {
    await delay()
    return { status: 1, data: { balance: mockApi.wallet.balance } }
  },

  async topUp(amount: number): Promise<ApiResponse<{ balance: number }>> {
    await delay(200)
    if (amount <= 0) return { status: 0, msg: 'Amount must be positive', data: { balance: mockApi.wallet.balance } }
    mockApi.wallet.balance += amount
    return { status: 1, msg: 'Topped up', data: { balance: mockApi.wallet.balance } }
  },

  async collect(orderId: string): Promise<ApiResponse<unknown>> {
    await delay()
    mockOrders = mockOrders.map((o) => (o.id === orderId ? { ...o, status: 2 } : o))
    return { status: 1, msg: 'Collected', data: null }
  },

  async enter(orderId: string): Promise<ApiResponse<unknown>> {
    await delay()
    mockOrders = mockOrders.map((o) => (o.id === orderId ? { ...o, status: 3 } : o))
    return { status: 1, msg: 'Entered', data: null }
  },

  tripIdString,
}

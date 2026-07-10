export interface ApiResponse<T> {
  status: number
  msg?: string
  message?: string
  data: T
}

export interface LoginRequest {
  username: string
  password: string
  verificationCode: string
}

export interface LoginData {
  userId: string
  username: string
  token: string
}

export interface RegisterRequest {
  userName: string
  password: string
  gender: number
  email: string
  documentType: number
  documentNum: string
}

export interface TravelQuery {
  startPlace: string
  endPlace: string
  departureTime: string
}

export interface Trip {
  tripId: { type: string; number: string } | string
  trainTypeName?: string
  startStation?: string
  terminalStation?: string
  startTime: string
  endTime: string
  economyClass: number
  confortClass: number
  priceForEconomyClass: string | number
  priceForConfortClass: string | number
}

export interface Contact {
  id: string
  name: string
  documentType: number
  documentNumber: string
  phoneNumber: string
  accountId?: string
}

export interface PreserveRequest {
  accountId: string
  contactsId: string
  tripId: string
  seatType: string
  date: string
  from: string
  to: string
  assurance: number
  foodType?: number
  foodName?: string
  foodPrice?: number
  stationName?: string
  storeName?: string
}

export interface Order {
  id: string
  trainNumber: string
  from: string
  to: string
  travelDate: string
  status: number
  price: string | number
  seatClass?: string
  contactsName?: string
}

export const ORDER_STATUS: Record<number, string> = {
  0: 'Not paid',
  1: 'Paid',
  2: 'Collected',
  3: 'Entered',
  4: 'Cancelled',
  5: 'Changed',
  6: 'Refunded',
}

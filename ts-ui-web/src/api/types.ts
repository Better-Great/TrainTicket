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

export interface WaitListOrder {
  id: string
  accountId: string
  contactsId: string
  contactsName?: string
  trainNumber: string
  seatType: number
  from: string
  to: string
  price: string
  waitUtilTime: string
  createdTime: string
  status: number
}

export interface WaitListCreateRequest {
  accountId: string
  contactsId: string
  tripId: string
  seatType: number
  date: string
  from: string
  to: string
  price: string
}

export interface OfficeRegion {
  region: string
}

export interface OfficeCity {
  city: string
  regions: OfficeRegion[]
}

export interface OfficeProvince {
  province: string
  cities: OfficeCity[]
}

export interface TicketOffice {
  officeName: string
  address: string
  workTime: string
  windowNum: string | number
}

export interface SpecificOfficesQuery {
  province: string
  city: string
  region: string
}

export interface Station {
  id: string
  name: string
  stayTime: number
}

export interface NewsItem {
  Title: string
  Content: string
}

/** Route as returned by route / admin-route services. */
export interface Route {
  id: string
  stations: string[]
  distances: number[]
  startStation: string
  endStation: string
  /** Legacy admin UI field aliases */
  startStationId?: string
  terminalStationId?: string
}

/** Create/update payload — comma-separated lists match Java RouteInfo. */
export interface RouteUpsertRequest {
  id?: string
  stationList: string
  distanceList: string
  startStation: string
  endStation: string
}

/** Train type (legacy spelling confortClass preserved). */
export interface TrainType {
  id: string
  name: string
  economyClass: number
  confortClass: number
  averageSpeed: number
}

/** Admin user account (adminuserservice). */
export interface AdminUser {
  userId: string
  userName: string
  password: string
  gender: number | string
  email: string
  documentType: number | string
  documentNum: string
}

export type AdminUserCreate = Omit<AdminUser, 'userId'>
export type AdminUserUpdate = AdminUser

/** Price rate for a route + train type. */
export interface Price {
  id: string
  routeId: string
  trainType: string
  basicPriceRate: number
  firstClassPriceRate: number
}

export type PriceCreate = Omit<Price, 'id'>

/** Named system config entry. */
export interface ConfigEntry {
  name: string
  value: string
  description: string
}

/** Admin contact create (requires accountId). */
export type AdminContactCreate = Omit<Contact, 'id'> & { accountId: string }

export const ORDER_STATUS: Record<number, string> = {
  0: 'Not paid',
  1: 'Paid',
  2: 'Collected',
  3: 'Entered',
  4: 'Cancelled',
  5: 'Changed',
  6: 'Refunded',
}

export const WAIT_LIST_STATUS: Record<number, string> = {
  0: 'Not paid',
  1: 'Paid · waiting',
  2: 'Collected',
  3: 'Cancelled',
  4: 'Refunded',
  5: 'Expired',
}

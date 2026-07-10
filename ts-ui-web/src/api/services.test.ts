import { beforeEach, describe, expect, it } from 'vitest'
import { resetMockState } from '@/api/mock'
import {
  advancedSearch,
  cancelWaitOrder,
  captchaUrl,
  createContact,
  createWaitOrder,
  getWallet,
  listContacts,
  listOrders,
  listWaitOrders,
  login,
  payOrder,
  preserveTicket,
  register,
  searchTrips,
  topUpWallet,
  collectTicket,
  enterStation,
  getOfficeRegions,
  getSpecificOffices,
  listStations,
  createStation,
  updateStation,
  deleteStation,
  getNews,
  listRoutes,
  upsertRoute,
  deleteRoute,
  listTrains,
  createTrain,
  updateTrain,
  deleteTrain,
  listUsers,
  createUser,
  updateUser,
  deleteUser,
} from '@/api/services'

const accountId = '4d2a46c7-71ce-4cf1-b5bb-b68406a1fd6a'

describe('services (mock mode)', () => {
  beforeEach(() => {
    resetMockState()
  })

  it('exposes mock captcha data url', () => {
    expect(captchaUrl()).toContain('data:image/svg+xml')
  })

  it('login + register through service layer', async () => {
    const logged = await login({
      username: 'a',
      password: 'b',
      verificationCode: '1234',
    })
    expect(logged.status).toBe(1)
    const reg = await register({
      userName: 'b',
      password: 'abcdef',
      gender: 1,
      email: 'b@c.d',
      documentType: 1,
      documentNum: '1',
    })
    expect(reg.status).toBe(1)
  })

  it('searchTrips and advancedSearch ranking', async () => {
    const q = {
      startPlace: 'Shang Hai',
      endPlace: 'Su Zhou',
      departureTime: '2026-07-15 00:00:00',
    }
    const all = await searchTrips(q, 0)
    expect(all.every((t) => t.id)).toBe(true)
    const cheap = await advancedSearch(q, 'cheapest')
    expect(Number(cheap[0]!.priceForEconomyClass)).toBeLessThanOrEqual(
      Number(cheap[cheap.length - 1]!.priceForEconomyClass),
    )
    expect(cheap[0]!.strategy).toBe('cheapest')
  })

  it('contacts service', async () => {
    const list = await listContacts(accountId)
    expect(list.data.length).toBeGreaterThan(0)
    const created = await createContact({
      name: 'New',
      documentType: 1,
      documentNumber: 'N1',
      phoneNumber: '1',
      accountId,
    })
    expect(created.data.id).toBeTruthy()
  })

  it('booking and payment services', async () => {
    const preserved = await preserveTicket({
      accountId,
      contactsId: 'c-1',
      tripId: 'G1234',
      seatType: '3',
      date: '2026-07-15',
      from: 'Shang Hai',
      to: 'Su Zhou',
      assurance: 0,
    })
    const orderId = preserved.data.orderId
    expect(orderId).toBeTruthy()
    expect((await payOrder(orderId!, 'G1234')).status).toBe(1)
    expect((await collectTicket(orderId!)).status).toBe(1)
    expect((await enterStation(orderId!)).status).toBe(1)
    const orders = await listOrders(accountId)
    expect(orders.data.some((o) => o.id === orderId)).toBe(true)
  })

  it('wallet services', async () => {
    const wallet = await getWallet(accountId)
    expect(wallet.data.balance).toBe(2000)
    const topped = await topUpWallet(accountId, '50')
    expect(topped.data.balance).toBe(2050)
  })

  it('wait-list services create/list/cancel', async () => {
    const created = await createWaitOrder({
      accountId,
      contactsId: 'c-1',
      tripId: 'G5555',
      seatType: 3,
      date: '2026-07-22',
      from: 'A',
      to: 'B',
      price: '66',
    })
    expect(created.status).toBe(1)
    const listed = await listWaitOrders(accountId)
    expect(listed.data.some((w) => w.id === created.data.id)).toBe(true)
    const cancelled = await cancelWaitOrder(created.data.id, accountId)
    expect(cancelled.data.status).toBe(3)
  })

  it('ticket office services', async () => {
    const regions = await getOfficeRegions()
    expect(regions.length).toBeGreaterThan(0)
    const offices = await getSpecificOffices({
      province: 'Shanghai',
      city: 'Shanghai',
      region: 'Pudong New Area',
    })
    expect(offices.length).toBe(2)
  })

  it('admin station services CRUD', async () => {
    const listed = await listStations()
    expect(listed.data.length).toBeGreaterThan(0)
    const created = await createStation({ name: 'Zhen Jiang', stayTime: 4 })
    expect(created.status).toBe(1)
    const updated = await updateStation({
      id: created.data.id,
      name: 'Zhenjiang',
      stayTime: 6,
    })
    expect(updated.data.name).toBe('Zhenjiang')
    expect((await deleteStation(created.data.id)).status).toBe(1)
  })

  it('news service', async () => {
    const items = await getNews()
    expect(items.length).toBeGreaterThanOrEqual(2)
    expect(items[0]?.Title).toBeTruthy()
  })

  it('admin route services CRUD', async () => {
    const listed = await listRoutes()
    expect(listed.data.length).toBeGreaterThan(0)
    const created = await upsertRoute({
      stationList: 'Guang Zhou,Shen Zhen',
      distanceList: '0,140',
      startStation: 'Guang Zhou',
      endStation: 'Shen Zhen',
    })
    expect(created.status).toBe(1)
    const updated = await upsertRoute({
      id: created.data.id,
      stationList: 'Guang Zhou,Dong Guan,Shen Zhen',
      distanceList: '0,60,140',
      startStation: 'Guang Zhou',
      endStation: 'Shen Zhen',
    })
    expect(updated.data.stations).toContain('Dong Guan')
    expect((await deleteRoute(created.data.id)).status).toBe(1)
  })

  it('admin train services CRUD', async () => {
    expect((await listTrains()).data.length).toBeGreaterThan(0)
    const created = await createTrain({
      name: 'TeKuai',
      economyClass: 120,
      confortClass: 40,
      averageSpeed: 160,
    })
    expect(created.status).toBe(1)
    const updated = await updateTrain({
      id: created.data.id,
      name: 'TeKuai',
      economyClass: 130,
      confortClass: 45,
      averageSpeed: 170,
    })
    expect(updated.data.averageSpeed).toBe(170)
    expect((await deleteTrain(created.data.id)).status).toBe(1)
  })

  it('admin user services CRUD', async () => {
    expect((await listUsers()).data.length).toBeGreaterThan(0)
    const created = await createUser({
      userName: 'ops_user',
      password: 'pass123',
      gender: 2,
      email: 'ops@example.com',
      documentType: 1,
      documentNum: 'ID99',
    })
    expect(created.status).toBe(1)
    const updated = await updateUser({ ...created.data, documentNum: 'ID100' })
    expect(updated.data.documentNum).toBe('ID100')
    expect((await deleteUser(created.data.userId)).status).toBe(1)
  })
})

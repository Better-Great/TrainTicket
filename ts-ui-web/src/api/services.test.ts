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
  listPrices,
  createPrice,
  updatePrice,
  deletePrice,
  listConfigs,
  createConfig,
  updateConfig,
  deleteConfig,
  listAdminContacts,
  createAdminContact,
  updateAdminContact,
  deleteAdminContact,
  listTravels,
  createTravel,
  updateTravel,
  deleteTravel,
  listAdminOrders,
  createAdminOrder,
  updateAdminOrder,
  deleteAdminOrder,
  listFoodDeliveries,
  createFoodDelivery,
  updateFoodDeliveryTrip,
  updateFoodDeliverySeat,
  updateFoodDeliveryTime,
  deleteFoodDelivery,
  listSecurityConfigs,
  createSecurityConfig,
  updateSecurityConfig,
  deleteSecurityConfig,
  checkSecurity,
  getVoucher,
  getAdminDashboardMetrics,
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

  it('admin price services CRUD', async () => {
    expect((await listPrices()).data.length).toBeGreaterThan(0)
    const created = await createPrice({
      routeId: 'route-svc',
      trainType: 'GaoTie',
      basicPriceRate: 0.25,
      firstClassPriceRate: 0.4,
    })
    expect(created.status).toBe(1)
    expect((await updatePrice({ ...created.data, firstClassPriceRate: 0.42 })).data.firstClassPriceRate).toBe(
      0.42,
    )
    expect((await deletePrice(created.data.id)).status).toBe(1)
  })

  it('admin config services CRUD', async () => {
    expect((await listConfigs()).data.length).toBeGreaterThan(0)
    const created = await createConfig({ name: 'SvcFlag', value: 'on', description: 'd' })
    expect(created.status).toBe(1)
    expect((await updateConfig({ name: 'SvcFlag', value: 'off', description: 'd2' })).data.value).toBe(
      'off',
    )
    expect((await deleteConfig('SvcFlag')).status).toBe(1)
  })

  it('admin contact services CRUD', async () => {
    expect((await listAdminContacts()).data.length).toBeGreaterThan(0)
    const created = await createAdminContact({
      accountId: 'acct-svc',
      name: 'Jordan',
      documentType: 2,
      documentNumber: 'PP1',
      phoneNumber: '555-9',
    })
    expect(created.status).toBe(1)
    expect((await updateAdminContact({ ...created.data, name: 'Jordan K' })).data.name).toBe('Jordan K')
    expect((await deleteAdminContact(created.data.id)).status).toBe(1)
  })

  it('admin travel services CRUD', async () => {
    expect((await listTravels()).data.length).toBeGreaterThan(0)
    const created = await createTravel({
      tripId: 'D8888',
      trainTypeName: 'GaoTie',
      routeId: 'route-2',
      startStationName: 'Shang Hai',
      stationsName: 'Hang Zhou',
      terminalStationName: 'Hang Zhou',
      startTime: '2026-09-01 07:00:00',
      endTime: '2026-09-01 09:00:00',
    })
    expect(created.status).toBe(1)
    const updated = await updateTravel({
      tripId: 'D8888',
      trainTypeName: 'GaoTie',
      routeId: 'route-2',
      startStationName: 'Shang Hai',
      stationsName: 'Jia Xing',
      terminalStationName: 'Hang Zhou',
      startTime: '2026-09-01 07:30:00',
      endTime: '2026-09-01 09:30:00',
    })
    expect(updated.data.trip.stationsName).toBe('Jia Xing')
    expect((await deleteTravel('D8888')).status).toBe(1)
  })

  it('admin order services CRUD', async () => {
    expect((await listAdminOrders()).data.length).toBeGreaterThan(0)
    const created = await createAdminOrder({
      boughtDate: '2026-07-12',
      travelDate: '2026-07-22',
      travelTime: '11:00:00',
      accountId: 'acct-svc',
      contactsName: 'Ops',
      documentType: 1,
      contactsDocumentNumber: 'D9',
      trainNumber: 'G5555',
      coachNumber: 1,
      seatClass: 3,
      seatNumber: '9F',
      from: 'Shang Hai',
      to: 'Su Zhou',
      status: 0,
      price: '55',
    })
    expect(created.status).toBe(1)
    expect((await updateAdminOrder({ ...created.data, status: 2 })).data.status).toBe(2)
    expect((await deleteAdminOrder(created.data.id, created.data.trainNumber)).status).toBe(1)
  })

  it('food delivery services', async () => {
    expect((await listFoodDeliveries()).data.length).toBeGreaterThan(0)
    const created = await createFoodDelivery({
      stationFoodStoreId: 'store-svc',
      tripId: 'D100',
      seatNo: 3,
      deliveryTime: '2026-08-02 09:00:00',
      deliveryFee: 2,
      foodList: [{ foodName: 'Bun', price: 6 }],
    })
    expect(created.status).toBe(1)
    expect((await updateFoodDeliveryTrip(created.data.id, 'D101')).data.tripId).toBe('D101')
    expect((await updateFoodDeliverySeat(created.data.id, 4)).data.seatNo).toBe(4)
    expect(
      (await updateFoodDeliveryTime(created.data.id, '2026-08-02 10:00:00')).data.deliveryTime,
    ).toContain('10:00')
    expect((await deleteFoodDelivery(created.data.id)).status).toBe(1)
  })

  it('security, voucher, and dashboard services', async () => {
    expect((await listSecurityConfigs()).data.length).toBeGreaterThan(0)
    const created = await createSecurityConfig({
      name: 'svc_flag',
      value: '1',
      description: 'd',
    })
    expect(created.status).toBe(1)
    expect((await updateSecurityConfig({ ...created.data, value: '2' })).data.value).toBe('2')
    expect((await checkSecurity('acct')).status).toBe(1)
    expect((await deleteSecurityConfig(created.data.id)).status).toBe(1)

    const voucher = await getVoucher({ orderId: 'ord-admin-1', type: 1 })
    expect(voucher.order_id).toBe('ord-admin-1')

    const dash = await getAdminDashboardMetrics()
    expect(dash.data.trains).toBeGreaterThan(0)
    expect(dash.data.foodDeliveries).toBeGreaterThan(0)
  })
})

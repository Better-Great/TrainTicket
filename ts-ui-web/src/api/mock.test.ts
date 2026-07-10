import { beforeEach, describe, expect, it } from 'vitest'
import { mockApi, resetMockState } from '@/api/mock'
import { travelTripIdString } from '@/api/types'

const accountId = '4d2a46c7-71ce-4cf1-b5bb-b68406a1fd6a'

describe('mockApi — full service coverage', () => {
  beforeEach(() => {
    resetMockState()
  })

  describe('auth', () => {
    it('logs in with valid captcha', async () => {
      const res = await mockApi.login({
        username: 'traveler',
        password: 'secret',
        verificationCode: '1234',
      })
      expect(res.status).toBe(1)
      expect(res.data.token).toBeTruthy()
    })

    it('rejects missing login fields', async () => {
      const res = await mockApi.login({ username: '', password: '', verificationCode: '' })
      expect(res.status).toBe(0)
    })

    it('registers and rejects short passwords', async () => {
      const ok = await mockApi.register({
        userName: 'newuser',
        password: 'secret1',
        gender: 1,
        email: 'a@b.c',
        documentType: 1,
        documentNum: 'X1',
      })
      expect(ok.status).toBe(1)
      const bad = await mockApi.register({
        userName: 'x',
        password: '123',
        gender: 1,
        email: 'a@b.c',
        documentType: 1,
        documentNum: 'X1',
      })
      expect(bad.status).toBe(0)
    })
  })

  describe('travel', () => {
    it('searches all / gd / other modes', async () => {
      const q = {
        startPlace: 'Shang Hai',
        endPlace: 'Su Zhou',
        departureTime: '2026-07-15 00:00:00',
      }
      expect((await mockApi.searchTrips(q, 'all')).length).toBe(4)
      expect((await mockApi.searchTrips(q, 'gd')).length).toBe(2)
      expect((await mockApi.searchTrips(q, 'other')).length).toBe(2)
    })

    it('returns empty trips when query incomplete', async () => {
      const trips = await mockApi.searchTrips(
        { startPlace: '', endPlace: '', departureTime: '' },
        'all',
      )
      expect(trips).toEqual([])
    })
  })

  describe('contacts', () => {
    it('lists and creates contacts', async () => {
      const listed = await mockApi.contacts(accountId)
      expect(listed.data.length).toBeGreaterThanOrEqual(2)
      const created = await mockApi.createContact({
        name: 'Pat Lee',
        documentType: 1,
        documentNumber: 'Z9',
        phoneNumber: '555-0111',
        accountId,
      })
      expect(created.status).toBe(1)
      expect(created.data.id).toMatch(/^c-/)
    })

    it('rejects incomplete contacts', async () => {
      const res = await mockApi.createContact({
        name: '',
        documentType: 1,
        documentNumber: '',
        phoneNumber: '',
      })
      expect(res.status).toBe(0)
    })
  })

  describe('orders lifecycle', () => {
    it('preserve → pay → collect → enter', async () => {
      const preserved = await mockApi.preserve({
        accountId,
        contactsId: 'c-1',
        tripId: 'G1234',
        seatType: '3',
        date: '2026-07-15',
        from: 'Shang Hai',
        to: 'Su Zhou',
        assurance: 0,
      })
      expect(preserved.status).toBe(1)
      const id = preserved.data.orderId

      expect((await mockApi.pay(id)).status).toBe(1)
      expect((await mockApi.collect(id)).status).toBe(1)
      expect((await mockApi.enter(id)).status).toBe(1)

      const orders = await mockApi.orders(accountId)
      expect(orders.data.find((o) => o.id === id)?.status).toBe(3)
    })

    it('blocks collect before pay', async () => {
      const preserved = await mockApi.preserve({
        accountId,
        contactsId: 'c-1',
        tripId: 'G9999',
        seatType: '3',
        date: '2026-07-15',
        from: 'A',
        to: 'B',
        assurance: 0,
      })
      const res = await mockApi.collect(preserved.data.orderId)
      expect(res.status).toBe(0)
    })
  })

  describe('wallet', () => {
    it('reads balance and tops up', async () => {
      const before = await mockApi.getWallet()
      expect(before.data.balance).toBe(2000)
      const topped = await mockApi.topUp(150)
      expect(topped.status).toBe(1)
      expect(topped.data.balance).toBe(2150)
    })

    it('rejects non-positive top-up', async () => {
      expect((await mockApi.topUp(0)).status).toBe(0)
      expect((await mockApi.topUp(-5)).status).toBe(0)
    })
  })

  describe('wait-list', () => {
    it('lists account wait-list entries', async () => {
      const res = await mockApi.waitListOrders(accountId)
      expect(res.data.some((w) => w.id === 'wl-demo-1')).toBe(true)
      const other = await mockApi.waitListOrders('someone-else')
      expect(other.data).toEqual([])
    })

    it('creates a wait-list entry with validation', async () => {
      const created = await mockApi.createWaitList({
        accountId,
        contactsId: 'c-2',
        tripId: 'D3101',
        seatType: 2,
        date: '2026-07-20',
        from: 'Shang Hai',
        to: 'Hang Zhou',
        price: '110',
      })
      expect(created.status).toBe(1)
      expect(created.data.trainNumber).toBe('D3101')
      expect(created.data.status).toBe(0)
    })

    it('rejects same from/to and duplicate active trip', async () => {
      const same = await mockApi.createWaitList({
        accountId,
        contactsId: 'c-1',
        tripId: 'G1',
        seatType: 3,
        date: '2026-07-20',
        from: 'A',
        to: 'A',
        price: '10',
      })
      expect(same.status).toBe(0)

      const first = await mockApi.createWaitList({
        accountId,
        contactsId: 'c-1',
        tripId: 'G777',
        seatType: 3,
        date: '2026-07-20',
        from: 'X',
        to: 'Y',
        price: '10',
      })
      expect(first.status).toBe(1)
      const dup = await mockApi.createWaitList({
        accountId,
        contactsId: 'c-1',
        tripId: 'G777',
        seatType: 3,
        date: '2026-07-20',
        from: 'X',
        to: 'Y',
        price: '10',
      })
      expect(dup.status).toBe(0)
    })

    it('cancels an active wait-list entry', async () => {
      const created = await mockApi.createWaitList({
        accountId,
        contactsId: 'c-1',
        tripId: 'Z100',
        seatType: 3,
        date: '2026-07-21',
        from: 'A',
        to: 'B',
        price: '40',
      })
      const cancelled = await mockApi.cancelWaitList(created.data.id, accountId)
      expect(cancelled.status).toBe(1)
      expect(cancelled.data.status).toBe(3)
    })
  })

  describe('ticket offices', () => {
    it('loads cascading regions', async () => {
      const list = await mockApi.regionList()
      expect(list[0]?.province).toBe('Shanghai')
      expect(list[0]?.cities[0]?.regions.length).toBeGreaterThan(0)
    })

    it('returns offices for a district and empty for unknown', async () => {
      const found = await mockApi.specificOffices({
        province: 'Shanghai',
        city: 'Shanghai',
        region: 'Pudong New Area',
      })
      expect(found.length).toBe(2)
      expect(found[0]?.officeName).toContain('Century')
      const missing = await mockApi.specificOffices({
        province: 'Shanghai',
        city: 'Shanghai',
        region: 'Nowhere',
      })
      expect(missing).toEqual([])
    })
  })

  describe('admin stations CRUD', () => {
    it('lists seed stations', async () => {
      const res = await mockApi.listStations()
      expect(res.data.length).toBe(3)
    })

    it('creates, updates, and deletes a station', async () => {
      const created = await mockApi.createStation({ name: 'Wu Xi', stayTime: 7 })
      expect(created.status).toBe(1)
      const updated = await mockApi.updateStation({
        id: created.data.id,
        name: 'Wuxi',
        stayTime: 9,
      })
      expect(updated.data.name).toBe('Wuxi')
      expect(updated.data.stayTime).toBe(9)
      const deleted = await mockApi.deleteStation(created.data.id)
      expect(deleted.status).toBe(1)
      const listed = await mockApi.listStations()
      expect(listed.data.some((s) => s.id === created.data.id)).toBe(false)
    })

    it('rejects invalid create', async () => {
      expect((await mockApi.createStation({ name: '', stayTime: 5 })).status).toBe(0)
      expect((await mockApi.createStation({ name: 'X', stayTime: 0 })).status).toBe(0)
      expect((await mockApi.createStation({ name: 'Shang Hai', stayTime: 3 })).status).toBe(0)
    })
  })

  describe('news', () => {
    it('returns news items with Title and Content', async () => {
      const items = await mockApi.news()
      expect(items.length).toBeGreaterThanOrEqual(2)
      expect(items[0]?.Title).toBeTruthy()
      expect(items[0]?.Content).toBeTruthy()
    })
  })

  describe('admin routes CRUD', () => {
    it('lists seed routes', async () => {
      const res = await mockApi.listRoutes()
      expect(res.data.length).toBe(2)
    })

    it('creates, updates, and deletes a route', async () => {
      const created = await mockApi.upsertRoute({
        stationList: 'Bei Jing,Tian Jin',
        distanceList: '0,120',
        startStation: 'Bei Jing',
        endStation: 'Tian Jin',
      })
      expect(created.status).toBe(1)
      expect(created.data.stations).toEqual(['Bei Jing', 'Tian Jin'])

      const updated = await mockApi.upsertRoute({
        id: created.data.id,
        stationList: 'Bei Jing,Tian Jin,Tang Shan',
        distanceList: '0,120,220',
        startStation: 'Bei Jing',
        endStation: 'Tang Shan',
      })
      expect(updated.status).toBe(1)
      expect(updated.data.stations.length).toBe(3)

      const deleted = await mockApi.deleteRoute(created.data.id)
      expect(deleted.status).toBe(1)
      expect((await mockApi.listRoutes()).data.some((r) => r.id === created.data.id)).toBe(false)
    })

    it('rejects mismatched station/distance counts', async () => {
      const res = await mockApi.upsertRoute({
        stationList: 'A,B',
        distanceList: '0',
        startStation: 'A',
        endStation: 'B',
      })
      expect(res.status).toBe(0)
    })

    it('rejects start/end that do not match list ends', async () => {
      const res = await mockApi.upsertRoute({
        stationList: 'A,B',
        distanceList: '0,10',
        startStation: 'X',
        endStation: 'B',
      })
      expect(res.status).toBe(0)
    })
  })

  describe('admin trains CRUD', () => {
    it('lists seed trains', async () => {
      expect((await mockApi.listTrains()).data.length).toBe(2)
    })

    it('creates, updates, and deletes a train', async () => {
      const created = await mockApi.createTrain({
        name: 'DongChe',
        economyClass: 150,
        confortClass: 60,
        averageSpeed: 200,
      })
      expect(created.status).toBe(1)
      const updated = await mockApi.updateTrain({
        id: created.data.id,
        name: 'DongChe',
        economyClass: 160,
        confortClass: 70,
        averageSpeed: 210,
      })
      expect(updated.data.economyClass).toBe(160)
      expect((await mockApi.deleteTrain(created.data.id)).status).toBe(1)
    })

    it('rejects invalid create', async () => {
      expect(
        (await mockApi.createTrain({ name: '', economyClass: 1, confortClass: 1, averageSpeed: 1 }))
          .status,
      ).toBe(0)
      expect(
        (
          await mockApi.createTrain({
            name: 'X',
            economyClass: 0,
            confortClass: 1,
            averageSpeed: 1,
          })
        ).status,
      ).toBe(0)
      expect(
        (
          await mockApi.createTrain({
            name: 'GaoTie',
            economyClass: 1,
            confortClass: 1,
            averageSpeed: 1,
          })
        ).status,
      ).toBe(0)
    })
  })

  describe('admin users CRUD', () => {
    it('lists seed users', async () => {
      expect((await mockApi.listUsers()).data.length).toBe(2)
    })

    it('creates, updates, and deletes a user', async () => {
      const created = await mockApi.createUser({
        userName: 'traveler1',
        password: 'secret1',
        gender: 1,
        email: 't1@example.com',
        documentType: 2,
        documentNum: 'P123',
      })
      expect(created.status).toBe(1)
      const updated = await mockApi.updateUser({
        ...created.data,
        email: 't1b@example.com',
      })
      expect(updated.data.email).toBe('t1b@example.com')
      expect((await mockApi.deleteUser(created.data.userId)).status).toBe(1)
    })

    it('rejects duplicate username', async () => {
      expect(
        (
          await mockApi.createUser({
            userName: 'admin',
            password: 'x',
            gender: 1,
            email: '',
            documentType: 1,
            documentNum: '',
          })
        ).status,
      ).toBe(0)
    })
  })

  describe('admin prices CRUD', () => {
    it('lists seed prices', async () => {
      expect((await mockApi.listPrices()).data.length).toBe(2)
    })

    it('creates, updates, and deletes a price', async () => {
      const created = await mockApi.createPrice({
        routeId: 'route-x',
        trainType: 'ZhiDa',
        basicPriceRate: 0.2,
        firstClassPriceRate: 0.35,
      })
      expect(created.status).toBe(1)
      const updated = await mockApi.updatePrice({
        ...created.data,
        basicPriceRate: 0.22,
      })
      expect(updated.data.basicPriceRate).toBe(0.22)
      expect((await mockApi.deletePrice(created.data.id)).status).toBe(1)
    })

    it('rejects non-positive rates', async () => {
      expect(
        (
          await mockApi.createPrice({
            routeId: 'r',
            trainType: 'G',
            basicPriceRate: 0,
            firstClassPriceRate: 0.1,
          })
        ).status,
      ).toBe(0)
    })
  })

  describe('admin configs CRUD', () => {
    it('lists seed configs', async () => {
      expect((await mockApi.listConfigs()).data.length).toBe(2)
    })

    it('creates, updates, and deletes a config', async () => {
      const created = await mockApi.createConfig({
        name: 'TestFlag',
        value: '1',
        description: 'test',
      })
      expect(created.status).toBe(1)
      const updated = await mockApi.updateConfig({
        name: 'TestFlag',
        value: '0',
        description: 'off',
      })
      expect(updated.data.value).toBe('0')
      expect((await mockApi.deleteConfig('TestFlag')).status).toBe(1)
    })

    it('rejects duplicate name', async () => {
      expect(
        (
          await mockApi.createConfig({
            name: 'DirectTicketAllocationProportion',
            value: '1',
            description: '',
          })
        ).status,
      ).toBe(0)
    })
  })

  describe('admin contacts CRUD', () => {
    it('lists contacts', async () => {
      expect((await mockApi.listAdminContacts()).data.length).toBeGreaterThanOrEqual(2)
    })

    it('creates, updates, and deletes a contact', async () => {
      const created = await mockApi.createAdminContact({
        accountId: 'acct-1',
        name: 'Pat Lee',
        documentType: 1,
        documentNumber: 'D111',
        phoneNumber: '555-0200',
      })
      expect(created.status).toBe(1)
      const updated = await mockApi.updateAdminContact({
        ...created.data,
        phoneNumber: '555-0201',
      })
      expect(updated.data.phoneNumber).toBe('555-0201')
      expect((await mockApi.deleteAdminContact(created.data.id)).status).toBe(1)
    })

    it('rejects create without accountId', async () => {
      expect(
        (
          await mockApi.createAdminContact({
            accountId: '',
            name: 'X',
            documentType: 1,
            documentNumber: '1',
            phoneNumber: '1',
          })
        ).status,
      ).toBe(0)
    })
  })

  describe('admin travels CRUD', () => {
    it('lists seed travels', async () => {
      expect((await mockApi.listTravels()).data.length).toBe(2)
    })

    it('creates, updates, and deletes a travel', async () => {
      const created = await mockApi.createTravel({
        tripId: 'G9999',
        trainTypeName: 'GaoTie',
        routeId: 'route-1',
        startStationName: 'Shang Hai',
        stationsName: 'Su Zhou',
        terminalStationName: 'Nan Jing',
        startTime: '2026-08-01 08:00:00',
        endTime: '2026-08-01 10:00:00',
      })
      expect(created.status).toBe(1)
      expect(travelTripIdString(created.data.trip.tripId)).toBe('G9999')
      const updated = await mockApi.updateTravel({
        tripId: 'G9999',
        trainTypeName: 'GaoTie',
        routeId: 'route-1',
        startStationName: 'Shang Hai',
        stationsName: 'Su Zhou',
        terminalStationName: 'Nan Jing',
        startTime: '2026-08-01 09:00:00',
        endTime: '2026-08-01 11:00:00',
      })
      expect(updated.data.trip.startTime).toContain('09:00')
      expect((await mockApi.deleteTravel('G9999')).status).toBe(1)
    })

    it('rejects duplicate trip id', async () => {
      expect(
        (
          await mockApi.createTravel({
            tripId: 'G1234',
            trainTypeName: 'GaoTie',
            routeId: 'route-1',
            startStationName: 'Shang Hai',
            stationsName: 'Su Zhou',
            terminalStationName: 'Nan Jing',
            startTime: '2026-08-01 08:00:00',
            endTime: '2026-08-01 10:00:00',
          })
        ).status,
      ).toBe(0)
    })
  })

  describe('admin orders CRUD', () => {
    it('lists aggregated seed orders', async () => {
      expect((await mockApi.listAdminOrders()).data.length).toBe(2)
    })

    it('creates, updates, and deletes an order', async () => {
      const created = await mockApi.createAdminOrder({
        boughtDate: '2026-07-11',
        travelDate: '2026-07-21',
        travelTime: '10:00:00',
        accountId: 'acct-1',
        contactsName: 'Pat',
        documentType: 1,
        contactsDocumentNumber: 'X1',
        trainNumber: 'G7777',
        coachNumber: 2,
        seatClass: 2,
        seatNumber: '2B',
        from: 'Shang Hai',
        to: 'Nan Jing',
        status: 0,
        price: '88',
      })
      expect(created.status).toBe(1)
      const updated = await mockApi.updateAdminOrder({
        ...created.data,
        status: 1,
        price: '90',
      })
      expect(updated.data.status).toBe(1)
      expect(
        (await mockApi.deleteAdminOrder(created.data.id, created.data.trainNumber)).status,
      ).toBe(1)
    })

    it('delete requires matching train number', async () => {
      expect((await mockApi.deleteAdminOrder('ord-admin-1', 'WRONG')).status).toBe(0)
    })
  })

  describe('food delivery', () => {
    it('lists seed deliveries', async () => {
      expect((await mockApi.listFoodDeliveries()).data.length).toBe(2)
    })

    it('creates, updates trip/seat/time, and deletes', async () => {
      const created = await mockApi.createFoodDelivery({
        stationFoodStoreId: 'store-x',
        tripId: 'G9000',
        seatNo: 7,
        deliveryTime: '2026-08-01 12:00:00',
        deliveryFee: 3,
        foodList: [{ foodName: 'Soup', price: 15 }],
      })
      expect(created.status).toBe(1)
      expect((await mockApi.updateFoodDeliveryTrip(created.data.id, 'G9001')).data.tripId).toBe(
        'G9001',
      )
      expect((await mockApi.updateFoodDeliverySeat(created.data.id, 8)).data.seatNo).toBe(8)
      expect(
        (await mockApi.updateFoodDeliveryTime(created.data.id, '2026-08-01 13:00:00')).data
          .deliveryTime,
      ).toContain('13:00')
      expect((await mockApi.deleteFoodDelivery(created.data.id)).status).toBe(1)
    })

    it('rejects empty food list', async () => {
      expect(
        (
          await mockApi.createFoodDelivery({
            stationFoodStoreId: 's',
            tripId: 'G1',
            seatNo: 1,
            deliveryTime: '2026-08-01 12:00:00',
            deliveryFee: 1,
            foodList: [],
          })
        ).status,
      ).toBe(0)
    })
  })

  describe('security + voucher + dashboard', () => {
    it('security config CRUD and account check', async () => {
      expect((await mockApi.listSecurityConfigs()).data.length).toBe(2)
      const created = await mockApi.createSecurityConfig({
        name: 'test_limit',
        value: '3',
        description: 'test',
      })
      expect(created.status).toBe(1)
      expect(
        (await mockApi.updateSecurityConfig({ ...created.data, value: '4' })).data.value,
      ).toBe('4')
      const check = await mockApi.checkSecurity('4d2a46c7-71ce-4cf1-b5bb-b68406a1fd6a')
      expect(check.status).toBe(1)
      expect((await mockApi.deleteSecurityConfig(created.data.id)).status).toBe(1)
    })

    it('issues a voucher for an admin order', async () => {
      const v = await mockApi.getVoucher({ orderId: 'ord-admin-1', type: 1 })
      expect(v.order_id).toBe('ord-admin-1')
      expect(v.train_number).toBe('G1234')
      const again = await mockApi.getVoucher({ orderId: 'ord-admin-1', type: 1 })
      expect(again.voucher_id).toBe(v.voucher_id)
    })

    it('dashboard metrics are positive', async () => {
      const m = await mockApi.dashboardMetrics()
      expect(m.data.stations).toBeGreaterThan(0)
      expect(m.data.orders).toBeGreaterThan(0)
      expect(m.data.securityConfigs).toBeGreaterThan(0)
    })
  })
})

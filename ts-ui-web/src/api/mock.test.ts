import { beforeEach, describe, expect, it } from 'vitest'
import { mockApi, resetMockState } from '@/api/mock'

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
})

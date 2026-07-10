import { describe, expect, it } from 'vitest'
import { mockApi } from '@/api/mock'

describe('mockApi', () => {
  it('searches trips for both train families', async () => {
    const trips = await mockApi.searchTrips(
      {
        startPlace: 'Shang Hai',
        endPlace: 'Su Zhou',
        departureTime: '2026-07-15 00:00:00',
      },
      'all',
    )
    expect(trips.length).toBe(4)
  })

  it('preserves and lists an unpaid order', async () => {
    const preserved = await mockApi.preserve({
      accountId: 'u1',
      contactsId: 'c-1',
      tripId: 'G1234',
      seatType: '3',
      date: '2026-07-15',
      from: 'Shang Hai',
      to: 'Su Zhou',
      assurance: 0,
    })
    expect(preserved.status).toBe(1)
    const orders = await mockApi.orders('u1')
    expect(orders.data.some((o) => o.id === preserved.data.orderId)).toBe(true)
  })
})

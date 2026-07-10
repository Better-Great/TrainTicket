import { describe, expect, it } from 'vitest'
import {
  documentTypeLabel,
  filterActiveWaitList,
  formatMoney,
  isHighSpeedTrip,
  seatTypeLabel,
  swapStations,
  tomorrowIso,
} from '@/utils/format'

describe('format utils', () => {
  it('formats money', () => {
    expect(formatMoney(75.5)).toBe('¥75.5')
    expect(formatMoney('120')).toBe('¥120.0')
    expect(formatMoney(undefined)).toBe('—')
  })

  it('detects high-speed trip ids', () => {
    expect(isHighSpeedTrip('G1234')).toBe(true)
    expect(isHighSpeedTrip('D5678')).toBe(true)
    expect(isHighSpeedTrip('Z2345')).toBe(false)
  })

  it('returns ISO date for tomorrow', () => {
    expect(tomorrowIso()).toMatch(/^\d{4}-\d{2}-\d{2}$/)
  })

  it('labels documents and seats', () => {
    expect(documentTypeLabel(1)).toBe('ID Card')
    expect(documentTypeLabel(2)).toBe('Passport')
    expect(seatTypeLabel(2)).toBe('Comfort')
    expect(seatTypeLabel(3)).toBe('Economy')
  })

  it('filters active wait-list statuses', () => {
    const items = [{ status: 0 }, { status: 1 }, { status: 3 }, { status: 5 }]
    expect(filterActiveWaitList(items)).toEqual([{ status: 0 }, { status: 1 }])
  })

  it('swaps stations in place', () => {
    const form = { from: 'A', to: 'B' }
    swapStations(form)
    expect(form).toEqual({ from: 'B', to: 'A' })
  })
})

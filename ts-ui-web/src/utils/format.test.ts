import { describe, expect, it } from 'vitest'
import { formatMoney, isHighSpeedTrip, tomorrowIso } from '@/utils/format'

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
})

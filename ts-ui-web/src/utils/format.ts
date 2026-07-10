export function tomorrowIso(): string {
  const d = new Date()
  d.setDate(d.getDate() + 1)
  return d.toISOString().slice(0, 10)
}

export function formatMoney(value: string | number | undefined): string {
  if (value === undefined || value === null || value === '') return '—'
  const n = typeof value === 'number' ? value : Number(value)
  if (Number.isNaN(n)) return String(value)
  return `¥${n.toFixed(1)}`
}

export function documentTypeLabel(type: number): string {
  if (type === 1) return 'ID Card'
  if (type === 2) return 'Passport'
  return 'Other'
}

export function isHighSpeedTrip(tripId: string): boolean {
  return /^[GD]/i.test(tripId)
}

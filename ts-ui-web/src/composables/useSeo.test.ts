import { describe, expect, it } from 'vitest'
import { applySeo } from '@/composables/useSeo'

describe('applySeo', () => {
  it('sets document title and description meta', () => {
    applySeo({
      title: 'Search trips',
      description: 'Find trains',
      path: '/search',
    })
    expect(document.title).toContain('Search trips')
    const desc = document.head.querySelector('meta[name="description"]')
    expect(desc?.getAttribute('content')).toBe('Find trains')
    const canonical = document.head.querySelector('link[rel="canonical"]')
    expect(canonical?.getAttribute('href')).toContain('/search')
  })

  it('marks private routes noindex', () => {
    applySeo({
      title: 'Orders',
      description: 'Private',
      path: '/orders',
      noindex: true,
    })
    const robots = document.head.querySelector('meta[name="robots"]')
    expect(robots?.getAttribute('content')).toBe('noindex, nofollow')
  })
})

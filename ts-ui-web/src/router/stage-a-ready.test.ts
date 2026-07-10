import { describe, expect, it } from 'vitest'
import { routeSeo } from '@/seo/routes'

/** Stage A readiness: every SPA surface has SEO + a concrete path. */
const expectedSeoKeys = [
  'home',
  'login',
  'register',
  'search',
  'advanced',
  'book',
  'orders',
  'collect',
  'contacts',
  'wallet',
  'waitlist',
  'food',
  'voucher',
  'offices',
  'news',
  'adminLogin',
  'adminDashboard',
  'adminStations',
  'adminRoutes',
  'adminTrains',
  'adminUsers',
  'adminPrices',
  'adminConfig',
  'adminContacts',
  'adminTravels',
  'adminOrders',
  'adminSecurity',
] as const

const expectedPaths = [
  '/',
  '/login',
  '/register',
  '/search',
  '/advanced',
  '/book',
  '/orders',
  '/collect',
  '/contacts',
  '/wallet',
  '/waitlist',
  '/food',
  '/voucher',
  '/offices',
  '/news',
  '/admin/login',
  '/admin',
  '/admin/stations',
  '/admin/routes',
  '/admin/trains',
  '/admin/users',
  '/admin/prices',
  '/admin/config',
  '/admin/contacts',
  '/admin/travels',
  '/admin/orders',
  '/admin/security',
]

describe('Stage A — UI ready coverage', () => {
  it('defines SEO for all Stage A surfaces', () => {
    for (const key of expectedSeoKeys) {
      expect(routeSeo[key], `missing seo key ${key}`).toBeTruthy()
      expect(routeSeo[key]!.path).toBeTruthy()
      expect(routeSeo[key]!.title).toBeTruthy()
    }
  })

  it('SEO paths cover the Stage A route map', () => {
    const paths = Object.values(routeSeo).map((s) => s.path)
    for (const p of expectedPaths) {
      expect(paths, `missing path ${p}`).toContain(p)
    }
  })
})

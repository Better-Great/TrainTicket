import type { SeoMeta } from '@/composables/useSeo'

export const routeSeo: Record<string, SeoMeta> = {
  home: {
    title: 'TrainTicket',
    description:
      'Book the next departure. Search G/D and conventional trains, reserve, pay, and collect.',
    path: '/',
  },
  login: {
    title: 'Sign in',
    description: 'Sign in to TrainTicket to manage bookings and tickets.',
    path: '/login',
    noindex: true,
  },
  register: {
    title: 'Create account',
    description: 'Register a TrainTicket account to book and manage trips.',
    path: '/register',
  },
  search: {
    title: 'Search trips',
    description: 'Find high-speed and conventional train trips by origin, destination, and date.',
    path: '/search',
  },
  advanced: {
    title: 'Advanced search',
    description: 'Find cheapest, quickest, or fewest-stop itineraries.',
    path: '/advanced',
  },
  book: {
    title: 'Confirm booking',
    description: 'Choose a passenger and confirm your train reservation.',
    path: '/book',
    noindex: true,
  },
  orders: {
    title: 'My orders',
    description: 'View and pay for your TrainTicket orders.',
    path: '/orders',
    noindex: true,
  },
  collect: {
    title: 'Collect & enter',
    description: 'Collect paid tickets and enter the station.',
    path: '/collect',
    noindex: true,
  },
  contacts: {
    title: 'Passengers',
    description: 'Manage passenger contacts for booking.',
    path: '/contacts',
    noindex: true,
  },
  wallet: {
    title: 'Wallet',
    description: 'View balance and top up your inside-payment wallet.',
    path: '/wallet',
    noindex: true,
  },
  waitlist: {
    title: 'Wait-list',
    description: 'Join and manage train seat wait-list orders.',
    path: '/waitlist',
    noindex: true,
  },
  food: {
    title: 'Food delivery',
    description: 'Order and track food delivery to your train seat.',
    path: '/food',
    noindex: true,
  },
  offices: {
    title: 'Ticket offices',
    description: 'Find train ticket offices by province, city, and district.',
    path: '/offices',
  },
  news: {
    title: 'News',
    description: 'System news from the TrainTicket news service.',
    path: '/news',
  },
  adminLogin: {
    title: 'Admin sign in',
    description: 'Administrator access for TrainTicket operations.',
    path: '/admin/login',
    noindex: true,
  },
  adminStations: {
    title: 'Admin stations',
    description: 'Create, update, and delete stations.',
    path: '/admin/stations',
    noindex: true,
  },
  adminRoutes: {
    title: 'Admin routes',
    description: 'Create, update, and delete train routes.',
    path: '/admin/routes',
    noindex: true,
  },
  adminTrains: {
    title: 'Admin trains',
    description: 'Create, update, and delete train types.',
    path: '/admin/trains',
    noindex: true,
  },
  adminUsers: {
    title: 'Admin users',
    description: 'Create, update, and delete user accounts.',
    path: '/admin/users',
    noindex: true,
  },
  adminPrices: {
    title: 'Admin prices',
    description: 'Create, update, and delete price rates.',
    path: '/admin/prices',
    noindex: true,
  },
  adminConfig: {
    title: 'Admin config',
    description: 'Create, update, and delete system config entries.',
    path: '/admin/config',
    noindex: true,
  },
  adminContacts: {
    title: 'Admin contacts',
    description: 'Create, update, and delete passenger contacts.',
    path: '/admin/contacts',
    noindex: true,
  },
  adminTravels: {
    title: 'Admin travels',
    description: 'Create, update, and delete travel trips.',
    path: '/admin/travels',
    noindex: true,
  },
  adminOrders: {
    title: 'Admin orders',
    description: 'Aggregated order management across high-speed and other trains.',
    path: '/admin/orders',
    noindex: true,
  },
}

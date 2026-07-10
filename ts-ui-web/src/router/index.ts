import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { applySeo, defaultSeo } from '@/composables/useSeo'
import { routeSeo } from '@/seo/routes'

declare module 'vue-router' {
  interface RouteMeta {
    requiresAuth?: boolean
    guest?: boolean
    seoKey?: keyof typeof routeSeo
  }
}

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'home',
    component: () => import('@/views/HomeView.vue'),
    meta: { seoKey: 'home' },
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('@/views/LoginView.vue'),
    meta: { guest: true, seoKey: 'login' },
  },
  {
    path: '/register',
    name: 'register',
    component: () => import('@/views/RegisterView.vue'),
    meta: { guest: true, seoKey: 'register' },
  },
  {
    path: '/search',
    name: 'search',
    component: () => import('@/views/SearchView.vue'),
    meta: { seoKey: 'search' },
  },
  {
    path: '/advanced',
    name: 'advanced',
    component: () => import('@/views/AdvancedSearchView.vue'),
    meta: { seoKey: 'advanced' },
  },
  {
    path: '/book',
    name: 'book',
    component: () => import('@/views/BookView.vue'),
    meta: { requiresAuth: true, seoKey: 'book' },
  },
  {
    path: '/orders',
    name: 'orders',
    component: () => import('@/views/OrdersView.vue'),
    meta: { requiresAuth: true, seoKey: 'orders' },
  },
  {
    path: '/collect',
    name: 'collect',
    component: () => import('@/views/CollectView.vue'),
    meta: { requiresAuth: true, seoKey: 'collect' },
  },
  {
    path: '/contacts',
    name: 'contacts',
    component: () => import('@/views/ContactsView.vue'),
    meta: { requiresAuth: true, seoKey: 'contacts' },
  },
  {
    path: '/wallet',
    name: 'wallet',
    component: () => import('@/views/WalletView.vue'),
    meta: { requiresAuth: true, seoKey: 'wallet' },
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 }
  },
})

router.beforeEach((to) => {
  const auth = useAuthStore()
  if (to.meta.requiresAuth && !auth.isAuthenticated) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
  return true
})

router.afterEach((to) => {
  const key = to.meta.seoKey
  const seo = (key && routeSeo[key]) || defaultSeo()
  applySeo({ ...seo, path: to.path })
})

export default router

export interface SeoMeta {
  title: string
  description: string
  path?: string
  noindex?: boolean
  image?: string
  type?: 'website' | 'article'
}

const SITE = 'TrainTicket'
const DEFAULT_DESC =
  'Search high-speed and conventional trains, reserve seats, pay, and collect tickets.'

function absoluteUrl(path = '/'): string {
  const origin =
    typeof window !== 'undefined' ? window.location.origin : 'https://trainticket.local'
  return `${origin}${path.startsWith('/') ? path : `/${path}`}`
}

function upsertMeta(attr: 'name' | 'property', key: string, content: string) {
  let el = document.head.querySelector<HTMLMetaElement>(`meta[${attr}="${key}"]`)
  if (!el) {
    el = document.createElement('meta')
    el.setAttribute(attr, key)
    document.head.appendChild(el)
  }
  el.content = content
}

function upsertLink(rel: string, href: string) {
  let el = document.head.querySelector<HTMLLinkElement>(`link[rel="${rel}"]`)
  if (!el) {
    el = document.createElement('link')
    el.rel = rel
    document.head.appendChild(el)
  }
  el.href = href
}

export function applySeo(meta: SeoMeta) {
  const title = meta.title.includes(SITE) ? meta.title : `${meta.title} · ${SITE}`
  const description = meta.description || DEFAULT_DESC
  const url = absoluteUrl(meta.path ?? '/')
  const image = absoluteUrl(meta.image ?? '/og-default.svg')
  const robots = meta.noindex ? 'noindex, nofollow' : 'index, follow'

  document.title = title

  upsertMeta('name', 'description', description)
  upsertMeta('name', 'robots', robots)
  upsertMeta('name', 'theme-color', '#0e2433')
  upsertMeta('property', 'og:site_name', SITE)
  upsertMeta('property', 'og:title', title)
  upsertMeta('property', 'og:description', description)
  upsertMeta('property', 'og:type', meta.type ?? 'website')
  upsertMeta('property', 'og:url', url)
  upsertMeta('property', 'og:image', image)
  upsertMeta('name', 'twitter:card', 'summary_large_image')
  upsertMeta('name', 'twitter:title', title)
  upsertMeta('name', 'twitter:description', description)
  upsertMeta('name', 'twitter:image', image)
  upsertLink('canonical', url)
}

export function defaultSeo(): SeoMeta {
  return {
    title: SITE,
    description: DEFAULT_DESC,
    path: '/',
  }
}

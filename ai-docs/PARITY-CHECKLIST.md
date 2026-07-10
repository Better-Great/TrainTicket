# Feature Parity Checklist

Match or exceed [`train-ticket/`](../train-ticket/) reference.  
Check off in SPA + E2E as each item ships.

---

## Auth & users

- [x] Login with captcha (`POST /api/v1/users/login`) — SPA mock
- [x] User registration (`POST /api/v1/userservice/users/register`) — SPA mock
- [x] JWT on protected endpoints — client Bearer + route guards
- [x] Logout (client + server) — client clear
- [ ] Avatar upload (`POST /api/v1/avatar`)

---

## Trip search & booking

- [x] Basic trip search (`travelservice` + `travel2service` `trips/left`) — SPA mock + client
- [ ] G/D routing rule preserved (or hidden via BFF TT-532)
- [x] Booking: contact select or inline create — SPA
- [x] Booking: seat class selection — SPA
- [ ] Booking: assurance optional — partial (select only)
- [ ] Booking: food (train vs station)
- [ ] Booking: consign optional
- [x] Preserve saga → unpaid order — SPA mock
- [x] Advanced search: minStation / cheapest / quickest (`travelplanservice`) — SPA mock
- [ ] Transfer search (`travelPlan/transferResult`) — TT-216
- [ ] Route planning (`routeplanservice`) — TT-217

---

## Orders & payment

- [x] Order list by account — SPA mock
- [x] Pay via inside-payment wallet — SPA mock pay
- [x] Wallet balance view + top-up — TT-215 SPA mock
- [ ] Cancel with refund preview
- [ ] Cancel confirm + refund
- [ ] Rebook + price difference payment
- [ ] Post-order consign from order list — TT-218
- [x] Order status: NOTPAID → PAID → COLLECTED → USED — SPA mock path

---

## Ticket lifecycle

- [x] Collect ticket (`executeservice/execute/collected/{orderId}`) — SPA mock
- [x] Enter station / execute (`executeservice/execute/execute/{orderId}`) — SPA mock
- [ ] Voucher print (`voucherservice` / legacy `/getVoucher`)
- [ ] Consign list by account
- [x] Wait-list orders UI — TT-211 SPA mock

---

## Ancillary

- [x] Contacts CRUD (client page) — SPA list/create (TT-214 partial)
- [ ] News feed — TT-219
- [x] Ticket office finder — TT-212 SPA mock
- [ ] Food delivery tracking — TT-220
- [ ] Email: preserve, create, change, cancel notifications

---

## Admin

- [x] Admin login — SPA `/admin/login`
- [ ] Orders admin (aggregated BFF)
- [ ] Routes CRUD
- [ ] Travels/trips CRUD
- [x] Stations CRUD — SPA `/admin/stations` (TT-301 partial)
- [ ] Trains CRUD
- [ ] Prices CRUD
- [ ] Config CRUD
- [ ] Contacts admin CRUD
- [ ] Users CRUD
- [ ] Security config (anti-scalping) — TT-306
- [ ] Admin dashboard metrics

---

## Infrastructure & routing

- [x] Gateway routes: wait-order, food-delivery
- [x] Gateway routes: voucher, news, ticket-office (+ legacy paths)
- [x] UI nginx proxies APIs via gateway only
- [ ] Single public port prod profile — TT-510
- [ ] CI/CD pipeline — TT-601
- [ ] E2E (train-ticket-auto-query scenarios) — TT-606
- [ ] K8s / Helm deploy — TT-604
- [ ] SkyWalking / Prometheus / Istio (research parity) — TT-801–810

---

## Exceed reference (not in original production UI)

- [x] Modern Bun + Vue 3 + TypeScript SPA (in progress)
- [x] SEO: per-route meta, robots, sitemap, JSON-LD, webmanifest
- [ ] Gateway BFF hides G/D split — TT-532
- [ ] OpenAPI-generated TypeScript client — TT-527
- [ ] Centralized gateway JWT auth — TT-501

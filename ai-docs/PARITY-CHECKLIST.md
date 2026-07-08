# Feature Parity Checklist

Match or exceed [`train-ticket/`](../train-ticket/) reference.  
Check off in SPA + E2E as each item ships.

---

## Auth & users

- [ ] Login with captcha (`POST /api/v1/users/login`)
- [ ] User registration (`POST /api/v1/userservice/users/register`)
- [ ] JWT on protected endpoints
- [ ] Logout (client + server)
- [ ] Avatar upload (`POST /api/v1/avatar`)

---

## Trip search & booking

- [ ] Basic trip search (`travelservice` + `travel2service` `trips/left`)
- [ ] G/D routing rule preserved (or hidden via BFF TT-532)
- [ ] Booking: contact select or inline create
- [ ] Booking: seat class selection
- [ ] Booking: assurance optional
- [ ] Booking: food (train vs station)
- [ ] Booking: consign optional
- [ ] Preserve saga → unpaid order
- [ ] Advanced search: minStation / cheapest / quickest (`travelplanservice`)
- [ ] Transfer search (`travelPlan/transferResult`) — TT-216
- [ ] Route planning (`routeplanservice`) — TT-217

---

## Orders & payment

- [ ] Order list by account
- [ ] Pay via inside-payment wallet
- [ ] Wallet balance view + top-up — TT-215
- [ ] Cancel with refund preview
- [ ] Cancel confirm + refund
- [ ] Rebook + price difference payment
- [ ] Post-order consign from order list — TT-218
- [ ] Order status: NOTPAID → PAID → COLLECTED → USED

---

## Ticket lifecycle

- [ ] Collect ticket (`executeservice/execute/collected/{orderId}`)
- [ ] Enter station / execute (`executeservice/execute/execute/{orderId}`)
- [ ] Voucher print (`voucherservice` / legacy `/getVoucher`)
- [ ] Consign list by account
- [ ] Wait-list orders UI — TT-211

---

## Ancillary

- [ ] Contacts CRUD (client page) — TT-214
- [ ] News feed — TT-219
- [ ] Ticket office finder — TT-212
- [ ] Food delivery tracking — TT-220
- [ ] Email: preserve, create, change, cancel notifications

---

## Admin

- [ ] Admin login
- [ ] Orders admin (aggregated BFF)
- [ ] Routes CRUD
- [ ] Travels/trips CRUD
- [ ] Stations CRUD
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

- [ ] Modern Bun + Vue 3 + TypeScript SPA
- [ ] Gateway BFF hides G/D split — TT-532
- [ ] OpenAPI-generated TypeScript client — TT-527
- [ ] Centralized gateway JWT auth — TT-501

# Handoff — TrainTicket Modernization

**Last updated:** 2026-07-10  
**Branch:** `feat` @ `f1119ae` + uncommitted quality pass  
**Active focus:** SPA quality — wait-list polish + unit tests for every service

## Where we stand

| Area | Status |
|------|--------|
| Commit | `f1119ae` local, not pushed |
| Wait-list | Improved: validation, cancel, filters, status chips, swap stations |
| Unit tests | **37** passing — mock + services + client + auth + SEO + TripRow + format |
| `bun run check` | Green |
| Docker | Deferred |

## Test map (every SPA service)

| Domain | Covered by |
|--------|------------|
| Auth login/register | `mock.test`, `services.test`, `auth.test` |
| Search / advanced | `mock.test`, `services.test` |
| Contacts | `mock.test`, `services.test` |
| Preserve → pay → collect → enter | `mock.test`, `services.test` |
| Wallet top-up | `mock.test`, `services.test` |
| Wait-list create/list/cancel | `mock.test`, `services.test` |
| HTTP client errors | `client.test` |
| SEO meta | `useSeo.test` |
| TripRow UI | `TripRow.test` |

## Next

1. Ticket office finder (TT-212) + its unit tests  
2. Admin shell  
3. Gateway live mode  

```bash
cd ts-ui-web && bun run check && bun run dev
```

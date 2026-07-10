# Session 2026-07-10 — Tests + wait-list quality

## Goal

Unit-test every SPA service; improve wait-list and polish existing flows.

## Done

- `resetMockState()` for deterministic tests
- Expanded mock validation (wait-list, pay/collect/enter guards, wallet debit)
- Wait-list UI overhaul (cancel, filters, chips, swap, empty/loading)
- New tests: `services.test`, `client.test`, `TripRow.test`; expanded mock/format/auth
- **37** tests via `bun run check`

## Next

TT-212 ticket office + tests.

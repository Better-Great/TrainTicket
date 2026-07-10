# Prioritized Improvements — 2026-07-10 (v12)

**Policy:** Stage A (UI ready) complete. Move to Track B live stack.

## Done

- Stage A SPA parity including security, dashboard, voucher
- `./scripts/smoke-stage-a-ui.sh` green (91 tests)

## Next

| P | Item |
|---|------|
| P0 | Track B: compose up + gateway smoke |
| P0 | `VITE_USE_MOCK=false` against live gateway |
| P1 | Fix first failing services from smoke |
| P2 | Service harden (Java/polyglot unit tests) |

## Verify

```bash
./scripts/smoke-stage-a-ui.sh
./scripts/smoke-test-routes.sh   # requires stack
```

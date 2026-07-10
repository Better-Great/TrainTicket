# Prioritized Improvements — 2026-07-10 (v4)

**Policy:** UI-first, local-first. Whole-repo sections with unit tests. Skills enforce senior UI/UX, fullstack, Java, devops, system design.

## Done this session

- News feed TT-219: `/news`, mock + gateway paths, SEO/nav
- `ts-news-service` Go unit tests
- Vitest **48** green via `bun run check`

## Next

| P | Item |
|---|------|
| P0 | Admin Routes CRUD (+ tests) |
| P0 | Admin Trains / Users CRUD |
| P1 | Gateway live mode + smoke |
| P2 | Food delivery tracking (TT-220) |

## Verify

```bash
cd ts-ui-web && bun run check && bun run dev
cd ts-news-service && go test ./...
```

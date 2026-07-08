# TrainTicket AI Docs

Cross-IDE continuity for AI-assisted development. **Commit this directory to GitHub.**

## Start here

1. [`HANDOFF.md`](HANDOFF.md) — current sprint, blockers, next ticket
2. [`ROADMAP.md`](ROADMAP.md) — phased modernization plan
3. [`AUDIT.md`](AUDIT.md) — honest status before server move
4. [`MIGRATION.md`](MIGRATION.md) — new server setup
5. [`ARCHITECTURE.md`](ARCHITECTURE.md) — current vs target architecture
6. [`PARITY-CHECKLIST.md`](PARITY-CHECKLIST.md) — feature parity vs reference
7. [`backlog/README.md`](backlog/README.md) — ticket index

## Session protocol

| When | Action |
|------|--------|
| **Start** | Read `HANDOFF.md` → relevant epic in `backlog/` |
| **During** | Log decisions in `DECISIONS.md`; update ticket status in backlog |
| **End** | Append `CHANGELOG-AI.md`; update `HANDOFF.md`; add `sessions/YYYY-MM-DD-*.md` |

## Directory layout

```
ai-docs/
  README.md                 # This file
  HANDOFF.md                # Live state — update every session
  ROADMAP.md                # Master plan + sprint table
  ARCHITECTURE.md           # Routing, services, diagrams
  DECISIONS.md              # Architecture Decision Records
  CHANGELOG-AI.md           # Session summaries (newest first)
  FLAWS-AUDIT.md            # Legacy flaws + remediation status
  PARITY-CHECKLIST.md       # Feature parity vs train-ticket/
  backlog/
    README.md
    EPIC-00-ai-docs.md      # Done
    EPIC-01-edge-routing.md # In progress
    EPIC-02-frontend-spa.md
    EPIC-03-ui-ux.md
    EPIC-04-backend.md
    EPIC-05-devops.md
    EPIC-06-observability.md
    EPIC-07-feature-parity-plus.md
    EPIC-08-resilience.md
    EPIC-09-research-ops.md
  sessions/
    YYYY-MM-DD-topic.md
  implemented/
    TT-###-slug.md
```

## Conventions

- **Scope:** Work only in `TrainTicket/`; `train-ticket/` is read-only reference.
- **Ticket IDs:** `TT-###` — status: Backlog → Ready → In Progress → Review → Done.
- **On completion:** Add `implemented/TT-###-slug.md` with what/why/files/verify steps.
- **Runtime:** Bun (not Node) for all JS/TS tooling.
- **Routing:** Gateway owns all north-south APIs; static server serves UI only.

## Quick commands

```bash
cd TrainTicket
./scripts/up-docker.sh
./scripts/smoke-test-routes.sh
```

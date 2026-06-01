# Dockerfiles

Per-service images under `dockerfile/Dockerfile.Ts.*`. Build context is always the **repo root**.

## Build & run

```bash
docker compose -f docker-compose.build.yml build
./scripts/up-docker.sh
```

See **[../docs/DOCKER.md](../docs/DOCKER.md)**.

## Non-Java

| Dockerfile | Service | Port |
|------------|---------|------|
| `Dockerfile.Ts.Ui.Dashboard` | nginx + static UI | 8080 |
| `Dockerfile.Ts.News.Service` | Go | 12862 |
| `Dockerfile.Ts.Avatar.Service` | Python/Flask | 17001 |
| `Dockerfile.Ts.Voucher.Service` | Python/Tornado | 16101 |
| `Dockerfile.Ts.Ticket.Office.Service` | Node.js | 16108 |

## Java

`Dockerfile.Ts.<Name>.Service` — requires JAR in `jar/` (`./scripts/build.sh`). Templates in `dockerfile/templates/`.

Regenerate Java Dockerfiles: `./dockerfile/gen_dockerfiles.sh`

# Configuration generator

Maintainer-only scaffolding when you **add a new service** or reset property templates from scratch.

Day-to-day Docker runs do not use this. Containers expand `properties/*.application.ini` via `ts-token-replacement-service` inside `dockerfile/entrypoint.sh`. For a local one-off expand:

```bash
./ts-token-replacement-service/replace-tokens.sh docker
```

| Script | Purpose |
|--------|---------|
| `analyze-and-generate.py` | Scan `application.yml` files and emit templates |
| `generate-dev-properties.py` | Generate environment property files |
| `generate-env-files.py` | Generate `.env` snippets for non-Java services |

See each script's `--help` and the examples under this directory if you are extending the service set.

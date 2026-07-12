# Token replacement service

Tiny JAR used at **container start** (and optionally on the host) to turn

`properties/<env>.application.ini` + each service's `application.properties.ini`

into a real `application.properties`.

Docker does this for you via `dockerfile/entrypoint.sh`. You only need this manually when running JARs on the host or debugging templates.

```bash
# build
mvn -pl ts-token-replacement-service -am package -DskipTests

# expand for an environment (writes under each service's src/main/resources/)
./ts-token-replacement-service/replace-tokens.sh docker
# or: dev | qa | prod
```

Copy the built jar to `jar/ts-token-replacement-service.jar` before `docker compose build` (see `./scripts/deploy.sh` / the Docker docs).

Templates live under `dockerfile/templates/<service>/` for images and often also under each `ts-*-service/` for local runs.

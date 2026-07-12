# jar/

Staged fat JARs for Docker builds. Populate with:

```bash
./scripts/build.sh all    # or mvn package
./scripts/deploy.sh all   # copies to jar/ts-<name>-service.jar
```

Dockerfiles expect the **unversioned** name (`ts-preserve-service.jar`), not `ts-preserve-service-1.0.jar`. `deploy.sh` renames on copy.

Also keep `ts-token-replacement-service.jar` here — every Java entrypoint runs it once at start to expand `properties/*.application.ini`.

Do not commit JARs; they are gitignored.

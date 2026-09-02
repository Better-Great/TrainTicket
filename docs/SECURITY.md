# Security and software supply chain

TrainTicket blocks High and Critical dependency, configuration, secret, and
container findings. Fix findings at their source; do not add blanket Trivy or
Gitleaks ignores. A narrowly scoped exception must name the finding, affected
component, owner, justification, and expiry date.

## CI gates

`.github/workflows/security.yml` runs on pull requests, pushes, dispatches, and
weekly:

- CodeQL for Java/Kotlin and JavaScript/TypeScript
- dependency review, failing at High severity
- full-history Gitleaks
- Trivy filesystem and configuration scans with SARIF upload
- Hadolint across every canonical Dockerfile

Actions are pinned to commit SHAs. Dependabot groups patch/minor updates while
leaving major upgrades in separate pull requests.

The image workflow publishes a full-SHA tag first, attaches BuildKit SBOM and
provenance attestations, scans the immutable digest, signs and verifies it with
GitHub OIDC, and only then creates `latest` or semver aliases. Pull requests do
not build the 46-image publish matrix.

## Local checks

```bash
mvn -B -ntp verify
(cd ts-ui-web && bun install --frozen-lockfile && bun run check && bun audit)
(cd ts-ticket-office-service && npm ci && npm audit --audit-level=high)
(cd ts-news-service && go test ./...)

docker run --rm -v "$PWD:/repo:ro" zricethezav/gitleaks:v8.30.0 \
  git --redact --no-banner /repo
docker run --rm -v "$PWD:/src:ro" -v trivy-cache:/root/.cache \
  aquasec/trivy:0.69.3 fs --config /src/trivy.yaml \
  --scanners vuln --severity HIGH,CRITICAL --exit-code 1 /src
docker run --rm -v "$PWD:/src:ro" -v trivy-cache:/root/.cache \
  aquasec/trivy:0.69.3 config --config /src/trivy.yaml \
  --severity HIGH,CRITICAL --exit-code 1 /src
```

Hadolint is run against `dockerfile/Dockerfile.Ts.*.Service` and
`ts-ui-web/Dockerfile`. The central Dockerfiles replace the removed, obsolete
service-local copies.

## Optional local SonarQube

SonarQube is local-only and does not replace the GitHub security gates. Do not
run it alongside the full TrainTicket stack on an approximately 8 GiB host.

1. Set Linux virtual memory once per boot:

   ```bash
   sudo sysctl -w vm.max_map_count=524288
   ```

2. Copy `.env.example` to `.env`, set a unique `SONAR_DB_PASSWORD`, then start:

   ```bash
   ./scripts/quality-scan.sh up
   ```

3. Open `http://localhost:9000`, change the initial administrator password,
   create a project token, and export it without committing it:

   ```bash
   export SONAR_TOKEN='...'
   ./scripts/quality-scan.sh scan
   ```

4. Stop while preserving data with `./scripts/quality-scan.sh down`. Use
   `purge` only when the database, extensions, and logs may be deleted.

Back up the database before upgrades:

```bash
docker compose -f docker-compose.quality.yml exec -T postgres \
  pg_dump -U "${SONAR_DB_USER:-sonar}" "${SONAR_DB_NAME:-sonar}" \
  > sonarqube-backup.sql
```

Also archive the `sonar-data` and `sonar-extensions` named volumes.

## SBOM and signature verification

Use the digest shown by Docker Hub or the publish job:

```bash
IMAGE=bettergreat/ts-gateway-service
DIGEST=sha256:...

docker buildx imagetools inspect "$IMAGE@$DIGEST" \
  --format '{{ json .SBOM }}'

cosign verify \
  --certificate-identity \
  "https://github.com/Better-Great/TrainTicket/.github/workflows/docker-publish.yml@refs/heads/main" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  "$IMAGE@$DIGEST"
```

For a release tag, replace the identity suffix with
`@refs/tags/v<version>`. Deploy by digest when reproducibility matters.

## Repository settings still requiring an administrator

- Protect `main` and require CI, Security, and image-publish checks as relevant.
- Require CodeQL/Trivy code-scanning findings to be resolved before merge.
- Enable Dependabot alerts and security updates.
- Enable GitHub secret scanning and push protection.
- Store `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` only as Actions secrets.
- Keep Actions OIDC enabled; no long-lived Cosign private key is used.

# Build:
#   docker build -t ts-avatar-service:latest .
#
# Runtime config: pass variables with `docker run --env-file .env` and/or mount
#   `-v /path/to/.env:/home/app/app/.env:ro`
# `.env` is gitignored and excluded from the build context (.dockerignore).
#
# Compose (repo root) uses dockerfile/Dockerfile.Ts.Avatar.Service.

FROM python:3.11-slim

LABEL com.trainticket.avatar.endpoints='{"service":"ts-avatar-service","health":"/health","avatar_post":"/api/v1/avatar"}'

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    HOME=/home/app \
    APP_HOME=/home/app/app

# Defaults only; override via env / env_file / mounted .env at runtime.
ENV AVATAR_SERVICE_PORT=${AVATAR_SERVICE_PORT}

RUN groupadd --system --gid 1000 app \
    && useradd --system --uid 1000 --gid app --create-home --home-dir /home/app app

WORKDIR ${APP_HOME}

COPY --chown=app:app requirements.txt ./
RUN pip install --no-cache-dir --root-user-action=ignore -r requirements.txt

COPY --chown=app:app . .
RUN mkdir -p received images \
    && chown -R app:app "${APP_HOME}"

USER app

EXPOSE ${AVATAR_SERVICE_PORT}

CMD ["sh", "-c", "exec gunicorn -w 2 -b 0.0.0.0:${AVATAR_SERVICE_PORT} --timeout 120 --chdir \"${APP_HOME}\" app:app"]

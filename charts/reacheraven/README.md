# Reacheraven Helm Chart

This chart deploys the Reacheraven platform and its optional dependencies (PostgreSQL, Redis and RabbitMQ).

## Usage

Add the repository and install the chart:

```bash
helm repo add reacheraven https://reacheraven.github.io/reacheraven
helm repo update
helm install my-reacheraven reacheraven/reacheraven
```

Configuration values can be overridden in `values.yaml` or via `--set` flags. Credentials in the default file are placeholders and should be replaced before running in production.

Common settings:

- `reacheraven.web.ingress.host` – domain for the web dashboard
- `reacheraven.api.ingress.host` – domain for the API service
- `global.publicWebUrl` – external URL of the web dashboard
- `global.publicApiUrl` – external URL of the API service
- `reacheraven.dependencies.postgresql.connectionString` – PostgreSQL connection string
- `reacheraven.dependencies.redis.connectionString` – Redis connection string
- `reacheraven.dependencies.rabbitmq.connectionString` – RabbitMQ connection string
- `reacheraven.api.env.jwtSecret` – secret used to sign JWT tokens
- `reacheraven.notifier.env.smtp.host` – SMTP server for notifications
- `reacheraven.scheduler.env.rabbitmqQueue` – queue name for scheduled jobs
- `reacheraven.ai.env.aiQueue` – queue name for AI requests

For additional options see the comments in `values.yaml`.


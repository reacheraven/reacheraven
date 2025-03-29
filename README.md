# Reacheraven Platform

This guide explains how to install the **Reacheraven** platform on a Kubernetes cluster using Helm. The chart includes all core components of the platform and, by default, installs PostgreSQL, Redis, and RabbitMQ as supporting services.

The Helm chart is hosted under the [Reacheraven GitHub organization](https://github.com/reacheraven) and can be added as a repository for Helm installations.

---

## Repository URL

```
https://reacheraven.github.io/reacheraven
```

---

## Prerequisites

Before installing, ensure the following:

- Helm 3.x is installed and configured
- You have access to a Kubernetes 1.20+ cluster
- Optional: Internet access to pull Docker images from Docker Hub and charts from Bitnami

---

## Step 1: Add the Reacheraven Helm Repository

```bash
helm repo add reacheraven https://reacheraven.github.io/reacheraven
helm repo update
```

This command adds the `reacheraven` Helm repository and updates your local index of available charts.

---

## Step 2: Install the Reacheraven Platform

```bash
helm install reacheraven reacheraven/reacheraven
```

By default, this command will:

- Deploy all core platform components:
  - `reacheraven-web`
  - `reacheraven-api`
  - `reacheraven-cron`
  - `reacheraven-sender`
- Deploy PostgreSQL (v17.4), Redis, and RabbitMQ using Bitnami's official charts

---

## Step 3: Customizing the Installation

You can override any default settings using `--set` flags. For example, if you want to disable the internal PostgreSQL, Redis, and RabbitMQ (e.g., to use external managed services), you can do:

```bash
helm install reacheraven reacheraven/reacheraven \
  --set postgresql.enabled=false \
  --set redis.enabled=false \
  --set rabbitmq.enabled=false
```

You may also customize image tags, environment variables, and service settings via the `values.yaml` file or CLI flags.

---

## Built-in Dependencies

By default, this chart will install the following Bitnami Helm charts as dependencies:

### PostgreSQL (v17.4)

- Chart: [bitnami/postgresql](https://artifacthub.io/packages/helm/bitnami/postgresql)
- Used as the primary relational database
- Default credentials and database name are configurable via `values.yaml`

### Redis

- Chart: [bitnami/redis](https://artifacthub.io/packages/helm/bitnami/redis)
- Used for caching and transient data
- Authentication is disabled by default

### RabbitMQ

- Chart: [bitnami/rabbitmq](https://artifacthub.io/packages/helm/bitnami/rabbitmq)
- Used as the event queue and messaging backbone
- Default user/password are set via `values.yaml`

You can disable any of these by setting `.enabled=false` in your Helm values.

---

## Example: Production Deployment

```bash
helm install reacheraven reacheraven/reacheraven \
  --set image.tag=v0.1.0 \
  --set postgresql.auth.postgresPassword=mysecret \
  --set rabbitmq.auth.password=anothersecret
```

You may also deploy this Helm chart in a CI/CD pipeline with Helmfile, ArgoCD, or FluxCD.

---

## Official Website and Documentation

For more detailed instructions, architecture diagrams, and advanced configuration, refer to:

- Website: [https://reacheraven.io](https://reacheraven.io)
- Documentation: [https://docs.reacheraven.io](https://docs.reacheraven.io)

These resources provide in-depth guides on using the platform, scaling in production environments, setting up external integrations, and troubleshooting common issues.

---

## Support

For issues or questions, open a GitHub issue at [github.com/reacheraven/reacheraven](https://github.com/reacheraven/reacheraven).

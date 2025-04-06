# Reacheraven Usage Guide

This document provides comprehensive instructions for **self-hosting** the Reacheraven platform. You will find guidelines to:

- Run Reacheraven locally with **Docker Compose** (ideal for development and testing).
- Deploy Reacheraven on **Kubernetes** using **Helm** (recommended for production).
- Configure each service and understand the available parameters.

## Overview

**Reacheraven** is a modern platform for observability, incident management, and real-time alerting. It allows you to monitor the health of systems and applications.

Official resources:
- **Website**: [https://reacheraven.io/](https://reacheraven.io/)
- **Documentation**: [https://docs.reacheraven.io/](https://docs.reacheraven.io/)
- **Demo**: [https://demo.reacheraven.io/](https://demo.reacheraven.io/)
- **Helm Repository**: [https://reacheraven.github.io/reacheraven/](https://reacheraven.github.io/reacheraven/)

## Running locally with Docker Compose

Docker Compose is the simplest way to test or develop Reacheraven. This method starts all containers (API, Web, Scheduler, Notifier, PostgreSQL, Redis, and RabbitMQ) on a single host.

### Prerequisites

- Docker installed (version 20+ recommended).
- Docker Compose (this guide references a `docker-compose.yml` with version `3.9`).

### Docker Compose

**Obtain the `docker-compose.yml`**  
   Clone the [official Reacheraven repository](https://github.com/reacheraven/reacheraven) or download the sample file directly.  
   > Adjust the example below to suit your environment.

**Start the services**  
   ```bash
   docker-compose up
   ```
   This command pulls all required images and starts the containers in detached mode.

**Access the application**  
   - The Reacheraven dashboard `http://localhost:3000/dashboard`.
   - The Reacheraven default status page `http://localhost:3000`.

**Shut down the services**  
   ```bash
   docker-compose down
   ```
   This stops and removes the containers.

### Parameters and Environment Variables (Docker Compose)

| Variable                | Description                                                      | Example / Default                                                          |
|-------------------------|------------------------------------------------------------------|----------------------------------------------------------------------------|
| `PORT`                  | Port on which the application container (API/Scheduler) listens  | `"8080"` / `"8081"`                                                        |
| `POSTGRES_URL`          | PostgreSQL connection string                                    | `postgres://user:pass@host:5432/db`   |
| `REDIS_URL`             | Redis connection string                                         | `redis://host:6379`                                                       |
| `JWT_SECRET`            | Secret key for signing JWT tokens *(sensitive)*                 | `my_secret_key`                                                            |
| `JWT_EXPIRATION_HOURS`  | Expiration time (in hours) for JWT tokens                       | `24`                                                                       |
| `TZ`                    | Timezone for the Scheduler                                      | `America/Sao_Paulo`                                                        |
| `RABBITMQ_URL`          | RabbitMQ connection string *(sensitive)*                        | `amqp://user:pass@host:5672`                                        |

Adjust these sensitive values (passwords, secret keys) for your production or staging environments.

---

## Installing on Kubernetes with Helm

For **production** environments, we recommend **Helm** (version 3 or later). The official Reacheraven chart:

- Automatically sets up pods for Web, API, Scheduler, and Notifier services.
- Installs PostgreSQL, Redis, and RabbitMQ (via Bitnami charts) by default.
- Allows extensive customization via `values.yaml` or `--set` flags.

### Overview and Helm Repository

The Reacheraven Helm chart is hosted at:  
[https://reacheraven.github.io/reacheraven/](https://reacheraven.github.io/reacheraven/)

Add the repository to your local Helm:

```bash
helm repo add reacheraven https://reacheraven.github.io/reacheraven
helm repo update
```

### Prerequisites (Helm)

- **Helm** 3.x
- Kubernetes >= 1.20
- Permissions to create Deployments, Services, Secrets, and ConfigMaps

### Basic Installation

```bash
helm install reacheraven reacheraven/reacheraven
```

This command will:

- Deploy these services:
  - **reacheraven-web** (frontend)
  - **reacheraven-api** (core API)
  - **reacheraven-scheduler** (task scheduler)
  - **reacheraven-notifier** (alerting/notification)
- Install **PostgreSQL**, **Redis**, and **RabbitMQ** using the official Bitnami charts.

Check deployment status:

```bash
helm status reacheraven
```

### Customizing the Installation

You can override any defaults using your own `values.yaml` or `--set` flags. For instance, to disable the built-in PostgreSQL, Redis, and RabbitMQ and use external services:

```bash
helm install reacheraven reacheraven/reacheraven \
  --set postgresql.enabled=false \
  --set redis.enabled=false \
  --set rabbitmq.enabled=false \
  --set api.env.POSTGRES_URL="postgres://user:pass@host:5432/db" \
  --set api.env.REDIS_URL="redis://host:6379" \
  --set scheduler.env.RABBITMQ_URL="amqp://user:pass@host:5672"
```

You can also customize image tags, environment variables, service types, replica counts, and more.

> **Tip**: For critical environments, store sensitive parameters (like passwords) in Kubernetes Secrets and reference them in Helm via `envFrom.secretRef`.

#### Example Override via `values.yaml`

Create a file named `my-values.yaml`:

```yaml
api:
  env:
    JWT_SECRET: "someSuperSecret123"
    POSTGRES_URL: "postgres://postgres:strongPassword@custom-postgres:5432/reacheraven?sslmode=disable"

postgresql:
  enabled: false

redis:
  enabled: false

rabbitmq:
  enabled: false
```

Then run:

```bash
helm install reacheraven reacheraven/reacheraven -f my-values.yaml
```

---

## Helm Chart Configuration Parameters

Below is a summary of key parameters in the chart’s default `values.yaml`:

| Parameter                           | Description                                                                         | Default Value                                                             |
|-------------------------------------|-------------------------------------------------------------------------------------|---------------------------------------------------------------------------|
| `replicaCount`                      | Number of replicas for each deployment (Web, API, Scheduler, Notifier)              | `1`                                                                       |
| `imagePullPolicy`                   | Docker image pull policy                                                            | `IfNotPresent`                                                            |
| `web.image`                         | Docker image for the Web service                                                   | `reacheraven/reacheraven-web`                                             |
| `web.tag`                           | Web service image version                                                           | `v1.0.14`                                                                 |
| `web.port`                          | Container port for the Web service                                                 | `3000`                                                                    |
| `web.service.type`                  | Kubernetes Service type for Web                                                    | `ClusterIP`                                                               |
| `web.service.port`                  | Kubernetes Service port for Web                                                    | `3000`                                                                    |
| `api.image`                         | Docker image for the API service                                                   | `reacheraven/reacheraven-api`                                             |
| `api.tag`                           | API image version                                                                  | `v1.0.8`                                                                  |
| `api.port`                          | Container port for the API                                                         | `8080`                                                                    |
| `api.env.PORT`                      | Application port for the API                                                       | `"8080"`                                                                  |
| `api.env.POSTGRES_URL`              | PostgreSQL connection URL *(sensitive)*                                            | `postgres://user:pass@host:5432/db`  |
| `api.env.REDIS_URL`                 | Redis connection URL                                                               | `redis://host:6379`                                                      |
| `api.env.JWT_SECRET`                | JWT secret *(sensitive)*                                                           | `my_secret_key`                                                           |
| `api.env.JWT_EXPIRATION_HOURS`      | JWT token expiration (hours)                                                       | `"24"`                                                                    |
| `api.service.type`                  | Kubernetes Service type for the API                                                | `ClusterIP`                                                               |
| `api.service.port`                  | Kubernetes Service port for the API                                                | `8080`                                                                    |
| `scheduler.image`                   | Docker image for the Scheduler                                                     | `reacheraven/reacheraven-scheduler`                                       |
| `scheduler.tag`                     | Scheduler image version                                                            | `v1.0.1`                                                                  |
| `scheduler.port`                    | Container port for the Scheduler                                                   | `8081`                                                                    |
| `scheduler.env.TZ`                  | Timezone for the Scheduler                                                         | `America/Sao_Paulo`                                                       |
| `scheduler.env.PORT`                | Scheduler application port                                                         | `"8081"`                                                                  |
| `scheduler.env.POSTGRES_URL`        | PostgreSQL connection URL for the Scheduler                                        | `postgres://user:pass@host:5432/db`  |
| `scheduler.env.REDIS_URL`           | Redis connection URL for the Scheduler                                             | `redis://host:6379`                                                      |
| `scheduler.env.RABBITMQ_URL`        | RabbitMQ connection URL *(sensitive)*                                              | `amqp://user:pass@host:5672`                                       |
| `scheduler.service.type`            | Kubernetes Service type for the Scheduler                                          | `ClusterIP`                                                               |
| `scheduler.service.port`            | Kubernetes Service port for the Scheduler                                          | `8081`                                                                    |
| `notifier.image`                    | Docker image for the Notifier                                                      | `reacheraven/reacheraven-notifier`                                        |
| `notifier.tag`                      | Notifier image version                                                             | `v1.0.1`                                                                  |
| `notifier.env.POSTGRES_URL`         | PostgreSQL connection URL for the Notifier *(sensitive)*                           | `postgres://user:pass@host:5432/db`  |
| `notifier.env.RABBITMQ_URL`         | RabbitMQ connection URL for the Notifier *(sensitive)*                             | `amqp://user:pass@host:5672`                                       |
| `notifier.service.type`             | Kubernetes Service type for the Notifier                                           | `ClusterIP`                                                               |
| `notifier.service.port`             | Kubernetes Service port for the Notifier                                           | `80`                                                                      |
| `postgresql.enabled`                | If `true`, installs PostgreSQL via Bitnami chart                                   | `true`                                                                    |
| `postgresql.persistence.enabled`    | If `true`, enables persistent storage for PostgreSQL                               | `true`                                                                    |
| `postgresql.persistence.size`       | PostgreSQL volume size                                                             | `8Gi`                                                                     |
| `redis.enabled`                     | If `true`, installs Redis via Bitnami chart                                        | `true`                                                                    |
| `redis.auth.enabled`                | If `true`, enables password authentication for Redis                               | `false`                                                                   |
| `redis.persistence.enabled`         | If `true`, enables persistent storage for Redis                                    | `true`                                                                    |
| `redis.persistence.size`            | Redis volume size                                                                  | `2Gi`                                                                     |
| `rabbitmq.enabled`                  | If `true`, installs RabbitMQ via Bitnami chart                                     | `true`                                                                    |
| `rabbitmq.auth.username`            | RabbitMQ username                                                                  | `user`                                                                    |
| `rabbitmq.auth.password`            | RabbitMQ password *(sensitive)*                                                    | `bitnami`                                                                 |
| `rabbitmq.persistence.enabled`      | If `true`, enables persistent storage for RabbitMQ                                 | `true`                                                                    |
| `rabbitmq.persistence.size`         | RabbitMQ volume size                                                               | `2Gi`                                                                     |
| `ingress.enabled`                   | If `true`, creates an Ingress resource for external access                         | `false`                                                                   |

Use `ingress.hosts`, `ingress.tls`, etc., to enable Ingress and expose Reacheraven externally. In production, consider using managed or dedicated instances for PostgreSQL and RabbitMQ, especially for high availability.

---

## 4. Support and References

- **Official Website**: [https://reacheraven.io/](https://reacheraven.io/)
- **Documentation**: [https://docs.reacheraven.io/](https://docs.reacheraven.io/)
- **Demo**: [https://demo.reacheraven.io/](https://demo.reacheraven.io/)
- **Helm Repository**: [https://reacheraven.github.io/reacheraven/](https://reacheraven.github.io/reacheraven/)
- **Source Code / Issues**: [https://github.com/reacheraven/reacheraven](https://github.com/reacheraven/reacheraven)

For questions or issues, open a ticket at:  
[https://github.com/reacheraven/reacheraven/issues](https://github.com/reacheraven/reacheraven/issues)

This documentation is open source. Feel free to contribute corrections or improvements by submitting a pull request in the official repository.
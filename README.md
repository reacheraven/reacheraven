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
  --set reacheraven.dependencies.postgresql.install=false \
  --set reacheraven.dependencies.redis.install=false \
  --set reacheraven.dependencies.rabbitmq.install=false \
  --set reacheraven.dependencies.postgresql.connectionString="postgresql://user:pass@host:5432/db" \
  --set reacheraven.dependencies.redis.connectionString="redis://user:pass@host:6379" \
  --set reacheraven.dependencies.rabbitmq.connectionString="amqp://user:pass@host:5672"
```

You can also customize image tags, environment variables, service types, replica counts, and more by editing the `reacheraven` section.

> **Tip**: For production environments, sensitive parameters (like credentials and connection strings) should be stored in Kubernetes Secrets and referenced using `envFrom.secretRef`.

#### Example Override via `values.yaml`

Create a file named `my-values.yaml`:

```yaml
reacheraven:
  dependencies:
    postgresql:
      install: false
      connectionString: "postgresql://postgres:strongPassword@custom-postgres:5432/reacheraven?sslmode=disable"
    redis:
      install: false
      connectionString: "redis://default:securePass@external-redis:6379"
    rabbitmq:
      install: false
      connectionString: "amqp://user:securePass@external-rabbitmq:5672/"
```

Then run:

```bash
helm install reacheraven reacheraven/reacheraven -f my-values.yaml
```
---

## Helm Chart Configuration Parameters

Below is a summary of key parameters in the chart’s default `values.yaml`:

| **Parameter**                                       | **Description**                                                                    | **Default**                                                                                         |
|-----------------------------------------------------|------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| **global.imagePullPolicy**                          | Pull policy for all Reacheraven containers                                         | `IfNotPresent`                                                                                      |
| **global.timezone**                                 | Default timezone for the entire application                                        | `UTC`                                                                                                |
| **reacheraven.web.image**                           | Docker image for the Web (frontend) service                                        | `reacheraven/reacheraven-web`                                                                       |
| **reacheraven.web.tag**                             | Web service image version                                                          | `v1.0.14`                                                                                           |
| **reacheraven.web.replicas**                        | Number of replicas for the Web service                                             | `1`                                                                                                 |
| **reacheraven.web.service.type**                    | Kubernetes Service type for the Web frontend                                       | `ClusterIP`                                                                                         |
| **reacheraven.api.image**                           | Docker image for the API service                                                   | `reacheraven/reacheraven-api`                                                                       |
| **reacheraven.api.tag**                             | API service image version                                                          | `v1.0.8`                                                                                            |
| **reacheraven.api.replicas**                        | Number of replicas for the API service                                             | `2`                                                                                                 |
| **reacheraven.api.service.type**                    | Kubernetes Service type for the API                                                | `ClusterIP`                                                                                         |
| **reacheraven.scheduler.image**                     | Docker image for the Scheduler service                                             | `reacheraven/reacheraven-scheduler`                                                                 |
| **reacheraven.scheduler.tag**                       | Scheduler image version                                                            | `v1.0.1`                                                                                            |
| **reacheraven.scheduler.replicas**                  | Number of replicas for the Scheduler                                               | `1`                                                                                                 |
| **reacheraven.scheduler.service.type**              | Kubernetes Service type for the Scheduler                                          | `ClusterIP`                                                                                         |
| **reacheraven.notifier.image**                      | Docker image for the Notifier service                                              | `reacheraven/reacheraven-notifier`                                                                  |
| **reacheraven.notifier.tag**                        | Notifier image version                                                             | `v1.0.1`                                                                                            |
| **reacheraven.notifier.replicas**                   | Number of replicas for the Notifier                                                | `1`                                                                                                 |
| **reacheraven.notifier.service.type**               | Kubernetes Service type for the Notifier                                           | `ClusterIP`                                                                                         |
| **reacheraven.dependencies.postgresql.install**     | If `true`, installs the Bitnami PostgreSQL subchart                                | `true`                                                                                              |
| **reacheraven.dependencies.postgresql.connectionString** | PostgreSQL connection string used by the app                                     | `postgresql://user:pass@host:5432/db`         |
| **reacheraven.dependencies.redis.install**          | If `true`, installs the Bitnami Redis subchart                                     | `true`                                                                                              |
| **reacheraven.dependencies.redis.connectionString** | Redis connection string used by the app                                           | `redis://user:pass@host:6379`                                          |
| **reacheraven.dependencies.rabbitmq.install**       | If `true`, installs the Bitnami RabbitMQ subchart                                  | `true`                                                                                              |
| **reacheraven.dependencies.rabbitmq.connectionString** | RabbitMQ connection string used by the app                                      | `amqp://user:pass@host:5672/`                                          |
| **postgresql.auth.username**                        | PostgreSQL username                                                                | `postgres`                                                                                          |
| **postgresql.auth.password**                        | PostgreSQL password *(sensitive)*                                                  | `changeme`                                                                                          |
| **postgresql.auth.database**                        | PostgreSQL database name                                                           | `reacheraven`                                                                                       |
| **postgresql.primary.persistence.enabled**          | If `true`, enables persistent storage for PostgreSQL                               | `true`                                                                                              |
| **postgresql.primary.persistence.size**             | Disk size for PostgreSQL persistent volume                                         | `5Gi`                                                                                               |
| **redis.architecture**                              | Redis architecture (e.g., standalone/replication)                                  | `standalone`                                                                                        |
| **redis.auth.username**                             | Redis ACL username                                                                 | `default`                                                                                           |
| **redis.auth.password**                             | Redis password *(sensitive)*                                                       | `changeme`                                                                                          |
| **redis.master.persistence.enabled**                | If `true`, enables persistent storage for Redis                                    | `true`                                                                                              |
| **redis.master.persistence.size**                   | Disk size for Redis persistent volume                                             | `2Gi`                                                                                               |
| **redis.master.extraEnvVars**                       | Additional environment variables for Redis Master                                 | `[ { name: ALLOW_EMPTY_PASSWORD, value: "no" } ]`                                                   |
| **rabbitmq.auth.username**                          | RabbitMQ username                                                                  | `user`                                                                                              |
| **rabbitmq.auth.password**                          | RabbitMQ password *(sensitive)*                                                    | `changeme`                                                                                          |
| **rabbitmq.extraEnvVars**                           | Additional environment variables for RabbitMQ                                      | `[ { name: RABBITMQ_MANAGEMENT_ALLOW_WEB_ACCESS, value: "yes" } ]`                                  |
| **rabbitmq.persistence.enabled**                    | If `true`, enables persistent storage for RabbitMQ                                 | `true`                                                                                              |
| **rabbitmq.persistence.size**                       | Disk size for RabbitMQ persistent volume                                           | `2Gi`                                                                                               |


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
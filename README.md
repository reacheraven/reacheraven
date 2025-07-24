# Reacheraven Usage Guide

This document provides comprehensive instructions for **self-hosting** the Reacheraven platform. You will find guidelines to:

Key features:
- Self-hosted observability platform with multi-tenant support
- Real-time monitoring and incident notifications

- Optional AI-powered insights

- Run Reacheraven locally with **Docker Compose** (ideal for development and testing).
- Deploy Reacheraven on **Kubernetes** using **Helm** (recommended for production).
- Configure each service and understand the available parameters.

## Overview

**Reacheraven** is an AI-integrated, self-hosted observability platform that delivers real-time alerts, automated status updates and advanced analytics—empowering multi-tenant teams to proactively monitor system health and communicate incidents with confidence.

Official resources:
- **Website**: [https://reacheraven.io/](https://reacheraven.io/)
- **Documentation**: [https://docs.reacheraven.io/](https://docs.reacheraven.io/)
- **Demo**: [https://web.reacheraven.io/](https://web.reacheraven.io/)
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
helm install reacheraven reacheraven/reacheraven \
     --set reacheraven.web.ingress="https://reacheraven-web-host" \
     --set reacheraven.api.ingress="https://reacheraven-api-host" \
     --namespace reacheraven
```

> Note: By default, the platform is installed and exposed via an ingress. If you need to apply customizations—such as using Istio, adding annotations for ingress types, or other ingress adjustments - please refer to [Advanced Ingress Configuration](https://docs.reacheraven.io/#/installation/advanced-exposition) in docs for further details. 


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


| **Parameter**                                             | **Description**                                                                                                                         | **Default**                                                                                                                       |
| --------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **global.imagePullPolicy**                                | Pull policy for all Reacheraven containers                                                                                              | `IfNotPresent`                                                                                                                    |
| **global.timezone**                                       | Default timezone for the entire application                                                                                             | `UTC`                                                                                                                             |
| **global.affinity**                                       | Kubernetes node affinity rules                                                                                                          | `{}`                                                                                                                              |
| **global.tolerations**                                    | Node tolerations                                                                                                                        | `[]`                                                                                                                              |
| **global.nodeSelector**                                   | Custom node selectors                                                                                                                   | `{}`                                                                                                                              |
| **reacheraven.web.image**                                 | Docker image for the Web (frontend) service                                                                                             | `reacheraven/reacheraven-web`                                                                                                       |
| **reacheraven.web.tag**                                   | Web service image version                                                                                                               | `v1.0.17`                                                                                                                         |
| **reacheraven.web.replicas**                              | Number of replicas for the Web service                                                                                                  | `1`                                                                                                                               |
| **reacheraven.web.service.type**                          | Kubernetes Service type for the Web frontend                                                                                            | `ClusterIP`                                                                                                                       |
| **reacheraven.web.api**                                   | Backend API configuration for the Web service (set to internal or external URL as needed)                                                 | `{}`                                                                                                                              |
| **reacheraven.web.ingress.enabled**                       | Enables the Ingress resource for the Web service                                                                                        | `true`                                                                                                                            |
| **reacheraven.web.ingress.host**                          | Hostname where the Web application will be accessible                                                                                   | `"reacheraven-web.example.com"`                                                                                                   |
| **reacheraven.web.ingress.paths**                         | List of routing paths. Example: one path for the root (`/`) using a `Prefix` path type                                                   | `[ { path: "/", pathType: "Prefix" } ]`                                                                                             |
| **reacheraven.web.ingress.tls**                           | TLS configuration for secure HTTPS access (e.g., specify hosts and certificate secret)                                                  | `{}`                                                                                                                              |
| **reacheraven.web.ingress.annotations**                   | Custom annotations for the Ingress resource (e.g., for Nginx, GKE, AWS ALB, or Azure Application Gateway)                                  | `{}`                                                                                                                              |
| **reacheraven.web.istio.enabled**                         | Enables Istio integration for the Web service via VirtualService                                                                         | `false`                                                                                                                           |
| **reacheraven.web.istio.hosts**                           | List of custom hostnames for the Istio VirtualService (if not specified, falls back to the ingress host)                                    | `{}`                                                                                                                              |
| **reacheraven.web.istio.http**                            | HTTP routing configuration for the Istio VirtualService                                                                                 | `{}`                                                                                                                              |
| **reacheraven.api.image**                                 | Docker image for the API service                                                                                                          | `reacheraven/reacheraven-api`                                                                                                       |
| **reacheraven.api.tag**                                   | API service image version                                                                                                                 | `v1.0.10`                                                                                                                         |
| **reacheraven.api.replicas**                              | Number of replicas for the API service                                                                                                  | `2`                                                                                                                               |
| **reacheraven.api.service.type**                          | Kubernetes Service type for the API service                                                                                             | `ClusterIP`                                                                                                                       |
| **reacheraven.api.ingress.enabled**                       | Enables the Ingress resource for the API service                                                                                          | `true`                                                                                                                            |
| **reacheraven.api.ingress.host**                          | Hostname where the API application will be accessible                                                                                   | `"reacheraven-api.example.com"`                                                                                                   |
| **reacheraven.api.ingress.paths**                         | List of routing paths for the API (e.g., one path for the root (`/`) using a `Prefix` path type)                                           | `[ { path: "/", pathType: "Prefix" } ]`                                                                                             |
| **reacheraven.api.ingress.tls**                           | TLS configuration for the API ingress (e.g., specify hosts and TLS certificate secret)                                                   | `{}`                                                                                                                              |
| **reacheraven.api.ingress.annotations**                   | Custom annotations for the API Ingress (e.g., settings for Nginx, GKE, AWS ALB, or Azure Application Gateway)                               | `{}`                                                                                                                              |
| **reacheraven.api.istio.enabled**                         | Enables Istio integration for the API service via VirtualService                                                                          | `false`                                                                                                                           |
| **reacheraven.api.istio.hosts**                           | List of custom hostnames for the API Istio VirtualService (fallback to ingress host if not set)                                             | `{}`                                                                                                                              |
| **reacheraven.api.istio.http**                            | HTTP routing configuration for the API Istio VirtualService                                                                               | `{}`                                                                                                                              |
| **reacheraven.scheduler.image**                           | Docker image for the Scheduler service                                                                                                  | `reacheraven/reacheraven-scheduler`                                                                                                 |
| **reacheraven.scheduler.tag**                             | Scheduler image version                                                                                                                   | `v1.0.1`                                                                                                                          |
| **reacheraven.scheduler.replicas**                        | Number of replicas for the Scheduler service                                                                                             | `1`                                                                                                                               |
| **reacheraven.scheduler.service.type**                    | Kubernetes Service type for the Scheduler service                                                                                         | `ClusterIP`                                                                                                                       |
| **reacheraven.notifier.image**                            | Docker image for the Notifier service                                                                                                   | `reacheraven/reacheraven-notifier`                                                                                                  |
| **reacheraven.notifier.tag**                              | Notifier image version                                                                                                                    | `v1.0.1`                                                                                                                          |
| **reacheraven.notifier.replicas**                         | Number of replicas for the Notifier service                                                                                              | `1`                                                                                                                               |
| **reacheraven.notifier.service.type**                     | Kubernetes Service type for the Notifier service                                                                                         | `ClusterIP`                                                                                                                       |
| **reacheraven.dependencies.postgresql.install**         | Whether to install the Bitnami PostgreSQL subchart                                                                                       | `true`                                                                                                                            |
| **reacheraven.dependencies.postgresql.connectionString**  | PostgreSQL connection string (should be provided as a Kubernetes Secret in production)                                                    | `"postgresql://postgres:changeme@reacheraven-postgresql-hl:5432/reacheraven?sslmode=disable"`                                     |
| **reacheraven.dependencies.redis.install**              | Whether to install the Bitnami Redis subchart                                                                                           | `true`                                                                                                                            |
| **reacheraven.dependencies.redis.connectionString**       | Redis connection string (should be provided as a Kubernetes Secret in production)                                                         | `"redis://default:changeme@reacheraven-redis-headless:6379"`                                                                        |
| **reacheraven.dependencies.rabbitmq.install**           | Whether to install the Bitnami RabbitMQ subchart                                                                                        | `true`                                                                                                                            |
| **reacheraven.dependencies.rabbitmq.connectionString**    | RabbitMQ connection string (should be provided as a Kubernetes Secret in production)                                                      | `"amqp://user:changeme@reacheraven-rabbitmq-headless:5672/"`                                                                        |
| **postgresql.auth.username**                              | PostgreSQL username                                                                                                                      | `postgres`                                                                                                                        |
| **postgresql.auth.password**                              | PostgreSQL password *(sensitive)*                                                                                                        | `changeme`                                                                                                                        |
| **postgresql.auth.database**                              | PostgreSQL database name                                                                                                                 | `reacheraven`                                                                                                                     |
| **postgresql.primary.persistence.enabled**                | Enables persistent storage for PostgreSQL                                                                                                | `true`                                                                                                                            |
| **postgresql.primary.persistence.size**                   | Disk size for PostgreSQL persistent volume                                                                                               | `5Gi`                                                                                                                             |
| **redis.architecture**                                    | Redis architecture (e.g., standalone or replication)                                                                                     | `standalone`                                                                                                                      |
| **redis.auth.username**                                   | Redis ACL username                                                                                                                       | `default`                                                                                                                         |
| **redis.auth.password**                                   | Redis password *(sensitive)*                                                                                                             | `changeme`                                                                                                                        |
| **redis.master.persistence.enabled**                      | Enables persistent storage for Redis                                                                                                     | `true`                                                                                                                            |
| **redis.master.persistence.size**                         | Disk size for Redis persistent volume                                                                                                    | `2Gi`                                                                                                                             |
| **redis.master.extraEnvVars**                             | Additional environment variables for Redis Master                                                                                        | `[ { name: ALLOW_EMPTY_PASSWORD, value: "no" } ]`                                                                                   |
| **rabbitmq.auth.username**                                | RabbitMQ username                                                                                                                        | `user`                                                                                                                            |
| **rabbitmq.auth.password**                                | RabbitMQ password *(sensitive)*                                                                                                          | `changeme`                                                                                                                        |
| **rabbitmq.extraEnvVars**                                 | Additional environment variables for RabbitMQ                                                                                            | `[ { name: RABBITMQ_MANAGEMENT_ALLOW_WEB_ACCESS, value: "yes" } ]`                                                                  |
| **rabbitmq.persistence.enabled**                          | Enables persistent storage for RabbitMQ                                                                                                  | `true`                                                                                                                            |
| **rabbitmq.persistence.size**                             | Disk size for RabbitMQ persistent volume                                                                                                 | `2Gi`                                                                                                                             |

Use `ingress.hosts`, `ingress.tls`, etc., to enable Ingress and expose Reacheraven externally. In production, consider using managed or dedicated instances for PostgreSQL and RabbitMQ, especially for high availability.

---

## 4. Support and References

- **Official Website**: [https://reacheraven.io/](https://reacheraven.io/)
- **Documentation**: [https://docs.reacheraven.io/](https://docs.reacheraven.io/)
- **Demo**: [https://web.reacheraven.io/](https://web.reacheraven.io/)
- **Helm Repository**: [https://reacheraven.github.io/reacheraven/](https://reacheraven.github.io/reacheraven/)
- **Source Code / Issues**: [https://github.com/reacheraven/reacheraven](https://github.com/reacheraven/reacheraven)

For questions or issues, open a ticket at:  
[https://github.com/reacheraven/reacheraven/issues](https://github.com/reacheraven/reacheraven/issues)

This documentation is open source. Feel free to contribute corrections or improvements by submitting a pull request in the official repository.
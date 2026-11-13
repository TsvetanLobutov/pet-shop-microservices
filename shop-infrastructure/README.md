# 🐾 Pet Shop Microservices Architecture

Welcome to my full-stack, event-driven e-commerce platform. This repository is the central hub for the entire system: it links to every service and contains the infrastructure needed to run it.

---

## 🏗️ System Architecture

| Component | Repository | Tech |
|-----------|------------|------|
| **Frontend** | [shop-frontend](https://github.com/TsvetanLobutov/shop-frontend) | React.js, Vite |
| **API Gateway** | [api-gateway](https://github.com/TsvetanLobutov/api-gateway) | Spring Cloud Gateway, JWT security |
| **Auth Service** | [auth-service](https://github.com/TsvetanLobutov/auth-service) | Spring Boot, PostgreSQL, JWT generation |
| **Product Service** | [product-service](https://github.com/TsvetanLobutov/product-service) | Spring Boot, PostgreSQL, Kafka consumer |
| **Order Service** | [order-service](https://github.com/TsvetanLobutov/order-service) | Spring Boot, PostgreSQL, Kafka producer |
| **Review Service** | [review-service](https://github.com/TsvetanLobutov/review-service) | Spring Boot, MongoDB |
| **Notification Service** | [notification-service](https://github.com/TsvetanLobutov/notification-service) | Spring Boot, Kafka consumer |

### Request flow

```
React Frontend ──► API Gateway (JWT) ──► auth / product / order / review services

order-service ──► Kafka ──┬──► product-service       (updates stock)
                          └──► notification-service  (sends notifications)
```

---

## 🚀 Infrastructure & Deployment

This repository contains the `docker-compose.yml` and the `k8s/` (Kubernetes) manifests required to run the entire stack.

### How to Run Locally (Kubernetes)

> Requires Docker, kubectl and Minikube.

**1. Start Minikube**

```bash
minikube start --memory=7000mb
```

**2. Apply the infrastructure (databases and Kafka)**

```bash
kubectl apply -f shop-infrastructure/k8s/infrastructure.yaml
```

**3. Deploy the microservices**

```bash
kubectl apply -f shop-infrastructure/k8s/services.yaml
```

**4. Deploy the frontend**

```bash
kubectl apply -f shop-infrastructure/k8s/frontend.yaml
```

**5. Access the application**

```bash
minikube service shop-frontend
```

---

## 🛠️ Troubleshooting

**Kafka starts but services cannot connect** (`Connection to node -1 could not be established`)

Kafka runs in KRaft mode inside a single pod, so the controller quorum must point to `localhost`:

```yaml
- name: KAFKA_CONTROLLER_QUORUM_VOTERS
  value: "1@localhost:9093"
```

Once the Kafka log shows `Kafka Server started`, restart the services that use it:

```bash
kubectl rollout restart deployment order-service
```

---

## 🧰 Technology Stack

- Java 21 / Spring Boot 4
- React.js / Vite
- Apache Kafka (event-driven pub/sub)
- PostgreSQL and MongoDB
- Docker and Kubernetes

---

## 👤 Author

**Tsvetan Lobutov**: [GitHub Profile](https://github.com/TsvetanLobutov)
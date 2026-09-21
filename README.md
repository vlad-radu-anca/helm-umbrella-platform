# EMS Platform Helm Charts

Production-grade Helm charts for a multi-component EMS (Element Management System) platform. Built during production client work; sanitized for portfolio use.

Charts are published as OCI artifacts to GitHub Container Registry (`ghcr.io/vlad-radu-anca`) and consumed by the umbrella chart `ems-platform-stack` as a one-click deployment.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ems-platform-stack (umbrella)                    │
│          One-click install: all 22 subcharts as OCI deps            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─── Ingress / Gateway ────────────────────────────────────────┐   │
│  │  ngf (NGINX Gateway Fabric)  │  cert-manager (TLS)          │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─── API & Backend ────────────┐  ┌─── Frontend ──────────────┐   │
│  │  apigw (API Gateway)         │  │  emsui (React SPA)        │   │
│  │  diesel (Akka/Play backend)  │  │  emshelpcenter            │   │
│  │  cts (Config & Template Svc) │  │  swagger (OpenAPI docs)   │   │
│  │  toc (Topology & Ops Center) │  └───────────────────────────┘   │
│  └──────────────────────────────┘                                   │
│                                                                     │
│  ┌─── Messaging ────────────────┐  ┌─── Data Layer ────────────┐   │
│  │  kafka-cluster (Strimzi)     │  │  mongo (ReplicaSet)       │   │
│  │  kafka-mirror                │  │  elasticsearch            │   │
│  │  topicOperator               │  │  kibana                   │   │
│  │  event-collector             │  └───────────────────────────┘   │
│  └──────────────────────────────┘                                   │
│                                                                     │
│  ┌─── Device Management ────────────────────────────────────────┐   │
│  │  GenieACS (TR-069 ACS): cwmp │ nbi │ gui │ fs               │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─── Supporting Services ──────────────────────────────────────┐   │
│  │  snmpproxy │ sftp-server │ spark │ tus │ misc               │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## Subcharts

| Chart | Purpose |
|---|---|
| `apigw` | API Gateway — JWT validation, routing, rate limiting |
| `diesel` | Core backend — Akka/Play microservice |
| `cts` | Configuration and Template Service |
| `toc` | Topology and Operations Center |
| `emsui` | React SPA frontend |
| `emshelpcenter` | Help center documentation |
| `swagger` | OpenAPI documentation |
| `kafka-cluster` | Strimzi-managed Kafka cluster with TLS |
| `kafka-mirror` | Kafka MirrorMaker2 for cross-cluster replication |
| `topicOperator` | Strimzi Topic Operator |
| `event-collector` | Real-time event stream processor |
| `mongo` | MongoDB ReplicaSet (3 nodes) |
| `elasticsearch` | Elasticsearch 7.x with persistent storage |
| `kibana` | Log and metric dashboards |
| `ngf` | NGINX Gateway Fabric (Kubernetes Gateway API) |
| `ems-cert-manager` | cert-manager integration and TLS certificates |
| `sftp-server` | Managed SFTP server for bulk file transfers |
| `spark` | Event analytics and aggregation |
| `tus` | Resumable file upload server (tus.io protocol) |
| `misc` | Shared jobs and init resources |
| `upgrade-stack` | Rolling upgrade helper jobs |
| `ems-platform-stack` | **Umbrella chart** — deploys all of the above |

## Multi-platform support (on-prem vs AWS)

Every chart supports two deployment targets via a single flag:

```yaml
global:
  platform: onprem   # or "aws"
```

Templates branch on `{{ include "platform" . }}` to produce the correct configuration:

| Resource | `onprem` | `aws` |
|---|---|---|
| Storage class | `local-path` | `ebs-csi-encrypted-gp3` |
| Secret backend | Kubernetes Secrets | AWS Secrets Manager (CSI driver) |
| MongoDB URI | On-prem replica set | RDS / DocumentDB |
| Keycloak URL | Internal DNS | AWS-managed endpoint |
| Node selector | Static labels | Karpenter: `karpenter-node: ems-autoscalernode-large` |

## CI/CD pipeline

```
Pull Request
  ├── detect-changes   — diff to find modified charts
  ├── linter           — helm lint on changed charts
  ├── dry-run          — helm install --dry-run on KinD cluster
  │     └── Dynamic CRD setup: Strimzi, cert-manager, Gateway API, NGINX
  └── release-validation — ct lint + values.schema.json validation + helm-unittest

Merge to master
  ├── version-bump     — semver bump from commit keywords (major/minor/patch)
  ├── publish-chart    — helm package + helm push → oci://ghcr.io/vlad-radu-anca
  └── update-umbrella  — helm dependency update + publish ems-platform-stack
```

Semantic version bump is automatic based on commit message keywords:

| Keyword | Bump type |
|---|---|
| `major`, `breaking` | `1.x.x → 2.0.0` |
| `minor`, `feat`, `feature` | `1.0.x → 1.1.0` |
| `patch`, `fix`, `bugfix` (default) | `1.0.0 → 1.0.1` |

## Schema validation

Every chart has a `values.schema.json` (JSON Schema Draft-7) that validates values at `helm install` time. The root `chart_schema.yaml` validates `Chart.yaml` structure via yamale. Both run in CI on every PR.

Example constraint (apigw):
```json
{
  "replicaCount": { "type": "integer", "minimum": 1 },
  "service": {
    "type": { "enum": ["ClusterIP", "NodePort", "LoadBalancer"] },
    "port":  { "type": "integer", "minimum": 1, "maximum": 65535 }
  }
}
```

## Quick start

```bash
# Pull the umbrella chart from GHCR
helm pull oci://ghcr.io/vlad-radu-anca/ems-platform-stack --version 0.7.8

# Install on-prem
helm upgrade --install ems-platform oci://ghcr.io/vlad-radu-anca/ems-platform-stack \
  --version 0.7.8 \
  --namespace ems-platform \
  --create-namespace \
  --set global.platform=onprem \
  --set global.loadBalancerIP=<YOUR_LB_IP> \
  --set diesel.data.diesel_secret=$DIESEL_SECRET \
  --set diesel.data.ems_client_secret=$EMS_CLIENT_SECRET

# Install on AWS (EKS)
helm upgrade --install ems-platform oci://ghcr.io/vlad-radu-anca/ems-platform-stack \
  --version 0.7.8 \
  --namespace ems-platform \
  --create-namespace \
  --set global.platform=aws \
  --set global.loadBalancerIP=<YOUR_LB_IP>
```

## Skills demonstrated

- Helm umbrella chart with 22 subcharts published as OCI artifacts to GHCR
- Platform abstraction: single flag selects on-prem vs AWS (node selectors, storage classes, secret backends, endpoints)
- JSON Schema validation (`values.schema.json`) per chart — schema errors caught at `helm install` time
- Semantic versioning automation via GitHub Actions commit keyword parsing
- Full CI/CD: lint → dry-run on KinD → schema validation → OCI publish → umbrella update
- Strimzi Kafka operator, cert-manager, NGINX Gateway Fabric (Kubernetes Gateway API)
- Helm unit tests (`helm-unittest`) per chart

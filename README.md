# Platform Helm Charts

Production-grade Helm charts for a multi-service platform: an API gateway, backend services, a React front end, Kafka, MongoDB, Elasticsearch and the supporting services around them. Built during production client work and sanitized for portfolio use.

Charts are published as OCI artifacts to GitHub Container Registry (`ghcr.io/vlad-radu-anca`). The umbrella chart `platform-stack` bundles 19 of them into a single install; the rest are deployed on their own.

## Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                     platform-stack (umbrella)                      │
│             One install: 19 subcharts vendored as OCI deps         │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌─── Ingress / Gateway ───────────────────────────────────────┐   │
│  │  ngf (NGINX Gateway Fabric)  │  cert-service (TLS certs)    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                    │
│  ┌─── API & Backend ────────────┐  ┌─── Frontend ─────────────┐    │
│  │  apigw (API Gateway)         │  │  webui (React SPA)       │    │
│  │  core-api (Akka/Play)        │  │  helpcenter              │    │
│  │  cts (Config & Templates)    │  │  swagger (OpenAPI docs)  │    │
│  │  toc (Topology & Ops)        │  └──────────────────────────┘    │
│  └──────────────────────────────┘                                  │
│                                                                    │
│  ┌─── Messaging ────────────────┐  ┌─── Data Layer ───────────┐    │
│  │  kafka-mirror                │  │  mongo (ReplicaSet)      │    │
│  │  topicOperator               │  │  elasticsearch           │    │
│  │  event-collector             │  │  kibana                  │    │
│  └──────────────────────────────┘  └──────────────────────────┘    │
│                                                                    │
│  ┌─── Supporting Services ─────────────────────────────────────┐   │
│  │  sftp-server │ spark │ tus │ misc                           │   │
│  └─────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────┘
```

## Charts

| Chart | Purpose | In umbrella |
|---|---|---|
| `apigw` | API gateway: JWT validation, routing, rate limiting | yes |
| `core-api` | Core backend, an Akka/Play microservice | yes |
| `cts` | Configuration and template service | yes |
| `toc` | Topology and operations service | yes |
| `webui` | React single page app | yes |
| `helpcenter` | Help center documentation site | yes |
| `swagger` | OpenAPI documentation | yes |
| `cert-service` | Certificate management service | yes |
| `ngf` | NGINX Gateway Fabric (Kubernetes Gateway API) | yes |
| `kafka-mirror` | Kafka MirrorMaker2 for cross-cluster replication | yes |
| `topicOperator` | Strimzi Topic Operator | yes |
| `event-collector` | Real-time event stream processor | yes |
| `mongo` | MongoDB replica set | yes |
| `elasticsearch` | Elasticsearch with persistent storage | yes |
| `kibana` | Log and metric dashboards | yes |
| `sftp-server` | SFTP server for bulk file transfers | yes |
| `spark` | Event analytics and aggregation | yes |
| `tus` | Resumable file uploads (tus.io protocol) | yes |
| `misc` | Shared jobs and init resources | yes |
| `kafka-cluster` | Strimzi-managed Kafka cluster with TLS | no |
| `certs` | Shared TLS certificate resources | no |
| `genieacs*` | GenieACS: `cwmp`, `nbi`, `gui`, `fs` | no |
| `snmpproxy` | SNMP proxy | no |
| `mongoexpress` | MongoDB web admin | no |
| `upgrade-stack` | Rolling upgrade helper jobs | no |
| `platform-stack` | **Umbrella chart**, deploys everything marked yes | n/a |

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
| Node selector | Static labels | Karpenter: `karpenter-node: autoscalernode-large` |

## CI/CD pipeline

```
Pull request
  ├── detect-changes      diff to find modified charts
  ├── linter              helm lint on changed charts
  ├── dry-run             helm install --dry-run on a KinD cluster
  │     └── CRDs set up on the fly: Strimzi, cert-manager, Gateway API, NGINX
  └── release-validation  ct lint, values.schema.json validation, helm-unittest

Merge to main
  ├── version-bump        semver bump from commit keywords (major/minor/patch)
  ├── publish-chart       helm package + helm push to oci://ghcr.io/vlad-radu-anca
  └── update-umbrella     verify dependencies exist, helm dependency update,
                          publish platform-stack
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
helm pull oci://ghcr.io/vlad-radu-anca/platform-stack --version <VERSION>

# Install on-prem. Subchart values sit under the dependency name, e.g. core-api-helm.
helm upgrade --install platform oci://ghcr.io/vlad-radu-anca/platform-stack \
  --version <VERSION> \
  --namespace platform \
  --create-namespace \
  --set global.platform=onprem \
  --set global.loadBalancerIP=<YOUR_LB_IP> \
  --set core-api-helm.coreApi.data.diesel_secret=$CORE_API_SECRET \
  --set core-api-helm.coreApi.data.platform_client_secret=$PLATFORM_CLIENT_SECRET

# Install on AWS (EKS)
helm upgrade --install platform oci://ghcr.io/vlad-radu-anca/platform-stack \
  --version <VERSION> \
  --namespace platform \
  --create-namespace \
  --set global.platform=aws \
  --set global.loadBalancerIP=<YOUR_LB_IP>
```

## Skills demonstrated

- Helm umbrella chart bundling 19 subcharts, all published as OCI artifacts to GHCR
- Platform abstraction: single flag selects on-prem vs AWS (node selectors, storage classes, secret backends, endpoints)
- JSON Schema validation (`values.schema.json`) per chart, so bad values fail at `helm install` time
- Semantic versioning automation via GitHub Actions commit keyword parsing
- Full CI/CD: lint, dry-run on KinD, schema validation, OCI publish, umbrella update
- Strimzi Kafka operator, cert-manager, NGINX Gateway Fabric (Kubernetes Gateway API)
- Helm unit tests (`helm-unittest`) per chart

## License

[Apache-2.0](LICENSE)

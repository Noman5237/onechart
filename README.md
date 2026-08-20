# onechart

A Helm chart for Kubernetes Application Deployment.

## Prerequisites

- Kubernetes 1.16+
- Helm 3+

## Installation

To install the chart with the release name `my-release`:

```sh
helm install my-release ./onechart
```

## Uninstallation

To uninstall/delete the `my-release` deployment:

```sh
helm delete my-release
```

## Configuration

The following table lists the configurable parameters of the `onechart` chart and their default values.

| Parameter                        | Description                                     | Default                        |
| -------------------------------- | ----------------------------------------------- | ------------------------------ |
| `nameOverride`                   | Override the name of the chart                  | `frontend`                     |
| `replicaCount`                   | Number of replicas                              | `1`                            |
| `kind`                           | Kubernetes resource kind                        | `StatefulSet`                  |
| `image.repository`               | Image repository                                | `nginx`                        |
| `image.pullPolicy`               | Image pull policy                               | `Always`                       |
| `image.tag`                      | Image tag                                       | `""`                           |
| `imagePullSecrets`               | Image pull secrets                              | `fintech-harbor`               |
| `config.EXAMPLE`                 | Example configuration                           | `EXAMPLE`                      |
| `secretConfig`                   | Secret-backed environment variables             | `{}`                           |
| `secrets.enabled`                | Enable secrets                                  | `false`                        |
| `fileSecrets`                    | File secrets configuration                      | See `values.yaml`              |
| `service`                        | Service configuration                           | See `values.yaml`              |
| `ingress.enabled`                | Enable ingress                                  | `true`                         |
| `ingress.className`              | Ingress class name                              | `nginx`                        |
| `ingress.hosts`                  | Ingress hosts                                   | See `values.yaml`              |
| `ingress.tls`                    | Ingress TLS configuration                       | See `values.yaml`              |
| `liveness`                       | Liveness probe configuration                    | See `values.yaml`              |
| `readiness`                      | Readiness probe configuration                   | See `values.yaml`              |
| `startup`                        | Startup probe configuration                     | See `values.yaml`              |
| `resources`                      | Resource requests and limits                    | See `values.yaml`              |
| `nodeSelector`                   | Node selector                                   | `{}`                           |
| `tolerations`                    | Tolerations                                     | `[]`                           |
| `affinity`                       | Affinity                                        | `{}`                           |
| `podDisruptionBudget.enabled`    | Create a PodDisruptionBudget                    | `false`                        |
| `podDisruptionBudget.minAvailable` | Minimum available Pods during voluntary disruptions | `1`                        |
| `podSpec.labels`                 | Labels to add to workload pods                  | `{}`                           |
| `command`                        | Command to run in the container                 | `while true; do date; sleep 2; done` |
| `shell`                          | Shell to use for the command                    | `/bin/bash`                    |
| `volumes`                        | Volumes configuration                           | See `values.yaml`              |
| `serviceAccount.create`          | Create a service account                        | `false`                        |
| `serviceAccount.annotations`     | Annotations for the service account             | `{}`                           |
| `serviceAccount.name`            | Name of the service account                     | `""`                           |
| `podSpec.annotations`            | Annotations for the pod spec                    | `{}`                           |
| `podSpec.securityContext`        | Security context for the pod spec               | `{}`                           |
| `container.annotations`          | Annotations for the container                   | `{}`                           |
| `container.securityContext`      | Security context for the container              | `{}`                           |
| `initContainers`                 | Init containers configuration                   | See `values.yaml`              |

### Existing Kubernetes Secrets

Use `secretConfig` to expose only reviewed keys from existing Kubernetes
Secrets. The chart does not create, copy, or manage those Secrets.

```yaml
config:
  DB_URL: "jdbc:postgresql://postgres:5432/application"

secretConfig:
  DB_USER:
    secretName: db-creds
    key: username
  DB_PASSWORD:
    secretName: db-creds
    key: password
  AWS_ACCESS_KEY_ID:
    secretName: aws-creds
    key: access-key-id
```

This renders native `valueFrom.secretKeyRef` entries in the primary
Deployment, StatefulSet, or Job container. A missing Secret or key prevents
the Pod from starting. For a Job that defines `containers`, place a
`secretConfig` map under each container that needs the credentials; credentials
are not automatically shared with every Job container.

`container.env` remains available for native Kubernetes environment entries,
and the legacy `secrets.enabled` behavior remains unchanged.

## Notes

After deploying the chart, you can get the application URL by running these commands:

```sh
export POD_NAME=$(kubectl get pods --namespace <namespace> -l "app.kubernetes.io/name=<chart-name>,app.kubernetes.io/instance=<release-name>" -o jsonpath="{.items[0].metadata.name}")
export CONTAINER_PORT=$(kubectl get pod --namespace <namespace> $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
echo "Visit http://127.0.0.1:8080 to use your application"
kubectl --namespace <namespace> port-forward $POD_NAME 8080:$CONTAINER_PORT
```

To check the status of the deployment, run:

```sh
kubectl get pods --namespace <namespace> -l "app.kubernetes.io/name=<chart-name>,app.kubernetes.io/instance=<release-name>"
```

To get the logs of the application, run:

```sh
kubectl logs --namespace <namespace> -l "app.kubernetes.io/name=<chart-name>,app.kubernetes.io/instance=<release-name>"
```

To delete the deployment, run:

```sh
helm delete <release-name> --namespace <namespace>
```

## List of Resources Deployed

```sh
echo "Deployments:"
kubectl get deployments -n <namespace> -o custom-columns=NAME:.metadata.name

echo "StatefulSets:"
kubectl get statefulsets -n <namespace> -o custom-columns=NAME:.metadata.name

echo "Services:"
kubectl get services -n <namespace> -o custom-columns=NAME:.metadata.name

echo "PersistentVolumeClaims:"
kubectl get pvc -n <namespace> -o custom-columns=NAME:.metadata.name

echo "ConfigMaps:"
kubectl get configmaps -n <namespace> -o custom-columns=NAME:.metadata.name

echo "Secrets:"
kubectl get secrets -n <namespace> -o custom-columns=NAME:.metadata.name
```

# linea-stack

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1](https://img.shields.io/badge/AppVersion-v1-informational?style=flat-square)

Helm chart for a simplified Linea stack (sequencer, maru, besu, ethstats) - production-ready skeleton

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Bianca Popescu | <inktense12@gmail.com> | <https://github.com/inktense12> |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| backup.compression | bool | `true` |  |
| backup.credentialsSecret.name | string | `"linea-stack-backup-credentials"` |  |
| backup.enabled | bool | `false` |  |
| backup.resources.limits.cpu | string | `"500m"` |  |
| backup.resources.limits.memory | string | `"512Mi"` |  |
| backup.resources.requests.cpu | string | `"200m"` |  |
| backup.resources.requests.memory | string | `"256Mi"` |  |
| backup.retention | int | `7` |  |
| backup.schedule | string | `"0 */6 * * *"` |  |
| backup.storage.bucket | string | `"linea-backups"` |  |
| backup.storage.endpoint | string | `""` |  |
| backup.storage.path | string | `"linea-stack"` |  |
| backup.storage.region | string | `"us-east-1"` |  |
| backup.storage.type | string | `"s3"` |  |
| besu.command[0] | string | `"besu-untuned"` |  |
| besu.enabled | bool | `true` |  |
| besu.hpa.enabled | bool | `true` |  |
| besu.hpa.maxReplicas | int | `3` |  |
| besu.hpa.minReplicas | int | `1` |  |
| besu.hpa.targetCPUUtilizationPercentage | int | `70` |  |
| besu.hpa.targetMemoryUtilizationPercentage | int | `70` |  |
| besu.image.repository | string | `"consensys/linea-besu-package"` |  |
| besu.image.tag | string | `"beta-v4.0-rc20-20251104100707-3294a02"` |  |
| besu.persistence.enabled | bool | `true` |  |
| besu.persistence.size | string | `"50Gi"` |  |
| besu.persistence.storageClass | string | `""` |  |
| besu.resources.limits.cpu | int | `2` |  |
| besu.resources.limits.memory | string | `"4Gi"` |  |
| besu.resources.requests.cpu | string | `"500m"` |  |
| besu.resources.requests.memory | string | `"1Gi"` |  |
| besu.service.metricsPort | int | `9545` |  |
| besu.service.rpcPort | int | `8545` |  |
| besu.service.type | string | `"LoadBalancer"` |  |
| besu.service.wsPort | int | `8546` |  |
| ethstats.enabled | bool | `true` |  |
| ethstats.env.WS_SECRET | string | `"12345"` |  |
| ethstats.image.repository | string | `"consensys/linea-ethstats-server"` |  |
| ethstats.image.tag | string | `"7422b2a-1730387766"` |  |
| ethstats.service.port | int | `3000` |  |
| ethstats.service.type | string | `"LoadBalancer"` |  |
| global.imagePullPolicy | string | `"IfNotPresent"` |  |
| global.namespace | string | `"default"` |  |
| maru.command[0] | string | `"java"` |  |
| maru.command[1] | string | `"-Dlog4j2.configurationFile=configs/maru/log4j.xml"` |  |
| maru.command[2] | string | `"-jar"` |  |
| maru.command[3] | string | `"maru.jar"` |  |
| maru.command[4] | string | `"--maru-genesis-file"` |  |
| maru.command[5] | string | `"configs/genesis.json"` |  |
| maru.command[6] | string | `"--config"` |  |
| maru.command[7] | string | `"configs/config.toml"` |  |
| maru.enabled | bool | `true` |  |
| maru.image.repository | string | `"consensys/maru"` |  |
| maru.image.tag | string | `"0f6dc85"` |  |
| maru.p2pKeySecretName | string | `"linea-stack-maru-p2p-key"` |  |
| maru.persistence.enabled | bool | `true` |  |
| maru.persistence.size | string | `"10Gi"` |  |
| maru.persistence.storageClass | string | `""` |  |
| maru.resources.limits.cpu | int | `1` |  |
| maru.resources.limits.memory | string | `"1Gi"` |  |
| maru.resources.requests.cpu | string | `"500m"` |  |
| maru.resources.requests.memory | string | `"512Mi"` |  |
| maru.service.httpPort | int | `8080` |  |
| maru.service.metricsPort | int | `9545` |  |
| maru.service.type | string | `"ClusterIP"` |  |
| metrics.serviceMonitor.additionalLabels | object | `{}` |  |
| metrics.serviceMonitor.enabled | bool | `true` |  |
| metrics.serviceMonitor.interval | string | `"15s"` |  |
| metrics.serviceMonitor.namespace | string | `"monitoring"` |  |
| metrics.serviceMonitor.releaseLabel | string | `"monitoring"` |  |
| metrics.serviceMonitor.scrapeTimeout | string | `"10s"` |  |
| replicaCount | int | `1` |  |
| sequencer.enabled | bool | `true` |  |
| sequencer.enode | string | `"14408801a444dafc44afbccce2eb755f902aed3b5743fed787b3c790e021fef28b8c827ed896aa4e8fb46e22bd67c39f994a73768b4b382f8597b0d44370e15d"` |  |
| sequencer.image.repository | string | `"consensys/linea-besu-package"` |  |
| sequencer.image.tag | string | `"beta-v4.0-rc20-20251104100707-3294a02"` |  |
| sequencer.p2pKeySecretName | string | `"linea-stack-sequencer-p2p-key"` |  |
| sequencer.persistence.enabled | bool | `true` |  |
| sequencer.persistence.size | string | `"10Gi"` |  |
| sequencer.persistence.storageClass | string | `""` |  |
| sequencer.resources.limits.cpu | int | `1` |  |
| sequencer.resources.limits.memory | string | `"1Gi"` |  |
| sequencer.resources.requests.cpu | string | `"500m"` |  |
| sequencer.resources.requests.memory | string | `"512Mi"` |  |
| sequencer.service.metricsPort | int | `9545` |  |
| sequencer.service.type | string | `"ClusterIP"` |  |
| txSender.amount | int | `10` |  |
| txSender.enabled | bool | `true` |  |
| txSender.image.repository | string | `"bibi12/linea-tx-sender"` |  |
| txSender.image.tag | string | `"v1.0.1"` |  |
| txSender.interval | int | `1` |  |
| txSender.rpc.port | int | `8545` |  |
| txSender.rpc.service | string | `"besu"` |  |
| txSender.secrets.secretName | string | `"linea-stack-tx-sender-secrets"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)

helm lint ./helm/charts/linea-stack  

helm template linea helm/charts/linea-stack



Orbstack
v0
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update



v1
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring



helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set prometheus.enabled=true \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.serviceMonitorSelector.matchLabels.release=monitoring




   kubectl create secret generic linea-stack-sequencer-p2p-key \
  --from-file=key=config/sequencer/key 

     kubectl create secret generic linea-stack-maru-p2p-key \
  --from-file=key=config/maru/key 

helm upgrade --install local helm/charts/linea-stack


Check Prometheus 

kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090

http://localhost:9090/targets

## Known Issues

**Maru Metrics**: Maru's metrics endpoint currently returns HTTP 500 with "Invalid registry: io.micrometer.core.instrument.composite.CompositeMeterRegistry". This is a known issue with the maru application's Micrometer registry initialization. Sequencer and Besu metrics are working correctly. Monitoring for maru can be done via logs until this is resolved in a future maru release.

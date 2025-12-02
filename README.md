helm lint ./helm/charts/linea-stack  

helm template linea helm/charts/linea-stack



Orbstack

   kubectl create secret generic linea-stack-sequencer-p2p-key \
  --from-file=key=config/sequencer/key 

     kubectl create secret generic linea-stack-maru-p2p-key \
  --from-file=key=config/maru/key 

helm upgrade --install local helm/charts/linea-stack

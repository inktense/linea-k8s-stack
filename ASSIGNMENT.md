# Linea DevOps/SRE/Platform Assignment 

This a very simple example of Linea stack, without the ZeroKnowledge part. 
We'll use this simple docker compose to test out a candidates readiness to work with infrastructure at scale using Kubernetes and Helm. 

## Context
This docker compose consists of 4 parts: 
  * `sequencer`: an execution layer sequencer which is in charge of sequencing(ordering) transactions in a block
  * `maru`: an in-house developed consensus client, similar to Teku and others, which is proposing and signing blocks (since we're running Paris fork)
  * `besu`: a blockchain client rpc node receiving transactions and propagating them to the rest of the network
  * `ethstats`: a web UI which displays network nodes status like latest block, number of peers, etc.

## Task
The goal of this task is to convert this docker compose to production ready, publicly available Helm chart.   
The following criteria should be met: 
  * Helm chart should be production ready, properly labeled and annotated.
  * Helm chart should be available publicly. 
  * Helm chart should be deployable and the network fully working with default values and minimal user configuration.
  * Helm chart repo should have a `README.md` file explaining its usage.
  * All secrets must be handled properly. 
  * `sequencer` and `maru` are the core components of the network, and they should be treated as such from a security and reliability standpoint.   
  * Expose `json-rpc` and `json-rpc-ws` interfaces from `besu` node only, to the public.
  * Expose `ethstats` service publicly.
  * Implement `ServiceMonitor` CR which will scrape metrics and ship them into the pre-deployed observability stack.
  * Implement basic autoscaling solution for `besu` RPC node, scaling on cpu and memory usage.
  * Use a `CronJob` or a custom service which implements some form of data availability (backup) solution for `sequencer`, `maru` and `besu` nodes (data folder external backup, volume snapshot, etc.).

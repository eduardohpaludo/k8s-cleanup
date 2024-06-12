#!/bin/bash

# DAYS por padrão é 7 (variável Dockerfile)
max=$DAYS

# Busca os replica sets, filtra pelos dias, filtra se tem replica set vazio e seleciona os mais antigos do que os dias setados
emptyReplicaSets=$(kubectl get rs --all-namespaces | \
  grep -oE '^[a-zA-Z0-9-]+\s+[a-zA-Z0-9-]+(\s+[0-9]+){4}d' | sed 's/d$//g' | \
  grep -E '(0\s+){3}' | \
  awk -v max=$max '$6 > max {print $1 "|" $2}')

# Loop nos replica sets encontrados e deleta-os
for rs in $emptyReplicaSets; do
  IFS='|' read namespace replicaSet <<< "$rs";
  kubectl -n $namespace delete rs $replicaSet;
  sleep 0.25
done

# Busca os jobs finalizados a mais de 1 hora
finishedJobs=$(kubectl get jobs --all-namespaces | awk 'IF $4 == 1 && $5 ~ /h|d/ {print $1 "|" $2}')

# Loop nos jobs encontrados e deleta-os
for job in $finishedJobs; do
  IFS='|' read namespace oldJob <<< "$job";
  kubectl -n $namespace delete job $oldJob;
  sleep 0.25
done

# Busca os evictedpods mais antigos que 1h
evictedPods=$(kubectl get pods --all-namespaces -a | grep 'Evicted' | \
  awk 'IF $6 ~ /h|d/ {print $1 "|" $2}')

# Loop nos evictedpods e deleta-os
for pod in $evictedPods; do
  IFS='|' read namespace evictedPod <<< "$pod";
  kubectl -n $namespace delete pod $evictedPod;
  sleep 0.25
done
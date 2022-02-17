#!/usr/bin/env bash
kubectl create ns monitor
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus-grafana prometheus-community/kube-prometheus-stack -n monitor -f values.yml

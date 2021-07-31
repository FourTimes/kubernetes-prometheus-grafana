# kubernetes-prometheus-grafana


Pre-requsties

    kubernetes cluster
    Helm 3+

Installation

    kubectl create ns monitor
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm install prometheus-grafana prometheus-community/kube-prometheus-stack -n monitor

```sh

NAME: prometheus-grafana
LAST DEPLOYED: Sat Jul 31 21:34:31 2021
NAMESPACE: monitor
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitor get pods -l "release=prometheus-grafana"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.

```

view all resources

```sh

# kubectl get all -n monitor

NAME                                                         READY   STATUS    RESTARTS   AGE
pod/alertmanager-prometheus-grafana-kube-pr-alertmanager-0   2/2     Running   0          15m
pod/prometheus-grafana-796954754b-wxms5                      2/2     Running   0          16m
pod/prometheus-grafana-kube-pr-operator-5857744965-7hpgn     1/1     Running   0          16m
pod/prometheus-grafana-kube-state-metrics-6dbd99c59b-gjr7k   1/1     Running   0          16m
pod/prometheus-grafana-prometheus-node-exporter-lnt7j        1/1     Running   0          16m
pod/prometheus-grafana-prometheus-node-exporter-svcrj        1/1     Running   0          16m
pod/prometheus-prometheus-grafana-kube-pr-prometheus-0       2/2     Running   0          15m

NAME                                                  TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                      AGE
service/alertmanager-operated                         ClusterIP      None             <none>         9093/TCP,9094/TCP,9094/UDP   15m
service/prometheus-grafana                            ClusterIP      172.20.205.93    <none>         80/TCP                       16m
service/prometheus-grafana-kube-pr-alertmanager       ClusterIP      172.20.36.210    <none>         9093/TCP                     16m
service/prometheus-grafana-kube-pr-operator           ClusterIP      172.20.202.188   <none>         443/TCP                      16m
service/prometheus-grafana-kube-pr-prometheus         ClusterIP      172.20.44.24     <none>         9090/TCP                     16m
service/prometheus-grafana-kube-state-metrics         ClusterIP      172.20.71.207    <none>         8080/TCP                     16m
service/prometheus-grafana-prometheus-node-exporter   ClusterIP      172.20.194.119   <none>         9100/TCP                     16m
service/prometheus-operated                           ClusterIP      None             <none>         9090/TCP                     15m

NAME                                                         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/prometheus-grafana-prometheus-node-exporter   2         2         2       2            2           <none>          16m

NAME                                                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prometheus-grafana                      1/1     1            1           16m
deployment.apps/prometheus-grafana-kube-pr-operator     1/1     1            1           16m
deployment.apps/prometheus-grafana-kube-state-metrics   1/1     1            1           16m

NAME                                                               DESIRED   CURRENT   READY   AGE
replicaset.apps/prometheus-grafana-796954754b                      1         1         1       16m
replicaset.apps/prometheus-grafana-kube-pr-operator-5857744965     1         1         1       16m
replicaset.apps/prometheus-grafana-kube-state-metrics-6dbd99c59b   1         1         1       16m

NAME                                                                    READY   AGE
statefulset.apps/alertmanager-prometheus-grafana-kube-pr-alertmanager   1/1     15m
statefulset.apps/prometheus-prometheus-grafana-kube-pr-prometheus       1/1     15m

```

Assign the grafana to load balancer to access global

    kubectl patch svc prometheus-grafana -n monitor -p '{"spec": {"type": "LoadBalancer"}}'
    kubectl patch svc prometheus-grafana-kube-pr-prometheus -n monitor -p '{"spec": {"type": "LoadBalancer"}}'

view the load balancer details 

```sh

NAME                                          TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                      AGE
alertmanager-operated                         ClusterIP      None             <none>           9093/TCP,9094/TCP,9094/UDP   21m
prometheus-grafana                            LoadBalancer   172.20.205.93    11.11.11.11      80:30264/TCP                 21m
prometheus-grafana-kube-pr-alertmanager       ClusterIP      172.20.36.210    <none>           9093/TCP                     21m
prometheus-grafana-kube-pr-operator           ClusterIP      172.20.202.188   <none>           443/TCP                      21m
prometheus-grafana-kube-pr-prometheus         ClusterIP      172.20.44.24     <none>           9090/TCP                     21m
prometheus-grafana-kube-state-metrics         ClusterIP      172.20.71.207    <none>           8080/TCP                     21m
prometheus-grafana-prometheus-node-exporter   ClusterIP      172.20.194.119   <none>           9100/TCP                     21m
prometheus-operated                           ClusterIP      None             <none>           9090/TCP                     21m


```

Open the browser to to load balancer

    http://11.11.11.11
    
        => username: admin
        => password: prom-operator

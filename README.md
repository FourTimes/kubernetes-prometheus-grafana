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



Create the custom serviceMonitor

Deployment File

```yml
---
# vim alb-ingress-controller.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: alb-ingress-controller
    app.kubernetes.io/project: smart-remittance
    app.kubernetes.io/usage: frontend
    app.kubernetes.io/environment: production
  name: alb-ingress-controller
  namespace: kube-system
spec:
  strategy:
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 1
    type: RollingUpdate
  minReadySeconds: 10
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 3
  minReadySeconds: 10
  selector:
    matchLabels:
      app.kubernetes.io/name: alb-ingress-controller
  template:
    metadata:
      labels:
        app.kubernetes.io/name: alb-ingress-controller
    spec:
      serviceAccountName: alb-ingress-controller
      containers:
      - name: alb-ingress-controller
        image: docker.io/amazon/aws-alb-ingress-controller:v1.1.8
        ports:
        - containerPort: 10254
        args:
          - --ingress-class=alb
          - --cluster-name=smart-remittance-prod
          - --aws-vpc-id=vpc-0852c36031ac7a6f6
          - --aws-region=ap-southeast-2
        env:
        - name: AWS_ACCESS_KEY_ID
          value: AWS_ACCESS_KEY_ID
        - name: AWS_SECRET_ACCESS_KEY
          value: AWS_SECRET_ACCESS_KEY
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: alb-ingress-controller
    app.kubernetes.io/project: smart-remittance
    app.kubernetes.io/usage: frontend
    app.kubernetes.io/environment: production
  name: alb-ingress-controller
rules:
  - apiGroups:
      - ""
      - extensions
    resources:
      - configmaps
      - endpoints
      - events
      - ingresses
      - ingresses/status
      - services
      - pods/status
    verbs:
      - create
      - get
      - list
      - update
      - watch
      - patch
  - apiGroups:
      - ""
      - extensions
    resources:
      - nodes
      - pods
      - secrets
      - services
      - namespaces
    verbs:
      - get
      - list
      - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/name: alb-ingress-controller
    app.kubernetes.io/project: smart-remittance
    app.kubernetes.io/usage: frontend
    app.kubernetes.io/environment: production
  name: alb-ingress-controller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: alb-ingress-controller
subjects:
  - kind: ServiceAccount
    name: alb-ingress-controller
    namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/name: alb-ingress-controller
    app.kubernetes.io/project: smart-remittance
    app.kubernetes.io/usage: frontend
    app.kubernetes.io/environment: production
  name: alb-ingress-controller
  namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/project: smart-remittance
    app.kubernetes.io/usage: frontend
    app.kubernetes.io/environment: production
  name: alb-ingress-controller
  namespace: kube-system
spec:
  type: ClusterIP
  selector:
    app.kubernetes.io/name: alb-ingress-controller
  ports:
  - port: 10254
```

Executive

```sh
    kubectl apply -f alb-ingress-controller.yml
```
ServiceMonitor
```yml
---
# vim alb-ingress-controller-service-monitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: alb-ingress-controller
  labels:
    app.kubernetes.io/name: alb-ingress-controller
spec:
  jobLabel: alb-ingress-controller
  endpoints:
    - port: metrics
      interval: 15s
      relabelings:
      - sourceLabels: [__meta_kubernetes_namespace]
        separator: ;
        regex: (.*)
        targetLabel: namespace
        replacement: $1
        action: replace
      - sourceLabels: [__meta_kubernetes_service_name]
        separator: ;
        regex: (.*)
        targetLabel: service
        replacement: $1
        action: replace
      - sourceLabels: [__meta_kubernetes_pod_name]
        separator: ;
        regex: (.*)
        targetLabel: pod
        replacement: $1
        action: replace
      - sourceLabels: [__meta_kubernetes_pod_container_name]
        separator: ;
        regex: (.*)
        targetLabel: container
        replacement: $1
        action: replace
      - sourceLabels: [__meta_kubernetes_service_name]
        separator: ;
        regex: (.*)
        targetLabel: job
        replacement: ${1}
        action: replace
      - separator: ;
        regex: (.*)
        targetLabel: endpoint
        replacement: metrics
        action: replace
      - sourceLabels: [__address__]
        separator: ;
        regex: (.*)
        modulus: 1
        targetLabel: __tmp_hash
        replacement: $1
        action: hashmod
      - sourceLabels: [__tmp_hash]
        separator: ;
        regex: "0"
        replacement: $1
        action: keep
  selector:
    matchLabels: {}  # Empty to match all labels
  namespaceSelector:
    matchNames:
      - kube-system
```

```sh
# kubectl get serviceMonitor

NAME                                            AGE
alb-ingress-controller                          8h
prometheus-grafana-kube-pr-alertmanager         2d12h
prometheus-grafana-kube-pr-apiserver            2d12h
prometheus-grafana-kube-pr-coredns              2d12h
prometheus-grafana-kube-pr-grafana              2d12h
prometheus-grafana-kube-pr-kube-proxy           2d12h
prometheus-grafana-kube-pr-kube-state-metrics   2d12h
prometheus-grafana-kube-pr-kubelet              2d12h
prometheus-grafana-kube-pr-node-exporter        2d12h
prometheus-grafana-kube-pr-operator             2d12h
prometheus-grafana-kube-pr-prometheus           2d12h
```

Create custom Alerts

```yml
---
# vim alb-ingress-controller-rules.yml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  labels:
    prometheus: kube-prometheus-stack-prometheus
    role: alert-rules
  name: alb-ingress-controller
spec:
  groups:
  - name: "alb-ingress-controller.rules"
    rules:
    - alert: albIngressControllerPodDown
      for: 30s
      expr: absent(up{container="alb-ingress-controller"})
      annotations:
        message: The application load balancer deployment has less than 1 pod running.
      labels:
        severity: critical
        usage: alb-ingress-controller
```

view Alerts

```sh
# kubectl get PrometheusRule

NAME                                                              AGE
alb-ingress-controller                                            77m
prometheus-grafana-kube-pr-alertmanager.rules                     2d12h
prometheus-grafana-kube-pr-k8s.rules                              2d12h
prometheus-grafana-kube-pr-kube-apiserver-burnrate.rules          2d12h
prometheus-grafana-kube-pr-kube-apiserver-histogram.rules         2d12h
prometheus-grafana-kube-pr-kube-prometheus-general.rules          2d12h
prometheus-grafana-kube-pr-kube-prometheus-node-recording.rules   2d12h
prometheus-grafana-kube-pr-kube-state-metrics                     2d12h
prometheus-grafana-kube-pr-kubernetes-apps                        2d12h
prometheus-grafana-kube-pr-kubernetes-resources                   2d12h
prometheus-grafana-kube-pr-kubernetes-storage                     2d12h
prometheus-grafana-kube-pr-kubernetes-system                      2d12h
prometheus-grafana-kube-pr-kubernetes-system-apiserver            2d12h
prometheus-grafana-kube-pr-kubernetes-system-kubelet              2d12h
prometheus-grafana-kube-pr-node-exporter                          2d12h
prometheus-grafana-kube-pr-node-exporter.rules                    2d12h
prometheus-grafana-kube-pr-node-network                           2d12h
prometheus-grafana-kube-pr-node.rules                             2d12h
prometheus-grafana-kube-pr-prometheus                             2d12h
prometheus-grafana-kube-pr-prometheus-operator                    2d12h

```


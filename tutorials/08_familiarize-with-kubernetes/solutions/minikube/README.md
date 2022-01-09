08 - Get familiar with Kubernetes basics
========================================


### Solution

*Please note that this solution is loosely based on a set of tasks written in 
the [official documentation](https://kubernetes.io/docs/tasks/)*


#### 0. Preparations

Install [minikube](https://minikube.sigs.k8s.io/docs/start/) (K8s on a local virtual machine) and
create a cluster, if you don't have any available. ([see requirements](https://minikube.sigs.k8s.io/docs/start/#what-youll-need))

```bash
minikube start \
    --cpus=2 --memory=4096m \
    --container-runtime=cri-o \
    --driver=virtualbox \
    --addons=ingress \
    --profile=devops-tutorial
```

Verify that `kubectl` is configured correctly:

```bash
kubectl api-resources
```

(lists all the different Kubernetes objects that are available via *api-server*)


#### 1. Make yourself familiar with `kubectl` and the cluster

No pod should be listed:

```bash
kubectl get pods
```

Start a pod (*`POD_NAME` must be unique*):

```bash
kubectl run ${POD_NAME} --image=docker.io/library/nginx:latest
```

The new pod should be listed now:

```bash
kubectl get pods ${POD_NAME}
```

Inspect the pod:

```bash
kubectl describe pods ${POD_NAME}
```

Connect to the running container inside that pod:

*context: workstation*
```bash
kubectl exec --stdin --tty ${POD_NAME} -- /bin/bash
```

... and inspect it:

*context: pod*
```bash
apt update
apt install psmisc
pstree
```

*__NOTE:__ `kubectl` [cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)*


#### 2. Define and deploy an application

Create a namespace:

```bash
kubectl create namespace "${NS_NAME}"
```

... and either use `-n ${NS_NAME}` whenever namespaced objects are involved, or set:

```bash
kubectl config set-context --current --namespace="${NS_NAME}"
```

Write a `Deployment` configuration for `docker.io/etherpad/etherpad:1.8.7` with the 
following specifications and use `kubectl` to deploy it on the cluster.

* replication of __2__
* bind to port `8080`
* deployment strategy: rolling update
* resource requirements (CPU, memory)
* run non-privileged (security context)
* health checks (aka probes)

```bash
kubectl apply -n ${NS_NAME} --file ./deployment.yaml
```

*__NOTE:__ it is also possible to define the namespace in the configuration file: `metadata.namespace: '${NS_NAME}'`* 

Confirm whether the deployment was successful and the `Pods` are healthy:

```bash
kubectl get pods -n ${NS_NAME} --output wide
```
```
NAME                                   READY   STATUS    RESTARTS   AGE     IP            NODE       NOMINATED NODE   READINESS GATES
etherpad-deployment-65cd77f4fc-98gq8   1/1     Running   0          70m     10.244.0.36   minikube   <none>           <none>
etherpad-deployment-65cd77f4fc-dmfjv   1/1     Running   0          82m     10.244.0.33   minikube   <none>           <none>
```

Delete one of the `Pods` to see the *replication controller* kick in as part of the `Deployment`

Terminal 1:
```bash
kubectl get pods -n ${NS_NAME} --output wide --watch
```
Terminal 2:
```bash
kubectl delete pods ${DEPLOYMENT_POD_NAME} --grace-period=0 -n ${NS_NAME}
```

*__NOTE:__ after Kubernetes notices that one pod is gone, it creates a new one to match the 
replication count*


#### 3. Expose the application

Write a `Service` configuration for the `Deployment` with the following specifications and
use `kubectl` to deploy it on the cluster.

* maps port `80` to port `8080`
* TCP as protocol
* from type *load balancer*

```bash
kubectl apply -n ${NS_NAME} --file ./service.yaml
```

Verify whether the configuration of the `Service` was successful:
 
```bash
kubectl get services -n ${SERVICE_NAME} --output wide
```
```
NAME               TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE     SELECTOR
etherpad-service   LoadBalancer   10.100.122.224   <pending>     80:32044/TCP   6h35m   app=etherpad
```

Connect to the nginx pod from (1) and verify that the `Service` resolves across the cluster:

*context: pod*
```bash
curl http://${SERVICE_NAME}.${NS_NAME}.svc.cluster.local/stats
```
*__NOTE:__ the response is supposed to be a JSON*

To eventually make the application available from outside the cluster, write an `Ingress` configuration 
pointing to the `Service` that you just created. Enable TLS termination.

*__NOTE:__ `Ingress` requires FQDNs. To get IP-based FQNDs one can either adjust `/etc/hosts` or utilize
[nip.io](https://nip.io). The IP of you Kubernetes single node cluster can be determined with the
command `minikube ip`*

```bash
kubectl apply -n ${NS_NAME} --file ./ingress.yaml
```

*__NOTE:__ since this solution makes use of the minikube ingress addon and thus the
[Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/), you may need some additional annotations
[to enable session affinity for connections coming from the outside](https://kubernetes.github.io/ingress-nginx/examples/affinity/cookie/)*

Finally, verify that the application is indeed accessible from your browser.


#### 4. Cleaning up

```bash
kubectl delete "${NS_NAME}"
kubectl delete pod ${POD_NAME} -n default
minikube stop
minikube delete
```

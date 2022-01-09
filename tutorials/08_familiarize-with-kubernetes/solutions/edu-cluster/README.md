08 - Get familiar with Kubernetes basics
========================================


### Solution

*Please note that this solution is loosely based on a set of tasks written in 
the [official documentation](https://kubernetes.io/docs/tasks/)*


#### 0. Preparations

1. log in to the [cluster management web console](https://rancher.ris.beuth-hochschule.de) (VPN access requires)
   with your university account 
2. click on *edu-cluster* in the list of clusters
3. click on *cluster* in the main navigation bar (top left next to *edu-cluster*) - you should see
   some kind of resource utilization meters in the main area of the page
4. obtain the *Kubeconfig File* (top right) and store the content on your workstation under `~/.kube/config`
5. navigate to *Projects/Namespaces*, click on *Add Namespaces* next to the project named after this module
   and give the namespace a meaningful & unique name (e.g. university account ID)
6. [install `kubectl`](https://kubernetes.io/docs/tasks/tools/#kubectl) on your workstation, if it doesn't
   already exist
7. moving forward, either use `-n ${NS_NAME` whenever namespaced objects are involved, or configure it as the
   default value in your local Kubeconfig - edit the file directly by adding `contexts[*].context.namespace: ${NS_NAME}`
   or run:

```bash
kubectl config set-context --current --namespace=${NS_NAME}
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

Write a `Deployment` configuration for `docker.io/etherpad/etherpad:stable` with the 
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
NAME                                  READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
etherpad-deployment-d8f8c56ff-2v959   1/1     Running   0          42m   10.42.5.16   ris-worker02   <none>           <none>
etherpad-deployment-d8f8c56ff-v9rdg   1/1     Running   0          42m   10.42.6.16   ris-worker03   <none>           <none>
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
* from type *Cluster IP*

```bash
kubectl apply -n ${NS_NAME} --file ./service.yaml
```

Verify whether the configuration of the `Service` was successful:
 
```bash
kubectl get services -n ${SERVICE_NAME} --output wide
```
```
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE   SELECTOR
etherpad-service   ClusterIP   10.43.205.119   <none>        80/TCP    41m   app=etherpad
```

Connect to the nginx pod from (1) and verify that the `Service` resolves across the cluster:

*context: pod*
```bash
curl http://${SERVICE_NAME}.${NS_NAME}.svc.cluster.local/stats
```
*__NOTE:__ the response is supposed to be a JSON*

To eventually make the application available from outside the cluster, write an `Ingress` configuration 
pointing to the `Service` that you just created.

*__NOTE:__ the ingress controller of the education cluster runs on a single node (`141.64.6.10`)
directly on the cluster, the respective DNS entry is an A record pointing to `*.lehre.ris.beuth-hochschule.de`, 
which is why the ingress host must be `${NAME}.lehre.ris.beuth-hochschule.de`; `NAME` is an arbitrary
virtual host name that can be chosen freely but must be unique (e.g. the namespace from earlier)*

```bash
kubectl apply -n ${NS_NAME} --file ./ingress.yaml
```

Finally, verify that the application is indeed accessible from your browser.


#### 4. Cleaning up

Use the [cluster management web console](https://rancher.ris.beuth-hochschule.de) to delete your namespace,
which will then delete all associated objects.

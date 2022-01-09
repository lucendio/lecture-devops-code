08 - Get familiar with Kubernetes basics
========================================


### Objective(s)

* basic knowledge of how to interact with `kubectl`
* write Kubernetes objects
* schedule workload
* inspect & debug workload


### Prerequisite(s)

* [`kubectl` is installed](https://kubernetes.io/docs/tasks/tools/#kubectl) to interact with the cluster
* a reachable Kubernetes cluster
* working credentials to authenticate against the cluster


### Task(s)

0. Gain access to a Kubernetes cluster or install one

1. Get to know `kubectl`

    * create an *nginx* *Pod*
    * inspect the pod    
    
__NOTE:__ [cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/) 

2. Write a `Deployment` manifest and deploy a stateless application

    * create a dedicated namespace
    * write the Deployment configuration file
    * apply the configuration

3. Expose the application

    * write a Service and Ingress configuration
    * apply the configurations
    * inspect the service
    * verify that the application is accessible from you browser

For more tutorials, please refer to the [official documentation](https://kubernetes.io/docs/tasks/)

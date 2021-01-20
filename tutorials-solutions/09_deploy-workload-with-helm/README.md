08 - Get familiar with Kubernetes basics
========================================


### Solution

*Please note that this solution makes use of solutions of previous tutorials and
hence will create a chart for [CodiMD](https://github.com/hackmdio/codimd#documentation).


#### 0. Preparations

Verify that `kubectl` is installed configured correctly:

```bash
kubectl api-resources
```
(lists all the different Kubernetes objects that are available via *api-server*)

In addition, [`helm`](https://helm.sh/docs/intro/install/) as well as [`sops`](https://github.com/mozilla/sops#download)
and [`gpg`](https://www.gnupg.org/download/index.html) are static binaries. Either try
your local package manager or just download them from their corresponding release pages,
make them executable and put them in a directory listed in `${PATH}`.


#### 1. Create a chart using an iterative method   

*__NOTE:__ Create a folder and add each file manually, or run `helm create $CHART_NAME` to generate a
boilerplate. The latter may require you to remove a couple of files again.*

(1) Creation
    I) Create meta files, such as `Chart.yaml`
    II) Put static Kubernetes object files in `./templates`
       * Deployments
       * Services
       * Ingress
    III) Deploy
        ```bash
        helm install ${RELEASE_NAME} ./chart
        ```
    
(2) Parameterization
    I) Refactor the object files by moving out certain data into a `values.yaml`, e.g.:
       * image repository and tag
       * replication factor
       * usernames and passwords
    II) Deploy again
        ```bash
        helm upgrade ${RELEASE_NAME} ./chart
        ```

(3) Refactoring/Separation
    I) Break down the content of `./chart/values.yaml` into three categories:    
       * defaults (stay)
       * parameters (move into a `./values.yaml` outside of the chart)
       * sensitive information (move into a `./secrets.yaml` outside of the chart)
    II) Generate a self-signed TLS key pair and add it to `./secrets.yaml`
        ```bash
        export SUB_DOMAIN=$(minikube ip | tr . -)
        openssl req -new -nodes -x509 -days 365 -newkey rsa:4096 -sha512 -keyout tls.key -out tls.crt -subj "/CN=pad.${SUB_DOMAIN}.nip.io"
        ```    
    III) Deploy again
        ```bash
        helm upgrade --values=./values.yaml --values=./secrets.yaml --set "fqdn=pad.${SUB_DOMAIN}.nip.io" ${RELEASE_NAME} ./chart
        ```
        
*__NOTE:__ Up until this point, the Pods resulting from the Deployment should end up in a CrashLoopBackoff. Can you find out why?*

(4) Add chart dependencies
    I) [PostgreSQL](https://github.com/bitnami/charts/tree/master/bitnami/postgresql)
        ```bash
        helm repo add bitnami https://charts.bitnami.com/bitnami
        cd ./chart && helm dependency build
        ```
    II) Adjust `./values.yaml`, `./secrets.yaml` and `./chart/values.yaml` by adding [sub-chart values](https://github.com/bitnami/charts/tree/master/bitnami/postgresql/README>md)
    III) Deploy again
        ```bash
        helm upgrade --values=./values.yaml --values=./secrets.yaml --set "fqdn=pad.${SUB_DOMAIN}.nip.io" ${RELEASE_NAME} ./chart
        ```

*__NOTE:__ See the `./chart` folder in the current directory or find some inspiration in the
[official chart of [`codimd`](https://github.com/hackmdio/codimd-helm/tree/master/charts/codimd)]*


#### 2. Encrypt your secrets

(1) Generate a key pair (in case you don't already own a GPG key-pair)

```bash
gpg --batch --gen-key ./gpg-key.conf
```

(2) Install the Helm-Sops plugin

```bash
SKIP_SOPS_INSTALL=true helm plugin install https://github.com/jkroepke/helm-secrets --version v3.4.0
```

(3) Encrypt `secrets.yaml`

```bash
cp secrets.yaml secrets-backup.yaml 
export SOPS_PGP_FP=$(gpg --with-colons --fingerprint | grep fpr | awk -F ':' '{print $$10}')
helm secrets enc secrets.yaml
```

(4) Redeploy to see if Helm decrypts the secrets during runtime

```bash
helm secrets \
    upgrade \
    --values=./values.yaml \
    --values=./secrets.yaml \
    --set "fqdn=pad.${SUB_DOMAIN}.nip.io" 
    ${RELEASE_NAME} ./chart
```

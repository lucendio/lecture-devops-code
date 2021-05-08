01 - Starting a container
=========================


### Solutions

#### 1. Building and running a Node server isolated in a container

```bash
docker build --file ./Containerfile --tag my-container-image:1.0.0 ./
docker run --publish 3000:8080 --name my-container my-container-image:1.0.0
```

__NOTE:__ You may want to detach from the container shell by adding `--detach` to the command. Also,
in case you already ran the command before, you may need to stop and remove the container:

```bash
docker stop my-container
docker rm my-container
```

To verify that the container is actually running

a) check the HTTP interface; either by opening up the URL in your browser or by using the command line:

```bash
curl http://${DOCKER_HOST_IP}:3000
```
*Response:* `Hello World!

__NOTE:__ Depending on *where* the container runtime actually spawns the container, `DOCKER_HOST_IP` might be
an IP of a virtual machine running on your host system, or, if Linux bis the host system, the value is probably
`127.0.0.1` aka. `localhost`. 

b) use the container management tool

```bash
docker ps 
```
*Result:*
```
CONTAINER ID   IMAGE                      COMMAND                  CREATED              STATUS              PORTS                    NAMES
d1afd14edda3   my-container-image:1.0.0   "node ./main.js --po…"   About a minute ago   Up About a minute   0.0.0.0:3000->8080/tcp   my-container
```


#### 2. Creating AWS resources from within a container

(A) Verify credentials

```bash
docker run \
    --mount type=bind,source=${HOME}/.aws,destination=/root/.aws,readonly \
    --interactive \
    --tty \
    --rm \
    docker.io/amazon/aws-cli \
    sts get-caller-identity
```

(B) Create a bucket

```bash
docker run \
    --mount type=bind,source=${HOME}/.aws,destination=/root/.aws,readonly \
    --interactive \
    --tty \
    --rm \
    docker.io/amazon/aws-cli \
    s3api create-bucket --bucket my-globally-unique-bucket-name
```

__NOTE:__ Check afterwards if the bucket actually exists: `s3 ls`. __Don't forget to delete the bucket
again after you are done.__

*More information and examples can be found in the
[official AWS CLI user guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-docker.html).*

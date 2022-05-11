01 - Starting a container
=========================


### Solutions

#### 1. Building and running a Node server isolated in a container

```bash
docker build --file ./Containerfile --tag my-container-image:1.0.0 ./
docker run --publish 3000:80 --name my-container my-container-image:1.0.0
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
*Response:* `[...] Hello World! [...]`

__NOTE:__ Depending on *where* the container runtime actually has spawned the container, `DOCKER_HOST_IP` might be
an IP of a virtual machine running on your host system, or, if Linux is the host system, the value is probably
`127.0.0.1` aka. `localhost`. 

b) use the container management tool

```bash
docker ps 
```
*Result:*
```
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS         PORTS                  NAMES
754f855f1aed   my-container-image:1.0.0   "/docker-entrypoint.…"   3 minutes ago   Up 3 minutes   0.0.0.0:3000->80/tcp   my-container
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

Start a container:
```bash
docker run \
    --name aws-container \
    --mount type=bind,source=${HOME}/.aws,destination=/root/.aws,readonly \
    --detach \
    --entrypoint sh \
    docker.io/amazon/aws-cli \
    -c 'while true; do sleep 3600; done'
```

Allocate a shell in the container:
```bash
docker exec \
    --interactive \
    --tty \
    aws-container \
    /bin/bash
```

Actually create the bucket:
```bash
aws s3api create-bucket --bucket my-globally-unique-bucket-name
```

__NOTE:__ Check afterwards if the bucket actually exists: `s3 ls`. __Don't forget to delete the bucket
again after you are done: `aws s3api delete-bucket --bucket ${BUCKET_NAME}`__

Remove the container:
```bash
docker rm --force aws-container
```

*More information and examples can be found in the
[official AWS CLI user guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-docker.html).*

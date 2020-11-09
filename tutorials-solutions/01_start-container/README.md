01 - Starting a container
=========================


### Solutions

#### 1. Running Etherpad in a container

(A) Simple

```bash
docker run --name my-etherpad-container docker.io/etherpad/etherpad:stable
```

(B) Complex

```bash
docker build --file ./Dockerfile --tag my-etherpad-image:1.0.0 ./
docker run --publish 8080:8443 --name my-etherpad-container my-etherpad-image:1.0.0
```

__NOTE:__ You may want to detach from the container shell by adding `--detach` to the command. Also,
in case you already ran the command before, you may need to stop and remove the container:

```bash
docker stop my-etherpad-container
docker rm my-etherpad-container
```


#### 2. Creating AWS resources from within a container

(A) Verify credentials

```bash
docker run \
    --mount type=bind,source=${HOME}/.aws,destination=/root/.aws,readonly \
    --interactive \
    --tty \
    --rm \
    amazon/aws-cli \
    sts get-caller-identity
```

(A) Verify credentials

```bash
docker run \
    --mount type=bind,source=${HOME}/.aws,destination=/root/.aws,readonly \
    --interactive \
    --tty \
    --rm \
    amazon/aws-cli \
    s3api create-bucket --bucket my-globally-unique-bucket-name
```

__NOTE:__ Check afterwards if the bucket actually exists: `s3 ls`. Don't forget to delete the bucket
again after you are done.

*More information and examples can be found in the
[official AWS CLI user guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-docker.html).*

01 - Starting a container
=========================


### Objective(s)

* successfully launch a container
* verify that your credentials from your AWS Educate account work


### Prerequisite(s)

* container engine is installed (e.g. Docker, Podman)
* valid AWS credentials that are configured in `~/.aws`


### Task(s)

1. Build a container image based on a
   [Dontainerfile](https://github.com/lucendio/lecture-devops-code/blob/master/pieces/containers/Containerfile)
   (e.g. `Dockerfile``). Start a container based on that image and expose the server Node in a way
   so that you are able to retrieve the landing page in your browser
   
2. Open up a shell in a container that contains the AWS cli. Mount your credentials into the
   container and verify that you are able to create resources.

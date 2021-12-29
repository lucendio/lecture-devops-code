05 - Set up and run a pipeline
==============================


### Solution

*Please note that this solution utilizes the automation platform GitLab.*

__Useful links:__

* [GitLab: CI/CD](https://docs.gitlab.com/ee/ci/README.html)
* [GitLab: Keyword reference](https://docs.gitlab.com/ee/ci/yaml/README.html)
* [GitLab: Building container images](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html)


#### 0. Preparations

* create a new project
* push the example code
* check CI/CD settings `Settings > CI/CD` to see if everything is in order


#### 1. Write a very simple pipeline and verify that it's being executed

`.gitlab-ci.yml`
```yml
test-job:
  script:
      - 'ls -al ./'
```

```
git add .gitlab-ci.yml
git commit -m 'testing Gitlab CI/CD with a simple pipeline'
git push
```

Under `CI/CD > Pipelines`, you should see a pipeline execution with the status *passed*. Click on one of
the stage cycles in order to get to the log of a job execution. 

*__NOTE:__ the log of the job should show the top-level content of the repository*

*__NOTE:__ in case of 'yaml invalid' errors, check the `CI/CD > Editor` for a more detailed explanation*


#### 2. Write a pipeline that ...

a) builds an artifact (archived bundle a/o container image) - see stage: `build` in `.gitlab-ci.yml`

*__NOTE:__ for container images, please note the docker-in-docker dilemma (see 'Useful links')*


b) test the code/artifact - see stage: `test` in `.gitlab-ci.yml`

*__NOTE:__ start a container based on the image produced during build stage, and either check from the outside
if Nginx runs (see solution), or from the inside by
[explicitly configure the image built during previous stage for the test job](https://docs.gitlab.com/ee/ci/yaml/README.html#image)*


c) publish the artifact(s) - see stage: `publish` in `.gitlab-ci.yml`

*__NOTE:__ use the GitLab-internal [Package](https://docs.gitlab.com/ee/user/packages/package_registry/) or 
[Container Image](https://docs.gitlab.com/ee/user/packages/container_registry/) Registries*

#### 3. Verify that the artifacts were published

Under `Packages & Registries > [Package,Container] Registry` you should be able to see and even download the artifact

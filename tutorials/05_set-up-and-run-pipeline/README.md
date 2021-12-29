05 - Set up and run a pipeline
==============================


### Objective(s)

* gain basic knowledge of how to use an automation platform
* configure and trigger a CI/CD pipeline


### Useful information & links

* [GitLab: Quick start](https://docs.gitlab.com/ee/ci/quick_start/)
* [Jenkins: Declarative pipeline](https://www.jenkins.io/doc/book/pipeline/syntax/#declarative-pipeline)
* [Github Actions: Workflow syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)


### Prerequisite(s)

* `git` is installed on your workstation


### Task(s)

0. Set up an empty Git repository (locally & remote) and add

  * application code of your choosing
  * other files/code required to build the application (e.g. container file)


1. Choose an automation platform 

*__NOTE:__ In cases, where code repository and automation platform are not one and the same, it might be
required to tell the automation platform where the repository actually is located. (e.g. create a new
item in Jenkins and add the Github URL)*


2. Consult the documentation to find out how to define and configure a pipeline  

*__NOTE:__ Following the approach of configuration-as-code, it is recommended to place the pipeline definition
right 'next' to the source code it's supposed to process*


3. Configure at least three stages (build, test, release) which eventually would produce an artifact that is a 
   container image and/or an archive bundle containing the executable source 

*__NOTE:__ The build steps carried out in the pipeline are probably very similar if not even the same used to build
the application locally on your workstation. Often, it's just a matter of adding the build commands to a shell/script
section in the pipeline definition.*

*__NOTE:__ The solution does not contain any tests or even a test framework, but there are other ways to
verify whether code works or not. Starting the app and check its response might suffice.*


4. Verify via browser that the artifact is actually published

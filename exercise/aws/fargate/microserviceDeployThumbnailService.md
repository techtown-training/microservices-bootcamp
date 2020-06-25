# Microservices: AWS: Fargate
# Microservice Deploy Thumbnail Service

### Objective

Deploy a Thumbnail microservice.

___

## Application Overview

![Application Architecture](images/application-architecture.png)

___

## Git Pull

Sometimes there are changes to the exercises as we move through the class sessions.  Unfortunately hands-on exercises do not always age well.  So let's make sure that we have the latest version of the class repo.

~~~shell
cd ~/microservices-bootcamp/
git pull
~~~

If there are any local changes that are preventing the "git pull" from merging we may have to work through those allow the command to complete.

___

# Build and deploy Thumbnail-Service

In this section we will build and deploy the **thumbnail-service** as an ECS service. We will deploy the service on Container instances. The thumbnail-service is a daemon process and no external interactions happens with this service. This service monitors the SQS queue and creates thumbnails, no TCP ports are required to be exposed.

The ECS Task-Definition and Service-Definition are located in the thumbnail-service folder.

___

## Prerequisite

This Fargate Microservice exercise have a few Prerequisite that must first be done with an AWS role that has some administrative access.  You instructor may need to first create the infrastructure needed for these labs.  The following links will describe what needs to first be created for the next number of labs.

[Lab Setup](microserviceLabSetup.md)

[Create ECS Cluster](microserviceCreateEcsCluster.md)

Once these steps are taken care of by your instructor you should be able to continue on with the labs.

___

## Task 1 - Build thumbnail-service docker image

1. Navigate to the thumbnail-service folder

~~~shell
cd ~/microservices-bootcamp/exercise/aws/source/fargate/microservice/thumbnail-service
~~~

2. Create ECR Repository for thumbnail-service

~~~shell
# Note the repositoryUri - output of below command
aws ecr create-repository --repository-name ecs-workshop/thumbnail-service-${LAB_NUMBER}
~~~

3. Build the Docker Image for the thumbnail-service. (hint: you have the repository name in the previous command)

~~~shell
docker build -t <repositoryUri>:latest .
~~~

4. Login to Elastic Container Registry (ECR)

~~~shell
aws ecr get-login --no-include-email | bash
~~~

5. Push the Docker image to ECR

~~~shell
docker push <repositoryUri>:latest
~~~

___

## Task 2 - Deploy the thumbnail-service as ECS Service

1. Create a CloudWatch LogGroup to collect thumbnail-service logs.

~~~shell
aws logs create-log-group --log-group-name ecs-workshop/thumbnail-service-${LAB_NUMBER}
~~~

2. Let us now register the ECS Task Definition for the thumbnail-service. A **task-definition.json** is located in the thumbnail-service folder.

First create the initial task-definition.json file.

~~~shell
cp template-task-definition.json task-definition.json
sed -ie "s/#00LAB00#/${LAB_NUMBER}/g" task-definition.json
sed -ie "s/#00AWSREGION00#/${AWS_REGION}/g" task-definition.json
~~~

Let us set the environment variables in the task-definition.json. Replace the following parameter placeholders in the task-definition.json file with appropriate values.

CloudFormation stack Output can be displayed with the following command.

~~~shell
aws cloudformation describe-stacks --stack-name ecs-workshop --query Stacks[*].Outputs | sort
~~~

|Parameter                           | Value                                   |
|------------------------------------|-----------------------------------------|
|&lt;ThumbnailServiceTaskRoleArn&gt; | ecs-workshop CloudFormation stack Output|
|&lt;repositoryUri&gt;               | ECR repository Uri of contacts-service  |
|&lt;SqsQueueUrl>                    | ecs-workshop CloudFormation stack Output|

~~~shell
aws ecs register-task-definition --cli-input-json file://task-definition.json
~~~

3. Create an ECS Service from the above Task Definition.

First create the initial service-definition.json file.

~~~shell
cp template-service-definition.json service-definition.json
sed -ie "s/#00LAB00#/${LAB_NUMBER}/g" service-definition.json
~~~

~~~shell
# Deploy the thumbnail-service
aws ecs create-service --cli-input-json file://service-definition.json

# Verify the thumbnail-service has been deployed successfully
# The command will wait till the service has been deployed. No output is returned.
aws ecs wait services-stable \
--cluster ecs-workshop-cluster-${LAB_NUMBER} \
--services thumbnail-service

# Verify the desired and running tasks for the service
aws ecs describe-services \
--cluster ecs-workshop-cluster-${LAB_NUMBER} \
--services thumbnail-service \
--query 'services[0].{desiredCount:desiredCount,runningCount:runningCount,pendingCount:pendingCount}'
~~~

___

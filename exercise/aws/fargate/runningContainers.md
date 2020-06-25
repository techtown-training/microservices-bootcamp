# Microservices: AWS: Fargate
# Running Containers

### Objective

Run  a basic container on AWS ECS Fargate.

___

## Git Pull

Sometimes there are changes to the exercises as we move through the class sessions.  Unfortunately hands-on exercises do not always age well.  So let's make sure that we have the latest version of the class repo.

~~~shell
cd ~/microservices-bootcamp/
git pull
~~~

If there are any local changes that are preventing the "git pull" from merging we may have to work through those allow the command to complete.

___

## Running Containers in AWS Fargate

In this exercise we will run our first workload in AWS Fargate.  We will first create task definitions.  The task definitions are where we will define the work that will be done as containers within Fargate.  After that we will create a Service that runs the tasks as defined.

Before we get started let's see if there are any task definitions utilizing the "aws ecs" command context:

~~~shell
aws ecs list-task-definitions | grep ${LAB_NUMBER}
~~~

Since we have not created a task definition for your lab instance yet, let's do that now.  For this lab all the source files exist on disk.  First we will switch to that directory:

~~~shell
cd ~/microservices-bootcamp/exercise/aws/source/fargate/runningContainers/
~~~

## Create task file

Next we will start with the example task template file, but we will make a copy of it for our local changes:

~~~shell
cp template-fargate-task.json fargate-task.json
~~~

Let's make some local modifications to our task definitions to include our unique lab ID.  We will edit the task definition file in place using 'sed':

~~~shell
sed -ie "s/#00LAB00#/${LAB_NUMBER}/g" fargate-task.json
~~~

## Register the task

Now take a look at the "fargate-task.json" file to get an understanding of what is being defined within this specific task.  When you are ready let's register the task definition with AWS:

~~~shell
aws ecs register-task-definition --cli-input-json file://$HOME/microservices-bootcamp/exercise/aws/source/fargate/runningContainers/fargate-task.json
~~~

Now let's again checkout the registered task definitions on our AWS account.  We should have one that correlates to our lab instance ID:

~~~shell
aws ecs list-task-definitions | grep ${LAB_NUMBER}
~~~

## Start the service

We need to store the task definition ID for our registered task into an environment variable to use later:

~~~shell
export TASK_DEFINITION=`aws ecs list-task-definitions --output text | grep fargate-${LAB_NUMBER} | head -n1 | cut -d/ -f2`
~~~

We should now have the task definition stored in the environment variable ${TASK_DEFINITION}

~~~bash
echo ${TASK_DEFINITION}
~~~

Now that we have the task definition defined let's create the service that runs that task within Fargate on our own fargate cluster:

~~~shell
aws ecs create-service --cluster fargate-cluster-${LAB_NUMBER} --service-name fargate-service-${LAB_NUMBER} --task-definition ${TASK_DEFINITION} --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[${LAB_SUBNET}],securityGroups=[${LAB_SECURITYGROUP}],assignPublicIp=ENABLED}"
~~~

We can checkout what services are running on our lab:

~~~shell
aws ecs list-services --cluster fargate-cluster-${LAB_NUMBER}
~~~

In addition to listing the services on our cluster we also can list the running tasks on our cluster:

~~~shell
aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER}
~~~

## Connect to service task

We do need to figure out what IP fargate assigned to our running service.  For that we first need to have the task ID stored in an environment variable:

~~~shell
export TASK_ID=`aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER} --output text | head -n1 | cut -d/ -f2`
~~~

We can verify that the ${TASK_ID} is now set:

~~~shell
echo ${TASK_ID}
~~~

We now can correlate that TASK_ID with a specific network interface in AWS.  We can store that network interfaces ID in and environment variable like this:

~~~shell
export TASK_NETWORK_INTERFACE_ID=$(aws ecs describe-tasks --cluster fargate-cluster-${LAB_NUMBER} --task ${TASK_ID} --query 'tasks[0].attachments[0].details[?name == `networkInterfaceId`].value' --output text)
~~~

Our network interface ID should now be stored in the ${TASK_NETWORK_INTERFACE_ID} environment variable:

~~~shell
echo ${TASK_NETWORK_INTERFACE_ID}
~~~

Now we can lookup the Puplic IP address of that TASK_NETWORK_INTERFACE_ID.  That is the ip address that the service is using to publish the container as a service:

~~~shell
aws ec2 describe-network-interfaces --network-interface-ids ${TASK_NETWORK_INTERFACE_ID} --query 'NetworkInterfaces[0].Association.PublicIp' --output text
~~~

Try connecting to that IP using a local browser on your machine over http.  So you should connect to "http://<FargateServiceIP>", replacing "FargateServiceIP" with the IP returned from the previous command.  If all goes well you should be presented with a webpage customized for your specific lab instance.

___

### Let the Instructor know

Send a screenshot of the webpage provided by your Fargate task to the instructor.

___


## Clean up

Next let's cleanup after ourselves.  Before we can remove our service we first need to shutdown the tasks running for that service.  We can do that by setting our "desired-count" to "0":

~~~shell
aws ecs update-service --cluster fargate-cluster-${LAB_NUMBER} --service fargate-service-${LAB_NUMBER} --desired-count=0
~~~

After a few seconds the task should shutdown at which point we can remove the service completely:

~~~shell
aws ecs delete-service --cluster fargate-cluster-${LAB_NUMBER} --service fargate-service-${LAB_NUMBER}
~~~

We also can remove our task definition:

~~~shell
aws ecs deregister-task-definition --task-definition ${TASK_DEFINITION}
~~~

##  verify service and task removal

Now we can verify that we have stopped the services:

~~~shell
aws ecs list-services --cluster fargate-cluster-${LAB_NUMBER}
aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER}
~~~

___




# Customize the Microservice

Customize the Microservice

In this section the desire is to build on skills we have used in the previous labs to build our own docker image, push that image to an ECR and finally deploy that image as a task on a Fargate service.

I have some examples in this directory but the idea is for you to customize build your own images.

So lets have some local directories to work in:

### Create project files

~~~shell
mkdir -p ~/myFargate/image
mkdir ~/myFargate/task
cd ~/myFargate/image
~~~

Now in this directory create a Dockerfile for your image.  Here is an example Dockerfile but feel free to make your own:

~~~yaml
FROM alpine:3.11
MAINTAINER Jordan Clark mail@jordanclark.us

ENV S6_OVERLAY_VERSION 1.22.1.0
ENV S6_OVERLAY_MD5HASH 3060e2fdd92741ce38928150c0c0346a

RUN apk add --no-cache wget ca-certificates && \
apk --no-cache --update upgrade && \
cd /tmp && \
wget https://github.com/just-containers/s6-overlay/releases/download/v$S6_OVERLAY_VERSION/s6-overlay-amd64.tar.gz && \
echo "$S6_OVERLAY_MD5HASH *s6-overlay-amd64.tar.gz" | md5sum -c - && \
tar xzf s6-overlay-amd64.tar.gz -C / && \
rm s6-overlay-amd64.tar.gz && \
wget -P /etc/cont-init.d/ https://raw.githubusercontent.com/p42/s6-alpine-docker/3.11/container-files/etc/cont-init.d/00_bootstrap.sh

RUN apk add --no-cache nginx && \
mkdir /run/nginx && \
rm /etc/nginx/nginx.conf && \
wget -P /etc/nginx/ https://raw.githubusercontent.com/p42/nginx-s6-alpine-docker/master/container-files/etc/nginx/nginx.conf && \
mkdir /etc/services.d/nginx && \
wget -P /etc/services.d/nginx/ https://raw.githubusercontent.com/p42/nginx-s6-alpine-docker/master/container-files/etc/services.d/nginx/run

RUN echo '<html> <head> <title>myFargate</title> <style>body {margin-top: 40px;} </style> </head><body> <div style=text-align:center> <h1>myFargate</h1> <h2>Congratulations!</h2> <p>My application is running in Fargate.</p> </div></body></html>' > /var/lib/nginx/html/index.html

ENTRYPOINT ["/init"]
~~~

## Build and Tag the image

Now let's bulid that image:

~~~shell
docker build -t myfargate:latest .
~~~

tag that image for ECR:

~~~shell
docker tag myfargate:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${LAB_NUMBER}-repo/myfargate:latest
~~~

## Push image to the repository

Before we push the image to the ECR we first need to create the repository:

~~~shell
aws ecr create-repository --repository-name ${LAB_NUMBER}-repo/myfargate
~~~

Now that that image is properly tagged we can now push it to the ECR:

~~~shell
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${LAB_NUMBER}-repo/myfargate:latest
~~~

## Register the task

Now lets switch directory to work on our task definitions:

~~~shell
cd ~/myFargate/task
~~~

~~~bash
cp ~/microservices-bootcamp/exercise/aws/source/fargate/custom/template-custom-task.json myfargate-task.json
~~~

Let's make some local modifications to our task definitions to include our unique lab ID.  We will edit the task definition file in place using 'sed':

~~~shell
sed -ie "s/#00LAB00#/${LAB_NUMBER}/g" myfargate-task.json
~~~

Let's customize the image to use in the task:

~~~shell
sed -ie "s/#00IMAGE00#/${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com\/${LAB_NUMBER}-repo\/myfargate:latest/g" myfargate-task.json
~~~

We need to attach the AWS Account ID:

~~~shell
sed -ie "s/#00AWSID00#/${AWS_ACCOUNT_ID}/g" myfargate-task.json
~~~

Take a look at your "myfargate-task.json" file make some changes, adjust as desired to make it your own.  When you are ready let's register the task definition with AWS:

~~~shell
aws ecs register-task-definition --cli-input-json file://$HOME/myFargate/task/myfargate-task.json
~~~

You should see the registered task definitions on our AWS account:

~~~shell
aws ecs list-task-definitions | grep ${LAB_NUMBER}
~~~

## Start the service

We need to store the task definition ID for our registered task into an environment variable to use later:

~~~shell
export MYTASK_DEFINITION=`aws ecs list-task-definitions --output text | grep myfargate-${LAB_NUMBER} | tail -n1 | cut -d/ -f2`
~~~

Now that we have the task definition defined let's create the service that runs that task within Fargate on our own fargate cluster:

~~~shell
aws ecs create-service --cluster fargate-cluster-${LAB_NUMBER} --service-name myfargate-service-${LAB_NUMBER} --task-definition ${MYTASK_DEFINITION} --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[${LAB_SUBNET}],securityGroups=[${LAB_SECURITYGROUP}],assignPublicIp=ENABLED}"
~~~

## Connect to the service

We can checkout what services are running on our lab:

~~~shell
aws ecs list-services --cluster fargate-cluster-${LAB_NUMBER}
~~~

In addition to listing the services on our cluster we also can list the running tasks on our cluster:

~~~shell
aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER}
~~~

We do need to figure out what IP fargate assigned to our running service.  For that we first need to have the task ID stored in an environment variable:

~~~shell
export TASK_ID=`aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER} --output text | head -n1 | cut -d/ -f2`
~~~

We now can correlate that TASK_ID with a specific network interface in AWS.  We can store that network interfaces ID in and environment variable like this:

~~~shell
export TASK_NETWORK_INTERFACE_ID=$(aws ecs describe-tasks --cluster fargate-cluster-${LAB_NUMBER} --task ${TASK_ID} --query 'tasks[0].attachments[0].details[?name == `networkInterfaceId`].value' --output text)
~~~

Now we can lookup the public IP address of that TASK_NETWORK_INTERFACE_ID.  That is the ip address that the service is using to publish the container as a service:

~~~shell
aws ec2 describe-network-interfaces --network-interface-ids ${TASK_NETWORK_INTERFACE_ID} --query 'NetworkInterfaces[0].Association.PublicIp' --output text
~~~

Since you are running a web service you can try connecting to that IP using a local browser on your machine over http.  So you should connect to "http://<FargateServiceIP>", replacing "FargateServiceIP" with the IP returned from the previous command.  If all goes well you should be presented with a webpage customized for your specific lab instance.

___


## Clean up

Next let's cleanup after ourselves.  Before we can remove our service we first need to shutdown the tasks running for that service.  We can do that by setting our "desired-count" to "0":

~~~shell
aws ecs update-service --cluster fargate-cluster-${LAB_NUMBER} --service myfargate-service-${LAB_NUMBER} --desired-count=0
~~~

After a few seconds the task should shutdown at which point we can remove the service completely:

~~~shell
aws ecs delete-service --cluster fargate-cluster-${LAB_NUMBER} --service myfargate-service-${LAB_NUMBER}
~~~

We also can remove our task definition:

~~~shell
aws ecs deregister-task-definition --task-definition ${MYTASK_DEFINITION}
~~~

##  verify service and task removal

Now we can verify that we have stopped the services:

~~~shell
aws ecs list-services --cluster fargate-cluster-${LAB_NUMBER}
aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER}
~~~

___

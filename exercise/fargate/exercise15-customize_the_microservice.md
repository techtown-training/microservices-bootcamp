# Exercise 15: Customize the Micro-service

## This exercise needs finalize it will be finish shortly

In this lab the desire is to build on skills we have used in the previous labs to build our own docker image, push that image to an ECR and finally deploy that image as a task on a Fargate service.

I have some examples in this directory but the idea is for you to customize build your own images.

So lets first have a directory to work in:

~~~bash
mkdir -p ~/myFargate/image
mkdir ~/myFargate/task
cd ~/myFargate/image
~~~

Now in this directory create a Dockerfile for your image.  Here is an example Dockerfile but feel free to make your own:
~~~yaml
FROM alpine:3:11
MAINTAINER Jordan Clark mail@jordanclark.us

ENV S6_OVERLAY_VERSION 1.22.1.0
ENV S6_OVERLAY_MD5HASH 3060e2fdd92741ce38928150c0c0346a

RUN apk add --no-cache wget ca-certificates && \
apk --no-cache --update upgrade && \
cd /tmp && \
wget https://github.com/just-containers/s6-overlay/releases/download/v$S6_OVERLAY_VERSION/s6-overlay-amd64.tar.gz && \
echo "$S6_OVERLAY_MD5HASH *s6-overlay-amd64.tar.gz" | md5sum -c - && \
tar xzf s6-overlay-amd64.tar.gz -C / && \
rm s6-overlay-amd64.tar.gz

RUN apk add --no-cache nginx && \
mkdir /run/nginx

ENTRYPOINT ["/init"]
~~~

Now let's bulid that image:
~~~bash
docker build -t myfargate:latest .
~~~

And let's tag that image for ECR:
~~~bash
docker tag myfargate:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/myfargate:latest
~~~

Now that that image is properly tagged we can now push it to the ECR:
~~~bash
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/myfargate:latest
~~~

Now lets switch directory to work on our task definitions:
~~~bash
cd ~/myFargate/task
~~~

~~~bash
cp ~/microservices-bootcamp/exercise/fargate/source/15/template-fargate-task.json myfargate-task.json
~~~

Let's make some local modifications to our task definitions to include our unique lab ID.  We will edit the task definition file in place using 'sed':
~~~bash
sed -ie "s/#00LAB00#/${LAB_NUMBER}/g" myfargate-task.json
~~~

Let's customize the image to use in the task:
~~~bash
sed -ie "s/#00IMAGE00#/${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com\/myfargate:latest/g" myfargate-task.json
~~~


Take a look at your "myfargate-task.json" file if there are changes feel free to adjust as desired.  When you are ready let's register the task definition with AWS:
~~~bash
aws ecs register-task-definition --cli-input-json file://$HOME/myFargate/task/myfargate-task.json
~~~

You should see the registered task definitions on our AWS account:
~~~bash
aws ecs list-task-definitions
~~~

We need to store the task definition ID for our registered task into an environment variable to use later:
~~~bash
export MYTASK_DEFINITION=`aws ecs list-task-definitions --output text | grep fargate-${LAB_NUMBER} | head -n1 | cut -d/ -f2`
~~~

Now that we have the task definition defined let's create the service that runs that task within Fargate on our own fargate cluster:
~~~bash
aws ecs create-service --cluster fargate-cluster-${LAB_NUMBER} --service-name fargate-service-${LAB_NUMBER} --task-definition ${TASK_DEFINITION} --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[${LAB_SUBNET}],securityGroups=[${LAB_SECURITYGROUP}],assignPublicIp=ENABLED}"
~~~

We can checkout what services are running on our lab:
~~~bash
aws ecs list-services --cluster fargate-cluster-${LAB_NUMBER}
~~~

In addition to listing the services on our cluster we also can list the running tasks on our cluster:
~~~bash
aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER}
~~~

We do need to figure out what IP fargate assigned to our running service.  For that we first need to have the task ID stored in an environment variable:
~~~bash
export TASK_ID=`aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER} --output text | head -n1 | cut -d/ -f2`
~~~

We now can correlate that TASK_ID with a specific network interface in AWS.  We can store that network interfaces ID in and environment variable like this:
~~~bash
export TASK_NETWORK_INTERFACE_ID=$(aws ecs describe-tasks --cluster fargate-cluster-${LAB_NUMBER} --task ${TASK_ID} --query 'tasks[0].attachments[0].details[?name == `networkInterfaceId`].value' --output text)
~~~

Now we can lookup the Puplic IP address of that TASK_NETWORK_INTERFACE_ID.  That is the ip address that the service is using to publish the container as a service:
~~~bash
aws ec2 describe-network-interfaces --network-interface-ids ${TASK_NETWORK_INTERFACE_ID} --query 'NetworkInterfaces[0].Association.PublicIp' --output text
~~~

Try connecting to that IP using a local browser on your machine over http.  So you should connect to "http://<FargateServiceIP>", replacing "FargateServiceIP" with the IP returned from the previous command.  If all goes well you should be presented with a webpage customized for your specific lab instance.

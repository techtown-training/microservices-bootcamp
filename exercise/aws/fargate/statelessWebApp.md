# Microservices: AWS: Fargate
# Stateless Web Application

### Objective

___

## AWS Interface Note:

In this section we will be working directly with AWS.  The exercise demonstrates the steps needed to accomplish each specific task using the AWS-CLI.  This is works well and is a consistent way to interface with AWS.  Although the same tasks can be done via the web-based AWS Console using the CLI or the API are essential skills to have when automating workflow.  __As a learning exercise feel free to login to the AWS Console and reflect also what is happing there as you work though each step.__  The AWS Console is an excellent tool to not only assist in leaning but also with day to day monitoring and troubleshooting.   But do not become reliant on just the AWS Console, as was mentioned before, that interface alone does not help with automation.  Automation is an essential requirement for DevOps, Pipelining and of course Microservices.

___

### Parts

In this exercise we will run the a stateless web application from the earlier exercise this time in AWS Fargate ECS.  First change to the directory to build the stateless:

~~~shell
cd ~/microservices-bootcamp/exercise/aws/source/fargate/stateless/image/
~~~

Create the ECR repository:

~~~shell
aws ecr create-repository --repository-name ${LAB_NUMBER}-repo/stateless
~~~

You can verify that the ECR repository is created:

~~~shell
aws ecr describe-repositories | grep ${LAB_NUMBER}-repo/stateless
~~~

## Build the image

Build the docker image that will be used by the stateless Fargate service:

~~~shell
docker build -t stateless:fargate .
~~~

Let's tag the image with the ECR required tag:

~~~shell
docker tag stateless:fargate ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${LAB_NUMBER}-repo/stateless:fargate
~~~

We can verify that the image exists and has the proper tag:

~~~shell
docker image ls
~~~

## Push the image to ECR

Make sure we are logged into the ECR:

~~~shell
aws ecr get-login  | sed 's/-e none //g' > ~/docker.login
~~~

We stored the login command in a local file "docker.login".  Let's now run that command that includes the login credentials and have our local docker client ready to push images:

~~~shell
bash ~/docker.login
~~~

Once logged in we have authorization to push the image to ECR:

~~~shell
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${LAB_NUMBER}-repo/stateless:fargate
~~~

## Create the ECS Task

~~~shell
cd ~/microservices-bootcamp/exercise/aws/source/fargate/stateless/
~~~

See what task are currently defined for your Lab instance, there should be none:

~~~shell
aws ecs list-task-definitions | grep ${LAB_NUMBER}
~~~

Copy the task template to a location we can work with:

~~~shell
cp template-fargate-stateless-task.json fargate-stateless-task.json
~~~

Let's make some local modifications to our task definitions to include our unique lab ID.  We will edit the task definition file in place using 'sed':

~~~shell
sed -ie "s/#00LAB00#/${LAB_NUMBER}/g" fargate-stateless-task.json
~~~

And we need to set the image name:

~~~shell
sed -ie "s/#00IMAGE00#/${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com\/${LAB_NUMBER}-repo\/stateless:fargate/g" fargate-stateless-task.json
~~~

The AWS account ID needs to be replaced also:

~~~shell
sed -ie "s/#00AWSACCOUNTID00#/${AWS_ACCOUNT_ID}/g" fargate-stateless-task.json
~~~

## Register the Task

Now we can register the task that is defined in the `fargate-stateless-task.json` file:

~~~shell
aws ecs register-task-definition --cli-input-json file://$HOME/microservices-bootcamp/exercise/aws/source/fargate/stateless/fargate-stateless-task.json
~~~

Now let's again checkout the registered task definitions on our AWS account.  We should have one that correlates to our lab instance ID:

~~~shell
aws ecs list-task-definitions | grep ${LAB_NUMBER}
~~~

## Create the Service:

We need to get the defined task ID:

~~~shell
export TASK_DEFINITION_STATELESS=`aws ecs list-task-definitions --output text | grep fargate-stateless-${LAB_NUMBER} | head -n1 | cut -d/ -f2`
~~~

This command should return the task ID:

~~~shell
echo ${TASK_DEFINITION_STATELESS}
~~~

Now we have the information we need to start the Fargate ECS Service:

~~~shell
aws ecs create-service --cluster fargate-cluster-${LAB_NUMBER} --service-name fargate-stateless-${LAB_NUMBER} --task-definition ${TASK_DEFINITION_STATELESS} --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[${LAB_SUBNET}],securityGroups=[${LAB_SECURITYGROUP}],assignPublicIp=ENABLED}"
~~~

## Verify the service

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
export TASK_ID_STATELESS=`aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER} --output text | head -n1 | cut -d/ -f2`
~~~

We can verify that the ${TASK_ID_STATELESS} is now set:

~~~shell
echo ${TASK_ID_STATELESS}
~~~

We now can correlate that TASK_ID_STATELESS with a specific network interface in AWS.  We can store that network interfaces ID in and environment variable like this:

~~~shell
export TASK_NETWORK_INTERFACE_STATELESS_ID=$(aws ecs describe-tasks --cluster fargate-cluster-${LAB_NUMBER} --task ${TASK_ID_STATELESS} --query 'tasks[0].attachments[0].details[?name == `networkInterfaceId`].value' --output text)
~~~

Our network interface ID should now be stored in the ${TASK_NETWORK_INTERFACE_STATELESS_ID} environment variable:

~~~shell
echo ${TASK_NETWORK_INTERFACE_STATELESS_ID}
~~~

Now we can lookup the Puplic IP address of that TASK_NETWORK_INTERFACE_STATELESS_ID.  That is the ip address that the service is using to publish the container as a service:

~~~shell
aws ec2 describe-network-interfaces --network-interface-ids ${TASK_NETWORK_INTERFACE_STATELESS_ID} --query 'NetworkInterfaces[0].Association.PublicIp' --output text
~~~

Try connecting to that IP using a local browser on your machine over http.  So you should connect to "http://<FargateServiceIP>", replacing "FargateServiceIP" with the IP returned from the previous command.  If all goes well you should be presented with a webpage customized for your specific lab instance.


___

### Let the Instructor know

Take a screenshot of webpage running from Fargate ECS, email it to the instructor.

___


## Clean up

Next let's cleanup after ourselves.  Before we can remove our service we first need to shutdown the tasks running for that service.  We can do that by setting our "desired-count" to "0":

~~~shell
aws ecs update-service --cluster fargate-cluster-${LAB_NUMBER} --service fargate-stateless-${LAB_NUMBER} --desired-count=0
~~~

After a few seconds the task should shutdown at which point we can remove the service completely:

~~~shell
aws ecs delete-service --cluster fargate-cluster-${LAB_NUMBER} --service fargate-stateless-${LAB_NUMBER}
~~~

We also can remove our task definition:

~~~shell
aws ecs deregister-task-definition --task-definition ${TASK_DEFINITION_STATELESS}
~~~

# verify service and task removal
Now we can verify that we have stopped the services:

~~~shell
aws ecs list-services --cluster fargate-cluster-${LAB_NUMBER}
aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER}
~~~

___

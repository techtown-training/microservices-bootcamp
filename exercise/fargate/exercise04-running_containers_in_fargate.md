# Exercise 04: Running Containers in AWS Fargate

In this excersise we will run our first workload in AWS Fargate.  We will first create task definitions.  The task definitions are where we will define the work that will be done as contaners within Fargate.  After that we will create a Service that runs the tasks as defined.

Before we get started let's see if there are any task definitions utilizing the "aws ecs" command context:
~~~bash
aws ecs list-task-definitions
~~~

Since we have not created a task definition for your lab instance yet, let's do that now.  For this lab all the source files exist on disk.  First we will switch to that directory:
~~~bash
cd ~/microservices-bootcamp/exercise/fargate/source/04/
~~~

Next we will start with the example task template file, but we will make a copy of it for our local changes:
~~~bash
cp template-fargate-task.json fargate-task.json
~~~

Let's make some local modifications to our task definitions to include our unique lab ID.  We will edit the task definition file in place using 'sed':
~~~bash
sed -ie "s/#00LAB00#/${LAB_NUMBER}/g" fargate-task.json
~~~

Now take a look at the "fargate-task.json" file to get an understanding of what is being defined within this specific task.  When you are ready let's register the task definition with AWS:
~~~bash
aws ecs register-task-definition --cli-input-json file://$HOME/microservices-bootcamp/exercise/fargate/source/04/fargate-task.json
~~~

Now let's again checkout the registered task definitions on our AWS account.  We should have one that correlates to our lab instance ID:
~~~bash
aws ecs list-task-definitions
~~~

We need to store the task definition ID for our registered task into an environment variable to use later:
~~~bash
export TASK_DEFINITION=`aws ecs list-task-definitions --output text | grep fargate-${LAB_NUMBER} | head -n1 | cut -d/ -f2`
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

Next let's cleanup after ourselves.  Before we can remove our service we first need to shutdown the tasks running for that service.  We can do that by setting our "desired-count" to "0":
~~~bash
aws ecs update-service --cluster fargate-cluster-${LAB_NUMBER} --service fargate-service-${LAB_NUMBER} --desired-count=0
~~~

After a few seconds the task should shutdown at which point we can remove the service completely:
~~~bash
aws ecs delete-service --cluster fargate-cluster-${LAB_NUMBER} --service fargate-service-${LAB_NUMBER}
~~~

We also can remove our task definition:
~~~bash
aws ecs deregister-task-definition --task-definition ${TASK_DEFINITION}
~~~

# verify service and task removal
Now we can verify that we have stopped the services:
~~~bash
aws ecs list-services --cluster fargate-cluster-${LAB_NUMBER}
aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER}
~~~

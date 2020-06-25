# Microservices: AWS: Fargate
# Wordpress on Fargate

### Objective

Install Wordpress on Fargate ECS.

___

## AWS Interface Note:

In this section we will be working directly with AWS.  The exercise demonstrates the steps needed to accomplish each specific task using the AWS-CLI.  This is works well and is a consistent way to interface with AWS.  Although the same tasks can be done via the web-based AWS Console using the CLI or the API are essential skills to have when automating workflow.  __As a learning exercise feel free to login to the AWS Console and reflect also what is happing there as you work though each step.__  The AWS Console is an excellent tool to not only assist in leaning but also with day to day monitoring and troubleshooting.   But do not become reliant on just the AWS Console, as was mentioned before, that interface alone does not help with automation.  Automation is an essential requirement for DevOps, Pipelining and of course Microservices.

___

## Task Definiton

Change to the proper working directory:

~~~shell
cd ~/microservices-bootcamp/exercise/aws/source/fargate/wordpress/
~~~

List the current task definitions for your lab instance, there probably currently are none:

~~~shell
aws ecs list-task-definitions | grep ${LAB_NUMBER}
~~~

Copy the task template:

~~~shell
cp template-fargate-wordpress-task.json fargate-wordpress-task.json
~~~

Let's make some local modifications to our task definitions to include our unique lab ID.  We will edit the task definition file in place using 'sed'.

Set the lab number:

~~~shell
sed -ie "s/#00LAB00#/${LAB_NUMBER}/g" fargate-wordpress-task.json
~~~

Set the AWS Account ID:

~~~shell
sed -ie "s/#00AWSACCOUNTID00#/${AWS_ACCOUNT_ID}/g" fargate-wordpress-task.json
~~~

Now we can register the task:

~~~shell
aws ecs register-task-definition --cli-input-json file://$HOME/microservices-bootcamp/exercise/aws/source/fargate/wordpress/fargate-wordpress-task.json
~~~

Now let's again checkout the registered task definitions on our AWS account.  We should have one that correlates to our lab instance ID:

~~~shell
aws ecs list-task-definitions | grep ${LAB_NUMBER}
~~~

## ECS Service

Query for the task definition ID:

~~~shell
export TASK_DEFINITION_WORDPRESS=`aws ecs list-task-definitions --output text | grep fargate-wordpress-${LAB_NUMBER} | head -n1 | cut -d/ -f2`
~~~

Verify that ID:

~~~shell
echo ${TASK_DEFINITION_WORDPRESS}
~~~

Create the service:

~~~shell
aws ecs create-service --cluster fargate-cluster-${LAB_NUMBER} --service-name fargate-wordpress-${LAB_NUMBER} --task-definition ${TASK_DEFINITION_WORDPRESS} --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[${LAB_SUBNET}],securityGroups=[${LAB_SECURITYGROUP}],assignPublicIp=ENABLED}"
~~~

Wait for the service to start, It should return to your shell when the service is started:

~~~shell
aws ecs wait services-stable --cluster fargate-cluster-${LAB_NUMBER} --services fargate-wordpress-${LAB_NUMBER}
~~~

Once that service starts you can now checkout what services are running on our lab:

~~~shell
aws ecs list-services --cluster fargate-cluster-${LAB_NUMBER}
~~~

In addition to listing the services on our cluster we also can list the running tasks on our cluster:

~~~shell
aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER}
~~~

## Connect to Wordpress

We do need to figure out what IP fargate assigned to our running service.  For that we first need to have the task ID stored in an environment variable:

~~~shell
export TASK_ID_WORDPRESS=`aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER} --output text | head -n1 | cut -d/ -f2`
~~~

We can verify that the ${TASK_ID_WORDPRESS} is now set:

~~~shell
echo ${TASK_ID_WORDPRESS}
~~~

We now can correlate that TASK_ID_WORDPRESS with a specific network interface in AWS.  We can store that network interfaces ID in and environment variable like this:

~~~shell
export TASK_NETWORK_INTERFACE_WORDPRESS_ID=$(aws ecs describe-tasks --cluster fargate-cluster-${LAB_NUMBER} --task ${TASK_ID_WORDPRESS} --query 'tasks[0].attachments[0].details[?name == `networkInterfaceId`].value' --output text)
~~~

Our network interface ID should now be stored in the ${TASK_NETWORK_INTERFACE_STATELESS_ID} environment variable:

~~~shell
echo ${TASK_NETWORK_INTERFACE_WORDPRESS_ID}
~~~

Now we can lookup the Puplic IP address of that TASK_NETWORK_INTERFACE_WORDPRESS_ID.  That is the ip address that the service is using to publish the container as a service:

~~~shell
aws ec2 describe-network-interfaces --network-interface-ids ${TASK_NETWORK_INTERFACE_WORDPRESS_ID} --query 'NetworkInterfaces[0].Association.PublicIp' --output text
~~~

Try connecting to that IP using a local browser on your machine over http.  So you should connect to "http://<FargateServiceIP>", replacing "FargateServiceIP" with the IP returned from the previous command.  If all goes well you should be presented with a webpage customized for your specific lab instance.

___

### Let the Instructor know

Nice Job, now try to login to the Wordpress instance and take a screenshot to share with the instructor.

___

Next let's cleanup after ourselves.  Before we can remove our service we first need to shutdown the tasks running for that service.  We can do that by setting our "desired-count" to "0":

~~~shell
aws ecs update-service --cluster fargate-cluster-${LAB_NUMBER} --service fargate-wordpress-${LAB_NUMBER} --desired-count=0
~~~

After a few seconds the task should shutdown at which point we can remove the service completely:

~~~shell
aws ecs delete-service --cluster fargate-cluster-${LAB_NUMBER} --service fargate-wordpress-${LAB_NUMBER}
~~~

We also can remove our task definition:

~~~shell
aws ecs deregister-task-definition --task-definition ${TASK_DEFINITION_WORDPRESS}
~~~

# verify service and task removal
Now we can verify that we have stopped the services:

~~~shell
aws ecs list-services --cluster fargate-cluster-${LAB_NUMBER}
aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER}
~~~

___

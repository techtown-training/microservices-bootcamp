# Microservices: AWS: Fargate
# Stateless Web Application

### Objective



### Parts


# Setup task

Register the task definition:

~~~shell
aws ecs register-task-definition --cli-input-json file://$HOME/microservices-bootcamp/exercise/aws/source/fargate/runningContainers/fargate-task.json
~~~

Verify the task definition:

~~~shell
aws ecs list-task-definitions | grep ${LAB_NUMBER}
~~~

Store new task definition in ${TASK_DEFINITION}

~~~shell
export TASK_DEFINITION=`aws ecs list-task-definitions --output text | grep fargate-${LAB_NUMBER} | head -n1 | cut -d/ -f2`
~~~

Create the service that runs that task within Fargate:

~~~shell
aws ecs create-service --cluster fargate-cluster-${LAB_NUMBER} --service-name myfargate-service-${LAB_NUMBER} --task-definition ${TASK_DEFINITION} --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[${LAB_SUBNET}],securityGroups=[${LAB_SECURITYGROUP}],assignPublicIp=ENABLED}"
~~~

Verify the service:

~~~shell
aws ecs list-services --cluster fargate-cluster-${LAB_NUMBER}
~~~

List the running tasks on our cluster:

~~~shell
aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER}
~~~

# Scaling the App

Let's look at scaling the myFargate service by adjusting the desired-count:

~~~shell
aws ecs update-service --cluster fargate-cluster-${LAB_NUMBER} --service myfargate-service-${LAB_NUMBER} --desired-count=2
~~~

After a short period of time you should now see 2 tasks running:

~~~shell
aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER}
~~~

___

### Let the Instructor know

Send a screenshot showing the multiple Fargate ECS Tasks to the instructor.

___


Feel free to also experiment with the service utilizing the AWS counsel.

## Clean-up

When we are finished let's cleanup after ourselves.  As we learned Before we can remove our service we first need to shutdown the tasks running for that service.  We can do that by setting our "desired-count" to "0":

~~~shell
aws ecs update-service --cluster fargate-cluster-${LAB_NUMBER} --service myfargate-service-${LAB_NUMBER} --desired-count=0
~~~

After a few seconds the task should shutdown at which point we can remove the service completely:

~~~shell
aws ecs delete-service --cluster fargate-cluster-${LAB_NUMBER} --service myfargate-service-${LAB_NUMBER}
~~~

We also can remove our task definition:

~~~shell
aws ecs deregister-task-definition --task-definition ${TASK_DEFINITION}
~~~

# verify service and task removal, It take a bit of time for the previous commands to complete:

Now we can verify that we have stopped the services:

~~~shell
aws ecs list-services --cluster fargate-cluster-${LAB_NUMBER}
aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER}
~~~

___

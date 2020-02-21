# Exercise 16: Scaling the App

Let's look at scaling the myFargate service by adjusting the desired-count:
~~~bash
aws ecs update-service --cluster fargate-cluster-${LAB_NUMBER} --service myfargate-service-${LAB_NUMBER} --desired-count=2
~~~

Feel free to also experiment with the service utilizing the AWS counsel.

Wen we are finished let's cleanup after ourselves.  As we learned Before we can remove our service we first need to shutdown the tasks running for that service.  We can do that by setting our "desired-count" to "0":
~~~bash
aws ecs update-service --cluster fargate-cluster-${LAB_NUMBER} --service myfargate-service-${LAB_NUMBER} --desired-count=0
~~~

After a few seconds the task should shutdown at which point we can remove the service completely:
~~~bash
aws ecs delete-service --cluster fargate-cluster-${LAB_NUMBER} --service myfargate-service-${LAB_NUMBER}
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

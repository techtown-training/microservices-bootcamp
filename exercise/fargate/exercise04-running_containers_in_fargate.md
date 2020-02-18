# Exercise 04: Running Containers in AWS Fargate
~~~bash
aws ecs list-task-definitions
~~~

~~~bash
cd ~/microservices-bootcamp/exercise/fargate/source/04/
cp template-fargate-task.json fargate-task.json
sed -ie "s/#00LAB00#/${LAB_NUMBER}/g" fargate-task.json
~~~

~~~bash
aws ecs register-task-definition --cli-input-json file://$HOME/microservices-bootcamp/exercise/fargate/source/04/fargate-task.json
~~~

~~~bash
aws ecs list-task-definitions
~~~

~~~bash
export TASK_DEFINITION=`aws ecs list-task-definitions --output text | grep fargate-${LAB_NUMBER} | head -n1 | cut -d/ -f2`
~~~

~~~bash
aws ecs create-service --cluster fargate-cluster-${LAB_NUMBER} --service-name fargate-service-${LAB_NUMBER} --task-definition ${TASK_DEFINITION} --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[${LAB_SUBNET}],securityGroups=[${LAB_SECURITYGROUP}],assignPublicIp=ENABLED}"
~~~

~~~bash
aws ecs list-services --cluster fargate-cluster-${LAB_NUMBER}
~~~

~~~bash
aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER}
~~~

~~~bash
export TASK_ID=`aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER} --output text | head -n1 | cut -d/ -f2`
~~~



~~~bash
export TASK_NETWORK_INTERFACE_ID=$(aws ecs describe-tasks --cluster fargate-cluster-${LAB_NUMBER} --task ${TASK_ID} --query 'tasks[0].attachments[0].details[?name == `networkInterfaceId`].value' --output text)
~~~

~~~bash
aws ec2 describe-network-interfaces --network-interface-ids ${TASK_NETWORK_INTERFACE_ID} --query 'NetworkInterfaces[0].Association.PublicIp' --output text
~~~

~~~bash
aws ecs update-service --cluster fargate-cluster-${LAB_NUMBER} --service fargate-service-${LAB_NUMBER} --desired-count=0
~~~

~~~bash
aws ecs delete-service --cluster fargate-cluster-${LAB_NUMBER} --service fargate-service-${LAB_NUMBER}
~~~

~~~bash
aws ecs deregister-task-definition --task-definition ${TASK_DEFINITION}
~~~

# verify service and task removal 
~~~bash
aws ecs list-services --cluster fargate-cluster-${LAB_NUMBER}
aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER}
~~~

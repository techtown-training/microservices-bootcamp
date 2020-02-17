# Exercise 04: Running Containers in AWS Fargate
~~~bash
aws ecs list-task-definitions
~~~

~~~bash
cd ~/microservices-bootcamp/exercise/fargate/source/04/
cp template-fargate-task.json fargate-task.json
sed -ie "s/#00LAB00#/${LAB_NUMBER}/g" fargate-task.json
aws ecs register-task-definition --cli-input-json file://$HOME/microservices-bootcamp/exercise/fargate/source/04/fargate-task.json
~~~

# Fix task number
~~~bash
aws ecs create-service --cluster fargate-cluster-${LAB_NUMBER} --service-name fargate-service-${LAB_NUMBER} --task-definition fargate-${LAB_NUMBER}:1 --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[${LAB_SUBNET}],securityGroups=[${LAB_SECURITYGROUP}],assignPublicIp=ENABLED}"
~~~

~~~bash
aws ecs list-services --cluster fargate-cluster-${LAB_NUMBER}
~~~

~~~bash
aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER}
~~~

#Get task id first####
~~~bash
aws ecs describe-tasks --cluster fargate-cluster-${LAB_NUMBER} --task b3718c4c-36e1-422a-98bd-d65e2e644b72 --query 'tasks[0].attachments[0].details[?name == `networkInterfaceId`].value' --output text
~~~

~~~bash
aws ec2 describe-network-interfaces --network-interface-ids eni-07d301ea3d912be15 --query 'NetworkInterfaces[0].Association.PublicIp' --output text
~~~

~~~bash
aws ecs update-service --cluster fargate-cluster-${LAB_NUMBER} --service fargate-service-${LAB_NUMBER} --desired-count=0
~~~

~~~bash
aws ecs delete-service --cluster fargate-cluster-${LAB_NUMBER} --service fargate-service-${LAB_NUMBER}
~~~

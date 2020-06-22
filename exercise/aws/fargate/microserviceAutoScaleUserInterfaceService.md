# Microservices: AWS: Fargate
# Microservice Auto Scale User Interface Service

### Objective



### Parts



___

# Setup auto scaling for User-Interface-Service

The process to create services that scale automatically has been made very easy, and is supported by the ECS console, CLI, and SDK. You choose the desired, minimum and maximum number of tasks, create one or more scaling policies, and Service Auto Scaling handles the rest. The service scheduler is also Availability Zone–aware, so you don’t have to worry about distributing your ECS tasks across multiple zones.

## Process overview

- Create CloudWatch Metrics.
- Register ECS service as a Scaling Target.
- Create Scaling Policy.
- Create CloudWatch Alarms.

___

## Setup auto scaling

Let us verify the current desired count of the user-interface-service.

~~~shell
# Verify the desired and running tasks for the service
aws ecs describe-services \
--cluster ecs-workshop-cluster-${LAB_NUMBER} \
--services user-interface-service \
--query 'services[0].{desiredCount:desiredCount,runningCount:runningCount,pendingCount:pendingCount}'
~~~

The above command showed that the user-interface-service's desired capacity is currently set to 1. We will setup autoscaling with CloudWatch metric **CPUUtilization** as the trigger. The capacity will be set as follows:

- minimum capacity = 2
- desired capacity = 2
- maximum capacity = 3

### Steps

1. Register the User-Interface-Service as an Application Auto Scaling target.

~~~shell
# Replace <EcsAutoscalingRoleArn> with value from ecs-workshop CloudFormation stack output
aws application-autoscaling register-scalable-target \
--service-namespace "ecs" \
--resource-id "service/ecs-workshop-cluster-${LAB_NUMBER}/user-interface-service" \
--scalable-dimension "ecs:service:DesiredCount" \
--min-capacity 2 \
--max-capacity 3 \
--role-arn "<EcsAutoscalingRoleArn>"

# Verify the desired and running tasks for the service.
# Notice that the desired cacpity is now set to 2
aws ecs describe-services \
--cluster ecs-workshop-cluster-${LAB_NUMBER} \
--services user-interface-service \
--query 'services[0].{desiredCount:desiredCount,runningCount:runningCount,pendingCount:pendingCount}'
~~~

3. Configure the scale-out policy when the average ECS service CPU utilization is greater than 50% for 1 minute.

First create the initial service-scale-out-policy.json file.

~~~shell
cp template-service-scale-out-policy.json service-scale-out-policy.json
sed -ie "s/#00LAB00#/${LAB_NUMBER}/g" service-scale-out-policy.json
~~~

~~~shell
# Add Scale-Out Policy
# Note the PolicyARN - required for the next command
aws application-autoscaling put-scaling-policy \
--cli-input-json file://service-scale-out-policy.json
~~~

~~~shell
# Scale Out Alarm - CPUUtilization > 50% for 1 minutes
aws cloudwatch put-metric-alarm \
--alarm-name "UIServiceScaleOutAlarm-${LAB_NUMBER}" \
--alarm-description "UI Service Scale-Out Alarm - CPU exceeds 50 percent" \
--metric-name "CPUUtilization" \
--namespace "AWS/ECS" \
--statistic "Average" \
--dimensions Name="ServiceName",Value="user-interface-service" Name="ClusterName",Value="ecs-workshop-cluster-${LAB_NUMBER}" \
--period 60 \
--evaluation-periods 1 \
--threshold 50.0 \
--comparison-operator GreaterThanOrEqualToThreshold \
--alarm-actions  "<PolicyARN from above command>"
~~~

4. Configure the scale-in policy when the average ECS service CPU utilization is less than 25% for 1 minute.

First create the initial service-scale-in-policy.json file.

~~~shell
cp template-service-scale-in-policy.json service-scale-in-policy.json
sed -ie "s/#00LAB00#/${LAB_NUMBER}/g" service-scale-in-policy.json
~~~

~~~shell
# Add Scale-In Policy
# Note the PolicyARN - required for the next command
aws application-autoscaling put-scaling-policy \
--cli-input-json file://service-scale-in-policy.json
~~~

~~~shell
# Scale In Alarm - CPUUtilization < 25% for 1 minute
aws cloudwatch put-metric-alarm \
--alarm-name "UIServiceScaleInAlarm-${LAB_NUMBER}" \
--alarm-description "UI Service Scale-Out Alarm - CPU less than 25 percent" \
--metric-name "CPUUtilization" \
--namespace "AWS/ECS" \
--statistic "Average" \
--dimensions Name="ServiceName",Value="user-interface-service" Name="ClusterName",Value="ecs-workshop-cluster-${LAB_NUMBER}" \
--period 60 \
--evaluation-periods 1 \
--threshold 25.0 \
--comparison-operator LessThanOrEqualToThreshold \
--alarm-actions  "<PolicyARN from above command>"
~~~

5. Let us now simulate load to test the autoscaling.

We will be using the "ab" utility that is found in the "apache2-utils" package.  Make the utility is installed.

~~~shell
sudo apt install -y apache2-utils
~~~

~~~shell
# Using Apache Bench to simulae load
# Replace <ALBDNSName> with Output value from the ecs-workshop CloudFormation Stack.
ab -n 150000 -c 500 http://<ALBDNSName>/

# Wait for a minimum of 3-5 minutes for the scaling event
# Open a new terminal and execute the below command to verify the desired count, which will now be set to 3
aws ecs describe-services \
--cluster ecs-workshop-cluster-${LAB_NUMBER} \
--services user-interface-service \
--query 'services[*].{desiredCount:desiredCount, runningCount:runningCount}'
~~~

___

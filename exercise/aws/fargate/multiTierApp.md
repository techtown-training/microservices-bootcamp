# Microservices: AWS: Fargate
# Multi-Tier Web Application

### Objective



### Parts




## Setup Taiga sources

We need to download some upstream git repos for this exercise.  Let's first change to the correct working directory:

~~~shell
cd ~/microservices-bootcamp/exercise/aws/source/fargate/multiTier/
~~~

Clone the `docker-taiga` git repo:

~~~shell
git clone https://github.com/thejordanclark/docker-taiga.git taiga
~~~

Change to the newly created directory:

~~~shell
cd taiga
~~~

Clone the "stable" `taiga-back` and `taiga-front-dist` repos as submodules:

~~~shell
git clone -b stable https://github.com/taigaio/taiga-back.git taiga-back
~~~

~~~shell
git clone -b stable https://github.com/taigaio/taiga-front-dist.git taiga-front-dist
~~~

## Install Taiga

~~~shell
cd ~/microservices-bootcamp/exercise/aws/source/fargate/multiTier/taiga/
~~~

~~~shell
aws ecr create-repository --repository-name ${LAB_NUMBER}-repo/taiga
~~~

~~~shell
aws ecr describe-repositories | grep ${LAB_NUMBER}-repo/taiga
~~~

~~~shell
docker build -t taiga:fargate .
~~~

~~~shell
docker tag taiga:fargate ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${LAB_NUMBER}-repo/taiga:fargate
~~~

~~~shell
docker image ls
~~~

~~~shell
aws ecr get-login  | sed 's/-e none //g' > ~/docker.login
~~~

We stored the login command in a local file "docker.login".  Let's now run that command that includes the login credentials and have our local docker client ready to push images:

~~~shell
bash ~/docker.login
~~~

~~~shell
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${LAB_NUMBER}-repo/taiga:fargate
~~~

___

~~~shell
cd ~/microservices-bootcamp/exercise/aws/source/fargate/multiTier/
~~~

~~~shell
aws ecs list-task-definitions | grep ${LAB_NUMBER}
~~~

~~~shell
cp template-fargate-multiTier-task.json fargate-multiTier-task.json
~~~

Let's make some local modifications to our task definitions to include our unique lab ID.  We will edit the task definition file in place using 'sed':

~~~shell
sed -ie "s/#00LAB00#/${LAB_NUMBER}/g" fargate-multiTier-task.json
~~~

~~~shell
sed -ie "s/#00AWSACCOUNTID00#/${AWS_ACCOUNT_ID}/g" fargate-multiTier-task.json
~~~

~~~shell
sed -ie "s/#00IMAGE00#/${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com\/${LAB_NUMBER}-repo\/taiga:fargate/g" fargate-multiTier-task.json
~~~


~~~shell
aws ecs register-task-definition --cli-input-json file://$HOME/microservices-bootcamp/exercise/aws/source/fargate/multiTier/fargate-multiTier-task.json
~~~

Now let's again checkout the registered task definitions on our AWS account.  We should have one that correlates to our lab instance ID:

~~~shell
aws ecs list-task-definitions | grep ${LAB_NUMBER}
~~~

###

~~~shell
export TASK_DEFINITION_TAIGA=`aws ecs list-task-definitions --output text | grep fargate-multiTier-${LAB_NUMBER} | head -n1 | cut -d/ -f2`
~~~

~~~shell
echo ${TASK_DEFINITION_TAIGA}
~~~

~~~shell
aws ecs create-service --cluster fargate-cluster-${LAB_NUMBER} --service-name fargate-multiTier-${LAB_NUMBER} --task-definition ${TASK_DEFINITION_TAIGA} --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[${LAB_SUBNET}],securityGroups=[${LAB_SECURITYGROUP}],assignPublicIp=ENABLED}"
~~~

~~~shell
aws ecs wait services-stable \
--cluster fargate-cluster-${LAB_NUMBER} \
--services fargate-multiTier-${LAB_NUMBER}
~~~

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
export TASK_ID_TAIGA=`aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER} --output text | head -n1 | cut -d/ -f2`
~~~

We can verify that the ${TASK_ID_TAIGA} is now set:

~~~shell
echo ${TASK_ID_TAIGA}
~~~

We now can correlate that TASK_ID_TAIGA with a specific network interface in AWS.  We can store that network interfaces ID in and environment variable like this:

~~~shell
export TASK_NETWORK_INTERFACE_TAIGA_ID=$(aws ecs describe-tasks --cluster fargate-cluster-${LAB_NUMBER} --task ${TASK_ID_TAIGA} --query 'tasks[0].attachments[0].details[?name == `networkInterfaceId`].value' --output text)
~~~

Our network interface ID should now be stored in the ${TASK_NETWORK_INTERFACE_STATELESS_ID} environment variable:

~~~shell
echo ${TASK_NETWORK_INTERFACE_TAIGA_ID}
~~~

Now we can lookup the Puplic IP address of that TASK_NETWORK_INTERFACE_TAIGA_ID.  That is the ip address that the service is using to publish the container as a service:

~~~shell
aws ec2 describe-network-interfaces --network-interface-ids ${TASK_NETWORK_INTERFACE_TAIGA_ID} --query 'NetworkInterfaces[0].Association.PublicIp' --output text
~~~

Try connecting to that IP using a local browser on your machine over http.  So you should connect to "http://<FargateServiceIP>", replacing "FargateServiceIP" with the IP returned from the previous command. It will take a few minutes to become available.

If everything worked as planned you should be presented with a "Taiga" page.  You can login to the app with the username="admin" and password="123123".

Next let's cleanup after ourselves.  Before we can remove our service we first need to shutdown the tasks running for that service.  We can do that by setting our "desired-count" to "0":

~~~shell
aws ecs update-service --cluster fargate-cluster-${LAB_NUMBER} --service fargate-multiTier-${LAB_NUMBER} --desired-count=0
~~~

After a few seconds the task should shutdown at which point we can remove the service completely:

~~~shell
aws ecs delete-service --cluster fargate-cluster-${LAB_NUMBER} --service fargate-multiTier-${LAB_NUMBER}
~~~

We also can remove our task definition:

~~~shell
aws ecs deregister-task-definition --task-definition ${TASK_DEFINITION_TAIGA}
~~~

# verify service and task removal
Now we can verify that we have stopped the services:

~~~shell
aws ecs list-services --cluster fargate-cluster-${LAB_NUMBER}
aws ecs list-tasks --cluster fargate-cluster-${LAB_NUMBER}
~~~

___

# Create ECS Cluster and Container Instances

__This section needs much administrator access to AWS__

___

## Task 1 - Create ECS Cluster

Let us create an ECS Cluster and add Container Instances to the ECS Cluster

~~~shell
# Note the ECS Cluster Arn
aws ecs create-cluster --cluster-name ecs-workshop-cluster-${LAB_NUMBER}

# Let us check the number of Container Instances in the ECS Cluster.
# It will be 0, as we have not joined any Containter Instances to the Cluster we just created.
aws ecs describe-clusters \
--clusters ecs-workshop-cluster-${LAB_NUMBER} \
--query clusters[0].registeredContainerInstancesCount
~~~

___

## Task 2 - Deploy Container Instances

Launch EC2 Instances and join them to the above ECS cluster. We will be using CloudFormation template to deploy and configure the Container instances.

~~~shell
# Get the following values from ecs-workshop CloudFormation Stack output
# Replace the following parameter placeholders in the below command:
# <SSH-KEY-NAME> - SSH Key Pair name in your Environment
# <VpcId>, <PrivateSubnet1Id>, <PrivateSubnet2Id>, <AlbSecurityGroupId>

aws cloudformation create-stack \
--stack-name ecs-workshop-container-instances-${LAB_NUMBER} \
--template-body file://cfn-templates/container-instances-template.yaml \
--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
--parameters \
ParameterKey="SshKeyName",ParameterValue="Default" \
ParameterKey="ECSClusterName",ParameterValue="ecs-workshop-cluster-${LAB_NUMBER}" \
ParameterKey="ECSClusterSize",ParameterValue=2 \
ParameterKey="VpcId",ParameterValue="${AWS_VPCID}" \
ParameterKey="PrivateSubnet1Id",ParameterValue="${AWS_PRIVATESUBNET1ID}" \
ParameterKey="PrivateSubnet2Id",ParameterValue="${AWS_PRIVATESUBNET2ID}" \
ParameterKey="AlbSecurityGroupId",ParameterValue="${AWS_ALBSECURITYGROUPID}"

# Verify that stack creation is complete
aws cloudformation wait stack-create-complete \
--stack-name ecs-workshop-container-instances-${LAB_NUMBER}
~~~

Once the above CloudFormation Stack creation is complete, let us check the ECS cluster status to verify the number of Cluster Instances.

~~~shell
# Let us check the number of Container Instances in the ECS Cluster.
# It will now be 2
aws ecs describe-clusters \
--clusters ecs-workshop-cluster-${LAB_NUMBER} \
--query clusters[0].registeredContainerInstancesCount
~~~

___

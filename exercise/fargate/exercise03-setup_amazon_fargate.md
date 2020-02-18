# Exercise 03: Setup Amazon Fargate

One of the benefits of Amazon Fargate is the fact that infrastructure does not have to be provisioned in advance.  Amazon Web Services when using Fargate will provision EC2 instances as needed to run the container workload.

For the labs we will need to setup the host that we will be using to manage the AWS Fargate workload from.  For that task each should receive an instance.  In the following steps we will prepare that instance with some environment variables that will be used through-out the labs and create an ECS cluster to house the exercise workload.

## Prepare Lab instances
We need an environment variable to use within this lab instance.  Run the following command replacing "lab00" with your lab instance number. For instance if you are number 42 set the environment variable to "lab42":
~~~bash
export LAB_NUMBER=lab00
~~~

Let also make this environment variable persist to new shells:
~~~bash
echo "export LAB_NUMBER=${LAB_NUMBER}" >> .bashrc
~~~

Lets collect some values from AWS that we will use in the labs including the VPC, Subnet, Security Group, AWS Account and Region to use.
~~~bash
export LAB_VPC=`aws ec2 describe-vpcs --filters Name=tag:Course,Values=MICROENGINEER --query 'Vpcs[].VpcId' --output text`
export LAB_SUBNET=`aws ec2 describe-subnets --filters Name=tag:Course,Values=MICROENGINEER --query 'Subnets[].SubnetId' --output text`
export LAB_SECURITYGROUP=`aws ec2 describe-security-groups --filters Name=tag:Course,Values=MICROENGINEER --query 'SecurityGroups[].GroupId' --output text`
export AWS_ACCOUNT_ID=`aws iam get-user --output json --query 'User.Arn' | cut -d: -f5`
export AWS_REGION=`cat ~/.aws/config | grep ^region | awk '{print $3}'`
~~~

As before lets make this environment variable persist to new shells:
~~~bash
echo "export LAB_VPC=${LAB_VPC}" >> .bashrc
echo "export LAB_SUBNET=${LAB_SUBNET}" >> .bashrc
echo "export LAB_SECURITYGROUP=${LAB_SECURITYGROUP}" >> .bashrc
echo "export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}" >> .bashrc
echo "export AWS_REGION=${AWS_REGION}" >> .bashrc
~~~

Through out the labs we will require a number of source files.  We can download this Git repo to the '~/microservices-bootcamp' directory:
~~~bash
cd ~/
git clone https://github.com/techtown-training/microservices-bootcamp.git
~~~

### Create Cluster
Let's first list the existing ECS clusters:
~~~bash
aws ecs list-clusters
~~~

If our cluster does not already exist run this command to create an ECS cluster for the exercises:
~~~bash
aws ecs create-cluster --cluster-name fargate-cluster-${LAB_NUMBER}
~~~

Go ahead and list the clusters and verify that your lab instance cluster exists.

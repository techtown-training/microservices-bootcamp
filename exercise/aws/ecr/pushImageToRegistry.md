# Microservices: AWS: ECR
# Push Image to Registry

### Objective



### Parts




# Push Image to ECR Registry

In this exercise we will be using AWS ECR to create a registry push an image to that registry.  For the context of the exercise we will push an upstream nginx image to our ECR registry.  

## Login to ECR

The first thing we need is some login credentials for docker to use to push the images to ECR.  Fortunately we can get those credentials with the "aws ecr get-login" command:

~~~shell
aws ecr get-login  | sed 's/-e none //g' > ~/docker.login
~~~

We stored the login command in a local file "docker.login".  Let's now run that command that includes the login credentials and have our local docker client ready to push images:

~~~shell
bash ~/docker.login
~~~

## Create the ECR repository

We need to create a image repository for each image we will be storing in AWS ECR.  We also will include our lab instance in the repository name to uniquely identify our specific images:

~~~shell
aws ecr create-repository --repository-name ${LAB_NUMBER}-repo/nginx
~~~

We can get a list of the repositories by describing them:

~~~shell
aws ecr describe-repositories
~~~

## Get an image to use for exercise

As I mentioned before we will be using an upstream nginx image for this exercise.  Let's pull that image into the local image store first:

~~~shell
docker pull nginx:1.17
~~~

## Tag image with ECR host and namespace

Now that we have the image local on our Linux instance, we need to "tag" that image as the unique name used in the ECR including the ECR hostname.  It does include stuff like what AWS account it is on and what AWS region the ECR is located in.  We will assign that tag with the "docker tag" context:

~~~shell
docker tag nginx:1.17 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${LAB_NUMBER}-repo/nginx:1.17
~~~

Now that that image is properly tagged we can now push it to the ECR:

## Push image to ECR

~~~shell
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${LAB_NUMBER}-repo/nginx:1.17
~~~

We can now verify that the image has been added by describing it:

~~~shell
aws ecr describe-images --repository-name ${LAB_NUMBER}-repo/nginx
~~~

___

### Let the Instructor know

Send a screenshot of output that lists the image layers that have been pushed to the ECR and share it with the instructor.

___

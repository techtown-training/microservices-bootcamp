# Microservices: AWS: ECR
# Pull Image from Registry

### Objective

Pull an image from AWS ECR and run a local Docker container using that image.

### Parts


___

## AWS Interface Note:

In this section we will be working directly with AWS.  The exercise demonstrates the steps needed to accomplish each specific task using the AWS-CLI.  This is works well and is a consistent way to interface with AWS.  Although the same tasks can be done via the web-based AWS Console using the CLI or the API are essential skills to have when automating workflow.  __As a learning exercise feel free to login to the AWS Console and reflect also what is happing there as you work though each step.__  The AWS Console is an excellent tool to not only assist in leaning but also with day to day monitoring and troubleshooting.   But do not become reliant on just the AWS Console, as was mentioned before, that interface alone does not help with automation.  Automation is an essential requirement for DevOps, Pipelining and of course Microservices.

___

### Clean up local image

In this exercise we will pull and use the image we pushed to the ECR.  First let's make sure we remove the local image tag:

~~~shell
docker image rm ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${LAB_NUMBER}-repo/nginx:1.18
~~~

Also just to make sure let's remove the image local upstream tag also:

~~~shell
docker image rm nginx:1.18
~~~

## Pull and Run image from ECR as container

Now let's pull and run an image based on the image we pushed to the ECR, notice it pulling the image from the ECR:

~~~shell
docker run -d --name FromECR -p 80:80 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${LAB_NUMBER}-repo/nginx:1.18
~~~

_Note: If there is an issue starting the `FromECR` container because of a port conflict on port 80 make sure that [k8s/SockShop](../k8s/sockShop.md) is stopped.  You can find the instruction to stop it at then end of that exercise.  Don't forget to remove the "Created" but not "Started" image before attempting to "run" a new image again with the same name. ;)_

We should now see the container running with the name "FromECR":

~~~shell
docker container ls
~~~

## Verify connectivity

Let's verify that we connect to the service from the Linux host:
~~~shell
curl http://localhost
~~~

Optionally we can see also prove that it works from a local browser by connecting to http://<AWS_EIP>/

~~~shell
echo ${AWS_EIP}
~~~

___

### Let the Instructor know

Send a screenshot of the website with the instructor the instructor to indicate that you have completed the exercise.

___

## Clean up

Let's stop the container:

~~~shell
docker stop FromECR
~~~

And remove the stopped "FromECR" container:

~~~shell
docker rm FromECR
~~~

And to finish cleaning up lets remove the image from the local image store:

~~~shell
docker image rm ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${LAB_NUMBER}-repo/nginx:1.18
~~~

___

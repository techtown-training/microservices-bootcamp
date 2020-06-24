# Microservices: AWS: ECR
# Pull Image from Registry

### Objective



### Parts




### Clean up local image

In this exercise we will pull and use the image we pushed to the ECR.  First let's make sure we remove the local image tag:

~~~shell
docker image rm ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${LAB_NUMBER}-repo/nginx:1.17
~~~

Also just to make sure let's remove the image local upstream tag also:

~~~shell
docker image rm nginx:1.17
~~~

## Pull and Run image from ECR as container

Now let's pull and run an image based on the image we pushed to the ECR, notice it pulling the image from the ECR:

~~~shell
docker run -d --name FromECR -p 80:80 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${LAB_NUMBER}-repo/nginx:1.17
~~~

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
docker image rm ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${LAB_NUMBER}-repo/nginx:1.17
~~~

___

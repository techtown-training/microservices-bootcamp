# Exercise 12: Pull Image from Registry

In this exercise we will pull and use the image we pushed to the ECR.  First let's make sure we remove the local image:
~~~bash
docker image rm ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/nginx:1.17
~~~

Also just to make sure let's remove the upstream image also:
~~~bash
docker image rm nginx:1.17
~~~

Now let's pull and run an image based on the image we pushed to the ECR:
~~~bash
docker run -d --name FromECR ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/nginx:1.17
~~~

We should now see the container running with the name "FromECR":
~~~bash
docker container ls
~~~

Let's stop the container
~~~bash
docker stop FromECR
~~~

And remove the stopped "FromECR" container:
~~~bash
docker remove FromECR
~~~

And to finish cleaning up lets remove the image from the local image store:
~~~bash
docker image rm ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/nginx:1.17
~~~

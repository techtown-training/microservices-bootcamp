# Microservices: AWS: Docker
# Simple Web Application

### Objective



### Parts




# Docker WebApp

Building on with what we learned in the last exercise, let's now install a simple webserver running nginx in docker publish it on port 80 of our Linux instance.  We will start this container again with the "docker run" command.  This time we add a "-d" to tell the container to detatch from the current shell and run in the background.  We also will name this container "webApp" and publish the service on port 80 of the linux host.  The "-p" creates a port-forward iptables rule on the host with a destination port 80, the number before the ":", forwarded to the container port 80, the number after the ":".  This container will use the official nginx image with version 1.17:

~~~shell
docker run -d --name webApp -p80:80 nginx:1.17
~~~

We now need to know what the external IP address is for your AWS Linux instance is.  You should have this IP address already.  It is the same IP that you use the connect to the Linux instance using SSH. To make it simple we also stored this IP in the environment variable $AWS_EIP:

~~~shell
echo $AWS_EIP
~~~

Before we connect to the new website let's first connect to the logs of nginx running in the container.  Docker containers typically write logs to standard-out which then allows us to see the logs using "docker logs".  We are also adding the "-f" option to "follow" the logs and we are connecting to the container by name, "webApp":

~~~shell
docker logs -f webApp
~~~

Now that we are watching the logs.  Open a browser and connect to the website at "http://<AWS_EIP>".  Don't forget to replace AWS_EIP with your actualy IP address.  You should see both the default nginx weppage and log entries in the docker logs.  To disconnect for the docker logs use "ctl-c".

We can also notice the "nginx:1.17" image in the local image store:

~~~shell
docker image ls
~~~

In addition to that we should still see the container running on the system:

~~~shell
docker container ls
~~~

To stop the "webApp" container we can us "docker container stop":

~~~shell
docker container stop webApp
~~~

We can remove the stopped "webApp" container:

~~~shell
docker container rm webApp
~~~

Let's also finish cleaning up after ourselves by removing the "nginx:1.17" image from the local image store:

~~~shell
docker image rm nginx:1.17
~~~

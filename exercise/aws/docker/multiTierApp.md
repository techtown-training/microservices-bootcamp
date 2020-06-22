# Microservices: AWS: Docker
# Multi-Tier Web Application

### Objective



### Parts


# Docker Multi-tier App

In this exercise we will deploy a more complex application that has a backend database and a frontend application.  We will be using an app called "Taiga" as the demo.  Taiga is an issue tracking application with a postgresql database for a datastor.  We will also be using docker-compose to build and deploy the "Taiga" application.  Docker-compose gives us the ability to represent a number of docker commands all in one common file.  Then that docker-compose file then can be used to deploy the entire stack of services with a single command on a single host.

Before we build and deploy "Taiga" we first need to install "docker-compose".  Using curl we will download docker-compose and install it to /usr/local/bin/docker-compose:

~~~shell
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
~~~

We then need to make sure that the new docker-compose file is executable:

~~~shell
sudo chmod +x /usr/local/bin/docker-compose
~~~

Now let's go ahead and link the docker-compose executable to /usr/bin/docker-compose to make sure it is in the shell path:

~~~shell
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
~~~

Let's verify that docker compose is loading by having it report it's version:

~~~shell
docker-compose --version
~~~

Now that we have docker-compose installed let's change to the build directory:

~~~shell
cd ~/microservices-bootcamp/exercise/aws/source/docker/multiTier/taiga/
~~~

The docker compose file has a few environment variables for the deployment.  One of the environment variables sets the hostname for the "Taiga" install.  Let's change that from "localhost" to the "AWS_EIP" address:

~~~shell
sed -ie "s/localhost/${AWS_EIP}/g" config.env
~~~

Now that we are all set.  Feel free to take a look at the docker-compose.yml file in additon to the Dockerfile to get an idea of what is going to happen.  When you are ready you can start the build / deploy by running "docker-compose up":

~~~shell
docker-compose up
~~~

The entire process will run in the foreground.  You should see it first build the image and download a postgresql image that will used.  The process will a take a few minutes to complete.  Once the image is built docker-compose will then start the database and the Taiga app which will initialize the database because it is the first run.  After that database is initialized the app will then finish starting up.

At this point log into the linux box with an additional SSH session because the current sessios is still tied up with docker-compose in the foreground which will continue to output the logs to to the terminal.  While on the new terminal look and see what docker images exist:

~~~shell
docker image ls
~~~

Also checkout what the running docker containers:

~~~shell
docker container ls
~~~

Let's again get the IP address and connect to the "http://<AWS_EIP>" url:

~~~shell
echo $AWS_EIP
~~~

If everything worked as planned you should be presented with a "Taiga" page.  You can login to the app with the username="admin" and password="123123"

When you are finished you can stop the docker-compose with "ctl-c".  If you want to start docker-compose in the background without dumping logs to the terminal you can use:

~~~shell
docker-compose up -d
~~~

To shutdown the app managed by docker-compose run:

~~~shell
docker-compose down
~~~

And to make sure the containers are cleaned up:

~~~shell
docker-compose rm
~~~

Docker-compose is a very handy tool when running workload on a single host.  To get more of an idea what docker-compose does check out the online help provided:

~~~shell
docker-compose help
~~~

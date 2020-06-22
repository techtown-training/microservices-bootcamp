# Microservices: AWS: Docker
# Helloworld!

### Objective



### Parts



# Docker Hello World!

### Docker: First container

Now that we have Docker installed let's run an image as a container:

~~~shell
docker run hello-world
~~~

What you will notice is first that the hello-world image was downloaded to the hosts local image stor.  We did not designate a version of the image so "latest" was used.

After the "hello-world:latest" image was downloaded locally.  That image was then run as a container.  The "hello-world" image when run outputs a "Hello from Docker!" followed by some helpful information to standard out which is displayed in the terminal. After the output is complete the container process exits cleanly and the container is now in a "stop" state.

#### Verify the hello-world image is local

We can see that the "helloworld:latest" image has been downloaded locally:

~~~shell
docker image ls
~~~

#### Verify the hello-world container has run

We also can "list" the current containers to see the container status.  On this command we will include the "-a" option which will list not only the running containers but the containers in a "stopped" / "Exited" state:

~~~shell
docker container ls -a
~~~

Notice that the container has a unique ID field (a truncated version of a SHA-256 hash) and a generated more human readable name.  When working with containers a truncated version of the container ID can be used to reference the container instance. We also can use the unique name to reference the containers.  In this insntace that name was generated as an adjective combined with a name of a person.

Let's store the container ID for the hello-world container in an environment variable to simplify the latter commands to clean up after ourselves:

~~~shell
export DOCKER_HELLOWORLD_CONTAINER=`docker container ls -a | grep hello-world | awk '{ print $1 }'`
~~~

#### View the output of the hello-world container

As you recall the standard output of the container was written to the terminal screen.  In addition to that it also is stored as container logs in the docker system.  To view the logs of the container run this command:

~~~shell
docker container logs ${DOCKER_HELLOWORLD_CONTAINER}
~~~

In this command as mentioned before we utilize an environment variable to identify the container instance.  You can replace that with the "Container ID" or the "Name" of the container.  Also as a help on many systems including these lab instances tab-complete is available.  Give it a try!   

#### Remove the container

Let's clean up after ourselves and remove the "stopped" container:

~~~shell
docker container rm ${DOCKER_HELLOWORLD_CONTAINER}
~~~

We can verify that the container is now removed by listing the current containers:

~~~shell
docker container ls -a
~~~

Now is a good time to mention an additional docker shortcut, would it not be nice to be able to run a docker container and have it remove itself when the processes in that container exits?  Fortunately the "--rm" option is for just the case:

~~~shell
docker run --rm hello-world
~~~

Now list the containers again to see if a new stopped container exists:

~~~shell
docker container ls -a
~~~

It does not.  The "--rm" works.

#### Something more ambitious

You may have noticed that the "hello-world" container mentioned doing something "more ambitious".  Let's do that by starting a new container this time based on "ubuntu:latest" and connect into the newly created container with a bash shell.  Notice in this command we added options for "-it" which enable an "interactive" "tty" interface for the "bash" process that will be run as the container command (CMD):

~~~shell
docker run -it ubuntu bash
~~~

Notice that the prompt changed to the new "Container ID".  This prompt is in a fresh Ubuntu container.  Feel free to explore.  When finished type 'exit' or 'ctl-d' to exit the bash process which stops the container and returns you to the host shell.

List the current containers and notice the recently exited ubuntu container:

~~~shell
docker container ls -a
~~~

As we did with the hello-world container let's store the "Container ID" in an environment variable:

~~~shell
export DOCKER_UBUNTU_CONTAINER=`docker container ls -a | grep ubuntu | awk '{ print $1 }'`
~~~

Let's again remove the stopped container:

~~~shell
docker container rm ${DOCKER_UBUNTU_CONTAINER}
~~~

#### Remove the images

We have one finial thing that we can optionally clean up.  we need to remove the images that where downloaded for "hello-world:latest" and "ubuntu:latest":

~~~shell
docker image rm hello-world:latest
docker image rm ubuntu:latest
~~~

Now we can verify the images have been removed:

~~~shell
docker image ls
~~~

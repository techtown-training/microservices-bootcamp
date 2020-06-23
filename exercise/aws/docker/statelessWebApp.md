# Microservices: AWS: Docker
# Stateless Web Application

### Objective

Run a simle javascript application in a Docker container.

### Parts


# Docker Stateless WebApp

In this exercise we will build and deploy a more complex but yet stateless web application.  We included the code in the git repo that was added during exercise 3.  Let's change to that directory so we have the source files to build our web application:

~~~shell
cd ~/microservices-bootcamp/exercise/aws/source/docker/stateless/
~~~

Feel free to look around in this directory.  You will notice a few things.  First there is a "Dockerfile" that explains what steps are needed to create a docker image for our web application.  In addition to the "Dockerfile" there also is simple javascript application in the "stateless.js" file.  That application will be coppied into the new container by the "COPY" line found on line number 3 of the "Dockerfile".

Now that we have looked around let's build this new image, for that we will use "docker build".  The newly built image is "tagged" with a name and version with the "-t stateless:v1" option.  Also notice the "." at the end of the line.  That tells "docker build" where to look for the "Dockerfile" and other artifacts that are needed to complete the build:

~~~shell
docker build -t stateless:v1 .
~~~

You should see all the steps described in the "Dockerfile" completed, each step creating an additional layer for the newly created image.  Now we should be able to see that image in our local image store:

~~~shell
docker image ls
~~~

Let's now run this new image as a container.  We will pass an environment key-value pair into the container with the "-e" option.  In this instance the APP_NAME environment variable is utilized by the javascript web application:

~~~shell
docker run -d -p80:80 --name stateless -e "APP_NAME=Stateless.v1" stateless:v1
~~~

As the previous exercise we published this web application on the AWS_EIP port 80 of your Linux instance.  Again we have conveniently stored the public AWS EIP for retrieval when we need it:

~~~shell
echo $AWS_EIP
~~~

As before with a local browser connect to you web application at "http://<AWS_EIP>".  You should be presented with a simple page including the APP_NAME passed in as an environment variable.

___

### Let the Instructor know

Send a screenshot of the running application to the instructor make sure to include the address field of your browser to show the URL.

___

Let's stop our "stateless" container:

~~~shell
docker container stop stateless
~~~

Now that the container is stopped we can remove it:

~~~shell
docker container rm stateless
~~~

This time let's leave the image in the local image store.  We will use it again in a later lab.

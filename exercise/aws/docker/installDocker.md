# Microservices: AWS: Docker
# Install Docker

### Objective

Install Docker on Lab instance.  Run First Docker Containers.  Review Docker CLI Basics.

### Parts

[Install Docker](#install-docker)
[Add user to docker group](#add-user-to-docker-group)
[Verify Docker](#verify-docker)

___

## Install Docker

In this exercise we will install the current version of Docker on the Ubuntu Lab instance.

Linux Distributions like Ubuntu, Debian, RHEL and CentOS all have a distribution managed docker package avalible in the official repositories but that distro managed version of Docker tends to be out-of-date.  Typically it is best to install a more current version of Docker by utilizing a repository managed by Docker to install Docker CE (Community Edition).

### Install Docker on Ubuntu

First we need to have some packages that need to be installed.  Yes, these packages are more then likely already installed but it does not hurt to verify:
~~~shell
sudo apt install -y software-properties-common curl
~~~

#### Add the package repository

Next we need to trust the key used to sign the packages in the Docker repository.  We also will then add that Docker repository to our system:
~~~shell
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
~~~

~~~shell
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
~~~

#### Install docker packages

Now that we have the package repository added we can update our local list of available packages. We then can install a specific version of docker that we will use for the exercises.  Notice that we will install the docker-ce and docker-ce-cli packages.  The "ce" indicates "community edition" which also distinguishes it from the Ubuntu distribution managed Docker package:

~~~shell
sudo apt update
~~~

~~~shell
sudo apt install -y docker-ce=5:18.09.9~3-0~ubuntu-bionic docker-ce-cli=5:18.09.9~3-0~ubuntu-bionic
~~~

#### Pin docker to a specific package version

The docker repository that we are installing always contains the newest version of Docker.  The newest version is sufficient in many cases but at other times it is required that we stay on a specific version of docker.  For these labs let's pin the docker packages to the current version installed:

~~~shell
sudo apt-mark hold docker-ce
~~~

~~~shell
sudo apt-mark hold docker-ce-cli
~~~

___

## Add user to docker group

To access Docker without sudo we can add a restricted user to the "docker" group.  We will do this for these labs but be aware that it is trivial to gain access to the entire system if you have write access to the docker socket.  So outside of the lab environments distribute this power with care:

~~~shell
sudo adduser $USER docker
~~~

We added our "ubuntu" user to the "docker" group but that change is not realized until a new shell is created.  One option is a bit of a hack but we can switch our primary group to "docker" then switch it back to "ubuntu" to relize that new group at the expense of a bit of bash history.  An alterative is to exit the shell and login again.

~~~shell
newgrp docker
newgrp ubuntu
~~~

___

## Verify Docker

Now let us verify that docker is installed and we can call the Docker CLI:
~~~bash
docker version
~~~

The results should show the Client and Server docker versions.

___

### Let the Instructor know

When you have completed the installation and displayed the Docker version.  Share with the Instructor the "Client" and "Engine"
version of Docker.

___

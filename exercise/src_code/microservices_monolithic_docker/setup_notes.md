## Run Monolithic Dockerized Application in Java in Ubuntu machine

## * Setting up the machine

```bash
ssh username@FQDN
```

#### apt-get update and install java, git, maven
```bash
sudo apt-get -y update
sudo apt-get -y install default-jdk git maven redis-tools
```

### Please note that docker installation is needed only if your machine doesn't have docker
#### install docker

```bash
curl -sSL https://get.docker.com/ | sh
```

##### add sudo access to the user

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
#exit and login again
```

### Please note that docker-compose installation is needed only if your machine doesn't have docker-compose
#### install docker-compose

```bash
sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

##### check docker and docker-compose
```bash
docker version
docker-compose version
```

## * Clone the git project

```bash
git clone https://github.com/shekhar2010us/microservices_monolithic_docker.git
cd microservices_monolithic_docker/
```

#### build the maven project locally

```bash
cd restful-test/
mvn clean install -U
cd ..
```

#### build the Docker image for the maven project and redis data upload

```bash
docker build -f Dockerfile.dataloader -t java_mvn_redis_loader:1.0 .
```

#### run the docker-compose
```bash
docker-compose up -d
```

#### check running docker containers
```bash
docker ps
```

Wait until "redis_loader" container gets killed. <br>
This container is responsible for loading static data to redis datastore.

<br>

## * Test the application

#### Run below http either in browser or using curl (note: change the IP of your machine)
* http://IP:8080/sample-monolithic-1.0/rest/retailDesign/getallstocks
* http://IP:8080/sample-monolithic-1.0/rest/retailDesign/getallproducts
* http://IP:8080/sample-monolithic-1.0/rest/retailDesign/getstock?productId=1
* http://IP:8080/sample-monolithic-1.0/rest/retailDesign/getstock?productId=3
* http://IP:8080/sample-monolithic-1.0/rest/retailDesign/getproduct?id=2
* http://IP:8080/sample-monolithic-1.0/rest/retailDesign/getproduct?id=5

* http://IP:8080/sample-monolithic-1.0/rest/retailDesign/combinedproduct?productId=1&id=1
* http://IP:8080/sample-monolithic-1.0/rest/retailDesign/combinedproduct?productId=1&id=2


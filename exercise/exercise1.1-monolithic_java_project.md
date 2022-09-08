## Run Monolithic Dockerized Application in Java in Ubuntu machine

## Setting up the machine

```bash
ssh ubuntu@FQDN
```

#### apt-get update and install java, git, maven
```bash
sudo apt-get -y update
sudo apt-get -y install default-jdk git maven redis-tools
```

#### Install Docker version 19.03

Install docker with the get.docker.com script.

```bash
curl -sSL https://get.docker.com | sudo VERSION=19.03 sh
```

Add your user to the docker group to allow docker commands to run without 'sudo'.

```bash
sudo usermod -aG docker $USER
```

Now logout and restart your shell so the group change can take effect.

```bash
exit
```

Restart your shell

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

## Clone the git project

```bash
cd ~/
git clone https://github.com/techtown-training/microservices-bootcamp.git
cd microservices-bootcamp/exercise/src_code/microservices_monolithic_docker/
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

## Test the application

#### Run below http either in browser or using curl (note: change the IP of your machine)
* http://{IP}:8080/sample-monolithic-1.0/rest/retailDesign/getallstocks
* http://{IP}:8080/sample-monolithic-1.0/rest/retailDesign/getallproducts
* http://{IP}:8080/sample-monolithic-1.0/rest/retailDesign/getstock?productId=1
* http://{IP}:8080/sample-monolithic-1.0/rest/retailDesign/getstock?productId=3
* http://{IP}:8080/sample-monolithic-1.0/rest/retailDesign/getproduct?id=2
* http://{IP}:8080/sample-monolithic-1.0/rest/retailDesign/getproduct?id=5

* http://{IP}:8080/sample-monolithic-1.0/rest/retailDesign/combinedproduct?productId=1&id=1
* http://{IP}:8080/sample-monolithic-1.0/rest/retailDesign/combinedproduct?productId=1&id=2

<br>

#### Example using the curl command

```bash
sudo apt install -y jq
curl http://127.0.0.1:8080/sample-monolithic-1.0/rest/retailDesign/getallstocks | jq
curl http://127.0.0.1:8080/sample-monolithic-1.0/rest/retailDesign/getallproducts | jq
curl http://127.0.0.1:8080/sample-monolithic-1.0/rest/retailDesign/getstock?productId=1 | jq
curl http://127.0.0.1:8080/sample-monolithic-1.0/rest/retailDesign/getstock?productId=3 | jq
curl http://127.0.0.1:8080/sample-monolithic-1.0/rest/retailDesign/getproduct?id=2 | jq
curl http://127.0.0.1:8080/sample-monolithic-1.0/rest/retailDesign/getproduct?id=5 | jq
curl http://127.0.0.1:8080/sample-monolithic-1.0/rest/retailDesign/combinedproduct?productId=1&id=1 | jq
curl http://127.0.0.1:8080/sample-monolithic-1.0/rest/retailDesign/getproduct?id=5 | jq
```

## Source code - For reference only

<b>Docker file</b> for data loading to Redis

```
# docker build -f Dockerfile.dataloader -t java_mvn_redis_loader:1.0 .
FROM maven:3.5

RUN apt-get update
RUN mkdir /code
ADD . /code
WORKDIR /code/restful-test

CMD ["mvn", "clean", "install", "-U"]
```

<b> docker compose file </b> to start the app with 3 containers

```
version: "3"
services:
  retail_app:
    image: tomcat:7.0.108-jdk8
    depends_on:
      - "redis_loader"
    volumes:
     - ./restful-test/target/sample-monolithic-1.0.war:/usr/local/tomcat/webapps/sample-monolithic-1.0.war
    ports:
     - "8080:8080"

  redis_loader:
    image: java_mvn_redis_loader:1.0
    container_name: redis_loader
    command: mvn exec:java -Dexec.mainClass="com.app.startup.DataLoader"
    depends_on:
      - "redis"

  redis:
    image: "redis:alpine"
    container_name: redis
    ports:
     - "6379:6379"
#docker run -it -p 8080:8080 -v ~/restful-test/target/sample-monolithic-1.0.war:/usr/local/tomcat/webapps/sample-monolithic-1.0.war tomcat:7.0.108-jdk8
```

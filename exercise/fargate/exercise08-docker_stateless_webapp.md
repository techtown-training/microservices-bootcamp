# Exercise 08: Docker Stateless WebApp


cd ~/microservices-bootcamp/exercise/fargate/source/08/stateless/

docker build -t stateless:v1 .

docker run -d -p80:80 --name stateless -e "APP_NAME=Stateless.v1" stateless:v1

curl http://ifconfig.co

docker container stop stateless

docker container rm stateless

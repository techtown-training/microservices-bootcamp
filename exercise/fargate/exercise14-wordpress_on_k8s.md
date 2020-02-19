# Exercise 14: Wordpress on Kubernetes

## This exercise needs finalize it will be finish shortly

~~~bash
cd ~/microservices-bootcamp/exercise/fargate/source/14/wordpress/
~~~

~~~bash
microk8s.kubectl apply -f wordpress-deployment
~~~

~~~bash
echo $AWS_EIP
~~~

curl https://<AWS_EIP>/

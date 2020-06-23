# Microservices: AWS: K8s
# Sock Shop

### Objective

Deploy Sock Shop Microservices Application on Kubernetes.

### Parts


This lab currently takes to many resources on a single node K8s cluster with 2G of memory.


~~~shell
cd ~/
~~~

~~~shell
git clone https://github.com/microservices-demo/microservices-demo.git
~~~

~~~shell
cd microservices-demo/deploy/kubernetes/
~~~

~~~shell
sed -ie "s/extensions\/apps\/v1beta1/v1/g" complete-demo.yaml
~~~

~~~shell
microk8s.kubectl create namespace sock-shop
~~~



~~~shell
microk8s.kubectl apply -f complete-demo.yaml
~~~

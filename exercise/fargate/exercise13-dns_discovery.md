# Exercise 13: DNS Discovery

Microk8s

~~~bash
sudo snap install microk8s --classic
~~~

~~~bash
sudo microk8s.status --wait-ready
~~~

~~~bash
sudo microk8s.enable dns storage ingress
~~~

~~~bash
sudo usermod -a -G microk8s $USER
~~~

~~~bash
microk8s.kubectl get nodes
~~~

~~~bash
microk8s.kubectl get services
~~~


~~~bash
alias kubectl='microk8s.kubectl'
echo "alias kubectl='microk8s.kubectl'" >> ~/.bashrc
~~~


~~~bash
microk8s.kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
~~~

~~~bash
watch microk8s.kubectl get pods
~~~

~~~bash
microk8s.kubectl get deploy,svc
microk8s.kubectl get ingress,pods
~~~

~~~bash
microk8s.kubectl delete deployment kubernetes-bootcamp
~~~

~~~bash
docker run -d -p 5000:5000 --name registry registry
~~~

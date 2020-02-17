# Exercise 07: Docker WebApp

~~~bash
docker run -d --name webApp -p80:80 nginx:1.17
~~~

~~~bash
curl ifconfig.co
~~~

~~~bash
docker logs -f webApp
~~~

http://<External IP>

ctl-c

~~~bash
docker image ls
~~~

~~~bash
docker container ls
~~~

~~~bash
docker container stop webApp
~~~

~~~bash
docker container rm webApp
~~~

~~~bash
docker image rm nginx:1.7
~~~

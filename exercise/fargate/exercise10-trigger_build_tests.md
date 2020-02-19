# Exercise 10: Trigger Build Tests

sudo apt install -y default-jre


sudo apt -y install vim apt-transport-https dirmngr wget software-properties-common
sudo add-apt-repository -y ppa:cwchien/gradle

sudo apt-get update
sudo apt -y install gradle

gradle wrapper clean integrationTest

~~~
BUILD SUCCESSFUL in 28s
6 actionable tasks: 5 executed, 1 up-to-date
~~~

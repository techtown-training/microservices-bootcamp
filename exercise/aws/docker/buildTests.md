# Microservices: AWS: Docker
# Build Tests

### Objective

Run inline tests using Gradle on Docker.

### Parts



## Trigger Build Tests

In this exercise we will demonstrate one of many ways to run unit tests our code that is being developed.  Many CI/CD models have pipelining environments setup.  There are many choices for those environments. Setting up one is beyond the scope of this class.  But we still can see unit tests in action by utilizing a tool like Gradle to build and run unit tests without a full-blown pipeline orchestrator on our local development machine, our Linux instance in this case.

In this exercise we will run a simple integration test that verifies the CRUD functionality of a service using DynamoDB. As I mentioned before in addition to Docker and docker-compose we will be using Gradle to actually run the tests.

For this exercise the we will need to install a few tools.  First Gradle is for Java and Groovy projects so we will need a JRE installed:

~~~shell
sudo apt install -y default-jre
~~~

Unfortunately the version of Gradle packaged for Ubuntu 18.04 is to old to recognize the current versions of OpenJDK, which we just installed.  So we will be utilizing a PPA to install a newer version of Gradle than the Ubuntu packaged version.  First we need to install the dependancies for setting up a PPA repository:

~~~shell
sudo apt -y install vim apt-transport-https dirmngr wget software-properties-common
~~~

Now we can use "add-apt-repository" to add the PPA we will be using for Gradle:

~~~shell
sudo add-apt-repository -y ppa:cwchien/gradle
~~~

Since we have added a new apt repository for our system.  The first think we need to do is update the local package lists:

~~~shell
sudo apt update
~~~

Now let's install gradle on the Linux instance:

~~~shell
sudo apt -y install gradle
~~~

Verify that gradle both runs and the version is at least version 6:

~~~shell
gradle --version
~~~

The dependancies for this exercise are now satisfied.  Let's change to the source file directory for this exercise:

~~~shell
cd ~/microservices-bootcamp/exercise/aws/source/docker/buildtests/
~~~

The first file to check out is the "build.gradle" file. This is where the local unit tests are defined. In this file you will notice that we add the binary repository for the docker-compose-rule. We will be using docker-compose within the tests. After that notice there is a set of testCompiles that will be compiled as dependancies.

The next thing to look at is the docker-compose file that will be used.  That file can be found in the 'src/test/resources/docker-compose-dynomodb.yml'  This docker-compose file makes dynomodb avalible as a resource for each unit test.

The actual tests can be found in the 'src/test/java/com.tomasulo.sample/infrastructure/UserRepositoryIntegrationTest.java' file.  There is quite a bit more to which is going on, but let's actually run the unit tests.  To do that we will use this command:

~~~shell
gradle wrapper clean integrationTest
~~~

When the test finish look for the "BUILD SUCCESSFUL" message in addition to a summary of the "actionable tasks" that where run.

### Let the Instructor know

Send a screenshot of the "BUILD SUCCESSFUL" message to the instructor to indicate that you have completed the exercise.

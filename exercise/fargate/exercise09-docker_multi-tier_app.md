Exercise 09: Docker Multi-tier App


sudo curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

sudo curl -L https://raw.githubusercontent.com/docker/compose/1.25.3/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose

docker-compose --version


cd ~/microservices-bootcamp/exercise/fargate/source/09/taiga/

sed -ie "s/localhost/${AWS_EIP}/g" docker-compose.yml

docker-compose up

admin / 123123

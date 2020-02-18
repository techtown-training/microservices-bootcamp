# Exercise 11: Push Image to Registry

ECR & Docker Hub

aws ecr get-login  | sed 's/-e none //g' > ~/docker.login

bash ~/docker.login

aws ecr create-repository --repository-name ${LAB_NUMBER}-repo/nginx

aws ecr describe-repositories

docker pull nginx:1.17

docker tag nginx:1.17 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/nginx:1.17

docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/nginx:1.17

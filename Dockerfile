ARG BUILD_ID
ARG PROJECT_NAME=alpha-jenkins-svc
ARG AWS_REGION
ARG AWS_DEFAULT_REGION

FROM alphaprosoft/ansible-img:latest

ENV BUILD_ID ${BUILD_ID}



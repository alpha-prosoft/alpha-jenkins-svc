ARG BUILD_ID
ARG PROJECT_NAME=alpha-jenkins-svc

FROM alphaprosoft/ansible-img:latest

ENV BUILD_ID ${BUILD_ID}



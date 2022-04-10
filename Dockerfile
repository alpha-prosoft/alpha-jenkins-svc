ARG BUILD_ID
ARG PROJECT_NAME=alpha-jenkins-svc

FROM alphaprosoft/ansible-img:b298

ENV BUILD_ID ${BUILD_ID}



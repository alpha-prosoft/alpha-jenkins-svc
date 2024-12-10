# VPC First steps

- Create Internet Gateway and attach to VPC
- Dont forget to setup RouteTables


## Build and run 

Replace "alpha" with your own project name and "PIPELINE" with your preffered environment name

```
./build-and-deploy.sh "alpha"

```

## Secrets

Setup assumes follwing secrets in AWS secret manager


#Credentials for jira
```
/pipeline/jenkins/jira-http

{
  "username": "***",
  "password": "***",
  "url": "https://***"
}
```

#Credentials for github 
```
/pipeline/jenkins/github-http

{
  "username": "***",
  "password": "***",
  "url": "https://***"
}
```


#Credentialsto deploy artifacts
```
/pipeline/jenkins/artifact-deploy-http

{
  "username": "***",
  "password": "***",
  "url": "https://***",
  "org": "com.example"
}

```

#Credentals to deploy non productive builds of artifacts (i.e. Pull request builds)
```
/pipeline/jenkins/artifact-deploy-dev-http
{
  "username": "***",
  "password": "***",
  "url": "https://***",
  "org": "com.example"
}
```

#Credentals to deploy public releases
```
/pipeline/jenkins/artifact-deploy-public-http
{
  "username": "***",
  "password": "***",
  "url": "https://***",
  "org": "com.example"
}
```


#Docker setup. `url` and `push-url` can be same value. 
```
/pipeline/jenkins/docker-http
{
  "username": "***",
  "password": "***",
  "url": "***",
  "push-url": "***",
  "org": "***"
}
```

#Initial instance setup
```
sudo apt-get update
sudo apt-get install -y docker.io awscli jq
sudo echo "{ "features": { "buildkit": true } }" > /etc/docker/daemon.json
sudo systemctl restart docker
```

# Build and deploy
```
./local-deploy.sh
```

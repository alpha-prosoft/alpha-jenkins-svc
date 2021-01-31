# VPC First steps

- Create Internet Gateway and attach to VPC
- Dont forget to setup RouteTables


## Secrets

Setup assumes follwing secrets in AWS secret manager


Credentials fot jira
```
/pipeline/jenkins/jira-http

{
  "username": "***",
  "password": "***",
  "url": "https://***"
}
```


Credentialsto deploy artifacts
```
/pipeline/jenkins/artifact-deploy-http

{
  "username": "***",
  "password": "***",
  "url": "https://***"
}

```

Credentals to deploy non productive builds of artifacts (i.e. Pull request builds)
```
/pipeline/jenkins/artifact-deploy-dev-http
{
  "username": "***",
  "password": "***",
  "url": "https://***"
}
```


Docker setup. `url` and `push-url` can be same value. 
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

Initial instance setup
```
sudo apt-get update
sudo apt-get install docker.io
sudo echo "{ "features": { "buildkit": true } }" > /etc/docker/daemon.json
sudo systemctl restart docker
```

# VPC First steps

- Create Internet Gateway and attach to VPC
- Dont forget to setup RouteTables


## Build and run 

Replace "alpha" with your own project name and "PIPELINE" with your preffered environment name

```
./build-and-deploy.sh "alpha"

```

## Secrets

Setup assumes secret in AWS secret manager under `/${EnvironmentNameLower}/jenkins/config`

Configuration structure:
```json
{
  "services": {
    "jira": {
      "username": "***",
      "password": "***",
      "url": "PREFIX1:https://yourorg1.atlassian.net,PREFIX2:https://yourorg2.atlassian.net"
    },
    "github": {
      "username": "***",
      "password": "***"
    },
    "artifactDeployHttp": {
      "username": "***",
      "password": "***",
      "url": "https://pkgs.dev.azure.com/your-org/prod/_packaging/prod/maven/v1",
      "org": "com.example"
    },
    "artifactDeployDevHttp": {
      "username": "***",
      "password": "***",
      "url": "https://pkgs.dev.azure.com/your-org/dev/_packaging/dev/maven/v1",
      "org": "com.example"
    },
    "artifactDeployPublicHttp": {
      "username": "***",
      "password": "***",
      "url": "https://clojars.org/repo",
      "org": "com.example"
    },
    "dockerHttp": {
      "username": "***",
      "password": "***",
      "url": "docker.io",
      "pushUrl": "docker.io",
      "org": "***"
    },
    "dockerDevHttp": {
      "username": "***",
      "password": "***",
      "org": "***"
    },
    "dockerPublicHttp": {
      "username": "***",
      "password": "***"
    }
  },
  "environment": {
    "PrivateHostedZoneName": "pipeline.example.com",
    "AccountId": "123456789012",
    "EnvironmentNameLower": "pipeline",
    "EnvironmentNameUpper": "PIPELINE",
    "Region": "eu-west-1",
    "AmiId": "ami-xxxxxxxxxxxxxxxxx",
    "InstanceProfileArn": "arn:aws:iam::123456789012:instance-profile/PIPELINE-service-name-InstanceProfile",
    "InstanceSecurityGroupId": "sg-xxxxxxxxxxxxxxxxx",
    "PrivateSubnet1A": "subnet-xxxxxxxxxxxxxxxxx",
    "PrivateSubnet2A": "subnet-xxxxxxxxxxxxxxxxx",
    "ServiceName": "service-name",
    "ServiceAlias": "jenkins",
    "Username": "jenkins"
  }
}
```


#Initial instance setup
```
sudo apt-get update
sudo apt-get install -y docker.io awscli jq
sudo echo "{ "features": { "buildkit": true } }" > /etc/docker/daemon.json
sudo systemctl restart docker
```


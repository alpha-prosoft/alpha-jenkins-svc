# VPC First steps

- Create Internet Gateway and attach to VPC
- Dont forget to setup RouteTables


## Build and run 

Replace "alpha" with your own project name and "PIPELINE" with your preffered environment name

```
./build-and-deploy.sh "alpha"

```

## Secrets

Setup assumes secret in AWS secret manager under `/${EnvironmentNameLower}/jenkins/config


#Credentials for jira
```json
{
	"credentials": {
		"jira": {
			"username": "***",
			"password": "***",
			"url": "https://***"
		},
		"github": {
			"username": "***",
			"password": "***",
			"url": "https://***"
		},
		"artifact-deploy-http": {
			"username": "***",
			"password": "***",
			"url": "https://***",
			"org": "com.example"
		},
		"artifact-deploy-dev-http": {
			"username": "***",
			"password": "***",
			"url": "https://***",
			"org": "com.example"
		},
		"artifact-deploy-public-http": {
			"username": "***",
			"password": "***",
			"url": "https://***",
			"org": "com.example"
		},
		"docker-http": {
			"username": "***",
			"password": "***",
			"url": "***",
			"push-url": "***",
			"org": "***"
		}
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


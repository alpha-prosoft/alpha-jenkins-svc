# VPC First steps

- Create Internet Gateway and attach to VPC
- Dont forget to setup RouteTables


## Build and run 

Replace "alpha" with your own project name and "PIPELINE" with your preffered environment name

```
./build-and-deploy.sh "alpha"

```

## Configuration

All configuration lives in a single **SSM Parameter Store** parameter at
`/${EnvironmentNameLower}/jenkins/config` (type `SecureString`). It is read once on
boot by `init-userdata.sh` and rendered into the Jenkins CasC config.

Two sections:

- `env` — Jenkins global environment variables. Add a key here and it appears on the
  controller automatically; no code change needed. Values may reference
  `<< services.* >>` and `<< environment.* >>` (the latter comes from the instance's
  `/etc/environment.json`, populated from CloudFormation outputs). The `<< >>`
  delimiters are used instead of `{{ }}` because Parameter Store reserves `{{ }}` for
  its own parameter references and rejects values that contain it.
- `services` — credentials and service URLs wired into Jenkins credentials.

Configuration structure:
```json
{
  "env": {
    "GLOBAL_PROPERTIES_DOCKER_BUILD_ARGS": "--build-arg DOCKER_URL=<< services.dockerHttp.url >> --build-arg DOCKER_PUSH_URL=<< services.dockerHttp.pushUrl >> --build-arg DOCKER_ORG=<< services.dockerHttp.org >> --build-arg BUILD_ID=${BUILD_ID} --progress plain --build-arg ARTIFACT_ORG=<< services.artifactDeployHttp.org >>",
    "DOCKER_ORG": "<< services.dockerHttp.org >>",
    "DOCKER_DEV_ORG": "<< services.dockerDevHttp.org >>",
    "DOCKER_PUSH_URL": "<< services.dockerHttp.pushUrl >>",
    "DOCKER_URL": "<< services.dockerHttp.url >>",
    "GERRIT_EMAIL": "jenkins@alpha-prosoft.com",
    "GERRIT_URL": "gerrit.<< environment.PrivateHostedZoneName >>",
    "GERRIT_USER": "jenkins",
    "GLOBAL_JIRA_URL": "<< services.jira.url >>",
    "GLOBAL_REPOSITORY_DEV_URL": "<< services.artifactDeployDevHttp.url >>",
    "GLOBAL_REPOSITORY_PROD_URL": "<< services.artifactDeployHttp.url >>",
    "GLOBAL_REPOSITORY_PUBLIC_URL": "<< services.artifactDeployPublicHttp.url >>",
    "ARTIFACT_ORG": "<< services.artifactDeployHttp.org >>",
    "ARTIFACT_DEV_ORG": "<< services.artifactDeployDevHttp.org >>",
    "ARTIFACT_PUBLIC_ORG": "<< services.artifactDeployPublicHttp.org >>",
    "GLOBAL_GROUP_ID": "<< services.artifactDeployHttp.org >>",
    "CONFIG_FILE_URL": "s3://<< environment.AccountId >>-<< environment.EnvironmentNameLower >>-configuration/accounts.json",
    "AWS_REGION": "<< environment.Region >>",
    "AWS_DEFAULT_REGION": "<< environment.Region >>"
  },
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
  }
}
```

The `environment` values referenced above (`PrivateHostedZoneName`, `AccountId`,
`EnvironmentNameLower`, `EnvironmentNameUpper`, `Region`, `AmiId`,
`InstanceProfileArn`, `InstanceSecurityGroupId`, `PrivateSubnet1A`,
`PrivateSubnet2A`, `ServiceName`, `ServiceAlias`, `Username`) are not stored in this
parameter — they are provided per-instance via `/etc/environment.json` from
CloudFormation outputs.

The Jenkins login password is read from a second SecureString parameter at
`/${EnvironmentNameLower}/jenkins/password`.

### Migrating from Secrets Manager

Configuration previously lived in AWS Secrets Manager. To migrate an environment to
Parameter Store, run a dry run first and then apply:
```
./migrate-secrets-to-ssm.sh pipeline          # dry run, prints planned changes
./migrate-secrets-to-ssm.sh pipeline --apply   # writes the SSM parameters
```
This copies `services` from the old `/${env}/jenkins/config` secret, injects the
default `env` block above, and migrates `/${env}/jenkins/password` verbatim. The
instance role needs `ssm:GetParameter` and `kms:Decrypt` on these paths.


#Initial instance setup
```
sudo apt-get update
sudo apt-get install -y docker.io awscli jq
sudo echo "{ "features": { "buildkit": true } }" > /etc/docker/daemon.json
sudo systemctl restart docker
```


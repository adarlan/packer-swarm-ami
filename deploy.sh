#!/bin/bash
set -e

echo -e "\n$(date)"

echo "SSMParameterName: $SSMParameterName"
SSMParameterValue=$(aws ssm get-parameter --with-decryption --name $SSMParameterName --query "Parameter.Value" | jq --monochrome-output fromjson)
echo "SSMParameterValue: $SSMParameterValue"

GitPlatform=$(echo $SSMParameterValue | jq -r '.git_platform')
GitUrl=$(echo $SSMParameterValue | jq -r '.git_url')
GitRef=$(echo $SSMParameterValue | jq -r '.git_ref')
echo "GitPlatform: $GitPlatform"
echo "GitUrl: $GitUrl"
echo "GitRef: $GitRef"

docker info | grep "Swarm: active" && SwarmActive=true || SwarmActive=false
if [ $SwarmActive = true ]; then
    echo "SwarmActive: true"
else
    echo "SwarmActive: false"
    docker swarm init
fi

cd ~
RepoUpdated=false
if [ ! -d swarm-deployment ]; then
    git clone $GitUrl swarm-deployment
    cd swarm-deployment
    git checkout $GitRef
    RepoUpdated=true
else
    cd swarm-deployment
    git fetch --all --tags
    git checkout $GitRef
    if [ ! $(git rev-list HEAD..origin/$GitRef --count) -eq 0 ]; then
        git pull
        RepoUpdated=true
    fi
fi
if [ $RepoUpdated = true ]; then
    DeployFile=swarm-compose.yaml
    StackName=main
    docker stack deploy --prune --compose-file $DeployFile $StackName
    docker system prune --all --force
fi

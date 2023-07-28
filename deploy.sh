#!/bin/bash
set -e

echo -e "\n$(date)"

ParameterName=swarm_deployment_config
ParameterValue=$(aws ssm get-parameter --name $ParameterName --query "Parameter.Value" | jq --monochrome-output fromjson)

GitUrl=$(echo $ParameterValue | jq -r '.GitUrl')
GitBranch=$(echo $ParameterValue | jq -r '.GitBranch')
DeployFile=$(echo $ParameterValue | jq -r '.DeployFile')
StackName=$(echo $ParameterValue | jq -r '.StackName')

SwarmActive=$(docker info | grep "Swarm: active") || SwarmInit=$(docker swarm init)

cd ~
RepoUpdated=false
if [ ! -d swarm-deployment ]; then
    git clone $GitUrl swarm-deployment
    cd swarm-deployment
    git checkout $GitBranch
    RepoUpdated=true
else
    cd swarm-deployment
    git checkout $GitBranch
    git fetch
    if [ ! $(git rev-list HEAD..origin/$GitBranch --count) -eq 0 ]; then
        git pull
        RepoUpdated=true
    fi
fi
if [ $RepoUpdated = true ]; then
    docker stack deploy --prune --compose-file $DeployFile $StackName
    docker system prune --all --force
fi

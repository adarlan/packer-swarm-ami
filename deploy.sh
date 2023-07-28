#!/bin/bash
set -e

ParameterName=swarm_deployment_config
ParameterValue=$(aws ssm get-parameter --name $ParameterName --query "Parameter.Value" | jq --monochrome-output fromjson)

GitUrl=$(echo $ParameterValue | jq '.GitUrl')
GitBranch=$(echo $ParameterValue | jq '.GitBranch')
DeployFile=$(echo $ParameterValue | jq '.DeployFile')
StackName=$(echo $ParameterValue | jq '.StackName')

SwarmActive=$(docker info | grep "Swarm: active") || SwarmInit=$(docker swarm init)

echo -e "\n$(date)"
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

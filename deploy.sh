#!/bin/bash
set -e

GitUrl="https://github.com/adarlan/traefik-swarm-deployment.git"
GitBranch="main"
DeployFile="swarm-compose.yaml"
StackName="default"

SwarmActive=$(docker info | grep "Swarm: active") || SwarmInit=$(docker swarm init)

echo -e "\n$(date)"
cd ~
Updated=0
if [ ! -d swarm-deployment ]; then
    git clone $GitUrl swarm-deployment
    cd swarm-deployment
    git checkout $GitBranch
    Updated=1
else
    cd swarm-deployment
    git checkout $GitBranch
    git fetch
    if [ ! $(git rev-list HEAD..origin/$GitBranch --count) -eq 0 ]; then
        git pull
        Updated=1
    fi
fi
if [ $Updated -eq 1 ]; then
    docker stack deploy --prune --compose-file $DeployFile $StackName
    docker system prune --all --force
fi

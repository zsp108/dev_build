#!/bin/bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${SCRIPT_ROOT}/scripts/utils.sh"

# Stop and remove Docker containers and images
docker stop $(docker ps -a -q)

systemctl stop docker && systemctl disable docker
if [ $? -ne 0 ]; then
    log error "Failed to stop Docker"
fi

for t in {containerd,containerd-shim,ctr,docker,dockerd,runc,docker-init,docker-proxy}; do
    if [ -f /usr/bin/$t ]; then
        rm /usr/bin/$t
        if [ $? -ne 0 ]; then
            log error "Failed to remove $t"
        fi
    else
        log error "$t not found"
    fi
done


mv /usr/lib/systemd/system/docker.service /usr/lib/systemd/system/docker.service.bak

systemctl daemon-reload
if [ $? -ne 0 ]; then
    log error "Failed to reload systemctl"
fi

log info "Docker uninstalled successfully"

#!/bin/bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${SCRIPT_ROOT}/scripts/utils.sh"


if command -v docker &> /dev/null; then
    log warn "Docker 已安装，脚本退出。"
    exit 0
else
    log info "Docker 未安装，执行后续操作。"
fi

read -p "请输入Docker 安装路径：" docker_dir

log info "正在安装 Docker..."
log info "安装路径：${docker_dir}"

mkdir -p "${docker_dir}"
if [ $? -ne 0 ]; then  
    log error "创建目录失败！"
fi

cd ../packages
tar xvpf docker-18.09.9.tgz >/dev/null
cp -p docker/* /usr/bin/ >/dev/null
rm -rf docker/


cat >/usr/lib/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.com
After=network.target docker.socket

[Service]
Type=notify
EnvironmentFile=-/etc/sysconfig/docker
WorkingDirectory=/usr/local/bin/
ExecStart=/usr/bin/dockerd \\
                --bip=172.17.0.1/16 \\
                \$DOCKER_OPT_MTU \\
                -H unix:///var/run/docker.sock \\
                --selinux-enabled=false \\
                --log-opt max-size=1g \\
                --data-root=${docker_dir} \\
                --live-restore
ExecReload=/bin/kill -s HUP \$MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF


sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://docker.211678.top","https://docker.1panel.live","https://hub.rat.dev","https://docker.m.daocloud.io","https://do.nark.eu.org","https://dockerpull.com","https://dockerproxy.cn","https://docker.awsl9527.cn","https://docker.m.daocloud.io","https://p5lmkba8.mirror.aliyuncs.com","https://registry.docker-cn.com"]
}

EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
systemctl status docker

if [ $? -eq 0 ]; then
    log info "Docker 安装成功！"
else
    log error "Docker 安装失败！"
fi
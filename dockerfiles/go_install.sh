#!/bin/bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd -P)"

logfile=$SCRIPT_ROOT/logs/qinit.log
# 日志函数，记录操作系统，并且将输出打印到屏幕
function log {
    local msg
    local logtype
    logtype=$1
    msg=$2
    datetime=`date +'%F %H:%M:%S'`
    logformat="${datetime} ${FUNCNAME[@]/log/} [line:`caller 0 | awk '{print$1}'`] ${logtype}:${msg}"
    {
    case $logtype in
        debug)
            echo "${logformat}" &>> $logfile;;
        info)
            echo -e "\033[32m $datetime [info] ${msg} \t \033[0m"
            echo "${logformat}" &>> $logfile;;
        warn)
            echo -e "\033[33m $datetime [WARN] ${msg} \t \033[0m"
            echo "${logformat}" &>> $logfile;;
        error)
            echo -e "\033[31m $datetime [ERROR] ${msg} \033[0m"
            echo "${logformat}" &>> $logfile
            exit 15;;
    esac
    }
}


# 根据架构和系统版本下载对应的 Git 安装包
if [[ "$OS" == "centos" || "$OS" == "rhel" ]]; then
    if [[ "$ARCH" == "x86_64" ]]; then
        log info "正在为 CentOS/RedHat $VERSION x86_64 下载 Git..."
        cd /tmp/ && curl -O https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.42.0.tar.gz
    elif [[ "$ARCH" == "aarch64" ]]; then
        log info "正在为 CentOS/RedHat $VERSION ARM64 下载 Git..."
        cd /tmp/ && curl -O https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.42.0.tar.gz
    else
        log error "暂不支持的架构: $ARCH"
    fi
elif [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    if [[ "$ARCH" == "x86_64" ]]; then
        log info "正在为 Ubuntu/Debian $VERSION x86_64 下载 Git..."
        cd /tmp/ && curl -O https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.42.0.tar.gz
    elif [[ "$ARCH" == "aarch64" ]]; then
        log info "正在为 Ubuntu/Debian $VERSION ARM64 下载 Git..."
        cd /tmp/ && curl -O https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.42.0.tar.gz
    else
        log error "暂不支持的架构: $ARCH"
    fi
else
    echo "暂不支持的操作系统: $OS"
    exit 1
fi
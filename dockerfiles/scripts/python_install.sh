#!/bin/bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd -P)"

logfile=$SCRIPT_ROOT/init.log
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

# 获取 CPU 架构
ARCH=$(uname -m)

# 获取系统版本信息（支持 CentOS/RedHat 或 Ubuntu/Debian）
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    log error "无法确定操作系统类型。"
    exit 1
fi

# 打印系统信息
log info "检测到系统架构: $ARCH"
log info "检测到操作系统: $OS $VERSION"

python_version=3.9.0

if [ `command -v python` ];then
    cur_pyversion=`python --version 2>&1 | awk '{print $2}'`
    log info "当前python版本为$cur_pyversion"

    if [ $python_version == $cur_pyversion ];then
        log info "已安装的版本和将要安装的版本相同,不进行安装"
        return
    # else
    #     log error "该环境已安装的Python版本和将要安装的版本不同，请清理旧版本Python后重试本脚本，旧版本位置：`command -v python`"
    fi
fi

# 安装依赖包
case $OS in
    'centos'|'redhat')
        yum install -y gcc gcc-c++ zlib zlib-devel readline-devel openssl-devel
        ;;
    'debian'|'ubuntu')
        apt install -y gcc g++ zlib1g zlib1g-dev
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac


# 根据架构和系统版本下载对应的 python 安装包
log info "正在为 $VERSION x86_64 下载 golang... ttps://www.python.org/ftp/python/$python_version/Python-$python_version.tgz"
if [ -f /tmp/Python-$python_version.tgz ]; then
    log info "已存在 Python 安装包，跳过下载"
else
    cd /tmp/ && wget https://www.python.org/ftp/python/$python_version/Python-$python_version.tgz
    if [ $? -ne 0 ]; then
        log error "下载 Python 安装包失败，请检查网络或重新运行脚本"
    fi
fi

# if [ -d $HOME/go ];then
#     log warn "检测到 $HOME/go 目录存在，请确认是否需要清理"
# else
#     mkdir -p $HOME/go
# fi
tar -xvf /tmp/Python-$python_version.tgz -C /usr/local/
mv /usr/local/Python-$python_version /usr/local/python$python_version
cd /usr/local/python$python_version && ./configure --prefix=/usr/local/python$python_version && make && make install


# 配置环境变量
echo "export PATH=\$PATH:/usr/local/python$python_version">>/etc/profile
source /etc/profile


# if [ `grep -c "# Go envs" $HOME/.bashrc` -ne 0 ];then
#         log warn """$HOME/.bashrc has git config, please check it 

# # Go envs
# export GOVERSION=go$go_version # Go 版本设置
# export GO_INSTALL_DIR=\$HOME/go # Go 安装目录
# export GOROOT=\$GO_INSTALL_DIR/\$GOVERSION # GOROOT 设置
# export GOPATH=\$WORKSPACE/golang # GOPATH 设置
# export PATH=\$GOROOT/bin:\$GOPATH/bin:\$PATH # 将 Go 语言自带的和通过 go install 安装的二进制文件加入到 PATH 路径中
# export GO111MODULE="on" # 开启 Go moudles 特性
# #export GOPROXY=https://goproxy.cn,direct # 安装 Go 模块时，代理服务器设置
# export GOPRIVATE=
# export GOSUMDB=off # 关闭校验 Go 依赖包的哈希值

# """
# else
#     cat << EOF >> $HOME/.bashrc
# export WORKSPACE="$HOME/workspace" # 设置工作目录

# #创建工作路径
# if [ ! -d $HOME/workspace ];then
#     mkdir -p $HOME/workspace 
# fi

# # Default entry folder
# cd $WORKSPACE # 登录系统，默认进入 workspace 目录

# alias ws="cd $WORKSPACE"

# # Go envs
# export GOVERSION=go$go_version # Go 版本设置
# export GO_INSTALL_DIR=\$HOME/go # Go 安装目录
# export GOROOT=\$GO_INSTALL_DIR/\$GOVERSION # GOROOT 设置
# export GOPATH=\$WORKSPACE/golang # GOPATH 设置
# export PATH=\$GOROOT/bin:\$GOPATH/bin:\$PATH # 将 Go 语言自带的和通过 go install 安装的二进制文件加入到 PATH 路径中
# export GO111MODULE="on" # 开启 Go moudles 特性
# #export GOPROXY=https://goproxy.cn,direct # 安装 Go 模块时，代理服务器设置
# export GOPRIVATE=
# export GOSUMDB=off # 关闭校验 Go 依赖包的哈希值
# EOF
# fi

# source $HOME/.bashrc && go version > /dev/null | mkdir -p $GOPATH && cd $GOPATH && go work init && log info "Install Golang successfully" || log error "Golang version is not '$go_version',maynot install Golang properly"
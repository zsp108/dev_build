#!/bin/bash

# backup original.bashrc
cp $HOME/.bashrc $HOME/.bashrc_`date +%Y%m%d%H%M%S`

# add user specific aliases and functions
cat << 'EOF' >> $HOME/.bashrc
# User specific aliases and functions
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
# Basic envs
export LANG="en_US.UTF-8" # 设置系统语言为 en_US.UTF-8，避免终端出现中文乱码
export PS1='[\u@elk-dev \W]\$ ' # 默认的 PS1 设置会展示全部的路径，为了防止过长，这里只展示："用户名@elk-dev 最后的目录名"
export WORKSPACE="$HOME/workspace" # 设置工作目录
export PATH=$HOME/bin:$PATH # 将 $HOME/bin 目录加入到 PATH 变量中

#创建工作路径
if [ ! -d $HOME/workspace ];then
    mkdir -p $HOME/workspace
fi

# Default entry folder
cd $WORKSPACE # 登录系统，默认进入 workspace 目录

alias ws="cd $WORKSPACE"
EOF

source $HOME/.bashrc
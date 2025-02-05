# dev_build
开发环境搭建

本脚本可避免环境奔溃或者开发环境搬迁等重新搭建繁琐步骤，当前环境基础镜像为centos 7.9 ，内置开发语言有：
- GOlang


# 使用方法
```bash
使用命令：
  make help                     显示帮助信息
  make docker_install           安装docker
  make docker_uninstall         卸载docker
  make build                    编译镜像
  make run                      运行容器
  make exec                     进入容器
  make stop                     停止所有容器
  make clean                    停止并清理所有容器
``` 

1. 未安装docker 环境请先执行`make docker_install` ,如需卸载docker 请执行 `make docker_uninstall`(谨慎操作！)。
2. 开发环境运行前请先编译镜像，需要保持外网链接，如果没有外网，建议将本脚本移至有外网环境编译后再拷贝到当前环境（拷贝方法自行百度），编译使用 `make build`。
3. 镜像编译成功后，就可以执行  `make run ` 把环境拉起来，拉起来后 sshd 默认端口为2202 ，可以通过ssh root@IP -P2202 登录该环境，也可以通过`make exec` 登录容器。
4. 环境内默认未安装任何语言，可以通过/root目录下的对应脚本进行安装,如需修改对应软件版本，请到`dockerfile/*.sh` 对应脚本修改，脚本也可用在宿主机环境执行


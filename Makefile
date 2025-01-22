# 镜像名称
IMAGE_NAME = test-kylin
TAG = v1.0.0
container_name = test_container

# Go 命令
DOCKER = docker
DOCKERBUILD = $(DOCKER) build 
DOCKERRUN = $(DOCKER) run


# 路径
DOCKER_DIR = dockerfiles

# 输出文件
# OUTPUT = $(BIN_DIR)/$(APP_NAME)

# 默认任务：编译项目
.PHONY: all
all: help

# 帮助信息
.PHONY: help
help:
	@echo "可用命令："
	@echo "  make help           		显示帮助信息"
	@echo "  make docker_install         	安装docker"
	@echo "  make docker_uninstall       	卸载docker"
	@echo "  make build                 	编译镜像"
	@echo "  make run           	运行容器"
	@echo "  make exec           	进入容器"
	@echo "  make stop           	停止所有容器"
	@echo "  make clean           	停止并清理所有容器"

.PHONY: docker_install
docker_install:
	cd scripts && sh docker_install.sh

.PHONY: docker_uninstall
docker_uninstall:
	cd scripts && sh docker_uninstall.sh

# 编译镜像
.PHONY: build
build: 
	cd $(DOCKER_DIR) && $(DOCKERBUILD) -t $(IMAGE_NAME):$(TAG) -f Dockerfile.el7 .

# 运行容器
.PHONY: run
run:
	$(DOCKERRUN) --privileged -itd -p 2202:2202 --name $(container_name) $(IMAGE_NAME):$(TAG) /bin/bash

# 运行bridge 模式的observer 容器
# cleanup:
# 	cd scripts && sh clean_ob.sh

.PHONY: exec
exec:run
	$(DOCKER) exec -it $(container_name) /bin/bash


.PHONY: stop
stop:
	docker stop $(shell docker ps -a -q)

.PHONY: clean
clean: stop
	docker rm $(shell docker ps -a -q)

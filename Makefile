# 镜像名称
IMAGE_NAME = obdocker
TAG = kylin-v1.0

# 项目路径

# Go 命令
DOCKER = docker
DOCKERBUILD = $(DOCKER) build 
DOCKERRUN = $(DOCKER) run


# 路径
DOCKER_DIR = dockerfile

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


.PHONY: docker_install
docker_install:
	cd scripts && sh docker_install.sh

# 创建镜像
.PHONY: build
build: 
	cd $(DOCKER_DIR) && $(DOCKERBUILD) -t $(IMAGE_NAME):$(TAG) .

# 运行bridge 模式的observer 容器
.PHONY: run_macvlan
run_macvlan:
	cd scripts && sh ob_runbymacvlan.sh

.PHONY: cleanup
cleanup:
	cd scripts && sh clean_ob.sh


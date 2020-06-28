.PHONY: run down setup-apps restart down-exchange down-app build-and-push-app deploy pull-image after_run deploy-test

include .env

COMPOSE = docker-compose -f compose/databases.yaml -f compose/proxy.yaml

WORKBENCH_TAG = latest
REPO = $(REPO_HOST)

###### app definition start ##########
# APP分为N个阶段，避免重启时由于先后顺序出现故障 common_redis common_mysql market_mongo registry common_mongo micro_web
# STEP1x 为基础镜像，如redis、mysql等; 或者是依赖度很高的基础模块，如 
# APP_STEP11 = mongo mysql redis
APP_STEP11 = 

# STEP2x 为功能相关镜像，比如用户模块需要先于其他业务模块启动
APP_STEP21 =

# STEP3x 为上层应用镜像，如管理后台等
APP_STEP31 =

# STEP9x 为最后启动相关，如proxy，需最后才启动
APP_STEP99 = proxy
# APP_STEP99 = 

ifndef $(APP)
APP =  $(APP_STEP11) $(APP_STEP21) $(APP_STEP31) $(APP_STEP99)
endif

###### app definition end ##########


ifndef $(BUILD_APP)
BUILD_APP = explorer-server explorer-pc
endif


# 将执行setup_hooks目录下对应名称的脚本
ifndef $(SETUP_APP)
SETUP_APP = 
endif

ifndef $(CLEAN_APP)
CLEAN_APP =
endif

default: run

#查看服务状态
ps:
	$(COMPOSE) ps $(APP)

#跟踪业务日志，可传APP变量
logsf:
	$(COMPOSE) logs -f --tail=100 $(APP)

#查看业务日志，可传APP变量
logs:
	$(COMPOSE) logs $(APP)

#启动某个服务
one:
	$(COMPOSE) up -d $(APP)

# 启动服务
run:
	$(COMPOSE) up -d $(APP_STEP11) $(APP_STEP21) $(APP_STEP31) $(APP_STEP99)
	$(COMPOSE) ps

# 重启服务，可传APP变量
restart:
	@$(COMPOSE) restart $(APP)

# 停止所有服务
stop:
	$(COMPOSE) stop $(APP)


# 删除所有服务及容器
down:
	$(COMPOSE) down

# =============== 分割线（init， 仅第一次初始化时使用） =================
# 初始化，仅第一次使用，也必须先于 make run 使用
setup: setup-apps

# 各项目第一次发布时，如果需要初始化，请参照setup_hook/exchange.sh
setup-apps:
	eval "for m in $(SETUP_APP); do sh -x scripts/setup_hooks/\$$m.sh; done"

# =============== 分割线（release 发布最新代码到仓库）===================

# 从仓库拉下最新workbench的代码，并更新配套服务代码
update:
	git pull --no-recurse-submodule && git submodule update --init


# 从app目录下build镜像，并且推到仓库
build-and-push-app:
	eval "for m in $(BUILD_APP); do scripts/build.sh -t $(WORKBENCH_TAG) -r $(REPO) -a \$$m -u; done"

# 从app目录下build镜像
build:
	eval "for m in $(BUILD_APP); do scripts/build.sh -t $(WORKBENCH_TAG) -r $(REPO) -a \$$m; done"

# 清除应用，可传CLEAN_APP环境变量
clean:
	eval "for m in $(CLEAN_APP); do scripts/clean_hooks/\$$m.sh; done"


# ============== 分割线(deploy 部署，拉取最新镜像运行) ===================

# 杀掉app
down-app:
	bash scripts/run_hook.sh -a down_app -A '$(APP)'

# 拉取镜像
pull:
	eval "for m in $(BUILD_APP); do docker pull $(REPO)/\$$m:$(WORKBENCH_TAG); done"
#pull-image:
#	docker pull $(REPO)/exchange
#	docker pull $(REPO)/usermgr
#	docker pull $(REPO)/place-order

# 部署
#deploy: pull-image down-app run after_run restart-nginx

# test deploy
#deploy-test: down-app run after_run restart-nginx

# 各项目部署完后需要执行的操作，请参照after_hooks/exchange.sh
after_run:
	bash scripts/run_hook.sh -a after -A '$(APP)'


FILE = Makefile.test
ifeq ($(FILE), $(wildcard $(FILE)))
include Makefile.test
endif

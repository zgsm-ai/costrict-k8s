[TOC]

# 部署

## 介绍

<font color='blue'>k8s-helm 方案是较复杂的自定义参数较多的方案，大部分配置需要手动配置，请根据实际情况决定是否选择此部署方案</font>

部署只提供 linux amd64 k8s集群模式部署方案,需要支持helm 3.18, 部署人员需要知道以下知识点:

1. docker
2. k8s
3. helm

注意：默认不部署prometheus+grafana+loki,如需要，请自行修改deploymetn-config.yaml。

## 前期准备

### 环境

准备以下环境: `k8s > v1.27.0`、 `helm >= 3`、`python >=3.6`(安装pyyaml：pip3 install PyYAML) ,如果你的环境中没有 python和helm环境，可以使用这个镜像运行容器，在这个容器中运行kubectl、python、helm等命令,也可以提前准备好[镜像](./docker_file/costrict-helm-tool/README.md)

准备可用的StorageClass，比如通过nfs创建的sc。

对于单节点服务器，不建议使用helm部署，可能存在部分服务不支持的情况，如果仍需要helm部署，请创建网络存储卷，也可以准备一个目录用于存储持久化数据，并创建hostPath类型的SC,请参考[https://github.com/rancher/local-path-provisioner](https://github.com/rancher/local-path-provisioner) ,其中[yaml文件](https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.32/deploy/local-path-storage.yaml)和[镜像](https://hub.docker.com/layers/rancher/local-path-provisioner/v0.0.32/images/sha256-64975a72cb31bda96fea61f4b59e6cca4545e531487a13fab7ba1b7aba95bd6c)下载导入和使用不在此教程中

### 导入镜像

如果是离线环境，请提前导入所有docker镜像

这些是部分稳定镜像，不常更新( 部分zgsm下镜像来自官方，我们只是备份一份到docker hub)：
```
# apisix
apache/apisix-dashboard:3.0.0-alpine
docker.io/bitnami/etcd:3.5.10-debian-11-r2
apache/apisix:3.9.1-debian

# casdoor 
zgsm/casdoor:v2.0.6

# oidc
zgsm/oidc-auth:v1.2.8

# higress
zgsm/higress-console:2.1.6
zgsm/higress-prometheus:v2.40.7
zgsm/higress-grafana:9.3.6
zgsm/higress-loki:2.9.4

# pgsql
docker.io/bitnami/postgresql:17.4.0-debian-12-r17
docker.io/bitnami/os-shell:12-debian-12-r43
docker.io/bitnami/postgres-exporter:0.17.1-debian-12-r6
docker.io/bitnami/postgresql:17.4.0-debian-12-r17

# pgsql-ha
docker.io/bitnami/pgpool:4.6.3-debian-12-r0
docker.io/bitnami/postgres-exporter:0.17.1-debian-12-r16
docker.io/bitnami/postgresql-repmgr:17.6.0-debian-12-r2

# weaviate
semitechnologies/weaviate:1.30.0

# redis
docker.io/redis:7.2.4

# nginx
nginx:1.27.1

```

<font color='red'>其他Costrict 的业务镜像，可以参考：values下的yaml文件，或者 [Docker compose方案](https://github.com/zgsm-ai/zgsm-backend-deploy/) 中的描述,或者联系我们。 </font>

### 创建k8s存储类(StorageClass)

根据实际的业务需求情况，创建sc，用于存储持久化数据。

### 创建namespace

创建namespace costrict 本例子都将按照costrict (cotun在costrict-cotun 命名空间下)namespace 进行配置

```
kubectl create ns costrict
kubectl create ns costrict-cotun
```

### 了解配置文件

在 deployment-config.yaml中，最外层的键除了global外都表示一个模块(键就是其模块名)，每个模块中有一个或者多个服务,每个服务都有多个配置，包含：

values配置，chart配置，storageClass配置，set配置：

- values配置的值表示其配置文件是 `values/模块名/值`这个配置文件
- chart配置的值表示其chart包在`values/模块名/值`
- storageClass配置 是一批键值对，代表其storageClass配置的key和value,修改时只需要修改value即可
- set配置表示 在运行helm install 是 --set的参数值

如：

```yaml
global:
  # 全局namespace,每个服务可以自定义,但是需要修改大量配置文件，不建议。
  namespace: costrict
  # set 可以用于全局helm Set
  set: ""

data-services:
  postgresql:
    values: postgresql-values.yaml
    chart: postgresql-16.6.6.tgz
    storageClass:
      "global.storageClass": "costrict-nfs"
    
  redis:
    values: redis-values.yaml
    chart: redis-20.3.0.tgz
  # 注释的内容将不会被安装
  # weaviate:
  #   chart: weaviate-17.4.5.tgz
  #   values: weaviate-values.yaml

```

表示data-service这个模块，有3个服务，分别是  postgresql redis weaviate(weaviate被注释了)

weaviate 的chart就在 `out/data-services/weaviate-17.4.5.tgz` weaviate的values.yaml就在 `values/data-service/weaviate-values.yaml` 

## 修改配置

### 修改部署配置

1. 修改配置文件选择注释掉不需要安装的内容

2. 如果用户量增加,建议将weaviate redis 单独使用docker 部署到特定服务器，提升稳定性, 建议拆分不同业务的存储，避免相互影响

3. 修改配置文件**deployment-config.yaml** 修改自定义的存储类

有这些模块的多个服务的存储类需要修改： `chat-rag` `portal` `tunnel-nanager` `postgresql` `redis`  `weaviate` `apisix` `higress`

比如chart-rag的配置如下：
```yaml
chat-rag:
  chat-rag:
    chart: chat-rag-0.1.0.tgz
    values: chat-rag-values.yaml
    storageClass:
      "persistence.storageClassName": "costrict-nfs"
```

只需要修改"persistence.storageClassName": "" 的值为你创建的sc即可，建议在deployment-config.yaml文件中直接搜索costrict-nfs全部替换即可

### 修改helm-values

 
1. 如果修改了cotun的运行命名空间，需要修改 values/codebase-server/querier-values.yaml的配置，因为这个配置需要访问cotun,默认命名空间是：costrict-cotun

2. `values/auth/oidc-values.yaml` 修改 clientID clientSecret,登录认证时需要
3. `values/ai-gateway/quota-manager-values.yaml` 修改signing_key, 用于签名配额
4. `values/auth/apisix-values.yaml` 修改相关的密钥和密码,以及需要暴露的apisix-gateway端口，这个端口将用于访问costrict的入口。
5. `values/portal/costrict-ssh-manager-values.yaml` 修改管理容器的密码，管理容器用于查看chat-rag日志，更新portal内容等。

## 检查配置完整度

```
python3 helm_deploy.py check
```

## 安装

1 使用 `python3 helm_deploy.py install postgresql-ha` 先安装pgsql,然后将deployment-config.yaml 中的postgresql 注释掉。

2 连接到`auth`和`quota-manager`数据库,运行[doc/sql/auth.sql](./sql/auth.sql) 和 [doc/sql/quota-manager.sql](./sql/quota-manager.sql)

3 使用以下命令安装其他全部服务
```
python3 helm_deploy.py install --all
```

### 修改路由

修改[路由配置脚本](./router/apisix_router_settin.sh) 的参数，配置路由,尤其是：
```bash
# client Id
OIDC_CLIENT_ID=7c51a6b92dfebfa55d96
# client secret
OIDC_CLIENT_SECRET=7c51a6b92dfebfa55d96
# apisix-admin 的地址，可以通过  kubectl get svc -n <namespace> 获取, 由于是clusterip,请在集群内执行脚本。
APISIX_ADDR=10.233.63.159:9180
# apisix的密钥，可在 values/auth/apisix-values.yaml 中自定义
AUTH="X-API-KEY: costrict-2025-admin"
```

### 配置casdoor

登录casdoor并配置

默认用户名密码

```
admin
123
```

修改客户端ID和客户端密钥为 values/oidc-values.yaml 中providers.casdoor中的值

重定向url中添加服务器地址

casdoor具体配置，请根据casdoor官方文档。


### 配置higress

访问higress 并设置初始密码如：admin costrict, 并按照官方文档配置。

我们提供了[配额服务](https://github.com/zgsm-ai/quota-manager) 和 [higress 配额插件](https://github.com/zgsm-ai/higress/blob/main/plugins/wasm-go/extensions/ai-quota/main.go) 请自行获取

### Portal

portal是一个使用nginx提供反向代理代理静态文件的服务，里面包含了一些costrict的客户端，错误码，wasm插件等，自行选择配置。

可参考[docker compose 部署方式](https://github.com/zgsm-ai/zgsm-backend-deploy/tree/main/portal/data) 中的内容。


## 使用

```
访问 apisix-gateway 这个k8s service的端口即可，costrict插件中设置的baseUrl也是访问这个端口即可。
```

# 卸载

不提供卸载脚本，请手动卸载，<font color='red'>卸载十分危险，请谨慎执行</font>

**卸载heml chart**

全部卸载

```shell
helm uninstall  -n <namespace>  $(helm list -n test-costrict  | awk '{print $1}' | grep -v NAME)
```

**卸载PVC**

```
kubectl delete pvc -n <namespace> $(kubectl get pvc -n <namespace> | awk '{print $1}' | grep -v NAME)
```


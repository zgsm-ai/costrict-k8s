[TOC]

# 部署

## 介绍

部署只提供 linux amd64 k8s集群模式部署方案,需要支持helm 3.18, 部署人员需要知道以下知识点:

1. docker
2. k8s
3. helm

注意：此部署只部署服务，相关配置还需要用户自行配置，**并且不部署Prometheus以及不同服务的 ServiceMonitor**

## 前期准备

### 环境

准备以下环境: `k8s > v1.27.0`、 `helm >= 3`、`python >=3.6`(安装pyyaml：pip3 install PyYAML) ,如果你的环境中没有 python和helm环境，可以使用这个镜像运行容器，在这个容器中运行kubectl、python、helm等命令,也可以提前准备好[镜像](./docker_file/README.md)

对于多节点，准备可用的StorageClass，比如通过nfs创建的sc。

对于单节点服务器，不建议使用helm部署，可能存在部分服务不支持的情况，如果仍需要helm部署，请创建网络存储卷，也可以准备一个目录用于存储持久化数据，并创建hostPath类型的SC,请参考[https://github.com/rancher/local-path-provisioner](https://github.com/rancher/local-path-provisioner) ,其中[yaml文件](https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.32/deploy/local-path-storage.yaml)和[镜像](https://hub.docker.com/layers/rancher/local-path-provisioner/v0.0.32/images/sha256-64975a72cb31bda96fea61f4b59e6cca4545e531487a13fab7ba1b7aba95bd6c)下载导入和使用不在此教程中

### 导入镜像

如果是离线环境，请导入所有docker镜像

### 创建k8s存储类(StorageClass)

根据实际的业务需求情况，创建sc

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

 
1. 如果修改了cotun的运行命名空间，需要修改 values/codebase-server/querier-values.yaml

### 修改自定义设置

1. `values/auth/oidc-values.yaml` 修改 clientID clientSecret,登录认证时需要
2. `values/ai-gateway/quota-manager-values.yaml` 修改signing_key, 用于签名配额

## 检查配置完整度

```
python3 helm_deploy.py check
```

## 安装

1 使用 `python3 helm_deploy.py install postgresql-ha` 先安装pgsql,然后将deployment-config.yaml 中的postgresql 注释掉。

2 连接到`auth`和`quota-manager`数据库,运行[doc/sql/auth.sql](./sql/auth.sql) 和 [doc/sql/quota-manager.sql](./sql/quota-manager.sql)

3 使用以下命令安装其他全部服务
```
python3 helm_deploy.py install
```

### 修改路由

修改[路由配置脚本](./router/apisix_router_settin.sh) 的参数，配置路由,尤其是：
```
OIDC_CLIENT_ID=7c51a6b92dfebfa55d96
OIDC_CLIENT_SECRET=7c51a6b92dfebfa55d96
```
其中 TRUSTED_ADDRESSES 可以使用命令查看
```
kubectl cluster-info dump | grep -i service-cluster-ip-range
```
### 配置casdoor

登录casdoor并配置

```
admin
123
```

修改客户端ID和客户端密钥为 values/oidc-values.yaml 中providers.casdoor中的值

重定向url中添加服务器地址

### 配置higress

访问higress 并设置初始密码如：admin test123,并按照官方文档配置安装。


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


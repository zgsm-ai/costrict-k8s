# costrict helm一键部署仓库

如何使用helm部署costrict,这是我们团队的内部方案,大部分步骤都比较简略，私有化部署建议参考docker-compose方案

如果用户量增加,建议将weaviate redis 单独使用docker 部署到特定节点,建议拆分不同业务的存储，避免相互影响

## 部署文档

部署流程请参考: [部署文档](./doc/deploy.md)


## 目录信息

**values:** 存放标准的helm values.yaml

**charts:** 存放所有chart,包含chart包或者chart源码。

```
├─ai-gateway
│  ├─quota-manager
│  └─quota-manager-frontend
├─auth
│  └─oidc-auth
├─chat-rag
│  └─chat-rag
├─code-completions
│  └─code-completions
├─code-review
│  └─code-review
├─codebase-server
│  ├─embedder
│  └─querier
├─data-services
├─frontend
│  └─credit-manager
├─portal
│  ├─costrict-ssh-manager
│  └─portal
├─statistics
│  └─pushgateway
└─tunnel
    ├─cotun
    └─tunnel-manager
```

**values**

helm values 文件都在values/目录下

```
├─ai-gateway            # ai网关和配额插件
├─auth                  # 服务网关和认证相关模块
├─chat-rag              # chat-rag
├─code-completions      # 代码补全
├─code-review           # code review 
├─codebase-server       # codebase相关的服务，包含querier embedding
├─data-services         # 数据服务,mysql, redis, 向量数据库等
├─frontend              # 前端页面
├─portal                # 静态资源,以及静态资源管理容器
├─statistics            # 统计相关，主要是指标数据采集 
└─tunnel                # 隧道相关
```

## 提交规范

### git 规范

| 设置    | 命令                                      | 用途                                                         |
| ------- | ----------------------------------------- | ------------------------------------------------------------ |
| `true`  | `git config --global core.autocrlf true`  | Windows 用户推荐：提交转 LF，检出转 CRLF                     |
| `input` | `git config --global core.autocrlf input` | Linux/macOS 用户推荐：提交时转 LF，但检出时不转换（保持 LF） |


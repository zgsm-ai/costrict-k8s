# costrict helm一键部署仓库

如何使用helm部署costrict,这是我们团队的内部方案,大部分步骤都忽略，私有化部署建议参考docker-compose方案

## 部署文档

[部署文档](./deploy.md)


## 目录信息

**values:** 存放标准的简略values.yaml

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
│  └─portal
└─tunnel
    ├─cotun
    └─tunnel-manager
```

## 提交规范

### git 规范

| 设置    | 命令                                      | 用途                                                         |
| ------- | ----------------------------------------- | ------------------------------------------------------------ |
| `true`  | `git config --global core.autocrlf true`  | Windows 用户推荐：提交转 LF，检出转 CRLF                     |
| `input` | `git config --global core.autocrlf input` | Linux/macOS 用户推荐：提交时转 LF，但检出时不转换（保持 LF） |


## 参数

### 全局参数

| 名称 | 描述 | 值 |
| --- | --- | --- |
| `global.imageRegistry` | 全局 Docker 镜像仓库 | `""` |
| `global.imagePullSecrets` | 全局 Docker 仓库密钥名称数组 | `[]` |
| `global.defaultStorageClass` | 持久化卷的全局默认存储类 | `""` |
| `global.postgresql.username` | PostgreSQL 用户名（覆盖 `postgresql.username`） | `""` |
| `global.postgresql.password` | PostgreSQL 密码（覆盖 `postgresql.password`） | `""` |
| `global.postgresql.database` | PostgreSQL 数据库（覆盖 `postgresql.database`） | `""` |
| `global.postgresql.repmgrUsername` | PostgreSQL repmgr 用户名（覆盖 `postgresql.repmgrUsername`） | `""` |
| `global.postgresql.repmgrPassword` | PostgreSQL repmgr 密码（覆盖 `postgresql.repmgrpassword`） | `""` |
| `global.postgresql.repmgrDatabase` | PostgreSQL repmgr 数据库（覆盖 `postgresql.repmgrDatabase`） | `""` |
| `global.postgresql.existingSecret` | 用于 PostgreSQL 密码的现有密钥名称（覆盖 `postgresql.existingSecret`） | `""` |
| `global.ldap.bindpw` | LDAP 绑定密码（覆盖 `ldap.bindpw`） | `""` |
| `global.ldap.existingSecret` | 用于 LDAP 密码的现有密钥名称（覆盖 `ldap.existingSecret`） | `""` |
| `global.pgpool.adminUsername` | Pgpool-II 管理员用户名（覆盖 `pgpool.adminUsername`） | `""` |
| `global.pgpool.adminPassword` | Pgpool-II 管理员密码（覆盖 `pgpool.adminPassword`） | `""` |
| `global.pgpool.srCheckUsername` | Pgpool-II 流复制检查用户名（覆盖 `pgpool.srCheckUsername`） | `""` |
| `global.pgpool.srCheckPassword` | Pgpool-II 流复制检查密码（覆盖 `pgpool.srCheckPassword`） | `""` |
| `global.pgpool.existingSecret` | Pgpool-II 现有密钥 | `""` |
| `global.security.allowInsecureImages` | 允许跳过镜像验证 | `false` |
| `global.compatibility.openshift.adaptSecurityContext` | 调整部署的 securityContext 部分，使其与 Openshift restricted-v2 SCC 兼容：删除 runAsUser、runAsGroup 和 fsGroup，让平台使用其允许的默认 ID。可能的值：auto（如果检测到的运行集群是 Openshift 则应用）、force（始终执行调整）、disabled（不执行调整） | `auto` |

### 通用参数

| 名称 | 描述 | 值 |
| --- | --- | --- |
| `kubeVersion` | 覆盖 Kubernetes 版本 | `""` |
| `nameOverride` | 部分覆盖 common.names.fullname 模板的字符串（将保留发布名称） | `""` |
| `fullnameOverride` | 完全覆盖 common.names.fullname 模板的字符串 | `""` |
| `namespaceOverride` | 完全覆盖 common.names.namespace 的字符串 | `""` |
| `commonLabels` | 添加到所有资源的通用标签（不考虑子图表）。作为模板评估 | `{}` |
| `commonAnnotations` | 添加到所有资源的通用注释（不考虑子图表）。作为模板评估 | `{}` |
| `clusterDomain` | Kubernetes 集群域 | `cluster.local` |
| `extraDeploy` | 与发布一起部署的额外对象数组（作为模板评估） | `[]` |
| `diagnosticMode.enabled` | 启用诊断模式（所有探针将被禁用，命令将被覆盖） | `false` |
| `diagnosticMode.command` | 覆盖部署中所有容器的命令 | `[]` |
| `diagnosticMode.args` | 覆盖部署中所有容器的参数 | `[]` |

### 带有 Repmgr 的 PostgreSQL 参数

| 名称 | 描述 | 值 |
| --- | --- | --- |
| `postgresql.image.registry` | 带有 Repmgr 的 PostgreSQL 镜像仓库 | `REGISTRY_NAME` |
| `postgresql.image.repository` | 带有 Repmgr 的 PostgreSQL 镜像仓库 | `REPOSITORY_NAME/postgresql-repmgr` |
| `postgresql.image.digest` | 带有 Repmgr 的 PostgreSQL 镜像摘要，格式为 sha256:aa.... 请注意，如果设置此参数，将覆盖标签 | `""` |
| `postgresql.image.pullPolicy` | 带有 Repmgr 的 PostgreSQL 镜像拉取策略 | `IfNotPresent` |
| `postgresql.image.pullSecrets` | 指定 docker-registry 密钥名称数组 | `[]` |
| `postgresql.image.debug` | 指定是否应启用调试日志 | `false` |
| `postgresql.labels` | 添加到 StatefulSet 的标签。作为模板评估 | `{}` |
| `postgresql.podLabels` | 添加到 StatefulSet Pod 的标签。作为模板评估 | `{}` |
| `postgresql.serviceAnnotations` | 为 PostgreSQL 服务提供任何额外的注释 | `{}` |
| `postgresql.replicaCount` | 要部署的副本数量。使用奇数。拥有 3 个副本是在提升新主节点时获得仲裁的最小数量。 | `3` |
| `postgresql.updateStrategy.type` | Postgresql StatefulSet 策略类型 | `RollingUpdate` |
| `postgresql.containerPorts.postgresql` | PostgreSQL 端口 | `5432` |
| `postgresql.automountServiceAccountToken` | 在 Pod 中挂载服务账户令牌 | `false` |
| `postgresql.hostAliases` | 部署 Pod 主机别名 | `[]` |
| `postgresql.hostNetwork` | 指定是否应为 PostgreSQL Pod 启用主机网络 | `false` |
| `postgresql.hostIPC` | 指定是否应为 PostgreSQL Pod 启用主机 IPC | `false` |
| `postgresql.podAnnotations` | 额外的 Pod 注释 | `{}` |
| `postgresql.podAffinityPreset` | PostgreSQL Pod 亲和性预设。如果设置了 `postgresql.affinity`，则忽略。允许的值：`soft` 或 `hard` | `""` |
| `postgresql.podAntiAffinityPreset` | PostgreSQL Pod 反亲和性预设。如果设置了 `postgresql.affinity`，则忽略。允许的值：`soft` 或 `hard` | `soft` |
| `postgresql.nodeAffinityPreset.type` | PostgreSQL 节点亲和性预设类型。如果设置了 `postgresql.affinity`，则忽略。允许的值：`soft` 或 `hard` | `""` |
| `postgresql.nodeAffinityPreset.key` | 要匹配的 PostgreSQL 节点标签键。如果设置了 `postgresql.affinity`，则忽略。 | `""` |
| `postgresql.nodeAffinityPreset.values` | 要匹配的 PostgreSQL 节点标签值。如果设置了 `postgresql.affinity`，则忽略。 | `[]` |
| `postgresql.affinity` | PostgreSQL Pod 分配的亲和性 | `{}` |
| `postgresql.nodeSelector` | PostgreSQL Pod 分配的节点标签 | `{}` |
| `postgresql.tolerations` | PostgreSQL Pod 分配的容忍度 | `[]` |
| `postgresql.topologySpreadConstraints` | Pod 分配的拓扑分布约束，在故障域之间跨集群分布。作为模板评估 | `[]` |
| `postgresql.priorityClassName` | Pod 优先级类 | `""` |
| `postgresql.schedulerName` | 使用备用调度程序，例如 "stork"。 | `""` |
| `postgresql.terminationGracePeriodSeconds` | PostgreSQL Pod 需要优雅终止的秒数 | `""` |
| `postgresql.podSecurityContext.enabled` | 为带有 Repmgr 的 PostgreSQL 启用安全上下文 | `true` |
| `postgresql.podSecurityContext.fsGroupChangePolicy` | 设置文件系统组更改策略 | `Always` |
| `postgresql.podSecurityContext.sysctls` | 使用 sysctl 接口设置内核设置 | `[]` |
| `postgresql.podSecurityContext.supplementalGroups` | 设置文件系统额外组 | `[]` |
| `postgresql.podSecurityContext.fsGroup` | 带有 Repmgr 的 PostgreSQL 文件系统的组 ID | `1001` |
| `postgresql.containerSecurityContext.enabled` | 启用容器的安全上下文 | `true` |
| `postgresql.containerSecurityContext.seLinuxOptions` | 在容器中设置 SELinux 选项 | `{}` |
| `postgresql.containerSecurityContext.runAsUser` | 设置容器的安全上下文 runAsUser | `1001` |
| `postgresql.containerSecurityContext.runAsGroup` | 设置容器的安全上下文 runAsGroup | `1001` |
| `postgresql.containerSecurityContext.runAsNonRoot` | 设置容器的安全上下文 runAsNonRoot | `true` |
| `postgresql.containerSecurityContext.privileged` | 设置容器的安全上下文 privileged | `false` |
| `postgresql.containerSecurityContext.readOnlyRootFilesystem` | 设置容器的安全上下文 readOnlyRootFilesystem | `true` |
| `postgresql.containerSecurityContext.allowPrivilegeEscalation` | 设置容器的安全上下文 allowPrivilegeEscalation | `false` |
| `postgresql.containerSecurityContext.capabilities.drop` | 要删除的功能列表 | `["ALL"]` |
| `postgresql.containerSecurityContext.seccompProfile.type` | 设置容器的安全上下文 seccomp 配置文件 | `RuntimeDefault` |
| `postgresql.command` | 覆盖默认容器命令（使用自定义镜像时有用） | `[]` |
| `postgresql.args` | 覆盖默认容器参数（使用自定义镜像时有用） | `[]` |
| `postgresql.lifecycleHooks` | 在启动时设置额外配置的 LifecycleHook，例如通过 REST API 设置 LDAP 设置。作为模板评估 | `{}` |
| `postgresql.extraEnvVars` | 包含额外环境变量的数组 | `[]` |
| `postgresql.extraEnvVarsCM` | 包含额外环境变量的 ConfigMap | `""` |
| `postgresql.extraEnvVarsSecret` | 包含额外环境变量的 Secret | `""` |
| `postgresql.extraVolumes` | 添加到 StatefulSet 的额外卷 | `[]` |
| `postgresql.extraVolumeMounts` | 添加到容器的额外卷挂载。通常与 `extraVolumes` 一起使用。 | `[]` |
| `postgresql.initContainers` | 添加到 StatefulSet 的额外初始化容器 | `[]` |
| `postgresql.sidecars` | 添加到 StatefulSet 的额外边车容器 | `[]` |
| `postgresql.resourcesPreset` | 根据一个通用预设设置容器资源（允许的值：none、nano、micro、small、medium、large、xlarge、2xlarge）。如果设置了 postgresql.resources，则忽略此设置（生产环境推荐使用 postgresql.resources）。 | `micro` |
| `postgresql.resources` | 为不同资源（如 CPU 或内存）设置容器请求和限制（生产工作负载必需） | `{}` |
| `postgresql.podManagementPolicy` | 设置 Pod 管理策略 | `Parallel` |
| `postgresql.livenessProbe.enabled` | 启用存活探针 | `true` |
| `postgresql.livenessProbe.initialDelaySeconds` | 存活探针的初始延迟秒数 | `15` |
| `postgresql.livenessProbe.periodSeconds` | 存活探针的周期秒数 | `10` |
| `postgresql.livenessProbe.timeoutSeconds` | 存活探针的超时秒数 | `5` |
| `postgresql.livenessProbe.failureThreshold` | 存活探针的失败阈值 | `6` |
| `postgresql.livenessProbe.successThreshold` | 存活探针的成功阈值 | `1` |
| `postgresql.readinessProbe.enabled` | 启用就绪探针 | `true` |
| `postgresql.readinessProbe.initialDelaySeconds` | 就绪探针的初始延迟秒数 | `5` |
| `postgresql.readinessProbe.periodSeconds` | 就绪探针的周期秒数 | `10` |
| `postgresql.readinessProbe.timeoutSeconds` | 就绪探针的超时秒数 | `5` |
| `postgresql.readinessProbe.failureThreshold` | 就绪探针的失败阈值 | `6` |
| `postgresql.readinessProbe.successThreshold` | 就绪探针的成功阈值 | `1` |
| `postgresql.startupProbe.enabled` | 启用启动探针 | `false` |
| `postgresql.startupProbe.initialDelaySeconds` | 启动探针的初始延迟秒数 | `5` |
| `postgresql.startupProbe.periodSeconds` | 启动探针的周期秒数 | `10` |
| `postgresql.startupProbe.timeoutSeconds` | 启动探针的超时秒数 | `5` |
| `postgresql.startupProbe.failureThreshold` | 启动探针的失败阈值 | `10` |
| `postgresql.startupProbe.successThreshold` | 启动探针的成功阈值 | `1` |
| `postgresql.customLivenessProbe` | 覆盖默认存活探针 | `{}` |
| `postgresql.customReadinessProbe` | 覆盖默认就绪探针 | `{}` |
| `postgresql.customStartupProbe` | 覆盖默认启动探针 | `{}` |
| `postgresql.networkPolicy.enabled` | 指定是否应创建 NetworkPolicy | `true` |
| `postgresql.networkPolicy.allowExternal` | 不要求连接使用服务器标签 | `true` |
| `postgresql.networkPolicy.allowExternalEgress` | 允许 Pod 访问任何端口范围和所有目标。 | `true` |
| `postgresql.networkPolicy.extraIngress` | 向 NetworkPolicy 添加额外的入口规则 | `[]` |
| `postgresql.networkPolicy.extraEgress` | 向 NetworkPolicy 添加额外的入口规则 | `[]` |
| `postgresql.networkPolicy.ingressNSMatchLabels` | 匹配以允许来自其他命名空间的流量的标签 | `{}` |
| `postgresql.networkPolicy.ingressNSPodMatchLabels` | 匹配以允许来自其他命名空间的流量的 Pod 标签 | `{}` |
| `postgresql.pdb.create` | 指定是否为带有 Repmgr 的 PostgreSQL 创建 Pod 中断预算 | `true` |
| `postgresql.pdb.minAvailable` | 应保持调度的最小 Pod 数量/百分比 | `""` |
| `postgresql.pdb.maxUnavailable` | 可能变得不可用的最大 Pod 数量/百分比。如果 `postgresql.pdb.minAvailable` 和 `postgresql.pdb.maxUnavailable` 都为空，则默认为 `1`。 | `""` |
| `postgresql.username` | PostgreSQL 用户名 | `postgres` |
| `postgresql.password` | PostgreSQL 密码 | `""` |
| `postgresql.database` | PostgreSQL 数据库 | `""` |
| `postgresql.existingSecret` | 使用现有密钥的 PostgreSQL 密码 | `""` |
| `postgresql.postgresPassword` | 当 `username` 不是 `postgres` 时，`postgres` 用户的 PostgreSQL 密码 | `""` |
| `postgresql.usePasswordFiles` | 设置为 `true` 以将 PostgreSQL 密钥作为文件挂载，而不是传递环境变量 | `true` |
| `postgresql.pgHbaTrustAll` | 配置 PostgreSQL HBA 以信任每个用户 | `false` |
| `postgresql.syncReplication` | 启用同步复制同步，等待数据在每个副本中同步，然后才能运行其他查询 | `false` |
| `postgresql.syncReplicationMode` | 这指定了从列出的服务器中选择同步备用服务器的方法。有效值：空、FIRST、ANY。 | `""` |
| `postgresql.repmgrUsername` | PostgreSQL Repmgr 用户名 | `repmgr` |
| `postgresql.repmgrPassword` | PostgreSQL Repmgr 密码 | `""` |
| `postgresql.repmgrDatabase` | PostgreSQL Repmgr 数据库 | `repmgr` |
| `postgresql.repmgrUsePassfile` | 配置 Repmgr 使用 `passfile` 而不是 `password` 变量*:*:*:username:password" | `true` |
| `postgresql.repmgrPassfilePath` | `passfile` 将存储的自定义路径 | `""` |
| `postgresql.repmgrLogLevel` | Repmgr 日志级别（DEBUG、INFO、NOTICE、WARNING、ERROR、ALERT、CRIT 或 EMERG） | `NOTICE` |
| `postgresql.repmgrConnectTimeout` | Repmgr 后端连接超时（以秒为单位） | `5` |
| `postgresql.repmgrReconnectAttempts` | Repmgr 后端重新连接尝试次数 | `2` |
| `postgresql.repmgrReconnectInterval` | Repmgr 后端重新连接间隔（以秒为单位） | `3` |
| `postgresql.repmgrFenceOldPrimary` | 设置在多主节点情况下是否需要隔离旧主节点 | `false` |
| `postgresql.repmgrChildNodesCheckInterval` | Repmgr 子节点检查间隔（以秒为单位） | `5` |
| `postgresql.repmgrChildNodesConnectedMinCount` | 在被视为隔离失败的旧主节点之前，Repmgr 连接的子节点最小数量 | `1` |
| `postgresql.repmgrChildNodesDisconnectTimeout` | 当检测到子节点不足时，节点将被隔离的时间（以秒为单位） | `30` |
| `postgresql.upgradeRepmgrExtension` | 升级数据库中的 Repmgr 扩展 | `false` |
| `postgresql.usePgRewind` | 使用 pg_rewind 进行备用故障转移（实验性） | `false` |
| `postgresql.audit.logHostname` | 将客户端主机名添加到日志文件 | `true` |
| `postgresql.audit.logConnections` | 将客户端登录操作添加到日志文件 | `false` |
| `postgresql.audit.logDisconnections` | 将客户端注销操作添加到日志文件 | `false` |
| `postgresql.audit.pgAuditLog` | 使用 pgAudit 扩展添加要记录的操作 | `""` |
| `postgresql.audit.pgAuditLogCatalog` | 使用 pgAudit 记录目录 | `off` |
| `postgresql.audit.clientMinMessages` | 与用户共享的消息日志级别 | `error` |
| `postgresql.audit.logLinePrefix` | 日志行前缀的模板字符串 | `""` |
| `postgresql.audit.logTimezone` | 日志时间戳的时区 | `""` |
| `postgresql.sharedPreloadLibraries` | 共享预加载库（逗号分隔列表） | `pgaudit, repmgr` |
| `postgresql.maxConnections` | 最大总连接数 | `""` |
| `postgresql.postgresConnectionLimit` | postgres 用户的最大连接数 | `""` |
| `postgresql.dbUserConnectionLimit` | 创建的用户的最大连接数 | `""` |
| `postgresql.tcpKeepalivesInterval` | TCP 保持活动间隔 | `""` |
| `postgresql.tcpKeepalivesIdle` | TCP 保持活动空闲 | `""` |
| `postgresql.tcpKeepalivesCount` | TCP 保持活动计数 | `""` |
| `postgresql.statementTimeout` | 语句超时 | `""` |
| `postgresql.pghbaRemoveFilters` | 要从 pg_hba.conf 文件中删除的模式逗号分隔列表 | `""` |
| `postgresql.extraInitContainers` | 额外的初始化容器 | `[]` |
| `postgresql.repmgrConfiguration` | Repmgr 配置 | `""` |
| `postgresql.configuration` | PostgreSQL 配置 | `""` |
| `postgresql.pgHbaConfiguration` | PostgreSQL 客户端身份验证配置 | `""` |
| `postgresql.configurationCM` | 包含配置文件的现有 ConfigMap 的名称 | `""` |
| `postgresql.extendedConf` | 扩展的 PostgreSQL 配置（需要 `volumePermissions.enabled` 为 `true`） | `""` |
| `postgresql.extendedConfCM` | 包含 PostgreSQL 扩展配置的 ConfigMap（需要 `volumePermissions.enabled` 为 `true`） | `""` |
| `postgresql.initdbScripts` | initdb 脚本字典 | `{}` |
| `postgresql.initdbScriptsCM` | 包含首次启动时运行的脚本的 ConfigMap | `""` |
| `postgresql.initdbScriptsSecret` | 包含首次启动时运行的脚本的 Secret | `""` |
| `postgresql.tls.enabled` | 为最终客户端连接启用 TLS 流量支持 | `false` |
| `postgresql.tls.preferServerCiphers` | 是否使用服务器的 TLS 密码首选项而不是客户端的 | `true` |
| `postgresql.tls.certificatesSecret` | 包含证书的现有密钥的名称 | `""` |
| `postgresql.tls.certFilename` | 证书文件名 | `""` |
| `postgresql.tls.certKeyFilename` | 证书密钥文件名 | `""` |
| `postgresql.preStopDelayAfterPgStopSeconds` | PostgreSQL 实例停止后，preStop 钩子等待的最小秒数 | `25` |
| `postgresql.headlessWithNotReadyAddresses` | 将 postgres headless 服务设置为 publishNotReadyAddresses 模式 | `false` |
| `witness.create` | 创建 PostgreSQL 见证节点 | `false` |
| `witness.labels` | 添加到 StatefulSet 的标签。作为模板评估 | `{}` |
| `witness.podLabels` | 添加到 StatefulSet Pod 的标签。作为模板评估 | `{}` |
| `witness.replicaCount` | 要部署的副本数量。 | `1` |
| `witness.updateStrategy.type` | Postgresql StatefulSet 策略类型 | `RollingUpdate` |
| `witness.containerPorts.postgresql` | PostgreSQL 见证端口 | `5432` |
| `witness.automountServiceAccountToken` | 在 Pod 中挂载服务账户令牌 | `false` |
| `witness.hostAliases` | 部署 Pod 主机别名 | `[]` |
| `witness.hostNetwork` | 指定是否应为 PostgreSQL 见证 Pod 启用主机网络 | `false` |
| `witness.hostIPC` | 指定是否应为 PostgreSQL 见证 Pod 启用主机 IPC | `false` |
| `witness.podAnnotations` | 额外的 Pod 注释 | `{}` |
| `witness.podAffinityPreset` | PostgreSQL 见证 Pod 亲和性预设。如果设置了 `witness.affinity`，则忽略。允许的值：`soft` 或 `hard` | `""` |
| `witness.podAntiAffinityPreset` | PostgreSQL 见证 Pod 反亲和性预设。如果设置了 `witness.affinity`，则忽略。允许的值：`soft` 或 `hard` | `soft` |
| `witness.nodeAffinityPreset.type` | PostgreSQL 见证节点亲和性预设类型。如果设置了 `witness.affinity`，则忽略。允许的值：`soft` 或 `hard` | `""` |
| `witness.nodeAffinityPreset.key` | 要匹配的 PostgreSQL 见证节点标签键。如果设置了 `witness.affinity`，则忽略。 | `""` |
| `witness.nodeAffinityPreset.values` | 要匹配的 PostgreSQL 见证节点标签值。如果设置了 `witness.affinity`，则忽略。 | `[]` |
| `witness.affinity` | PostgreSQL 见证 Pod 分配的亲和性 | `{}` |
| `witness.nodeSelector` | PostgreSQL 见证 Pod 分配的节点标签 | `{}` |
| `witness.tolerations` | PostgreSQL 见证 Pod 分配的容忍度 | `[]` |
| `witness.topologySpreadConstraints` | Pod 分配的拓扑分布约束，在故障域之间跨集群分布。作为模板评估 | `[]` |
| `witness.priorityClassName` | Pod 优先级类 | `""` |
| `witness.schedulerName` | 使用备用调度程序，例如 "stork"。 | `""` |
| `witness.terminationGracePeriodSeconds` | PostgreSQL 见证 Pod 需要优雅终止的秒数 | `""` |
| `witness.podSecurityContext.enabled` | 为带有 Repmgr 的 PostgreSQL 见证启用安全上下文 | `true` |
| `witness.podSecurityContext.fsGroupChangePolicy` | 设置文件系统组更改策略 | `Always` |
| `witness.podSecurityContext.sysctls` | 使用 sysctl 接口设置内核设置 | `[]` |
| `witness.podSecurityContext.supplementalGroups` | 设置文件系统额外组 | `[]` |
| `witness.podSecurityContext.fsGroup` | 带有 Repmgr 的 PostgreSQL 见证文件系统的组 ID | `1001` |
| `witness.containerSecurityContext.enabled` | 启用容器的安全上下文 | `true` |
| `witness.containerSecurityContext.seLinuxOptions` | 在容器中设置 SELinux 选项 | `{}` |
| `witness.containerSecurityContext.runAsUser` | 设置容器的安全上下文 runAsUser | `1001` |
| `witness.containerSecurityContext.runAsGroup` | 设置容器的安全上下文 runAsGroup | `1001` |
| `witness.containerSecurityContext.runAsNonRoot` | 设置容器的安全上下文 runAsNonRoot | `true` |
| `witness.containerSecurityContext.privileged` | 设置容器的安全上下文 privileged | `false` |
| `witness.containerSecurityContext.readOnlyRootFilesystem` | 设置容器的安全上下文 readOnlyRootFilesystem | `true` |
| `witness.containerSecurityContext.allowPrivilegeEscalation` | 设置容器的安全上下文 allowPrivilegeEscalation | `false` |
| `witness.containerSecurityContext.capabilities.drop` | 要删除的功能列表 | `["ALL"]` |
| `witness.containerSecurityContext.seccompProfile.type` | 设置容器的安全上下文 seccomp 配置文件 | `RuntimeDefault` |
| `witness.command` | 覆盖默认容器命令（使用自定义镜像时有用） | `[]` |
| `witness.args` | 覆盖默认容器参数（使用自定义镜像时有用） | `[]` |
| `witness.lifecycleHooks` | 在启动时设置额外配置的 LifecycleHook，例如通过 REST API 设置 LDAP 设置。作为模板评估 | `{}` |
| `witness.extraEnvVars` | 包含额外环境变量的数组 | `[]` |
| `witness.extraEnvVarsCM` | 包含额外环境变量的 ConfigMap | `""` |
| `witness.extraEnvVarsSecret` | 包含额外环境变量的 Secret | `""` |
| `witness.extraVolumes` | 添加到部署的额外卷 | `[]` |
| `witness.extraVolumeMounts` | 添加到容器的额外卷挂载。通常与 `extraVolumes` 一起使用。 | `[]` |
| `witness.initContainers` | 添加到部署的额外初始化容器 | `[]` |
| `witness.sidecars` | 添加到部署的额外边车容器 | `[]` |
| `witness.resourcesPreset` | 根据一个通用预设设置容器资源（允许的值：none、nano、micro、small、medium、large、xlarge、2xlarge）。如果设置了 witness.resources，则忽略此设置（生产环境推荐使用 witness.resources）。 | `micro` |
| `witness.resources` | 为不同资源（如 CPU 或内存）设置容器请求和限制（生产工作负载必需） | `{}` |
| `witness.livenessProbe.enabled` | 启用存活探针 | `true` |
| `witness.livenessProbe.initialDelaySeconds` | 存活探针的初始延迟秒数 | `30` |
| `witness.livenessProbe.periodSeconds` | 存活探针的周期秒数 | `10` |
| `witness.livenessProbe.timeoutSeconds` | 存活探针的超时秒数 | `5` |
| `witness.livenessProbe.failureThreshold` | 存活探针的失败阈值 | `6` |
| `witness.livenessProbe.successThreshold` | 存活探针的成功阈值 | `1` |
| `witness.readinessProbe.enabled` | 启用就绪探针 | `true` |
| `witness.readinessProbe.initialDelaySeconds` | 就绪探针的初始延迟秒数 | `5` |
| `witness.readinessProbe.periodSeconds` | 就绪探针的周期秒数 | `10` |
| `witness.readinessProbe.timeoutSeconds` | 就绪探针的超时秒数 | `5` |
| `witness.readinessProbe.failureThreshold` | 就绪探针的失败阈值 | `6` |
| `witness.readinessProbe.successThreshold` | 就绪探针的成功阈值 | `1` |
| `witness.startupProbe.enabled` | 启用启动探针 | `false` |
| `witness.startupProbe.initialDelaySeconds` | 启动探针的初始延迟秒数 | `5` |
| `witness.startupProbe.periodSeconds` | 启动探针的周期秒数 | `10` |
| `witness.startupProbe.timeoutSeconds` | 启动探针的超时秒数 | `5` |
| `witness.startupProbe.failureThreshold` | 启动探针的失败阈值 | `10` |
| `witness.startupProbe.successThreshold` | 启动探针的成功阈值 | `1` |
| `witness.customLivenessProbe` | 覆盖默认存活探针 | `{}` |
| `witness.customReadinessProbe` | 覆盖默认就绪探针 | `{}` |
| `witness.customStartupProbe` | 覆盖默认启动探针 | `{}` |
| `witness.pdb.create` | 指定是否为带有 Repmgr 的 PostgreSQL 见证创建 Pod 中断预算 | `true` |
| `witness.pdb.minAvailable` | 应保持调度的最小 Pod 数量/百分比 | `""` |
| `witness.pdb.maxUnavailable` | 可能变得不可用的最大 Pod 数量/百分比。如果 `witness.pdb.minAvailable` 和 `witness.pdb.maxUnavailable` 都为空，则默认为 `1`。 | `""` |
| `witness.upgradeRepmgrExtension` | 升级数据库中的 repmgr 扩展 | `false` |
| `witness.pgHbaTrustAll` | 配置 PostgreSQL HBA 以信任每个用户 | `false` |
| `witness.repmgrLogLevel` | Repmgr 日志级别（DEBUG、INFO、NOTICE、WARNING、ERROR、ALERT、CRIT 或 EMERG） | `NOTICE` |
| `witness.repmgrConnectTimeout` | Repmgr 后端连接超时（以秒为单位） | `5` |
| `witness.repmgrReconnectAttempts` | Repmgr 后端重新连接尝试次数 | `2` |
| `witness.repmgrReconnectInterval` | Repmgr 后端重新连接间隔（以秒为单位） | `3` |
| `witness.audit.logHostname` | 将客户端主机名添加到日志文件 | `true` |
| `witness.audit.logConnections` | 将客户端登录操作添加到日志文件 | `false` |
| `witness.audit.logDisconnections` | 将客户端注销操作添加到日志文件 | `false` |
| `witness.audit.pgAuditLog` | 使用 pgAudit 扩展添加要记录的操作 | `""` |
| `witness.audit.pgAuditLogCatalog` | 使用 pgAudit 记录目录 | `off` |
| `witness.audit.clientMinMessages` | 与用户共享的消息日志级别 | `error` |
| `witness.audit.logLinePrefix` | 日志行前缀的模板字符串 | `""` |
| `witness.audit.logTimezone` | 日志时间戳的时区 | `""` |
| `witness.maxConnections` | 最大总连接数 | `""` |
| `witness.postgresConnectionLimit` | postgres 用户的最大连接数 | `""` |
| `witness.dbUserConnectionLimit` | 创建的用户的最大连接数 | `""` |
| `witness.tcpKeepalivesInterval` | TCP 保持活动间隔 | `""` |
| `witness.tcpKeepalivesIdle` | TCP 保持活动空闲 | `""` |
| `witness.tcpKeepalivesCount` | TCP 保持活动计数 | `""` |
| `witness.statementTimeout` | 语句超时 | `""` |
| `witness.pghbaRemoveFilters` | 要从 pg_hba.conf 文件中删除的模式逗号分隔列表 | `""` |
| `witness.extraInitContainers` | 额外的初始化容器 | `[]` |
| `witness.repmgrConfiguration` | Repmgr 配置 | `""` |
| `witness.configuration` | PostgreSQL 配置 | `""` |
| `witness.pgHbaConfiguration` | PostgreSQL 客户端身份验证配置 | `""` |
| `witness.configurationCM` | 包含配置文件的现有 ConfigMap 的名称 | `""` |
| `witness.extendedConf` | 扩展的 PostgreSQL 配置（需要 `volumePermissions.enabled` 为 `true`） | `""` |
| `witness.extendedConfCM` | 包含 PostgreSQL 扩展配置的 ConfigMap（需要 `volumePermissions.enabled` 为 `true`） | `""` |
| `witness.initdbScripts` | initdb 脚本字典 | `{}` |
| `witness.initdbScriptsCM` | 包含首次启动时运行的脚本的 ConfigMap | `""` |
| `witness.initdbScriptsSecret` | 包含首次启动时运行的脚本的 Secret | `""` |

### Pgpool-II 参数

| 名称 | 描述 | 值 |
| --- | --- | --- |
| `pgpool.image.registry` | Pgpool-II 镜像仓库 | `REGISTRY_NAME` |
| `pgpool.image.repository` | Pgpool-II 镜像仓库 | `REPOSITORY_NAME/pgpool` |
| `pgpool.image.digest` | Pgpool-II 镜像摘要，格式为 sha256:aa.... 请注意，如果设置此参数，将覆盖标签 | `""` |
| `pgpool.image.pullPolicy` | Pgpool-II 镜像拉取策略 | `IfNotPresent` |
| `pgpool.image.pullSecrets` | 指定 docker-registry 密钥名称数组 | `[]` |
| `pgpool.image.debug` | 指定是否应启用调试日志 | `false` |
| `pgpool.customUsers.usernames` | 逗号或分号分隔的额外用户列表，这些用户将通过 pgpool 执行数据库连接。 | `""` |
| `pgpool.customUsers.passwords` | 上述用户的关联密码的逗号或分号分隔列表。必须与用户名列表具有相同数量的元素。 | `""` |
| `pgpool.automountServiceAccountToken` | 在 Pod 中挂载服务账户令牌 | `false` |
| `pgpool.hostAliases` | 部署 Pod 主机别名 | `[]` |
| `pgpool.customUsersSecret` | 包含将添加到 pgpool_passwd 的账户用户名和密码的密钥名称 | `""` |
| `pgpool.existingSecret` | 使用现有密钥的 Pgpool-II 管理员密码 | `""` |
| `pgpool.labels` | 添加到部署的标签。作为模板评估 | `{}` |
| `pgpool.podLabels` | 添加到 Pod 的标签。作为模板评估 | `{}` |
| `pgpool.serviceLabels` | 添加到服务的标签。作为模板评估 | `{}` |
| `pgpool.serviceAnnotations` | 为 Pgpool-II 服务提供任何额外的注释 | `{}` |
| `pgpool.customLivenessProbe` | 覆盖默认存活探针 | `{}` |
| `pgpool.customReadinessProbe` | 覆盖默认就绪探针 | `{}` |
| `pgpool.customStartupProbe` | 覆盖默认启动探针 | `{}` |
| `pgpool.command` | 覆盖默认容器命令（使用自定义镜像时有用） | `[]` |
| `pgpool.args` | 覆盖默认容器参数（使用自定义镜像时有用） | `[]` |
| `pgpool.lifecycleHooks` | 在启动时设置额外配置的 LifecycleHook，例如通过 REST API 设置 LDAP 设置。作为模板评估 | `{}` |
| `pgpool.extraEnvVars` | 包含额外环境变量的数组 | `[]` |
| `pgpool.extraEnvVarsCM` | 包含额外环境变量的 ConfigMap | `""` |
| `pgpool.extraEnvVarsSecret` | 包含额外环境变量的 Secret | `""` |
| `pgpool.extraVolumes` | 添加到部署的额外卷 | `[]` |
| `pgpool.extraVolumeMounts` | 添加到容器的额外卷挂载。通常与 `extraVolumes` 一起使用。 | `[]` |
| `pgpool.initContainers` | 添加到部署的额外初始化容器 | `[]` |
| `pgpool.sidecars` | 添加到部署的额外边车容器 | `[]` |
| `pgpool.replicaCount` | 要部署的副本数量 | `1` |
| `pgpool.podAnnotations` | 额外的 Pod 注释 | `{}` |
| `pgpool.priorityClassName` | Pod 优先级类 | `""` |
| `pgpool.schedulerName` | 使用备用调度程序，例如 "stork"。 | `""` |
| `pgpool.terminationGracePeriodSeconds` | pgpool Pod 需要优雅终止的秒数 | `""` |
| `pgpool.topologySpreadConstraints` | Pod 分配的拓扑分布约束，在故障域之间跨集群分布。作为模板评估 | `[]` |
| `pgpool.podAffinityPreset` | Pgpool-II Pod 亲和性预设。如果设置了 `pgpool.affinity`，则忽略。允许的值：`soft` 或 `hard` | `""` |
| `pgpool.podAntiAffinityPreset` | Pgpool-II Pod 反亲和性预设。如果设置了 `pgpool.affinity`，则忽略。允许的值：`soft` 或 `hard` | `soft` |
| `pgpool.nodeAffinityPreset.type` | Pgpool-II 节点亲和性预设类型。如果设置了 `pgpool.affinity`，则忽略。允许的值：`soft` 或 `hard` | `""` |
| `pgpool.nodeAffinityPreset.key` | 要匹配的 Pgpool-II 节点标签键。如果设置了 `pgpool.affinity`，则忽略。 | `""` |
| `pgpool.nodeAffinityPreset.values` | 要匹配的 Pgpool-II 节点标签值。如果设置了 `pgpool.affinity`，则忽略。 | `[]` |
| `pgpool.affinity` | Pgpool-II Pod 分配的亲和性 | `{}` |
| `pgpool.nodeSelector` | Pgpool-II Pod 分配的节点标签 | `{}` |
| `pgpool.tolerations` | Pgpool-II Pod 分配的容忍度 | `[]` |
| `pgpool.podSecurityContext.enabled` | 为 Pgpool-II 启用安全上下文 | `true` |
| `pgpool.podSecurityContext.fsGroupChangePolicy` | 设置文件系统组更改策略 | `Always` |
| `pgpool.podSecurityContext.sysctls` | 使用 sysctl 接口设置内核设置 | `[]` |
| `pgpool.podSecurityContext.supplementalGroups` | 设置文件系统额外组 | `[]` |
| `pgpool.podSecurityContext.fsGroup` | Pgpool-II 文件系统的组 ID | `1001` |
| `pgpool.containerSecurityContext.enabled` | 启用容器的安全上下文 | `true` |
| `pgpool.containerSecurityContext.seLinuxOptions` | 在容器中设置 SELinux 选项 | `{}` |
| `pgpool.containerSecurityContext.runAsUser` | 设置容器的安全上下文 runAsUser | `1001` |
| `pgpool.containerSecurityContext.runAsGroup` | 设置容器的安全上下文 runAsGroup | `1001` |
| `pgpool.containerSecurityContext.runAsNonRoot` | 设置容器的安全上下文 runAsNonRoot | `true` |
| `pgpool.containerSecurityContext.privileged` | 设置容器的安全上下文 privileged | `false` |
| `pgpool.containerSecurityContext.readOnlyRootFilesystem` | 设置容器的安全上下文 readOnlyRootFilesystem | `true` |
| `pgpool.containerSecurityContext.allowPrivilegeEscalation` | 设置容器的安全上下文 allowPrivilegeEscalation | `false` |
| `pgpool.containerSecurityContext.capabilities.drop` | 要删除的功能列表 | `["ALL"]` |
| `pgpool.containerSecurityContext.seccompProfile.type` | 设置容器的安全上下文 seccomp 配置文件 | `RuntimeDefault` |
| `pgpool.resourcesPreset` | 根据一个通用预设设置容器资源（允许的值：none、nano、micro、small、medium、large、xlarge、2xlarge）。如果设置了 pgpool.resources，则忽略此设置（生产环境推荐使用 pgpool.resources）。 | `micro` |
| `pgpool.resources` | 为不同资源（如 CPU 或内存）设置容器请求和限制（生产工作负载必需） | `{}` |
| `pgpool.livenessProbe.enabled` | 启用存活探针 | `true` |
| `pgpool.livenessProbe.initialDelaySeconds` | 存活探针的初始延迟秒数 | `30` |
| `pgpool.livenessProbe.periodSeconds` | 存活探针的周期秒数 | `10` |
| `pgpool.livenessProbe.timeoutSeconds` | 存活探针的超时秒数 | `5` |
| `pgpool.livenessProbe.failureThreshold` | 存活探针的失败阈值 | `3` |
| `pgpool.livenessProbe.successThreshold` | 存活探针的成功阈值 | `1` |
| `pgpool.readinessProbe.enabled` | 启用就绪探针 | `true` |
| `pgpool.readinessProbe.initialDelaySeconds` | 就绪探针的初始延迟秒数 | `5` |
| `pgpool.readinessProbe.periodSeconds` | 就绪探针的周期秒数 | `5` |
| `pgpool.readinessProbe.timeoutSeconds` | 就绪探针的超时秒数 | `5` |
| `pgpool.readinessProbe.failureThreshold` | 就绪探针的失败阈值 | `5` |
| `pgpool.readinessProbe.successThreshold` | 就绪探针的成功阈值 | `1` |
| `pgpool.startupProbe.enabled` | 启用启动探针 | `false` |
| `pgpool.startupProbe.initialDelaySeconds` | 启动探针的初始延迟秒数 | `5` |
| `pgpool.startupProbe.periodSeconds` | 启动探针的周期秒数 | `10` |
| `pgpool.startupProbe.timeoutSeconds` | 启动探针的超时秒数 | `5` |
| `pgpool.startupProbe.failureThreshold` | 启动探针的失败阈值 | `10` |
| `pgpool.startupProbe.successThreshold` | 启动探针的成功阈值 | `1` |
| `pgpool.networkPolicy.enabled` | 指定是否应创建 NetworkPolicy | `true` |
| `pgpool.networkPolicy.allowExternal` | 不要求连接使用服务器标签 | `true` |
| `pgpool.networkPolicy.allowExternalEgress` | 允许 Pod 访问任何端口范围和所有目标。 | `true` |
| `pgpool.networkPolicy.extraIngress` | 向 NetworkPolicy 添加额外的入口规则 | `[]` |
| `pgpool.networkPolicy.extraEgress` | 向 NetworkPolicy 添加额外的入口规则 | `[]` |
| `pgpool.networkPolicy.ingressNSMatchLabels` | 匹配以允许来自其他命名空间的流量的标签 | `{}` |
| `pgpool.networkPolicy.ingressNSPodMatchLabels` | 匹配以允许来自其他命名空间的流量的 Pod 标签 | `{}` |
| `pgpool.pdb.create` | 指定是否应为 Pgpool-II Pod 创建 Pod 中断预算 | `true` |
| `pgpool.pdb.minAvailable` | 应保持调度的最小 Pod 数量/百分比 | `""` |
| `pgpool.pdb.maxUnavailable` | 可能变得不可用的最大 Pod 数量/百分比。如果 `pgpool.pdb.minAvailable` 和 `pgpool.pdb.maxUnavailable` 都为空，则默认为 `1`。 | `""` |
| `pgpool.updateStrategy` | 用于用新 Pod 替换旧 Pod 的策略 | `{}` |
| `pgpool.containerPorts.postgresql` | Pgpool-II 端口 | `5432` |
| `pgpool.minReadySeconds` | 在更新期间，Pod 需要准备好的秒数，然后才能杀死下一个 | `""` |
| `pgpool.adminUsername` | Pgpool-II 管理员用户名 | `admin` |
| `pgpool.adminPassword` | Pgpool-II 管理员密码 | `""` |
| `pgpool.srCheckUsername` | Pgpool-II 流复制检查用户名 | `sr_check_user` |
| `pgpool.srCheckPassword` | Pgpool-II 流复制检查密码 | `""` |
| `pgpool.srCheckDatabase` | 执行流复制检查的数据库名称 | `postgres` |
| `pgpool.usePasswordFiles` | 设置为 `true` 以将 pgpool 密钥作为文件挂载，而不是传递环境变量 | `true` |
| `pgpool.authenticationMethod` | Pgpool 身份验证方法。对于 PSQL < 14，使用 'md5'。 | `scram-sha-256` |
| `pgpool.logConnections` | 记录所有客户端连接（PGPOOL_ENABLE_LOG_CONNECTIONS） | `false` |
| `pgpool.logHostname` | 记录客户端主机名而不是 IP 地址（PGPOOL_ENABLE_LOG_HOSTNAME） | `true` |
| `pgpool.logPcpProcesses` | 记录 PCP 进程（PGPOOL_ENABLE_LOG_PCP_PROCESSES） | `true` |
| `pgpool.logPerNodeStatement` | 为每个 DB 节点分别记录每个 SQL 语句（PGPOOL_ENABLE_LOG_PER_NODE_STATEMENT） | `false` |
| `pgpool.logLinePrefix` | 日志条目行的格式（PGPOOL_LOG_LINE_PREFIX） | `""` |
| `pgpool.clientMinMessages` | 客户端的日志级别 | `error` |
| `pgpool.numInitChildren` | 预分叉的 Pgpool-II 服务器进程的数量。这也是并发的 | `""` |
| `pgpool.reservedConnections` | 保留连接的数量。当为零时，多余的连接块。当非零时，多余的连接将被拒绝并显示错误消息。 | `1` |
| `pgpool.maxPool` | 每个子进程中缓存连接的最大数量（PGPOOL_MAX_POOL） | `""` |
| `pgpool.childMaxConnections` | 每个子进程中客户端连接的最大数量（PGPOOL_CHILD_MAX_CONNECTIONS） | `""` |
| `pgpool.childLifeTime` | 如果 Pgpool-II 子进程保持空闲，则终止它的时间（以秒为单位）（PGPOOL_CHILD_LIFE_TIME） | `""` |
| `pgpool.clientIdleLimit` | 如果客户端自上次查询以来保持空闲，则断开连接的时间（以秒为单位）（PGPOOL_CLIENT_IDLE_LIMIT） | `""` |
| `pgpool.connectionLifeTime` | 终止到 PostgreSQL 后端的缓存连接的时间（以秒为单位）（PGPOOL_CONNECTION_LIFE_TIME） | `""` |
| `pgpool.useConnectionCache` | 使用连接缓存（PGPOOL_ENABLE_CONNECTION_CACHE） | `true` |
| `pgpool.useLoadBalancing` | 使用 Pgpool-II 负载均衡 | `true` |
| `pgpool.disableLoadBalancingOnWrite` | 写入操作上的负载均衡器行为 | `transaction` |
| `pgpool.configuration` | Pgpool-II 配置 | `""` |
| `pgpool.poolHbaConfiguration` | Pgpool-II 客户端身份验证配置 | `""` |
| `pgpool.configurationCM` | 包含 Pgpool-II 配置的 ConfigMap | `""` |
| `pgpool.initdbScripts` | initdb 脚本字典 | `{}` |
| `pgpool.initdbScriptsCM` | 包含每次初始化 Pgpool-II 容器时运行的脚本的 ConfigMap | `""` |
| `pgpool.initdbScriptsSecret` | 包含每次初始化 Pgpool-II 容器时运行的脚本的 Secret | `""` |
| `pgpool.tls.enabled` | 为最终客户端连接启用 TLS 流量支持 | `false` |
| `pgpool.tls.autoGenerated` | 创建自签名 TLS 证书。目前仅支持 PEM 证书 | `false` |
| `pgpool.tls.preferServerCiphers` | 是否使用服务器的 TLS 密码首选项而不是客户端的 | `true` |
| `pgpool.tls.certificatesSecret` | 包含证书的现有密钥的名称 | `""` |
| `pgpool.tls.certFilename` | 证书文件名 | `""` |
| `pgpool.tls.certKeyFilename` | 证书密钥文件名 | `""` |
| `pgpool.tls.certCAFilename` | CA 证书文件名 | `""` |

### LDAP 参数

| 名称 | 描述 | 值 |
| --- | --- | --- |
| `ldap.enabled` | 启用 LDAP 支持 | `false` |
| `ldap.existingSecret` | 用于 LDAP 密码的现有密钥名称 | `""` |
| `ldap.uri` | 以 `ldap[s]://<hostname>:<port>` 形式开头的 LDAP URL | `""` |
| `ldap.basedn` | LDAP 基础 DN | `""` |
| `ldap.binddn` | LDAP 绑定 DN | `""` |
| `ldap.bindpw` | LDAP 绑定密码 | `""` |
| `ldap.bslookup` | LDAP 基础查找 | `""` |
| `ldap.scope` | LDAP 搜索范围 | `""` |
| `ldap.searchfilter` | LDAP 搜索过滤器 | `""` |
| `ldap.searchmap` | LDAP 搜索映射 | `""` |
| `ldap.tlsReqcert` | LDAP 对服务器证书的 TLS 检查 | `""` |
| `ldap.nssInitgroupsIgnoreusers` | LDAP 忽略的用户 | `root,nslcd` |

### 其他参数

| 名称 | 描述 | 值 |
| --- | --- | --- |
| `rbac.create` | 创建角色和角色绑定（PSP 工作所需） | `false` |
| `rbac.rules` | 要设置的自定义 RBAC 规则 | `[]` |
| `serviceAccount.create` | 指定是否应创建 ServiceAccount | `true` |
| `serviceAccount.name` | 要使用的 ServiceAccount 的名称。 | `""` |
| `serviceAccount.annotations` | ServiceAccount 的额外自定义注释 | `{}` |
| `serviceAccount.automountServiceAccountToken` | 允许在创建的 serviceAccount 上自动挂载 ServiceAccountToken | `false` |
| `psp.create` | 是否创建 PodSecurityPolicy。警告：PodSecurityPolicy 在 Kubernetes v1.21 或更高版本中已弃用，在 v1.25 或更高版本中不可用 | `false` |

### 指标参数

| 名称 | 描述 | 值 |
| --- | --- | --- |
| `metrics.enabled` | 启用 PostgreSQL Prometheus 导出器 | `false` |
| `metrics.image.registry` | PostgreSQL Prometheus 导出器镜像仓库 | `REGISTRY_NAME` |
| `metrics.image.repository` | PostgreSQL Prometheus 导出器镜像仓库 | `REPOSITORY_NAME/postgres-exporter` |
| `metrics.image.digest` | PostgreSQL Prometheus 导出器镜像摘要，格式为 sha256:aa.... 请注意，如果设置此参数，将覆盖标签 | `""` |
| `metrics.image.pullPolicy` | PostgreSQL Prometheus 导出器镜像拉取策略 | `IfNotPresent` |
| `metrics.image.pullSecrets` | 指定 docker-registry 密钥名称数组 | `[]` |
| `metrics.image.debug` | 指定是否应启用调试日志 | `false` |
| `metrics.podSecurityContext.enabled` | 为 PostgreSQL Prometheus 导出器启用安全上下文 | `true` |
| `metrics.podSecurityContext.seLinuxOptions` | 在容器中设置 SELinux 选项 | `{}` |
| `metrics.podSecurityContext.runAsUser` | PostgreSQL Prometheus 导出器容器的用户 ID | `1001` |
| `metrics.podSecurityContext.runAsGroup` | PostgreSQL Prometheus 导出器容器的组 ID | `1001` |
| `metrics.podSecurityContext.runAsNonRoot` | 设置 PostgreSQL Prometheus 导出器容器的安全上下文 runAsNonRoot | `true` |
| `metrics.podSecurityContext.seccompProfile.type` | 设置 PostgreSQL Prometheus 导出器容器的安全上下文 seccompProfile | `RuntimeDefault` |
| `metrics.resourcesPreset` | 根据一个通用预设设置容器资源（允许的值：none、nano、micro、small、medium、large、xlarge、2xlarge）。如果设置了 metrics.resources，则忽略此设置（生产环境推荐使用 metrics.resources）。 | `nano` |
| `metrics.resources` | 为不同资源（如 CPU 或内存）设置容器请求和限制（生产工作负载必需） | `{}` |
| `metrics.containerPorts.http` | Prometheus 指标导出器端口 | `9187` |
| `metrics.livenessProbe.enabled` | 启用存活探针 | `true` |
| `metrics.livenessProbe.initialDelaySeconds` | 存活探针的初始延迟秒数 | `30` |
| `metrics.livenessProbe.periodSeconds` | 存活探针的周期秒数 | `10` |
| `metrics.livenessProbe.timeoutSeconds` | 存活探针的超时秒数 | `5` |
| `metrics.livenessProbe.failureThreshold` | 存活探针的失败阈值 | `6` |
| `metrics.livenessProbe.successThreshold` | 存活探针的成功阈值 | `1` |
| `metrics.readinessProbe.enabled` | 启用就绪探针 | `true` |
| `metrics.readinessProbe.initialDelaySeconds` | 就绪探针的初始延迟秒数 | `5` |
| `metrics.readinessProbe.periodSeconds` | 就绪探针的周期秒数 | `10` |
| `metrics.readinessProbe.timeoutSeconds` | 就绪探针的超时秒数 | `5` |
| `metrics.readinessProbe.failureThreshold` | 就绪探针的失败阈值 | `6` |
| `metrics.readinessProbe.successThreshold` | 就绪探针的成功阈值 | `1` |
| `metrics.startupProbe.enabled` | 启用启动探针 | `false` |
| `metrics.startupProbe.initialDelaySeconds` | 启动探针的初始延迟秒数 | `5` |
| `metrics.startupProbe.periodSeconds` | 启动探针的周期秒数 | `10` |
| `metrics.startupProbe.timeoutSeconds` | 启动探针的超时秒数 | `5` |
| `metrics.startupProbe.failureThreshold` | 启动探针的失败阈值 | `10` |
| `metrics.startupProbe.successThreshold` | 启动探针的成功阈值 | `1` |
| `metrics.customLivenessProbe` | 覆盖默认存活探针 | `{}` |
| `metrics.customReadinessProbe` | 覆盖默认就绪探针 | `{}` |
| `metrics.customStartupProbe` | 覆盖默认启动探针 | `{}` |
| `metrics.service.enabled` | PostgreSQL Prometheus 导出器指标服务已启用 | `true` |
| `metrics.service.type` | PostgreSQL Prometheus 导出器指标服务类型 | `ClusterIP` |
| `metrics.service.ports.metrics` | PostgreSQL Prometheus 导出器指标服务端口 | `9187` |
| `metrics.service.nodePorts.metrics` | PostgreSQL Prometheus 导出器节点端口 | `""` |
| `metrics.service.clusterIP` | PostgreSQL Prometheus 导出器指标服务集群 IP | `""` |
| `metrics.service.loadBalancerIP` | PostgreSQL Prometheus 导出器服务负载均衡器 IP | `""` |
| `metrics.service.loadBalancerSourceRanges` | PostgreSQL Prometheus 导出器服务负载均衡器源 | `[]` |
| `metrics.service.externalTrafficPolicy` | PostgreSQL Prometheus 导出器服务外部流量策略 | `Cluster` |
| `metrics.annotations` | PostgreSQL Prometheus 导出器服务的注释 | `{}` |
| `metrics.customMetrics` | 额外的自定义指标 | `{}` |
| `metrics.extraEnvVars` | 包含额外环境变量的数组 | `[]` |
| `metrics.extraEnvVarsCM` | 包含额外环境变量的 ConfigMap | `""` |
| `metrics.extraEnvVarsSecret` | 包含额外环境变量的 Secret | `""` |
| `metrics.serviceMonitor.enabled` | 如果为 `true`，则创建 Prometheus Operator ServiceMonitor（还需要 `metrics.enabled` 为 `true`） | `false` |
| `metrics.serviceMonitor.namespace` | Prometheus 运行的可选命名空间 | `""` |
| `metrics.serviceMonitor.interval` | 抓取指标的频率（默认使用，回退到 Prometheus 的默认值） | `""` |
| `metrics.serviceMonitor.scrapeTimeout` | 服务监控抓取超时 | `""` |
| `metrics.serviceMonitor.annotations` | ServiceMonitor 的额外注释 | `{}` |
| `metrics.serviceMonitor.labels` | 可以使用的额外标签，以便 Prometheus 发现 ServiceMonitor | `{}` |
| `metrics.serviceMonitor.selector` | 如果遵循 CoreOS Prometheus 安装说明（<https://github.com/bitnami/charts/tree/main/bitnami/kube-prometheus#tldr>），则默认使用 | `{}` |
| `metrics.serviceMonitor.relabelings` | ServiceMonitor 重新标记。值作为模板评估 | `[]` |
| `metrics.serviceMonitor.metricRelabelings` | ServiceMonitor metricRelabelings。值作为模板评估 | `[]` |
| `metrics.serviceMonitor.honorLabels` | 指定 honorLabels 参数以添加抓取端点 | `false` |
| `metrics.serviceMonitor.jobLabel` | 目标服务上用作 prometheus 中作业名称的标签名称。 | `""` |

### 卷权限参数

| 名称 | 描述 | 值 |
| --- | --- | --- |
| `volumePermissions.enabled` | 启用初始化容器以调整卷权限 | `false` |
| `volumePermissions.image.registry` | 初始化容器卷权限镜像仓库 | `REGISTRY_NAME` |
| `volumePermissions.image.repository` | 初始化容器卷权限镜像仓库 | `REPOSITORY_NAME/os-shell` |
| `volumePermissions.image.digest` | 初始化容器卷权限镜像摘要，格式为 sha256:aa.... 请注意，如果设置此参数，将覆盖标签 | `""` |
| `volumePermissions.image.pullPolicy` | 初始化容器卷权限镜像拉取策略 | `IfNotPresent` |
| `volumePermissions.image.pullSecrets` | 指定 docker-registry 密钥名称数组 | `[]` |
| `volumePermissions.podSecurityContext.enabled` | 是否为卷权限初始化容器启用安全上下文 | `true` |
| `volumePermissions.podSecurityContext.seLinuxOptions` | 在容器中设置 SELinux 选项 | `{}` |
| `volumePermissions.podSecurityContext.runAsUser` | 初始化容器卷权限用户 ID | `0` |
| `volumePermissions.podSecurityContext.runAsGroup` | 初始化容器卷权限容器的组 ID | `0` |
| `volumePermissions.podSecurityContext.runAsNonRoot` | 为初始化容器卷权限容器设置安全上下文 runAsNonRoot | `false` |
| `volumePermissions.podSecurityContext.seccompProfile.type` | 为初始化容器卷权限容器设置安全上下文 seccompProfile | `RuntimeDefault` |
| `volumePermissions.resourcesPreset` | 根据一个通用预设设置容器资源（允许的值：none、nano、micro、small、medium、large、xlarge、2xlarge）。如果设置了 volumePermissions.resources，则忽略此设置（生产环境推荐使用 volumePermissions.resources）。 | `nano` |
| `volumePermissions.resources` | 为不同资源（如 CPU 或内存）设置容器请求和限制（生产工作负载必需） | `{}` |

### 持久化参数

| 名称 | 描述 | 值 |
| --- | --- | --- |
| `persistence.enabled` | 启用数据持久化 | `true` |
| `persistence.existingClaim` | 手动管理的持久化卷和声明 | `""` |
| `persistence.storageClass` | 持久化卷存储类 | `""` |
| `persistence.mountPath` | 卷将挂载的路径，使用不同的 PostgreSQL 镜像时有用。 | `/bitnami/postgresql` |
| `persistence.accessModes` | 数据卷的访问模式列表 | `["ReadWriteOnce"]` |
| `persistence.size` | 持久化卷声明大小 | `8Gi` |
| `persistence.annotations` | 持久化卷声明注释 | `{}` |
| `persistence.labels` | 持久化卷声明标签 | `{}` |
| `persistence.selector` | 选择器以匹配现有的持久化卷（此值作为模板评估） | `{}` |
| `persistentVolumeClaimRetentionPolicy.enabled` | 为 postgresql Statefulset 启用持久化卷保留策略 | `false` |
| `persistentVolumeClaimRetentionPolicy.whenScaled` | 当 StatefulSet 的副本计数减少时的卷保留行为 | `Retain` |
| `persistentVolumeClaimRetentionPolicy.whenDeleted` | 当 StatefulSet 被删除时应用的卷保留行为 | `Retain` |

### 流量暴露参数

| 名称 | 描述 | 值 |
| --- | --- | --- |
| `service.type` | Kubernetes 服务类型（`ClusterIP`、`NodePort` 或 `LoadBalancer`） | `ClusterIP` |
| `service.ports.postgresql` | PostgreSQL 端口 | `5432` |
| `service.portName` | PostgreSQL 服务端口名称 | `postgresql` |
| `service.nodePorts.postgresql` | Kubernetes 服务 nodePort | `""` |
| `service.loadBalancerIP` | 如果服务类型是 `LoadBalancer`，则为负载均衡器 IP | `""` |
| `service.loadBalancerSourceRanges` | 服务是 LoadBalancer 时允许的地址 | `[]` |
| `service.clusterIP` | 设置要使用的集群 IP | `""` |
| `service.externalTrafficPolicy` | 启用客户端源 IP 保留 | `Cluster` |
| `service.extraPorts` | 要暴露的额外端口（通常与 `sidecar` 值一起使用） | `[]` |
| `service.sessionAffinity` | 控制客户端请求的去向，到同一个 Pod 或轮询 | `None` |
| `service.sessionAffinityConfig` | sessionAffinity 的额外设置 | `{}` |
| `service.annotations` | 为 PostgreSQL 和 Pgpool-II 服务提供任何额外的注释 | `{}` |
| `service.serviceLabels` | PostgreSQL 服务的标签 | `{}` |
| `service.headless.annotations` | 无头服务的注释。 | `{}` |

### 备份参数

| 名称 | 描述 | 值 |
| --- | --- | --- |
| `backup.enabled` | 启用数据库的"定期"逻辑转储 | `false` |
| `backup.cronjob.schedule` | 设置 cronjob 参数 schedule | `@daily` |
| `backup.cronjob.timeZone` | 设置 cronjob 参数 timeZone | `""` |
| `backup.cronjob.concurrencyPolicy` | 设置 cronjob 参数 concurrencyPolicy | `Allow` |
| `backup.cronjob.failedJobsHistoryLimit` | 设置 cronjob 参数 failedJobsHistoryLimit | `1` |
| `backup.cronjob.successfulJobsHistoryLimit` | 设置 cronjob 参数 successfulJobsHistoryLimit | `3` |
| `backup.cronjob.startingDeadlineSeconds` | 设置 cronjob 参数 startingDeadlineSeconds | `""` |
| `backup.cronjob.ttlSecondsAfterFinished` | 设置 cronjob 参数 ttlSecondsAfterFinished | `""` |
| `backup.cronjob.restartPolicy` | 设置 cronjob 参数 restartPolicy | `OnFailure` |
| `backup.cronjob.podSecurityContext.enabled` | 为 CronJob/备份启用 PodSecurityContext | `true` |
| `backup.cronjob.podSecurityContext.fsGroupChangePolicy` | 设置文件系统组更改策略 | `Always` |
| `backup.cronjob.podSecurityContext.sysctls` | 使用 sysctl 接口设置内核设置 | `[]` |
| `backup.cronjob.podSecurityContext.supplementalGroups` | 设置文件系统额外组 | `[]` |
| `backup.cronjob.podSecurityContext.fsGroup` | CronJob 的组 ID | `1001` |
| `backup.cronjob.containerSecurityContext.enabled` | 启用容器安全上下文 | `true` |
| `backup.cronjob.containerSecurityContext.seLinuxOptions` | 在容器中设置 SELinux 选项 | `{}` |
| `backup.cronjob.containerSecurityContext.runAsUser` | 备份容器的用户 ID | `1001` |
| `backup.cronjob.containerSecurityContext.runAsGroup` | 备份容器的组 ID | `1001` |
| `backup.cronjob.containerSecurityContext.runAsNonRoot` | 设置备份容器的安全上下文 runAsNonRoot | `true` |
| `backup.cronjob.containerSecurityContext.readOnlyRootFilesystem` | 容器本身是否只读 | `true` |
| `backup.cronjob.containerSecurityContext.allowPrivilegeEscalation` | 是否可以提升备份 Pod 的权限 | `false` |
| `backup.cronjob.containerSecurityContext.seccompProfile.type` | 设置备份容器的安全上下文 seccompProfile 类型 | `RuntimeDefault` |
| `backup.cronjob.containerSecurityContext.capabilities.drop` | 设置备份容器的安全上下文要删除的功能 | `["ALL"]` |
| `backup.cronjob.command` | 设置备份容器要运行的命令 | `["/bin/bash","-c","PGPASSWORD=\"${PGPASSWORD:-$(< \"$PGPASSWORD_FILE\")}\" pg_dumpall --clean --if-exists --load-via-partition-root --quote-all-identifiers --no-password --file=\"${PGDUMP_DIR}/pg_dumpall-$(date '+%Y-%m-%d-%H-%M').pgdump\""]` |
| `backup.cronjob.labels` | 设置 cronjob 标签 | `{}` |
| `backup.cronjob.annotations` | 设置 cronjob 注释 | `{}` |
| `backup.cronjob.nodeSelector` | PostgreSQL 备份 CronJob Pod 分配的节点标签 | `{}` |
| `backup.cronjob.tolerations` | PostgreSQL 备份 CronJob Pod 分配的容忍度 | `[]` |
| `backup.cronjob.podAffinityPreset` | PostgreSQL 备份 Pod 亲和性预设。如果设置了 `backup.cronjob.affinity`，则忽略。允许的值：`soft` 或 `hard` | `""` |
| `backup.cronjob.nodeAffinityPreset.type` | PostgreSQL 备份节点亲和性预设类型。如果设置了 `backup.cronjob.affinity`，则忽略。允许的值：`soft` 或 `hard` | `""` |
| `backup.cronjob.nodeAffinityPreset.key` | 要匹配的 PostgreSQL 备份节点标签键。如果设置了 `backup.cronjob.affinity`，则忽略。 | `""` |
| `backup.cronjob.nodeAffinityPreset.values` | 要匹配的 PostgreSQL 备份节点标签值。如果设置了 `backup.cronjob.affinity`，则忽略。 | `[]` |
| `backup.cronjob.affinity` | PostgreSQL 备份 Pod 分配的亲和性 | `{}` |
| `backup.cronjob.resourcesPreset` | 根据一个通用预设设置容器资源（允许的值：none、nano、micro、small、medium、large、xlarge、2xlarge）。如果设置了 backup.cronjob.resources，则忽略此设置（生产环境推荐使用 backup.cronjob.resources）。 | `nano` |
| `backup.cronjob.resources` | 为不同资源（如 CPU 或内存）设置容器请求和限制 | `{}` |
| `backup.cronjob.extraEnvVars` | 包含额外环境变量的数组 | `[]` |
| `backup.cronjob.extraEnvVarsCM` | 包含额外环境变量的 ConfigMap | `""` |
| `backup.cronjob.extraEnvVarsSecret` | 包含额外环境变量的 Secret | `""` |
| `backup.cronjob.extraVolumes` | 添加到备份容器的额外卷 | `[]` |
| `backup.cronjob.extraVolumeMounts` | 添加到备份容器的额外卷挂载。通常与 `extraVolumes` 一起使用 | `[]` |
| `backup.cronjob.storage.existingClaim` | 提供现有的 `PersistentVolumeClaim`（仅当 `architecture=standalone` 时） | `""` |
| `backup.cronjob.storage.resourcePolicy` | 将其设置为 "keep" 以避免在 helm 删除操作期间删除 PVC。留空将在图表删除后删除 PVC | `""` |
| `backup.cronjob.storage.storageClass` | 备份数据卷的 PVC 存储类 | `""` |
| `backup.cronjob.storage.accessModes` | PV 访问模式 | `["ReadWriteOnce"]` |
| `backup.cronjob.storage.size` | 备份数据卷的 PVC 存储请求 | `8Gi` |
| `backup.cronjob.storage.annotations` | PVC 注释 | `{}` |
| `backup.cronjob.storage.mountPath` | 挂载卷的路径 | `/backup/pgdump` |
| `backup.cronjob.storage.subPath` | 要挂载的卷的子目录 | `""` |
| `backup.cronjob.storage.volumeClaimTemplates.selector` | 对卷的标签查询，以考虑绑定（例如，使用本地卷时） | `{}` |

使用 `--set key=value[,key=value]` 参数为 `helm install` 指定每个参数。例如，

```console
helm install my-release \
    --set postgresql.password=password \
    oci://REGISTRY_NAME/REPOSITORY_NAME/postgresql-ha
```

> 注意：您需要将占位符 `REGISTRY_NAME` 和 `REPOSITORY_NAME` 替换为对 Helm 图表仓库和仓库的引用。例如，在 Bitnami 的情况下，您需要使用 `REGISTRY_NAME=registry-1.docker.io` 和 `REPOSITORY_NAME=bitnamicharts`。

上述命令将用户 `postgres` 的密码设置为 `password`。

> 注意：部署此图表后，无法使用 Helm 更改应用程序的访问凭据，如用户名或密码。要在部署后更改这些应用程序凭据，请删除图表使用的任何持久化卷（PV）并重新部署，或者如果可用，使用应用程序的内置管理工具。

或者，可以在安装图表时提供指定上述参数值的 YAML 文件。例如，

```console
helm install my-release \
    -f values.yaml \
    bitnami/postgresql-ha
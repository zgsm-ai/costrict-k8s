# postgresql-ha 

pgsql 高可用版本，相关配置项参考 [./pgsql-README.md](./pgsql-READEME.md) 参数翻译版本：[./pgsql-REAMEME_zh-CN.md](./pgsql-REAMEME_zh-CN.md) 

## 一些运维语句

管理员用户运行


获取节点情况
```sql
SELECT * FROM repmgr.nodes;
```

获取连接情况，用于调参

```sql
SHOW pool_pools;          -- 每个子池的 in-use/free 数量
SHOW pool_nodes;          -- 后端节点状态及 running_connections
SHOW pool_processes;      -- 当前所有客户端连接详情（PID、数据库、用户、状态）
```
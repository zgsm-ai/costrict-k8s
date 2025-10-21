# postgresql-ha 

pgsql 高可用版本，相关配置项参考 [./pgsql-README.md](./pgsql-READEME.md) 参数翻译版本：[./pgsql-REAMEME_zh-CN.md](./pgsql-REAMEME_zh-CN.md) 

## 一些运维语句

管理员用户运行


获取节点情况
```sql
SELECT * FROM repmgr.nodes;
```
## Helm Charts Release

### 下载选项

📦 **all.tar** - 包含所有 Helm charts 的完整打包文件
- 适合一次性下载所有 charts
- 解压后可获得所有单独的 .tgz 文件

📋 **单独的 .tgz 文件** - 各个 Helm charts 的独立包
- 适合只需要特定 chart 的用户
- 可以选择性下载需要的 chart

---

### 使用说明

下载 all.tar 后解压：
```bash
tar -xvf all.tar
```

安装单个 chart：
```bash
helm install chart-name chart-name.tgz -v values.yaml
```

## Helm Charts Release

### 下载选项

📦 **all.tar** - 包含所有 Helm charts 的完整打包文件
- 适合一次性下载所有 charts
- 解压后可获得所有单独的 .tgz 文件

📦 **单独的 k8s-deploy.zip 文件** -  部署所需的所有文件

- 包含所有 Helm charts 的完整打包文件, 不包含各种镜像


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

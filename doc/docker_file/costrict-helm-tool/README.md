# 创建一个容器，用于运行python和helm,对于没有这些环境的用户来说很重要。

预构建镜像

请在当前目录运行

```shell
wget https://get.helm.sh/helm-v3.18.6-linux-amd64.tar.gz
tar -zxf helm-v3.18.6-linux-amd64.tar.gz
docker build -t costrict-helm:v1 -f Dockerfile .
```

运行

请到项目根目录运行
```shell
docker run -d \
  --network host \
  --name costrict-helm \
  -v $(which kubectl):/usr/local/bin/kubectl:ro \
  -v /etc/kubernetes:/etc/kubernetes:ro \
  -v ${PWD}:/app \
  -e KUBECONFIG=/etc/kubernetes/admin.conf \
  -v ~/.kube:/root/.kube:ro \
  costrict-helm:v1
  
docker exec -it costrict-helm /bin/bash

```
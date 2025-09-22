
## Ready images

pull & push higress images.

```shell
docker pull higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/console:2.1.6
docker pull higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/higress:2.1.6
docker pull higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/gateway:2.1.6
docker pull higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/grafana:9.3.6
docker pull higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/loki:2.9.4
docker pull higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/prometheus:v2.40.7
docker pull higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/pilot:2.1.6

docker tag higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/gateway:2.1.6 zgsm/higress-gateway:2.1.6
docker pull higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/higress:2.1.6 zgsm/higress-higress:2.1.6
docker tag higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/console:2.1.6 zgsm/higress-console:2.1.6
docker tag higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/loki:2.9.4 zgsm/higress-loki:2.9.4
docker tag higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/grafana:9.3.6 zgsm/higress-grafana:9.3.6
docker tag higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/prometheus:v2.40.7 zgsm/higress-prometheus:v2.40.7
docker tag higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/pilot:2.1.6 zgsm/higress-pilot:2.1.6

docker push zgsm/higress-gateway:2.1.6
docker push zgsm/higress-higress:2.1.6
docker push zgsm/higress-console:2.1.6
docker push zgsm/higress-loki:2.9.4
docker push zgsm/higress-grafana:9.3.6
docker push zgsm/higress-prometheus:v2.40.7
docker push zgsm/higress-pilot:2.1.6

```
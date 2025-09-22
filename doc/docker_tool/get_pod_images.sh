#!/bin/bash

# 脚本：获取指定命名空间下所有 Pod 的镜像（去重）
# 用法：./get_pod_images.sh <namespace>
# 如果未提供命名空间，则默认为当前上下文的命名空间或 "default"

# 检查 kubectl 是否安装
if ! command -v kubectl &> /dev/null; then
    echo "错误：kubectl 未安装或未在 PATH 中"
    exit 1
fi

# 获取命名空间参数
NAMESPACE="$1"

# 如果未提供命名空间，则尝试获取当前上下文的命名空间，否则使用 default
if [ -z "$NAMESPACE" ]; then
    NAMESPACE=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
    if [ -z "$NAMESPACE" ]; then
        NAMESPACE="default"
    fi
    echo "未指定命名空间，使用: $NAMESPACE"
else
    echo "使用命名空间: $NAMESPACE"
fi

# 检查命名空间是否存在
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    echo "错误：命名空间 '$NAMESPACE' 不存在"
    exit 1
fi

# 获取所有 Pod 的镜像并去重
echo "正在获取命名空间 '$NAMESPACE' 下所有 Pod 的镜像..."

IMAGES=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].spec.containers[*].image}' 2>/dev/null)

if [ -z "$IMAGES" ]; then
    echo "在命名空间 '$NAMESPACE' 中未找到任何 Pod 或镜像。"
    exit 0
fi

# 将镜像列表转换为每行一个，并去重排序
echo "$IMAGES" | tr ' ' '\n' | sort -u

echo "共找到 $(echo "$IMAGES" | tr ' ' '\n' | sort -u | wc -l) 个唯一的镜像。"

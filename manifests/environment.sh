#!/usr/bin/bash

# 生成 EncryptionConfig 所需的加密 key
export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)


# 声明节点map
declare -A MASTER_NODES WORKER_NODES ALL_NODES OTHER_MASTER_NODES OTHER_NODES
MASTER_NODES=(['k8s-m1']="10.1.80.71" ['k8s-m2']="10.1.80.72" ['k8s-m3']="10.1.80.73")
WORKER_NODES=(['k8s-n1']="10.1.80.74")

# 集群所有节点数组
for node_name in ${!MASTER_NODES[@]}; do
  ALL_NODES[$node_name]=${MASTER_NODES[$node_name]}
done

for node_name in ${!WORKER_NODES[@]}; do
  ALL_NODES[$node_name]=${WORKER_NODES[$node_name]}
done

# 集群内除k8s-m1外的所有节点
for node_name in ${!ALL_NODES[@]}; do
 OTHER_NODES[$node_name]=${ALL_NODES[$node_name]}
done
unset OTHER_NODES['k8s-m1']

# 集群内除k8s-m1外的所有Master节点
for node_name in ${!MASTER_NODES[@]}; do
 OTHER_MASTER_NODES[$node_name]=${MASTER_NODES[$node_name]}
done
unset OTHER_MASTER_NODES['k8s-m1']

# etcd 集群服务地址列表
export ETCD_ENDPOINTS="https://10.1.80.71:2379,https://10.1.80.72:2379,https://10.1.80.73:2379"

# etcd 集群间通信的 IP 和端口
export ETCD_NODES="k8s-m1=https://10.1.80.71:2380,k8s-m2=https://10.1.80.72:2380,k8s-m3=https://10.1.80.73:2380"

# kube-apiserver 的 VIP（HA 组件 keepalived 发布的 IP）
export MASTER_VIP=10.1.80.77

# kube-apiserver VIP 地址（HA 组件 haproxy 监听 8443 端口）
export KUBE_APISERVER="https://${MASTER_VIP}:8443"

# 节点间互联网络接口名称
export IFACE="enp0s3"

# etcd 数据目录
export ETCD_DATA_DIR="/data/k8s/etcd/data"

# etcd WAL 目录，建议是 SSD 磁盘分区，或者和 ETCD_DATA_DIR 不同的磁盘分区
export ETCD_WAL_DIR="/data/k8s/etcd/wal"

# k8s 各组件数据目录
export K8S_DIR="/data/k8s/k8s"

# docker 数据目录
export DOCKER_DIR="/data/k8s/docker"

## 以下参数一般不需要修改

# TLS Bootstrapping 使用的 Token，可以使用命令 head -c 16 /dev/urandom | od -An -t x | tr -d ' ' 生成
BOOTSTRAP_TOKEN="41f7e4ba8b7be874fcff18bf5cf41a7c"

# 最好使用 当前未用的网段 来定义服务网段和 Pod 网段

# 服务网段，部署前路由不可达，部署后集群内路由可达(kube-proxy 保证)
SERVICE_CIDR="10.254.0.0/16"

# Pod 网段，建议 /16 段地址，部署前路由不可达，部署后集群内路由可达(flanneld 保证)
CLUSTER_CIDR="172.30.0.0/16"

# 服务端口范围 (NodePort Range)
export NODE_PORT_RANGE="30000-32767"

# flanneld 网络配置前缀
export FLANNEL_ETCD_PREFIX="/kubernetes/network"

# kubernetes 服务 IP (一般是 SERVICE_CIDR 中第一个IP)
export CLUSTER_KUBERNETES_SVC_IP="10.254.0.1"

# 集群 DNS 服务 IP (从 SERVICE_CIDR 中预分配)
export CLUSTER_DNS_SVC_IP="10.254.0.2"

# 集群 DNS 域名（末尾不带点号）
export CLUSTER_DNS_DOMAIN="cluster.local"


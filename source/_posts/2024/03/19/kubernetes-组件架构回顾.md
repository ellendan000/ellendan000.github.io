---
title: kubernetes 组件架构回顾
top: false
cover: false
toc: true
date: 2024-03-19 17:09:16
img:
coverImg:
password:
keywords:
tags:
categories:
---

前面回顾了 Kubernetes 的逻辑概念模型和使用，这篇主要回顾一下 Kubernetes 的组件架构。  
之前提到 Kubernetes 将集群中的机器划分为至少一个 Master 节点和一群 Node 节点。  

Master 节点上：  
- 需要预安装 `docker` 和 `kubectl` 程序（运行 Pod 的必需环境）。
- 以 static pod 的方式（使用 kubectl 命令安装）运行`Kube-apiserver`、`kube-contoller-manager`、`kube-scheduler`，这些进程实现了整个集群的资源管理、安全控制、系统监控、Pod调度、弹性伸缩等管理功能。
- 集群数据集中存储在 `etcd` 键值存储库中，为了防止单点故障、进行高可用考虑，可将 etcd 以集群方式部署。
- 网络组件：`kube-proxy`、`flannel`(如果使用 Minikube，Minikube 中使用的网络组件是kindnet，此组件只适合用于开发和测试)

Node 节点上：  
- 需要预安装 `docker` 和 `kubectl` 程序。
- 网络组件：`kube-proxy`、`flannel`。

![Kubernetes components](./kubernetes-组件架构回顾/kubernetes-components.png)

__control-panel__: 除 Node 工作节点外，Master 节点代表的集群控制面角色也被成为`control-panel`。  
PV（持久卷）是 Kubernetes 集群的资源之一，但并非是安装 Node 和 Master 上，由一些网络磁盘、块或者文件系统提供，然后被控制面进行 PV Provisioning，由 PVC（PersistentVolumeClaim）申请对PV的使用，最后通过 PVC 挂载到 Pod 上以供容器使用。  









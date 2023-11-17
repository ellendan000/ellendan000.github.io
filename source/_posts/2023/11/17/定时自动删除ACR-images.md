---
title: 定时自动删除ACR images
top: false
cover: false
toc: false
date: 2023-11-17 22:46:56
img:
coverImg:
password:
keywords:
tags:
    - Azure
    - 云平台
categories:
    - Azure
---

在之前 Azure App Service 部署时，使用到了 Azure Container Register，对于许多项目而言，超过一定时限的历史 images 再次使用的几率近乎为零。
因此，无论从制品管理，还是存储成本，定期清除不使用的 images是一项常见的任务。
可以使用 Azure 提供的工具 acr purge 和 acr task 来达成该目标。

#### 1. 命令创建定时 ACR task
运行以下命令（使用Azure cli 或者 Azure cloud shell皆可）。
```
$ PURGE_CMD="acr purge --filter '.*:.*' --ago 14d --untagged"
$ az acr task create --name purgeTask \
    --cmd "$PURGE_CMD" \
    --schedule "0 1 * * *" \
    --registry <register-name> \
    --context /dev/null
```

#### 2. 查看 task runs
命令：
```
$ az acr task list-runs --name purgeTask --registry <register-name> --output table
```

#### 3. 也可以单次手动触发 ACR purge
```
$ PURGE_CMD="acr purge --filter '.*:.*' --ago 14d --untagged"
$ az acr run --cmd "$PURGE_CMD" --registry <register-name> /dev/null
```

#### 相关链接
- [教程：按定义的计划运行 ACR 任务](https://learn.microsoft.com/zh-cn/azure/container-registry/container-registry-tasks-scheduled)
- [自动清除 Azure 容器注册表中的映像](https://learn.microsoft.com/zh-cn/azure/container-registry/container-registry-auto-purge)

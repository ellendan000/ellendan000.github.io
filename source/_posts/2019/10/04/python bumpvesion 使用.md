---
title: python bumpvesion 使用
date: 2019-10-04 12:52:00  
tags: 
    - Python
categories: 
    - Python
---

python library project升级版本的工具。  
[开发者上手说明](https://pypi.org/project/bumpversion/)

这里按 source version control的项目配置进行说明。
1. 安装 bumpverson
```
pipenv install bumpversion --dev
```

2. 添加配置文件`.bumpversion.cfg`，并加入版本管理。  
配置文件内容：
```
[bumpversion]
current_version = 0.1.1
commit = True
tag = True

[bumpversion:file:setup.py]

[bumpversion:file:package_name/__init__.py]
```
上面一个[]下面是针对一个 section 的详细配置。  
如，有两个需要控制 verion num 的地方，则要配置两个[bumpversion:file:...] section。  
`current_version = 0.1.1` 记录当前的版本是 0.0.1。  
`commit = True` bump 的时候会自动生成一条 commit。可以配置 commit msg 格式。  
`tag = True` bump 的时候自动打 tag。  
具体每一项详细配置可见官方说明。  

3. 运行 bumpversion 命令。
```
pipenv shell
bumpversion <part>
```
part 默认主要是 **major**、**minor**、**patch**。  
输入对应的 part，bumpversion 会对应的进行 version 升级。  
比如：`bumpversion major`, 按上面的配置，version 会由`0.1.1`升级为`1.0.0`。

4. push commits/tags。
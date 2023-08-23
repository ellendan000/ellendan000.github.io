---
title: Docker学习笔记
date: 2016-11-08 19:49:00  
tags: 
    - Docker
    - DevOps
categories: 
    - Docker  
---


本地用的Docker for Mac，使用[official tutorial](https://docs.docker.com/docker-for-mac/) 进行前期安装工作。

安装好后，运行第一个命令 `docker --version`
> Docker version 1.12.1, build 6f9534c 

官方文档上面一直提到一个Docker Toolbox，是针对不满足Docker for Mac的系统配置要求"_macOS 10.10.3 Yosemite or newer_"，则建议安装Docker Toolbox。

### 如何运行 container
#### 1. 简单运行起来一个container。  
从 Docker hub 上搜索一个 image。
```
$ docker search hello-world
```

从 Docker hub 上 pull 一个 image。
```
$ docker pull hello-world
```

基于 image 运行一个 container。
```
$ docker run hello-world
```

#### 2. 其实用一条命令就直接完成上面的三项：**docker run hello-world**  
运行**docker run**的时候，docker engine其实做了三个动作： 
 - 检查本地是否有 hello-world 的 image
 - 如果本地没有，从 Docker hub 下载 hello-world 的 image（不只是Docker hub上）
 - 加载 image 去运行一个 container

#### 3. 列举出所有 container 和 image  
显示所有运行中的 container
```
$ docker ps
```

显示所有被创建的 container
```
$ docker ps -a
```

显示最近一个被创建的 container
```
$ docker ps -l
```

显示本地所有 image
```
$ docker images
```

#### 4. image 和 container 的定义
>Docker Engine provides the core Docker technology that enables images and containers. 
An image is a filesystem and parameters to use at runtime. It doesn’t have state and never changes. A container is a running instance of an image.

#### 5. 在 container 内运行命令
```
$ docker run ubuntu echo "hello word"
```
通常当命令执行完毕时，container 即会停止。

```
$ docker run -t -i ubuntu /bin/bash
```
host 运行一个 container，并且打开一条交互连接。
> **-t** flag assigns a pseudo-tty or terminal inside the new container.  
**-i** flag allows you to make an interactive connection by grabbing the standard input (STDIN) of the container.  

```
$ docker run -d ubuntu /bin/sh -c "while true; do echo hello world; sleep 1; done"
```
用后台进程的形式运行命令。
>-d flag runs the container in the background (to daemonize it).  

__注意：如果不指定 contrainer name，docker 将自动生成 container name。__

#### 6. 查看指定 container 的标准输出信息
```
$ docker logs <containerId>[<containerName>]
$ docker logs -f <containerId>[<containerName>] //-f 效果同tail -f
```

#### 7. 停止/启动/删除container  
```
$ docker stop <containerID>[<containerName>]
$ docker start <containerID>[<containerName>]
$ docker rm <containerID>[<containerName>]
```

### 如何创建 Image
> There are two ways you can update and create images.  
You can update a container created from an image and commit the results to an image.  
You can use a Dockerfile to specify instructions to create an image.  

#### 1. 第一种，更新一个 image 并且 commit。
```
# 创建&运行一个container，并开启交互模式
$ docker run -t -i training/sinatra /bin/bash

# 进入container terminal bash，安装ruby，安装包，退出
root@0b2616b0e5a8:/# apt-get install -y ruby2.0-dev ruby2.0
root@0b2616b0e5a8:/# gem2.0 install json
root@0b2616b0e5a8:/# exit

# 提交变更，-m message/ -a author，containerId， commit后的image name
$ docker commit -m "Added json gem" -a "Kate Smith" 0b2616b0e5a8 ouruser/sinatra:v2
```
commit 之后在本地 images 中就可以看见 ouruser/sinatra:v2 的 image 了，之后可以选择从这个 image 来创建一个新的 container，或者将其 push 到 docker bub 上。

#### 2. 第二种，使用 Dockerfile 文件
- 创建一个 Dockfile 文件
```
$ mkdir mydockerbuild
$ cd mydockerbuild
$ touch Dockerfile
```

- 打开 Dockerfile，并进行编写
~~~
FROM docker/whalesay:latest  
RUN apt-get -y update && apt-get install -y fortunes
# CMD /usr/games/fortune -a | cowsay
~~~

- build image
```
$ docker build -t docker-whale .
```
>The docker build -t docker-whale . command takes the Dockerfile in the current directory, and builds an image called docker-whale on your local machine.

#### 3. 上传 image
附： 如果需要将image发布到docker hub上，首先需要sign up一个 [docker hub](https://hub.docker.com/) 的账号。
然后本地命令行
```
$ docker login
$ docker push yourhubname/docker-whale
```

添加一个 tag
```
$ docker tag <imageId>[<imageName>] yourhubname/docker-whale:latest
```

#### 4. 删除 image
```
$ docker rmi <imageID>[<imageName>]
```
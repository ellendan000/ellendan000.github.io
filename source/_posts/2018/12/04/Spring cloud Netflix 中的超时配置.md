---
title: Spring cloud Netflix中的超时配置
date: 2018-12-04 20:14:00  
tags: 
    - Spring Cloud
    - Java
categories: 
    - Spring Cloud
    - Java
---

一般SpringCloud中超时配置，含Hystrix/Ribbon两部分：
```
ribbon:
  ReadTimeout: 120000
  ConnectTimeout: 120000
  
hystrix:
  command:
    default:
      execution:
        isolation:
          strategy: THREAD
          thread:
            timeoutInMilliseconds: 120000
```
hystrix thread timeout需要比ribbon timeout设置时间长。  
ribbon有retry机制，如果timeout设置时间短，则无法retry。

在zuul中，如果使用的是服务发现，ribbon timeout同上。  
如果使用的指定URL形式，ribbon timeout需要如下配置：
```
zuul:
  host:
    connect-timeout-millis: 120000
    socket-timeout-millis: 120000
```
[Zuul官方说明](https://cloud.spring.io/spring-cloud-netflix/multi/multi__router_and_filter_zuul.html#_zuul_timeouts)
>8.13 Zuul Timeouts
If you want to configure the socket timeouts and read timeouts for requests proxied through Zuul, you have two options, based on your configuration:
>If Zuul uses service discovery, you need to configure these timeouts with the ribbon.ReadTimeout and ribbon.SocketTimeout Ribbon properties.
If you have configured Zuul routes by specifying URLs, you need to use __zuul.host.connect-timeout-millis__ and __zuul.host.socket-timeout-millis__.
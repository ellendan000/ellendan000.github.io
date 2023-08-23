---
title: Spring Cloud Eureka 服务治理
date: 2018-05-16 00:00:00  
tags: 
    - Spring Cloud
    - Java
categories: 
    - Spring Cloud
---

### 服务注册中心
在服务治理框架中，通常有一个 `服务注册中心`，提供：
1. 服务注册。
每个服务单元向其登记自己提供的服务，将主机、端口号、版本号等告知注册中心，注册中心按 `服务名` 来组织清单。
2. 服务发现。
服务调用方需要调用某个服务名的实例提供的服务，则向服务注册中心获取所有服务实例的清单，以实现对具体服务实例的访问。

```
# first build.gradle
dependencies {
    compile 'org.springframework.cloud:spring-cloud-starter-eureka-server'
    compile 'org.springframework.boot:spring-boot-starter-web'
    ……
}

# second application.yaml
server:
  port: 11111

eureka:
  instance:
    hostname: localhost
  lease-renewal-interval-in-seconds: 30
  lease-expiration-duration-in-seconds: 90
  server:
    enable-self-preservation: false
  client:
    fetch-registry: false
    register-with-eureka: false
    serviceUrl:
      defaultZone: http://${eureka.instance.hostname}:${server.port}/eureka/
# third Application.java
@EnableEureKaServer
```

Netflix Eureka由于使用Restful API协议，因此支持跨语言跨平台的微服务应用进行注册。
### 服务提供者
Eureka客户端：
1. 向注册中心登记自身提供的服务，并且周期性地发送心跳来更新它的服务租约。
2. 从注册中心查询服务清单，把它们缓存到本地，并周期性地刷新服务状态。

### 服务续约(renew)
在服务注册完成之后，服务提供者维护一个心跳用来持续告知服务中心，以防止被服务列表中剔除。
使用spring boot actuator提供的/health来维护心跳、提供健康检查。
```
#first build.gradle
dependencies {
    compile 'org.springframework.cloud:spring-cloud-starter-eureka'
    compile 'org.springframework.boot:spring-boot-starter-actuator'
    ……
}

#second application.yaml
eureka:
  client:    
    serviceUrl:
		defaultZone: http://localhost:11111/eureka

#third Application.java
@EnableDiscoveryClient
```


### 服务下线
服务提供者正常关闭时，会触发一个服务下线的Restful请求给注册中心。注册中心在收到请求后，会将该服务编辑为下线，并广播此事件。

### 服务剔除
注册中心会定时每个一段时间 _lease-renewal-interval-in-seconds_ ，将服务清单中超过时间 _lease-expiration-duration-in-seconds_ 秒没有续约的服务剔除出去。

### 自我保护
基于上面服务剔除的，注册中心在运行期间，会统计心跳失败的比例在15分钟内是否低于85%，如果是，注册中心会将当前注册信息保护起来，让其不会过期。  
由于本地很容易触发保护机制，因此本地开发时关闭自我保护。
```
# application.yaml
server:
    enable-self-preservation: false
```
---
title: Spring config server
date: 2018-06-13 15:42:00  
tags: 
    - Spring Cloud
    - Java
categories: 
    - Spring Cloud
    - Java
---

## server
1. 添加依赖  
```
dependencies {
    compile 'org.springframework.cloud:spring-cloud-config-server'
    compile 'org.springframework.cloud:spring-cloud-starter-eureka'
    compile 'org.springframework.boot:spring-boot-starter-actuator'
}
```

2. 添加annotation  
```
@SpringBootApplication
@EnableConfigServer
public class ConfigServerApp {
    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApp.class, args);
    }
}
```

3. application.yaml配置文件添加config repo  
```
spring:
  application:
    name: config-server
  cloud:
    config:
      server:
        git:
          uri: file://${user.home}/space/app-config
          search-paths: '{application}/{profile}'
server:
  port: 7001
```
上面使用的本地文件系统方式进行配置仓库的内容管理，该方式仅用于开发和测试。在生产环境中务必搭建自己的Git配置库。

4. 将config server注册进服务发现，application.yaml
```
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:11111/eureka
    healthcheck:
      enabled: true
```

5. 同时可以考虑开启actuator endpoints。  
endpoints.enabled默认true。其中/health在后面Git配置库中有更多作用。  
```
management:
  security:
    enabled: false
```

## clinet
1. 添加依赖
```
dependencies {
    compile 'org.springframework.cloud:spring-cloud-starter-eureka'
    compile 'org.springframework.cloud:spring-cloud-starter-config'
    compile 'org.springframework.boot:spring-boot-starter-actuator'
}
```

2. bootstrap.yml配置  
```
spring:
  cloud:
    config:
\#      uri: http://localhost:7001
      discovery:
        enabled: true
        service-id: config-server
      fail-fast: true
  application:
    name: hello-cloud
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:local}
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:11111/eureka
    healthcheck:
      enabled: true
server:
  port: 8001
```
上面spring.application.name即会用在search-paths的{application}，spring.profiles.active即是search-paths的{profile}。  
同时从服务发现中查找config-server。如果不使用服务发现，可使用spring.cloud.config.uri指定静态的url。  
spring.cloud.config.fail-fast用于快速验证config server的连接可用状态，防止container前期load时长过长，到后面config server才发现不能用而启动失败。

3. 添加服务发现的annotation
```
@EnableDiscoveryClient
@SpringBootApplication
public class Application {

    public static void main(String[] args) {
        new SpringApplicationBuilder(Application.class).web(true).run(args);
    }
}
```

4. 开启actuator endpoints。其中/refresh可以对配置进行动态刷新。
```
management:
  context-path: /actuator
  security:
    enabled: false
```

5. 写一个支持刷新Example。
```
@RefreshScope
@RestController
public class HelloController {
    private final Logger logger = Logger.getLogger(getClass().getName());
    @Value("${from}")
    private String from;
    @GetMapping("/from")
    public String from(){
        return this.from;
    }
}
```

## 刷新操作
1. 修改配置库内from value。
2. curl -X POST http://localhost:8001/actuator/refresh。
3. 再次访问http://localhost:8001/from

## 在config server添加多个配置库
1. application.yaml
```
spring:
  application:
    name: config-server
  cloud:
    config:
      server:
        git:
          uri: git@github.com:XXX/app-config.git
          search-paths: '{application}/{profile}'
          passphrase: ********
          force-pull: true
          repos:
            none_prod:
              pattern:
                - '*/dev'
              uri: git@github.com:XXX/app-config.git
              searchPaths: '{application}/{profile}'
            prod:
              pattern:
                - '*/prod'
              uri: git@github.com:XXX/prod-app-config.git
              searchPaths: '{application}'
        health:
          repositories:
            none_prod:
              name: none_prod
              profiles: dev
server:
  port: 7001
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:11111/eureka
    healthcheck:
      enabled: true
```
spring.cloud.config.server.git.uri为默认配置库。
spring.cloud.config.server.health.repositories用来配置/health endpoint中健康检查的repos。

2. 这里采用使用本地ssh setting的方式。

* 首先，本地${user.home}/.ssh下有ssh key。
* 再次，ssh key加入ssh-agent。主要要确定config和know_host文件中记录。  
```
$ eval "$(ssh-agent -s)"
\# 添加config文件
\# Host gitlab.com
\# HostName gitlab.com
\# AddKeysToAgent yes
\# UseKeychain yes
\# User TTT
\# IdentityFile ~/.ssh/id_tw_rsa
$ ssh-add -K ~/.ssh/id_tw_rsa
\# 查看agent public keys
$ ssh-add -l
```
* 最后，如果key中有设置passphrase，在application.yaml一定要配置spring.cloud.config.server.git.passphrase。


---
title: spring boot actuator 基本配置
date: 2018-06-08 17:05:00  
tags: 
    - Spring Cloud
    - Java
categories: 
    - Spring Cloud
---

[1.5.3版本官方doc](https://docs.spring.io/spring-boot/docs/1.5.13.RELEASE/reference/htmlsingle/#production-ready)

spring-boot-actuator包自动提供了默认的management endpoint，用以监控容器内部的各种状态和指标。

### import
~~~
dependencies {
	compile("org.springframework.boot:spring-boot-starter-actuator")
}
~~~

### 打开endpoints
endpoints默认状态就是打开的。如果想全部关掉，然后分别打开：

~~~
management:
  context-path: /actuator
  security:
    enabled: false
endpoints:
  enabled: false
  health:
    enabled: true
    time-to-live: 10000
  info:
    enabled: true
~~~

### 关于security
如果系统没有@EnableWebSecurity自行定制security的话，可以使用`management.security.enabled`来控制management endpoint中sensitive的访问权限，以及not sensitive的显示内容范围。如下：

~~~
management:
  context-path: /actuator
  security:
    enabled: true
security:
  basic:
    enabled: true
  user:
    name: admin
    password: secret
~~~
当@EnableWebSecurity后，所有访问权限都由WebSecurityConfigurerAdapter的子类full controll。

spring boot 1.4可以通过`management.security.enabled=false`来关闭对management endpoints的security check，是由于spring boot实现的一个bug。  
spring boot 1.5中已经修复。  
而在spring boot 2.0中已经将`management.security.enabled`去掉。  
因此，在custom WebSecurityConfigurerAdapter中，还是使用正确的姿势对management endpoints进行特别设置：

~~~
...
.antMatchers("/info", "/health", "/metrics").permitAll()
~~~

### 关于management.port
`management.port=9999`虽然可以将management endpoint开放在独立的端口上，但`/health`check并不能自动检测主端口是否可用。  
因此，如果使用`management.port`时，可能需要自行定制一个HealthIndicator来ping主服务端口。
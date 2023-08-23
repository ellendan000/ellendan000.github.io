---
title: Spring cloud Feign
date: 2018-07-25 13:58:00  
tags: 
    - Spring Cloud
    - Java
categories: 
    - Spring Cloud
---

#### 1. dependency
~~~
dependencies {
    compile("org.springframework.cloud:spring-cloud-starter-feign")
    ……
}
~~~

#### 2. annotation
~~~
@SpringBootApplication
@EnableFeignClients
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
~~~

#### 3. feign client
~~~~
#不使用服务发现，直接配置url；
#使用服务发现，不配置url，name为service_id，另外project注意加入服务发现依赖、打开服务发现配置
@FeignClient(name = "invokeClient", url = "localhost:8001")
public interface InvokeClient {
@GetMapping("/user/{id}/username")
    public String name(@PathVariable("id") String id);

}
~~~~

注意，虽然支持spring MVC的annotation，但@PathVariable、@RequestParam、@RequestHeader等参数名的注解，一定要设置value值，这点与写controller不同。


#### 4. 打开feign log
feign clients默认的Logger.Level对象定义的是NONE级别，要想打开：  
首先：

~~~
@Configuration
public class GlobalFeignConfiguration {
    @Bean
    Logger.Level feignLoggerLevel() {
        return Logger.Level.FULL;
    }
}
~~~

然后，开启具体feign client logger:

~~~
#application.yaml

logging:
  level:
    <packageName>.<FeignInterfaceName>: DEBUG

~~~

或者针对性对feignClient进行配置：

~~~
@FeignClient(name = "invokeClient", configuration = GlobalFeignConfiguration.class, url = "localhost:8001")
public interface InvokeClient {

}
~~~

#### 附：
controller与feignClient的接口定制方式相同，实践中可以考虑由provider，也就是controller方提供统一接口，避免重复。

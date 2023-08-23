---
title: 在gradle管理可共享的依赖版本管理  
date: 2020-06-05 14:18:20  
tags: 
    - Gradle
    - Java
categories: 
    - Java
---

“可共享的依赖版本管理” —— 用过 Maven 的小伙伴们可能说，这不就是BOM么。  
对，这里聊的就是如何使用 gradle 实现 BOM 生成和导入。  
没用过 Maven 的小伙伴们也不用被劝退，想想在使用Spring plugin `io.spring.dependency-management`时，
`imports.mavenBom`到底在做什么，有没有想要了解一下？
<!-- more -->

### 1. BOM是什么？
在说 BOM 之前，先了解一下 Maven 的一些基本概念。  
Maven __POM__，全名 `Project Object Model`, 是 Maven 使用中的重要配置文件，xml格式，主要用来导入依赖和进行项目构建。  
Maven __BOM__，全名 `Bill Of Materials`, 是一种特殊的 POM，主要用来集中管理项目依赖的版本，更加灵活地维护所有依赖的版本信息。  
配置好的 BOM，可以放在单个项目中自用，也可以传阅和分享给其他项目进行公用。

讲的直观一点，效果就是（见下图）：
![Spring-dependencies-management](在gradle管理可共享的依赖版本/Spring-dependencies-management.png)
dependencies中依赖的那些库为何可以不用标明版本？  
正是因为使用了*dependency-management* 插件，当 gradle plugin *org.springframework.boot* 检测到此插件启用时，会自动导入Spring boot dependencies BOM，这样依赖库们会主动使用 BOM 中推荐的版本。[链接](https://docs.spring.io/spring-boot/docs/current/gradle-plugin/reference/html/#managing-dependencies)

下面是Spring Cloud BOM的一部分展示(完整见[链接](https://github.com/spring-cloud/spring-cloud-release/blob/vHoxton.SR5/spring-cloud-dependencies/pom.xml))：

![Spring-cloud-dependencies](在gradle管理可共享的依赖版本/Spring-cloud-dependencies.png)

看到这里，是不是觉得有 BOM 的情况下便捷不少，再也不用一条条dependency分别查阅、选择和维护版本了？  
日常开发中，我们已经见识过了Spring boot / Spring Cloud /junit 这些常用 BOMs。

当有了已经被验证过的依赖版本管理，setup projects时候直接拿来复用，是不是感觉省事不少？  
同时 BOM 不可避免地还支持版本升级。  
下面我们就来看看如何在 gradle 中定义我们自己的 BOM。

### 2. gradle Java platform plugin
`gradle Java platform plugin`是 gradle 对定义、发布 BOM 提供的一款实用插件。  
引入它，我们就可以开始动手工作了。[官方链接](https://docs.gradle.org/5.6.3/userguide/java_platform_plugin.html#header)

_`build.gradle`_
```
plugins {
    id 'maven-publish'
    id 'java-platform'
}

version '0.1.1-SNAPSHOT'

javaPlatform {
    allowDependencies()
}
dependencies {
    api platform('org.springframework.boot:spring-boot-dependencies:2.2.6.RELEASE')
    api platform('org.springframework.cloud:spring-cloud-dependencies:Greenwich.SR3')
    api platform('org.springframework.cloud:spring-cloud-contract-dependencies:2.2.3.RELEASE')
    api platform('org.junit:junit-bom:5.3.2')
    constraints {
        api 'com.google.guava:guava:27.0.1-jre'

        api 'ch.vorburger.mariaDB4j:mariaDB4j-springboot:2.4.0'
        api 'org.mariadb.jdbc:mariadb-java-client:2.2.5'

        api 'org.mockito:mockito-core:2.22.0'
        api 'org.mockito:mockito-junit-jupiter:2.22.0'
        api 'org.assertj:assertj-core:3.11.1'
    }
}

publishing {
    repositories {
        maven {
            credentials {
                username = 'jfrog'
                password = 'jfrog123456'
            }

            def releasesRepoUrl = 'http://localhost:8082/artifactory/libs-release/'
            def snapshotsRepoUrl = 'http://localhost:8082/artifactory/libs-snapshot/'
            url = version.endsWith('SNAPSHOT') ? snapshotsRepoUrl : releasesRepoUrl
        }
    }

    publications {
        myPlatform(MavenPublication) {
            from components.javaPlatform
        }
    }
}
```

当然, 作为一个服务级的 BOM，自然无需从零开始逐条定义，可以直接先 import 框架级的 BOMs，如上例中的Spring boot / Spring cloud / Spring cloud contract / Junit。  
但由于需要使用第三方platform bom, 则不得不打开配置约束 ——`javaPlatform.allowDependencies`。具体使用请见[官方链接](https://docs.gradle.org/5.6.3/userguide/java_platform_plugin.html#sec:java_platform_bom_import)

这里，通过gradle生成的 BOM 会发布到一个我本地自己搭建的JFrog artifactory OSS中。
(为什么不在云上搭一个？啊哈哈，因为JFrog artifactory OSS最低预配是4核4G内存，自己掏钱就手短了。。)
当然,也可以生成本地的 POM 文件，手动复制传阅，但这样就不容易进行后续的版本管理和保持更新了。

maven publish 成功后，我们就可以来使用 BOM 导入依赖版本了。

### 3. gradle platform
导入方式也非常简单，直接使用platform组件即可。[官方链接](https://docs.gradle.org/current/userguide/platforms.html)

创建一个example项目试一下, 编写`build.gradle`文件。
```
repositories {
    maven {
        credentials {
            username = "jfrog"
            password = "jfrog123456"
        }
        url "http://localhost:8082/artifactory/libs-snapshot/"
    }
}

dependencies {
    implementation platform('com.ellendan.service.template:dependencies-bom:0.1.1-SNAPSHOT')

    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-security'

}

```
对，就是使用platform()引入即可。  

也许有人会问：大家用 spring-dependency-management 习惯了，这个 BOM 是否支持 spring-dependency-management 的 `imports.mavenBom`。  
理论上是支持的。  
但本人在写代码的时候，发现自定义 BOM 中spring boot dependencies BOM 无法被成功引入，而其他 BOMs 都没有此问题、可以成功导入。  
因此，我这里并不推荐通过spring-dependency-management的`imports.mavenBom`来导入。

### 4. 为什么要做“可共享的依赖版本管理”
这还要从本人最近的一个任务说起。  
任务本身是做 —— “启动模板”。  
但“启动模板”，这四个字，怎么看都觉得非常的静态。  
结合Rebecca《演进式架构》中“服务模板”的概念（虽然“模板”这命名还是怎么看怎么静态）。在构建服务的过程中，为了防止有害的重复，如果技术上的适当耦合避免不了，那就尽量让其黑盒复用。  
> 通过在服务模板中定义适当的技术架构耦合点，并让基础设施团队管理这些耦合，就能使各个服务团队免于这些苦恼。  

所以，这里决定尝试做一个“服务模板”。  
依赖版本管理只是其中的一个小的部分, 并且使用 gradle 来实现也非常简单。  
具体代码地址：https://github.com/ellendan000/service_template

### PS. 废话篇
眼看2020就要过半，由于2020开局乱来，受种种因素影响，计划一团混乱变更。  
一鼓作气，再而衰，三而竭，各种计划目标债。期望2020后半段能走好吧~

### 参考资料
1. https://docs.spring.io/spring-boot/docs/current/gradle-plugin/reference/html/#managing-dependencies
2. https://docs.gradle.org/5.6.3/userguide/java_platform_plugin.html#header
3. https://docs.gradle.org/current/userguide/platforms.html
4. https://docs.spring.io/dependency-management-plugin/docs/current/reference/html/#introduction
5. https://www.baeldung.com/spring-maven-bom

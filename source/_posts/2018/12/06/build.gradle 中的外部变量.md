---
title: build.gradle中的外部变量
date: 2018-12-06 02:05:00  
tags: 
    - Gradle
    - Java
categories: 
    - Gradle
    - Java  
---

使用gradle命令的时候，经常被Option -P\\-D搞得混淆。其实很容易区分一下。

### Project property
在build.gradle文件中，能直接通过变量名访问 或者 project前缀访问的是project property。  

##### 设置
project property可以通过5种方式自定义设置(优先级从低到高)：  
1. gradle.properties文件  
(user gradle home下的gradle.properties文件优先级高于工程目录下的gradle.properties文件)
```
branchName=t1
```
2. 环境变量
```
ORG_GRADLE_PROJECT_branchName=t2
```
3. 命令行-D
```
./gradlew clean build -Dorg.gradle.project.branchName=t3
```
4. 命令行-P
```
./gradlew clean build -PbranchName=t4
```
5. build.gradle自身文件内, 定义时使用前缀ext。
```
ext {
  branchName=t5
}
```
##### 访问
读取project property时需要注意，如果值不存在，构建将直接失败。因此，如果有值不存在的情况需要判断时，使用方法`Project.hasProperty(java.lang.String) `。

### System property
看了上面第3项中，有个**命令行-D**。  
其可以传递一个system property给gradle运行的JVM中，跟Java -D的功用相同。  

##### 设置
system property可以使用两种方式自定义：  
1. gradle.properties文件。使用前缀systemProp：  
~~~
systemProp.branchName=y1
~~~

需要注意，在multi project build中，只有root directory下的gradle.properties文件中配置的systemProp才会生效。其他子模块中的会被忽略。  

2. 命令行-D
```
./gradlew clean build -DbranchName=y2
```

##### 访问
需要在build.gradle文件中使用时，需要调用：
```
System.properties['system']
```


---
title: 尽量不要在 Spring Config Server 中使用太长的数组
date: 2018-10-07 22:48:00  
tags: 
    - Spring Cloud
    - Java
categories: 
    - Spring Cloud
    - Java  
---

上周second vendor在使用我们搭建好的config server向API-Gateway中追加配置项的时候，发生了一个小插曲。  

本来本意是想**追加**一条 _忽略去校验Token_ 的API Pattern, 但是失误操作成**覆盖**整个 _忽略去校验Token_ 的API Pattern Array.  

------------


来看一下我们的yaml配置文件application-default.yml中的结构：
```
ignoredValidateTokenUrl:
  - /api/user/password-reset
  - /tablet/js/**
  - /integration/**
  …………
```
整个Array由于日积月累，length已经长达四五十。  
之前追加新的条目，大家相互心照不宣地都是在default yaml中编写，于是在QA、UAT等环境中，也就并没有在config server里再另行定制维护。

这次second vendor的想法很简单，只是想在这四五十条的后面再追加一条新的API。于是他在UAT环境的application-uat.yml中这样做的：
```
ignoredValidateTokenUrl:
  - /api/d2d
```
然后，那天我们UAT环境一下午都无法登录。。

这其中，起因固然是second vendor的小伙伴对**Spring config server**或者说是对**Spring Profile-specific properties**的不熟悉造成的。  
但换个角度来看，由于*Spring config server*、*Spring Profile-specific properties*对配置进行覆盖的主原则就是根据key，如果value是一个数组，也就是数组内所有元素都共用一个key。  
因此，这时候的覆盖就是整个数组进行覆盖，其内部是不能再次进行细化操作的。

而如果数组元素配置在各环境重复度相当高，且又在config server中不同环境都维护一套的话，容易造成：
1. 维护成本增加。  
每次修改的时候，不仅检查当前环境yaml文件，还要与default文件进行比对，以免遗漏。
2. 容易失误出错，无法溯源。  
需要经常与default进行对比，一旦遗漏，就会出错。又若是遗漏后长时间未发现，发现时已很难分辨到底是失误还是特殊定制。

因此当使用Array作为property-value时，应该依如下顺序进行一下考虑：
1. length大概只有2~5个的，可以考虑直接用key-Array，或者key-strings都行。如Zuul sensitiveHeaders，长度最多只有3。
2. 如果Array中的每一个元素项可以找到有具体涵义的名称作为key的话，就将key-Array的实现解构成多个key-value，如Zuul的routes。
3. 如果是数组长度又长，基本不需要profile-special的，可以考虑不配置在*Spring config server*、*Spring Profile-specific properties*中。可以考虑将其持久在其他文件介质中、数据库中等等。


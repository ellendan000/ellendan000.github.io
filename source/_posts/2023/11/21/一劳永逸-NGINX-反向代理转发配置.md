---
title: 一劳永逸 NGINX 反向代理转发配置
top: false
cover: false
toc: true
date: 2023-11-21 15:47:46
img:
coverImg:
password:
keywords:
tags:
    - DevOps
categories:
    - DevOps
---

当项目环境 setup 时，针对不同的技术选型，一些时候需要自己使用 NGINX 配置反向代理。
每当这个时候，我总是记不住 location 和 proxy_pass 中路径带 `/` 和不带 `/` 的对应关系、配置错误还会带来重定向 post 变 get 的问题等等，因此每每配置都需要查阅文档，反复验证和测试。
而最近找到一种写法，可以彻底放弃之前的配置困扰 —— 其解决思路可以类比 表达式中的括号`()`, 当记不住或者不确定操作符之间的优先级时，建议添加`()`，即`将隐式转成显式声明`  —— 避免优先级不明确的同时，也增加了代码的可读性。

下面就是个人建议的 Nginx 配置方式：
```
location ~* ^/api/(players|usage)(.*)$ {
    proxy_pass https://example.com/api/$1$2$is_args$args;
    proxy_buffering off;
    proxy_set_header  X-Forwarded-For $remote_addr;
}

location ~* ^/api/(wx\-tokens|orders)(.*)$ {
    proxy_pass https://example.com/api/$1$2$is_args$args;
    proxy_buffering off;
    proxy_set_header  X-Forwarded-For $remote_addr;
}
```
如上
- 使用正则 `~* ^$` 匹配原始的整个请求路径
- proxy_pass 路径带上整个正则匹配的子组，`$1$2`明确整个URI的部分，`$is_args$args`明确queryString部分（这部分不在location regex的匹配范围内）
- `proxy_buffering off` 为了使用 chunked 方式透传，需要关闭 proxy_buffering


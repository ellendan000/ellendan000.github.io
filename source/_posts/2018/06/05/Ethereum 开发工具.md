---
title: Ethereum 开发工具
date: 2018-06-05 23:27:00  
tags: 
    - Ethereum
    - Blockchain
categories: 
    - Ethereum
    - Blockchain
---

## Using Remix
有个叫[Remix](http://remix.ethereum.org/)的在线IDE，快速地验证智能合约，或者一些基本调试，还是特别方便的。

## Using truffle
#### 安装ganache
可以选择安装有图形界面的[ganache](https://github.com/trufflesuite/ganache)，或者无图形界面的命令行[ganache-cli](https://github.com/trufflesuite/ganache-cli)。

按个人喜好选择。
本人两种都安装了，但使用时更喜好命令行版。  
```
$ npm install -g ganache-cli
$ ganache-cli //即可运行
```

#### 安装truffle
```
$ npm install -g truffle
```

#### build project
```
$ mkdir hello-solidity-truffle
$ cd hello-solidity-truffle
$ truffle init
```

#### truffle常用命令
```
truffle migrate
truffle test
truffle console
```

### 安装MetaMask
MetaMask是一个以Chrome浏览器插件形式实现的轻钱包。  
进入Chrome Web Store查找安装后即可。

然后要记得创建的口令和密码。

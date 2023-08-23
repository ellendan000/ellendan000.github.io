---
title: 在使用 AngularJS 的过程中了解 Promise（二）
date: 2015-12-05 20:13:00  
tags: 
    - AngularJS
    - Promise
categories: 
    - AngularJS
---

公司最近有个博客大赛，OP甚至亲自在team stand-up上要求大家积极投稿。对于我这种热爱写代码、记流水账、提炼式总结的人，拽文真的不是太想做，但是，好吧，这是所谓的impact中最容易做到的一种，那就去做吧。

---

Promise，对擅长前端的Dev应该众所周知，对于典型的后端Dev来说，基本可以总结为一句话：**来自于Promise/A+，CommonJS指定规范，解决JS中的回调地狱和异步调用。**

**异步调用**，由于在浏览器中JavaScript单线程运行，为了减小那些占用时间长的方法调用的线程等待时间（如向服务器请求资源），定义的某些方法需要在固定事件或响应后才调用执行。

而所谓**回调地狱**，就是指下面这种可以无限延伸、可读性差、可维护性差的代码调用。

```
$.get('api/xxx/a', function(a) {
  $.get('api/xxx/b', function(b) {
    $.get('api/xxx/c', function(c) {
      ...
    }, errorCallback);
  }, errorCallback);
}, errorCallback);
```

先来简单说一下AngularJS的Promise的使用，其实主要是两大对象deferred和promise。也可以准确来说，promise是deferred的一个属性对象。  

defer - 延迟，promise - 承诺。

defer就好像遥控器，promise就是被遥控的炸弹。装配这一套装置的技术员他承诺，按下遥控上的绿色按钮时，左边的炸弹会被引爆，按下红色，右边的炸弹会灰飞烟灭。

他安装好了这一切，然后拿着遥控器这个句柄，去喝了茶去逛了个街，最主要的是他打了份报告——向上级申请执行引爆，上级经过深思熟虑通过了审批，还顺便选了个黄道吉日，于是技术员按下了遥控上的一个按钮，不出意外对应的炸弹被引爆。

从遥控炸弹安装完成，到最后被引爆，这一段跨越时间的执行就达到了延迟。

好吧，这是个蹩脚的比喻，在这里本人只是想将defer/promise这两个词具象一下，其不能完全说明Promise包含的完整机制。因为如果这是看上面这个举例，根本就是一个单纯的Command Pattern就可以实现。

这里回归正题，deferred和promise：

promise有一个最主要的方法then，用于注册三类回调函数：successCallBack/errorCallBack/notificationCallBack，然后生成一个新的nextPromise并将其返回。

deferred对象包含三个方法，resolve()/reject()/notify()，被调用时分别对应执行本实例promise注册的三个回调（见上行，按顺序一对一）。注意resolve和reject是二选一，也就是说炸弹的遥控器是一次性的，它只代表一次延时，炸掉一个就已经成为既定事实不可再改。

所以对于对于promise而言有三种状态，pending（还在延迟中）、resolve、reject。resolve\\reject也同时叫fullfilled，即完成状态。  

一段简单的使用代码：

```
var deferred = $q.defer();
deferred.promise.then(function success(data) {
  console.log(data);
},
function error(reason) {
  console.error(reason);
},
function notification(progress) {
  console.info(progress);
});

$timeout(function(){
    deferred.resolve('simple');
}, 3000);
```

看，基本上就是这样。至于我为什么说炸弹的例子不太恰当，“一”就是resolve是可以传递参数的，callback函数会对其进行加工。而炸弹的遥控器…这个无法再塞进去任何东西传递给炸弹。

考虑到这些promise更像是香肠加工流水线，定制好职能和顺序，塞进去一头猪，经历层层加工，最后出来的是香肠。

而“二”是最有意思的地方，promise支持链状调用，即promise.then(…).then(…)……。同时，达到的效果是，当defer.resolve()/reject()后，首先调用按状态调用then1的callback，then2中的callback始终是在then1的callback调用执行完以后才执行，即串行。

为什么觉得有意思呢？链状结构无非就是callback函数的最后一句return this不就得了么？

查看下angular1.3.15源码，事实上，并不是。(项目中用的是angularJS 1.2.26，因此本文中angular书写方式还是1.2的，但1.2源码释义性没有1.3的高，因此本人贴的源码都是1.3的，请谅解。)

如本人前面所写的“promise有一个最主要的方法then……，然后生成一个新的nextPromise并将其返回”。

```
 then: function(onFulfilled, onRejected, progressBack) {
    var result = new Deferred();

    this.$$state.pending = this.$$state.pending || [];
    this.$$state.pending.push([result, onFulfilled, onRejected, progressBack]);
    if (this.$$state.status > 0) scheduleProcessQueue(this.$$state);

    return result.promise;
  }
```

而它为何要这样做呢？它的目的其实是，当第一组炸弹引爆后的推动力可以顺利触发第二组炸弹的遥控器按钮。defer2.resolve(promise2callback())。

因此promise有连接几个then进行调用，即使生成了几个promise，每一个promise对应的defer遥控都在前一个promise的callback结束处，并且将callback的返回值作为resolve()的参数值。

完全可以进行验证，见下

```
var deferred = $q.defer(),
      promise = deferred.promise;
  
  promise.then(function(val){
    console.log("A " + val);
    return "A";
  });
  
  promise.then(function(val){
    console.log("B " + val);
    return "B";
  });
  
  deferred.resolve("P");
```

如果认为promise.then的链状调用，每次都是返回当前promise的话，上面这段代码就应该与promise.then().then()其实是同一个意思，然后很可惜，执行结果是

-   "A P"
    
-   "B P"
    

这里可以想一下为何Promise采用此种链状实现方式。实现Promise的目的是解决回调地狱和异步回调，也就是说痛点原型是这样：

```
asyncTask1('a', function(val1) {
    console.log('start task1 callback', val1 += 'b');

    asyncTask2(val1, function(val2) {
      console.log('start task2 callback', val2 += 'c');

      asyncTask3(val2, function(val3) {
        console.log('start task3 callback', val3 += 'd');
        console.log('end task3 callback');
      });
      console.log('end task2 callback');
    });
    console.log('end task1 callback');
  });
```

上面如果按照期望的链状设计想法，执行下来效果预想如下：

```
"start task1 callback"
"ab"
"end task1 callback"
"start task2 callback"
"abc"
"end task2 callback"
"start task3 callback"
"abcd"
"end task3 callback"
```

而事实上，按照方法栈后进先出的原则，其实结果是：

```
"start task1 callback"
"ab"
"start task2 callback"
"abc"
"start task3 callback"
"abcd"
"end task3 callback"
"end task2 callback"
"end task1 callback"
```

对按照方法栈的原则，这是不可违背的事实，但是JavaScript幸运的有setTimeout\\angularJS有nextTick，在每一个asyncTask调用其回调函数时，仅需使用setTimeout\\nextTick来调用callback即可。

这时链状执行asyncTask1(callback)->asyncTask2(callback) ->asyncTask3(callback)的顺序就可实现，回过头来再看一眼，callback1对于asyncTask2的调用到底提供了什么？提供执行后的结果作为入参 \+ 触发其调用而已，除此之外他们可以是各自完整的封装，他们连接成链（链状数据结构的“链”）。

因此上面那个例子，由promise调用，其实是这样的：

```
var asyncTask1 = function(data, millisecond) {
      var defer = $q.defer();
      $timeout(function() {
        defer.resolve(data);
      }, millisecond);
      return defer.promise;
    },
    asyncTask2 = asyncTask1,
    asyncTask3 = asyncTask1;

  asyncTask1('a', 5000).then(function(val1) {
    val1 += 'b';
    console.log('task1 callback', val1);
    return asyncTask2(val1, 3000);
  }).
  then(function(val2) {
    val2 += 'c';
    console.log('task2 callback', val2);
    return asyncTask3(val2, 1000);
  }).
  then(function(val3) {
    val3 += 'd';
    console.log('task3 callback', val3);
  });
```

angularJS Promise这块代码实现颇为有趣，另外1.3版本比之1.2，这块源码大量被重构，释义提升了不少。

总的来说，Promise的链状实现两点起到很大作用：

1、setTimeout/nextTick让回调跳出了先进后出的尴尬；

2、每一对Defer/Promise对象都是天生“绝”配。链状的执行，其实是前一个promise注册的回调与下一个defer的resolve/reject尾首向触发的过程。

这里也只是拿多个异步任务回调粗略的描述了一下，在项目中用的最多的then链形式，还是一个异步触发多个顺序回调处理而已，由于其从第一个then回调开始就直接return“确定内容的对象”，后续 promise 状态及入参判断简单，这里对于这样情况就不再描述。
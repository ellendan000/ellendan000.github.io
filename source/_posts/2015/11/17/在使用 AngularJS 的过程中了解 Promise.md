---
title: 在使用AngularJS的过程中了解Promise（一）
date: 2015-11-17 00:33:00  
tags: 
    - AngularJS
    - Promise
categories: 
    - AngularJS  
---

好吧，我承认最近的确在重新学浏览器端的技术。OMG，刚入行的时候我就觉得最糟心的浏览器端语言 —— 心中一直想要回避的区域，并且NB前端工程师需要克服种种与后端工程师属性不和的区域（跨浏览器跨设备、标准不统一、JS单线程下的效率与工作流程、UI风格美不美位置准不准确等等等等），对于我这种不关心审美也没多少耐心厌恶无标准的死板后台工程师来说，心中一直只想说：请放过我。

最近在做一个AngularJS的项目，其致力于前后端分离、提供前端模板、标准web页面组件等等，在其中遇见了一个Promise，才发现脱离前端关注已经很久了，不知不觉中前端也在不断往前发展。废话就不多说了，后面是自己使用部分的一点总结。

---

Promise来自于Promise/A+，CommonJS指定规范。解决JS中的回调地狱和异步调用。

### Promise简单使用

抛开AngularJS实现的源码不说的话，使用Promise其实主要分为两部分：deferred和promise 两个对象。

```javascript
var deferred = $q.defer();
deferred.promise.then(function(){
  console.log('hello');
});
deferred.resolve();
```

"defer"英文单词“延迟”，"promise"给予“承诺”。

promise是deffered的一个属性，带有最主要的then方法，用于注册三类回调函数：successCallBack/errorCallBack/notificationCallBack，并且生成一个新的promise。

而deferred的三个方法，分别针对于出发这三类回调的发生：resolve()/reject()/notify().

而一个延迟任务，resolve()/reject()只能二选一进行触发。

```javascript
var deferred = $q.defer();
var promise = deferred.promise;

promise.then(function success(data) {
  console.log(data);
},
function error(reason) {
  console.error(reason);
},
function notification(progress) {
  console.info(progress);
});

var progress = 0;
var interval = $interval(function() {
  if (progress >= 100) {
    $interval.cancel(interval);
    deferred.resolve('All done!');
  }
  progress += 10;
  deferred.notify(progress + '%...');
  }, 100);
```

在我看来deferred就像由它生出的promise这颗炸弹的遥控器，deferred按下resolve()按钮，successCallBack被调用；或者按下reject()按钮，errorCallBack被调用；延迟加载中，notify()触发notificationCallBack。

这个比喻虽然形象，但是其实并不能很好的概括promise的所有功能。比如：参数的传递。

resolve(result) -> function successCallBack(result){}

reject(reason) -> function errorCallBack(reason){}

notify(progress) -> function notificationCallBack(progress){}

参数对象可以为普通对象也可以为promise对象，如果为promise，效果同链式向下传递。

  
### Promise链式使用

promise对象是可以使用多个then方法连续调用的，即链式书写调用。

```javascript
var deferred = $q.defer();
var promise = deferred.promise;
  
promise.then(function(val) {
    console.log(val);
    return 'B+';
  }, function(val) {
    console.log(val);
    return 'B-';
  })
  .then(function(val) {
    console.log(val);
   }, function(val){
    console.log('I only want to see who will execute here');
  });

deferred.resolve('A+');
//deferred.reject('A-');
```

resolve('A+')时，将打印：A+，B+

reject('A-')时，将打印：A-，B-

这里需要注意的是reject(),reject()仅负责第一层then的触发。第一层then的successCallBack\errorCallBack成功执行后（无error发生），则自动触发下一层promise.then对应的resolve()方法。

所以上例中需要reject('A-')时，想要打印出：A-，I only want to see who will execute here。则需要

```javascript
var deferred = $q.defer();
var promise = deferred.promise;
  
promise.then(function(val) {
    console.log(val);
    return 'B+';
  }, function(val) {
    console.log(val);
    throw "this is error";
  })
  .then(function(val) {
    console.log(val);
   }, function(val){
    console.log('I only want to see who will execute here');
    console.log(val);
  });

  deferred.reject('A-');
```

打印结果：

```
A
this is error
I only want to see who will execute here
this is error
```

error被打印，但任务未中断。

```javascript
  var defer1 = $q.defer(),
    defer2 = $q.defer(),
    promise1 = defer1.promise,
    promise2 = defer2.promise;

  promise1.then(function(val) {
    console.log("I'm promise1 success");
    console.log(val);
  }, function(reason) {
    console.log("I'm promise1 error");
  });

  var promise3 = promise2.then(function(val) {
    console.log("I'm promise2 success" + val);
    return '2';
  }).then(function(val){
    console.log("I'm promise2 success" + val);
    return '3';
  }).then(function(val){
    console.log("I'm promise2 success" + val);
    return '4';
  });
  
  defer1.resolve(promise3);
  defer2.resolve('1');
```

打印：

```
I'm promise2 success1
I'm promise2 success2
I'm promise2 success3
I'm promise1 success
4
```

这里refer.resolve参数即为一个promise，所以defer1.promise上注册的回调会在promise3已知的回调执行完以后在进行调用。
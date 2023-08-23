---
title: Jasmine 基础 API
date: 2015-12-17 06:10:00  
tags: 
    - Javascript
    - unit test
categories: 
    - Javascript  
---

#### 1.  Jasmine官网documen地址 
[http://jasmine.github.io/2.4/introduction.html](http://jasmine.github.io/2.4/introduction.html)
    
#### 2.  下载发布包，参照示例进行使用
github 上下载最新的 Release 的 zip 包，本地解压后打开：SpecRunner.html(运行文件)、src（js源文件夹）、spec（js测试文件夹）、lib（jasmine依赖的js库）
    
#### 3.  打开SpecRunner.html文件，在注释说明的相应位置添加源文件、测试文件。
```
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Jasmine Spec Runner v2.3.4</title>

  <link rel="shortcut icon" type="image/png" href="lib/jasmine-2.3.4/jasmine_favicon.png">
  <link rel="stylesheet" href="lib/jasmine-2.3.4/jasmine.css">

  <script src="lib/jasmine-2.3.4/jasmine.js"></script>
  <script src="lib/jasmine-2.3.4/jasmine-html.js"></script>
  <script src="lib/jasmine-2.3.4/boot.js"></script>

  <!-- include source files here... -->
  <script src="src/Player.js"></script>
  <script src="src/Song.js"></script>

  <!-- include spec files here... -->
  <script src="spec/SpecHelper.js"></script>
  <script src="spec/PlayerSpec.js"></script>

</head>
<body>
</body>
</html>
```
    
#### 4.  spec.js文件基本格式
```
describe("A suite is just a function", function() {
  var a;

  it("and so is a spec", function() {
    a = true;

    expect(a).toBe(true);
  });});
```
    
describe\\it都是function，describe用来定义spec suite，it用来定义spec。
 
第一个参数都为字符串，第二个为测试块。
>describe：“The string is a name or title for a spec suite – usually what is being tested. The function is a block of code that implements the suite.”  
>
>it：“The string is the title of the spec and the function is the spec, or test. A spec contains one or more expectations that test the state of the code. An expectation in Jasmine is an assertion that is either true or false. ”
    
#### 5.  基础API的使用
    
**Matcher**：
```
expect().toBe();            //同===
expect().not.toBe();        //所有的断言都可用not取反
expect().toEqual();         //可比较字面量或者变量指向的对象内容
expect().toMatch(/bar/);    //正则
expect().toBeDefined();     //是否被定义，未定义是undefined
expect().toBeUndefined();   //是否未定义
expect().toBeNull();        //是否是null
expect().toBeTruthy();      //是否为truthy
expect().toBeFalsy();       //是否未falsy
expect().toContain();       //数组是否包含某元素,基与equals对比
expect().toBeLessThan();    //小于某值, 可比较数字、字符串、时间
expect().toBeGreaterThan(); //大于某值
expect().toBeCloseTo(, 0);  //根据第二位参数所给的精度，保留相应精度，其后“Round_half_down”，比较值是否相等
expect(fn1).toThrow()；     //断言fn1运行会抛出异常

//断言fn1运行会抛出具体异常
expect(fn1).toThrowError("foo bar baz");    
expect(fn1).toThrowError(/bar/);
expect(fn1).toThrowError(TypeError);
expect(fn1).toThrowError(TypeError, "foo bar baz");
```

**手动失败**：

```
fail("Callback has been called");
```

**Setup and Teardown**：

```
beforeEach, afterEach, beforeAll, afterAll
```

在嵌套describe的情况，在it之前会按照由外靠内的顺序执行beforeEach，结束后又由内到外执行afterEach。

**this**：

在一个spec的beforeEach/it/afterEach范围内有效分享对象的方式。

“Each spec’s`beforeEach`/`it`/`afterEach` has the `this` as the same empty object that is set back to empty for the next spec’s `beforeEach`/`it`/`afterEach`.”

```
describe("A spec", function() {
  beforeEach(function() {
    this.foo = 0;
  });

  it("can use the `this` to share state", function() {
    expect(this.foo).toEqual(0);
    this.bar = "test pollution?";
  });

  it("prevents test pollution by having an empty `this` created for the next spec", function() {
    expect(this.foo).toEqual(0);
    expect(this.bar).toBe(undefined);
  });});
```

**Disabling Suites**:

```
xdescribe("A spec", function() {});
```

**Pending Specs**:

“Pending specs do not run, but their names will show up in the results as`pending`”。且方法内的一切断言将被忽视。

```
//三种方式
xit("can be declared 'xit'", function() {
    expect(true).toBe(false);
  });
  
it("can be declared with 'it' but without a function");

//该方法内部调用了pending，将标记为pending方法，参数传达pending原因。
it("can be declared by calling 'pending' in the spec body", function() {
    expect(true).toBe(false);
    pending('this is why it is pending');
  });
```

**Spies**:  

“ A spy can stub any function and tracks calls to it and all arguments. ”  

```
spyOn(foo, 'setBar');                        //创建spy，并拦截对方法的调用
spyOn(foo, 'getBar').and.callThrough();      //创建spy，并代理真实方法的调用

//创建spy，并拦截结果的返回，给予结果定义。所有的返回结果被替换。
spyOn(foo, "getBar").and.returnValue(745);   
//创建spy，并拦截结果的返回，按照调用顺序给予结果定义
spyOn(foo, "getBar").and.returnValues("fetched first", "fetched second"); 

//fake一个方法
spyOn(foo, "getBar").and.callFake(function() {
      return 1001;
    });
        
spyOn(foo, "setBar").and.throwError("quux");  //所有的调用将抛出异常

//and.stub(),fake一个空方法体
spyOn(foo, 'setBar');
foo.setBar.and.stub();
```

**jasmine.createSpy**

```
whatAmI = jasmine.createSpy('whatAmI');    //创建一个方法用于spy，不需要该方法已经定义, context为定义时的上下文
tape = jasmine.createSpyObj(['play', 'pause', 'stop', 'rewind']);    //创建一个对象，且属性也同时被定义
```

**matcher：**

```
expect(foo.setBar).toHaveBeenCalled();            //已经被调用
expect(foo.setBar).toHaveBeenCalledWith(123);     //已经通过参数XX调用

//======期望值的matcher======
expect(foo).toHaveBeenCalledWith(jasmine.any(Number), jasmine.any(Function));    //jasmine.any(构造函数名)，此类型的任何对象即可匹配
expect(foo).toHaveBeenCalledWith(12, jasmine.anything());                        //jasmine.anything()，非undefined\null的即可匹配
expect(foo).toEqual(jasmine.objectContaining({bar: "baz"}));                     //jasmine.objectContaining，包含此属性的对象即可匹配
expect(foo).toEqual(jasmine.arrayContaining([3, 1]));                            //jasmine.arrayContaining，包含其元素子集的数组即可匹配
expect({foo: 'bar'}).toEqual({foo: jasmine.stringMatching(/^bar$/)});            //jasmine.stringMatching，包含此字符串匹配方式的即可匹配（参数方式可参见toMatch）

//自定义任何想要的期望匹配：asymmetricMatch
describe("custom asymmetry", function() {
  var tester = {
    asymmetricMatch: function(actual) {
      var secondValue = actual.split(',')[1];
      return secondValue === 'bar';
    }
  };

  it("dives in deep", function() {
    expect("foo,bar,baz,quux").toEqual(tester);
  });

  describe("when used with a spy", function() {
    it("is useful for comparing arguments", function() {
      var callback = jasmine.createSpy('callback');

      callback('foo,bar,baz');

      expect(callback).toHaveBeenCalledWith(tester);
    });
  });});
```

**spy.calls：**

“Every call to a spy is tracked and exposed on the `calls` property.” 对spy的完整track信息。  

```
expect(foo.setBar.calls.any()).toEqual(false); //spy的函数被调用至少一次，则返回true
expect(foo.setBar.calls.count()).toEqual(0);   //spy的函数被调用的次数

//函数被调用的索引对应的参数列表：foo.setBar.calls.argsFor
foo.setBar(123);
foo.setBar(456, "baz");
expect(foo.setBar.calls.argsFor(0)).toEqual([123]);
expect(foo.setBar.calls.argsFor(1)).toEqual([456, "baz"]);
//被调用的历史完整列表：foo.setBar.calls.allArgs
expect(foo.setBar.calls.allArgs()).toEqual([[123],[456, "baz"]]);

//track的历史所有完整信息：foo.setBar.calls.all（注意是数组）
expect(foo.setBar.calls.all()).toEqual([{object: foo, args: [123], returnValue: undefined}]);

//track的最近一次的完整信息：foo.setBar.calls.mostRecent
expect(foo.setBar.calls.mostRecent()).toEqual({object: foo, args: [456, "baz"], returnValue: undefined});

//track的第一次的完整信息：foo.setBar.calls.first
expect(foo.setBar.calls.first()).toEqual({object: foo, args: [123], returnValue: undefined});

expect(spy.calls.first().object).toBe(foo);    //object为调用上下文context
foo.setBar.calls.reset();                      //清除track历史记录，重置
```

**Jasmine Clock**：

```
beforeEach中jasmine.clock().install();
afterEach中jasmine.clock().uninstall();
it中使用jasmine.clock().tick(101); 调用时模拟时间已经走了101毫秒，好似时间加速器

//模拟绝对时间
var baseTime = new Date(2013, 9, 23);
jasmine.clock().mockDate(baseTime);
jasmine.clock().tick(50);
expect(new Date().getTime()).toEqual(baseTime.getTime() + 50);
```

**Asynchronous Support**：done

可使用在beforeEach/it/afterEach中，function注入done即可。注入done声明此处有异步调用，测试需要等待。

如在“jasmine.DEFAULT\_TIMEOUT\_INTERVAL”超时之前都未有调用done方法，其后将失败。可通过beforeEach/afterEach的第二个参数，it的第三个参数声明超时时间。

```
it("takes a long time", function(done) {
            setTimeout(function() {
                done();
            }, 9000);
        }, 10000);
```

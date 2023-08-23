---
title: JavaScript 启示录总结
date: 2015-11-24 13:44:00  
tags: 
    - JavaScript
categories: 
    - JavaScript
---

JavaScript1.5版本，相当于ECMAScript第三版。

---

1\. 创建复杂对象（非原始对象）的三种方式：

-   new Object（首先创建出的是无预定义属性或者方法的空对象）
    

```
var codyA = new Object();
codyA.name = '张三';
```

-   构造器
    

```
var Person = function (name) {
        this.name = name;
    },
    codyB = new Person('张三');
```

-   字面量
    

```
var codyC = {
    name: "张三"
};
```

    三种方式，构造器方式中构造函数可以当成一个强大、集中定义的对象“工厂”，可用于复用来创建更多的Person对象。 

     \* 为自定义对象创建自定义构造函数的同时，也为Person()实例创建了原型继承；使用字面量来构造，会避开了原型继承的使用。

  

2\. new

    构造函数只是一个函数，除非使用关键字new来调用。

    JavaScript给予的动作：

-   将该函数的this值设置为正在构建的新对象
    
-   默认返回新创建的对象，即返回this（新对象被认为是构建该对象的构造函数的实例，即Person()的实例）
    

    注意：  

-   构造函数名首字母大写
    
-   如果不使用new来调用构造函数，this将指向包装该函数的“父”对象。
    

  

3\. JavaScript内置（或者叫预包装）了9个原生对象构造函数：Number()、String()、Boolean()、Object()、Array()、Function()、Date()、RegExp()、Error()。  

    JavaScript又叫“预包装若干原生对象构造函数的语言” —— JavaScript主要是由这9个对象以及 原始值（布尔、数字、字符串）来创建。  

    注意：Math对象是静态对象，不是构造函数，只是一个对象命名空间，用于存储数学函数。

  

4\. 原始值（字符串、数字、布尔）与String()、Number()、Boolean()。原始值还有null、undefined等。

     原始值皆不为对象。原始值特殊之处在于表示简单值，很多时候作为不可再细化的进行复制和操作。

  

     字符串、数字、布尔 有其对应的包装构造函数。应**尽量使用原始值**：

-    typeof "a" => "string"，而typeof (new String('b')) => "object"
    
-   在原始值被视为对象的情况下才会创建实际的复杂对象。如“a”.length在使用时，JS会在幕后为字面量创建一个包装器对象，以便将该值被视为一个对象。调用方法以后，JS即抛弃包装对象，该值返回字面量类型。
    
-   原始值的constructor属性，会显示其包装对象的构造函数String()、Number()、Boolean()
    
-   String('test')\\Number('10')\\Boolean('true')也可以获取原始值，注意前面没有new。
    
    由此可见，**JavaScript中所有东西都用成对象**，而非那句“JavaScript中所有东西都是对象”。
    

  

5\. 字面量是JavaScript提供的一种快捷方式，使用字面量创建对象与构造函数方式基本相同，除了字符串、数字、布尔字面量。

```
var myNumber = 123,
  myString = 'hello',
  myBoolean = true,
  myObject = {
    name: 'Jack'
  },
  myArray = ['foo', 'bar'],
  myFunction = function(x, y) {
    return x + y;
  },
  myRegExp = /\b[a-z]+\b/;
```

  

6\. 原始值null、undefined

    两者没有包装类型构造函数。  

    可以用null来显式指出对象属性不包含值。

    undefined两种方式：1、声明的变量未初始化；2、试图访问的对象没有被定义（即还没被命名），并且不存在于原型链中。

    只允许JavaScript使用undefined是一种很好的方法。永远不要将一个值设置为undefined。如果制定一个属性或变量值不可用，应该使用null。  

  

7\. === 与 ==

    尽量不要都不要使用==，== 会自动执行类型转换。  

    === 比较原始值时，是进行值比较。对复杂对象进行比较时，是进行对象引用比较，可理解为比较的是对象引用地址的值，只有当操作符两端是同一个对象时才为true。

      

8\. typeof

    typeof返回正在使用值的类型。  

```
console.log(typeof null); 	            //object    !!
console.log(typeof undefined);              //undefined !!
console.log(typeof 123); 		    //number
console.log(typeof 'hello'); 		    //string
console.log(typeof true); 		    //boolean
console.log(typeof (new Number(123))); 	    //object
console.log(typeof (new Boolean(true)));    //object
console.log(typeof (new String('hello')));  //object
console.log(typeof (new Object())); 	    //object
console.log(typeof (new Array('foo', 'bar'))); 			//object
console.log(typeof (new Function("x", "y", "return x + y"))); 	//function  !!
console.log(typeof (new Date())); 				//object
console.log(typeof (new RegExp('\\b[a-z]+\\b'))); 		//object
console.log(typeof (new Error('Crap!'))); 			//object
```

  

9\. 构造函数生成的对象实例

-   拥有指向其构造函数的constructor属性
    

```
function Test(){
  this.name = "zhangsan";
}

var a = {},
  B = function() {
    this.name = "Jack";
  },
  d = new B(),
    e = new Test();
console.log(a.constructor === Object); //true
console.log(d.constructor === B);      //true
console.log(e.constructor === Test);   //true
```

-   可拥有自己的独立属性
    

```
var myString = new String('hello');
myString.prop = 'test';
```

     源于JavaScript对象的动态属性特性，原始值无动态属性支持。

     动态属性支持易变对象，因此甚至可以通过其来该院JavaScript本身原生对象的预配置特性，但不建议这样做。

     即使Function对象也可以添加独立属性：  

```
function Test(){
  this.name = "zhangsan";
}

Test.go = "hello";
console.log(Test.go);
```

  

10\. 可当做容器的复杂对象：Object()、Array()、Function(), 可以包含其他复杂对象。

     注意Function并非指动态属性（此功能在Object()中），Function见下：  

```
function Test() {
  var getTest = function() {
    var get = function(){
      //TODO
    }
  }
}
```

  

11\. 获取、设置、更新对象属性  

     两种：点表示法、中括号表示法，尽量使用点表示法。  

     中括号表示法仅在：1、需要传递获取的属性名为变量； 2、使用关键字为属性名的情况。  

     同时，字面量声明对象时，属性名没必要使用为字符串，除非是下面几种情况: 1、是保留关键字；2、包含空格或者特殊字符；3、以数字开头。

  

12\. delete操作符

```
var test = {name: 'Jack'};
delete test.name;
console.log(test.name);    //undefined
```

-   delete是将属性从一个对象删除的唯一方法。将属性设置为undefined或null只能改变属性的值，不会将属性从对象删除。
    
-   delete不会删除在原型链上找到的属性。
    

  

13\. 属性、方法的获取，以及原型链

    如果试图访问对象中没有的属性、方法，JavaScript会试图使用 原型链来查找。

     查找myArray.foo, 首先查找创建对象的构造函数(MyArray())，并检查器原型属性(MyArray.prototype)，然后会寻找另外两个位置：(Array.prototype，然后是Object.prototype)，对象的构造函数prototype对象上查找它。

     例子：  

```
var myArray = ['foo', 'bar'];
console.log(myArray.hasOwnProperty('join')); //输出false
```

     当 JavaScript创建Array构造函数时，join()方法等作为Array()原型属性的一个属性被添加。

-   prototype属性是JavaScript为每一个Function()实例创建的一个对象。它将通过new关键字创建的对象实例链接回创建他们的构造函数。实例才可以共享或继承通用方法和属性。共享发生在**属性查找**时。
    

          JavaScript会为每个函数创建原型对象，不论是否是构造函数。

-   所有函数都是由Function()构造函数创建的。当创建函数实例时，它总有一个prototype属性，它是一个**空对象**。
    

```
var myFunction = function(){};
console.log(myFunction.prototype); //同{}
```

-   当函数使用new关键字创建对象时，它都会在**创建的实例对象**和**创建实例对象的构造函数的prototype属性**之间添加一个隐性链接\_\_proto\_\_。这样就形成了原型链，原型链将每个实例都链接至其构造函数的prototype属性。
    

          如果需要使用\_\_proto\_\_属性，正确的写法是：myObject.constructor.prototype

          原型链最后的是Object.prototype

-   用新对象替换prototype属性会删除默认的构造函数属性。但是可以手动指定一个。
    

```
var Foo = function(){console.log('good');};
Foo.prototype = {constructor: Foo};

var fooInstance = new Foo();
console.log(fooInstance.constructor === Foo);
console.log(fooInstance.constructor);
```

     打印：

     "good"   true  function(){console.log('good');}

-   prototype引用的对象是动态的，原型链查找出的内容也会是动态的。
    
-   用新对象替换prototype属性不会更新以前已创建的实例，因此一旦开始创建实例，就不应该在替换构造函数的原型属性。
    

  

14\. hasOwnProperty 和 in操作符  

    in操作符可以检查一个对象的属性，包括来自原型链的属性；  

    hasOwnProperty方法可以检查来自非原型链属性的对象。

```
var myObject = {foo: 'value'};
console.log(myObject.hasOwnProperty('foo'));
console.log(myObject.hasOwnProperty('toString'));
console.log('toString' in myObject);
```

     for..in循环遍历对象的属性，并且只遍历可枚举的属性（即可用属性），例如构造函数属性就不会显示。可以使用obj.propertyIsEnumerable(prop)来检查可枚举属性。

     注意：访问属性的顺序并不一定是定义的顺序。

```
var cody = {
  age: 23,
  gender: 'male'
};

for (var key in cody) {
  //避免来自原型链的属性
  if (cody.hasOwnProperty(key)) {
    console.log(key);
  }
}
```

15\. 对象和函数

-   Object（）创建出的实例，也可叫Object()对象实例，拥有的属性：constructor以及隐藏属性\_\_proto\_\_；实例方法：hasOwnProperty()等等。
    
-   Function() 函数属性：prototype, Function.prototype; Object（）这个函数具有属性：prototype, 即Object.prototype。
    
    Function()对象实例属性：arguments、constructor(函数也是对象)、length；实例方法：call()、apply()等。
    

   所有的实例(new Object())都拥有constructor和\_\_proto\_\_属性。所有的函数(new Function())都有prototype属性。

  

16\. 函数

     函数是可执行语句的唯一作用域。函数总有返回值，如果没有指定返回值，默然返回undefined。

     函数创建的三种方式：1\. new Function(arg..., functionBody); 2. 函数表达式 var name = function(){}；3. 函数语句，字面量形式 function name(){};

new方式少用，原因同eval()。

    函数的使用：所有函数体中，this和arguments都是可用的。

    **arguments**：即使在函数定义中不指定参数，如果在调用时发送了参数，还是可以依靠arguments来访问参数。  

```
var add = function() {
    return arguments[0] + arguments[1];
}
console.log(add(3, 4));
```

arguments对象拥有名为callee的属性，是对当前执行函数的引用。当函数需要递归调用时，非常有用。

     **this**: 是对包含函数的对象的引用。如果不在对象中，this是全局对象，浏览器是window。

     **length**: 定义的参数数量（却不能直接使用），用法arguments.callee.length。argments也有一个length属性, Javascript1.4开始废弃，不同处是 调用时属性的长度。  

使用4中不同的场景或模式调用函数：

-   作为函数(仅作为函数调用，this会被指向head对象)
    
-   作为方法（在对象中）
    
-   作为构造函数
    
-   使用apply（）或者call（）
    

apply与call的区别是参数传递的不同:

```
function print(text, extra) {
  console.log(this.name + text + extra);
}

var zhang = {
  name: 'zhang'
};
print.apply(zhang, [' good', ' morning']);
print.call(zhang, ' nice', ' day');
```

  

自调用的匿名函数，需要使用括号，或者任何将函数转化成表达式的符号。

```
(function (msg){
  console.log(msg);
}('Hello'));

var a = function (msg){
  console.log(msg);
  return 'ok';
}('Hello');
```

  

    函数可以嵌套，并且嵌套的深度是没有限制的。但**嵌套函数的this值是head对象**。

```
var test = {
    name: 'Jack',
    say: function() {
      var name = function(){
        return this.name;
      };
      console.log('hello ' + name());
    }
  },
  name = 'head';

test.say();
```

**自动提升：**在真正定义函数语句之前，可以在执行时调用该语句。因为在运行代码之前，函数语句已经被编译器解释，并添加至执行堆栈、上下文中。  

注意：只有“函数语句”形式的被提升，“函数表达式”的函数不会提升。

  

17\. head/全局对象

     JavaScript代码本身必须包含在对象内部，如Web浏览器环境中，JavaScript被包含在window对象内，并且在其内部执行，这个window对象被认为是“head对象”。  

     **head对象**是JavaScript环境中可用的最高作用域/上下文。  

```
var myStringVar = 'myString';
console.log('myStringVar' in window);
```

     **“全局对象”**是指直接包含在head对象内部的值。如上myStringVar就是一个全局对象，是head对象的一个属性。  

     head对象内的**全局函数**（JavaScript附带的一些预定义函数）：parseInt()\\parseFloat()\\decodeURI()\\decodeURIComponent()\\encodeURI()\\encodeURIComponent()\\eval()\\isFinite()\\isNaN()  

     **引用head对象**：1、使用head对象的名称（如浏览器中，是window）； 2、在全局作用域中使用this关键字；

     但一般head对象是隐式的，通常不显示引用(除非命名太简单易被遮盖住)。同时，性能方面alert()比window.alert()代价要低。（即使我们知道想要的属性在全局作用域中，但如果只依靠作用域离链，并避免显式地引用head对象，会更快）

```
var foo = {
    method: function(text) {
      alert('nice ' + text);
      window.alert('good ' + window.text); //想访问text遮盖中的全局text变量
    }
  },
  text = 'zhang';

foo.method('li');
```

  

18\. this

     创建函数时，系统会创建一个名为this的关键字，它链接到运行该函数的对象。或者说是链接到执行上下文中。

    除了new关键字和call()\\apply()的情况例外：

-   new调用构造函数时，this引用“即将调用的对象”；
    
-   call\\apply会使用context对象改写this值。say.call(context, args..)
    

  

```
var myObject = {name: 'zhang'},
    name = 'li',
    sayHello = function(){
  console.log('hello ' + this.name);
};
myObject.sayHello = sayHello;
myObject.sayHello();
sayHello();
```

    打印："hello zhang" "hello li"

  

**    在传递函数或者有多个函数的引用**时，要意识到this值会根据调用函数所在的上下文而改变。除了**this**和**arguments**之外所有变量都遵守“词法作用域”规则。

    在嵌套函数中this关键字引用head对象，ES5中开始固定规定。即当this值的寄主函数被封装在另一个函数的内部或者在另一个函数的上下文中调用时，this将永远指向head对象的引用。

    可以充分利用作用域链来避免this被改写。

```
var myObject = {
    name: 'zhang',
    say: function() {
      var that = this;

      (function helper() {
        console.log(that.name);
        console.log(this.name);
      })();
    }
  },
  name = 'win';

myObject.say();
```

    打印: "zhang" "win"

  

    原型方法内的this关键字引用构造函数实例。当在prototype对象中的方法内部使用this关键字时，this可用于引用实例。如果实例中不包含要查找的属性，则使用原型链查找。  

```
var Person = function(name){
  if(name){
   this.name = name; 
  }
};

Person.prototype.sayHello = function(){
  console.log('hello ' + this.name);
};

var zhang = new Person('zhang');
zhang.sayHello();

Object.prototype.name = 'default';
var d = new Person();
d.sayHello();
```

  

19\. 作用域

    JavaScript作用域有三种：全局作用域、局部作用域（函数作用域）和eval作用域。  

-   全局作用域是作用域链中的最高层/最后一个
    
-   包含函数的函数，会创建堆栈执行作用域。又叫作用域栈。
    
-   JavaScript没有块级作用域。
    

    **作用域链（词法作用域）**  

```
var x = 10,
  foo = function() {
    var y = 20;
    return function() {
      var z = 30;
      console.log(x + y + z);
    };
  };

var y = 500;
foo()();
```

     打印：60  

     y在解释时就已经绑定。即**函数定义时确定作用域，而非调用时确定，作用域链是根据函数定义时的位置确定的，也叫“词法作用域”**。与this、arguments区分开。  

    作用域链式基于代码的编写方式创建的，而不是基于调用函数所在的上下文。这使得函数即使从一个不同的上下文调用函数，也能够访问最初编写代码时所在的作用域，这被称为“**闭包**”。

  

20\. Array()

创建数组的两种形式：1、new Array(length) 2、\[element1, element2,...\]

第一种预定义数组的长度，并且每个元素都是undefined。

```
var myArray = [];
myArray[50] = 'blue';
console.log(myArray.length);    //51,50之前的元素都是undefined填充
```

可以通过设置数组长度来来添加或删除值。

  

21\. 0、-0、null、false、 NaN、undefined和空字符串（“”）外的任何有效JavaScript值都将被转换为true。

```
var falseBoolean = new Boolean(false);
console.log(falseBoolean);

if(falseBoolean){    //即使是false的布尔对象，实际上是true对象
  console.log('falseBoolean is truthy');
}
```
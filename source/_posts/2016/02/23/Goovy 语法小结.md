---
title: Groovy 语法小结
date: 2016-02-23 00:11:00  
tags: 
    - Groovy
categories: 
    - Groovy
---

1\. 安全导航操作符 ?.,只有对象引用不为空时才会分派调用。

```
def a
a?.isEmpty()
```

  

2\. groovy不强迫捕获我们不关心的异常。

捕获所有Exception 

```
try{
}catch(ex){
}
```

  

3\. groovy默认都是public的。

  

4\. groovy默认提供构造器。

```
class Robot{
    def type, height, width
} 
robot = new Robot(type: 'arm', width: 10, height: 40)
```

  

5\. groovy传参

出现键值对的形式，groovy会将所有键值对作为第一个形参（Map）的Entry，其余参数按顺序赋给剩余形参。

```
class Robot{
    def access(location, weight, fragile){
        print "$fragile, $weight, $location"
    }
}
robot.access(x: 30, y: 20, z:10, 5, true)
//可改变顺序
robot.access(5, true, x: 30, y: 20, z:10)
```

注意：使用键值对传参，最好是当参数仅有一个Map时使用；

如果一定要使用一个Map + 多个参数传递的形式，请显示声明Map类型。  

```
class Robot{
    def access(Map location, weight, fragile){
        print "$fragile, $weight, $location"
    }
}
```

当实参包含的不是两个对象和一个任意键值对，代码就会报错。

  

6\. 可选形参, 方法可以不用再写重载

```
def log(x, base = 10){
    Math.log(x) / Math.log(base)
}
```

  

6.1 变长传参

最后一位形参是数组形式

```
def receiveVarArgs(int a, int... b){}
def receiveVarArg(int a, int[] b){}
```

注意：Groovy将 \[2, 3\]看作是ArrayList的一个实例对象，因此调用时：

```
receiveVarArgs（1， [2, 3, 4] as int[]）
```

  

可参考Groovy创建数组、列表的区别：

```
int[] arr = [1, 2, 3]
def arr1 = [1, 2, 3] as int[]
def arr2 = [1, 2, 3] //ArrayList类型
```

  

7\. 多赋值。返回数组，被多赋值给各个变量。

等号左边变量多的，将设为null（不能默认null的，抛异常），右边值多的，将丢弃。

```
def splitName(fullName){
fullName.split(' ')
}
def (firstName, lastName) = splitName('James Bond')
```

  

因此可以延伸为交换变量

```
def a = 1
def b = 2
(a, b) = [b, a]
```

  

8\. 实现接口

一接口，单方法

```
def diaplyMouseLocation = {positionLabel.setText("$it.x, $it.y")}
frame.addMouseListener(diaplyMouseLocation as MouseListener)
```

  

一接口，多方法

```
def handleFocus = [
    focusGained : {}
    focusLost : {}
]
```

  

动态实现接口， asType()作为什么的接口实现

```
events = ['WindowListener', 'ComponentListener']//可以是更动态的一些输入
handler = {msgLabel.setText("$it")}
for(event in events){
    handlerImpl = handler.asType(Class.forName("java.awt.event.${event}"))
    frame."add${event}"(handlerImpl)
}
```

  

9\. 默认布尔处理

groovy基本都为对象，除引用对象不为空为true外，有些对象还有如下情况也为true。

| Boolean | 值为true |
| Collection | 不为空 |
| Map | 映射不为空 |
| Char | 不为0 |
| 字符串 | 长度大于0 |
| 数字 | 不为0 |
| 数组 | 长度大于0 |
| 其他类型 | 不为null |
| 自定制 | 通过asBoolean()方法来重写 |

  

10\. forEach

```
for(String greet : greetings){}
for(def greet : greetings){}
```

不想指定类型：

```
for(greet in greetings){}
```

或者 内部迭代器 each()

  

10\. 静态导入支持别名

```
import static Math.random as rand
double value = rand()
```

  

11\. java的编译时注解被忽略，如Override。

12\. groovy既支持动态类型，又支持泛型。泛型在执行时进行检查生效。

13\. Groovy可以重载操作符，因为每个操作符都被映射到一个标准的方法。

14\. 使用注解生成代码

[@Canonical](http://my.oschina.net/u/2345489) 标注于类上，用于生成toString():逗号分隔各属性，可排除属性

```
@Canonical(excludes='lastName, age')
class Person{}
```

  

[@Delegate](http://my.oschina.net/delegate) 用于引入被委托类相应的方法包装器，用于委派任务。引入的具体实例方法与顺序有关。

查找还未有的方法进行一次引入。

```
class Worker{
    def work(){}
    def analyze(){}
}
class Expert{
    def analyze(){}
}
class Manager{
    @Delegate Expert expert = new Expert()//引入Expert实例的analyze方法
    @Delegate Worker worker = new Worker()//引入Worker实例的work方法
}
```

  

@Immutable 标注在类上，用于便捷生成不可变值对象，即属性final。同时提供hashCode()、equals()、toString()方法。

```
@Immutable
class CreditCard{
    String cardNumber
    int creditLimit
}
```

  

[@Lazy](http://my.oschina.net/u/145675) 标注于属性上，懒加载

```
class Heavy{}
class AsNeeded {
    @Lazy Heavy heavy = new Heavy()
}
```

  

[@Singleton](http://my.oschina.net/u/674) 标注于类上，实现单例模式

```
@Singleton(lazy = true)
class TheUnique{
}
```

  

15\. == 

== 等于调用java的equals()，除非实现Comparable接口的类型，== 等于compareTo()

is()等于java的==

  

16\. groovy匿名内部类使用可能会有问题，会将{……}实现体当做闭包。
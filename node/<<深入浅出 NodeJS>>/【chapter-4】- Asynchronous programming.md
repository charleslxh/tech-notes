# 《深入浅出 NodeJS》— Chapter 4
##  异步编程

### [函数式编程](http://baike.baidu.com/link?url=Z4B2eNi8XykgqYQr6leg45PsgPxH0YfeRyienymIzvbPNgLm5-ASzZAKQoNX6FHVZ8GK-Q_igmlmE-Mpd0dn7q)

**函数式编程**是种编程典范，它将电脑运算视为函数的计算。函数编程语言最重要的基础是 λ 演算（lambda calculus）。
而且λ演算的函数可以接受函数当作输入（参数）和输出（返回值）。和指令式编程相比，函数式编程强调函数的计算比指令的执行重要。
和过程化编程相比，函数式编程里，函数的计算可随时调用。

**函数式编程** 的特点：

-   支持闭包和高阶函数，支持惰性计算（lazy evaluation）。
-   使用递归作为控制流程的机制。
-   加强了引用透明性。
-   没有副作用。

在 JS 中，函数是一等“公民”，使用非常灵活，无论是调用或者作为参数或者作为返回值，它将是异步编程的基础。

### 高阶函数

通常情况下，一般函数只接收基本的 *数据类型* 和 *对象引用* 作为`参数`或`返回值`。高阶函数可以把函数作为参数或返回值的函数。

```js
var bar = function(x) { console.log("I." + x); }

var foo = function(x, bar) { return bar(x) }

// 下面是典型的高阶函数编程：sort
var points = [ 40, 100, 1, 5, 25, 10 ]
points.sort(function(previous, next) {
    return previous - next;
});
```

高阶函数在 JS 中比比皆是，ES5 中还提供了一系列的数组方法： forEach()、map()、reduce()、filter()、reduceRight()、every()、some()等都十分典型。

### 偏函数用法（Partial function）

`偏函数用法`是指创建一个调用另外一个部分（函数或变量已经预置的函数）的函数用法。

```js
// 偏函数
var isType = function(type) {
    return function(obj) {
        return type == typeof obj;
    }
}

// 偏函数的应用
var isString = isType("string")
var isFunction = isType("function")

isString("justiliao") // => true
isFunction(function(){}) // => true

```

如上面所示：通过指定部分参数来产生一个新制定的函数的形式就叫偏函数。

### 异步编程的优势与难点

**优势**: 基于事件驱动的非阻塞 I/O 模型，这是他的灵魂。
**难点**：

-   异常的处理
-   函数嵌套过深
-   阻塞代码
-   多线程编程
-   异步转同步

### 异步编程解决方案

-   事件发布/订阅模式
-   Promise/Deferred 模式
-   流程控制库

#### 事件发布/订阅模式

事件监听器是一种广泛用于异步编程的模式，是回调函数的事件化。Node 自身提供了 [events](http://nodeapi.ucdok.com/#/api/events.html) 模块。它具有： addListener()/on()、once()、removeListener()、removeALlListeners() 和 emit()。

```js
// 订阅
emitter.on("event_name", function(message) { 
    console.log("I am " + message); // => I am justinliao
});
// 发布
emitter.emit("event_name", "justinliao");
```

`事件发布/订阅模式`可以实现一个事件与多个处理函数（回调函数或叫监听器）绑定，当 emit() 发布事件后，消息会传递给绑定这个事件的所有监听器
调用并且，监听器可以很灵活的调用和删除。使得事件和具体处理逻辑之间实现关联和解耦。

`事件发布/订阅模式` 自身并无同步异步的问题存在，但是在 Node 中， emit() 多半是伴随着事件循环而异步调用的。

`事件发布/订阅模式` 常常用来解耦业务逻辑。Node 对事件做了一些额外的处理：

-   如果一个事件超过了 `10` 个 监听器，将会得到警告。设计者认为监听器太多可能会导致内存泄露的问题。另外一个事件的监听器过多，会严重影响
CPU的性能问题。`emitter.setMaxLIsteners(0);` 可以设置监听器个数上限（0：表示无限多个）
-   为了处理异常，EventEmitter 对象对 error 事件进行了特殊对待，如果运行期间处罚了 error 事件，首先会检查是否有 error 事件的监听器
，如果有，就直接调用这个监听器。否则，就作为异常抛出，如果外部没有捕获这个异常，则会导致线程崩溃。

`多异步之间的协调问题`：

通过上面的知识了解我们可以知道：一个事件是可以绑定多个监听器的，即： **一对多**。但是如果一个监听器依赖于多个事件传递的消息呢，即 **多对一** 。我们可以有如下方案：

**一** ： 借助 *第三方变量* (`哨兵变量`来处理结果)，通常我们把一个`记录次数`的变量叫做哨兵变量。详细请看代码：

```js
// 定义一个偏函数
var afterAllEvent = function(times, callback) {
    count = 0;
    result = {};

    return function(key, value) {
        count++;
        result[key] = value;

        if(count === times) {
            callback(result);
        };
    };
};

// 结合 pub/sub 模式实现 多对一 情况
emitter = require("events").EventEmitter;

var render = function(data) { 
    // 渲染函数，需要多个事件返回的内容。
};

var done = afterAllEvent(3, render);

emitter.on("done", done);

fs.readFile("template_path", "utf8", function(err, template) {
    emitter.emit("done", "template", template);
});

db.query(sql, function(err, data) {
    emitter.emit("done", "DBdata", data);
});

l10n.get(function(err, resource) {
    emitter.emit("done", "resource", resource);
});
```

**二** ：使用第三方框架，如 [EventProxy](https://github.com/JacksonTian/eventproxy) 模块，它是对事件的 pub/sub 模式的扩充，可以自由的订阅组合事件。[详细参考 API](http://html5ify.com/eventproxy/api.html)

#### Promise/Deferred 模式

#### 流程控制库

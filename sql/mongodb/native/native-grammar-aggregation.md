# MongoDB 语法包含了更新、查询、索引、聚合、管理、分片、复制

## MongoDB 聚合函数 [Aggregation]

## API 文档
[点击查看 API](http://docs.mongodb.org/manual)

---------------------------------------------------------------------------------------------

### 聚合函数

**count([boolean || number])** ： `count()` 查询记录条数，忽略限制条件。 `count(true | 非0)` 查询限制条件之后的记录条数。

- `parameter` ： 可以传 `Boolean` 值或 `非0` 的 Number 。
- `return` ： Number 类型的值。

```js
db.blog.find().count();
15
db.blog.find().limit(10).skip(5).count();
15
db.blog.find().limit(10).skip(5).count(true);
5
```

**distinct** ：用来找出给定的键所有的不同值。 **必须** 指定 `collection` 和 `key`

- `parameter` ： 键值名称 `key` 。
- `return` ： Object ，其中包含了返回的值的数组 `values<Array>`，和执行成功的标识 `ok`:1。

```js
// 假如 people 中有如下文档
db.people.fine();
{ "name": "Ada", "age": 20 }
{ "name": "Justin", "age": 22 }
{ "name": "Cherry", "age": 19 }
{ "name": "Ben", "age": 24 }
{ "name": "Charles", "age": 20 }

// 使用 distinct 可以找出 指定键的所有不同的值
db.runCommand({ "distinct": "people", "key": "age" });
{ "values": [20, 22, 19, 24], "ok": 1 }
// 或者如下写法
db.people.distinct("age");
{ "values": [20, 22, 19, 24], "ok": 1 }
```

**group** ：用来找出给定的键所有的不同值。`db.collection.group({ key, reduce, initial [, keyf] [, cond] [, finalize] })`

- `parameter` ： 如下表所述 。
- `return` ： Object ，分组之后的文档。

| 参数名        | 类型           | 描述        |
| :----------:|:--------------| :----------:|
| `key`   | document | 需要进行分组的键，可以是多个键，按照顺序进行分组， `{ "name": 1, "age": 1, "class.name": 1 }` |
| `reduce`   | function | 每个组都对应一个 `reduce` 函数，每个文档都会调用一次，函数可能会返回一个 `sum` 或 `count` 结果，函数接收两个参数： **当前文档** 和 **这个分组的聚合后的结果文档（aggregation result document）** |
| `initial`   | document | 初始化聚合结果文档 Initializes the aggregation result document. |
| `keyf`   | function |  **可选**，通过一系列计算或操作返回值来替代 `key` 来作为 `group` 的条件 |
| `cond`   | document |  条件，只有满足条件的文档才会被列入分组中，条件可以使用任何查询选择器  |
| `finalize`   | function | **可选**， 完成器或叫终结器，用以精简从数据库返回的数据。在最终返回给用户的结果之前每个文档都会调用一次，这个 function 可以修改返回结果的结构（简单说：对数据进行封装）。 |

#### 聚合操作一

```js
// Example collection
db.test.find()
[
  { "class": { name: "C1" }, "username": "Justin", "grade": 100 },
  { "class": { name: "C2" }, "username": "Anson", "grade": 100 },
  { "class": { name: "C3" }, "username": "Ben", "grade": 100 },
  { "class": { name: "C4" }, "username": "Cherry", "grade": 100 },
  { "class": { name: "C1" }, "username": "Charles", "grade": 100 },
  { "class": { name: "C1" }, "username": "Alice", "grade": 100 },
  { "class": { name: "C2" }, "username": "Phepobe", "grade": 100 },
  { "class": { name: "C2" }, "username": "Ada", "grade": 100 }
]

// 简单的 group 查询示例
db.test.group(
   {
     key: { 'class.name': 1 },
     cond: { grade: { $gt: 90 } },
     reduce: function( curr, result ) {
                 result.total += curr.grade;
             },
     initial: { total : 0 }
   }
)

// 返回的结果
[
  { "class": "C1", "grade": 300 },
  { "class": "C2", "grade": 300 },
  { "class": "C3", "grade": 100 },
  { "class": "C4", "grade": 100 },
]
```

#### 聚合操作二

```js
// Example Collection
db.skills.find();
[
  { "time" : ISODate("2015-08-26T04:00:00Z"), "name" : "abc1", "total" : 25 },
  { "time" : ISODate("2015-08-27T04:00:00Z"), "name" : "abc2", "total" : 25 },
  { "time" : ISODate("2015-08-28T04:00:00Z"), "name" : "abc3", "total" : 25 },
  { "time" : ISODate("2015-08-29T04:00:00Z"), "name" : "abc4", "total" : 25 },
  { "time" : ISODate("2015-08-30T04:00:00Z"), "name" : "abc5", "total" : 25 },
  { "time" : ISODate("2015-08-31T04:00:00Z"), "name" : "abc6", "total" : 25 },
  { "time" : ISODate("2015-09-01T04:00:00Z"), "name" : "abc7", "total" : 25 },
  { "time" : ISODate("2015-09-02T04:00:00Z"), "name" : "abc8", "total" : 25 },
  { "time" : ISODate("2015-09-03T04:00:00Z"), "name" : "abc9", "total" : 25 },
  { "time" : ISODate("2015-09-04T04:00:00Z"), "name" : "abc10", "total" : 25 },
  { "time" : ISODate("2015-09-05T04:00:00Z"), "name" : "abc11", "total" : 25 },
  { "time" : ISODate("2015-09-06T04:00:00Z"), "name" : "abc12", "total" : 25 },
  { "time" : ISODate("2015-09-07T04:00:00Z"), "name" : "abc13", "total" : 25 },
]

// 使用 keyf 代替 key
db.skills.group(
   {
     keyf: function(doc) {
               return { day_of_week: doc.time.getDay() };
            },
     cond: { total: { $gt: 20 } },
     reduce: function( curr, result ) {
                 result.total += curr.total;
                 result.count++
             },
     initial: { total : 0, count: 0 }
   }
)

// 返回的结果
[
  { "day_of_week": 0, "total": 50, count: 2 },
  { "day_of_week": 1, "total": 25, count: 1 },
  { "day_of_week": 2, "total": 50, count: 2 },
  { "day_of_week": 3, "total": 50, count: 2 },
  { "day_of_week": 4, "total": 50, count: 2 },
  { "day_of_week": 5, "total": 50, count: 2 },
  { "day_of_week": 6, "total": 50, count: 2 },
]
```

#### 聚合操作三

```js
// Example Collection
db.skills.find();
[
  { "time" : ISODate("2015-08-26T04:00:00Z"), "name" : "abc1", "total" : 25 },
  { "time" : ISODate("2015-08-27T04:00:00Z"), "name" : "abc2", "total" : 25 },
  { "time" : ISODate("2015-08-28T04:00:00Z"), "name" : "abc3", "total" : 25 },
  { "time" : ISODate("2015-08-29T04:00:00Z"), "name" : "abc4", "total" : 25 },
  { "time" : ISODate("2015-08-30T04:00:00Z"), "name" : "abc5", "total" : 25 },
  { "time" : ISODate("2015-08-31T04:00:00Z"), "name" : "abc6", "total" : 25 },
  { "time" : ISODate("2015-09-01T04:00:00Z"), "name" : "abc7", "total" : 25 },
  { "time" : ISODate("2015-09-02T04:00:00Z"), "name" : "abc8", "total" : 25 },
  { "time" : ISODate("2015-09-03T04:00:00Z"), "name" : "abc9", "total" : 25 },
  { "time" : ISODate("2015-09-04T04:00:00Z"), "name" : "abc10", "total" : 25 },
  { "time" : ISODate("2015-09-05T04:00:00Z"), "name" : "abc11", "total" : 25 },
  { "time" : ISODate("2015-09-06T04:00:00Z"), "name" : "abc12", "total" : 25 },
  { "time" : ISODate("2015-09-07T04:00:00Z"), "name" : "abc13", "total" : 25 },
]

// 使用 finalize 来改变输出 的结构
db.skills.group(
   {
     keyf: function(doc) {
               return { day_of_week: doc.time.getDay() };
            },
     cond: { total: { $gt: 20 } },
     reduce: function( curr, result ) {
                 result.total += curr.total;
                 result.count++
             },
     initial: { total : 0 , count: 0}
     finalize: function(result) {
                var weekdays = [
                    "Sunday",
                    "Monday",
                    "Tuesday",
                    "Wednesday",
                    "Thursday",
                    "Friday",
                    "Saturday"
                ];
                result.day_of_week = weekdays[result.day_of_week];
                result.avg = Math.round(result.total / result.count);
              }
   }
)

// 返回的结果
[
  { "day_of_week": "Sunday", "avg": 25 },
  { "day_of_week": "Monday", "avg": 25 },
  { "day_of_week": "Tuesday", "avg": 25 },
  { "day_of_week": "Wednesday", "avg": 25 },
  { "day_of_week": "Thursday", "avg": 25 },
  { "day_of_week": "Friday", "avg": 25 },
  { "day_of_week": "Saturday", "avg": 25 },
]
```

**mapReduce** ：强大的聚合工具，`count` 、 `distinct` 和 `group` 的任务他都能做。

- `parameter` ： 如下表所述 。
- `return` ： Object ，操作之后的文档。

#### mapReduce 的调用方法如下：

```js
db.collection.mapReduce(
  map, // function
  reduce, // function
  {
    out: // collection,
    query: // document,
    sort: // document,
    limit: // number,
    finalize: // function,
    scope: // document,
    jsMode: // boolean,
    verbose: // boolean
  }
)
```

| 参数名        | 类型           | 描述        |
| :----------:|:--------------| :----------:|
| `map` | Javascript function | 映射函数，可以理解为根据 `key` 分组（生成键值对序列，作为reduce函数参数），这个操作要么`无作为`，要么`返回一些键和值`，函数通过 `this` 关键字来映射整个文档，通过调用 `emit` 函数”返回“要处理的键和值|
| `reduce` | Javascript function | 统计函数，接收 `map` emit 过来的 `key` 和 `value`，`reduce` 会处理每一个分组，|
| `options` | document | 为 `mapReduce` 指定附加参数的选项，详细如下表 |

**测试数据** 以下例子都使用该 mork 数据

```js
db.test.find();
[
  { "_id": "1", "name": "user1", "age": 18 },
  { "_id": "2", "name": "user2", "age": 20 },
  { "_id": "3", "name": "user3", "age": 15 },
  { "_id": "4", "name": "user4", "age": 30 },
  { "_id": "5", "name": "user5", "age": 15 },
  { "_id": "6", "name": "user6", "age": 18 },
  { "_id": "7", "name": "user7", "age": 60 },
  { "_id": "8", "name": "user8", "age": 30 },
  { "_id": "9", "name": "user9", "age": 25 },
  { "_id": "10", "name": "user10", "age": 20 },
  { "_id": "11", "name": "user11", "age": 60 },
  { "_id": "12", "name": "user12", "age": 80 },
  { "_id": "13", "name": "user13", "age": 60 },
  { "_id": "14", "name": "user14", "age": 80 },
  { "_id": "15", "name": "user15", "age": 42 },
  { "_id": "16", "name": "user16", "age": 42 },
  { "_id": "17", "name": "user17", "age": 42 },
  { "_id": "18", "name": "user18", "age": 15 },
  { "_id": "19", "name": "user19", "age": 1 },
  { "_id": "20", "name": "user20", "age": 0 },
]

```

#### Map 函数详解

```js
var map = function() {
    // 简单的对 document 进行按 age 分组。
    // key: age, values: name<Array>
    emit(this.age, this.name);
};
```

**结果** 根据 key 进行分组

```js
// 第一组
{ 0, [ "user20" ]}
// 第二组
{ 1, [ "user19" ]}
// 第三组
{ 15, [ "user3", "user5", "user18" ]}
// 第四组
{ 18, [ "user1", "user6" ]}
// 第五组
{ 20, [ "user2", "user10" ]}
// 第六组
{ 25, [ "user9" ]}
// 第七组
{ 30, [ "user4", "user8" ]}
// 第八组
{ 42, [ "user15", "user16", "user17" ]}
// 第九组
{ 60, [ "user7", "user11", "user13" ]}
// 第十组
{ 80, [ "user12", "user14" ]}
```

```js
// map 里面也可以使用过滤操作
var map = function() {
    var type;
    if ( 0 < this.age <= 18 ) {
        type = "未成年人"
    } else if ( 18 < this.age < 60 ) {
        type = "成年人"
    } else {
        type = "老年人"
    };
    emit(type, this.name);
}
```

**结果** 按年龄段分组，分为`未成年人`、`成年人`和`老年人`

```js
// 第一组
{ "未成年人", [ "user1", "user3", "user5", "user6", "user18", "user19", "user20" ]}
// 第二组
{ "成年人", [ "user2", "user4", "user8", "user9", "user10", "user15", "user16", "user17" ]}
// 第三组
{ "老年人", [ "user7", "user11", "user12", "user13", "user14" ]}
```

#### Reduce 函数详解

```js
// reduce 回处理每一个分组
// 我们这里使用第二种分组方法返回的结果作为函数的参数，即按年龄段分组作为参数。
var reduce = function(key, values) {
    var result = { key: values }

    if (result.key === "未成年人") {
        result.message = "青春是你们最大的财富。";
    } else if (result.key === "成年人") {
        result.message = "你们正站在人生的巅峰。"；
    } else {
        result.message = "人老心未老，豪气冲云霄。"；
    }

    return ret;
}
```

**结果** 经过 `reduce` 处理后的数据如下：

```js
> var count  = db.books.mapReduce(map, reduce, { out: "people_results" });
> db.people_results.find()
{
    "未成年人": [ "user1", "user3", "user5", "user6", "user18", "user19", "user20" ],
    "message": "青春是你们最大的财富。"
}
{
    "成年人": [ "user2", "user4", "user8", "user9", "user10", "user15", "user16", "user17" ],
    "message": "你们正站在人生的巅峰。"
}
{
    "老年人": [ "user7", "user11", "user12", "user13", "user14" ],
    "message": "人老心未老，豪气冲云霄。"
}
```

#### Options 参数详解

| 参数名        | 类型           | 描述        |
| :----------:|:--------------| :----------:|
| `out` | String OR Document |指定 `mapReduce` 最后结果集的输出位置，结果保存的集合 |
| `keeptemp` | Boolean | 连接关闭时是否保存临时结果集 |
| `query` | Document |查询条件，满足条件的文档才会作为 *input documents* 给 `map` 函数 |
| `sort` | Document | 给 *input documents* 排序 |
| `limit` | Number | 指定输入到映射函数的最大文件数 (the max number of input document)|
| `finalize` | Function | 在 `reduce` 函数之后调用，用来改变输出结果集的结构或数据 |
| `scope` | Document | 声明”全局“变量，这些变量可以在 `map` ， `reduce` 和 `finalize` 函数中使用 |
| `jsMode` | Boolean | 布尔值，是否 **减少** 执行过程中 BSON 和 JS 的转换，默认 `true`, **注**： *false* 时: `BSON => JS => map => BSON => JS => reduce => BSON`, *true* 时: `BSON => js => map => reduce => BSON` |
| `verbose` | Boolean | 布尔值，是否产生更加详细的服务器日志，默认 `true` |

#### 综合实例

```js
// map 函数
var mapFunc = function() {
    var type;
    if ( 0 < this.age <= 18 ) {
        type = "未成年人"
    } else if ( 18 < this.age < 60 ) {
        type = "成年人"
    } else {
        type = "老年人"
    };
    emit(type, this.name);
}
// reduce 函数
var reduceFunc = function() {
    var result = { key: values }

    if (result.key === "未成年人") {
        result.message = "青春是你们最大的财富。";
    } else if (result.key === "成年人") {
        result.message = "你们正站在人生的巅峰。"；
    } else {
        result.message = "人老心未老，豪气冲云霄。"；
    }

    return resultVal;
}
// finalize 函数
var finalizeFunc = function(key, resultVal) {
    resultVal.message = resultVal.message + scope;
}

// mapReduce 调用
db.test.mapReduce(
    mapFunc,
    reduceFunc,
    {
        out: "people_results",
        query: { age : { $gt: 10 } }
        sort: { name: 1 }
        finalize: finalizeFunc
        scope: { scope: "全局变量" }
    }
)
```

**结果** 经过 `reduce` 处理后的数据如下：

```js
{
    "未成年人": [ "user1", "user3", "user5", "user6", "user18", "user19", "user20" ],
    "message": "青春是你们最大的财富。全局变量"
}
{
    "成年人": [ "user2", "user4", "user8", "user9", "user10", "user15", "user16", "user17" ],
    "message": "你们正站在人生的巅峰。全局变量"
}
{
    "老年人": [ "user7", "user11", "user12", "user13", "user14" ],
    "message": "人老心未老，豪气冲云霄。全局变量"
}
```

# MongoDB 语法包含了更新、查询、索引、聚合、管理、分片、复制

## MongoDB 查询操作

## API 文档
[点击查看 API](http://docs.mongodb.org/manual)

---------------------------------------------------------------------------------------------

### 查询

#### 查询方法： [查看所有方法](http://docs.mongodb.org/manual/tutorial/query-documents)

**find(query\<Object\>)**：（查询所有）
```js
// 查询所有博客，不传或传 {} 表示查询所有
db.blog.find();
/* 0 */
{
    "_id" : ObjectId("549cab0bd1594c1c0c2b4e9a"),
    "username" : "charleslxh@icloud.com",
    "password" : "abc123_",
    "number" : 20,
    "friends" : [
        {
            "name" : "justin",
            "age" : "20",
            "school" : "University"
        },
        {
            "name" : "cherry",
            "age" : "18",
            "school" : "University"
        },
        {
            "name" : "bob",
            "age" : "22",
            "school" : "University"
        },
        {
            "name" : "anson",
            "age" : "23",
            "school" : "University"
        },
        {
            "name" : "charles",
            "age" : "20",
            "school" : "University"
        }
    ]
}

/* 1 */
{
    "_id" : ObjectId("549cab18d1594c1c0c2b4e9b"),
    "username" : "cherryxu@icloud.com",
    "password" : "12345678",
    "number" : 21,
    "friends" : [
        {
            "name" : "justin",
            "age" : "20",
            "school" : "University"
        },
        {
            "name" : "cherry",
            "age" : "18",
            "school" : "University"
        },
        {
            "name" : "bob",
            "age" : "22",
            "school" : "University"
        },
        {
            "name" : "anson",
            "age" : "23",
            "school" : "University"
        },
        {
            "name" : "charles",
            "age" : "20",
            "school" : "University"
        }
    ]
}
```

**findOne(query\<Object\>)** ： 同 `find()` 但只返回第一个匹配的文档。

**skip(number\<Number\>)** ： skip 会略过 前 number 个匹配的文档，然后返回余下的文档。如果匹配集合里文档少于 number 个，则不会返回任何文档。

**limit(number\<Number\>)** ： limit 上限函数，最多返回 number 结果，如果文档少于 number 个，则全部返回。

**sort({ key1: 1 | -1, key2: 1 | -1, ... })** ： sort 排序函数，按参数逐个排序，1： 升序，-1： 降序。

limit, sort, skip 可以组合使用。略过过多会导致性能问题，尽量避免使用。

不适用 skip 进行分页： skip 略过太多内容性能会很慢。

可用如下方式分页：

```js
// 获取第一页的数据
var page1 = db.test.find().sort({ "date": -1 }).limit)(100)

var lastest = null

while(page1.hasNext()) {
    lastest = page1.next();
    display(lastest)
}

// 获取第二页的数据
var page2 = db.test().find({ "date": { &gt: lastest.date } }).sort({ "date": -1 }).limit(100);

```

**count()** ： `count()` 查询记录条数，忽略限制条件。 `count(true | 非0)` 查询限制条件之后的记录条数。

```js
db.blog.find().count();
15
db.blog.find().limit(10).skip(5).count();
15
db.blog.find().limit(10).skip(5).count(true);
5
```

**高级查询** 详细情况请参考 [MongoDB 聚合查询]()

-    `$maxscan <integer>` ： 指定查询最多扫描的文档数量。

```js
db.blog.find().limit(2).skip(1).sort({ number: 1 }).explain()
```

-    `$min <document>` ： 查询的开始条件。

-    `$max <document>` ： 查询的结束条件。

-    `$hint <document>` ： 指定服务器使用哪个索引进行查询。

-    `$explain <boolean>` ： 获取查询执行的细节，而并非真正执行查询。

-    `$snapshot <boolean>` ： 确保查询的结果是在查询执行那一刻的一致快照。

---------------------------------------------------------------------------------------------

#### 修改器: [查看所有修改器](http://docs.mongodb.org/manual/reference/operator/update/ update 修改器)

**`查询选择器`**：（Comparison）

| 名字        | 描述           | 名字        | 描述           |
| :----------:|:--------------| :----------:|:--------------|
| `$eq`   | 匹配与指定值 **相等** 的字段 | `$ne`   | 匹配所有与指定值 **不相** 等字段 |
| `$gt`   | 匹配 **大于**  指定值的字段 | `$lt`   | 匹配 **小于** 指定值的字段 |
| `$gte`   | 匹配 **大于** 或 **等于** 指定值的字段 | `$lte`   | 匹配 **小于** 或 **等于** 指定值的字段 |
| `$in`   | 匹配所有 **包含于** 指定数组的字段 | `$nin`   | 匹配所有 **不包含于**指定数组的字段 |

```js
// 查询 username 为 cherryxu@icloud.com， 并且 friends 中 年龄大于 20 的博客
db.blog.find({ "username" : "cherryxu@icloud.com", "friends.age": { $gt: 20 } });
{
    "_id" : ObjectId("549cab18d1594c1c0c2b4e9b"),
    "username" : "cherryxu@icloud.com",
    "password" : "12345678",
    "number" : 21,
    "friends" : [
        {
            "name" : "bob",
            "age" : "22",
            "school" : "University"
        },
        {
            "name" : "anson",
            "age" : "23",
            "school" : "University"
        }
    ]
}
// 查询 username 为 cherryxu@icloud.com， 并且 friends 中 名字有 justin、cherry 的博客
db.blog.find({"password" : "12345678", "friends.name": { $in: [ "justin", "cherry" ] }});
{
    "_id" : ObjectId("549cab18d1594c1c0c2b4e9b"),
    "username" : "cherryxu@icloud.com",
    "password" : "12345678",
    "number" : 21,
    "friends" : [
        {
            "name" : "justin",
            "age" : "20",
            "school" : "University"
        },
        {
            "name" : "cherry",
            "age" : "18",
            "school" : "University"
        }
    ]
}
```

**`逻辑选择器`**：（Logical）

| 名字        | 描述           |
| :----------:|:--------------|
| `$or`  | 只要匹配到 **OR** 条件中的任意一条都会返回这个文档，`OR` 接受一个包含多个条件的数组，并且可以包含其他条件选择器 { $or: [ { num: { $in: [1, 2, 3] } }, { name: 'justinliao' } ] } |
| `$and`  | 只有满足 **AND** 中的所有条件才能返回文档 |
| `$not`  | 元条件句，返回与条件 **不相符** 的文档 |
| `$nor`  | 返回 **不满足** 所有条件的文档，刚好事 `$or` 运算结果的 *补集* |

```js
// 查询 username 为 cherryxu@icloud.com， 或 password 是 00000 的博客
db.blog.find({$or: [ {"username": "cherryxu@icloud.com"}, { "password": "00000" } ]});
{
    "_id" : ObjectId("549cab0bd1594c1c0c2b4e9a"),
    "username" : "cherryxu@icloud.com",
    "password" : "abc123_",
    "number" : 20,
    "friends" : [
        {
            "name" : "justin",
            "age" : "20",
            "school" : "University"
        },
        {
            "name" : "cherry",
            "age" : "18",
            "school" : "University"
        },
        {
            "name" : "bob",
            "age" : "22",
            "school" : "University"
        },
        {
            "name" : "anson",
            "age" : "23",
            "school" : "University"
        },
        {
            "name" : "charles",
            "age" : "20",
            "school" : "University"
        }
    ]
}

// 查询 username 为 cherryxu@icloud.com， 并且 password 是 00000 的博客
db.blog.find({$and: [ {"username": "cherryxu@icloud.com"}, { "password": "00000" } ]});
{}
```

**`元素选择器`**：（Element）

| 名字        | 描述           |
| :----------:|:--------------|
| `$exists`  | 匹配某字段存在或不存在，`{ key: { $exists: true } }` 该字段必须存在，就返回。否则 `false` 表示该字段不存在的情况就返回 |
| `$type`   | 匹配某键值是指定类型就返回 `{ key: { $type: <BSON type} }` |

**BSON type 的取值如下**

- `Double`：  1
- `String`  2
- `Object`  3
- `Array`   4
- `Binary data` 5
- `Undefined`   6   Deprecated.
- `Object id`   7
- `Boolean` 8
- `Date`    9
- `Null`    10
- `Regular Expression`  11
- `JavaScript`  13
- `Symbol`  14
- `JavaScript (with scope)` 15
- `32-bit integer`  16
- `Timestamp`   17
- `64-bit integer`  18
- `Min key` 255
- `Max key` 127

```js
// 查找 username 是 cherryxu@icloud.com， 并且 password 必须存在的情况下返回文档
db.blog.find({"username": "cherryxu@icloud.com", "password": { $exists: true }});
{
    "_id" : ObjectId("549cab0bd1594c1c0c2b4e9a"),
    "username" : "cherryxu@icloud.com",
    "password" : "abc123_",
    "number" : 20,
    "friends" : [
        {
            "name" : "justin",
            "age" : "20",
            "school" : "University"
        },
        {
            "name" : "cherry",
            "age" : "18",
            "school" : "University"
        },
        {
            "name" : "bob",
            "age" : "22",
            "school" : "University"
        },
        {
            "name" : "anson",
            "age" : "23",
            "school" : "University"
        },
        {
            "name" : "charles",
            "age" : "20",
            "school" : "University"
        }
    ]
}
// 查找 username 是 cherryxu@icloud.com， 并且 password 必须不存在的情况下返回文档
db.blog.find({"username": "cherryxu@icloud.com", "password": { $exists: false }});
{}

// 查找 username 是 cherryxu@icloud.com， 并且 password 的类型是 Double
db.blog.find({"username": "cherryxu@icloud.com", "password": { $type: 2 }});
{}

// 查找 username 是 cherryxu@icloud.com， 并且 password 的类型是 String
// 结果如 "password": { $exists: true } 的查询结果
db.blog.find({"username": "cherryxu@icloud.com", "password": { $type: 1 }});

```

**`值选择器`**：（Evaluation）

| 名字        | 描述           |
| :----------:|:--------------|
| `$mod`  | 匹配键值对第一个数`取余`是第二个数的文档 `{ key: { $mod: [ 4, 0 ] } }` |
| `$regex` | 匹配键值符合正则表达式的文档 `{ key: { $regex: you regex, $options: options } }`|
| `$text`  | 全文搜素，查询所有键值包含 `$search` 里的内容的文档， `{ $text: { $search: <string>, $language: <string} }` |
| `$where` | 匹配满足 `JavaScript` 表达式的文档，他可以使用任意的JavaScript作为查询的一部分,包含 *JavaScript表达式的字符串* 或者 *JavaScript函数* |

**$regex options 详解**

- `i`  　如果设置了这个修饰符，模式中的字母会进行大小写 **不敏感** 匹配。
- `m`   默认情况下，PCRE 认为目标字符串是由单行字符组成的(然而实际上它可能会包含多行).如果目标字符串中没有 "\n" 字符，或者模式中没有出现“行首”/“行末”字符，设置这个修饰符不产生任何影响。对于正则表达式中含有这些字符的（`^`　代表以什么开头　或　`$`以　什么结尾）将会对一个含有多行的字符串组成的一个字符串( **即含有换行符\n** ) 只匹配这行的开头或结尾，如果设置此选项，将会视每一个换行符分割的字符串进行匹配。示例如下：
- `s`    如果设置了这个修饰符，模式中的点号元字符 **匹配所有字符**，包含换行符。如果没有这个修饰符，点号不匹配换行符。
- `x`    如果设置了这个修饰符，模式中的没有经过转义的或不在字符类中的空白数据字符总会被忽略，并且位于一个未转义的字符类外部的#字符和下一个换行符之间的字符也被忽略。 这个修饰符使被编译模式中可以包含注释。 注意：这仅用于数据字符。 空白字符 还是不能在模式的特殊字符序列中出现，比如序列。

```js
// Options 'i', config this opotion, the partten will match the upper and lower cases.
db.products.find( { sku: { $regex: /^ABC/i } } )

// With 'i' option, the query matchs following documents.
{ "_id" : 100, "sku" : "AbC123", "description" : "Single line description." }
{ "_id" : 101, "sku" : "abc789", "description" : "First line\nSecond line" }
```

```js
// Options about 'm', multiline match for lines starting or ending with a special word.
db.products.find( { description: { $regex: /^S/, $options: 'm' } } )

// With configged the options with 'm', the result may query those documents.
{ "_id" : 100, "sku" : "abc123", "description" : "Single line description." }
{ "_id" : 101, "sku" : "abc789", "description" : "First line\nSecond line" }

// Without configged the options with 'm', but with this options the result just this document.
{ "_id" : 100, "sku" : "abc123", "description" : "Single line description." }
```

```js
// Options about 's', Allow the partten to match all characters including newline character,
// If without configged this options, it will ignore the newline character.
db.products.find( { description: { $regex: /m.*line/, $options: 'si' } } )

// With the 's' option. the query matches the following documents.
{ "_id" : 102, "sku" : "xyz456", "description" : "Many spaces before     line" }
{ "_id" : 103, "sku" : "xyz789", "description" : "Multiple\nline description" }

// Without 's' option, the '.' donesn't match the newline character.
{ "_id" : 102, "sku" : "xyz456", "description" : "Many spaces before     line" }
```

**Behavior**
The different in `$regex` and `/pattern/`:
-   To include a regular expression in `$in` query expression. You can only use the Javascript regular expression
    (i.e. `/pattern/`), For example:

```js
    { name: { $in: [ /^acme/i, /^ack/ ] } }
```

-   To include a regular expression in comma-separated list of query conditions for the field, use the $regex
    operator. For example:

```js
    { name: { $regex: /acme.*corp/i, $nin: [ 'acmeblahcorp' ] } }
    { name: { $regex: /acme.*corp/, $options: 'i', $nin: [ 'acmeblahcorp' ] } }
    { name: { $regex: 'acme.*corp', $options: 'i', $nin: [ 'acmeblahcorp' ] } }
```

-   To use `x` or `s` options, you must use `$regex` and `$options`, For example:

```js
    { name: { $regex: /acme.*corp/, $options: "si" } }
    { name: { $regex: 'acme.*corp', $options: "si" } }
```

-   To use some supported features in PCRE(Pore) regular expression, but those features unsupported by Javascript.
    You must use the `$regex` operator expression with the pattern as a string. For example: `(?!)` or `(?-i)`
    or `(?<=)` , they are unsupported in Javascript regular expression.

```js
    { name: { $regex: '(?i)a(?-i)cme' } }
```
**注意**：

-  在查询以 `a` 开头字符串时，可以有三种形式， `/^a/`, `/^a./`,和`/^a.$/` 。后面两种形式会扫描整个字符串，查询速度会变慢。
第一种形式会在查到符合的开头后停止扫描后面的字符。
-


**全文搜索支持的语言()$language**: `danish` `dutch` `english` `finnish` `french` `german` `hungarian``italian` `norwegian` `portuguese` `romanian` `russian` `spanish` `swedish` `turkish`

```js
// 查找 username 是 cherryxu@icloud.com， 并且 number 能被 4 整除
db.blog.find({"username": "cherryxu@icloud.com", "number": { $mod: [ 4, 0 ] } });
{
    "_id" : ObjectId("549cab0bd1594c1c0c2b4e9a"),
    "username" : "cherryxu@icloud.com",
    "password" : "abc123_",
    "number" : 20,
    "friends" : [...] // 此处省略
}

// 查找 username 是 cherryxu@icloud.com， 并且 password 是以下划线结尾的，si 表示不敏感匹配所有字符
db.blog.find({"username": "cherryxu@icloud.com", "password": { $regex: /._/i, $options: 'si' } });
{
    "_id" : ObjectId("549cab0bd1594c1c0c2b4e9a"),
    "username" : "cherryxu@icloud.com",
    "password" : "abc123_",
    "number" : 20,
    "friends" : [...] // 此处省略
}

// 给某一个字段建立全文搜索的索引
db.blog.createIndex( { password: "text" } );
// 根据全文搜索索引查找 password 为 abc123_ 的文档
db.blog.find( { $text: { $search: "abc123_" } } );
{
    "_id" : ObjectId("549cab0bd1594c1c0c2b4e9a"),
    "username" : "cherryxu@icloud.com",
    "password" : "abc123_",
    "number" : 20,
    "friends" : [...] // 此处省略
}

// 查询 number 大于 20， 且密码不能为空的文档（javascript 表达式）
db.blog.find({ $where: "this.password != null && this.number > 20" });
// 查询 number 大于 20， 且密码不能为空的文档（javascript 函数）
db.blog.find({ $where: function() { return (this.password != null && this.number > 20) } });
{
    "_id" : ObjectId("549cab18d1594c1c0c2b4e9b"),
    "username" : "cherryxu@icloud.com",
    "password" : "12345678",
    "number" : 21,
    "friends" : [...] // 此处省略
}
```

**`数组选择器`**：（Array）

| 名字        | 描述           |
| :----------:|:--------------|
| `$all`  | 匹配那些指定键的键值中包含数组，而且该数组包含条件指定数组的所有元素的文档,数组中元素顺序不影响查询结果 `{ key: { $all: [ "book", "pencil" ] } }` |
| `$elemMatch` | 匹配数组中每一个满足条件的文档 `{ arrName: { $elemMatch: { key: value, score: { $gte: 30 } } } }`, 如果条件是一个单一的话，`{ arrName: { $elemMathch: { score: { $gte: 30} } } }` 相当于 `{ arrName.score: { $gte: 30} }`|
| `$size`  | 用其查询指定长度的数组 `{ arrName: { $size: 2 }`, 注： `$size` 只接收一个 `Number` |

```js
// 插入三条数据
db.inventory.insert(
{
    "name": "t1",
    "amount": 16,
    "tags": [ "school", "book", "bag", "headphone", "appliances" ]
},
{
    "name": "t2",
    "amount": 50,
    "tags": [ "appliances", "school", "book" ]
},
{
    "name": "t3",
    "amount": 58,
    "tags": [ "bag", "school", "book" ]
});

// 查询出在集合 inventory 中 tags 键值包含数组，且该数组中包含 appliances、school、 book 元素的所有文档
db.inventory.find({ tags: { $all: [ "appliances", "school", "book" ] } })
// 该查询将匹配tags键值包含如下任意数组的所有文档:
{
    "name": "t1",
    "amount": 16,
    "tags": [ "school", "book", "bag", "headphone", "appliances" ]
},
{
    "name": "t2",
    "amount": 50,
    "tags": [ "appliances", "school", "book" ]
}

// 查询出在集合 inventory 中 tags 数组长度是 5 的文档
db.inventory.find({ tags: { $size: 5 } })
{
    "name": "t1",
    "amount": 16,
    "tags": [ "school", "book", "bag", "headphone", "appliances" ]
}

// 查询 username 是 cherryxu@icloud.com， 且 friends 中 年龄大于 20 的
db.blog.find({"username": "cherryxu@icloud.com", "friends": { $elemMatch: { "school": "University", "age": { $gt: 20 } } } });
{
    "_id" : ObjectId("549cab0bd1594c1c0c2b4e9a"),
    "username" : "cherryxu@icloud.com",
    "password" : "abc123_",
    "number" : 20,
    "friends" : [
        {
            "name" : "bob",
            "age" : "22",
            "school" : "University"
        },
        {
            "name" : "anson",
            "age" : "23",
            "school" : "University"
        }
    ]
}
```

**`选择器`**：（Comments）

| 名字        | 描述           |
| :----------:|:--------------|
| `$comment`  | 给您的查询条件添加注释，便与理解和跟踪，它并不会影响你的查询结果|

```js
db.blog.find({"username" : "charleslxh@icloud.com", $comment: "Find even values."});
{
    "_id" : ObjectId("549cab0bd1594c1c0c2b4e9a"),
    "username" : "charleslxh@icloud.com",
    "password" : "abc123_",
    "number" : 20,
    "friends" : [...] // 此处省略
}
```

**`视图选择器`**：（Projection Operators）

| 名字        | 描述           |
| :----------:|:--------------|
| `$`  | 返回匹配到的数组的第一个元素，不设置则返回所有符合条件的值，`{ "grades.mean": { $gt: 70 } }, { "grades.$": 1 }` 若 `grades` 数组中有多个元素的 `mean` 属性值大于70，但是又 `$` 所以结果只返回第一个属性值大于70的元素|
| `$elemMatch` | 同数组的 `$elemMatch`|
| `$slice` | 此操作符根据参数"{ field: value }" 指定键名和键值选择出文档集合，并且该文档集合中指定"array"键将返回从指定数量的元素。如果count的值大于数组中元素的数量，该查询返回数组中的所有元素的。，`db.blog.find({ key: value },{ friends: { $slice: [1,3] } })`，返回文档中 `friends` 的值从第 `1` 个开始返回 `3` 个|

```js
// 返回 friends
db.blog.find({ "friends": { $elemMatch: { "school" : "University", "age" : { $gt: 20 } } } }, { "friends.$": 1 } )
{
    "_id" : ObjectId("549cab0bd1594c1c0c2b4e9a"),
    "username" : "cherryxu@icloud.com",
    "password" : "abc123_",
    "number" : 20,
    "friends" : [
        {
            "name" : "justin",
            "age" : "20",
            "school" : "University"
        }
    ]
}
{
    "_id" : ObjectId("549cab18d1594c1c0c2b4e9b"),
    "username" : "cherryxu@icloud.com",
    "password" : "12345678",
    "number" : 21,
    "friends" : [
        {
            "name" : "justin",
            "age" : "20",
            "school" : "University"
        }
    ]
}

// 根据 username 为 cherryxu@icloud.com 查出的结果，在对该结果的 friends 字段取第一个元素
db.blog.find({"username": "cherryxu@icloud.com"}, {"friends": { $slice: 1 } });
{
    "_id" : ObjectId("549cab0bd1594c1c0c2b4e9a"),
    "username" : "cherryxu@icloud.com",
    "password" : "abc123_",
    "number" : 20,
    "friends" : [
        {
            "name" : "justin",
            "age" : "20",
            "school" : "University"
        }
    ]
}

// 根据 username 为 cherryxu@icloud.com 查出的结果，在对该结果的 friends 字段取第一个元素
db.blog.find({"username": "cherryxu@icloud.com"}, {"friends": { $slice: -1 } });
{
    "_id" : ObjectId("549cab0bd1594c1c0c2b4e9a"),
    "username" : "cherryxu@icloud.com",
    "password" : "abc123_",
    "number" : 20,
    "friends" : [
        {
            "name" : "charles",
            "age" : "20",
            "school" : "University"
        }
    ]
}

// 根据 username 为 cherryxu@icloud.com 查出的结果，在对该结果的 friends 字段从第二个元素开始取两个元素
db.blog.find({"username": "cherryxu@icloud.com"}, {"friends": { $slice: [2, 2]  } });
{
    "_id" : ObjectId("549cab0bd1594c1c0c2b4e9a"),
    "username" : "cherryxu@icloud.com",
    "password" : "abc123_",
    "number" : 20,
    "friends" : [
        {
            "name" : "cherry",
            "age" : "18",
            "school" : "University"
        },
        {
            "name" : "bob",
            "age" : "22",
            "school" : "University"
        }
    ]
}
```

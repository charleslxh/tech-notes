# MongoDB 语法包含了更新、查询、索引、聚合、管理、分片、复制

## MongoDB 更新操作（创建、插入、删除）

## API 文档
[点击查看 API](http://docs.mongodb.org/manual)

---------------------------------------------------------------------------------------------

### 创建

**插入** 是向 `MongoDB` 添加数据的基本方法

**1**： 对目标集合使用 `insert` 方法，插入一个文档

```bash
db.foo.insert({
    "name": "mongoDB grammer",
    "author": "Justin Liao",
    "createAt": "ISODate("2015-07-28T16:00:00.000Z")",
    "email": "charleslxh@icloud.com"
})
```

**2**： 使用 save 操作保存一个文档。

```bash
db.products.save( { item: "book", qty: 40 } )
```

**insert** 和 **save**的区别: 如果插入的集合的值，在集合中已经存在,用 Insert 执行插入操作回报异常，已经存在 *_id* 的键。用Save如果系统中没有相同的 *_id* 就执行插入操作，有的话就执行覆盖掉原来的值。相当于修改操作。我这里就不做演示了。

**批量插入** 如果要插入多个文档，可以使用批量插入。批量插入能传递一个由`文档构成的数组`的数据库。一次插入和一次批量插入都是一个单一的 TCP 请求
，也就是说避免了数据库处理请求头之类所带来的时间开销，就能减少插入时间。

```bash
arr = [
    { "book": "Clean Code" },
    { "author": "Robert C.Martin" },
    { "description": "A Handbook of Agile Software Craftsmanship" }
]
db.foo.insert(arr)
```

**导入、导出数据源** `mongoimport` 和 `mongoexport`, *命令行命令*

**mongoimport** 参数说明： (更多参数使用 `mongoimport --help`)
  - `h`: 指明数据库宿主机的 IP
  - `u`: 指明数据库的用户名
  - `p`: 指明数据库的密码
  - `d`: 指明数据库的名字
  - `c`: 指明 collection 的名字
  - `f`: 指明要导入那些列
  - `type`: 指明要导入的文件格式
  - `headerline`: 指明第一行是列名，不需要导入
  - `file`： 指明要导入的文件

```shell
[user@localhost mongodb]# mongoimport -d test -c students students.dat
```

**mongoexport** 参数说明： (更多参数使用 `mongoexport --help`)
  - `d`: 指明使用的库，本例中为 test
  - `c`: 指明要导出的集合，本例中为 students
  - `o`: 指明要导出的文件名，本例中为 students.dat
  - `csv`： 指明要导出为 csv 格式
  - `f`： 指明需要导出 classid 、 name 、 age 这3列的数据

```shell
[root@localhost mongodb]# mongoexport -d test -c students --csv -f classid, name, age -o students_csv.dat
```

**插入：原理和作用**
当执行插入的时候，您所使用的驱动程序会将数据转换为 BSON （关于 `BSON` 请见下文）格式，数据库解析 BSON ，检验是否包含 *_id*，并且文档不超过4M，除此之外不做其他验证，简单将文档存入数据库。

**安全性** MongoDB 在插入式是不会执行代码的，所以这块代码没有注入式攻击的可能。传统的注入式攻击对 MongoDB 无效。

**BSON** Binary JSON，轻量级二进制格式，能将 MongoDB 所有文档表示为字节字符串。数据库能理解 BSON，存在磁盘上的文档也是这种格式。
 BSON 的三个主要目标：
  - `效率`： BSON 设计更加有效的表示数据，占用更少的空间。最差比 JSON 效率略低，最好情况（存放二进制数据或大数）BSON效率高得多
  - `可遍历性`： BSON 牺牲了空间效率，换取了更容易遍历的格式。例如在字符串面前加入其长度，而不是在结尾加入一个终结符。
  - `性能`： BSON 的编码和解码速度非常快
关于 [BSON](http://www.bsonspec.org 点击查看 BSON) 详细说明，参见 http://www.bsonspec.org

---------------------------------------------------------------------------------------------

### 删除文档

删除的速度会很快，但是要清除整个几何，直接删除集合（然后重新建立索引）会更快。

**删除所有文档** 使用 `remove()`

```shell
> db.users.remove()
```

**删除指定文档** 使用 `remove（condition）`

```shell
> db.users.remove({ "name": "justinliao" })
```

**删除** 使用drop()删除集合, 使用dropDatabase()函数删除数据库

```shell
> db.userdetails.drop()
```

```shell
> db.dropDatabase()
```

---------------------------------------------------------------------------------------------

### 更新文档

当文档存入数据库以后，就可以使用 `update` 的方法来修改它。更新是原子的，若是两个更新同时发生，先到服务器的先执行，接着执行另外一个，所以相互有冲突的更新可以火速传递，并不会相互干扰，最后的更新会取得”胜利“。

#### update参数： update( query, modifier, upsert, multi )
- `query`:  查询文档 Object 例如：{ "userId": "justin.liao" }
- `modifier`: 更新文档 Object 例如： { "username": "Justin Liao" }
- `upsert`: 是否插入式更新 Boolean
- `multi`: 是否更新多个文档 Boolean

```js
> db.user.find()
[{ "_id": ObjectId("a3b4c5d6e7f8g1h2i9j0k4l2"),
  "name": "justinliao",
  "email": "charleslxh@icloud.com",
  "major": "information security",
  "location": "ShangHai China"
},
{ "_id": ObjectId("a3b4c5d6e7f8g1h2i9j0k4l2"),
  "name": "cherryxu",
  "email": "cherryxu@icloud.com",
  "major": "information security",
  "location": "ShangHai China"
}]

> db.user.update( { "major": "information security" }, { "location": "BeiJing China" }, false, true )
{ "nMatched" : 2, "nUpserted" : 0, "nModified" : 2 }

> db.user.find( { "name": "justinliao" } )
[{ "_id": ObjectId("a3b4c5d6e7f8g1h2i9j0k4l2"),
  "name": "justinliao",
  "email": "charleslxh@icloud.com",
  "major": "information security",
  "location": "BeiJing China"
}]
```

#### 修改器: [查看所有修改器](http://docs.mongodb.org/manual/reference/operator/update/ update 修改器)

**`字段修改器`**：（fileds）

| 名字        | 描述           |
| :----------:|:--------------|
|`$set`       | 用来指定一个键并更新键值，如果这个建不存在就创建它 |
|`$unset`     | 移除某个指定的字段 |
|`$setOnInsert` | 以 insert 的形式来做 set 操作，如果存在键值就不 set ，如果不存在就 insert 这个文档，常与 `{upsert:true}` 一起用 |
|`$min`       | 只有当指定的值小于现有字段值时才更新该字段 |
|`$max`      | 只有当指定的值大于现有字段值时才更新该字段 |
|`$inc`        | 用来增加已有的键的值，如果不存在就创建一个，`$inc` 只能用于整数、长整数、双精度数，`$inc` 的值只能是整数 |
|`$mul`  | 将某个指定的键值的值乘以某个数字后在赋给该键值 |
|`$rename`      | 重命名某一存在的字段的键 |
|`$currentDate`  |  将某一键值设置为当前时间，如果键值 `true` 表示默认设置为 *Date* ，如果指定了值为 `{ $type: "timestamp" }` 或 `{ $type: "date" }` 就设置指定类型 |

**`数组修改器`**：（array）

| 名字        | 描述           |
| :----------:|:--------------|
|`$`       | 修改器定位操作符，可以定位到数组的某一项进行单独操作，但是定位符只会更新匹配到的第一个元素，如果将 `mutil:true`，就可以更新所有匹配到的元素 |
|`$addToSet`     | 非重复性添加，只有当数组中不存在某一元素时才将指定值插入到数组中用户名易注册 |
|`$pop`       | 删除数组的第一个（`{$pop: { key: 1 } }`）或最后一个元素（`{$pop: { key: -1 } }`） |
|`$pullAll`      | 删除所有匹配到的元素 |
|`$pull`        | 根据特定条件来删除所有匹配到的元素 |
|`$pushAll`  | 用 `$push` 和 `$each` 可以代替这个修改器，如果你指定是 *一个*，他跟 `$pull` 是一样的 |
|`$push`      | 添加一个元素到数组的末尾 要是没有就会创建一个新的数组 |

**`辅助工具`**：（Modifiers）

| 名字        | 描述           |
| :----------:|:--------------|
|`$each`       | 遍历一个指定的数组。`{ $addToSet: { key: { $each: [0, 1, 2, 3 , 4, 5] } } }` 修饰 `$push` 和 `$addToSet` 操作
|`$slice`     | 将指定数组更新至只包含几个元素，0：将数组 set 为空数组；number < 0：数组只包含最后一个元素；number > 0：数组只包含第一个元素，修饰 `$push`操作 |
|`$sort`       | 将数组按（`1`：顺序，`-1`：倒序）排序更新，修饰 `$push`操作 |
|`$position`      | 在指定的位置 number 前插入一个或多个元素，修饰 `$push`操作, number 从0开始 |

**`位修改器`**：（Bitwise）

| 名字        | 描述           |
| :----------:|:--------------|
|`$bit`       | 执行按位与，或，异或运算对指定的值进行更新 `{ $bit: { <field>: { <and/or/xor>: <int> } } }` |

**`分割器`**：（Isolation）

| 名字        | 描述           |
| :----------:|:--------------|
|`$isolation`  | 将指定字段进行隔离，多元化操作字段时，`$isolated : 1` 将会设置某个字段值被操作一次 |

```shell
> db.book.find()
[{
  bookshop: "Amazon",
  books: [
    {
      name: "clean code",
      price: 45
    },
    {
      name: "mongoDB: The Definitive Guide",
      price: 35
    }
  ]
},
{
  bookshop: "Suning",
  books: [
    {
      name: "Java Basic",
      price: 45
    },
    {
      name: "mongoDB: The Definitive Guide",
      price: 35
    },
    {
      name: "Oracle: The Definitive Guide",
      price: 40
    }
  ]
}]

> db.book.update({ bookshop: "Amazon" }, { $push: { books: { $each: [ { name: "PHP", price: 26 } ] } } })
> db.book.find({ bookshop: "Amazon" })
{
  bookshop: "Amazon",
  books: [
    {
      name: "clean code",
      price: 45
    },
    {
      name: "mongoDB: The Definitive Guide",
      price: 35
    },
    {
      name: "PHP",
      price: 26
    }
  ]
}

> db.book.update({ bookshop: "Amazon" }, { $setOnInsert: { category: [ "technology", "literature" ] } } )
> db.book.find({ bookshop: "Amazon" })
{
  bookshop: "Amazon",
  books: [
    {
      name: "clean code",
      price: 45
    },
    {
      name: "mongoDB: The Definitive Guide",
      price: 35
    },
    {
      name: "PHP",
      price: 26
    }
  ],
  category: [ "technology", "literature" ]
}

> db.book.update({ bookshop: "Amazon" }, { $addToSet: { category: { $each: [ "physical", "literature" ] } } })
> db.book.find({ bookshop: "Amazon" })
{
  bookshop: "Amazon",
  books: [
    {
      name: "clean code",
      price: 45
    },
    {
      name: "mongoDB: The Definitive Guide",
      price: 35
    },
    {
      name: "PHP",
      price: 26
    }
  ],
  category: [ "technology", "literature", "physical" ]
}

> db.book.update({ bookshop: "Amazon" }, { $slice: { category: -1 } })
> db.book.find({ bookshop: "Amazon" })
{
  bookshop: "Amazon",
  books: [
    {
      name: "clean code",
      price: 45
    },
    {
      name: "mongoDB: The Definitive Guide",
      price: 35
    },
    {
      name: "PHP",
      price: 26
    }
  ],
  category: [ "physical" ]
}

> db.book.update({ bookshop: "Amazon" }， { $sort: { books.price: 1 } })
> db.book.find({ bookshop: "Amazon" })
{
  bookshop: "Amazon",
  books: [
    {
      name: "PHP",
      price: 26
    },
    {
      name: "mongoDB: The Definitive Guide",
      price: 35
    },
    {
      name: "clean code",
      price: 45
    }
  ],
  category: [ "physical" ]
}
```


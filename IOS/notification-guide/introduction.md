# IOS support two notification types: Local Notification and remote Notification

**About**: 两种类型的用户通知都可以做到当应用不在前台运行时通知用户。该通知可以是一个 *message* ， 也可以是一个 *即将到来的事件* 或 *远程服务器的一段新数据* 。无论是远程通知还是本地通知，当它到来时，他们会弹出通知内容，也会标记 App ，它也能发出通知声音。（ **注意**：这两种通知类型跟 *广播式通知* 和 *键值观察式通知(KVO)* 是不相关的。）

**本地通知和远程通知几个需要注意的方面：** [深入了解本地通知和远程通知](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/WhatAreRemoteNotif.html#//apple_ref/doc/uid/TP40008194-CH102-SW1)

-   **他们解决了相同的问题**：任何时间只能有一个 APP 是活跃状态（前台运行），当 APP 不在前台运行时，可能会有任何这个用户感兴趣的事件发生，
而本地通知和远程通知则允许这个 APP 去通知用户相关事件发生了。

-   **本地通知、远程通知表现形式是一样的**：An onscreen alert or banner；A badge on the app’s icon；A sound that accompanies an alert, banner, or badge

-   **他们发生的来源不一样**： *本地通知* 是由 APP 自定义并由自身发出的通知。 *远程通知* 是由 **远程服务器**（通常也叫 `Provider`）发送给 APNS（Apple Push Notification Service），由 APNS 负责推送给相应设备（`Device`）。

-   **注册、调度和处理本地和远程通知**： 如果要预设一个本地通知，这个 APP 需要注册一个通知类型，创建一个本地通知对象，分配时间，指定通知内
容等。如果要接收远程通知，这就不需要那么多的步骤，这个 APP 需要注册一个通知类型并发送一个 Device Token 到相应服务器。 **处理通知**：收到
通知后，用户可以通过滑动忽略通知（或点击通知， **注意** 在 `>= IOS8` 中用户通知种可以添加任意用户自定义操作，比如滑动回复，滑动出现点赞之
类的按钮。）

-   **APNS 是远程通知的唯一途径**：APNS 推送通知到有相应 APP 并开启了接收这些通知的设备，每个设备都会与 APNS 建立一个认证和加密过的 IP
`长连接`，通知就在这条长连接中传输；而 Provider 与 APNS 交互是通过一个持续的、安全的 TCP 通道传输信息，每当有消息需要推送时，Provider
发送给 APNS，由 APNS 推送给相应设备。

-   **远程通知需要提供安全证书**：开发远程通知的 Provider 端，你需要开发者中心获取一套 `SSL 证书`（1.    Certification(证书)
证书是对电脑开发资格的认证，每个开发者帐号有一套，分为两种：1) Developer Certification(开发证书)安装在电脑上提供权限：开发人员
通过设备进行真机测试，可以生成副本供多台电脑安装；2) Distribution Certification(发布证书)安装在电脑上提供发布iOS程序的权限：开发人员可以制做测试版和发布版的程序。不可生成副本，仅有配置该证书的电脑才可使用），一个证书仅仅只能用于一个 APP（通过 Bundle ID 来鉴别）和两个环境
（生成环境和产品环境）

-   **Provider 和 APNS 通过二进制借口交互**：这套二进制接口是异步执行的，它是通过建立一个 TCP 连接来发送二进制数据流，这套接口分为两种，
分别试用于开发环境和产品环境，建立这个连接需要不同的证书（Developer Certification(开发证书)适用于开发环境，Distribution Certification(发布证书)适用于产品环境）。APNS 还提供了一个 `回馈服务器（feedback service）`， 你可以通过这套服务接口来查询通知失败的
设备。

*总的来说：本质上说本地通知和远程通知都用来提醒用户有什么事情发生，不同之处在于：本地通知是 APP 自身定制、发送的；远程通知是由服务器发送给 APNS 再由 APNS 转发给 Client APP 的。*

## Local Notification

其实，本地通知使用比较少，大多数适用于一些基于时间creat的行为（比如说：设定某个固定事件触发什么事。）

一个本地通知包含以下三个属性：

-   **Scheduled time**：你必须指定

-   **Notification type**：包含通知内容，默认操作按钮的名字，应用标记的数量（app icon badge number），通知发生时的声音，IOS8 或更后
可以自定义操作。

-   **Custom data**：本地通知可以设置用户自身的信息。Custom data 用户存储该信息。

*注意：每个设备上的每一个 APP 最多只能预设64个本地通知，超过的会被系统丢弃，重复的通知会被时为一个通知。*

## Remote Notification

一个 IOS/MAC 应用一般采用的是 C/S 架构，在服务器端，APP 有一套给 Client APP 提供数据的方法；在客户端，Client APP 定期的从服务器端拉取
新数据更新本地。但是假如这个 APP 没有连接服务器或服务器提供了一些新数据需要应用及时更新呢，远程通知运营而生了，他能够完美的解决这个问题。一个
远程通知是一个非常小的消息，它被发送给设备的系统，这些系统能够通知客户端程序去更新数据。假如这个 APP 开启了这个功能并且注册过了，这条消息通知
就能被送至系统和 APP 中。`APNS` （ *Apple Push Notification Service* ）就是 `Remote Notification` 的核心技术。

详细信息 => [【点击这里】](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/WhatAreRemoteNotif.html#//apple_ref/doc/uid/TP40008194-CH102-SW1)


## Registering, Scheduling, and Handling User Notifications

### Registering for Notification Types in iOS

### Scheduling Local Notifications

### Registering for Remote Notifications

### Handling Local and Remote Notifications

### Using Notification Actions in iOS

### Using Location-Based Notifications

### Preparing Custom Alert Sounds

### Passing the Provider the Current Language Preference (Remote Notifications)

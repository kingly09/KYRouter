# KYRouter
一个高效,灵活,易用 的 iOS URL Router

## 前言

随着用户的需求越来越多，对App的用户体验也变的要求越来越高。为了更好的应对各种需求，开发人员从软件工程的角度，将App架构由原来简单的MVC变成MVVM，VIPER等复杂架构。更换适合业务的架构，是为了后期能更好的维护项目。

但是用户依旧不满意，继续对开发人员提出了更多更高的要求，不仅需要高质量的用户体验，还要求快速迭代，最好一天出一个新功能，而且用户还要求不更新就能体验到新功能。为了满足用户需求，于是开发人员就用H5，ReactNative，Weex等技术对已有的项目进行改造。项目架构也变得更加的复杂，纵向的会进行分层，网络层，UI层，数据持久层。每一层横向的也会根据业务进行组件化。尽管这样做了以后会让开发更加有效率，更加好维护，但是如何解耦各层，解耦各个界面和各个组件，降低各个组件之间的耦合度，如何能让整个系统不管多么复杂的情况下都能保持“高内聚，低耦合”的特点？这一系列的问题都摆在开发人员面前，亟待解决。

## app 亟待解决的问题

* 3D-Touch功能或者点击推送消息，要求外部跳转到App内部一个很深层次的一个界面。

比如微信的3D-Touch可以直接跳转到“我的二维码”。“我的二维码”界面在我的里面的第三级界面。或者再极端一点，产品需求给了更加变态的需求，要求跳转到App内部第十层的界面，怎么处理？

* 自家的一系列App之间如何相互跳转？

如果自己App有几个，相互之间还想相互跳转，怎么处理？

*  如何解除App组件之间和App页面之间的耦合性？

随着项目越来越复杂，各个组件，各个页面之间的跳转逻辑关联性越来越多，如何能优雅的解除各个组件和页面之间的耦合性？

*  如何能统一iOS和Android两端的页面跳转逻辑？甚至如何能统一三端的请求资源的方式？

项目里面某些模块会混合ReactNative，Weex，H5界面，这些界面还会调用Native的界面，以及Native的组件。那么，如何能统一Web端和Native端请求资源的方式？

*  如果使用了动态下发配置文件来配置App的跳转逻辑，那么如果做到iOS和Android两边只要共用一套配置文件？

* 如果App出现bug了，如何不用JSPatch，就能做到简单的热修复功能？

比如App上线突然遇到了紧急bug，能否把页面动态降级成H5，ReactNative，Weex？或者是直接换成一个本地的错误界面？

*  如何在每个组件间调用和页面跳转时都进行埋点统计？每个跳转的地方都手写代码埋点？利用Runtime AOP ？

*  如何在每个组件间调用的过程中，加入调用的逻辑检查，令牌机制，配合灰度进行风控逻辑？

*  如何在App任何界面都可以调用同一个界面或者同一个组件？只能在AppDelegate里面注册单例来实现？

*  比如App出现问题了，用户可能在任何界面，如何随时随地的让用户强制登出？或者强制都跳转到同一个本地的error界面？或者跳转到相应的H5，ReactNative，Weex界面？如何让用户在任何界面，随时随地的弹出一个View ？


以上这些问题其实都可以通过在App端设计一个路由来解决。

因此，造一个轮子 KYRouter 路由，来解决这些问题。

## KYRouter 和 其他的Router有哪些不同？

已经有几款不错的 Router 了，如 [JLRoutes](https://github.com/joeldev/JLRoutes), [HHRouter](https://github.com/Huohua/HHRouter), 但细看了下之后发现，还是不太满足需求。

JLRoutes 的问题主要在于查找 URL 的实现不够高效，通过遍历而不是匹配。还有就是功能偏多。

HHRouter 的 URL 查找是基于匹配，所以会更高效，KYRouter 也是采用的这种方法，但它跟 ViewController 绑定地过于紧密，一定程度上降低了灵活性。

KYRouter 呢？

1. [KYRouter支持openURL时，可以传一些 userinfo 过去](#KYRouter_02)
2. [支持中文的URL](#KYRouter_03)
3. [定义一个全局的 URL Pattern 作为 Fallback](#KYRouter_04)

模仿的JLRoutes的匹配不到会自动降级到global的思想。

4. [当 OpenURL 结束时，可以执行 Completion Block](#KYRouter_05)
5. [可以统一管理URL](#KYRouter_06)

URL 的处理一不小心，就容易散落在项目的各个角落，不容易管理。比如注册时的 pattern 是 ky://beauty/:id，然后 open 时就是 KY://beauty/123，这样到时候 url 有改动，处理起来就会很麻烦，不好统一管理。

所以 `KYRouter` 提供了一个类方法来处理这个问题。

```
#define TEMPLATE_URL @"qq://name/:name"

[KYRouter registerURLPattern:TEMPLATE_URL  toHandler:^(NSDictionary *routerParameters) {
    NSLog(@"routerParameters[name]:%@", routerParameters[@"name"]); // halfrost
}];

[KYRouter openURL:[KYRouter generateURLWithPattern:TEMPLATE_URL parameters:@[@"halfrost"]]];
}
```

`generateURLWithPattern:` 函数会对我们定义的宏里面的所有的:进行替换，替换成后面的字符串数组，依次赋值。



## 安装

```
pod 'KYRouter', '~>1.0.0'
```

## 如何使用

###  最基本的使用

```
[KYRouter registerURLPattern:@"ky://foo/bar" toHandler:^(NSDictionary *routerParameters) {
    NSLog(@"routerParameterUserInfo:%@", routerParameters[KYRouterParameterUserInfo]);
}];

[KYRouter openURL:@"ky://foo/bar"];
```

当匹配到 URL 后，`routerParameters` 会自带几个 key

```objc
extern NSString *const KYRouterParameterURL;
extern NSString *const KYRouterParameterCompletion;
extern NSString *const KYRouterParameterUserInfo;
```


### <a name="KYRouter_02"></a> KYRouter支持openURL时，可以传一些 userinfo 过去

```
[KYRouter registerURLPattern:@"ky://category/travel" toHandler:^(NSDictionary *routerParameters) {
    NSLog(@"routerParameters[KYRouterParameterUserInfo]:%@", routerParameters[KYRouterParameterUserInfo]);
    // @{@"user_id": @1900}
}];

[KYRouter openURL:@"ky://category/travel" withUserInfo:@{@"user_id": @1900} completion:nil];
```

### <a name="KYRouter_03"></a> 支持中文的URL

```
[KYRouter registerURLPattern:@"ky://search/直播" toHandler:^(NSDictionary *routerParameters) {
    NSLog(@"routerParameters:%@", routerParameters);
}];

[KYRouter openURL:@"ky://search/直播"];
```

### <a name="KYRouter_04"></a> 定义一个全局的 URL Pattern 作为 Fallback

```
[KYRouter registerURLPattern:@"ky://" toHandler:^(NSDictionary *routerParameters) {
    NSLog(@"没有人处理该 URL，就只能 fallback 到这里了");
}];

[KYRouter openURL:@"ky://search/travel/china?has_travelled=0"];
```

### <a name="KYRouter_05"></a> 当 OpenURL 结束时，可以执行 Completion Block

```
[KYRouter registerURLPattern:@"ky://detail" toHandler:^(NSDictionary *routerParameters) {
    NSLog(@"匹配到了 url, 一会会执行 Completion Block");

    // 模拟 push 一个 VC
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        void (^completion)() = routerParameters[KYRouterParameterCompletion];
        if (completion) {
            completion();
        }
    });
}];

[KYRouter openURL:@"ky://detail" withUserInfo:nil completion:^{
    [self appendLog:@"Open 结束，我是 Completion Block"];
}];
```


### <a name="KYRouter_06"></a> 可以统一管理URL


URL 的处理一不小心，就容易散落在项目的各个角落，不容易管理。比如注册时的 pattern 是 `ky://beauty/:id`，然后 open 时就是 `ky://beauty/123`，这样到时候 url 有改动，处理起来就会很麻烦，不好统一管理。

所以 KYRouter 提供了一个类方法来处理这个问题。

```
+ (NSString *)generateURLWithPattern:(NSString *)pattern parameters:(NSArray *)parameters;
```

使用方式

```
#define TEMPLATE_URL @"ky://search/:keyword"

[KYRouter registerURLPattern:TEMPLATE_URL  toHandler:^(NSDictionary *routerParameters) {
    NSLog(@"routerParameters[keyword]:%@", routerParameters[@"keyword"]); // Hangzhou
}];

[KYRouter openURL:[KYRouter generateURLWithPattern:TEMPLATE_URL parameters:@[@"Hangzhou"]]];
}
```

这样就可以在一个地方定义所有的 URL Pattern，使用时，用这个方法生成 URL 就行了。



> 更多信息，请参考 `demo`

## 协议

KYRouter 被许可在 MIT 协议下使用。查阅 LICENSE 文件来获得更多信息。

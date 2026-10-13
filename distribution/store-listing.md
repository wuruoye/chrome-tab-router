# Chrome Web Store 商店文案草稿

核对日期：2026-10-12。以下文字按当前代码编写，正式填写时需以最终 ZIP、Mac 应用安装方式和实际界面复核。`[待填写]` 内容不可原样发布。

## 产品信息

- 名称：Chrome Tab Router · 链接复用
- 简述：在网页链接创建新标签页之前，将链接交给 Mac 应用，查找并复用已有标签页。
- 分类、语言、发布地区：由账户持有人在后台按目标用户选择。
- 支持网址或邮箱：`[待填写：可公开使用的支持渠道]`
- Mac 应用下载地址：`[待填写：稳定、公开且可供审核人员获取的地址]`
- 隐私政策 URL：`[待填写：公开托管 distribution/privacy-policy.md 最终版的 HTTPS 地址]`

## 详细说明

Chrome Tab Router 与同名 Mac 应用配合，在用户点击将打开新标签页的网页链接时，把该链接的完整 URL 交给本机应用，查找 Chrome 中是否已有匹配的标签页。找到后切换到该标签页；没有找到时正常打开新标签页。默认按完整 URL 匹配；设置中可以选择忽略页面锚点、常见跟踪参数或所有查询参数。匹配后可以把已有标签页更新为收到的完整 URL，也可以保留原地址。用户还可以决定复用时是否刷新、暂停网页链接接管或排除指定域名。

安装扩展和 Mac 应用后，点击扩展图标并选择“连接 Mac 应用”。在 Chrome 提示时允许打开本机应用。网页中指向新标签页的链接、Command 点击和鼠标中键点击可由扩展交给 Mac 应用处理。Mac 应用需要获准控制 Chrome，才能查找和切换标签页。若 Mac 应用暂时不可用，扩展会尝试直接打开目标链接。

为匹配标签页，扩展会读取用户点击的链接 URL，并通过 Chrome Native Messaging 交给本机 Mac 应用；Mac 应用在本机读取 Chrome 已打开标签页的 URL 作比较。即使启用忽略查询参数或锚点的匹配设置，传给本机应用的仍是完整 URL，更新标签页时也使用该完整 URL。URL 可能包含路径、查询参数或片段。本功能在支持的网页和框架中运行，具体数据处理见隐私政策。

仅支持 macOS 13 或更新版本和 Google Chrome。使用前需安装 Mac 应用：`[待填写：下载地址]`。

## Privacy 表单用语草稿

**唯一用途：** 在用户要求网页链接打开新标签页时，借助本机 Mac 应用查找并复用 Chrome 已打开的标签页。

**`nativeMessaging` 理由：** 扩展将用户点击的目标 URL 发送给用户安装的本机 Chrome Tab Router 应用，并读取该应用返回的路由结果与设置；本机应用负责查询和切换 Chrome 标签页。扩展不通过该权限连接开发者服务器。

**网站访问范围理由：** `content_scripts` 匹配 `http://*/*` 和 `https://*/*`，并在各框架中监听用户触发的新标签页链接。用户可在 Mac 应用中关闭网页链接接管或设置排除域名。仅在符合接管条件时把目标 URL 发给本机应用。

**数据披露核对：** 申报浏览活动相关数据，说明目标链接 URL 和 Mac 应用用于匹配的现有标签页 URL 只在用户设备上处理；设置和连接所用扩展 ID 保存在 Mac 本地；操作日志只记录时间和动作名称。后台若将链接 URL 归入“网站内容”或其他类别，应按实际字段定义同时申报。将这段说明与最终隐私政策、产品内提示逐项核对。

**远程代码：** 当前扩展包内的 JavaScript 直接运行，没有加载远程执行代码；提交前复核最终 ZIP。

**审核说明：** 提供可安装的 Mac 应用、安装步骤、连接扩展操作、Chrome 自动化权限设置，以及能验证“匹配现有标签页”和“未匹配时新建标签页”的网址。该材料可放入后台 Test instructions。

## 参考资料

[商店资料字段](https://developer.chrome.com/docs/webstore/cws-dashboard-listing/)、[隐私字段与权限理由](https://developer.chrome.com/docs/webstore/cws-dashboard-privacy/)、[Native Messaging 用法](https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging)、[本机数据处理披露](https://developer.chrome.com/docs/webstore/program-policies/user-data-faq)。

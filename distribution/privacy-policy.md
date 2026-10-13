# Chrome Tab Router 隐私政策草稿

核对日期：2026-10-12。发布前须填好开发者身份、联系渠道、公开 URL，并与最终应用和扩展代码逐项核对。本文是待发布文本，不能以仓库文件路径代替 Chrome Web Store 要求的公开隐私政策链接。

**开发者：** `[待填写：发布账户对应的开发者名称]`

**联系邮箱：** `[待填写：公开支持邮箱]`

**生效日期：** `[待填写：正式发布日]`

## 功能与处理的数据

Chrome Tab Router 扩展与用户安装的同名 Mac 应用配合，在用户点击会打开新标签页的网页链接时查找并复用已打开的 Chrome 标签页。为完成这项功能，扩展读取该次点击的完整目标 URL，并通过 Chrome Native Messaging 发送给本机 Mac 应用。完整 URL 可能包含域名、路径、查询参数和片段，因此可能包含用户放在 URL 中的信息。

Mac 应用在用户设备上读取 Chrome 当前打开的标签页 URL，与目标 URL 比较。默认按完整 URL 匹配；用户可设置匹配时忽略页面锚点、常见跟踪参数或所有查询参数。这些设置只改变比较方式，扩展仍会将完整目标 URL 传给本机应用。找到匹配标签页后，应用可按设置将其更新为收到的完整 URL、保留原地址或刷新；没有匹配时会打开新标签页。扩展还会向本机应用读取启用状态、排除域名等设置；连接时，Mac 应用保存扩展 ID，用于限制本机消息通道的来源。

扩展的网页脚本在 HTTP 和 HTTPS 网页及其框架中运行，用于识别用户触发的新标签页链接。扩展不会为匹配功能读取页面正文、表单内容、密码或 Cookie。用户可以在 Mac 应用中暂停网页链接接管或设置排除域名。

## 存储、共享与保留

目标 URL 和用于比较的现有标签页 URL 由本机程序临时处理，不写入 Chrome Tab Router 的操作日志。Mac 应用在本机保存功能设置、排除域名和连接所需的扩展 ID；本机操作日志记录时间和动作名称，不记录 URL。卸载前可在 Mac 应用中关闭登录启动并恢复原来的默认浏览器，随后退出应用、删除应用和 Chrome 扩展。需要清理本机数据时，可删除 `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.sigma.chrome_tab_router.json`，运行 `defaults delete com.sigma.ChromeTabRouter`，并删除 `~/Library/Logs/ChromeTabRouter/`。这些步骤清理的是本应用的本机设置、连接文件和操作日志。

当前扩展和 Mac 应用代码没有把这些 URL 发送给开发者的服务器，也没有加入分析或广告服务。Chrome 正常打开目标网站时，浏览器与该网站之间的常规网络请求仍会发生；网站自身的数据处理遵循该网站的政策。用户的浏览 URL 不用于广告，也不出售给第三方。

## 权限

`nativeMessaging` 允许扩展与用户设备上的 Mac 应用通信，完成链接路由及设置读取。网页脚本需要在支持的网页中运行，才能识别用户请求新标签页的链接。Mac 应用需要 macOS 的 Chrome 自动化权限，才能读取并切换已打开的标签页。扩展发布包请求的具体权限以商店安装提示和最终 Manifest 为准。

## 用户选择与政策变化

用户可在 Mac 应用中关闭网页链接接管、排除指定域名，或卸载扩展与应用。若以后改变所处理的数据、用途或接收方，开发者会先更新本政策及产品中的说明，并按 Chrome Web Store 的要求告知用户。

Chrome Tab Router 对通过 Chrome 扩展 API 获得的信息遵守 [Chrome Web Store User Data Policy](https://developer.chrome.com/docs/webstore/program-policies/policies) 的 Limited Use 要求，只为上述向用户展示的链接复用功能使用浏览活动数据。

## 官方依据

[Chrome Web Store 隐私政策要求](https://developer.chrome.com/docs/webstore/program-policies/policies)、[本机处理仍须披露](https://developer.chrome.com/docs/webstore/program-policies/user-data-faq)、[隐私字段填写说明](https://developer.chrome.com/docs/webstore/cws-dashboard-privacy/)、[2026 年政策更新](https://developer.chrome.com/blog/cws-policy-updates-2026)。

# Chrome Tab Router 隐私政策

**开发者：** [wuruoye](https://github.com/wuruoye)

**联系渠道：** [GitHub Issues](https://github.com/wuruoye/chrome-tab-router/issues)

**生效日期：** 2026-10-13

本政策适用于 Chrome Tab Router 的 Mac 应用和 Chrome 扩展。公开阅读地址为 [隐私政策](https://wuruoye.github.io/chrome-tab-router/privacy.html)。

## 功能与处理的数据

Chrome Tab Router 扩展与用户安装的同名 Mac 应用配合，在用户点击会打开新标签页的网页链接时查找并复用已打开的 Chrome 标签页。为完成这项功能，扩展读取该次点击的完整目标 URL，并通过 Chrome Native Messaging 发送给本机 Mac 应用。完整 URL 可能包含域名、路径、查询参数和片段，因此可能包含用户放在 URL 中的信息。

Mac 应用在用户设备上读取 Chrome 当前打开的标签页 URL，与目标 URL 比较。默认按完整 URL 匹配；用户可在菜单栏设置匹配时忽略页面锚点、常见跟踪参数或所有查询参数。这些设置只改变比较方式，扩展仍会将完整目标 URL 传给本机应用。找到匹配标签页后，应用可按设置将其更新为收到的完整 URL、保留原地址或刷新；没有匹配时会打开新标签页。扩展还会向本机应用读取启用状态、排除域名等设置。Mac 应用在本机登记正式扩展 ID，以及用户主动连接的开发版扩展 ID，用于限制本机消息通道的来源。

扩展的网页脚本在 HTTP 和 HTTPS 网页及其框架中运行，用于识别用户触发的新标签页链接。扩展不会为匹配功能读取页面正文、表单内容、密码输入框或 Cookie。Mac 应用还会处理外部应用交给系统打开的 HTTP/HTTPS 链接，或用户通过菜单栏主动打开的剪贴板链接；应用只在用户选择该菜单操作时读取剪贴板。用户可以在菜单栏暂停标签页复用、关闭网页链接接管或管理例外网站。

## 存储、共享与保留

1.3.2 的 Mac 应用独立跟踪自己打开或更新的标签页，读取该标签页的加载状态和最终 URL，并将原始 URL 与最终 URL 保存在 `~/Library/Caches/ChromeTabRouter/Navigation/app.json`。这项功能不依赖扩展，也不发送额外探测请求。App 只跟踪自己发起导航的标签页，普通页面跳转和关闭后清理当前记录；匹配时再次核对 Chrome 本次进程、标签页 ID 与当前网址。隐身窗口记录只在 App 内存中使用，不写入该文件。App 不保证捕获快速经过的所有中间跳转地址。

1.3.1 的扩展监听当前主页面的导航和服务器重定向地址，为每个标签页保存当前页面经过的完整 URL。普通页面跳转会替换这份记录，关闭标签页会删除记录；它不会保存标签页过去访问的所有页面。扩展的记录保存在 Chrome 会话内存中，重载扩展或重启 Chrome 后清空。为使外部应用打开的链接也能复用标签页，扩展通过 Native Messaging 将当前重定向记录发送给本机 Mac 应用，写入仅当前用户可访问的 `~/Library/Caches/ChromeTabRouter/Navigation/`。缓存按标签页关闭和导航更新，Mac 应用运行时检测到 Chrome 退出会清理；旧 Chrome 进程的记录不再参与匹配。隐身标签页记录不发送给 Mac 应用。这些地址不上传、不写入操作日志，也不用于浏览历史分析。

目标 URL 和用于比较的现有标签页 URL 由本机程序临时处理，不写入 Chrome Tab Router 的操作日志。Mac 应用在本机保存功能设置、排除域名、连接所需的扩展 ID，以及用于恢复默认浏览器的原应用标识。本机连接状态还保存最近发起通信的扩展 ID 和最近连接时间，用于菜单栏显示最近连接记录；这不表示扩展持续在线。本机操作日志仅记录时间和动作名称。设置、连接文件和操作日志会保留在用户设备上，直到用户主动清理。应用不建立浏览网址历史。

卸载前可在菜单栏关闭登录启动并恢复原来的默认浏览器，随后退出应用、删除应用和 Chrome 扩展。需要清理本机数据时，可删除 `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.sigma.chrome_tab_router.json`，运行 `defaults delete com.sigma.ChromeTabRouter`，并删除 `~/Library/Logs/ChromeTabRouter/`。这些步骤清理的是本应用的本机设置、连接文件和操作日志。

扩展和 Mac 应用不会把这些 URL、设置或操作日志发送给开发者的服务器，没有分析或广告服务，开发者无法通过本应用远程查看用户的浏览 URL。Chrome 正常打开目标网站时，浏览器与该网站之间的常规网络请求仍会发生；网站自身的数据处理遵循该网站的政策。用户的浏览 URL 不用于广告，不出售给第三方，也不用于与链接复用无关的用途。

## 权限

`nativeMessaging` 允许扩展与用户设备上的 Mac 应用通信，完成链接路由及设置读取。网页脚本在 HTTP/HTTPS 网页及其框架中运行，才能识别用户请求新标签页的链接；Chrome 内部页面和 Chrome Web Store 等受保护页面不支持这些脚本。Mac 应用需要 macOS 的 Chrome 自动化权限，才能读取并切换已打开的标签页。

1.3.1 使用 `webNavigation` 识别主页面导航、页面脚本重定向和普通页面切换，使用 `webRequest` 及 HTTP/HTTPS 主机权限观察主页面服务器重定向的前后 URL，使用 `storage` 在扩展会话内存中保存当前页面记录。监听只处理主页面地址，不读取请求正文、响应正文、Cookie 或认证信息，不拦截网络请求。

## 公开页面与支持渠道

官网由开发者的服务器提供，GitHub Pages 提供镜像。页面没有分析脚本、广告、表单或应用内追踪；验证页仅在浏览器中显示当前页面的 URL，不请求 App 数据。访问官网时，浏览器会向托管服务器发送提供页面所需的常规网络请求，可能包含 IP 地址、浏览器信息和访问路径。这些请求与 App 为复用标签页而在本机处理的网址分开，官网不会从 App 读取用户的浏览 URL、设置或操作日志。

公开仓库、GitHub Pages 镜像、Release 安装包下载和 GitHub Issues 由 GitHub 提供相应服务，遵循 [GitHub 隐私声明](https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement)。GitHub Issues 中的用户提交内容公开可见。这些页面和支持服务不会从 Chrome Tab Router 读取用户的浏览 URL、设置或操作日志。

## 用户选择与政策变化

用户可在菜单栏关闭网页链接接管、暂停标签页复用、管理例外域名，或卸载扩展与应用。若以后改变所处理的数据、用途或接收方，开发者会先更新本政策及产品中的说明，并按 Chrome Web Store 的要求告知用户。

Chrome Tab Router 对通过 Chrome 扩展 API 获得的信息遵守 [Chrome Web Store User Data Policy](https://developer.chrome.com/docs/webstore/program-policies/policies) 的 Limited Use 要求，只为上述向用户展示的链接复用功能使用浏览活动数据。

## 官方依据

[Chrome Web Store 隐私政策要求](https://developer.chrome.com/docs/webstore/program-policies/policies)、[本机处理仍须披露](https://developer.chrome.com/docs/webstore/program-policies/user-data-faq)、[隐私字段填写说明](https://developer.chrome.com/docs/webstore/cws-dashboard-privacy/)、[2026 年政策更新](https://developer.chrome.com/blog/cws-policy-updates-2026)。

# Chrome Web Store 商店填写材料

准备版本：1.3.0。核对日期：2026-10-13。以下各字段正文可直接复制到商店草稿。1.3.0 预览版安装包及公开页面已完成发布核验；当前商店草稿包为 1.2.0，仍需上传最终 1.3.0 ZIP，先不提交审核。

Mac 1.3.0 已构建安装，严格签名检查、本机协议读取共享设置及允许来源配置已通过。真实 Chrome 扩展 1.3.0 重载与自动连接、菜单栏功能截图仍待用户操作和核验。以下功能说明和审核步骤描述产品行为，不表示本次 Chrome 连接或商店审核已经完成。

## 产品信息

- 名称：Chrome Tab Router · 链接复用
- 简述：在网页链接创建新标签页之前，将链接交给 Mac 应用，查找并复用已有标签页。
- 分类：工作效率。
- 默认语言：中文（简体）。发布地区按后台选择。
- 支持网址：[GitHub Issues](https://github.com/wuruoye/chrome-tab-router/issues)
- Mac 应用下载地址：[1.3.0 · Apple 芯片](https://github.com/wuruoye/chrome-tab-router/releases/download/v1.3.0/chrome-tab-router-mac-1.3.0-arm64.zip)
- 安装说明与验证页面：[Chrome Tab Router](https://wuruoye.github.io/chrome-tab-router/)
- 隐私政策 URL：[隐私政策](https://wuruoye.github.io/chrome-tab-router/privacy.html)
- 商店项目：[Chrome Tab Router](https://chromewebstore.google.com/detail/chrome-tab-router/iineonbhdnmadlkkmdcofakekmjpnkmn)。当前仍为草稿，上架后该链接可用于安装。

## 详细说明

Chrome Tab Router 与同名 Mac 应用配合，在用户点击将打开新标签页的网页链接时，把该链接的完整 URL 交给本机应用，查找 Chrome 中是否已有匹配的标签页。找到后切换到该标签页；没有找到时正常打开新标签页。默认按完整 URL 匹配；Mac 应用菜单栏中可以选择忽略页面锚点、常见跟踪参数或所有查询参数。匹配后可以把已有标签页更新为收到的完整 URL，也可以保留原地址。用户还可以决定复用时是否刷新、是否查找所有 Chrome 窗口、暂停标签页复用或网页链接接管，以及登录时自动启动。

所有设置均从 Mac 应用菜单栏访问，扩展与 Mac 应用共用自动保存的设置。菜单栏显示默认浏览器状态、自动连接配置和最近连接记录，提供设为默认浏览器、恢复原默认浏览器、安装扩展、修复自动连接、打开扩展目录、安装与连接说明、隐私政策和 Chrome 自动化权限设置入口。“例外网站”子菜单支持添加、查看和删除域名；添加时弹出输入框。例外域名及其子域名的链接每次新开。

安装并打开 Mac 应用后，再安装 Chrome 扩展。Mac 应用每次启动时会登记正式扩展的本机连接，扩展在安装、Chrome 启动和打开弹窗时自动检测连接；点击扩展图标可确认“已连接”。先安装扩展、再安装 App 时，首次打开 App 后点击“重新检测”即可重试。需要修复连接或使用本地开发版时，在扩展弹窗点击“修复连接”，并在 Chrome 提示时允许打开本机应用；新开发版的连接请求还需在 App 中确认。网页中指向新标签页的链接、Command 点击和鼠标中键点击可由扩展交给 Mac 应用处理。Mac 应用需要获准控制 Chrome，才能查找和切换标签页。若 Mac 应用暂时不可用，扩展会尝试直接打开目标链接。

为匹配标签页，扩展会读取用户点击的链接 URL，并通过 Chrome Native Messaging 交给本机 Mac 应用；Mac 应用在本机读取 Chrome 已打开标签页的 URL 作比较。即使启用忽略查询参数或锚点的匹配设置，传给本机应用的仍是完整 URL，更新标签页时也使用该完整 URL。URL 可能包含路径、查询参数或片段。本功能在支持的网页和框架中运行，具体数据处理见隐私政策。

支持 macOS 13 或更新版本和 Google Chrome。本次提供 Apple 芯片版 Mac 应用，使用前需下载安装：
https://github.com/wuruoye/chrome-tab-router/releases/download/v1.3.0/chrome-tab-router-mac-1.3.0-arm64.zip

完整安装说明：
https://wuruoye.github.io/chrome-tab-router/

隐私政策：
https://wuruoye.github.io/chrome-tab-router/privacy.html

网页脚本仅在支持扩展脚本的 HTTP/HTTPS 页面中工作。Chrome 内部页面、Chrome Web Store、地址栏、书签、右键菜单、表单、脚本调用 window.open() 和普通当前页跳转不在网页点击接管范围内。

## Privacy 表单正文

**唯一用途：** 在用户要求网页链接打开新标签页时，借助本机 Mac 应用查找并复用 Chrome 已打开的标签页。

**`nativeMessaging` 理由：** 扩展将用户点击的目标 URL 发送给用户安装的本机 Chrome Tab Router 应用，并读取该应用返回的路由结果与设置；本机应用负责查询和切换 Chrome 标签页。扩展不通过该权限连接开发者服务器。

**网站访问范围理由：** `content_scripts` 匹配 `http://*/*` 和 `https://*/*`，并在各框架中监听用户触发的新标签页链接。用户可在 Mac 应用菜单栏中关闭网页链接接管，或在“例外网站”子菜单中管理排除域名。仅在符合接管条件时把目标 URL 发给本机应用。

**数据处理说明：** 扩展读取用户主动点击的目标链接 URL，并通过本机 Native Messaging 交给 Mac 应用。Mac 应用只在用户设备上读取 Chrome 已打开标签页的 URL，用于匹配、切换、更新和刷新标签页。完整 URL 可能包含域名、路径、查询参数和片段。设置、例外域名、扩展 ID、最近通信的来源扩展 ID 与时间、原默认浏览器标识保存在 Mac 本地；操作日志仅记录时间和动作名称，不记录 URL。浏览 URL、设置、连接记录和日志不会上传给开发者，不用于广告，不出售给第三方。

**数据类别选择：** 选择“浏览活动”（Web history / browsing activity，按后台实际字段名称）。不选择“完全不处理用户数据”。本功能不读取网页正文、表单、密码输入框或 Cookie；完整 URL 本身可能包含用户放在路径、查询参数或片段中的信息。后台如按定义把链接 URL 同时归入“网站内容”或其他数据类别，应相应申报 URL，并与本隐私政策一致。

**Limited Use 声明：** Chrome Tab Router 只为向用户提供链接复用功能处理浏览 URL。数据仅在用户设备上处理，不出售、不用于广告，也不用于与该功能无关的用途；遵守 Chrome Web Store User Data Policy，包括 Limited Use 要求。

**远程代码：** 选择“否”。所有 JavaScript 均随扩展包分发，没有加载或执行远程代码。

## Test instructions 正文

本扩展需要本机 Chrome Tab Router Mac 应用。无需账号、密码或付费。请使用 Apple 芯片 Mac、macOS 13 或更新版本，以及 Google Chrome。

1. 下载 Mac 应用： https://github.com/wuruoye/chrome-tab-router/releases/download/v1.3.0/chrome-tab-router-mac-1.3.0-arm64.zip 。解压后将 Chrome Tab Router.app 放入 ~/Applications 并打开。安装包使用临时签名，尚未经过 Apple 公证；macOS 如阻止首次打开，请按“系统设置 → 隐私与安全性”中的系统提示确认打开。
2. 安装本次审核的扩展。Mac 应用会登记正式扩展 ID；扩展自动检测本机连接。点击扩展图标确认“已连接”。如先安装扩展、后安装 App，请首次打开 App 后在扩展中点击“重新检测”。如仍未连接，先从 Mac 菜单栏“Chrome 扩展”中选择“修复自动连接”，再检测；必要时在扩展弹窗点击“修复连接”，允许打开 Mac 应用，然后重新打开弹窗确认。
3. 点击 Mac 菜单栏图标，确认“启用标签页复用”“接管 Chrome 网页的新标签页链接”“在所有 Chrome 窗口中查找”“切换到已有标签页后刷新”“复用时更新为新链接”均开启。在“网址匹配”中开启“忽略所有查询参数”和“忽略页面锚点”。例外网站列表保持为空。
4. 在 Chrome 打开 https://wuruoye.github.io/chrome-tab-router/ 并到“验证标签页复用”部分。点击第一个链接，打开 https://wuruoye.github.io/chrome-tab-router/demo/reuse.html?id=1#first 。首次处理时，如 macOS 请求自动化权限，允许 Mac 应用控制 Google Chrome；如已拒绝，可从菜单栏打开 Chrome 自动化权限设置。示例页显示自身完整地址、参数和锚点。
5. 回到验证页面，点击第二个链接。它使用 target=_blank，指向 https://wuruoye.github.io/chrome-tab-router/demo/reuse.html?id=2#second 。预期：复用第 4 步的标签页，网址及页面中的地址展示更新为第 5 步的完整链接，并载入页面；标签页总数不增加。
6. 回到验证页面，点击第三个链接，指向 https://wuruoye.github.io/chrome-tab-router/demo/other.html?id=3 。确保没有该 other.html 路径的其他标签页。预期：新增一个 Chrome 标签页；页面显示不同路径。
7. 在验证页面对第二个链接使用 Command 点击和鼠标中键点击，预期仍复用 reuse.html 的标签页。网页脚本不支持 Chrome Web Store 和 Chrome 内部页面，请在上述公开验证页面测试。
8. 在菜单栏关闭网页链接接管，再点击验证页面的新标签页链接，预期由 Chrome 正常新开。在“例外网站”中添加 wuruoye.github.io 后，发往该域名及其子域名的链接也正常新开；测试完成后可在同一子菜单中移除。
9. 如需验证外部应用打开链接，在菜单栏“默认浏览器”中选择“设为默认浏览器”，确认系统提示后，从其他应用打开上述链接。HTTP/HTTPS 链接会由 Mac 应用匹配已有标签页；可使用“恢复原来的默认浏览器”恢复。

支持： https://github.com/wuruoye/chrome-tab-router/issues

隐私政策： https://wuruoye.github.io/chrome-tab-router/privacy.html

## 图片材料

| 文件 | 尺寸 | 用途与状态 |
|---|---|---|
| `assets/installation-page-1280x800.jpg` | 1280×800 | 真实线上安装说明网页的补充截图，尺寸已确认。可用于说明安装流程；菜单栏、扩展弹窗及功能成功画面另行采集。 |
| `assets/chrome-web-store-small-promo.png` | 440×280 | 已准备的小宣传图，说明标签页复用功能；同名 SVG 为可编辑原稿。 |

菜单栏设置、扩展“已连接”弹窗和实际复用成功画面的截图仍待完成。图片与文案尚未确认填入商店后台；1.3.0 草稿包更新和提交审核均未完成。素材说明见 [assets/README.md](assets/README.md)。

## 参考资料

[商店资料字段](https://developer.chrome.com/docs/webstore/cws-dashboard-listing/)、[隐私字段与权限理由](https://developer.chrome.com/docs/webstore/cws-dashboard-privacy/)、[Native Messaging 用法](https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging)、[本机数据处理披露](https://developer.chrome.com/docs/webstore/program-policies/user-data-faq)。

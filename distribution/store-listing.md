# Chrome Web Store 商店填写材料

准备版本：Mac 应用与扩展 1.3.2。核对日期：2026-10-13。1.3.2 包含 App 独立地址记录与扩展的当前页面重定向链记录。商店待审核版本目前为 1.3.0，准备替换审核包并重新提审，审核后自动发布保持关闭。

Mac 1.3.0 已构建安装，严格签名检查、本机协议读取共享设置及允许来源配置已通过。真实 Chrome 弹窗的实际来源已核对为正式商店 ID `iineonbhdnmadlkkmdcofakekmjpnkmn`，显示“已连接 · 网页链接接管已开启”；Mac 最近连接记录为同一 ID。已实测正式 ID 的同完整网址普通、Command 和中键点击复用，以及不同路径新开。联系邮箱已通过 Google 验证。提亮后的菜单、新排版开发版弹窗与安装说明三张截图已上传保存，1.3.0 已提交审核。

Privacy 表单已于 2026-10-13 填写并保存：单一用途、`nativeMessaging` 理由、主机访问范围理由、隐私政策网址、不使用远程代码、数据类别“网络记录”和“网站内容”，以及三项 Limited Use 披露；隐私政策网址已更新为官网页面。商品分类、语言、图标、宣传图和三张截图已保存，Test instructions 已保存 437 字短版，并显示“已保存测试说明”。Distribution 已只读核对为免费、公开、所有地区，保留原设置。

## 产品信息

- 名称：Chrome Tab Router · 链接复用
- 简述：在网页链接创建新标签页之前，将链接交给 Mac 应用，查找并复用已有标签页。
- 分类：工具。
- 语言：中文（中国）。发布地区按后台选择。
- 支持网址：[GitHub Issues](https://github.com/wuruoye/chrome-tab-router/issues)
- Mac 应用下载地址：[1.3.2 · Apple 芯片](https://github.com/wuruoye/chrome-tab-router/releases/download/v1.3.2/chrome-tab-router-mac-1.3.2-arm64.zip)
- 安装说明与验证页面：[Chrome Tab Router](https://ruoye.site/chrome-tab-router/)
- 隐私政策 URL：[隐私政策](https://ruoye.site/chrome-tab-router/privacy.html)
- 商店项目：[Chrome Tab Router](https://chromewebstore.google.com/detail/chrome-tab-router/iineonbhdnmadlkkmdcofakekmjpnkmn)。已提交审核，审核通过后手动发布；上架后该链接可用于安装。
- Distribution 当前设置：免费、公开、所有地区。已提交审核，审核后自动发布关闭，尚未上架。

## 详细说明

Chrome Tab Router 与同名 Mac 应用配合，在用户点击将打开新标签页的网页链接时，把该链接的完整 URL 交给本机应用，查找 Chrome 中是否已有匹配的标签页。找到后切换到该标签页；没有找到时正常打开新标签页。默认按完整 URL 匹配；Mac 应用菜单栏中可以选择忽略页面锚点、常见跟踪参数或所有查询参数。匹配后可以把已有标签页更新为收到的完整 URL，也可以保留原地址。用户还可以决定复用时是否刷新、是否查找所有 Chrome 窗口、暂停标签页复用或网页链接接管，以及登录时自动启动。

所有设置均从 Mac 应用菜单栏访问，扩展与 Mac 应用共用自动保存的设置。菜单栏显示默认浏览器状态、自动连接配置和最近连接记录，提供设为默认浏览器、恢复原默认浏览器、安装扩展、修复自动连接、打开扩展目录、安装与连接说明、隐私政策和 Chrome 自动化权限设置入口。“例外网站”子菜单支持添加、查看和删除域名；添加时弹出输入框。例外域名及其子域名的链接每次新开。

安装并打开 Mac 应用后，再安装 Chrome 扩展。Mac 应用每次启动时会登记正式扩展的本机连接，扩展在安装、Chrome 启动和打开弹窗时自动检测连接；点击扩展图标可确认“已连接”。先安装扩展、再安装 App 时，首次打开 App 后点击“重新检测”即可重试。若弹窗仍显示未连接，可点击“修复连接”，并在 Chrome 提示时允许打开本机应用；新开发版的连接请求还需在 App 中确认。已连接时可用“重新检测”或“打开 Mac 菜单”。网页中指向新标签页的链接、Command 点击和鼠标中键点击可由扩展交给 Mac 应用处理。Mac 应用需要获准控制 Chrome，才能查找和切换标签页。若 Mac 应用暂时不可用，扩展会尝试直接打开目标链接。

Mac 应用可以独立处理外部应用打开的链接，并记录自己打开或更新标签页的原始和最终 URL。扩展补充 Chrome 网页内部点击，监听当前主页面导航和服务器重定向，记录每个标签页当前页面实际经过的完整 URL；再次打开已记录的地址可复用同一标签页。普通页面跳转会替换记录，关闭标签页会清理记录。App 独立运行时不保证捕获快速经过的所有中间地址。

为匹配标签页，扩展会读取用户点击的链接 URL，并通过 Chrome Native Messaging 交给本机 Mac 应用；Mac 应用在本机读取 Chrome 已打开标签页的 URL 作比较。扩展的当前页面记录保存在 Chrome 会话内存中，并写入仅当前用户可访问的本机缓存供 App 读取；App 自己采集的当前页面记录独立保存。即使启用忽略查询参数或锚点的匹配设置，传给本机应用的仍是完整 URL，更新标签页时也使用该完整 URL。URL 可能包含路径、查询参数或片段。浏览 URL 不上传给开发者、不用于广告或出售，不写入操作日志；具体数据处理见隐私政策。

支持 macOS 13 或更新版本和 Google Chrome。本次提供 Apple 芯片版 Mac 应用，使用前需下载安装：
https://github.com/wuruoye/chrome-tab-router/releases/download/v1.3.2/chrome-tab-router-mac-1.3.2-arm64.zip

完整安装说明：
https://ruoye.site/chrome-tab-router/

隐私政策：
https://ruoye.site/chrome-tab-router/privacy.html

网页脚本仅在支持扩展脚本的 HTTP/HTTPS 页面中工作。Chrome 内部页面、Chrome Web Store、地址栏、书签、右键菜单、表单、脚本调用 window.open() 和普通当前页跳转不在网页点击接管范围内。

## Privacy 表单正文

**唯一用途：** 在用户要求网页链接打开新标签页时，借助本机 Mac 应用查找并复用 Chrome 已打开的标签页。

**`nativeMessaging` 理由：** 扩展将用户点击的目标 URL 发送给用户安装的本机 Chrome Tab Router 应用，并读取该应用返回的路由结果与设置；本机应用负责查询和切换 Chrome 标签页。扩展不通过该权限连接开发者服务器。

**`storage` 理由：** 使用 `chrome.storage.session` 在扩展会话内存中保存各标签页当前页面的导航和重定向地址，防止 service worker 休眠后丢失当前记录。普通页面导航与关闭标签页会清理旧记录，重载扩展或重启 Chrome 后会话记录清空。不使用云同步或保存完整浏览历史。

**`webNavigation` 理由：** 监听主页面导航完成、页面脚本重定向、历史状态与锚点变化，为当前标签页关联原始地址和最终地址，并在普通页面跳转后替换记录。只处理主页面，忽略子框架与预渲染页面，不读取正文、表单或认证信息。

**`webRequest` 理由：** 以非阻塞方式观察 HTTP/HTTPS 主页面请求和服务器重定向事件，读取该次请求的 URL 与重定向目标 URL，为当前页面记录实际重定向链。不读取请求正文、响应正文、Cookie、认证头或其他请求头，不拦截或修改网络请求。

**网站访问范围理由：** HTTP/HTTPS 主机权限使扩展能观察当前主页面的服务器重定向 URL，网页脚本在各框架中识别用户触发的新标签页链接。功能需适用于任意用户访问的网站，因此使用 `http://*/*` 与 `https://*/*`。用户可关闭网页链接接管、暂停复用或设置例外域名。数据只在本机用于当前标签页复用，不读取页面正文、请求正文、Cookie 或认证信息。

**数据处理说明：** 扩展读取用户主动点击的目标 URL 和当前主页面导航、重定向 URL，通过本机 Native Messaging 交给 Mac 应用。当前页面记录保存在扩展会话内存及权限受限的本机缓存，普通导航与关闭标签页后清理；隐身标签页记录不发送给 App。App 独立保存自己打开链接的原始和最终地址。所有完整 URL 只用于当前标签页匹配、切换、更新和刷新，不建立完整浏览历史、不写入操作日志、不上传给开发者，不用于广告或出售。设置、例外域名、扩展 ID 与默认浏览器标识保存在本机。

**数据类别选择：** 实际勾选“网络记录”和“网站内容”；表单对“网站内容”的举例包含超链接。申报对象为用户点击的目标链接 URL 和 Mac 应用用于比较的现有标签页 URL，仅在用户设备上处理。本功能不读取网页正文、表单、密码输入框或 Cookie；完整 URL 本身可能包含用户放在路径、查询参数或片段中的信息。

**Limited Use 声明：** Chrome Tab Router 只为向用户提供链接复用功能处理浏览 URL。数据仅在用户设备上处理，不出售、不用于广告，也不用于与该功能无关的用途；遵守 Chrome Web Store User Data Policy，包括 Limited Use 要求。

**远程代码：** 选择“否”。所有 JavaScript 均随扩展包分发，没有加载或执行远程代码。

## Test instructions 短版

后台上限为 500 字。以下 437 字正文已实际保存，并显示“已保存测试说明”；复制时保留五行换行。

```text
无需账号或付费。需要 Apple 芯片 Mac、macOS 13+ 和 Google Chrome。
App 下载：https://github.com/wuruoye/chrome-tab-router/releases/download/v1.3.2/chrome-tab-router-mac-1.3.2-arm64.zip
解压到 ~/Applications 并首次打开。预览包为临时签名，未 Apple 公证；如系统阻止，按“隐私与安全性”提示确认打开。首次路由时允许 App 控制 Chrome。
安装本次审核扩展，弹窗确认“已连接”。完整安装和测试步骤：https://ruoye.site/chrome-tab-router/
菜单开启复用、网页接管、新链接更新、刷新，并忽略所有查询参数与锚点。验证页依次点击三个链接：第一个新开；第二个复用原页并更新参数，标签页数不增加；第三个新开。Command/中键点击也复用。关闭接管或将该域名加入例外后正常新开。
```

## Test instructions 详细版

本扩展需要本机 Chrome Tab Router Mac 应用。无需账号、密码或付费。请使用 Apple 芯片 Mac、macOS 13 或更新版本，以及 Google Chrome。

1. 下载 Mac 应用： https://github.com/wuruoye/chrome-tab-router/releases/download/v1.3.2/chrome-tab-router-mac-1.3.2-arm64.zip 。解压后将 Chrome Tab Router.app 放入 ~/Applications 并打开。安装包使用临时签名，尚未经过 Apple 公证；macOS 如阻止首次打开，请按“系统设置 → 隐私与安全性”中的系统提示确认打开。
2. 安装本次审核的扩展。Mac 应用会登记正式扩展 ID；扩展自动检测本机连接。点击扩展图标确认“已连接”。如先安装扩展、后安装 App，请首次打开 App 后在扩展中点击“重新检测”。如仍未连接，先从 Mac 菜单栏“Chrome 扩展”中选择“修复自动连接”，再检测；必要时在扩展弹窗点击“修复连接”，允许打开 Mac 应用，然后重新打开弹窗确认。
3. 点击 Mac 菜单栏图标，确认“启用标签页复用”“接管 Chrome 网页的新标签页链接”“在所有 Chrome 窗口中查找”“切换到已有标签页后刷新”“复用时更新为新链接”均开启。在“网址匹配”中开启“忽略所有查询参数”和“忽略页面锚点”。例外网站列表保持为空。
4. 在 Chrome 打开 https://ruoye.site/chrome-tab-router/ 并到“验证标签页复用”部分。点击第一个链接，打开 https://ruoye.site/chrome-tab-router/demo/reuse.html?id=1#first 。首次处理时，如 macOS 请求自动化权限，允许 Mac 应用控制 Google Chrome；如已拒绝，可从菜单栏打开 Chrome 自动化权限设置。示例页显示自身完整地址、参数和锚点。
5. 回到验证页面，点击第二个链接。它使用 target=_blank，指向 https://ruoye.site/chrome-tab-router/demo/reuse.html?id=2#second 。预期：复用第 4 步的标签页，网址及页面中的地址展示更新为第 5 步的完整链接，并载入页面；标签页总数不增加。
6. 回到验证页面，点击第三个链接，指向 https://ruoye.site/chrome-tab-router/demo/other.html?id=3 。确保没有该 other.html 路径的其他标签页。预期：新增一个 Chrome 标签页；页面显示不同路径。
7. 在验证页面对第二个链接使用 Command 点击和鼠标中键点击，预期仍复用 reuse.html 的标签页。网页脚本不支持 Chrome Web Store 和 Chrome 内部页面，请在上述公开验证页面测试。
8. 在菜单栏关闭网页链接接管，再点击验证页面的新标签页链接，预期由 Chrome 正常新开。在“例外网站”中添加 ruoye.site 后，发往该域名及其子域名的链接也正常新开；测试完成后可在同一子菜单中移除。
9. 如需验证外部应用打开链接，在菜单栏“默认浏览器”中选择“设为默认浏览器”，确认系统提示后，从其他应用打开上述链接。HTTP/HTTPS 链接会由 Mac 应用匹配已有标签页；可使用“恢复原来的默认浏览器”恢复。

支持： https://github.com/wuruoye/chrome-tab-router/issues

隐私政策： https://ruoye.site/chrome-tab-router/privacy.html

## 图片材料

| 文件 | 尺寸 | 用途与状态 |
|---|---|---|
| `ChromeExtension/icons/icon128.png` | 128×128 | 商店图标，已上传并保存。 |
| `assets/mac-menu-1280x800.jpg` | 1280×800 | 真实 Mac 主菜单排版截图，已视觉核对、上传保存并确认留存；商品截图第 1 张。 |
| `assets/extension-popup-1280x800.jpg` | 1280×800 | 真实开发版扩展连接弹窗排版截图，已视觉核对、上传保存并确认留存；商品截图第 2 张。 |
| `assets/installation-page-1280x800.jpg` | 1280×800 | 真实线上安装说明网页的补充截图，已上传保存并确认留存；商品截图第 3 张，用于说明安装流程。 |
| `assets/chrome-web-store-small-promo.png` | 440×280 | 小宣传图，已上传并保存，说明标签页复用功能；同名 SVG 为可编辑原稿。 |
| `assets/mac-menu-1.3.0.jpg` | 548×854 | 真实 Mac 主菜单原图，用于生成排版截图。 |
| `assets/extension-popup-1.3.0.jpg` | 728×640 | 真实开发版扩展连接弹窗原图，用于生成排版截图。 |

两份界面图从真实原图生成，菜单背景已提亮，文字和设置保留，弹窗原图未修改；排版页为 [mac-menu.html](screenshots/mac-menu.html) 和 [extension-popup.html](screenshots/extension-popup.html)，最终 JPEG 为 1280×800。官网已上线，联系邮箱已验证，正式商店 ID 的实际连接、同完整网址复用、不同路径新开、参数与锚点更新、例外网站和两种暂停开关均已通过真实 Chrome 验证。验证时临时切换共享配置，原设置与测试页面已恢复和清理。公钥见 [chrome-extension-public-key.pem](chrome-extension-public-key.pem)，正式 ID 测试见 [official-id-testing.md](official-id-testing.md)，素材说明见 [assets/README.md](assets/README.md)。

## 参考资料

[商店资料字段](https://developer.chrome.com/docs/webstore/cws-dashboard-listing/)、[隐私字段与权限理由](https://developer.chrome.com/docs/webstore/cws-dashboard-privacy/)、[Native Messaging 用法](https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging)、[本机数据处理披露](https://developer.chrome.com/docs/webstore/program-policies/user-data-faq)。

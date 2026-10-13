# Chrome Tab Router

一个本地 Mac 链接处理应用。将它设为默认浏览器后，外部应用交给系统打开的 http / https 链接会先检查 Chrome 的已有标签页。

- 已有匹配网址的标签页：切换到那个标签页，可选择刷新和更新为新链接，不创建新标签页。
- 没有相同网址：在 Chrome 新开标签页。
- 默认按完整 URL 匹配。域名和协议转为小写，省略默认端口，并补齐根路径的 `/`；路径始终参与匹配。
- 多个窗口中都有相同网址时，优先选择靠前的窗口及其当前标签页。
- 链接顺序处理，避免连续打开同一链接时重复创建标签页。
- 所有设置均从菜单栏访问，同时提供打开剪贴板链接和退出。
- 菜单栏显示默认浏览器状态，提供设为默认浏览器和恢复原默认浏览器的操作。

## 设置与参数更新

点击菜单栏中的 Chrome Tab Router 图标即可查看和修改设置。“网址匹配”子菜单管理查询参数和锚点选项，“例外网站”子菜单管理排除域名。设置自动保存在 Mac 应用的 UserDefaults 中，扩展通过 Native Messaging 读取同一份设置。“Chrome 扩展”子菜单提供安装入口、自动连接配置与最近连接记录、修复自动连接、扩展目录、安装说明和隐私政策。

| 设置 | 行为 |
|---|---|
| 启用标签页复用 | 控制是否查找并复用已有标签页 |
| 切换后刷新 | 完整 URL 相同或保留原 URL 时刷新；关闭后保留页面状态 |
| 忽略页面锚点 | 匹配时不比较 `#` 后的内容 |
| 忽略跟踪参数 | 匹配时跳过 `utm_*`、`gclid`、`dclid`、`fbclid`、`msclkid`、`mc_cid`、`mc_eid` |
| 忽略所有查询参数 | 匹配时不比较 `?` 后的内容；启用后覆盖忽略跟踪参数选项 |
| 复用时更新为新链接 | 匹配到旧标签页后，将它的地址更新为收到的完整 URL |
| 在所有窗口中查找 | 关闭后只查找最前面的 Chrome 窗口 |
| 接管网页新标签页链接 | 控制 Chrome 配套扩展是否将网页中的新标签页链接交给 Mac 应用 |
| 例外网站 | 在“例外网站”子菜单中添加、查看和删除域名；指定域名及其子域名每次新开，网页扩展也跳过这些链接 |
| 登录时自动启动 | 使用 macOS 登录项服务，可在系统设置中管理 |

添加例外网站时，在菜单栏“例外网站”子菜单中选择添加操作，并在弹出的输入框中填写域名。

例如启用“忽略所有查询参数”“忽略页面锚点”和“复用时更新为新链接”后，先打开[本项目同路径示例 id=1](https://wuruoye.github.io/chrome-tab-router/demo/reuse.html?id=1#first)，再打开[同路径示例 id=2](https://wuruoye.github.io/chrome-tab-router/demo/reuse.html?id=2#second)，会保留原标签页并载入 `id=2` 的页面。参数变化产生一次导航加载；仅锚点变化时，按刷新开关决定是否重新载入。关闭“复用时更新为新链接”后，匹配到的标签页保留原地址。

## 下载与安装

[1.3.0 预览版](https://github.com/wuruoye/chrome-tab-router/releases/tag/v1.3.0)已公开发布，以下安装包和 Pages 页面已于 2026-10-13 完成发布核验。

- [Mac 应用 · Apple 芯片](https://github.com/wuruoye/chrome-tab-router/releases/download/v1.3.0/chrome-tab-router-mac-1.3.0-arm64.zip)
- [Chrome 扩展 ZIP](https://github.com/wuruoye/chrome-tab-router/releases/download/v1.3.0/chrome-tab-router-extension-1.3.0.zip)
- [官方网站与安装验证](https://ruoye.site/chrome-tab-router/)
- [隐私政策](https://ruoye.site/chrome-tab-router/privacy.html)
- [GitHub Pages 镜像](https://wuruoye.github.io/chrome-tab-router/)
- [联系与支持](https://github.com/wuruoye/chrome-tab-router/issues)

Mac 安装包支持 Apple 芯片和 macOS 13 或更新版本。下载后解压，将 `Chrome Tab Router.app` 放入 `~/Applications` 并打开。安装包使用临时签名，尚未经过 Apple 公证；macOS 如阻止首次打开，可按 [Apple 的说明](https://support.apple.com/guide/mac-help/open-a-mac-app-from-an-unknown-developer-mh40616/mac)在“系统设置 → 隐私与安全性”中确认打开。菜单栏“默认浏览器”中提供“设为默认浏览器”操作。首次路由链接时，允许应用控制 Google Chrome。

## 从源码编译

需要 macOS 13 或更新版本，以及 Xcode 命令行工具。本机构建当前 CPU 架构的应用。

```sh
zsh scripts/install.sh
```

应用安装在 `~/Applications/Chrome Tab Router.app`。点击菜单栏中的应用图标，选择“默认浏览器 → 设为默认浏览器”。首次打开链接时，允许应用控制 Google Chrome。

安装脚本会先编译再安装。仅编译、不安装时，运行 `zsh scripts/build.sh`。

如果自动化权限此前被拒绝，在“系统设置 → 隐私与安全性 → 自动化”中，允许 Chrome Tab Router 控制 Google Chrome。

## Chrome 配套扩展

外部应用打开的链接由 Mac 应用接收。Chrome 网页内部打开新标签页的链接需要配套扩展。

[Chrome Web Store 项目](https://chromewebstore.google.com/detail/chrome-tab-router/iineonbhdnmadlkkmdcofakekmjpnkmn)当前仍为草稿，上架后可通过此地址安装。Mac 菜单栏“Chrome 扩展”中提供商店入口和本地测试安装方式。

当前本地安装与测试步骤：

1. 打开 Mac 应用。在 Chrome 打开 `chrome://extensions/`，开启开发者模式，点击“加载已解压的扩展程序”。
2. 选择本项目的 `ChromeExtension` 目录、应用自带的扩展目录，或解压后的扩展 ZIP 目录；所选文件夹应直接包含 `manifest.json`。
3. 打开 Chrome 工具栏中的本扩展。如果弹窗仍未连接，点击“修复连接”，在 Chrome 提示时允许打开，并确认新的开发版连接请求。
4. 重新打开扩展弹窗，确认显示“已连接”。安装前已经打开的网页需要刷新一次以加载扩展脚本。

1.3.0 的 Mac 应用会在每次启动时自动登记正式扩展 ID；扩展在安装、Chrome 启动和打开弹窗时自动检测连接。先安装扩展、再安装 App 时，首次打开 App 后返回扩展弹窗或欢迎页，点击“重新检测”即可重试。主动连接开发版时，扩展会自动传递自己的 ID；Mac 应用同时保留正式 ID 和一个用户明确连接的开发版 ID，新开发版的连接请求需用户确认。无需复制 ID。

菜单栏显示“自动连接已配置”或最近连接时间，扩展弹窗显示本次检测结果。连接需要修复时，可先在菜单栏选择“修复自动连接”，再从扩展弹窗点击“重新检测”。若弹窗仍显示未连接，可点击“修复连接”，并在 Chrome 提示时允许打开本机应用；新开发版的连接请求还需在 App 中确认。已连接时可用“重新检测”或“打开 Mac 菜单”。

2026-10-13 已在真实 Chrome 工具栏核对 1.3.0 弹窗实际来源为正式商店 ID `iineonbhdnmadlkkmdcofakekmjpnkmn`，显示“已连接 · 网页链接接管已开启”，Mac 应用最近连接记录也来自该 ID。普通、Command 和中键点击同完整网址均复用原标签页，不同路径只新增一页；具体状态见[发布清单](distribution/release-checklist.md)。

网页新标签页链接、Command 点击和鼠标中键点击可在创建标签页前交给 Mac 应用。地址栏、书签、右键菜单、表单、脚本调用 `window.open()` 及普通当前页跳转由 Chrome 处理。匹配和路由会切换到目标标签页。

只在支持扩展脚本的 HTTP/HTTPS 网页中运行；Chrome 内部页面和 Chrome Web Store 等受保护页面不支持。Mac 应用连接不可用时，扩展保留 Chrome 原有行为或尝试直接新开目标链接。

正式发布准备见 [发布清单](distribution/release-checklist.md)、[商店填写材料](distribution/store-listing.md)和[隐私政策正文](distribution/privacy-policy.md)。运行 `sh scripts/package-extension.sh` 可生成 ZIP。2026-10-13 已核对商店草稿版本 1.3.0 及权限，商品说明、分类、语言、图标、宣传图和三张截图已保存；菜单图片已提亮，截图顺序为菜单栏、开发版扩展连接弹窗、安装说明。官网已部署到 Ruoye 服务器，联系邮箱已验证。正式 ID 的实际连接，以及同完整网址的普通、Command 和中键点击复用、不同路径新开已通过真实 Chrome 验证。参数与锚点更新、例外网站及暂停行为仍需提审前核对。尚未提交审核。

## 恢复与卸载

先在菜单栏关闭登录启动、选择“恢复原来的默认浏览器”，再退出应用，最后删除应用和 Chrome 扩展。

本机消息注册文件位于 `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.sigma.chrome_tab_router.json`，卸载时可一并删除。偏好设置的域为 `com.sigma.ChromeTabRouter`；需要清理时可运行 `defaults delete com.sigma.ChromeTabRouter`，并删除下面的日志目录。

偏好设置保存在应用自己的 UserDefaults 中。运行记录保存在 `~/Library/Logs/ChromeTabRouter/events.log`，仅包含时间和动作，不记录 URL 或网页内容。

可用以下命令检查 http / https 的系统默认处理应用：

```sh
"$HOME/Applications/Chrome Tab Router.app/Contents/MacOS/ChromeTabRouter" --status
```

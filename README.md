# Chrome Tab Router

一个本地 Mac 链接处理应用。将它设为默认浏览器后，外部应用交给系统打开的 http / https 链接会先检查 Chrome 的已有标签页。

- 已有匹配网址的标签页：切换到那个标签页，可选择刷新和更新为新链接，不创建新标签页。
- 没有相同网址：在 Chrome 新开标签页。
- 默认按完整 URL 匹配。域名和协议转为小写，省略默认端口，并补齐根路径的 `/`；路径始终参与匹配。
- 多个窗口中都有相同网址时，优先选择靠前的窗口及其当前标签页。
- 链接顺序处理，避免连续打开同一链接时重复创建标签页。
- 菜单栏提供设置、打开剪贴板链接和退出。
- 设置页提供恢复原默认浏览器的按钮。

## 设置与参数更新

设置自动保存在 Mac 应用中，扩展通过 Native Messaging 读取同一份设置。

| 设置 | 行为 |
|---|---|
| 切换后刷新 | 完整 URL 相同或保留原 URL 时刷新；关闭后保留页面状态 |
| 忽略页面锚点 | 匹配时不比较 `#` 后的内容 |
| 忽略跟踪参数 | 匹配时跳过 `utm_*`、`gclid`、`dclid`、`fbclid`、`msclkid`、`mc_cid`、`mc_eid` |
| 忽略所有查询参数 | 匹配时不比较 `?` 后的内容；启用后覆盖忽略跟踪参数选项 |
| 复用时更新为新链接 | 匹配到旧标签页后，将它的地址更新为收到的完整 URL |
| 在所有窗口中查找 | 关闭后只查找最前面的 Chrome 窗口 |
| 例外网站 | 指定域名及其子域名每次新开；网页扩展也跳过这些链接 |
| 登录时自动启动 | 使用 macOS 登录项服务，可在系统设置中管理 |

例如启用“忽略所有查询参数”和“复用时更新为新链接”后，已有 `https://example.com/page?id=1`，再打开 `https://example.com/page?id=2`，会保留原标签页并载入 `id=2` 的页面。参数变化产生一次导航加载；仅锚点变化时，按刷新开关决定是否重新载入。关闭“复用时更新为新链接”后，匹配到的标签页保留原地址。

## 编译与安装

需要 macOS 13 或更新版本，以及 Xcode 命令行工具。本机构建当前 CPU 架构的应用。

```sh
zsh scripts/install.sh
```

应用安装在 `~/Applications/Chrome Tab Router.app`。打开设置页，点击“设为默认浏览器”。首次打开链接时，允许应用控制 Google Chrome。

安装脚本会先编译再安装。仅编译、不安装时，运行 `zsh scripts/build.sh`。

如果自动化权限此前被拒绝，在“系统设置 → 隐私与安全性 → 自动化”中，允许 Chrome Tab Router 控制 Google Chrome。

## Chrome 配套扩展

外部应用打开的链接由 Mac 应用接收。Chrome 网页内部打开新标签页的链接需要配套扩展。

1. 在 Chrome 打开 `chrome://extensions/`，开启开发者模式，点击“加载已解压的扩展程序”。
2. 选择本项目的 `ChromeExtension` 目录；也可在 Mac 设置中打开应用自带的扩展目录。
3. 点击 Chrome 工具栏中的本扩展，选择“连接 Mac 应用”，在 Chrome 提示时允许打开。
4. 重新打开扩展弹窗，确认显示“已连接”。安装前已经打开的网页需要刷新一次以加载扩展脚本。

连接过程会自动传递扩展 ID。Mac 应用仅为该 ID 注册本机 Native Messaging host。网页新标签页链接、Command 点击和鼠标中键点击可在创建标签页前交给 Mac 应用。地址栏、书签、右键菜单、表单、脚本调用 `window.open()` 及普通当前页跳转由 Chrome 处理。匹配和路由会切换到目标标签页。

只在支持扩展脚本的 HTTP/HTTPS 网页中运行；Chrome 内部页面和 Chrome Web Store 等受保护页面不支持。Mac 应用连接不可用时，扩展保留 Chrome 原有行为或尝试直接新开目标链接。

正式发布准备见 [发布清单](distribution/release-checklist.md)、[商店文案](distribution/store-listing.md)和[隐私政策草稿](distribution/privacy-policy.md)。运行 `sh scripts/package-extension.sh` 可生成 ZIP；当前尚未上传商店或提交审核。

## 恢复与卸载

先在设置页关闭登录启动、点击“恢复原来的默认浏览器”，再从菜单栏退出，最后删除应用和 Chrome 扩展。

本机消息注册文件位于 `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.sigma.chrome_tab_router.json`，卸载时可一并删除。偏好设置的域为 `com.sigma.ChromeTabRouter`；需要清理时可运行 `defaults delete com.sigma.ChromeTabRouter`，并删除下面的日志目录。

偏好设置保存在应用自己的 UserDefaults 中。运行记录保存在 `~/Library/Logs/ChromeTabRouter/events.log`，仅包含时间和动作，不记录 URL 或网页内容。

可用以下命令检查 http / https 的系统默认处理应用：

```sh
"$HOME/Applications/Chrome Tab Router.app/Contents/MacOS/ChromeTabRouter" --status
```

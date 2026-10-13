# Chrome Web Store 发布清单

核对日期：2026-10-13。准备版本：Mac 应用与扩展 1.3.0。本清单按仓库实现和下列 Chrome 官方资料整理。商店后台字段及审核结果以实际页面为准。1.3.0 已按用户指示提交审核，后台显示“待审核”，审核后自动发布关闭。审核通过后的公开发布须另获用户授权。

## 本地安装与材料

- [x] 核对最终 `ChromeExtension/manifest.json` 的版本、权限和图标。仅保留功能必需的权限；`chrome.tabs.create()` 本身无需 `tabs` 权限。当前功能需要 `nativeMessaging`，因为 service worker 通过 `chrome.runtime.sendNativeMessage()` 调用本机 Mac 应用。`http://*/*`、`https://*/*` 和 `all_frames` 使脚本能在各网页的框架中识别用户点击的新标签页链接，应在商店隐私字段解释这一范围。
- [x] 准备 128×128 PNG 扩展图标并写入 `icons.128`；同时准备 16×16 和 48×48 图标用于 Chrome 界面。图标需与最终 ZIP 中的文件一致。
- [x] 执行 `sh scripts/package-extension.sh`。脚本校验 Manifest V3、版本、128×128 PNG 图标和 ZIP 内容，生成 `build/chrome-tab-router-extension-<version>.zip`。确认 `manifest.json` 位于 ZIP 根目录；每次更新使用高于已上传版本的版本号。
- [x] 历史验证：扩展 1.2.0 已于 2026-10-13 在真实 Chrome 中完成加载、连接及网页链接验证：`target="_blank"` 的同路径链接保留原标签页并更新查询参数；不同路径只新增一个标签页。Mac 应用日志确认分别执行了复用更新和新建。
- [x] Mac 1.3.0 已于 2026-10-13 完成构建与安装；严格签名检查、本机协议读取共享设置、正式扩展 ID 与一个已批准开发版 ID 的允许来源检查均通过。
- [x] 用户于 2026-10-13 确认 Chrome 扩展 1.3.0 已重载，并自动显示“已连接”。
- [x] 主线程于 2026-10-13 在真实 Chrome 工具栏打开开发版扩展 `epmhbckoikdfejlaelgbihlbmhplopld` 的弹窗，看到“已连接 · 网页链接接管已开启”，并核对共享设置与 Mac 当前设置一致。已保存 728×640 原始弹窗截图 `assets/extension-popup-1.3.0.jpg`。
- [x] 2026-10-13 在真实 Chrome 中验证扩展 1.3.0：首次点击同路径示例新增一页；再次普通点击、Command 点击和中键点击同一个完整网址，均保留原标签页且数量不变；点击不同路径只新增一页。使用当前设置，未改动用户偏好。验证截图保存在本地 `build/reuse-verification-1.3.0.jpg` 与 `build/other-path-verification-1.3.0.jpg`。
- [x] 准备补充安装说明截图 `assets/installation-page-1280x800.jpg`，已于 2026-10-13 核对尺寸为 1280×800。画面来自真实线上安装说明网页，用于说明安装流程。
- [x] 从真实主菜单和开发版扩展弹窗原图生成 `assets/mac-menu-1280x800.jpg` 与 `assets/extension-popup-1280x800.jpg`。主线程已视觉核对，`sips` 实测两份均为 1280×800；对应排版页为 `screenshots/mac-menu.html` 和 `screenshots/extension-popup.html`。
- [x] 制作 440×280 小宣传图，文件为 `assets/chrome-web-store-small-promo.png`，可编辑原稿为同名 SVG。素材已于 2026-10-13 检查尺寸、文字与配色；宣传图只说明已实现的标签页复用功能。
- [x] 准备完整的商店填写材料、安装说明和审核测试步骤，文件为 `distribution/store-listing.md`、`README.md` 和 `docs/index.html`。公开开发者名称使用 wuruoye，支持渠道为 [GitHub Issues](https://github.com/wuruoye/chrome-tab-router/issues)。
- [x] 准备无占位符的隐私政策正文及静态页面，文件为 `distribution/privacy-policy.md` 和 `docs/privacy.html`，生效日期为 2026-10-13。公开页面不含私人联系方式、分析脚本或表单。

## 下载与公开页面部署

- [x] [GitHub Release v1.3.0](https://github.com/wuruoye/chrome-tab-router/releases/tag/v1.3.0)已公开发布为预览版。2026-10-13 核验 [Mac 安装包](https://github.com/wuruoye/chrome-tab-router/releases/download/v1.3.0/chrome-tab-router-mac-1.3.0-arm64.zip)下载跳转后返回 HTTP 200，内容为 Apple 芯片版 1.3.0 应用。扩展核心功能依赖本机应用，审核人员需要能安装并使用。安装包使用临时签名，尚未经过 Apple 公证，安装说明已披露。
- [x] [扩展 ZIP](https://github.com/wuruoye/chrome-tab-router/releases/download/v1.3.0/chrome-tab-router-extension-1.3.0.zip)已随 1.3.0 预览版发布，2026-10-13 核对 Release 资产存在，用于商店上架前的本地安装与测试。
- [x] GitHub Pages 已使用 `main:/docs` 部署，2026-10-13 核验最新构建状态为 `built`，[安装说明与验证页面](https://wuruoye.github.io/chrome-tab-router/)已部署，[隐私政策](https://wuruoye.github.io/chrome-tab-router/privacy.html)返回 HTTP 200，均为公开页面。
- [x] 本项目自有的 [同路径示例](https://wuruoye.github.io/chrome-tab-router/demo/reuse.html?id=1#first)和[不同路径示例](https://wuruoye.github.io/chrome-tab-router/demo/other.html?id=3)已上线，2026-10-13 核验均返回 HTTP 200。页面仅展示自身完整地址、参数和锚点，无后台请求或追踪；用于更新参数、复用标签页及不同路径新开页面的审核演示和截图。

## 商店草稿

- [x] 2026-10-13 官网已部署到 [Ruoye 服务器](https://ruoye.site/chrome-tab-router/)，首页、隐私政策、图片、样式与验证页均返回 HTTP 200；浏览器已核对桌面、手机布局和演示页面实际网址展示。部署说明见 [ruoye-site-deploy.md](ruoye-site-deploy.md)。

- [x] 已使用注册开发者账户创建并更新本项目草稿。
- [x] 扩展 1.2.0 首次于 2026-10-13 上传商店草稿，Item ID 为 `iineonbhdnmadlkkmdcofakekmjpnkmn`，当前审核版本为 1.3.0。
- [x] 用户于 2026-10-13 确认扩展 1.3.0 ZIP 已上传到同一商店草稿。
- [x] 主线程于 2026-10-13 上传原 1.3.0 ZIP 后，在 Package 页面明确核对到版本 1.3.0、`nativeMessaging` 与主机权限范围；提交前已再次核对。
- [x] 主线程在 Package 页读取公钥，保存为 [chrome-extension-public-key.pem](chrome-extension-public-key.pem)。已准备[正式 ID 本地验证说明](official-id-testing.md)和 `build/ChromeExtension-store-id/` 测试副本；用户加载后已核对真实弹窗的正式 ID 与自动连接。
- [x] 核对 Mac 应用的 Native Messaging host 允许来源已包含商店草稿的扩展 ID 和一个此前已批准的开发版 ID；该 host 仅允许正式 ID 和用户明确连接的开发版 ID。
- [x] 已批准开发版 ID 的真实弹窗连接与共享设置已由主线程核对。
- [x] 用户于 2026-10-13 确认说明、首页和支持网址在前台显示正常。
- [x] 主线程于 2026-10-13 在 Privacy 表单填入单一用途、`nativeMessaging` 理由、主机访问范围理由和隐私政策网址；选择不使用远程代码，勾选数据类别“网络记录”和“网站内容”（表单举例包含超链接），并勾选三项符合实际处理行为的 Limited Use 披露。保存后看到“已成功保存内容。”。
- [x] Store Listing 分类为“工具”，语言为“中文（中国）”；128×128 商店图标、440×280 宣传图及 1280×800 补充安装说明截图均已上传并保存。说明、首页和支持网址的前台显示已由用户确认。
- [x] 商品详细说明最终为 1362 字，官网地址改为 Ruoye 服务器；商品详情显示“已成功保存内容。”。
- [x] 商品详情中的三张截图已保存；菜单图已提亮、菜单与扩展弹窗采用新排版，顺序为 Mac 菜单栏、开发版扩展连接弹窗、安装说明。
- [x] 已只读核对 Distribution 的原有设置为免费、公开、所有地区，保留原设置。
- [x] Test instructions 表单上限为 500 字，已保存 `distribution/store-listing.md` 中的 437 字短版，并显示“已保存测试说明”。完整 9 步保留在材料详细版，公开安装页提供安装与验证说明。
- [x] 首页、详细说明、隐私政策和测试说明中的链接已更新为官网；返回商品详情后确认 1362 字说明、首页网址和三张图片留存。1.3.0 已提交审核，后台显示“待审核”。

## 提审前验证与账户事项

- [x] 2026-10-13 用户加载正式 ID 测试副本后，真实 Chrome 弹窗的实际 URL 为 `chrome-extension://iineonbhdnmadlkkmdcofakekmjpnkmn/popup.html`，显示“已连接 · 网页链接接管已开启”；Mac 应用的 `chromeExtensionLastContactID` 同时记录该正式 ID。按用户当前设置测试：首次新增标签页 `1803923998`，再次普通、Command 和中键点击均保留该标签页，总数保持 7；不同路径只新增 `1803924002`，总数为 8。两张验证截图保存在本地 `build/official-id-reuse-verification-1.3.0.jpg` 与 `build/official-id-other-path-verification-1.3.0.jpg`，测试结束仅清理本次创建的三个标签页。
- [x] 2026-10-13 使用正式 ID 1.3.0，在真实 Chrome 中验证同路径参数与锚点更新：临时开启忽略所有查询参数、忽略锚点、新链接更新和刷新后，`reuse.html?id=1#first` 更新为 `reuse.html?id=2#second`，保留标签页 `1803924033`，总数保持 10；Mac 操作日志记录 `reused-updated`。截图保存在本地 `build/official-id-parameter-update-verification-1.3.0.jpg`。
- [x] 2026-10-13 临时将 `ruoye.site` 加入共享配置的例外网站，在真实 Chrome 中连续两次点击同一链接，均各新开一页，原页保留，总数依次为 10、11、12。
- [x] 2026-10-13 分别关闭 `interceptBrowserLinks` 与 `enabled`，在真实 Chrome 中重复点击同一链接，均每次新开一页；关闭 `enabled` 时，正式 ID 弹窗显示“已连接 · 网页链接接管已暂停”。恢复后再次点击复用原标签页，数量不增加，Mac 日志记录 `reused`。
- [x] 本次通过 `defaults` 临时修改应用与扩展共用的 UserDefaults，再通过真实网页点击核对行为；菜单栏应用的界面读取超时，未覆盖菜单控件操作。测试结束已恢复七个修改项的原值与是否显式保存，当前忽略查询参数关闭、忽略锚点与跟踪参数开启、复用时刷新关闭、复用与网页接管开启，例外网站为空。测试页面已清理。
- [x] 2026-10-13 在已加载正式 ID 的真实 Chrome 网页中，临时停用本机 Native Messaging 登记后点击示例链接，只新增一页 `1803924120`，实际页面正常显示目标地址。本机登记文件已按原内容与权限恢复，测试页面已清理。
- [x] 提审前已核对菜单设置、商品说明、扩展弹窗、隐私政策及代码中的数据处理行为：全部设置由 Mac 菜单管理，完整 URL 仅用于本机匹配与更新，操作日志只记录动作和时间。菜单显示此前已由用户确认；本轮未操作菜单控件。
- [x] 2026-10-13 再次核对本地 1.3.0 ZIP 的 Manifest、后台脚本、网页脚本与弹窗文件均与源码一致；官网、隐私政策和公开 Mac 下载地址均返回 HTTP 200。
- [x] 按用户明确授权，在开发者账户中提供公开联系邮箱。
- [x] 2026-10-13 通过 Google 验证邮件完成确认，后台显示“您的联系电子邮件地址现已通过验证。”。

## 提审和公开发布

- [x] 2026-10-13 核对后台 1.3.0 软件包、隐私披露、1362 字商品说明、三张图片及 437 字测试步骤后提交审核。确认框中的“通过审核后自动发布”已关闭；Google 提示全站访问权限可能需深入审核。提交回执显示“待审核”，确认内容已提交并正接受合规性审核。回执截图保存在本地 `build/chrome-web-store-review-receipt-1.3.0.jpg`。审核通过后手动发布；已暂存版本须在 30 天内发布，否则会回到草稿。
- [ ] 审核通过且决定对外提供时，账户持有人核对可见性与地区并执行发布。正式面向所有人时选择 Public。之后核对商店页面、安装、Native Messaging 连接、隐私政策链接和支持链接。

## 官方依据

- [注册开发者账户](https://developer.chrome.com/docs/webstore/register/)；[设置账户和验证邮箱](https://developer.chrome.com/docs/webstore/set-up-account/)；[开发者协议与注册费](https://developer.chrome.com/docs/webstore/program-policies/terms)；[2026 年官方更新提及 5 美元](https://developer.chrome.com/docs/extensions/whats-new/)；[Trader 验证常见问题](https://developer.chrome.com/docs/webstore/program-policies/trader-verification-faq)
- [准备扩展与 ZIP](https://developer.chrome.com/docs/webstore/prepare/)；[图片要求](https://developer.chrome.com/docs/webstore/images/)；[扩展图标](https://developer.chrome.com/docs/extensions/reference/manifest/icons/)；[Tabs API 权限](https://developer.chrome.com/docs/extensions/reference/api/tabs)；[Native Messaging](https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging)
- [发布步骤和延期发布](https://developer.chrome.com/docs/webstore/publish/)；[草稿公钥与稳定 ID](https://developer.chrome.com/docs/extensions/reference/manifest/key)；[隐私字段](https://developer.chrome.com/docs/webstore/cws-dashboard-privacy/)；[本机数据处理仍须披露](https://developer.chrome.com/docs/webstore/program-policies/user-data-faq)；[2026 年隐私政策更新](https://developer.chrome.com/blog/cws-policy-updates-2026)
- [可见性及审核](https://developer.chrome.com/docs/webstore/cws-dashboard-distribution/)；[审核测试说明](https://developer.chrome.com/docs/webstore/cws-dashboard-test-instructions/)；[两步验证要求](https://developer.chrome.com/docs/webstore/program-policies/policies)

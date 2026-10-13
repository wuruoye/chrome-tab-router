# Chrome Web Store 发布清单

核对日期：2026-10-13。准备版本：Mac 应用与扩展 1.3.0。本清单按仓库实现和下列 Chrome 官方资料整理。商店后台字段及审核结果以实际页面为准。当前只准备和更新草稿，尚未提交审核；提交审核、设置可见性和公开发布须另获用户授权。

## 目前可在本地完成

- [x] 核对最终 `ChromeExtension/manifest.json` 的版本、权限和图标。仅保留功能必需的权限；`chrome.tabs.create()` 本身无需 `tabs` 权限。当前功能需要 `nativeMessaging`，因为 service worker 通过 `chrome.runtime.sendNativeMessage()` 调用本机 Mac 应用。`http://*/*`、`https://*/*` 和 `all_frames` 使脚本能在各网页的框架中识别用户点击的新标签页链接，应在商店隐私字段解释这一范围。
- [x] 准备 128×128 PNG 扩展图标并写入 `icons.128`；同时准备 16×16 和 48×48 图标用于 Chrome 界面。图标需与最终 ZIP 中的文件一致。
- [x] 执行 `sh scripts/package-extension.sh`。脚本校验 Manifest V3、版本、128×128 PNG 图标和 ZIP 内容，生成 `build/chrome-tab-router-extension-<version>.zip`。确认 `manifest.json` 位于 ZIP 根目录；每次更新使用高于已上传版本的版本号。
- [x] 历史验证：扩展 1.2.0 已于 2026-10-13 在真实 Chrome 中完成加载、连接及网页链接验证：`target="_blank"` 的同路径链接保留原标签页并更新查询参数；不同路径只新增一个标签页。Mac 应用日志确认分别执行了复用更新和新建。
- [ ] 提交审核前核对菜单栏中的全部开关、默认浏览器操作、扩展连接状态、安装说明，以及“例外网站”子菜单的域名添加、查看和删除操作。继续核对排除域名、暂停功能、本机应用不可用时的行为，以及 Command/中键点击。还须核对产品界面在处理浏览 URL 前清楚说明用途并取得用户同意，商店页面、隐私政策和实际界面用语应一致。
- [x] Mac 1.3.0 已于 2026-10-13 完成构建与安装；严格签名检查、本机协议读取共享设置、正式扩展 ID 与一个已批准开发版 ID 的允许来源检查均通过。允许来源已配置，实际 Chrome 自动连接仍待验证。
- [ ] 在真实 Chrome 中重载扩展 1.3.0，核对扩展弹窗的本次连接结果，再验证自动连接、同路径参数更新和不同路径新开页面。
- [ ] 制作至少一张真实功能截图，尺寸为 1280×800 或 640×400，方角且无留白。采集菜单栏设置界面、Chrome 扩展连接界面及实际点击验证画面，并按商店尺寸整理。
- [x] 准备补充安装说明截图 `assets/installation-page-1280x800.jpg`，已于 2026-10-13 核对尺寸为 1280×800。画面来自真实线上安装说明网页，仅用于说明安装流程；菜单栏、扩展弹窗和功能验证截图仍待完成。
- [x] 制作 440×280 小宣传图，文件为 `assets/chrome-web-store-small-promo.png`，可编辑原稿为同名 SVG。素材已于 2026-10-13 检查尺寸、文字与配色；宣传图只说明已实现的标签页复用功能。
- [x] 准备完整的商店填写材料、安装说明和审核测试步骤，文件为 `distribution/store-listing.md`、`README.md` 和 `docs/index.html`。公开开发者名称使用 wuruoye，支持渠道为 [GitHub Issues](https://github.com/wuruoye/chrome-tab-router/issues)。
- [x] 准备无占位符的隐私政策正文及静态页面，文件为 `distribution/privacy-policy.md` 和 `docs/privacy.html`，生效日期为 2026-10-13。公开页面不含私人联系方式、分析脚本或表单。

## 下载与公开页面部署

- [x] [GitHub Release v1.3.0](https://github.com/wuruoye/chrome-tab-router/releases/tag/v1.3.0)已公开发布为预览版。2026-10-13 核验 [Mac 安装包](https://github.com/wuruoye/chrome-tab-router/releases/download/v1.3.0/chrome-tab-router-mac-1.3.0-arm64.zip)下载跳转后返回 HTTP 200，内容为 Apple 芯片版 1.3.0 应用。扩展核心功能依赖本机应用，审核人员需要能安装并使用。安装包使用临时签名，尚未经过 Apple 公证，安装说明已披露。
- [x] [扩展 ZIP](https://github.com/wuruoye/chrome-tab-router/releases/download/v1.3.0/chrome-tab-router-extension-1.3.0.zip)已随 1.3.0 预览版发布，2026-10-13 核对 Release 资产存在，用于商店上架前的本地安装与测试。
- [x] GitHub Pages 已使用 `main:/docs` 部署，2026-10-13 核验最新构建状态为 `built`，[安装说明与验证页面](https://wuruoye.github.io/chrome-tab-router/)已部署，[隐私政策](https://wuruoye.github.io/chrome-tab-router/privacy.html)返回 HTTP 200，均为公开页面。
- [x] 本项目自有的 [同路径示例](https://wuruoye.github.io/chrome-tab-router/demo/reuse.html?id=1#first)和[不同路径示例](https://wuruoye.github.io/chrome-tab-router/demo/other.html?id=3)已上线，2026-10-13 核验均返回 HTTP 200。页面仅展示自身完整地址、参数和锚点，无后台请求或追踪；用于更新参数、复用标签页及不同路径新开页面的审核演示和截图。

## 开发者账户与草稿

- [ ] 选定负责发布的 Google 账户。Chrome Web Store 要求注册开发者账户、接受协议并支付一次性注册费。官方 2026 年页面提及 5 美元，实际金额和付款条件以注册页面显示为准。账户邮箱创建后不能直接修改。
- [ ] 在 Account 页面填写发布者名称、验证联系邮箱，并为 Google 账户开启两步验证。发布者还须声明 Trader 或 Non-Trader；若选择 Trader，按后台要求完成身份验证，法律名称、电话和地址等资料可能展示在商店页面。不要在文案中预填个人资料。
- [x] 扩展 1.2.0 已于 2026-10-13 上传商店草稿，Item ID 为 `iineonbhdnmadlkkmdcofakekmjpnkmn`，尚未提交审核。
- [ ] 将最终扩展 1.3.0 ZIP 更新到同一商店草稿，核对 Package 页面版本及权限；先不提交审核。
- [ ] 在 Package 页 **View public key** 获取该项目的公钥。若本地解压加载需要与商店草稿保持同一个扩展 ID，可按官方 `manifest.key` 文档将公钥内容写入本地开发用 Manifest，并核对 `chrome://extensions` 的 ID。公钥与私钥不同，不要上传私钥。
- [x] 核对 Mac 应用的 Native Messaging host 允许来源已包含商店草稿的扩展 ID 和一个此前已批准的开发版 ID；该 host 仅允许正式 ID 和用户明确连接的开发版 ID。
- [ ] 在真实 Chrome 中验证正式 ID 的自动连接；如使用本地开发版，同时核对已批准的开发版 ID 仍可连接。允许来源配置通过不代表实际连接验证已完成。
- [ ] 在 Store Listing 填入最终标题、简述、详细说明、截图和宣传图；在 Privacy 填入唯一用途、每项权限及网站访问范围的理由、数据处理分类和公开隐私政策 URL。点击链接的完整 URL 以及 Mac 应用读取的现有标签页 URL 属于浏览活动数据；即使只在本机处理也必须如实披露。后台分类选项以实际页面为准，不应填写“完全不处理用户数据”。
- [ ] 在 Distribution 选择销售模式、地区和可见性。Public 可被所有用户看到和安装；Unlisted 持链接者可安装；Private 限指定测试者。三种可见性都经过相同政策审核。若要先让指定测试者安装，添加 trusted testers，并选择 Private。
- [ ] 将 `distribution/store-listing.md` 中完整的 Test instructions 填入草稿，包含 App 下载、安装与连接、菜单栏设置、无账号验证链接和预期结果。该字段按官方说明不是发布必填项。

## 提审和公开发布

- [ ] 核对后台所有字段及 ZIP 版本后，账户持有人点击 **Submit for Review**。若只希望先通过审核、不自动公开，提交时关闭审核通过后立即发布选项，使用 deferred publishing。审核通过后须在 30 天内手动发布，否则已暂存提交会回到草稿。
- [ ] 审核通过且决定对外提供时，账户持有人核对可见性与地区并执行发布。正式面向所有人时选择 Public。之后核对商店页面、安装、Native Messaging 连接、隐私政策链接和支持链接。

## 官方依据

- [注册开发者账户](https://developer.chrome.com/docs/webstore/register/)；[设置账户和验证邮箱](https://developer.chrome.com/docs/webstore/set-up-account/)；[开发者协议与注册费](https://developer.chrome.com/docs/webstore/program-policies/terms)；[2026 年官方更新提及 5 美元](https://developer.chrome.com/docs/extensions/whats-new/)；[Trader 验证常见问题](https://developer.chrome.com/docs/webstore/program-policies/trader-verification-faq)
- [准备扩展与 ZIP](https://developer.chrome.com/docs/webstore/prepare/)；[图片要求](https://developer.chrome.com/docs/webstore/images/)；[扩展图标](https://developer.chrome.com/docs/extensions/reference/manifest/icons/)；[Tabs API 权限](https://developer.chrome.com/docs/extensions/reference/api/tabs)；[Native Messaging](https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging)
- [发布步骤和延期发布](https://developer.chrome.com/docs/webstore/publish/)；[草稿公钥与稳定 ID](https://developer.chrome.com/docs/extensions/reference/manifest/key)；[隐私字段](https://developer.chrome.com/docs/webstore/cws-dashboard-privacy/)；[本机数据处理仍须披露](https://developer.chrome.com/docs/webstore/program-policies/user-data-faq)；[2026 年隐私政策更新](https://developer.chrome.com/blog/cws-policy-updates-2026)
- [可见性及审核](https://developer.chrome.com/docs/webstore/cws-dashboard-distribution/)；[审核测试说明](https://developer.chrome.com/docs/webstore/cws-dashboard-test-instructions/)；[两步验证要求](https://developer.chrome.com/docs/webstore/program-policies/policies)

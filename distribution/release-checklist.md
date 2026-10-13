# Chrome Web Store 发布清单

核对日期：2026-10-12。本清单按仓库当前实现和下列 Chrome 官方资料整理。商店后台字段及审核结果以实际页面为准。注册、付款、提交审核、设置可见性和公开发布均需由开发者账户持有人操作。

## 目前可在本地完成

- [x] 核对最终 `ChromeExtension/manifest.json` 的版本、权限和图标。仅保留功能必需的权限；`chrome.tabs.create()` 本身无需 `tabs` 权限。当前功能需要 `nativeMessaging`，因为 service worker 通过 `chrome.runtime.sendNativeMessage()` 调用本机 Mac 应用。`http://*/*`、`https://*/*` 和 `all_frames` 使脚本能在各网页的框架中识别用户点击的新标签页链接，应在商店隐私字段解释这一范围。
- [x] 准备 128×128 PNG 扩展图标并写入 `icons.128`；同时准备 16×16 和 48×48 图标用于 Chrome 界面。图标需与最终 ZIP 中的文件一致。
- [x] 执行 `sh scripts/package-extension.sh`。脚本校验 Manifest V3、版本、128×128 PNG 图标和 ZIP 内容，生成 `build/chrome-tab-router-extension-<version>.zip`。确认 `manifest.json` 位于 ZIP 根目录；每次更新使用高于已上传版本的版本号。
- [x] 已于 2026-10-13 在真实 Chrome 中完成扩展加载、自动连接及网页链接验证：`target="_blank"` 的同路径链接保留原标签页并更新查询参数；不同路径只新增一个标签页。Mac 应用日志确认分别执行了复用更新和新建。
- [ ] 提交审核前继续核对排除域名、暂停功能、本机应用不可用时的行为，以及 Command/中键点击。还须核对产品界面在处理浏览 URL 前清楚说明用途并取得用户同意，商店页面、隐私政策和实际界面用语应一致。
- [ ] 制作至少一张真实功能截图，尺寸为 1280×800 或 640×400，方角且无留白。已保存 Mac 设置的原始截图 `assets/mac-settings-source.png`；这张原图仍需按商店尺寸整理，Chrome 扩展连接界面及实际点击验证尚待完成。
- [x] 制作 440×280 小宣传图，文件为 `assets/chrome-web-store-small-promo.png`，可编辑原稿为同名 SVG。素材已于 2026-10-13 检查尺寸、文字与配色；宣传图只说明已实现的标签页复用功能。
- [ ] 确定可供用户和审核人员获取的 Mac 应用安装包、下载地址、安装说明及支持渠道；当前仓库没有可在商店引用的正式下载地址。扩展核心功能依赖本机应用，审核人员也需能实际操作。
- [ ] 核对 `distribution/store-listing.md` 和 `distribution/privacy-policy.md`。补齐开发者名称、联系邮箱、应用下载地址及公开托管的隐私政策 URL 后，再复制到后台。隐私政策不能只留在仓库文件中。

## 开发者账户与草稿

- [ ] 选定负责发布的 Google 账户。Chrome Web Store 要求注册开发者账户、接受协议并支付一次性注册费。官方 2026 年页面提及 5 美元，实际金额和付款条件以注册页面显示为准。账户邮箱创建后不能直接修改。
- [ ] 在 Account 页面填写发布者名称、验证联系邮箱，并为 Google 账户开启两步验证。发布者还须声明 Trader 或 Non-Trader；若选择 Trader，按后台要求完成身份验证，法律名称、电话和地址等资料可能展示在商店页面。不要在文案中预填个人资料。
- [ ] 用最终扩展 ZIP 在 Developer Dashboard 选择 **Add new item**，先保存草稿。上传成功后记录 Item ID；在 Package 页 **View public key** 可获取该项目的公钥。若本地解压加载需要与商店草稿保持同一个扩展 ID，可按官方 `manifest.key` 文档将公钥内容写入本地开发用 Manifest，并核对 `chrome://extensions` 的 ID。公钥与私钥不同，不要上传私钥。Mac 应用的 Native Messaging host 只允许指定扩展 ID，上传后需核对连接使用的是该 Item ID。
- [ ] 在 Store Listing 填入最终标题、简述、详细说明、截图和宣传图；在 Privacy 填入唯一用途、每项权限及网站访问范围的理由、数据处理分类和公开隐私政策 URL。点击链接的完整 URL 以及 Mac 应用读取的现有标签页 URL 属于浏览活动数据；即使只在本机处理也必须如实披露。后台分类选项以实际页面为准，不应填写“完全不处理用户数据”。
- [ ] 在 Distribution 选择销售模式、地区和可见性。Public 可被所有用户看到和安装；Unlisted 持链接者可安装；Private 限指定测试者。三种可见性都经过相同政策审核。若要先让指定测试者安装，添加 trusted testers，并选择 Private。
- [ ] 在 Test instructions 提供 Mac 应用取得方式、安装与连接步骤、可复现的测试链接和预期结果，便于审核人员验证依赖本机应用的功能。该字段按官方说明不是发布必填项。

## 提审和公开发布

- [ ] 核对后台所有字段及 ZIP 版本后，账户持有人点击 **Submit for Review**。若只希望先通过审核、不自动公开，提交时关闭审核通过后立即发布选项，使用 deferred publishing。审核通过后须在 30 天内手动发布，否则已暂存提交会回到草稿。
- [ ] 审核通过且决定对外提供时，账户持有人核对可见性与地区并执行发布。正式面向所有人时选择 Public。之后核对商店页面、安装、Native Messaging 连接、隐私政策链接和支持链接。

## 官方依据

- [注册开发者账户](https://developer.chrome.com/docs/webstore/register/)；[设置账户和验证邮箱](https://developer.chrome.com/docs/webstore/set-up-account/)；[开发者协议与注册费](https://developer.chrome.com/docs/webstore/program-policies/terms)；[2026 年官方更新提及 5 美元](https://developer.chrome.com/docs/extensions/whats-new/)；[Trader 验证常见问题](https://developer.chrome.com/docs/webstore/program-policies/trader-verification-faq)
- [准备扩展与 ZIP](https://developer.chrome.com/docs/webstore/prepare/)；[图片要求](https://developer.chrome.com/docs/webstore/images/)；[扩展图标](https://developer.chrome.com/docs/extensions/reference/manifest/icons/)；[Tabs API 权限](https://developer.chrome.com/docs/extensions/reference/api/tabs)；[Native Messaging](https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging)
- [发布步骤和延期发布](https://developer.chrome.com/docs/webstore/publish/)；[草稿公钥与稳定 ID](https://developer.chrome.com/docs/extensions/reference/manifest/key)；[隐私字段](https://developer.chrome.com/docs/webstore/cws-dashboard-privacy/)；[本机数据处理仍须披露](https://developer.chrome.com/docs/webstore/program-policies/user-data-faq)；[2026 年隐私政策更新](https://developer.chrome.com/blog/cws-policy-updates-2026)
- [可见性及审核](https://developer.chrome.com/docs/webstore/cws-dashboard-distribution/)；[审核测试说明](https://developer.chrome.com/docs/webstore/cws-dashboard-test-instructions/)；[两步验证要求](https://developer.chrome.com/docs/webstore/program-policies/policies)

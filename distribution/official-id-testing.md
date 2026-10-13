# 正式扩展 ID 本地验证

准备版本：1.3.0。材料核对日期：2026-10-13。正式 ID 的 Chrome 显示及自动连接仍须实际核对，尚未提交审核。

正式 Item ID：`iineonbhdnmadlkkmdcofakekmjpnkmn`。公钥保存于 [chrome-extension-public-key.pem](chrome-extension-public-key.pem)，已通过 `openssl pkey -pubin -noout` 校验。

本地测试副本位于 `/Users/sigma/Documents/github/chrome-tab-router/build/ChromeExtension-store-id/`，仅其 `manifest.json` 加入公钥 `key`。该目录在 Git 忽略范围内。公钥来自商店 Package 页；PEM 头尾与换行已移除，处理方式见 [Chrome 官方 manifest.key 说明](https://developer.chrome.com/docs/extensions/reference/manifest/key)。

已核对 9 个文件路径一致：8 个文件与 `ChromeExtension/` 源码逐字节相同，Manifest 除新增 `key` 外相同。原有 1.3.0 扩展 ZIP、构建的 App、已安装的 App 中的 9 个扩展文件也均与源码相同。本次无需重新构建 Mac 包或替换已上传的商店包。

验证步骤：

1. 在 Chrome 中暂停原有开发版扩展，避免两份扩展同时接管同一网页。
2. 由用户在 Chrome 扩展管理页加载上述测试副本，并核对 **Chrome 实际显示的扩展 ID** 与正式 Item ID 完全一致。加入公钥、Mac 菜单显示“已配置”、旧开发版显示“已连接”均不能替代这一步。
3. 打开正式 ID 扩展的弹窗或欢迎页，确认自动显示“已连接”；无需手动修复或复制 ID。通过“打开 Mac 菜单”核对共享设置。
4. 在普通网页验证：同路径的新参数链接保留原标签页并载入新 URL，不同路径链接新增一个标签页。截图只保留本工具界面和自有演示网页。

本地副本只用于发布前验证。后续源码变动后需重新生成副本，并重新比较文件；不将测试副本混作当前商店上传 ZIP。

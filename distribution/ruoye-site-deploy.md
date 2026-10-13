# 官网部署

官网地址：[Chrome Tab Router](https://ruoye.site/chrome-tab-router/)。静态文件来自本仓库 `docs/`，GitHub Pages 同时提供镜像。

Ruoye 服务器使用 Caddy。项目文件独立放在 `/var/www/chrome-tab-router/`；`current` 指向当前版本的静态页面目录。路由片段保存为 `/etc/caddy/chrome-tab-router.routes.caddy`，内容见 [ruoye-site.routes.caddy](ruoye-site.routes.caddy)。在现有 `ruoye.site` 网站块中导入该片段，路径外的页面继续使用原路由。

发布时从公开 GitHub 仓库取得已提交的版本，将 `docs/` 复制到 `releases/<commit>/`，再切换 `current`。Caddy 配置变更须先校验，再重载服务；更换静态文件版本无需重载。

示例页面使用外部 `demo/url-display.js`，兼容服务器现有的脚本内容安全策略。公开下载仍使用 GitHub Release；网站没有分析脚本、用户账号或后端表单。

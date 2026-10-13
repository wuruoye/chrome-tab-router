const connectLink = document.querySelector("#connect");
const extensionID = chrome.runtime.id;
if (/^[a-p]{32}$/.test(extensionID)) {
  connectLink.href = `chrometabrouter://connect?extensionID=${extensionID}`;
}

async function update() {
  try {
    const response = await chrome.runtime.sendMessage({ type: "settings" });
    if (!response?.ok) throw new Error();
    connectLink.hidden = true;
    const settings = response.settings;
    document.querySelector("#state").textContent = settings.enabled && settings.interceptBrowserLinks
      ? "已连接 · 网页链接接管已开启" : "已连接 · 网页链接接管已暂停";
    document.querySelector("#details").textContent =
      "所有设置保存在 Mac 应用中。" + (settings.refreshReusedTabs ? "复用标签页时会刷新。" : "相同 URL 复用时保留页面状态。") +
      (settings.useIncomingURL ? "匹配后会使用新链接更新网址。" : "匹配后保留原网址。");
  } catch {
    document.querySelector("#state").textContent = "尚未连接 Mac 应用";
    document.querySelector("#details").textContent = /^[a-p]{32}$/.test(extensionID)
      ? "点击连接，在 Chrome 提示时允许打开 Mac 应用。完成后重新打开此弹窗。"
      : "扩展 ID 无效，请重新加载扩展。";
    connectLink.hidden = !/^[a-p]{32}$/.test(extensionID);
  }
}
update();

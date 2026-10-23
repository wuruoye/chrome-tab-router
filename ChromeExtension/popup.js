const connectLink = document.querySelector("#connect");
const extensionID = chrome.runtime.id;
const validExtensionID = /^[a-p]{32}$/.test(extensionID);
const retryButton = document.querySelector("#retry");
const stateLabel = document.querySelector("#state");
const detailsLabel = document.querySelector("#details");
const installSteps = document.querySelector("#install-steps");
let checking = false;
if (validExtensionID) {
  connectLink.href = `chrometabrouter://connect?extensionID=${extensionID}`;
}

async function update() {
  if (checking) return;
  checking = true;
  retryButton.disabled = true;
  stateLabel.textContent = "正在检测 Mac 应用…";
  try {
    const response = await chrome.runtime.sendMessage({ type: "settings" });
    if (!response?.ok) {
      const error = new Error(response?.error || "本地连接暂时不可用。");
      error.connectionState = response?.connectionState;
      throw error;
    }
    connectLink.hidden = true;
    if (installSteps) installSteps.hidden = true;
    const settings = response.settings;
    stateLabel.textContent = settings.enabled && settings.interceptBrowserLinks
      ? "已连接 · 网页链接接管已开启" : "已连接 · 网页链接接管已暂停";
    detailsLabel.textContent =
      "匹配规则与复用后的操作在 Mac 菜单栏分别设置。" +
      (settings.useIncomingURL ? "匹配后使用完整新链接并加载。" : "匹配后保留原网址。") +
      (settings.refreshReusedTabs ? "网址保持不变时也刷新。" : "网址保持不变时保留页面状态。");
  } catch (error) {
    if (installSteps) installSteps.hidden = false;
    stateLabel.textContent = error.connectionState === "app-missing" ? "还未找到 Mac 应用"
      : error.connectionState === "repair-needed" ? "需要修复本地连接" : "尚未连接 Mac 应用";
    detailsLabel.textContent = validExtensionID
      ? "安装并首次打开 Mac 应用后，点击“重新检测”即可自动连接，无需重新安装扩展。已有 App 时可先重新打开；仍未连接，再点击“修复连接”并允许 Chrome 打开 App。"
      : "扩展 ID 无效，请重新加载扩展。";
    connectLink.hidden = !validExtensionID;
  } finally {
    checking = false;
    retryButton.disabled = false;
  }
}
retryButton.addEventListener("click", update);
window.addEventListener("focus", update);
update();

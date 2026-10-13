const host = "com.sigma.chrome_tab_router";

async function showConnectionStatus(connected) {
  // A badge failure must not retry a link that the Mac application has already accepted.
  try {
    await chrome.action.setBadgeText({ text: connected ? "" : "!" });
    await chrome.action.setBadgeBackgroundColor({ color: "#b8493f" });
    await chrome.action.setTitle({ title: connected ? "Chrome Tab Router" : "Chrome Tab Router · 请连接 Mac 应用" });
  } catch { /* The connection itself remains usable if Chrome cannot update the action. */ }
}

function connectionFailure(error) {
  const message = String(error?.message || error || "");
  let connectionState = "unavailable";
  if (/native messaging host.*not found/i.test(message)) connectionState = "app-missing";
  else if (/access.*forbidden|not allowed|permission/i.test(message)) connectionState = "repair-needed";
  return { ok: false, connectionState, error: "本地连接暂时不可用，请安装并首次打开 Mac 应用后重新检测。" };
}

async function nativeRequest(request) {
  try {
    const response = await chrome.runtime.sendNativeMessage(host, request);
    if (!response?.ok) throw new Error(response?.error || "本地连接失败。");
    await showConnectionStatus(true);
    return response;
  } catch (error) {
    await showConnectionStatus(false);
    throw error;
  }
}

async function probeConnection() {
  try { return await nativeRequest({ action: "settings" }); }
  catch (error) { return connectionFailure(error); }
}

chrome.runtime.onInstalled.addListener(details => {
  void probeConnection();
  if (details.reason === "install") {
    void chrome.tabs.create({ url: chrome.runtime.getURL("welcome.html") }).catch(() => {});
  }
});

chrome.runtime.onStartup.addListener(() => { void probeConnection(); });

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (sender.id !== chrome.runtime.id) return false;
  (async () => {
    if (message.type === "settings") {
      return await probeConnection();
    }
    if (message.type === "open-settings") {
      return await nativeRequest({ action: "openSettings" });
    }
    if (message.type !== "route" || !sender.tab || typeof message.url !== "string" || message.url.length > 16384) {
      return { ok: false, error: "请求格式不正确。" };
    }
    const source = new URL(sender.url);
    if (!["http:", "https:"].includes(source.protocol)) return { ok: false };
    const url = new URL(message.url);
    if (!["http:", "https:"].includes(url.protocol)) return { ok: false };
    try {
      const response = await nativeRequest({ action: "route", url: url.href });
      return response;
    } catch {
      // Keep the requested link usable if the native application is unavailable.
      await chrome.tabs.create({ url: url.href, active: message.active !== false,
                                windowId: sender.tab.windowId, openerTabId: sender.tab.id });
      return { ok: true, fallback: true };
    }
  })().then(sendResponse).catch(error => sendResponse(connectionFailure(error)));
  return true;
});

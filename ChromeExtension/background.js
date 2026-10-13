const host = "com.sigma.chrome_tab_router";

async function nativeRequest(request) {
  const response = await chrome.runtime.sendNativeMessage(host, request);
  if (!response?.ok) throw new Error(response?.error || "本地连接失败。");
  return response;
}

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (sender.id !== chrome.runtime.id) return false;
  (async () => {
    if (message.type === "settings") {
      return await nativeRequest({ action: "settings" });
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
      await chrome.action.setBadgeText({ text: "" });
      return response;
    } catch {
      // Keep the requested link usable if the native application is unavailable.
      await chrome.tabs.create({ url: url.href, active: message.active !== false,
                                windowId: sender.tab.windowId, openerTabId: sender.tab.id });
      await chrome.action.setBadgeText({ text: "!" });
      return { ok: true, fallback: true };
    }
  })().then(sendResponse).catch(() => sendResponse({ ok: false, error: "请先在 Mac 应用中连接扩展。" }));
  return true;
});

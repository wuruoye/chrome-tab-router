(() => {
  let settings = null;
  let loading = false;

  async function refreshSettings() {
    if (loading) return;
    loading = true;
    try {
      const response = await chrome.runtime.sendMessage({ type: "settings" });
      settings = response?.ok ? response.settings : null;
    } catch { settings = null; }
    finally { loading = false; }
  }

  function shouldExclude(url) {
    return (settings.excludedDomains || []).some(domain =>
      url.hostname === domain || url.hostname.endsWith("." + domain));
  }

  function handleLink(event) {
    if (!settings?.enabled || !settings.interceptBrowserLinks || !event.isTrusted ||
        event.defaultPrevented || event.altKey || event.shiftKey || event.ctrlKey) return;
    const middle = event.type === "auxclick" && event.button === 1;
    if (!middle && (event.type !== "click" || event.button !== 0)) return;
    const anchor = event.composedPath().find(node =>
      node instanceof HTMLAnchorElement || node instanceof HTMLAreaElement);
    if (!anchor || anchor.hasAttribute("download")) return;
    const target = anchor.getAttribute("target") || document.querySelector("base[target]")?.getAttribute("target") || "";
    if (!middle && !event.metaKey && target.toLowerCase() !== "_blank") return;
    let url;
    try { url = new URL(anchor.href, document.baseURI); } catch { return; }
    if (!["http:", "https:"].includes(url.protocol) || shouldExclude(url)) return;
    event.preventDefault();
    event.stopImmediatePropagation();
    const openFallback = () => window.open(url.href, "_blank", "noopener");
    try {
      chrome.runtime.sendMessage({ type: "route", url: url.href, active: !middle && !event.metaKey })
        .then(response => { if (!response?.ok) throw new Error("链接尚未处理。"); })
        .catch(openFallback);
    } catch {
      // A reloaded extension can invalidate this page's runtime before a Promise is returned.
      openFallback();
    }
  }

  document.addEventListener("click", handleLink, true);
  document.addEventListener("auxclick", handleLink, true);
  document.addEventListener("pointerdown", refreshSettings, true);
  window.addEventListener("focus", refreshSettings);
  document.addEventListener("visibilitychange", () => {
    if (!document.hidden) refreshSettings();
  });
  refreshSettings();
})();

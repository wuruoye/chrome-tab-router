// Addresses belong to the current main-frame navigation, never to a tab's browsing history.
class TabNavigationRecords {
  constructor(sync) {
    this.sync = sync;
    this.tabs = {};
    this.queue = chrome.storage.session.get("tabNavigationRecords").then(saved => {
      this.tabs = saved.tabNavigationRecords || {};
    }).catch(() => {});
    this.syncQueue = Promise.resolve();
    this.timer = null;

    const navigation = callback => details => {
      if (details.frameId !== 0 || details.tabId < 0 ||
          (details.documentLifecycle && details.documentLifecycle !== "active")) return;
      this.change(() => callback.call(this, details));
    };
    chrome.webNavigation.onBeforeNavigate.addListener(navigation(this.beforeNavigate));
    chrome.webNavigation.onCommitted.addListener(navigation(this.committed));
    chrome.webNavigation.onHistoryStateUpdated.addListener(navigation(this.historyUpdated));
    chrome.webNavigation.onReferenceFragmentUpdated.addListener(navigation(this.fragmentUpdated));
    chrome.webNavigation.onErrorOccurred.addListener(navigation(this.navigationFailed));
    const requests = { urls: ["http://*/*", "https://*/*"], types: ["main_frame"] };
    chrome.webRequest.onBeforeRequest.addListener(details => {
      if (details.tabId >= 0) this.change(() => this.beforeRequest(details));
    }, requests);
    chrome.webRequest.onBeforeRedirect.addListener(details => {
      if (details.tabId >= 0) this.change(() => this.redirected(details));
    }, requests);
    chrome.tabs.onRemoved.addListener(tabId => this.change(() => { delete this.tabs[tabId]; }));
    chrome.tabs.onReplaced.addListener((added, removed) => this.change(() => {
      delete this.tabs[removed];
      delete this.tabs[added];
    }));
    // These events also refresh window ownership after a tab is moved between windows.
    chrome.tabs.onAttached.addListener(() => this.change(() => {}));
    this.change(() => {});
  }

  httpURL(value) {
    if (typeof value !== "string" || value.length > 16384) return null;
    try {
      const url = new URL(value);
      return ["http:", "https:"].includes(url.protocol) ? url.href : null;
    } catch { return null; }
  }

  addresses(values) {
    return [...new Set(values.map(value => this.httpURL(value)).filter(Boolean))].slice(-32);
  }

  change(callback) {
    this.queue = this.queue.then(async () => {
      callback();
      await chrome.storage.session.set({ tabNavigationRecords: this.tabs });
      clearTimeout(this.timer);
      this.timer = setTimeout(() => { void this.flush().catch(() => {}); }, 150);
    }).catch(() => {});
  }

  beforeNavigate(details) {
    const previous = this.tabs[details.tabId] || {};
    const url = this.httpURL(details.url);
    const continuing = previous.request?.urls.includes(url);
    this.tabs[details.tabId] = {
      ...previous,
      pending: {
        url,
        previousURL: previous.pending?.previousURL || previous.url,
        previousAliases: previous.pending?.previousAliases || previous.aliases || [],
        reload: continuing && previous.pending ? previous.pending.reload : url === previous.url
      }
    };
  }

  beforeRequest(details) {
    const record = this.tabs[details.tabId] ||= {};
    if (record.request?.id !== details.requestId) {
      record.request = { id: details.requestId, urls: [], method: details.method };
    }
    record.request.urls = this.addresses([...record.request.urls, details.url]);
  }

  redirected(details) {
    const record = this.tabs[details.tabId] ||= {};
    if (record.request?.id !== details.requestId) {
      record.request = { id: details.requestId, urls: [], method: details.method };
    }
    record.request.urls = this.addresses([...record.request.urls, details.url, details.redirectUrl]);
  }

  committed(details) {
    const record = this.tabs[details.tabId] || {};
    const url = this.httpURL(details.url);
    if (!url) { delete this.tabs[details.tabId]; return; }
    const qualifiers = details.transitionQualifiers || [];
    const redirected = qualifiers.includes("server_redirect") || qualifiers.includes("client_redirect");
    const request = record.request?.urls.includes(url) && record.request.method === "GET" ? record.request.urls : [];
    let aliases = request.length ? request : [url];
    if (redirected && record.pending?.url) aliases = [...aliases, record.pending.url];
    if (qualifiers.includes("client_redirect") ||
        (record.pending?.reload && details.transitionType === "reload")) {
      aliases = [...(record.pending?.previousAliases || []), ...aliases];
    }
    this.tabs[details.tabId] = {
      url, aliases: this.addresses([...aliases, url]), documentId: details.documentId
    };
  }

  historyUpdated(details) {
    const url = this.httpURL(details.url);
    if (!url) { delete this.tabs[details.tabId]; return; }
    const record = this.tabs[details.tabId];
    if (record?.url === url && record.documentId === details.documentId) return;
    // A normal pushState/replaceState navigation is a different current page.
    this.tabs[details.tabId] = { url, aliases: [url], documentId: details.documentId };
  }

  fragmentUpdated(details) {
    const record = this.tabs[details.tabId];
    const url = this.httpURL(details.url);
    if (!record || !url || record.documentId !== details.documentId) return;
    const fragment = new URL(url).hash;
    record.aliases = this.addresses(record.aliases.map(value => {
      const address = new URL(value);
      address.hash = fragment;
      return address.href;
    }).concat(url));
    record.url = url;
  }

  navigationFailed(details) {
    const record = this.tabs[details.tabId];
    if (!record || record.pending?.url !== this.httpURL(details.url)) return;
    // A cancelled load may leave the preceding page visible; validate its URL in flush().
    record.url = record.pending.previousURL;
    record.aliases = record.pending.previousAliases;
    delete record.pending;
    delete record.request;
  }

  async flush() {
    clearTimeout(this.timer);
    const operation = this.queue.then(async () => {
      const open = await chrome.tabs.query({});
      const live = new Set(open.map(tab => String(tab.id)));
      for (const id of Object.keys(this.tabs)) if (!live.has(id)) delete this.tabs[id];
      const entries = [];
      let bytes = 0;
      for (const tab of open) {
        const record = this.tabs[tab.id];
        if (!record || record.pending || tab.incognito || !record.url ||
            record.url !== this.httpURL(tab.url) || record.aliases?.length < 2) continue;
        const entry = { tabID: tab.id, windowID: tab.windowId, url: record.url, aliases: record.aliases };
        const size = new TextEncoder().encode(JSON.stringify(entry)).length;
        if (bytes + size > 900000 || entries.length >= 512) continue;
        entries.push(entry);
        bytes += size;
      }
      await chrome.storage.session.set({ tabNavigationRecords: this.tabs });
      return entries;
    });
    this.queue = operation.then(() => {}).catch(() => {});
    const snapshot = await operation;
    this.syncQueue = this.syncQueue.catch(() => {}).then(() => this.sync(snapshot));
    return await this.syncQueue;
  }
}

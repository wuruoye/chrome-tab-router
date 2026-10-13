function displayCurrentAddress() {
  document.getElementById("current-url").textContent = window.location.href;
  document.getElementById("current-path").textContent = window.location.pathname;
  document.getElementById("current-query").textContent = window.location.search || "无查询参数";
  document.getElementById("current-fragment").textContent = window.location.hash || "无页面锚点";
}
displayCurrentAddress();
window.addEventListener("hashchange", displayCurrentAddress);

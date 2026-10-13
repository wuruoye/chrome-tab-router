on tabSnapshot()
    with timeout of 20 seconds
        tell application id "com.google.Chrome"
            if not running then launch
            set snapshot to {}
            set firstWindow to true
            repeat with browserWindow in every window
                set windowIdentifier to id of browserWindow
                set selectedTab to active tab of browserWindow
                set selectedIdentifier to id of selectedTab
                set end of snapshot to {windowIdentifier, selectedIdentifier, URL of selectedTab, firstWindow}
                repeat with candidateTab in every tab of browserWindow
                    if id of candidateTab is not selectedIdentifier then
                        set end of snapshot to {windowIdentifier, id of candidateTab, URL of candidateTab, firstWindow}
                    end if
                end repeat
                set firstWindow to false
            end repeat
            return snapshot
        end tell
    end timeout
end tabSnapshot

on focusTab(windowIdentifier, tabIdentifier, targetURL, shouldUpdateURL, shouldRefresh)
    with timeout of 20 seconds
        tell application id "com.google.Chrome"
            set browserWindow to first window whose id is windowIdentifier
            set windowTabs to every tab of browserWindow
            repeat with tabNumber from 1 to count of windowTabs
                set candidateTab to item tabNumber of windowTabs
                if id of candidateTab is tabIdentifier then
                    set active tab index of browserWindow to tabNumber
                    set minimized of browserWindow to false
                    set index of browserWindow to 1
                    activate
                    if shouldUpdateURL then set URL of candidateTab to targetURL
                    if shouldRefresh then reload candidateTab
                    return "reused"
                end if
            end repeat
            error "标签页已关闭，请重试。"
        end tell
    end timeout
end focusTab

on openNewTab(targetURL)
    with timeout of 20 seconds
        tell application id "com.google.Chrome"
            if not running then launch
            if (count of windows) is 0 then
                make new window
                set URL of active tab of front window to targetURL
            else
                tell front window to make new tab with properties {URL:targetURL}
                set active tab index of front window to count of tabs of front window
                set minimized of front window to false
            end if
            activate
            return "opened"
        end tell
    end timeout
end openNewTab

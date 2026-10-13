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
                set end of snapshot to {windowIdentifier, selectedIdentifier, URL of selectedTab, firstWindow, loading of selectedTab, mode of browserWindow}
                repeat with candidateTab in every tab of browserWindow
                    if id of candidateTab is not selectedIdentifier then
                        set end of snapshot to {windowIdentifier, id of candidateTab, URL of candidateTab, firstWindow, loading of candidateTab, mode of browserWindow}
                    end if
                end repeat
                set firstWindow to false
            end repeat
            return snapshot
        end tell
    end timeout
end tabSnapshot

on trackedTabSnapshot(tabIdentifiers)
    with timeout of 3 seconds
        tell application id "com.google.Chrome"
            if not running then return {}
            set snapshot to {}
            repeat with browserWindow in every window
                repeat with requestedIdentifier in tabIdentifiers
                    set matchingTabs to every tab of browserWindow whose id is (contents of requestedIdentifier)
                    repeat with candidateTab in matchingTabs
                        set end of snapshot to {id of browserWindow, id of candidateTab, URL of candidateTab, false, loading of candidateTab, mode of browserWindow}
                    end repeat
                end repeat
            end repeat
            return snapshot
        end tell
    end timeout
end trackedTabSnapshot

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
                    return {windowIdentifier, id of candidateTab, URL of candidateTab, true, loading of candidateTab, mode of browserWindow}
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
                set createdWindow to front window
                set createdTab to active tab of createdWindow
                set URL of createdTab to targetURL
            else
                set createdWindow to front window
                set createdTab to make new tab at end of tabs of createdWindow with properties {URL:targetURL}
            end if
            set createdIdentifier to id of createdTab
            repeat with tabNumber from 1 to count of tabs of createdWindow
                if id of tab tabNumber of createdWindow is createdIdentifier then
                    set active tab index of createdWindow to tabNumber
                    exit repeat
                end if
            end repeat
            set minimized of createdWindow to false
            activate
            return {id of createdWindow, createdIdentifier, URL of createdTab, true, loading of createdTab, mode of createdWindow}
        end tell
    end timeout
end openNewTab

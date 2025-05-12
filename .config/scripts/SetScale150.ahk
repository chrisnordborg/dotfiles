#Requires AutoHotkey v2.0
SendMode("Input")

; Read current scaling from registry (LogPixels)
currentDPI := RegRead("HKEY_CURRENT_USER\Control Panel\Desktop", "LogPixels", 96)

; Open Display Settings
Run("ms-settings:display")
Sleep(1000)

; Tab to the scaling dropdown (adjust this if needed)
Send("{Tab 4}")
;Sleep(300)

; Open the dropdown
Send("{Enter}")
;Sleep(200)

; Directly select the target scaling value based on current DPI
Send("{Up 4}")            ; Go to 100% in the dropdown
;Sleep(200)
Send("{Down 2}")            ; Go to 150% in the dropdown
;Sleep(200)

; Select the new scaling value
Send("{Enter}")
;Sleep(500)

; Optional: Close Settings window
Send("!{F4}")

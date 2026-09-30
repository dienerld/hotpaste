#Requires AutoHotkey v2.0
#SingleInstance Force

;@Ahk2Exe-SetName HotPaste
;@Ahk2Exe-SetDescription HotPaste - textos prontos nas teclas F1 a F8
;@Ahk2Exe-SetVersion 1.0.0

#Include config.ahk
#Include hotkeys.ahk
#Include tray.ahk
#Include gui.ahk

if !A_IsCompiled
    TraySetIcon(A_ScriptDir "\..\assets\icon.ico")

HasArg(name) {
    for arg in A_Args {
        if arg = name
            return true
    }
    return false
}

cfg := Config(A_ScriptDir "\HotPaste.ini")
cfg.Load()

; Primeira execução (sem .ini): liga "Iniciar com o Windows" e grava o .ini para
; que a decisão não se repita (desmarcar depois é respeitado). Só no .exe.
if cfg.firstRun {
    if A_IsCompiled
        Startup.Enable(A_ScriptFullPath)
    cfg.Save()
}

win := MainWindow(cfg, () => tray.Refresh())
tray := TrayMenu(() => win.Show(), () => win.RefreshStartup())
hotkeys := HotkeyManager(cfg, PasteText)
hotkeys.Register()

if !HasArg("--tray")
    win.Show()

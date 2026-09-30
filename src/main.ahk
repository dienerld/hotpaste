#Requires AutoHotkey v2.0
#SingleInstance Force

;@Ahk2Exe-SetName HotPaste
;@Ahk2Exe-SetDescription HotPaste - textos prontos nas teclas F1 a F8
;@Ahk2Exe-SetVersion 1.1.0

#Include version.ahk
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
; Se não der para gravar o .ini, não liga o autostart (senão religaria a cada abertura).
if cfg.firstRun {
    if cfg.Save() {
        if A_IsCompiled
            Startup.Enable(A_ScriptFullPath)
    } else {
        WarnSaveFailed()
    }
}

; Se o .exe foi movido, atualiza o caminho do autostart (sem religar se o usuário desativou).
if A_IsCompiled
    Startup.Repair(A_ScriptFullPath)

ShowWindow() {
    win.Show()
    tray.Refresh()   ; a marca do menu pode ter ficado velha (Gerenciador de Tarefas)
}

win := MainWindow(cfg, () => tray.Refresh())
tray := TrayMenu(ShowWindow, () => win.RefreshStartup())
; F1–F8 não colam dentro da própria janela do HotPaste (senão o texto vai parar no campo).
hotkeys := HotkeyManager(cfg, PasteText, () => WinActive("ahk_id " win.gui.Hwnd))
hotkeys.Register()

if !HasArg("--tray")
    ShowWindow()

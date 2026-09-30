#Requires AutoHotkey v2.0
#SingleInstance Force

#Include lib.ahk
#Include ..\src\config.ahk
#Include ..\src\hotkeys.ahk
#Include test_config.ahk
#Include test_hotkeys.ahk

; Erro não tratado não pode abrir diálogo (travaria o CI): registra e encerra.
OnError(FatalError)
FatalError(e, mode) {
    T.failed += 1
    T.log .= "ERRO NAO TRATADO: " e.Message " (" e.What ", linha " e.Line ")`n"
    T.Finish()
}

RunConfigTests()
RunHotkeyTests()
T.Finish()

#Requires AutoHotkey v2.0

; "Iniciar com o Windows" = valor na chave Run do usuário (não exige admin).
class Startup {
    static KEY := "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
    static APPROVED_KEY := "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
    static NAME := "HotPaste"

    static Command(exePath) => '"' exePath '" --tray'

    ; Ligado = existe o valor em Run e o Windows não o marcou como desativado
    ; (Gerenciador de Tarefas > Inicializar grava um byte ímpar em StartupApproved).
    static IsEnabled(key := Startup.KEY, name := Startup.NAME, approvedKey := Startup.APPROVED_KEY) {
        try {
            if RegRead(key, name) = ""
                return false
        } catch {
            return false
        }
        try {
            flags := RegRead(approvedKey, name)   ; REG_BINARY volta como texto hexadecimal
            if StrLen(flags) >= 2 && Mod(Integer("0x" SubStr(flags, 1, 2)), 2) = 1
                return false
        }
        return true
    }

    static Enable(exePath, key := Startup.KEY, name := Startup.NAME, approvedKey := Startup.APPROVED_KEY) {
        RegWrite(Startup.Command(exePath), "REG_SZ", key, name)
        try RegDelete(approvedKey, name)
    }

    static Disable(key := Startup.KEY, name := Startup.NAME) {
        try RegDelete(key, name)
    }

    ; Corrige o caminho gravado em Run quando o .exe foi movido. Só reescreve o
    ; valor de Run: não mexe em StartupApproved (respeita o Gerenciador de Tarefas).
    static Repair(exePath, key := Startup.KEY, name := Startup.NAME) {
        try {
            current := RegRead(key, name)
        } catch {
            return false   ; ausente: o usuário não quer iniciar com o Windows
        }
        if current !== Startup.Command(exePath) {
            RegWrite(Startup.Command(exePath), "REG_SZ", key, name)
            return true
        }
        return false
    }

    static SetEnabled(enabled, exePath, key := Startup.KEY, name := Startup.NAME, approvedKey := Startup.APPROVED_KEY) {
        if enabled
            Startup.Enable(exePath, key, name, approvedKey)
        else
            Startup.Disable(key, name)
    }

    static Toggle(exePath, key := Startup.KEY, name := Startup.NAME, approvedKey := Startup.APPROVED_KEY) {
        if Startup.IsEnabled(key, name, approvedKey)
            Startup.Disable(key, name)
        else
            Startup.Enable(exePath, key, name, approvedKey)
    }
}

class TrayMenu {
    static STARTUP_ITEM := "Iniciar com o Windows"

    ; showWindow / onStartupChanged: chamáveis sem argumentos.
    __New(showWindow, onStartupChanged) {
        this.showWindow := showWindow
        this.onStartupChanged := onStartupChanged
        m := A_TrayMenu
        m.Delete()
        m.Add("Abrir", ObjBindMethod(this, "OnOpen"))
        m.Add(TrayMenu.STARTUP_ITEM, ObjBindMethod(this, "OnToggleStartup"))
        m.Add()
        m.Add("Sair", (*) => ExitApp())
        m.Default := "Abrir"
        m.ClickCount := 1
        A_IconTip := "HotPaste v" APP_VERSION
        this.Refresh()
    }

    OnOpen(*) {
        this.showWindow.Call()
    }

    OnToggleStartup(*) {
        Startup.Toggle(A_ScriptFullPath)
        this.Refresh()
        this.onStartupChanged.Call()
    }

    Refresh() {
        if Startup.IsEnabled()
            A_TrayMenu.Check(TrayMenu.STARTUP_ITEM)
        else
            A_TrayMenu.Uncheck(TrayMenu.STARTUP_ITEM)
    }
}

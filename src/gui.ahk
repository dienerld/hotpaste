#Requires AutoHotkey v2.0

; Janela única: uma linha por tecla (F1–F8) com campo multilinha e botão Limpar,
; mais a caixa "Iniciar com o Windows". Salva a cada edição; fechar (X) só
; esconde a janela.
class MainWindow {
    ; onStartupChanged: chamável sem argumentos, avisado quando a caixa muda.
    __New(cfg, onStartupChanged) {
        this.cfg := cfg
        this.onStartupChanged := onStartupChanged
        this.edits := Map()

        g := Gui(, "HotPaste")
        g.SetFont("s10", "Segoe UI")
        g.MarginX := 16
        g.MarginY := 14
        g.AddText("w580", "Escreva o texto de cada tecla. Ao apertar F1 a F8 em qualquer programa, o texto é colado ali. Teclas sem texto funcionam normalmente.")

        y := 72
        loop Config.SLOTS {
            n := A_Index
            g.AddText(Format("xm y{} w32 h24", y + 4), "F" n)
            edit := g.AddEdit(Format("x+8 y{} w440 r3 +VScroll", y), Config.ToWindows(cfg.Get(n)))
            btn := g.AddButton(Format("x+8 y{} w80 h28", y), "Limpar")
            edit.OnEvent("Change", ObjBindMethod(this, "OnEdit", n))
            btn.OnEvent("Click", ObjBindMethod(this, "OnClear", n))
            this.edits[n] := edit
            y += 76
        }

        this.startupBox := g.AddCheckbox(Format("xm y{} w400", y + 4), "Iniciar com o Windows")
        this.startupBox.OnEvent("Click", ObjBindMethod(this, "OnStartupClick"))
        this.gui := g
        this.RefreshStartup()
    }

    OnEdit(n, ctrl, *) {
        this.cfg.Set(n, ctrl.Value)
    }

    OnClear(n, *) {
        this.edits[n].Value := ""
        this.cfg.Set(n, "")
    }

    OnStartupClick(*) {
        Startup.Toggle(A_ScriptFullPath)
        this.RefreshStartup()
        this.onStartupChanged.Call()
    }

    ; Relê o estado real (o usuário pode ter mudado no Gerenciador de Tarefas).
    RefreshStartup() {
        this.startupBox.Value := Startup.IsEnabled() ? 1 : 0
    }

    Show() {
        this.RefreshStartup()
        this.gui.Show()
        WinActivate("ahk_id " this.gui.Hwnd)
    }
}

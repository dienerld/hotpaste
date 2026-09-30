#Requires AutoHotkey v2.0

; Avisa (uma vez por sessão) que não foi possível gravar o .ini.
WarnSaveFailed() {
    static warned := false
    if warned
        return
    warned := true
    MsgBox("Não consegui salvar seus textos em " A_ScriptDir ". Mova o HotPaste para a pasta Documentos e abra de novo.", "HotPaste", "Icon!")
}

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
        g.MarginY := 10
        g.AddText("w580", "Texto de cada tecla, colado ao apertar F1 a F8. Tecla sem texto funciona normalmente.")

        y := 44
        loop Config.SLOTS {
            n := A_Index
            g.AddText(Format("xm y{} w32 h24", y + 4), "F" n)
            edit := g.AddEdit(Format("x+8 y{} w440 r2 +VScroll", y), Config.ToWindows(cfg.Get(n)))
            btn := g.AddButton(Format("x+8 y{} w80 h28", y), "Limpar")
            edit.OnEvent("Change", ObjBindMethod(this, "OnEdit", n))
            btn.OnEvent("Click", ObjBindMethod(this, "OnClear", n))
            this.edits[n] := edit
            y += 58
        }

        this.startupBox := g.AddCheckbox(Format("xm y{} w400", y + 4), "Iniciar com o Windows")
        this.startupBox.OnEvent("Click", ObjBindMethod(this, "OnStartupClick"))
        this.gui := g
        this.RefreshStartup()
    }

    OnEdit(n, ctrl, *) {
        if !this.cfg.Set(n, ctrl.Value)
            WarnSaveFailed()
    }

    OnClear(n, *) {
        this.edits[n].Value := ""
        if !this.cfg.Set(n, "")
            WarnSaveFailed()
    }

    OnStartupClick(*) {
        ; Value já reflete o clique: é o estado desejado (não inverte o estado do registro).
        Startup.SetEnabled(this.startupBox.Value = 1, A_ScriptFullPath)
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

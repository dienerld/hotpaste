#Requires AutoHotkey v2.0

; Avisa que não foi possível gravar o .ini. Por padrão só uma vez por sessão;
; com always := true (clique em Salvar) avisa sempre.
WarnSaveFailed(always := false) {
    static warned := false
    if warned && !always
        return
    warned := true
    MsgBox("Não consegui salvar seus textos em " A_ScriptDir ". Mova o HotPaste para a pasta Documentos e abra de novo.", "HotPaste", "Icon!")
}

; Janela única: uma linha por tecla (F1–F8) com campo multilinha e botão Limpar,
; caixa "Iniciar com o Windows", botão Salvar e rodapé com versão e link.
; Os textos só valem (e vão para o .ini) quando o usuário clica em Salvar;
; fechar (X) esconde a janela, perguntando antes se houver alterações pendentes.
class MainWindow {
    ; onStartupChanged: chamável sem argumentos, avisado quando a caixa muda.
    __New(cfg, onStartupChanged) {
        this.cfg := cfg
        this.onStartupChanged := onStartupChanged
        this.edits := Map()
        this.dirty := false
        this.saveFailed := false

        g := Gui(, "HotPaste v" APP_VERSION)
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
            edit.OnEvent("Change", ObjBindMethod(this, "OnEdit"))
            btn.OnEvent("Click", ObjBindMethod(this, "OnClear", n))
            this.edits[n] := edit
            y += 56
        }

        this.startupBox := g.AddCheckbox(Format("xm y{} w200 h24", y + 6), "Iniciar com o Windows")
        this.startupBox.OnEvent("Click", ObjBindMethod(this, "OnStartupClick"))
        this.status := g.AddText(Format("x224 y{} w270 h24 Right", y + 8), "")
        this.saveBtn := g.AddButton(Format("x504 y{} w80 h30 Disabled", y + 3), "Salvar")
        this.saveBtn.OnEvent("Click", ObjBindMethod(this, "Save"))
        ; Sem callback de Click, o AutoHotkey abre o href sozinho.
        g.AddLink(Format("xm y{} w568 h20", y + 44), "HotPaste v" APP_VERSION '  ·  Feito por <a href="https://github.com/dienerld">dienerld</a>')

        g.OnEvent("Close", ObjBindMethod(this, "OnClose"))
        this.gui := g
        OnExit(ObjBindMethod(this, "OnAppExit"))
        this.RefreshStartup()
    }

    ; Há campo diferente do texto salvo, ou uma gravação que falhou?
    HasChanges() {
        if this.saveFailed
            return true
        loop Config.SLOTS {
            if Config.NormalizeNewlines(this.edits[A_Index].Value) !== this.cfg.Get(A_Index)   ; !== diferencia maiúsculas
                return true
        }
        return false
    }

    ; Recalcula o estado a partir dos campos (não depende de a ordem dos eventos).
    UpdateDirty() {
        this.dirty := this.HasChanges()
        this.saveBtn.Enabled := this.dirty
        this.status.Text := this.dirty ? "Alterações não salvas" : ""
    }

    OnEdit(*) {
        this.UpdateDirty()
    }

    OnClear(n, *) {
        this.edits[n].Value := ""
        this.UpdateDirty()
    }

    ; Grava os 8 campos. Devolve true se gravou.
    Save(*) {
        texts := []
        loop Config.SLOTS
            texts.Push(this.edits[A_Index].Value)
        if this.cfg.SetAll(texts) {
            this.saveFailed := false
            this.UpdateDirty()
            this.status.Text := "Salvo!"
            return true
        }
        this.saveFailed := true
        this.UpdateDirty()
        WarnSaveFailed(true)
        return false
    }

    ; Volta os campos para o último texto salvo.
    Revert() {
        loop Config.SLOTS
            this.edits[A_Index].Value := Config.ToWindows(this.cfg.Get(A_Index))
        this.UpdateDirty()
    }

    ; Com alterações pendentes, pergunta o que fazer. Devolve true se pode seguir
    ; (salvou ou descartou) e false se o usuário cancelou ou não deu para salvar.
    ResolvePending() {
        if !this.dirty
            return true
        answer := MsgBox("Você tem alterações não salvas. Salvar antes de fechar?", "HotPaste", "YesNoCancel Icon? 262144")
        if answer = "Yes"
            return this.Save()
        if answer = "No" {
            this.Revert()
            return true
        }
        return false
    }

    ; X da janela: devolver true impede de esconder.
    OnClose(*) {
        if !this.ResolvePending()
            return true
    }

    ; "Sair" da bandeja: devolver 1 impede o app de encerrar. Fim de sessão do
    ; Windows nunca é bloqueado.
    OnAppExit(reason, code) {
        if reason = "Logoff" || reason = "Shutdown"
            return 0
        if this.ResolvePending()
            return 0
        this.Show()
        return 1
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

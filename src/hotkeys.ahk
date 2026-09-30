#Requires AutoHotkey v2.0

; Cola `text` no programa em foco via área de transferência e devolve o
; conteúdo anterior (texto, imagem, arquivos…) mesmo se algo falhar.
PasteText(text, delayMs := 150) {
    saved := ClipboardAll()
    try {
        A_Clipboard := ""
        A_Clipboard := Config.ToWindows(text)
        if !ClipWait(1)
            return false
        Send "^v"
        Sleep delayMs   ; dá tempo do programa de destino ler a área de transferência
        return true
    } finally {
        A_Clipboard := saved
    }
}

class HotkeyManager {
    ; paste: objeto chamável (text) => …  (em produção, PasteText)
    __New(cfg, paste) {
        this.cfg := cfg
        this.paste := paste
        this.criterion := ObjBindMethod(this, "IsActive")
        this.action := ObjBindMethod(this, "Fire")
    }

    static SlotFromKey(name) {
        if RegExMatch(name, "^F([1-8])$", &m)
            return Integer(m[1])
        return 0
    }

    ; Usado pelo HotIf: só intercepta a tecla se o slot tem texto.
    IsActive(name, *) {
        n := HotkeyManager.SlotFromKey(name)
        return n > 0 && this.cfg.IsFilled(n)
    }

    Fire(name, *) {
        n := HotkeyManager.SlotFromKey(name)
        if n = 0 || !this.cfg.IsFilled(n)
            return
        Critical "On"   ; evita duas colagens embaralhando a área de transferência
        try {
            this.paste.Call(this.cfg.Get(n))
        } catch {
            ; falha ao colar não deve aparecer como erro para o usuário
        } finally {
            Critical "Off"
        }
        KeyWait name    ; segurar a tecla não repete a colagem
    }

    Register() {
        HotIf this.criterion
        loop Config.SLOTS
            Hotkey "F" A_Index, this.action
        HotIf
    }
}

#Requires AutoHotkey v2.0

; Guarda os 8 textos (F1–F8) e os persiste em um .ini simples:
;   [HotPaste]
;   F1=texto\ncom quebra e \\ barra
class Config {
    static SLOTS := 8

    __New(path) {
        this.path := path
        this.slots := Map()
        this.firstRun := false
        this.Reset()
    }

    Reset() {
        loop Config.SLOTS
            this.slots[A_Index] := ""
    }

    Get(n) => this.slots[n]

    Set(n, text) {
        this.slots[n] := Config.NormalizeNewlines(text)
        return this.Save()
    }

    ; Vazio = nada além de espaço/tab/quebra de linha.
    IsFilled(n) => Trim(this.slots[n], " `t`r`n") != ""

    ; Lê o arquivo. Ausente, ilegível ou com lixo: mantém o que for válido e
    ; deixa o resto vazio, sem lançar erro.
    Load() {
        this.Reset()
        this.firstRun := !FileExist(this.path)
        try {
            raw := FileRead(this.path, "UTF-8")
        } catch {
            return
        }
        raw := LTrim(raw, Chr(0xFEFF))
        for line in StrSplit(raw, "`n", "`r") {
            pos := InStr(line, "=")
            if !pos
                continue
            if !RegExMatch(SubStr(line, 1, pos - 1), "^F([1-8])$", &m)
                continue
            this.slots[Integer(m[1])] := Config.Decode(SubStr(line, pos + 1))
        }
    }

    ; Devolve true se gravou; false (sem lançar erro) se a pasta não permitir gravar.
    Save() {
        text := "[HotPaste]`r`n"
        loop Config.SLOTS
            text .= "F" A_Index "=" Config.Encode(this.slots[A_Index]) "`r`n"
        tmp := this.path ".tmp"
        try {
            f := FileOpen(tmp, "w", "UTF-8-RAW")
            f.Write(text)
            f.Close()
            FileMove(tmp, this.path, 1)   ; troca atômica: nunca deixa o .ini pela metade
            return true
        } catch {
            try FileDelete(tmp)
            return false
        }
    }

    static NormalizeNewlines(s) => StrReplace(StrReplace(s, "`r`n", "`n"), "`r", "`n")

    ; Para controles Edit do Windows e para colar em programas.
    static ToWindows(s) => StrReplace(s, "`n", "`r`n")

    static Encode(s) {
        s := Config.NormalizeNewlines(s)
        s := StrReplace(s, "\", "\\")
        return StrReplace(s, "`n", "\n")
    }

    static Decode(s) {
        out := ""
        i := 1
        len := StrLen(s)
        while i <= len {
            ch := SubStr(s, i, 1)
            nxt := SubStr(s, i + 1, 1)
            if ch == "\" && nxt == "n" {
                out .= "`n"
                i += 2
            } else if ch == "\" && nxt == "\" {
                out .= "\"
                i += 2
            } else {
                out .= ch
                i += 1
            }
        }
        return out
    }
}

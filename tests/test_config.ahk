#Requires AutoHotkey v2.0

TempIni() {
    return A_Temp "\hotpaste-test-" A_TickCount "-" Random(1000, 9999) ".ini"
}

Cleanup(path) {
    try FileDelete(path)
}

; Grava com Set() e relê com um Config novo, como se o app tivesse reiniciado.
RoundTrip(n, text) {
    path := TempIni()
    a := Config(path)
    a.Set(n, text)
    b := Config(path)
    b.Load()
    got := b.Get(n)
    Cleanup(path)
    return got
}

RunConfigTests() {
    T.Run("defaults vazios", () => (
        c := Config(TempIni()),
        T.Eq(c.Get(1), "", "slot 1 vazio"),
        T.Eq(c.Get(8), "", "slot 8 vazio")
    ))

    T.Run("roundtrip multilinha", () =>
        T.Eq(RoundTrip(1, "Olá`nmundo"), "Olá`nmundo", "multilinha"))

    T.Run("CRLF vira LF", () => (
        c := Config(TempIni()),
        c.Set(2, "a`r`nb`rc"),
        T.Eq(c.Get(2), "a`nb`nc", "normaliza quebras"),
        Cleanup(c.path)
    ))

    ; Review Focus 1: barra invertida literal
    T.Run("barra invertida literal", () => (
        T.Eq(RoundTrip(3, "C:\novo\nome"), "C:\novo\nome", "caminho windows"),
        T.Eq(RoundTrip(3, "fim\"), "fim\", "barra no fim"),
        T.Eq(RoundTrip(3, "\\n"), "\\n", "duas barras e n")
    ))

    ; Review Focus 2: '=', bordas com espaço, acento e emoji
    T.Run("igual, espacos e unicode", () => (
        T.Eq(RoundTrip(4, "  a=b  "), "  a=b  ", "igual e espacos"),
        T.Eq(RoundTrip(5, "ação 😀 ü"), "ação 😀 ü", "unicode")
    ))

    T.Run("arquivo tem os 8 slots", () => (
        p := TempIni(),
        c := Config(p),
        c.Set(1, "x"),
        raw := FileRead(p, "UTF-8"),
        T.True(InStr(raw, "F1=x") && InStr(raw, "F8="), "F1 e F8 no arquivo"),
        T.True(InStr(raw, "[HotPaste]"), "cabecalho"),
        Cleanup(p)
    ))

    ; Review Focus 3: arquivo ausente / corrompido / BOM
    T.Run("arquivo inexistente", () => (
        c := Config(TempIni()),
        c.Load(),
        T.Eq(c.Get(1), "", "continua vazio")
    ))

    T.Run("arquivo corrompido", () => (
        p := TempIni(),
        FileAppend("lixo`n=semchave`nF9=zzz`nF1`nF2=ok`n[x]`nF3=a=b`nF0=no`n", p, "UTF-8-RAW"),
        c := Config(p),
        c.Load(),
        T.Eq(c.Get(1), "", "F1 sem '=' ignorado"),
        T.Eq(c.Get(2), "ok", "F2 valido"),
        T.Eq(c.Get(3), "a=b", "so o primeiro '=' separa"),
        T.Eq(c.slots.Count, 8, "continua com 8 slots"),
        T.True(!c.slots.Has(0) && !c.slots.Has(9), "F0 e F9 ignorados"),
        Cleanup(p)
    ))

    T.Run("arquivo com BOM", () => (
        p := TempIni(),
        FileAppend(Chr(0xFEFF) "[HotPaste]`r`nF4=bom`r`n", p, "UTF-8-RAW"),
        c := Config(p),
        c.Load(),
        T.Eq(c.Get(4), "bom", "le F4 com BOM"),
        Cleanup(p)
    ))

    T.Run("firstRun", () => (
        p := TempIni(),
        a := Config(p),
        T.Eq(a.firstRun, false, "false antes do Load"),
        a.Load(),
        T.Eq(a.firstRun, true, "arquivo ausente = primeira execucao"),
        a.Save(),
        b := Config(p),
        b.Load(),
        T.Eq(b.firstRun, false, "depois de gravar nao e mais primeira execucao"),
        Cleanup(p)
    ))

    T.Run("IsFilled", () => (
        c := Config(TempIni()),
        c.Set(1, "   `n `t"),
        c.Set(2, " a "),
        T.Eq(c.IsFilled(1), false, "so espacos = vazio"),
        T.Eq(c.IsFilled(2), true, "com texto"),
        T.Eq(c.IsFilled(3), false, "nunca preenchido"),
        Cleanup(c.path)
    ))

    T.Run("Encode/Decode", () => (
        T.Eq(Config.Encode("a`nb\"), "a\nb\\", "encode"),
        T.Eq(Config.Decode("a\nb\\"), "a`nb\", "decode"),
        T.Eq(Config.Decode("\x"), "\x", "escape desconhecido fica"),
        T.Eq(Config.ToWindows("a`nb"), "a`r`nb", "ToWindows")
    ))

    ; Save devolve o resultado da gravação; Set repassa
    T.Run("Set devolve o resultado do Save", () => (
        c := Config(TempIni()),
        T.Eq(c.Set(1, "x"), true, "caminho gravavel"),
        Cleanup(c.path),
        d := Config(A_Temp "\hotpaste-no-such-dir-" A_TickCount ".ini"),
        T.Eq(d.Set(1, "x"), false, "pasta inexistente")
    ))

    ; Gravação atômica: escreve em .tmp e move
    T.Run("Save nao deixa .tmp", () => (
        p := TempIni(),
        c := Config(p),
        c.Set(1, "a`nb"),
        T.Eq(FileExist(p ".tmp"), "", "sem .tmp"),
        d := Config(p),
        d.Load(),
        T.Eq(d.Get(1), "a`nb", "conteudo ok"),
        Cleanup(p)
    ))

    T.Run("Save que falha nao deixa .tmp", () => (
        p := A_Temp "\hotpaste-no-such-dir-" A_TickCount ".ini",
        c := Config(p),
        T.Eq(c.Save(), false, "falha"),
        T.Eq(FileExist(p ".tmp"), "", "sem .tmp")
    ))
}

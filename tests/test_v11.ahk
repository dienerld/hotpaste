#Requires AutoHotkey v2.0

; Botão Salvar (Config.SetAll) e versão do app.
RunSaveAndVersionTests() {
    T.Run("SetAll grava os 8 de uma vez", () => (
        p := TempIni(),
        a := Config(p),
        texts := ["um", "dois`r`nlinhas", "", "  esp  ", "C:\novo\nome", "a=b", "ação 😀", "oito"],
        T.Eq(a.SetAll(texts), true, "grava"),
        b := Config(p),
        b.Load(),
        T.Eq(b.Get(1), "um", "slot 1"),
        T.Eq(b.Get(2), "dois`nlinhas", "slot 2 normaliza quebras"),
        T.Eq(b.Get(3), "", "slot 3 vazio"),
        T.Eq(b.Get(4), "  esp  ", "slot 4 espacos"),
        T.Eq(b.Get(5), "C:\novo\nome", "slot 5 barras"),
        T.Eq(b.Get(6), "a=b", "slot 6 igual"),
        T.Eq(b.Get(7), "ação 😀", "slot 7 unicode"),
        T.Eq(b.Get(8), "oito", "slot 8"),
        Cleanup(p)
    ))

    T.Run("SetAll sobrescreve textos antigos", () => (
        p := TempIni(),
        a := Config(p),
        a.Set(1, "antigo"),
        a.SetAll(["", "", "", "", "", "", "", ""]),
        b := Config(p),
        b.Load(),
        T.Eq(b.Get(1), "", "slot 1 esvaziado"),
        Cleanup(p)
    ))

    T.Run("SetAll devolve false se nao consegue gravar", () => (
        c := Config(A_Temp "\hotpaste-sem-pasta-" A_TickCount "\x.ini"),
        T.Eq(c.SetAll(["a", "", "", "", "", "", "", ""]), false, "devolve false"),
        T.Eq(c.Get(1), "a", "texto fica em memoria")
    ))

    T.Run("APP_VERSION tem formato x.y.z", () =>
        T.True(RegExMatch(APP_VERSION, "^\d+\.\d+\.\d+$"), "formato x.y.z"))

    T.Run("main.ahk usa a mesma versao", () => (
        src := FileRead(A_ScriptDir "\..\src\main.ahk", "UTF-8"),
        T.True(RegExMatch(src, "m);@Ahk2Exe-SetVersion\s+(\S+)", &m), "achou a diretiva SetVersion"),
        T.Eq(m[1], APP_VERSION, "SetVersion igual a APP_VERSION")
    ))
}

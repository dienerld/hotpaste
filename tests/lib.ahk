#Requires AutoHotkey v2.0

; Mini-framework de testes. Cada teste chama T.Eq/T.True; T.Finish() grava
; tests\results.txt e encerra com código 0 (tudo ok) ou 1 (alguma falha).
class T {
    static passed := 0
    static failed := 0
    static log := ""

    static Eq(actual, expected, name) {
        if actual == expected {
            T.passed += 1
        } else {
            T.failed += 1
            T.log .= "FALHA: " name "`n  esperado: [" expected "]`n  obtido:   [" actual "]`n"
        }
    }

    static True(cond, name) {
        T.Eq(cond ? 1 : 0, 1, name)
    }

    static Run(name, fn) {
        try {
            fn()
        } catch as e {
            T.failed += 1
            T.log .= "ERRO em " name ": " e.Message " (" e.What ")`n"
        }
    }

    static Finish() {
        summary := T.passed " ok, " T.failed " falhas`n" T.log
        f := FileOpen(A_ScriptDir "\results.txt", "w", "UTF-8-RAW")
        f.Write(summary)
        f.Close()
        ExitApp(T.failed > 0 ? 1 : 0)
    }
}

#Requires AutoHotkey v2.0

RunHotkeyTests() {
    T.Run("SlotFromKey", () => (
        T.Eq(HotkeyManager.SlotFromKey("F1"), 1, "F1"),
        T.Eq(HotkeyManager.SlotFromKey("F8"), 8, "F8"),
        T.Eq(HotkeyManager.SlotFromKey("F9"), 0, "F9 fora"),
        T.Eq(HotkeyManager.SlotFromKey("F10"), 0, "F10 fora"),
        T.Eq(HotkeyManager.SlotFromKey("F0"), 0, "F0 fora"),
        T.Eq(HotkeyManager.SlotFromKey("^F1"), 0, "com modificador"),
        T.Eq(HotkeyManager.SlotFromKey(""), 0, "vazio")
    ))

    T.Run("IsActive so com slot preenchido", () => (
        cfg := Config(TempIni()),
        cfg.Set(2, "oi"),
        mgr := HotkeyManager(cfg, (t) => 0),
        T.Eq(mgr.IsActive("F2"), true, "F2 preenchido"),
        T.Eq(mgr.IsActive("F1"), false, "F1 vazio deixa a tecla passar"),
        T.Eq(mgr.IsActive("F9"), false, "tecla invalida"),
        Cleanup(cfg.path)
    ))

    ; Review Focus 4: só espaços não pode roubar a tecla
    T.Run("IsActive ignora slot so com espacos", () => (
        cfg := Config(TempIni()),
        cfg.Set(5, "   `n  "),
        mgr := HotkeyManager(cfg, (t) => 0),
        T.Eq(mgr.IsActive("F5"), false, "F5 so com espacos passa"),
        Cleanup(cfg.path)
    ))

    T.Run("Fire cola o texto do slot", () => (
        cfg := Config(TempIni()),
        cfg.Set(3, "Olá`nmundo"),
        calls := [],
        mgr := HotkeyManager(cfg, (t) => calls.Push(t)),
        mgr.Fire("F3"),
        T.Eq(calls.Length, 1, "uma colagem"),
        T.Eq(calls[1], "Olá`nmundo", "texto exato"),
        Cleanup(cfg.path)
    ))

    T.Run("Fire nao cola slot vazio nem tecla invalida", () => (
        cfg := Config(TempIni()),
        calls := [],
        mgr := HotkeyManager(cfg, (t) => calls.Push(t)),
        mgr.Fire("F4"),
        mgr.Fire("F9"),
        T.Eq(calls.Length, 0, "nada colado"),
        Cleanup(cfg.path)
    ))

    ; Review Focus 5: falha na colagem não pode virar erro para o usuário
    T.Run("Fire engole erro da colagem", () => (
        cfg := Config(TempIni()),
        cfg.Set(6, "x"),
        mgr := HotkeyManager(cfg, (t) => (_ := 1 / 0)),
        mgr.Fire("F6"),
        T.True(true, "nao lancou"),
        Cleanup(cfg.path)
    ))
}

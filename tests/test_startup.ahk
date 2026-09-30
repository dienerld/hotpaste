#Requires AutoHotkey v2.0

RunStartupTests() {
    T.Run("Startup.Command", () =>
        T.Eq(Startup.Command("C:\Meus Apps\HotPaste.exe"),
            '"C:\Meus Apps\HotPaste.exe" --tray', "aspas e --tray"))

    T.Run("Startup registro ida e volta", () => (
        key := "HKCU\Software\HotPaste-Test\Run",
        appr := "HKCU\Software\HotPaste-Test\Approved",
        name := "HotPasteTest",
        Startup.Disable(key, name),
        T.Eq(Startup.IsEnabled(key, name, appr), false, "comeca desligado"),
        Startup.Enable("C:\x y\HotPaste.exe", key, name, appr),
        T.Eq(Startup.IsEnabled(key, name, appr), true, "ligado"),
        T.Eq(RegRead(key, name), '"C:\x y\HotPaste.exe" --tray', "valor gravado"),
        Startup.Disable(key, name),
        T.Eq(Startup.IsEnabled(key, name, appr), false, "desligado de novo"),
        Startup.Disable(key, name),    ; desligar de novo não pode dar erro
        T.True(true, "disable idempotente"),
        RegDeleteKey("HKCU\Software\HotPaste-Test")
    ))

    ; Gerenciador de Tarefas > Inicializar grava um byte ímpar em StartupApproved
    T.Run("Startup respeita StartupApproved", () => (
        key := "HKCU\Software\HotPaste-Test\Run",
        appr := "HKCU\Software\HotPaste-Test\Approved",
        name := "HotPasteTest",
        Startup.Enable("C:\x\HotPaste.exe", key, name, appr),
        RegWrite("030000000000000000000000", "REG_BINARY", appr, name),
        T.Eq(Startup.IsEnabled(key, name, appr), false, "byte 03 = desativado pelo usuario"),
        RegWrite("020000000000000000000000", "REG_BINARY", appr, name),
        T.Eq(Startup.IsEnabled(key, name, appr), true, "byte 02 = habilitado"),
        RegWrite("030000000000000000000000", "REG_BINARY", appr, name),
        Startup.Enable("C:\x\HotPaste.exe", key, name, appr),
        T.Eq(Startup.IsEnabled(key, name, appr), true, "Enable limpa o marcador"),
        RegDeleteKey("HKCU\Software\HotPaste-Test")
    ))

    T.Run("Startup.Toggle", () => (
        key := "HKCU\Software\HotPaste-Test\Run",
        appr := "HKCU\Software\HotPaste-Test\Approved",
        name := "HotPasteTest",
        Startup.Disable(key, name),
        Startup.Toggle("C:\x\HotPaste.exe", key, name, appr),
        T.Eq(Startup.IsEnabled(key, name, appr), true, "toggle liga"),
        Startup.Toggle("C:\x\HotPaste.exe", key, name, appr),
        T.Eq(Startup.IsEnabled(key, name, appr), false, "toggle desliga"),
        RegDeleteKey("HKCU\Software\HotPaste-Test")
    ))
}

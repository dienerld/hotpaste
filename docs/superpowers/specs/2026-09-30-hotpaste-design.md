# HotPaste — Design

## Objetivo

App Windows para público leigo que associa textos pré-definidos às teclas F1 a F8. Ao apertar a tecla, o texto é inserido no programa em foco, evitando Ctrl+C / Ctrl+V.

**Sucesso:** uma pessoa sem conhecimento técnico configura os 8 textos em menos de 1 minuto, sem usar PowerToys nem qualquer configuração avançada.

## Decisões tomadas

- Funciona em qualquer programa, enquanto o processo do app estiver rodando (ícone na bandeja).
- Nome: **HotPaste** (`HotPaste.exe`); a pasta do repositório continua `replace-f`.
- Ícone: `assets/icon.svg` (fonte), `assets/icon.ico` (16–256 px) e `assets/icon.png` (prévia) — prancheta laranja (degradê quente = "Hot", prancheta = "Paste") com um "F" branco. O `.ico` é usado no `.exe` (Ahk2Exe `/icon`) e no ícone da bandeja.
- Tecnologia: **AutoHotkey v2**, compilado em um único `.exe` (sem instalador, sem admin).
- Desenvolvimento no Linux; teste em uma máquina Windows; build do `.exe` via **GitHub Actions** (`windows-latest`).
- Slot vazio mantém a função original da tecla (ex.: F5 atualiza); slot preenchido vira texto e bloqueia a tecla original.

## Comportamento e interface

**Janela única, em português**, com 8 linhas (F1 a F8). Cada linha tem um campo de texto multilinha e um botão "Limpar". Não há botão "Salvar": cada edição é salva automaticamente.

**Bandeja do sistema**
- Fechar a janela (X) apenas minimiza para a bandeja; o app continua ativo.
- Menu do ícone: "Abrir", "Iniciar com o Windows" (caixa marcável), "Sair".
- **Iniciar com o Windows:** chave `HKCU\...\Run` (sem admin), gravando `"<exe>" --tray`. Vem **ligado por padrão na primeira execução** (quando `HotPaste.ini` não existe); desmarcar depois é respeitado. A caixa aparece na janela principal **e** no menu da bandeja, sempre sincronizadas, e respeita o Gerenciador de Tarefas (`StartupApproved\Run`): se o usuário desativar lá, a caixa aparece desmarcada.
- Iniciado pelo Windows (`--tray`): o app sobe direto na bandeja, sem janela. Aberto manualmente: a janela sempre aparece.

**Ao apertar F1–F8**
- Slot preenchido: insere o texto no programa em foco e bloqueia a tecla original.
- Slot vazio: a tecla passa normalmente.

**Inserção do texto:** colagem via área de transferência. Salva o conteúdo atual, coloca o preset, envia Ctrl+V e restaura o conteúdo anterior. Preserva acentos, emojis e quebras de linha. Limitação: programas que bloqueiam Ctrl+V (alguns campos de senha, terminais remotos) não recebem o texto.

**Armazenamento:** arquivo `.ini` na pasta do app.

## Fora do escopo

Outras teclas além de F1–F8, combinações com Ctrl/Alt, perfis de presets, variáveis (data, nome), atualização automática.

## Estrutura

```
replace-f/
├── assets/             # icon.svg, icon.ico, icon.png
├── src/
│   ├── main.ahk        # ponto de entrada: liga as partes
│   ├── config.ahk      # ler/gravar o .ini (8 slots)
│   ├── hotkeys.ahk     # registra F1–F8 e insere o texto
│   ├── gui.ahk         # janela com os 8 campos
│   └── tray.ahk        # ícone, menu e "iniciar com o Windows"
├── .github/workflows/build.yml
├── docs/superpowers/specs/
└── README.md
```

Cada arquivo tem uma responsabilidade. `hotkeys.ahk` conhece apenas o `config` (para ler o texto do slot) e nada de janela. `gui.ahk` apenas grava no `config`.

## Fluxo de dados

1. O app inicia e o `config` lê o `.ini`.
2. O `hotkeys` registra F1–F8 uma única vez, com a condição "dispara só se o slot tiver texto". A condição consulta o `config` a cada tecla apertada, então não é preciso re-registrar após edições.
3. Ao editar um campo, o `gui` grava no `config` (e no `.ini`); a próxima tecla já usa o texto novo.

## Tratamento de erros

- `.ini` ausente ou corrompido: recria com 8 slots vazios, sem mostrar erro ao usuário.
- Falha na colagem: a área de transferência original é restaurada mesmo assim.
- Instância única: abrir o app de novo traz a janela existente para a frente.

## Build

GitHub Actions em `windows-latest`, a cada push: instala o AutoHotkey v2, compila `src/main.ahk` com o Ahk2Exe e publica `HotPaste.exe` como artefato. Ao criar uma tag (ex.: `v1.0`), anexa o `.exe` a uma Release.

## Testes

- **Automatizados (Actions):** lógica pura — leitura/gravação do `config` e a regra "slot vazio não intercepta". Scripts AHK retornam código de saída.
- **Manuais (Windows, checklist no README):** F1 no Bloco de Notas, navegador e Word; texto com acento e várias linhas; slot vazio (F5 ainda atualiza); fechar para a bandeja; iniciar com o Windows; restauração da área de transferência. Teclas globais e colagem não são testáveis automaticamente com confiança.

## Riscos

- Falso positivo de antivírus em `.exe` de AutoHotkey. Mitigação: código aberto e orientação no README; assinatura de código fica para depois, se necessário.
- Programas executando como administrador não recebem teclas de um app comum. Mitigação: documentar no README.

# HotPaste

Cole textos prontos com uma tecla. Escolha um texto para cada tecla **F1 a F8**; depois, em qualquer programa (navegador, WhatsApp Web, Word…), é só apertar a tecla e o texto aparece onde o cursor estiver. Sem Ctrl+C / Ctrl+V.

## Como usar

1. Baixe o `HotPaste.exe` na página de [Releases](../../releases) e dê dois cliques. Não precisa instalar. Se baixou um `.zip`, **extraia o `.exe` e mova para a pasta definitiva (por exemplo, Documentos) antes de abrir pela primeira vez**: abrir de dentro do zip roda de uma pasta temporária, e o início automático e o `.ini` acabam lá. Se o Windows mostrar um aviso ao abrir, veja [Aviso do Windows](#aviso-do-windows-fornecedor-desconhecido).
2. Na janela, escreva o texto de cada tecla e clique em **Salvar**. As teclas só passam a usar os textos novos depois de salvar; ao fechar com alterações pendentes, o HotPaste pergunta se você quer salvar.
3. Feche a janela (X): o HotPaste continua funcionando na **bandeja** (perto do relógio). Clique no ícone para reabrir.
4. Aperte **F1 a F8** em qualquer programa para colar o texto.

- Tecla sem texto funciona normalmente (F5 continua atualizando a página).
- **Iniciar com o Windows** já vem marcado na primeira vez, para o HotPaste estar sempre pronto depois de reiniciar. Desmarque na janela ou no menu do ícone da bandeja (botão direito) se não quiser. Também dá para desativar em Gerenciador de Tarefas → Inicializar.
- Clique com o botão direito no ícone da bandeja para **Abrir** ou **Sair**.
- Os textos ficam no arquivo `HotPaste.ini`, ao lado do `.exe`. Copie os dois para levar para outro computador; o início automático **não** é ligado sozinho lá, marque a caixa na janela.
- Em muitos notebooks as teclas F1–F8 precisam da tecla **Fn** (ou do Fn Lock ligado).
- Apertar F1 a F8 **dentro da janela do HotPaste** não cola nada (assim você pode digitar e testar sem sujar os campos).
- A **versão** aparece no título da janela, no rodapé e ao passar o mouse no ícone da bandeja.
- Feito por [dienerld](https://github.com/dienerld).

## Aviso do Windows (Fornecedor desconhecido)

O `HotPaste.exe` ainda **não tem assinatura digital** (assinar exige um certificado emitido por uma autoridade, e isso demora). Por isso, ao abrir pela primeira vez, o Windows pode mostrar "O Windows protegeu seu computador" ou "Fornecedor desconhecido". Isso **não** significa que o arquivo tem vírus; significa só que o Windows ainda não conhece quem publicou.

Para abrir mesmo assim:

1. Na janela azul, clique em **Mais informações**.
2. Clique em **Executar assim mesmo**.

Se quiser conferir antes de abrir:

- O código-fonte completo está neste repositório, e o `.exe` é compilado pelo GitHub Actions a partir dele.
- Cada release traz o **SHA256** do arquivo. No PowerShell, na pasta do arquivo: `Get-FileHash HotPaste.exe` — o resultado deve ser igual ao da página da release (maiúsculas ou minúsculas não importam).
- Você pode enviar o `.exe` em [virustotal.com](https://www.virustotal.com) para ver o resultado de vários antivírus.

## Limitações

- Programas abertos **como administrador** não recebem as teclas de um app comum. Se F1–F8 não funcionar em um programa assim, abra o HotPaste como administrador também.
- **Não guarde senhas nem dados sensíveis.** Os textos ficam em texto puro no `HotPaste.ini` e passam pela área de transferência (e pelo histórico do Win+V).
- Alguns campos de senha e conexões remotas bloqueiam o colar (Ctrl+V) e não recebem o texto.
- Não coloque o HotPaste em pastas protegidas (como `Arquivos de Programas`), senão ele não consegue salvar o `.ini`. Use, por exemplo, a Área de Trabalho ou Documentos.
- Alguns antivírus podem avisar sobre apps feitos com AutoHotkey (falso positivo). O código é aberto e está neste repositório.

## Desenvolvimento

- Linguagem: [AutoHotkey v2](https://www.autohotkey.com/). Código em `src/`, testes em `tests/`.
- Testes automáticos (lógica pura): rodam no GitHub Actions a cada push. No Windows: `AutoHotkey64.exe tests\run.ahk` e leia `tests\results.txt`.
- O `.exe` é gerado pelo Actions (artefato `HotPaste` de cada execução). Para publicar uma versão: atualize `APP_VERSION` em `src/version.ahk` **e** `;@Ahk2Exe-SetVersion` em `src/main.ahk` (os testes conferem que são iguais), commit, e `git tag vX.Y.Z && git push origin vX.Y.Z`. O CI recusa a release se a tag não bater com `APP_VERSION`.
- Ícone: `assets/icon.svg` é a fonte; `icon.ico` e `icon.png` são gerados dela.

## Checklist manual (teclas globais e colagem não têm teste automático)

Rode no Windows, com o `.exe` do Actions, antes de cada versão:

- [ ] F1 preenchida cola no Bloco de Notas, no navegador (campo de texto) e no Word.
- [ ] Texto com acentos (`ação`, `ü`) e emoji cola idêntico.
- [ ] Texto com várias linhas cola com as quebras de linha.
- [ ] Texto com barra invertida (`C:\novo\nome`) cola idêntico.
- [ ] Apertar F1 dentro da janela do HotPaste não cola nada.
- [ ] A janela cabe inteira em 1366×768 e em 1080p com escala de 150%.
- [ ] Slot vazio: F5 atualiza a página; F2 renomeia arquivo no Explorer.
- [ ] Slot só com espaços: a tecla ainda funciona normalmente.
- [ ] Copie uma imagem, aperte F1, depois cole (Ctrl+V): a imagem continua na área de transferência.
- [ ] Copie um texto, aperte F1, depois Ctrl+V: cola o texto copiado (não o preset).
- [ ] Segurar F1 cola só uma vez.
- [ ] Editar um texto e apertar a tecla **sem salvar**: ainda cola o texto antigo. Depois de clicar em **Salvar**, cola o novo.
- [ ] O botão **Salvar** começa desabilitado, habilita ao editar (com "Alterações não salvas"), e mostra "Salvo!" depois de salvar.
- [ ] Trocar só maiúscula/minúscula de uma letra também habilita o **Salvar**.
- [ ] Fechar pelo X com alterações pendentes pergunta: **Sim** salva e fecha; **Não** descarta (ao reabrir, os campos voltam ao texto salvo); **Cancelar** mantém a janela aberta.
- [ ] **Sair** pela bandeja com alterações pendentes faz a mesma pergunta; **Cancelar** não fecha o app.
- [ ] "Limpar" esvazia o campo, habilita o **Salvar**, e só depois de salvar a tecla volta ao normal.
- [ ] A versão (1.1.0) aparece no título da janela, no rodapé e na dica do ícone da bandeja; o link **dienerld** abre o perfil no navegador.
- [ ] Fechar pelo X esconde a janela e o F1 continua colando; clique no ícone da bandeja reabre.
- [ ] Primeira execução do `.exe` (sem `HotPaste.ini`): "Iniciar com o Windows" aparece marcado na janela e no menu da bandeja; reiniciar o Windows: o app sobe sem janela, com o ícone na bandeja.
- [ ] Desmarcar na janela desmarca no menu da bandeja (e vice-versa); depois de apagar o app da lista, reabrir não religa sozinho (o `.ini` já existe).
- [ ] Desativar o HotPaste em Gerenciador de Tarefas → Inicializar: ao reabrir a janela, a caixa aparece desmarcada.
- [ ] Abrir o `.exe` de novo com ele já rodando não deixa dois ícones na bandeja.
- [ ] Apagar `HotPaste.ini` (ou encher de lixo) e abrir: o app abre com os 8 campos vazios, sem erro.
- [ ] Se algum programa cola o texto antigo, aumentar o atraso `delayMs` em `PasteText` (`src/hotkeys.ahk`).

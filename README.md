# HotPaste

Cole textos prontos com uma tecla. Escolha um texto para cada tecla **F1 a F8**; depois, em qualquer programa (navegador, WhatsApp Web, Word…), é só apertar a tecla e o texto aparece onde o cursor estiver. Sem Ctrl+C / Ctrl+V.

## Como usar

1. Baixe o `HotPaste.exe` na página de [Releases](../../releases) e dê dois cliques. Não precisa instalar.
2. Na janela, escreva o texto de cada tecla. Tudo é salvo sozinho.
3. Feche a janela (X): o HotPaste continua funcionando na **bandeja** (perto do relógio). Clique no ícone para reabrir.
4. Aperte **F1 a F8** em qualquer programa para colar o texto.

- Tecla sem texto funciona normalmente (F5 continua atualizando a página).
- **Iniciar com o Windows** já vem marcado na primeira vez, para o HotPaste estar sempre pronto depois de reiniciar. Desmarque na janela ou no menu do ícone da bandeja (botão direito) se não quiser. Também dá para desativar em Gerenciador de Tarefas → Inicializar.
- Clique com o botão direito no ícone da bandeja para **Abrir** ou **Sair**.
- Os textos ficam no arquivo `HotPaste.ini`, ao lado do `.exe`. Copie os dois para levar para outro computador.

## Limitações

- Programas abertos **como administrador** não recebem as teclas de um app comum. Se F1–F8 não funcionar em um programa assim, abra o HotPaste como administrador também.
- Alguns campos de senha e conexões remotas bloqueiam o colar (Ctrl+V) e não recebem o texto.
- Não coloque o HotPaste em pastas protegidas (como `Arquivos de Programas`), senão ele não consegue salvar o `.ini`. Use, por exemplo, a Área de Trabalho ou Documentos.
- Alguns antivírus podem avisar sobre apps feitos com AutoHotkey (falso positivo). O código é aberto e está neste repositório.

## Desenvolvimento

- Linguagem: [AutoHotkey v2](https://www.autohotkey.com/). Código em `src/`, testes em `tests/`.
- Testes automáticos (lógica pura): rodam no GitHub Actions a cada push. No Windows: `AutoHotkey64.exe tests\run.ahk` e leia `tests\results.txt`.
- O `.exe` é gerado pelo Actions (artefato `HotPaste` de cada execução). Para publicar uma versão: `git tag v1.0.0 && git push --tags`.
- Ícone: `assets/icon.svg` é a fonte; `icon.ico` e `icon.png` são gerados dela.

## Checklist manual (teclas globais e colagem não têm teste automático)

Rode no Windows, com o `.exe` do Actions, antes de cada versão:

- [ ] F1 preenchida cola no Bloco de Notas, no navegador (campo de texto) e no Word.
- [ ] Texto com acentos (`ação`, `ü`) e emoji cola idêntico.
- [ ] Texto com várias linhas cola com as quebras de linha.
- [ ] Texto com barra invertida (`C:\novo\nome`) cola idêntico.
- [ ] Slot vazio: F5 atualiza a página; F2 renomeia arquivo no Explorer.
- [ ] Slot só com espaços: a tecla ainda funciona normalmente.
- [ ] Copie uma imagem, aperte F1, depois cole (Ctrl+V): a imagem continua na área de transferência.
- [ ] Copie um texto, aperte F1, depois Ctrl+V: cola o texto copiado (não o preset).
- [ ] Segurar F1 cola só uma vez.
- [ ] Editar um texto na janela e apertar a tecla logo em seguida já usa o texto novo.
- [ ] "Limpar" esvazia o campo e a tecla volta ao normal.
- [ ] Fechar pelo X esconde a janela e o F1 continua colando; clique no ícone da bandeja reabre.
- [ ] Primeira execução do `.exe` (sem `HotPaste.ini`): "Iniciar com o Windows" aparece marcado na janela e no menu da bandeja; reiniciar o Windows: o app sobe sem janela, com o ícone na bandeja.
- [ ] Desmarcar na janela desmarca no menu da bandeja (e vice-versa); depois de apagar o app da lista, reabrir não religa sozinho (o `.ini` já existe).
- [ ] Desativar o HotPaste em Gerenciador de Tarefas → Inicializar: ao reabrir a janela, a caixa aparece desmarcada.
- [ ] Abrir o `.exe` de novo com ele já rodando não deixa dois ícones na bandeja.
- [ ] Apagar `HotPaste.ini` (ou encher de lixo) e abrir: o app abre com os 8 campos vazios, sem erro.
- [ ] Se algum programa cola o texto antigo, aumentar o atraso `delayMs` em `PasteText` (`src/hotkeys.ahk`).

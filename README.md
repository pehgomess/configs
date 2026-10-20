# Terminal Bash no Ubuntu

Prompt colorido com horário, usuário, hostname, pasta e branch Git.
`*` indica alterações (inclusive arquivos novos); `?` indica arquivos não rastreados.
Saudação com sistema, uptime, discos, rede e uma frase do fortune.
Inclui atalhos, tmux com tema Gruvbox e Neovim. Fish não é necessário.

## Instalar

```bash
cd /home/pedro/Documents/repo/configs
bash scripts/install-ubuntu.sh --packages
```

Abra um novo terminal Bash ou carregue a personalização na sessão atual:

```bash
source "${XDG_CONFIG_HOME:-$HOME/.config}/bash/terminal.bash"
```

`--packages` usa sudo para instalar bash, bash-completion, git, python3,
neovim, tmux, fortune-mod, xclip, wl-clipboard e ripgrep. Sem essa opção,
o instalador exige que os programas essenciais já estejam disponíveis.
Não altera seu shell de login. Se você o mudou para Fish anteriormente,
use `chsh -s /bin/bash` e entre novamente na sessão.

O `.bashrc` existente recebe um bloco para carregar `terminal.bash`;
as outras configurações são substituídas com backup. Os backups ficam em
`${XDG_DATA_HOME:-~/.local/share}/configs-backup.*`. Cada backup contém
`installed-files.txt` com os destinos alterados e os arquivos anteriores
com a estrutura de seus caminhos absolutos. Para desfazer, remova os destinos
listados e restaure os originais correspondentes. Respeita XDG_CONFIG_HOME e
XDG_DATA_HOME. Execute como seu usuário, sem sudo na frente do script.

Para testar só o visual, sem instalar nada:

```bash
bash --noprofile --rcfile .config/bash/terminal.bash -i
```

Use `exit` para voltar à sessão anterior. As frases exigem o banco instalado.
Para desativar a saudação, coloque `CONFIGS_GREETING=0` antes do bloco do
configs no seu `.bashrc`.

## Complementos

- **tmux:** funciona com Bash e inicia painéis em `/bin/bash`. Inicie com
  `tmux`; prefixo `Ctrl+a`, mouse habilitado e navegação `prefixo` + h/j/k/l.
  Copie com `y` no modo de cópia ou `Ctrl+y` para enviar o buffer ao clipboard.
  Usa wl-copy no Wayland e xclip no X11. Em sessões remotas sem servidor
  gráfico, o clipboard do desktop não estará disponível.
- **Neovim:** inicie com `nvim` ou `e`. Tema desert, números relativos,
  undo persistente e comandos externos via Bash. A configuração padrão não
  tem dependências de plugins. `init.vim-cpp` é uma variante legada com CoC,
  não aplicada: exige vim-plug, Node.js, CoC e servidores de linguagem.
- **fortune:** frases e índice instalados nos dados do usuário; não exige
  arquivos em `/usr/share/games/fortunes`.
- **Atalhos:** g/gc para Git, p/up para apt, e para Neovim, m para make,
  c/ct para Cargo. make e Cargo só são necessários se você usar esses atalhos.
  eza é opcional; sem ele os atalhos de listagem usam ls colorido.
- **Conclusão de comandos:** bash-completion é instalado e usa a integração
  padrão do Ubuntu. Para sugestões e realce durante a digitação, instale
  o complemento ble.sh abaixo.

O terminal precisa aceitar cores ANSI. Para os separadores Powerline do tmux,
selecione uma fonte com esses glifos se aparecerem quadrados. Tema e painéis
não trocam o emulador de terminal. As configurações antigas de Fish ficam
no repositório como referência, sem serem instaladas.

## Sugestões automáticas e conclusão com ble.sh

```bash
bash scripts/install-blesh.sh
```

Abra um novo terminal Bash. O instalador baixa o nightly oficial do ble.sh,
instala nos dados do usuário, atualiza a personalização e cria backup do
`.bashrc`, da personalização e da instalação anterior. Requer curl, tar e xz
(no Ubuntu: `sudo apt install curl xz-utils`). Não precisa repetir a instalação
completa de tmux/Neovim. O complemento é carregado automaticamente somente
em terminais interativos e preserva o prompt.

- Digite `cd ` e pressione Tab para completar e mostrar candidatos.
- Sugestões automáticas aparecem durante a digitação; seta para a direita no
  fim da linha aceita a sugestão, conforme os atalhos padrão do ble.sh.
- Comandos recebem realce de sintaxe; Ctrl+R busca o histórico.

Para desativar, coloque `CONFIGS_BLESH=0` antes do bloco configs no `.bashrc`
e abra outro terminal. Para uma sessão sem configurações: `bash --norc`.

Referência: [instalação e uso oficial do ble.sh](https://github.com/akinomyoga/ble.sh).

# Cheatsheet

## zsh / oh-my-zsh

Z Shell (zsh) using [oh-my-z.sh](https://ohmyz.sh/)

## tmux

[tmux](https://github.com/tmux/tmux) is a powerful terminal multiplexer. Using "h" as the command key e.g. C-h (ctrl+h) and vim keys (hjkl). [tmuxcheatsheet.com](https://tmuxcheatsheet.com/)

## neovim

See [init.vim](./files/init.vim) for full configuration.

Leader is configured to `;`. Typing `;ec` in normal mode will edit the init.vim config file.

### C ctrl

| C key | Note                         |
|-------|------------------------------|
| C-w   | Window move (hjkl)           |
| C-t   | Open terminal (ctrl+d close) |
| C-n   | Toggle nvim tree (left)      |
| C-a   | Toggle code tag tree (right) |
| C-p   | Find file (start typing)     |
| C-o   | go def back                  |
| C-l   | go def forward               |

### nvim-tree keys

[nvim-tree](nvim-tree/nvim-tree.lua)

| Key    | Note                     |
|--------|--------------------------|
| a      | add (create) file or dir |
| c or x | copy or cut              |
| d      | delete                   |
| p      | paste                    |
| r      | rename                   |
| s      | start                    |

### <leader> ; shortcuts

| <leader> xx | Note        |
|-------------|-------------|
| ;           | leader      |
| <leader>ec  | edit config |
| <leader>sc  | save config |
| <leader>cc  | comment     |
| <leader>ff  | find file   |
| <leader>fg  | live grep   |
| <leader>fb  | find buffer |

### golang

[ray-x/go.nvim](https://github.com/ray-x/go.nvim)

| Cmd             | Shortcut | Note                                                       |
|-----------------|----------|------------------------------------------------------------|
| :GoAddTags json |          | Add, remove, clear tags (GoRmTags xml, GoClearTags)        |
| :GoAddTest      |          | Create a test for this also (:GoAddAllTest, :GoAddExpTest) |
| :GoAlt          | ;ga      | Go to test or code                                         |
| :GoBuild        |          | go build                                                   |
| :GoCmt          | ;gc      | Go comment (add comment to function)                       |
|                 | gd       | goto definition                                            |
|                 | gr       | show references                                            |
| :GoIfErr        | ;ge      | Add if err != nil block                                    |
| :GoFillStruct   | ;gf      | Fill struct                                                |
| :GoFillSwitch   |          | Fill switch                                                |
| :GoFixPlurals   |          | Fix plurals a(a string, b string) to a(a, b string)        |
| :GoImpl         |          | :GoImpl receiver interface                                 |
| :GoLint         | ;gl      | Run Lint                                                   |
| :GoDoc          | ;gi      | Show info                                                  |
| :GoCoverage     | ;gx      | Show coverage                                              |
| :GoRename       |          | Go Rename                                                  |
| :GoTest         |          | Go Test (:GoTestFunc, :GoTestFile)                         |
| :GoGenerate     |          | Go Generate                                                |

#### golang debugging

[rcarriga/nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)

| Cmd            | Shortcut | Note              |
|----------------|----------|-------------------|
| :GoBreakToggle | ;gb      | Toggle breakpoint |
| :GoDebug -test | ;gdt     | Debug test        |
| :GoDebug -stop | ;gds     | Debug stop        |

Inside the debugging

| Key | Note              |
|-----|-------------------|
| c   | continue (run)    |
| n   | next              |
| s   | step              |
| S   | stop              |
| u   | up (step-out)     |
| D   | Down (step-in)    |
| b   | toggle breakpoint |
| P   | pause             |
| p   | print             |

## git

See [gitconfig](./files/gitconfig) for aliases and config.

set termguicolors
call plug#begin('~/.config/nvim/plugged')

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

Plug 'windwp/nvim-autopairs'
Plug 'ntpeters/vim-better-whitespace'

Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter'

Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'theHamsta/nvim-dap-virtual-text'

Plug 'ray-x/guihua.lua' " float term, codeaction and codelens gui support

Plug 'ray-x/lsp_signature.nvim'

Plug 'ray-x/go.nvim'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Disable ctrl+p in favour of telescope
" Plug 'ctrlpvim/ctrlp.vim'

Plug 'akinsho/toggleterm.nvim'

Plug 'preservim/nerdcommenter'

"Plug 'airblade/vim-gitgutter'

Plug 'stevearc/aerial.nvim'

Plug 'tpope/vim-fugitive'

Plug 'hashivim/vim-terraform'

Plug 'EdenEast/nightfox.nvim'
" Plug 'ray-x/aurora'

call plug#end()

" Relax file compatibility restriction with original vi
" (not necessary to set with neovim, but useful for vim)
set nocompatible

set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8

set undofile " Maintain undo history between sessions
set undodir=~/.vim/undodir"

" colours
" colorscheme aurora
colorscheme nightfox

" Disable beep / flash
set vb t_vb=

" Set tabs and indents (for go)
set ts=5
set shiftwidth=5
set ai sw=5
set noexpandtab

"" Line Numbers
set number

"" Enable hidden buffers
set nohidden

" highlight matches when searching
" Use C-l to clear (see key map section)
set hlsearch
set incsearch
set ignorecase
set smartcase

set shell=/usr/bin/zsh

" Disable line wrapping
" Toggle set to ';w' in key map section
set nowrap

" enable line and column display
set ruler

"disable showmode since using vim-airline; otherwise use 'set showmode'
set noshowmode

" change the leader key from "\" to ";" ("," is also popular)
let mapleader=";"

"" Disable the blinking cursor.
set gcr=a:blinkon0

" autowrite
set autowriteall

"todo
"au TermEnter * setlocal scrolloff=0
"au TermLeave * setlocal scrolloff=3

"" Status bar
set laststatus=2

"" Use modeline overrides
"set modeline
"set modelines=10

"set title
"set titleold="Terminal"
"set titlestring=%F

"" colours for vimdiff (todo: Not working)
"hi DiffAdd      ctermfg=Black         ctermbg=Green
"hi DiffChange   ctermfg=Green         ctermbg=Black
"hi DiffDelete   ctermfg=LightBlue     ctermbg=Red
"hi DiffText     ctermfg=Yellow        ctermbg=Red

"" no one is really happy until you have this shortcuts
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall

" Shortcut to edit THIS configuration file: (e)dit (c)onfiguration
nnoremap <silent> <leader>ec :e $MYVIMRC<CR>

" Shortcut to source (reload) THIS configuration file after editing it: (s)ource (c)onfiguraiton
nnoremap <silent> <leader>sc :source $MYVIMRC<CR>

" Shortcut to list and switch buffers
nnoremap <C-b> :buffers<CR>:b

" set paste / nopaste
nmap <silent> <leader>pp :set paste<CR>
nmap <silent> <leader>pn :set nopaste<CR>

" Go Stuff!
nnoremap <silent> <leader>ga :GoAlt<CR>
nnoremap <silent> <leader>gb :GoBreakToggle<CR>
nnoremap <silent> <leader>gc :GoCmt<CR>
nnoremap <silent> <leader>ge :GoIfErr<CR>
nnoremap <silent> <leader>gf :GoFillStruct<CR>
nnoremap <silent> <leader>gi :GoDoc<CR>
nnoremap <silent> <leader>gl :GoLint<CR>
nnoremap <silent> <leader>gt :GoAddTags<CR>
nnoremap <silent> <leader>gx :GoCoverage<CR>

" GoDebug stuff
nnoremap <silent> <leader>gdt :GoDebug -test<CR>
nnoremap <silent> <leader>gds :GoDebug -stop<CR>

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" toggle the tag bar
nnoremap <silent> <leader>a :AerialToggle float<cr>

" use ;; for escape - http://vim.wikia.com/wiki/Avoid_the_escape_key
inoremap ;; <Esc>

" Instead of ctrl+p
nnoremap <C-p> :Telescope find_files<CR>

nnoremap <C-n> :NvimTreeToggle<CR>

nnoremap <C-a> :AerialToggle right<CR>

" Toggle Terminal open with C-t
" To toggle it off you must run C-\ C-n C-t
nnoremap <C-t> :ToggleTerm size=25<CR>

"C-o godef back
"C-l godef forward

"todo installed in /opt/venv
"let g:python3_host_prog = '/home/tc/.config/nvim/venv38/bin/python3'

let g:better_whitespace_enabled=1
let g:strip_whitespace_on_save=1
let g:strip_whitespace_confirm=0

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#tabline#buffer_nr_show = 1

" todo not working eg :GoTestFunc shows nothing (quickfix)
"let g:go_term_enabled = 0
"let g:go_term_mode = "vsplit"
"let g:go_term_reuse = 0

" terraform
let g:terraform_fmt_on_save=1
let g:terraform_align=1

" gofmt on save
autocmd BufWritePre *.go :silent! lua require('go.format').goimport()

" Auto start NERD tree when opening a directory
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NvimTreeToggle' argv()[0] | wincmd p | ene | wincmd p | endif

" Auto start NERD tree if no files are specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | exe 'NvimTreeToggle' | endif

" todo: not working
" Let quit work as expected if after entering :q the only window left open is NERD Tree itself
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NvimTree") && b:NvimTree.isTabTree()) | q | endif

lua <<EOF
vim.loader.enable()

require('nvim-autopairs').setup({
     fast_wrap = {
          chars = { '{', '[', '(', '"', "'" },
     }
})

require'nvim-tree'.setup()

require("toggleterm").setup{
--  open_mapping = [[<c-;>]],
}

require 'go'.setup({
  goimport = 'gopls', -- if set to 'gopls' will use golsp format
  gofmt = 'gopls', -- if set to gopls will use golsp format
  max_line_len = 160,
  tag_transform = false, -- gomodifytag overwrite eg snakecase camelcase
  test_dir = '',
  comment_placeholder = ' ',
  lsp_cfg = true, -- false: use your own lspconfig
  lsp_gofumpt = true, -- true: set default gofmt in gopls format to gofumpt
  lsp_on_attach = true, -- use on_attach from go.nvim
  dap_debug = true,
})

cfg = {...}  -- add you config here
require "lsp_signature".setup(cfg)

require("go.format").goimport()  -- goimport + gofmt

local protocol = require'vim.lsp.protocol'

require('aerial').setup({})

EOF

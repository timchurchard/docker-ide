" ========== Vim Basic Settings ============= "

" Make vim incompatbile to vi.
set nocompatible
set modelines=2

" Pathogen settings.
filetype off
"call pathogen#runtime_append_all_bundles()
call pathogen#infect()
Helptags
filetype plugin indent on

" Line numbers
set number
set numberwidth=4

" TAB settings.
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smarttab

" More Common Settings.
set encoding=utf-8
set scrolloff=3
set autoindent
set copyindent
set showmode
set showcmd
set hidden
set visualbell
syntax on

" Make search ignore case if lowercase else case sensitive
set ignorecase
set smartcase

" incsearch
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)


" Get Rid of stupid Goddamned help keys
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" Work around for SSH in Browser (Alt+up down left right instead of ctrl+w h)
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>

" Insert mode press F2 to disable any auto-intent etc on the pasted text!
set pastetoggle=<F2>

" Wildmenu completion "
set wildmenu
set wildmode=list:longest
set wildignore+=.hg,.git,.svn " Version Controls"
set wildignore+=*.aux,*.out,*.toc "Latex Indermediate files"
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg "Binary Imgs"
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest "Compiled Object files"
set wildignore+=*.spl "Compiled speolling world list"
set wildignore+=*.sw? "Vim swap files"
set wildignore+=*.DS_Store "OSX SHIT"
set wildignore+=*.luac "Lua byte code"
set wildignore+=migrations "Django migrations"
set wildignore+=*.pyc "Python Object codes"
set wildignore+=*.orig "Merge resolution files"

" Stop vim writing backup files in normal dirs
set swapfile
set dir=/workspace/.vim-tmp

" ========== Plugin Settings ========== "

" Colour
colorscheme gruvbox

" gruvbox
set bg=dark
" set bg=light

" Mapping to NERDTree
nnoremap <C-n> :NERDTreeToggle<cr>
let NERDTreeIgnore=['\.vim$', '\~$', '\.pyc$']

" vim-go
let g:go_fmt_command="gopls"
let g:go_gopls_gofumpt=1

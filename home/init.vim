let mapleader = " "

nnoremap <Leader>c :nohlsearch<CR>

nnoremap <Leader><Leader> :buffer#<CR>
nnoremap <Leader>n :bnext<CR>
nnoremap <Leader>m :bprevious<CR>

nmap <C-N> :tabnext<CR>
nmap <C-P> :tabprev<CR>
nmap <C-X> :tabclose<CR>

nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>

noremap <Leader>w g<C-g>

nnoremap <Leader>o :only<CR>

let &t_SI = '\<Esc>[6 q'
let &t_SR = '\<Esc>[4 q'
let &t_EI = '\<Esc>[2 q'

filetype plugin indent on

syntax on

set colorcolumn=80

set mouse=a

set shortmess+=c

set hidden

set updatetime=100

set showcmd

set cursorline

set tabstop=8
set softtabstop=4
set shiftwidth=4
set expandtab

set modelines=1

set splitbelow
set splitright

set diffopt+=vertical

set wildmenu
set wildignorecase

set number relativenumber

set spelllang=en_gb

augroup numbertoggle
autocmd!
autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
autocmd BufLeave,FocusLost,InsertEnter * set norelativenumber
augroup END

set laststatus=2

set noshowmode

set incsearch
set hlsearch
set ignorecase
set smartcase

autocmd ColorScheme * highlight Comment cterm=italic

fun! TrimWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun

autocmd BufWritePre * :call TrimWhitespace()

" fugitive
nnoremap <Leader>gs :Git<CR>
nnoremap <Leader>gc :Git commit -v -q<CR>
nnoremap <Leader>ga :Git commit --amend -v -q<CR>
nnoremap <Leader>go :Git pull<CR>
nnoremap <Leader>gl :Glog<CR>
nnoremap <Leader>gp :Git push<CR>
nnoremap <Leader>gf :Git fetch<CR>
nnoremap <Leader>gb :Git blame<CR>
nnoremap <Leader>gr :GBrowse<CR>

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
set wildmode=longest:full,full

set number relativenumber

set spelllang=en_gb

augroup numbertoggle
autocmd!
autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
autocmd BufLeave,FocusLost,InsertEnter * set norelativenumber
augroup END

set noshowmode

set incsearch
set hlsearch
set ignorecase
set smartcase

fun! TrimWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun

autocmd BufWritePre * :call TrimWhitespace()

lua << EOF
  -- always show the sign column to prevent it moving
  vim.wo.signcolumn = "yes"

  -- fugitive
  vim.keymap.set('n', '<leader>gs', "<cmd>:Git<cr>", { desc = "Git status" })
  vim.keymap.set('n', '<leader>go', "<cmd>:Git pull<cr>", { desc = "Git pull" })
  vim.keymap.set('n', '<leader>gp', "<cmd>:Git push<cr>", { desc = "Git push" })
  vim.keymap.set('n', '<leader>gf', "<cmd>:Git fetch<cr>", { desc = "Git fetch" })
  vim.keymap.set('n', '<leader>gb', "<cmd>:Git blame<cr>", { desc = "Git blame" })
  vim.keymap.set('n', '<leader>gl', "<cmd>:Git log --oneline --graph<cr>", { desc = "Git log" })
  vim.keymap.set('n', '<leader>gr', "<cmd>:GBrowse<cr>", { desc = "Git open" })
EOF

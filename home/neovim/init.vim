lua << EOF
  -- keybind leaders
  vim.g.mapleader = " "
  vim.g.maplocalleader = "\\"

  -- options

  -- show where 80 chars is
  vim.o.colorcolumn = "80"

  -- highlight line where the cursor is
  vim.o.cursorline = true

  -- enable mouse mode
  vim.o.mouse = 'a'

  -- decrease update time
  vim.o.updatetime = 100

  -- show commands in bottom right
  vim.o.showcmd = true

  -- don't show current mode, statusline will do that
  vim.o.showmode = false

  -- spacings
  vim.o.tabstop = 8
  vim.o.softtabstop = 4
  vim.o.shiftwidth = 4
  vim.o.expandtab = true

  -- numbering
  vim.o.number = true
  vim.o.relativenumber = true

  -- always show the sign column to prevent it moving
  vim.wo.signcolumn = "yes"

  -- ensure guicolors are set up
  vim.o.termguicolors = true

  -- search settings
  vim.o.incsearch = true
  vim.o.hlsearch = true
  vim.o.ignorecase = true
  vim.o.smartcase = true

EOF

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

set splitbelow
set splitright

set diffopt+=vertical

set wildmenu
set wildignorecase
set wildmode=longest:full,full


set spelllang=en_gb

augroup numbertoggle
autocmd!
autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
autocmd BufLeave,FocusLost,InsertEnter * set norelativenumber
augroup END

fun! TrimWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun

autocmd BufWritePre * :call TrimWhitespace()

lua << EOF
  -- fugitive
  vim.keymap.set('n', '<leader>gs', "<cmd>:Git<cr>", { desc = "Git status" })
  vim.keymap.set('n', '<leader>go', "<cmd>:Git! pull<cr>", { desc = "Git pull" })
  vim.keymap.set('n', '<leader>gp', "<cmd>:Git! push<cr>", { desc = "Git push" })
  vim.keymap.set('n', '<leader>gu', "<cmd>:Git! push --set-upstream origin HEAD<cr>", { desc = "Git push new branch" })
  vim.keymap.set('n', '<leader>gf', "<cmd>:Git! fetch<cr>", { desc = "Git fetch" })
  vim.keymap.set('n', '<leader>gb', "<cmd>:Git blame<cr>", { desc = "Git blame" })
  vim.keymap.set('n', '<leader>gl', "<cmd>:Git log --oneline --graph<cr>", { desc = "Git log" })
  vim.keymap.set('n', '<leader>gr', "<cmd>:GBrowse<cr>", { desc = "Git open" })

  -- neogit
  vim.keymap.set('n', '<leader>gn', "<cmd>:Neogit<cr>", { desc = "Neogit" })

  -- Goyo
  vim.keymap.set('n', '<leader>y', "<cmd>:Goyo<cr>", { desc = "Goyo" })
EOF


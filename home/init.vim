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

" coc

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<TAB>'
let g:coc_snippet_prev = '<S-TAB>'

nmap <LocalLeader>d <Plug>(coc-definition)
nmap <LocalLeader>t <Plug>(coc-type-definition)
nmap <LocalLeader>f <Plug>(coc-references)
nmap <LocalLeader>r <Plug>(coc-rename)
nmap <LocalLeader>i <Plug>(coc-implementation)
nmap <Leader>s <Plug>(coc-diagnostic-prev)
nmap <Leader>d <Plug>(coc-diagnostic-next)
nmap <Leader>a :CocList --auto-preview diagnostics<CR>
nmap <LocalLeader>a :CocAction<CR>
nmap <LocalLeader>c <Plug>(coc-codelens-action)

nnoremap <silent> <LocalLeader>h :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

autocmd CursorHold * silent call CocActionAsync('highlight')

" try and open documentation in a new buffer split
inoremap <silent> <C-x> <C-r>=ShowDoc()<CR><C-e>
function! ShowDoc() abort
  let winid = get(g:, 'coc_last_float_win', -1)
  if winid != -1
    let bufnr = winbufnr(winid)
    exe 'below sb '.bufnr
  endif
  return ''
endfunction

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

" telescope
nnoremap <leader>b <cmd>Telescope buffers<cr>
nnoremap <leader>f <cmd>Telescope find_files<cr>
nnoremap <leader>l <cmd>Telescope live_grep<cr>
nnoremap <leader>/ <cmd>Telescope current_buffer_fuzzy_find<cr>

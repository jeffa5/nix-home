pkgs: {
  enable = true;
  vimAlias = true;
  vimdiffAlias = true;
  extraPackages = with pkgs; [ nodejs ];
  extraConfig = ''
    let mapleader = "\<Space>"

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

    autocmd FileType * setlocal formatoptions-=cro

    autocmd ColorScheme * highlight Comment cterm=italic

    fun! TrimWhitespace()
        let l:save = winsaveview()
        keeppatterns %s/\s\+$//e
        call winrestview(l:save)
    endfun

    autocmd BufWritePre * :call TrimWhitespace()
  '';
  plugins = with pkgs.vimPlugins; [
    {
      plugin = gruvbox-community;
      config = ''
        set background=dark
        colorscheme gruvbox
      '';
    }
    {
      plugin = coc-nvim;
      config = ''
        inoremap <silent><expr> <TAB>
              \ pumvisible() ? "\<C-n>" :
              \ <SID>check_back_space() ? "\<TAB>" :
              \ coc#refresh()
        inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

        function! s:check_back_space() abort
          let col = col('.') - 1
          return !col || getline('.')[col - 1]  =~# '\s'
        endfunction

        inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

        function! s:check_back_space() abort
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

        nnoremap <LocalLeader>h :call <SID>show_documentation()<CR>

        function! s:show_documentation()
            if (index(['vim','help'], &filetype) >= 0)
              execute 'h '.expand('<cword>')
            else
              call CocAction('doHover')
            endif
        endfunction

        autocmd CursorHold * silent call CocActionAsync('highlight')
      '';
    }
    coc-rust-analyzer
    coc-yank
    coc-highlight
    coc-json
    coc-yaml
    {
      plugin = vim-fugitive;
      config = ''
        nnoremap <Leader>gs :Gstatus<CR>
        nnoremap <Leader>gc :Gcommit -v -q<CR>
        nnoremap <Leader>ga :Gcommit --amend -v -q<CR>
        nnoremap <Leader>go :Gpull<CR>
        nnoremap <Leader>gl :Glog<CR>
        nnoremap <Leader>gp :Gpush<CR>
        nnoremap <Leader>gf :Gfetch<CR>
        nnoremap <Leader>gb :Gblame<CR>
        nnoremap <Leader>gr :Gbrowse<CR>
      '';
    }
    vim-eunuch
    vim-commentary
    vim-unimpaired
    vim-surround
    vim-dispatch
    vim-repeat
    vim-gitgutter
    lexima-vim
    {
      plugin = lightline-vim;
      config = ''
        function! CocCurrentFunction()
            return get(b:, 'coc_current_function', "")
        endfunction

        let g:lightline = {
              \ 'colorscheme': 'gruvbox',
              \ 'active': {
              \   'left': [ [ 'mode', 'paste' ],
              \             [ 'gitbranch' ],
              \             [ 'readonly', 'filename', 'modified' ] ],
              \   'right': [ [ 'cocstatus', 'currentfunction' ],
              \              [ 'percent', 'lineinfo' ],
              \              [ 'fileformat', 'fileencoding', 'filetype' ] ]
              \ },
              \ 'tabline': {
              \   'left': [ [ 'tabs' ] ],
              \   'right': []
              \ },
              \ 'component_function': {
              \   'filename': 'LightlineFilename',
              \   'gitbranch': 'fugitive#head',
              \   'cocstatus': 'coc#status',
              \   'currentfunction': 'CocCurrentFunction'
              \ },
              \ }

        function! LightlineFilename()
            return expand('%:f')
        endfunction
      '';
    }
    {
      plugin = fzf-vim;
      config = ''
        nmap <Leader>b :Buffers<CR>
        nmap <Leader>f :Files<CR>
        nmap <Leader>l :Lines<CR>
        nmap <Leader>/ :BLines<CR>
        nmap <Leader>t :Windows<CR>
      '';
    }
    {
      plugin = indentLine;
      config = ''
        let g:indentLine_concealcursor = ""
      '';
    }
    {
      plugin = vimtex;
      config = ''
        let g:vimtex_view_method = 'zathura'
        let g:vimtex_quickfix_open_on_warning = 0
        let g:vimtex_compiler_latexmk = {
            \ 'options' : [
            \   '-pdf',
            \   '-shell-escape',
            \   '-verbose',
            \   '-file-line-error',
            \   '-synctex=1',
            \   '-interaction=nonstopmode',
            \ ],
            \}
        let g:tex_flavor = 'latex'
      '';
    }
    {
      plugin = neoformat;
      config = ''
        nmap <Leader>e :Neoformat<CR>
        augroup fmt
            autocmd!
            autocmd BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')
            autocmd BufWritePre * :Neoformat
        augroup END
        let g:neoformat_enabled_ruby = []
        let g:neoformat_enabled_yaml = ['prettier']
        let g:neoformat_enabled_python = ['black', 'isort']
        let g:neoformat_go_gofmt = {
            \ 'exe': 'gofmt',
            \ 'args': ['-s'],
            \ }
        let g:neoformat_enabled_go = ['gofmt']
        let g:neoformat_enabled_markdown = []
        let g:neoformat_sh_shfmt = {
            \ 'exe': 'shfmt',
            \ 'args': ['-i 2', '-ci', '-bn', '-s'],
            \ 'stdin': 1,
            \ }
      '';
    }
    {
      plugin = vimspector;
      config = ''
        let g:vimspector_enable_mappings='HUMAN'
      '';
    }
    {
      plugin = goyo-vim;
      config = ''
        nmap <silent><Leader>y :Goyo<CR>
        let g:goyo_linenr = 1
        let g:goyo_width = 100
        autocmd! User GoyoEnter Limelight
        autocmd! User GoyoLeave Limelight!
      '';
    }
    {
      plugin = limelight-vim;
      config = ''
        let g:limelight_conceal_ctermfg = 'darkgray'
      '';
    }
    vim-polyglot
  ];
}
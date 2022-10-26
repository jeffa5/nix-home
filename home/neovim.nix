pkgs: {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    coc.enable = true;
    coc.package = pkgs.vimUtils.buildVimPluginFrom2Nix {
      pname = "coc.nvim";
      version = "2022-05-21";
      src = pkgs.fetchFromGitHub {
        owner = "neoclide";
        repo = "coc.nvim";
        rev = "791c9f673b882768486450e73d8bda10e391401d";
        sha256 = "sha256-MobgwhFQ1Ld7pFknsurSFAsN5v+vGbEFojTAYD/kI9c=";
      };
      meta.homepage = "https://github.com/neoclide/coc.nvim/";
    };
    coc.settings = {
      "diagnostic.errorSign" = "";
      "diagnostic.warningSign" = "";
      "diagnostic.infoSign" = "";
      "diagnostic.hintSign" = "";
      "rust-analyzer.cargo.runBuildScripts" = true;
      "rust-analyzer.checkOnSave.command" = "clippy";
      "rust-analyzer.cargo.allFeatures" = true;
      "rust-analyzer.procMacro.enable" = true;
      "coc.preferences.formatOnSaveFiletypes" = [
        "css"
        "json"
        "jsonc"
        "markdown"
        "rust"
      ];
    };
    extraPackages = with pkgs; [ nodejs rustfmt alejandra ];
    extraConfig = ''
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

      " fzf
      nnoremap <Leader>b :Buffers<CR>
      nnoremap <Leader>f :Files<CR>
      nnoremap <Leader>l :Lines<CR>
      nnoremap <Leader>/ :BLines<CR>
      nnoremap <Leader>t :Windows<CR>

      " goyo
      nnoremap <silent><Leader>y :Goyo<CR>
      let g:goyo_linenr = 1
      let g:goyo_width = 100
      autocmd! User GoyoEnter Limelight
      autocmd! User GoyoLeave Limelight!
    '';
    plugins = with pkgs.vimPlugins; [
      {
        plugin = gruvbox-community;
        config = ''
          set background=light
          let g:gruvbox_contrast_light = 'hard'
          colorscheme gruvbox
        '';
      }
      coc-rust-analyzer
      coc-yank
      # gives 100% cpu usage...
      # coc-highlight
      coc-json
      coc-yaml
      coc-go
      coc-vimtex
      coc-texlab
      coc-prettier
      coc-pyright
      coc-tsserver
      vim-fugitive
      vim-rhubarb
      {
        plugin = fugitive-gitlab-vim;
        config = ''
          let g:fugitive_gitlab_domains = ['https://gitlab.developers.cam.ac.uk/']
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
                \   'gitbranch': 'FugitiveHead',
                \   'cocstatus': 'coc#status',
                \   'currentfunction': 'CocCurrentFunction'
                \ },
                \ }

          function! LightlineFilename()
              return expand('%:f')
          endfunction
        '';
      }
      fzf-vim
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
          nnoremap <Leader>e :Neoformat<CR>
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
      goyo-vim
      {
        plugin = limelight-vim;
        config = ''
          let g:limelight_conceal_ctermfg = 'darkgray'
        '';
      }
      {
        plugin = vim-polyglot;
        config = ''
          let g:vim_markdown_conceal = 0
          let g:vim_markdown_conceal_code_blocks = 0
        '';
      }
    ];
  };
}

pkgs: {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    coc.enable = true;
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
    extraPackages = with pkgs; [nodejs rustfmt alejandra];
    extraConfig = builtins.readFile ./init.vim;
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
      {
        plugin = indentLine;
        config = ''
          let g:indentLine_concealcursor = ""
        '';
      }
      {
        plugin = vimtex;
        config = ''
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
      {
        plugin = vim-polyglot;
        config = ''
          let g:vim_markdown_conceal = 0
          let g:vim_markdown_conceal_code_blocks = 0
        '';
      }

      telescope-nvim
      nvim-treesitter
    ];
  };
}

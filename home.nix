{ config, pkgs, ... }:

{
  home.username = "andrew";
  home.homeDirectory = "/home/andrew";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs  ; [
    htop
    waybar
    mako
    xwayland
    alacritty
    zathura
    (nerdfonts.override { fonts = [ "Hack" ]; })
    spotify
    tmux
    aerc
    newsboat
    syncthing
    wofi
    rofi
    bat
    wl-clipboard
    ripgrep
    playerctl
    pamixer
    tree
    swaylock
    swayidle
    lm_sensors
    fd
  ];

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableNixDirenvIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      delta.enable = true;
    };

    firefox = {
      enable = true;
      package = pkgs.firefox-wayland;
      profiles = {
        andrew = {
          settings = {
            "browser.startup.page" = 3;
            "browser.shell.checkDefaultBrowser" = false;
            "browser.startup.homepage" = "about:blank";
            "browser.newtabpage.enabled" = false;
          };
        };
      };
    };

    neovim = {
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
    };

    zsh = {
      enable = true;
      plugins = [
        {
          # will source zsh-autosuggestions.plugin.zsh
          name = "zsh-autosuggestions";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-autosuggestions";
            rev = "v0.4.0";
            sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
          };
        }
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-syntax-highlighting";
            rev = "0.7.1";
            sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
          };
        }
        {
          name = "alias-tips";
          src = pkgs.fetchFromGitHub {
            owner = "djui";
            repo = "alias-tips";
            rev = "master";
            sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
          };
        }
      ];
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "gitfast" ];
      };

      initExtra = ''
          source ~/.zsh/vi
          source ~/.zsh/aliases
          source ~/.zsh/prompt
          [ -f ~/.zsh/local_aliases ] && source ~/.zsh/local_aliases

          export EDITOR=nvim
          export VISUAL=nvim

          autoload edit-command-line; zle -N edit-command-line
          bindkey '^e' edit-command-line

          export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

          zstyle ':completion:*:*:make:*' tag-order 'targets'

        # OPAM configuration
          . $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

          [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

          fpath+=${ZDOTDIR:-~}/.zsh/functions

          autoload -U +X bashcompinit && bashcompinit
          autoload -Uz compinit && compinit -i

          export TERM=xterm-256color
      '';
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    extraConfig = ''
      # Logo key. Use Mod1 for Alt.
            set $mod Mod4
      # Home row direction keys, like vim
            set $left h
            set $down j
            set $up k
            set $right l
      # Your preferred terminal emulator
            set $term alacritty

      # Your preferred application launcher
            set $menu ~/.local/bin/sway/rofi

      # rename workspaces
            set $workspace1 "1 "
            set $workspace2 "2 "
            set $workspace3 "3 "
            set $workspace4 "4  "
            set $workspace5 "5  "
            set $workspace6 "6  "
            set $workspace7 "7  "
            set $workspace8 "8 "
            set $workspace9 "9 "
            set $workspace10 "10 "

      ### Output configuration
      #
      # Default wallpaper (more resolutions are available in /usr/share/backgrounds/sway/)
            output * bg ~/.wallpaper.png fill

      ### Input configuration
      #
      # Example configuration:
      #
      #   input "2:14:SynPS/2_Synaptics_TouchPad" {
      #       dwt enabled
      #       tap enabled
      #       natural_scroll enabled
      #       middle_emulation enabled
      #   }
      #
      # You can get the names of your inputs by running: swaymsg -t get_inputs
      # Read `man 5 sway-input` for more information about this section.
            input "1739:31251:DLL07BE:01_06CB:7A13_Touchpad" {
            middle_emulation enabled
            tap enabled
            natural_scroll enabled
            }

      ### Key bindings
      #
      # Basics:
      #
          # start a terminal
            bindsym $mod+Return exec $term

          # kill focused window
            bindsym $mod+q kill

          # start your launcher
            bindsym $mod+space exec $menu

          # Drag floating windows by holding down $mod and left mouse button.
          # Resize them with right mouse button + $mod.
          # Despite the name, also works for non-floating windows.
          # Change normal to inverse to use left mouse button for resizing and right
          # mouse button for dragging.
            floating_modifier $mod normal

          # reload the configuration file
            bindsym $mod+Shift+r reload

      #
      # Moving around:
      #
          # Move your focus around
            bindsym $mod+$left focus left
            bindsym $mod+$down focus down
            bindsym $mod+$up focus up
            bindsym $mod+$right focus right
          # or use $mod+[up|down|left|right]
            bindsym $mod+Left focus left
            bindsym $mod+Down focus down
            bindsym $mod+Up focus up
            bindsym $mod+Right focus right

          # _move_ the focused window with the same, but add Shift
            bindsym $mod+Shift+$left move left
            bindsym $mod+Shift+$down move down
            bindsym $mod+Shift+$up move up
            bindsym $mod+Shift+$right move right
          # ditto, with arrow keys
            bindsym $mod+Shift+Left move left
            bindsym $mod+Shift+Down move down
            bindsym $mod+Shift+Up move up
            bindsym $mod+Shift+Right move right
      #
      # Workspaces:
      #

          # switch to workspace
            bindsym $mod+1 workspace $workspace1
            bindsym $mod+2 workspace $workspace2
            bindsym $mod+3 workspace $workspace3
            bindsym $mod+4 workspace $workspace4
            bindsym $mod+5 workspace $workspace5
            bindsym $mod+6 workspace $workspace6
            bindsym $mod+7 workspace $workspace7
            bindsym $mod+8 workspace $workspace8
            bindsym $mod+9 workspace $workspace9
            bindsym $mod+0 workspace $workspace10
          # move focused container to workspace
            bindsym $mod+Shift+1 move container to workspace $workspace1
            bindsym $mod+Shift+2 move container to workspace $workspace2
            bindsym $mod+Shift+3 move container to workspace $workspace3
            bindsym $mod+Shift+4 move container to workspace $workspace4
            bindsym $mod+Shift+5 move container to workspace $workspace5
            bindsym $mod+Shift+6 move container to workspace $workspace6
            bindsym $mod+Shift+7 move container to workspace $workspace7
            bindsym $mod+Shift+8 move container to workspace $workspace8
            bindsym $mod+Shift+9 move container to workspace $workspace9
            bindsym $mod+Shift+0 move container to workspace $workspace10
          # Note: workspaces can have any name you want, not just numbers.
          # We just use 1-10 as the default.
      #
      # Layout stuff:
      #
          # You can "split" the current object of your focus with
          # $mod+b or $mod+v, for horizontal and vertical splits
          # respectively.
            bindsym $mod+b splith
            bindsym $mod+v splitv

          # Switch the current container between different layout styles
            bindsym $mod+s layout stacking
            bindsym $mod+w layout tabbed
            bindsym $mod+e layout toggle split

          # Make the current focus fullscreen
            bindsym $mod+f fullscreen

          # Toggle the current focus between tiling and floating mode
            bindsym $mod+Shift+space floating toggle

          # Swap focus between the tiling area and the floating area
          #bindsym $mod+space focus mode_toggle

          # move focus to the parent container
            bindsym $mod+a focus parent


      # start the udiskie program to automount drives
            exec --no-startup-id udiskie -N

      # start notification daemon
            exec --no-startup-id mako

      # start redshift
            exec --no-startup-id redshift
            include ~/.config/sway/config.d/*
    '';
    config = {
      modifier = "Mod4";
      keybindings = { };
      bars = [
        {
          command = "\${pkgs.waybar}/bin/waybar";
        }
      ];
    };
  };

  services = {
    wlsunset = {
      enable = true;
      latitude = "51.5";
      longitude = "-0.1";
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";
}

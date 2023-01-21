pkgs: {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      rust-analyzer
      pyright
      sumneko-lua-language-server
      isort
      pylint
      black
      alejandra
      nil
      marksman
    ];
    extraConfig = builtins.readFile ./neovim/init.vim;
    plugins = with pkgs.vimPlugins; [
      {
        plugin = gruvbox-nvim;
        type = "lua";
        config = ''
          require("gruvbox").setup{}
          vim.o.background = "light"
          vim.cmd([[colorscheme gruvbox]])
        '';
      }
      vim-fugitive
      vim-rhubarb
      {
        plugin = fugitive-gitlab-vim;
        config = ''
          let g:fugitive_gitlab_domains = ['https://gitlab.developers.cam.ac.uk/']
        '';
      }
      vim-eunuch
      {
        plugin = comment-nvim;
        type = "lua";
        config = ''
          -- commentary
          require("Comment").setup{}
        '';
      }
      vim-unimpaired
      vim-surround
      vim-repeat
      lexima-vim
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

      telescope-fzf-native-nvim
      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/telescope-nvim.lua;
      }
      nvim-treesitter.withAllGrammars
      {
        plugin = nvim-treesitter-context;
        type = "lua";
        config = ''
          -- context
          require("treesitter-context").setup{}
        '';
      }
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          -- setup done in nvim-cmp loop below
        '';
      }
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      cmp-path
      cmp-buffer
      cmp_luasnip
      luasnip
      {
        plugin = nvim-cmp;
        type = "lua";
        config = builtins.readFile ./neovim/nvim-cmp.lua;
      }
      {
        plugin = null-ls-nvim;
        type = "lua";
        config = ''
          -- null lsp
          local null_ls = require("null-ls")
          null_ls.setup {
            sources = {
              null_ls.builtins.diagnostics.pylint,
              null_ls.builtins.formatting.isort,
              null_ls.builtins.formatting.black,
              null_ls.builtins.formatting.alejandra,
            }
          }
        '';
      }
      {
        plugin = lualine-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/lualine.lua;
      }
      {
        # lsp progress text
        plugin = fidget-nvim;
        type = "lua";
        config = ''
          -- fidget-nvim
          require("fidget").setup{}
        '';
      }
      {
        plugin = rust-tools-nvim;
        type = "lua";
        config = ''
          local rt = require("rust-tools")

          rt.setup({
            server = {
              on_attach = function(client, bufnr)
                -- call the general bindings
                on_attach(client, bufnr)
                -- Hover actions
                vim.keymap.set("n", "<localleader>h", rt.hover_actions.hover_actions, { buffer = bufnr, desc = "Hover" })
                -- Code action groups
                vim.keymap.set("n", "<localleader>a", rt.code_action_group.code_action_group, { buffer = bufnr, desc = "Code action" })
              end,
            },
          })
        '';
      }

      {
        plugin = which-key-nvim;
        type = "lua";
        config = ''
          vim.o.timeout = true
          vim.o.timeoutlen = 300
          require("which-key").setup {}
        '';
      }
      {
        plugin = indent-blankline-nvim-lua;
        type = "lua";
        config = ''
          -- indent blankline
          require("indent_blankline").setup {}
        '';
      }
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          -- gitsigns
          require('gitsigns').setup()
        '';
      }
    ];
  };
}

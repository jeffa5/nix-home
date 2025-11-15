{
  pkgs,
  lib,
  ...
}: let
  vimPkgs = pkgs.vimPlugins;
in {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages =
      [
        pkgs.alejandra
        pkgs.black
        pkgs.beancount-language-server
        pkgs.clang-tools
        pkgs.isort
        pkgs.lua-language-server
        pkgs.marksman
        pkgs.nil
        pkgs.nodePackages.prettier
        pkgs.pylint
        pkgs.pyright
        pkgs.rust-analyzer
        pkgs.texlab
        pkgs.tinymist
      ]
      ++ lib.optional (pkgs ? wordnet-ls) pkgs.wordnet-ls
      ++ lib.optional (pkgs ? maills) pkgs.maills
      ++ lib.optional (pkgs ? icalls) pkgs.icalls;
    extraConfig = builtins.readFile ./neovim/init.vim;
    plugins = [
      {
        plugin = vimPkgs.gruvbox-nvim;
        type = "lua";
        config = ''
          require("gruvbox").setup{}
          vim.o.background = "light"
          vim.cmd([[colorscheme gruvbox]])
        '';
      }
      vimPkgs.vim-fugitive
      vimPkgs.vim-rhubarb
      vimPkgs.fugitive-gitlab-vim
      vimPkgs.vim-eunuch
      {
        plugin = vimPkgs.comment-nvim;
        type = "lua";
        config = ''
          -- commentary
          require("Comment").setup{}
        '';
      }
      vimPkgs.vim-unimpaired
      vimPkgs.vim-surround
      vimPkgs.vim-repeat
      vimPkgs.lexima-vim
      {
        plugin = vimPkgs.vim-polyglot;
        config = ''
          let g:vim_markdown_conceal = 0
          let g:vim_markdown_conceal_code_blocks = 0
        '';
      }

      {
        plugin = vimPkgs.fzf-lua;
        type = "lua";
        config = builtins.readFile ./neovim/fzf-lua.lua;
      }

      vimPkgs.nvim-treesitter.withAllGrammars
      {
        plugin = vimPkgs.nvim-treesitter-context;
        type = "lua";
        config = ''
          -- context
          require("treesitter-context").setup{}
        '';
      }
      {
        plugin = vimPkgs.nvim-lspconfig;
        type = "lua";
        config = ''
          -- setup done in nvim-cmp loop below
        '';
      }
      vimPkgs.cmp-nvim-lsp
      vimPkgs.cmp-nvim-lsp-signature-help
      vimPkgs.cmp-path
      vimPkgs.cmp-buffer
      vimPkgs.cmp_luasnip
      vimPkgs.luasnip
      {
        plugin = vimPkgs.nvim-cmp;
        type = "lua";
        config =
          (builtins.readFile ./neovim/nvim-cmp.lua)
          + lib.optionalString (pkgs ? wordnet-ls) ''
            vim.lsp.config('wordnet', {
                on_attach = on_attach,
                capabilities = capabilities,
                init_options = { wordnet = '${pkgs.wordnet}/dict' },
                default_config = {
                    cmd = { 'wordnet-ls', '--stdio' },
                    filetypes = { 'text', 'markdown', 'typst' },
                    root_dir = function(_)
                        return '/'
                    end,
                }
            })
          ''
          + lib.optionalString (pkgs ? maills) ''
            vim.lsp.config('maills', {
                on_attach = on_attach,
                capabilities = capabilities,
                init_options = { vcard_dir = '~/contacts/jeffas', contact_list_file = '~/contacts/list' },
                default_config = {
                    cmd = { 'maills', '--stdio' },
                    filetypes = { 'mail' },
                    root_dir = function(_)
                        return '/'
                    end,
                }
            })
          ''
          + lib.optionalString (pkgs ? icalls) ''
            vim.lsp.config('icalls', {
                on_attach = on_attach,
                capabilities = capabilities,
                init_options = {},
                default_config = {
                    cmd = { 'icalls', '--stdio' },
                    filetypes = { 'icalendar' },
                    root_dir = function(_)
                        return '/'
                    end,
                }
            })
          '';
      }
      {
        plugin = vimPkgs.none-ls-nvim;
        type = "lua";
        config = ''
          -- none lsp
          local null_ls = require("null-ls")
          null_ls.setup {
            sources = {
              null_ls.builtins.diagnostics.pylint,
              null_ls.builtins.formatting.isort,
              null_ls.builtins.formatting.black,
              null_ls.builtins.formatting.alejandra,
              null_ls.builtins.formatting.prettier,
            }
          }
        '';
      }
      {
        plugin = vimPkgs.lualine-nvim;
        type = "lua";
        config = builtins.readFile ./neovim/lualine.lua;
      }
      {
        # lsp progress text
        plugin = vimPkgs.fidget-nvim;
        type = "lua";
        config = ''
          -- fidget-nvim
          require("fidget").setup{}
        '';
      }
      {
        plugin = vimPkgs.which-key-nvim;
        type = "lua";
        config = ''
          vim.o.timeout = true
          vim.o.timeoutlen = 300
          require("which-key").setup {}
        '';
      }
      {
        plugin = vimPkgs.indent-blankline-nvim-lua;
        type = "lua";
        config = ''
          -- indent blankline
          require("ibl").setup {}
        '';
      }
      {
        plugin = vimPkgs.gitsigns-nvim;
        type = "lua";
        config = ''
          -- gitsigns
          require('gitsigns').setup()
        '';
      }

      {
        plugin = vimPkgs.aerial-nvim;
        type = "lua";
        config = ''
          -- aerial
          require("aerial").setup({
            on_attach = function(bufnr)
              -- Jump forwards/backwards with '{' and '}'
              vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
              vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
            end,
          })
          vim.keymap.set("n", "<localleader>o", "<cmd>AerialToggle!<CR>", {desc = "Outline"})
        '';
      }
      {
        plugin = vimPkgs.img-clip-nvim;
        type = "lua";
        config = ''
          -- img-clip
          require("img-clip").setup({
            default = {
              dir_path = ".",
              relative_to_current_file = true,
            }
          })
          vim.keymap.set("n", "<leader>p", "<cmd>PasteImage<CR>", {desc = "Paste image"})
        '';
      }
      vimPkgs.vim-beancount
      {
        plugin = vimPkgs.vim-slime;
        config = ''
          " vim-slime
          let g:slime_target = "tmux"
          let g:slime_default_config = {"socket_name": "default", "target_pane": "{last}"}
        '';
      }
      {
        plugin = vimPkgs.oil-nvim;
        type = "lua";
        config = ''
          require("oil").setup()
        '';
      }
    ];
  };
}

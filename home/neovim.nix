{
  wordnet-ls,
  maills,
  icalls,
}: {pkgs, ...}: {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      alejandra
      black
      isort
      lua-language-server
      marksman
      nil
      pylint
      pyright
      rust-analyzer
      clang-tools
      texlab
      tinymist
      wordnet-ls
      maills
      icalls
    ];
    extraConfig = builtins.readFile ./neovim/init.vim;
    plugins = with pkgs.vimPlugins; [
      {
        plugin = goyo-vim;
        config = ''
          let g:goyo_linenr = 1
          function! s:goyo_enter()
            set noshowmode
            set noshowcmd
            set scrolloff=999
            lua require('lualine').hide()
          endfunction

          function! s:goyo_leave()
            set showmode
            set showcmd
            set scrolloff=5
            lua require('lualine').hide({unhide=true})
          endfunction

          autocmd! User GoyoEnter nested call <SID>goyo_enter()
          autocmd! User GoyoLeave nested call <SID>goyo_leave()
        '';
      }
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
      neogit
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

      {
        plugin = fzf-lua;
        type = "lua";
        config = builtins.readFile ./neovim/fzf-lua.lua;
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
        config =
          (builtins.readFile ./neovim/nvim-cmp.lua)
          + ''
            require('lspconfig')['wordnet'].setup {
                on_attach = on_attach,
                capabilities = capabilities,
                init_options = { wordnet = '${pkgs.wordnet}/dict' },
            }

            require('lspconfig')['maills'].setup {
                on_attach = on_attach,
                capabilities = capabilities,
                init_options = { vcard_dir = '~/contacts/jeffas', contact_list_file = '~/contacts/list' },
            }

            require('lspconfig')['icalls'].setup {
                on_attach = on_attach,
                capabilities = capabilities,
                init_options = {},
            }
          '';
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
              -- https://github.com/simrat39/rust-tools.nvim/issues/300
              settings = {
                  ["rust-analyzer"] = {
                      inlayHints = { locationLinks = false },
                      check = { command = "clippy" },
                  }
              }
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
          require("ibl").setup {}
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
      typst-vim

      {
        plugin = aerial-nvim;
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
    ];
  };
}

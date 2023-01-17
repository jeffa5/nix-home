pkgs: {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [rust-analyzer sumneko-lua-language-server];
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
        plugin = telescope-nvim;
        type = "lua";
        config = ''

          -- telescope
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>f', builtin.find_files, {})
          vim.keymap.set('n', '<leader>l', builtin.live_grep, {})
          vim.keymap.set('n', '<leader>b', builtin.buffers, {})
          vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, {})

          -- diagnostic mappings
          -- see `:help vim.diagnostic.*` for docs
          vim.keymap.set('n', '<leader>a', builtin.diagnostics, {})
          vim.keymap.set('n', '<leader>d', vim.diagnostic.goto_next, {})
          vim.keymap.set('n', '<leader>s', vim.diagnostic.goto_prev, {})

          local actions = require("telescope.actions")
          require("telescope").setup{
            defaults = {
              mappings = {
                i = {
                  ["<esc>"] = actions.close
                },
              },
            }
          }
          '';
      }
      nvim-treesitter
      {
        plugin =
          nvim-lspconfig;
        type = "lua";
        config = ''
          -- setup done in nvim-cmp loop below
        '';
      }
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      cmp-path
      cmp_luasnip
      luasnip
      {
        plugin = nvim-cmp;
        type = "lua";
        config = builtins.readFile ./neovim/nvim-cmp.lua;
      }
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require('lualine').setup {
            options = {
              section_separators = { left = ' ', right = ' ' },
              component_separators = { left = '|', right = '|' },
            },
            sections = {
              lualine_a = {'mode'},
              lualine_b = {'branch', 'diff', 'diagnostics'},
              lualine_c = {{'filename', path = 1}, 'lsp_progress'},
              lualine_x = {'encoding', 'fileformat', 'filetype'},
              lualine_y = {'progress'},
              lualine_z = {'location'}
            },
            extensions = {'quickfix', 'fugitive'},
          }
          '';
      }
      {
        plugin = lualine-lsp-progress;
        type = "lua";
        config = ''
          '';
      }
    ];
  };
}

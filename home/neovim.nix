pkgs: {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [rust-analyzer];
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
        config = ''
          -- Add additional capabilities supported by nvim-cmp
          local capabilities = require("cmp_nvim_lsp").default_capabilities()

          local lspconfig = require('lspconfig')

          -- Use an on_attach function to only map the following keys
          -- after the language server attaches to the current buffer
          local on_attach = function(client, bufnr)
            -- Mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local bufopts = { noremap=true, silent=true, buffer=bufnr }
            vim.keymap.set('n', '<localleader>D', vim.lsp.buf.declaration, bufopts)
            vim.keymap.set('n', '<localleader>d', vim.lsp.buf.definition, bufopts)
            vim.keymap.set('n', '<localleader>h', vim.lsp.buf.hover, bufopts)
            vim.keymap.set('n', '<localleader>i', vim.lsp.buf.implementation, bufopts)
            vim.keymap.set('n', '<localleader>s', vim.lsp.buf.signature_help, bufopts)
            vim.keymap.set('n', '<localleader>t', vim.lsp.buf.type_definition, bufopts)
            vim.keymap.set('n', '<localleader>r', vim.lsp.buf.rename, bufopts)
            vim.keymap.set('n', '<localleader>a', vim.lsp.buf.code_action, bufopts)
            vim.keymap.set('n', '<localleader>f', vim.lsp.buf.references, bufopts)
            vim.keymap.set('n', '<localleader>e', function() vim.lsp.buf.format { async = true } end, bufopts)
          end

          -- Enable some language servers with the additional completion capabilities offered by nvim-cmp
          local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver' }
          for _, lsp in ipairs(servers) do
            lspconfig[lsp].setup {
              on_attach = on_attach,
              capabilities = capabilities,
            }
          end

          -- luasnip setup
          local luasnip = require 'luasnip'

          -- nvim-cmp setup
          local cmp = require 'cmp'
          cmp.setup {
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ['<C-u>'] = cmp.mapping.scroll_docs(-4),
              ['<C-d>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<CR>'] = cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
              },
              ['<Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
                else
                  fallback()
                end
              end, { 'i', 's' }),
              ['<S-Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                  luasnip.jump(-1)
                else
                  fallback()
                end
              end, { 'i', 's' }),
            }),
            sources = {
              { name = 'nvim_lsp' },
              { name = 'luasnip' },
              { name = 'nvim_lsp_signature_help' },
              { name = 'path' },
            },
          }
        '';
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

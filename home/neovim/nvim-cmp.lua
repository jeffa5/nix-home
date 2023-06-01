-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = function(desc)
        return { noremap = true, silent = true, buffer = bufnr, desc = desc }
    end
    vim.keymap.set('n', '<localleader>D', vim.lsp.buf.declaration, bufopts("Goto declaration"))
    vim.keymap.set('n', '<localleader>d', vim.lsp.buf.definition, bufopts("Goto definition"))
    vim.keymap.set('n', '<localleader>h', vim.lsp.buf.hover, bufopts("Hover"))
    vim.keymap.set('n', '<localleader>i', vim.lsp.buf.implementation, bufopts("Goto implementation"))
    vim.keymap.set('n', '<localleader>s', vim.lsp.buf.signature_help, bufopts("Signature help"))
    vim.keymap.set('n', '<localleader>t', vim.lsp.buf.type_definition, bufopts("Goto type definition"))
    vim.keymap.set('n', '<localleader>r', vim.lsp.buf.rename, bufopts("Rename"))
    vim.keymap.set('n', '<localleader>a', vim.lsp.buf.code_action, bufopts("Code action"))
    vim.keymap.set('n', '<localleader>f', vim.lsp.buf.references, bufopts("Show references"))
    vim.keymap.set('n', '<localleader>e', function() vim.lsp.buf.format { async = true } end, bufopts("Format"))

    -- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#highlight-symbol-under-cursor
    if client.server_capabilities.documentHighlightProvider then
        vim.cmd [[
          hi! LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
          hi! LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
          hi! LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
        ]]
        vim.api.nvim_create_augroup('lsp_document_highlight', {
            clear = false
        })
        vim.api.nvim_clear_autocmds({
            buffer = bufnr,
            group = 'lsp_document_highlight',
        })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            group = 'lsp_document_highlight',
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            group = 'lsp_document_highlight',
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
        })
    end
end

-- Add additional capabilities supported by nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local lspconfig = require('lspconfig')

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver', 'nil_ls', 'gopls', 'texlab', 'marksman', 'typst_lsp' }
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

lspconfig['lua_ls'].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}

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
        { name = 'buffer' },
    },
}

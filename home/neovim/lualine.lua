local function lsp_client_names()
    local client_names = {}
    for _, client in ipairs(vim.lsp.get_active_clients()) do
        table.insert(client_names, client.name)
    end
    return table.concat(client_names, ",")
end

require('lualine').setup {
    options = {
        section_separators = { left = ' ', right = ' ' },
        component_separators = { left = '|', right = '|' },
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'filetype', 'encoding', 'fileformat' },
        lualine_y = { lsp_client_names },
        lualine_z = { 'progress', 'location' }
    },
    extensions = { 'quickfix', 'fugitive' },
}

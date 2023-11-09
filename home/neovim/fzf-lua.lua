-- fzf-lua
local fzflua = require('fzf-lua')
vim.keymap.set('n', '<leader>f', fzflua.files, { desc = "Find files" })
vim.keymap.set('n', '<leader>l', fzflua.live_grep, { desc = "Find lines" })
vim.keymap.set('n', '<leader>b', fzflua.buffers, { desc = "Buffers" })
vim.keymap.set('n', '<leader>/', fzflua.lines, { desc = "Buffer lines" })

-- diagnostic mappings
-- see `:help vim.diagnostic.*` for docs
vim.keymap.set('n', '<leader>a', fzflua.diagnostics_workspace, { desc = "Diagnostics" })
vim.keymap.set('n', '<leader>d', vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set('n', '<leader>s', vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })

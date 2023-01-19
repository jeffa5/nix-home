-- telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = "Find files" })
vim.keymap.set('n', '<leader>l', builtin.live_grep, { desc = "Find lines" })
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = "Buffers" })
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = "Buffer lines" })

-- diagnostic mappings
-- see `:help vim.diagnostic.*` for docs
vim.keymap.set('n', '<leader>a', builtin.diagnostics, { desc = "Diagnostics" })
vim.keymap.set('n', '<leader>d', vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set('n', '<leader>s', vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })

local actions = require("telescope.actions")
require("telescope").setup {
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close
            },
        },
    }
}

-- use fzf filtering
require("telescope").load_extension("fzf")

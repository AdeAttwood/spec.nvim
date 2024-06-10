local runner = require "spec.runner"

vim.api.nvim_create_user_command("SpecFile", runner.run_file, { bang = true })
vim.api.nvim_create_user_command("SpecAtCursor", runner.run_at_cursor, { bang = true })
vim.api.nvim_set_keymap("n", "st", "<cmd>SpecAtCursor<CR>", { nowait = true, silent = true })
vim.api.nvim_set_keymap("n", "sf", "<cmd>SpecFile<CR>", { nowait = true, silent = true })

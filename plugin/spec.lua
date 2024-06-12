local runner = require "spec.runner"
local view_error = require "spec.view_error"

vim.api.nvim_create_user_command("SpecViewError", view_error, { bang = true })
vim.api.nvim_create_user_command("SpecFile", runner.run_file, { bang = true })
vim.api.nvim_create_user_command("SpecAtCursor", runner.run_at_cursor, { bang = true })
vim.api.nvim_set_keymap("n", "st", "<cmd>SpecAtCursor<CR>", { nowait = true, silent = true })
vim.api.nvim_set_keymap("n", "sf", "<cmd>SpecFile<CR>", { nowait = true, silent = true })

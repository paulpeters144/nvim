-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<C-b>", "<C-v>", { desc = "Visual block mode" })

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-f>", "<C-f>zz")
vim.keymap.set("n", "<C-b>", "<C-b>zz")
vim.keymap.set("n", "Y", "yy")

vim.keymap.del("n", "<leader>e")
vim.keymap.del("n", "<leader>E")


-- -- Leaving this here as an example in case you want to delete default keymaps
-- -- delete default buffer navigation keymaps
vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")

-- vim.keymap.set("n", "<S-h>", function()
--   require("telescope.builtin").buffers(require("telescope.themes").get_ivy({
--     sort_mru = true,
--     -- -- Sorts current and last buffer to the top and selects the lastused (default: false)
--     -- -- Leave this at false, otherwise when put in normal mode, the buffer
--     -- -- below is selected, not the one at the top
--     sort_lastused = false,
--     initial_mode = "normal",
--     -- Pre-select the current buffer
--     -- ignore_current_buffer = false,
--     -- select_current = true,
--     layout_config = {
--       -- Set preview width, 0.7 sets it to 70% of the window width
--       preview_width = 0.45,
--     },
--   }))
-- end, { desc = "[P]Open telescope buffers" })

vim.keymap.set("n", "<S-h>", function()
  require("telescope.builtin").buffers(require("telescope.themes").get_ivy({
    sort_mru = true,
    sort_lastused = false,
    initial_mode = "normal",
    layout_config = {
      height = 50,       -- number of lines tall (you can also try 0.5 for 50% of screen)
      preview_width = 0.45,
    },
    attach_mappings = function(_, map)
      local actions = require("telescope.actions")

      -- Map `d` in normal mode inside telescope
      map("n", "d", actions.delete_buffer)

      return true
    end,
  }))
end, { desc = "[P]Open telescope buffers" })

return {
  {
    "nvim-lua/plenary.nvim",
    init = function()
      local function show_cheatsheet()
        local Path = require("plenary.path")
        local cheatsheet_path = vim.fn.stdpath("config") .. "/lua/user/cheatsheet.txt"

        local file = Path:new(cheatsheet_path)
        local ok, lines = pcall(function()
          return file:readlines()
        end)

        if not ok or not lines then
          lines = { "❌ Could not read cheatsheet file." }
        end

        local width = 70
        local height = #lines + 2
        local buf = vim.api.nvim_create_buf(false, true)

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

        vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = math.floor((vim.o.lines - height) / 2),
          col = math.floor((vim.o.columns - width) / 2),
          style = "minimal",
          border = "rounded",
        })

        vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
        vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, silent = true })
      end

      vim.keymap.set("n", "<leader>ch", show_cheatsheet, { desc = "Show Cheatsheet" })
    end,
  },
}

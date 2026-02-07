return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local selected_model = "gemini-3-flash-preview"
      local adapter_name = "Gemini 3 Flash"

      -- Dynamic adapter function
      local function get_adapter()
        return require("codecompanion.adapters").extend("gemini", {
          name = adapter_name,
          schema = {
            model = {
              default = selected_model,
            },
          },
        })
      end

      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = get_adapter,
          },
          inline = {
            adapter = get_adapter,
          },
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "AI [C]hat" })
      vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "AI [A]ctions" })
      vim.keymap.set({ "n", "v" }, "<leader>ai", "<cmd>CodeCompanion<cr>", { desc = "AI [I]nline" })
      
      vim.keymap.set({ "n", "v" }, "<leader>as", function()
        if selected_model == "gemini-3-flash-preview" then
          selected_model = "gemini-3-pro-preview"
          adapter_name = "Gemini 3 Pro"
        else
          selected_model = "gemini-3-flash-preview"
          adapter_name = "Gemini 3 Flash"
        end
        vim.notify("Switched CodeCompanion model to " .. adapter_name)
      end, { desc = "AI [S]witch Model" })
    end,
  },
}

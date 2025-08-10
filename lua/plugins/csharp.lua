-- in your lua/plugins/csharp.lua
return {
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    opts = {
      filewatching = "roslyn",
      broad_search = true,         -- scan parent dirs for .sln
      lock_target = false,
      ignore_target = nil,
    },
  },
  {
    "bosvik/roslyn-diagnostics.nvim",
    ft = { "cs" },
    opts = {
      filter = function(f)
        return f:match("%.cs$") and not f:match("/[ob][ij][bn]/")
      end,
      diagnostic_opts = {
        virtual_text = { prefix = "●" },
        severity_sort = true,
      },
    },
    keys = { { "<leader>cD", "<cmd>RequestDiagnostics<cr>", desc = "Roslyn Diagnostics" } },
  },
}

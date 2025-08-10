return {
  "williamboman/mason.nvim",
  opts = function(_, opts)
    -- Add the extra registries here
    opts.registries = {
      "github:mason-org/mason-registry",
      "github:Crashdummyy/mason-registry",
    }
  end,
}

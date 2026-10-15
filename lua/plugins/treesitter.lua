-- nvim-treesitter parser management + HLSL shader support
--
-- nvim-treesitter is already pulled in as a dependency of inliber; this spec
-- loads it eagerly so the HLSL parser can be installed automatically and
-- `:TSInstall` is always available.

return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    init = function()
      -- Neovim ships no filetype for HLSL shaders (unlike glsl), so register
      -- the common extensions ourselves.
      vim.filetype.add {
        extension = {
          hlsl = 'hlsl',
          hlsli = 'hlsl',
          hlslh = 'hlsl',
          fx = 'hlsl',
          fxh = 'hlsl',
          cginc = 'hlsl',
        },
      }
    end,
    config = function()
      -- Install the HLSL parser (and its `cpp` dependency) on first run if it
      -- isn't already installed. This is a no-op once installed.
      vim.schedule(function()
        local installed = require('nvim-treesitter.config').get_installed('parsers')
        if not vim.list_contains(installed, 'hlsl') then
          require('nvim-treesitter').install { 'hlsl' }
        end
      end)
    end,
  },
}

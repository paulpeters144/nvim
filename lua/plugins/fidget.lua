return {
  {
    'j-hui/fidget.nvim',
    opts = {
      progress = {
        display = {
          done_icon = '✓', -- Icon shown when the AI finishes its task
        },
      },
      notification = {
        window = {
          winblend = 0, -- Ensure the notification window is opaque
        },
      },
    },
  },
}

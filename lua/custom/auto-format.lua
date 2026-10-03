vim.api.nvim_create_autocmd('BufWritePost', {
  callback = function(args)
    -- local file = vim.api.nvim_buf_get_name(args.buf)
    -- print('Saved: ' .. file)
  end,
})

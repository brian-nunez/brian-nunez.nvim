local group = vim.api.nvim_create_augroup('config-autocmds', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  group = group,
  desc = 'Highlight yanked text',
  callback = function()
    vim.highlight.on_yank()
  end,
})

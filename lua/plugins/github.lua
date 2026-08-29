return {
  {
    'tpope/vim-rhubarb',
    cmd = 'GBrowse',
    dependencies = 'tpope/vim-fugitive',
  },
  {
    'github/copilot.vim',
    enabled = false,
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.api.nvim_set_keymap('i', '<Tab>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
      vim.g.copilot_filetypes = {
        ['*'] = true,
        ['javascript'] = true,
        ['typescript'] = true,
        ['html'] = true,
        ['lua'] = true,
        ['rust'] = true,
        ['c'] = true,
        ['c#'] = true,
        ['c++'] = true,
        ['go'] = true,
        ['python'] = true,
        ['yml'] = true,
        ['yaml'] = true,
      }
    end,
  },
}

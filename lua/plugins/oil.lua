return {
  {
    'stevearc/oil.nvim',
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    lazy = false,
    config = function()
      require('oil').setup {
        view_options = {
          -- Show files and directories that start with "."
          show_hidden = true,
        },
        float = {
          padding = 5,
          max_width = 0.6,
          max_height = 0.6,
          border = 'rounded',
          win_options = {
            winblend = 0,
          },
          get_win_title = function()
            return vim.fn.stdpath 'config'
          end,
          preview_split = 'right',
        },
      }
      vim.keymap.set('n', '_', '<cmd>Oil --float .<cr>', { desc = 'Open directory in floating Oil' })
      vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open parent directory' })
      vim.keymap.set('n', '<leader>dir', '<cmd>Oil<cr>', { desc = 'Open directory' })
      vim.keymap.set('n', '<leader>n', '<cmd>Oil<cr>', { desc = 'Open file explorer' })
      vim.keymap.set('n', '<leader>files', '<cmd>Oil<cr>', { desc = 'Open files' })
    end,
  },
}

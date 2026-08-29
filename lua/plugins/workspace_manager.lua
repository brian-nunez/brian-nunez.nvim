return {
  {
    'coffebar/neovim-project',
    opts = {
      projects = {
        '~/Documents/workspace/*',
        '~/.config/*',
      },
      picker = {
        type = 'telescope',
      },
    },
    init = function()
      vim.opt.sessionoptions:append 'globals'
      vim.keymap.set('n', '<leader>pd', '<cmd>NeovimProjectDiscover<cr>', { desc = 'Discover project' })
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'Shatur/neovim-session-manager',
    },
    lazy = false,
    priority = 100,
  },
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
  },
}

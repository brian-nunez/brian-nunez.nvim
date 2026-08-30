local parsers = {
  'bash',
  'c',
  'diff',
  'go',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'vim',
  'vimdoc',
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local treesitter = require 'nvim-treesitter'

      -- During a branch migration, Lazy can load the legacy module before it
      -- checks out the rewritten main branch. Avoid calling the new API until
      -- it is actually available; the next Neovim start will use main.
      if type(treesitter.install) == 'function' then
        treesitter.install(parsers)
      else
        vim.notify('Restart Neovim to finish the nvim-treesitter main-branch migration', vim.log.levels.WARN)
        return
      end

      vim.api.nvim_create_autocmd('FileType', {
        desc = 'Enable Tree-sitter highlighting and indentation',
        callback = function(event)
          pcall(vim.treesitter.start, event.buf)

          if vim.bo[event.buf].filetype ~= 'ruby' then
            vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}

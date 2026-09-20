local parsers = {
  'arduino',
  'astro',
  'bash',
  'c',
  'cpp',
  'css',
  'csv',
  'diff',
  'dockerfile',
  'git_config',
  'gitcommit',
  'gitignore',
  'go',
  'gomod',
  'gosum',
  'gowork',
  'hcl',
  'html',
  'ini',
  'java',
  'javascript',
  'json',
  'lua',
  'luadoc',
  'make',
  'markdown',
  'markdown_inline',
  'nginx',
  'php',
  'python',
  'query',
  'requirements',
  'ruby',
  'sql',
  'ssh_config',
  'templ',
  'terraform',
  'toml',
  'tsv',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'xml',
  'yaml',
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install(parsers)

      vim.api.nvim_create_autocmd('FileType', {
        desc = 'Enable Tree-sitter highlighting and indentation',
        callback = function(event)
          if not pcall(vim.treesitter.start, event.buf) then
            return
          end

          if vim.bo[event.buf].filetype ~= 'ruby' then
            vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}

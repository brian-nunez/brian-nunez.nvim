return {
  {
    'lervag/vimtex',
    ft = { 'bib', 'plaintex', 'tex' },
    init = function()
      vim.g.vimtex_view_method = vim.fn.has 'macunix' == 1 and 'skim' or 'zathura'
    end,
  },
}

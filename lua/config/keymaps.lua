local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic errors' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic quickfix list' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

map('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus upper window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right window' })

map('n', 'j', 'jzz')
map('n', 'k', 'kzz')
map('n', '<leader>format', '=ap', { desc = 'Format paragraph' })

map('n', '<leader>ac', '<cmd>!arduino-cli compile -b arduino:renesas_uno:unor4wifi .<cr>', { desc = 'Arduino compile' })
map('n', '<leader>au', function()
  local port = vim.env.ARDUINO_PORT
  local port_argument = port and ' -p ' .. vim.fn.shellescape(port) or ''
  vim.cmd('!arduino-cli upload' .. port_argument .. ' -b arduino:renesas_uno:unor4wifi .')
end, { desc = 'Arduino upload' })

local minimum_version = { 0, 11, 5 }

local required_executables = {
  'arduino-cli',
  'arduino-language-server',
  'bash-language-server',
  'clangd',
  'dlv',
  'git',
  'go',
  'gopls',
  'java',
  'javac',
  'jdtls',
  'lua-language-server',
  'make',
  'node',
  'npm',
  'pyright-langserver',
  'python3',
  'rg',
  'stylua',
  'tsc',
  'typescript-language-server',
  'unzip',
}

local function check_version()
  local version = vim.version()
  local version_string = string.format('%d.%d.%d', version.major, version.minor, version.patch)

  if vim.version.cmp(version, minimum_version) >= 0 then
    vim.health.ok('Neovim version: ' .. version_string)
  else
    vim.health.error('Neovim 0.11.5 or newer is required; found ' .. version_string)
  end
end

local function check_executables()
  for _, executable in ipairs(required_executables) do
    local path = vim.fn.exepath(executable)
    if path ~= '' then
      vim.health.ok(executable .. ': ' .. path)
    else
      vim.health.error(executable .. ' is missing; run ./check-dependencies.sh')
    end
  end
end

return {
  check = function()
    vim.health.start 'Neovim configuration'
    vim.health.info('System: ' .. vim.inspect(vim.uv.os_uname()))
    check_version()
    check_executables()
  end,
}

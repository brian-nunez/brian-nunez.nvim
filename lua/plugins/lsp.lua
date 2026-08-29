local servers = { 'arduino_language_server', 'clangd', 'gopls', 'lua_ls' }

local function executable(name)
  local path = vim.fn.exepath(name)
  return path ~= '' and path or name
end

local function arduino_config_file()
  local data_directory = vim.fn.has 'macunix' == 1 and '~/Library/Arduino15' or '~/.arduino15'
  return vim.fn.expand(data_directory .. '/arduino-cli.yaml')
end

local function get_clangd()
  return vim.lsp.get_clients({ bufnr = 0, name = 'clangd' })[1]
end

local function setup_clangd_commands()
  vim.api.nvim_create_user_command('ClangdSwitchSourceHeader', function()
    local client = get_clangd()
    if not client then
      vim.notify('Clangd is not attached to this buffer', vim.log.levels.ERROR)
      return
    end

    client:request('textDocument/switchSourceHeader', vim.lsp.util.make_text_document_params(0), function(err, result)
      if err then
        vim.notify(err.message or tostring(err), vim.log.levels.ERROR)
      elseif result then
        vim.cmd.edit(vim.uri_to_fname(result))
      else
        vim.notify 'No corresponding source or header file found'
      end
    end, 0)
  end, { desc = 'Switch between C/C++ source and header' })

  vim.api.nvim_create_user_command('ClangdShowSymbolInfo', function()
    local client = get_clangd()
    if not client then
      vim.notify('Clangd is not attached to this buffer', vim.log.levels.ERROR)
      return
    end

    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    client:request('textDocument/symbolInfo', params, function(err, result)
      if err or not result or not result[1] then
        return
      end

      local name = 'name: ' .. result[1].name
      local container = 'container: ' .. result[1].containerName
      vim.lsp.util.open_floating_preview({ name, container }, '', {
        border = 'rounded',
        focus = false,
        focusable = false,
      })
    end, 0)
  end, { desc = 'Show clangd symbol information' })
end

local function arduino_root(bufnr, on_dir)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local root = vim.fs.root(filename, function(name)
    return name:match '%.ino$' ~= nil
  end)

  on_dir(root or vim.fs.dirname(filename))
end

local function setup_lsp()
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  capabilities.textDocument.semanticTokens = capabilities.textDocument.semanticTokens or {}
  capabilities.textDocument.semanticTokens.multilineTokenSupport = true

  vim.lsp.config('*', { capabilities = capabilities })

  vim.lsp.config('clangd', {
    cmd = { 'clangd', '--background-index', '--clang-tidy', '--header-insertion=iwyu' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
    root_markers = {
      { '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', 'compile_flags.txt', 'configure.ac' },
      '.git',
    },
  })

  vim.lsp.config('arduino_language_server', {
    cmd = {
      executable 'arduino-language-server',
      '-cli-config',
      arduino_config_file(),
      '-cli',
      executable 'arduino-cli',
      '-clangd',
      executable 'clangd',
      '-fqbn',
      'arduino:renesas_uno:unor4wifi',
    },
    filetypes = { 'arduino' },
    root_dir = arduino_root,
    capabilities = {
      textDocument = { semanticTokens = vim.NIL },
      workspace = { semanticTokens = vim.NIL },
    },
  })

  vim.lsp.config('gopls', {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = { 'go.work', 'go.mod', '.git' },
    settings = {
      gopls = {
        analyses = { unusedparams = true },
        completeUnimported = true,
        usePlaceholders = true,
      },
    },
  })

  local lua_library = vim.api.nvim_get_runtime_file('lua', true)
  table.insert(lua_library, '${3rd}/luv/library')

  vim.lsp.config('lua_ls', {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = {
      { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml' },
      '.git',
    },
    settings = {
      Lua = {
        completion = { callSnippet = 'Replace' },
        runtime = { version = 'LuaJIT' },
        workspace = {
          checkThirdParty = false,
          library = lua_library,
        },
      },
    },
  })

  vim.lsp.enable(servers)
end

local function setup_attach_mappings()
  local group = vim.api.nvim_create_augroup('config-lsp-attach', { clear = true })

  vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(event)
      local client = assert(vim.lsp.get_client_by_id(event.data.client_id))
      local telescope = require 'telescope.builtin'
      local map = function(keys, action, desc)
        vim.keymap.set('n', keys, action, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      map('gd', telescope.lsp_definitions, 'Go to definition')
      map('gr', telescope.lsp_references, 'Go to references')
      map('gI', telescope.lsp_implementations, 'Go to implementation')
      map('<leader>D', telescope.lsp_type_definitions, 'Type definition')
      map('<leader>ds', telescope.lsp_document_symbols, 'Document symbols')
      map('<leader>ws', telescope.lsp_dynamic_workspace_symbols, 'Workspace symbols')
      map('<leader>rn', vim.lsp.buf.rename, 'Rename')
      map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
      map('K', vim.lsp.buf.hover, 'Hover documentation')
      map('gD', vim.lsp.buf.declaration, 'Go to declaration')

      if client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function()
          local enabled = vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }
          vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
        end, 'Toggle inlay hints')
      end

      if client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_group = vim.api.nvim_create_augroup('config-lsp-highlight-' .. event.buf, { clear = true })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          group = highlight_group,
          buffer = event.buf,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          group = highlight_group,
          buffer = event.buf,
          callback = vim.lsp.buf.clear_references,
        })
      end
    end,
  })
end

return {
  {
    'hrsh7th/cmp-nvim-lsp',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      setup_clangd_commands()
      setup_attach_mappings()
      setup_lsp()
    end,
  },
}

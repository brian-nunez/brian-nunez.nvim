# Neovim Configuration

- Production configuration for Neovim 0.11.5 or newer.
- Supported systems:
  - macOS on Apple Silicon.
  - Ubuntu Desktop 24.04 on AMD64.
- Uses Neovim's built-in LSP configuration API.
- Uses system-installed language servers and formatters.
- Does not use Mason or NERDTree.
- Uses `lazy.nvim` for plugin management and `oil.nvim` for file browsing.

## Documentation

- [Installation and external software](docs/installation.md)
- [Plugin inventory and key mappings](docs/plugins.md)

## Quick Start

```bash
cd ~/.config/nvim
./check-dependencies.sh
nvim
```

- Run `:Lazy` after startup to inspect plugin status.
- Run `:checkhealth config` to verify Neovim and external executables.
- Run `:checkhealth vim.lsp` inside a project to inspect LSP clients.

## Layout

```text
.
├── init.lua
├── check-dependencies.sh
├── lazy-lock.json
├── docs/
│   ├── installation.md
│   └── plugins.md
└── lua/
    ├── config/
    │   ├── autocmds.lua
    │   ├── health.lua
    │   ├── keymaps.lua
    │   └── options.lua
    └── plugins/
        └── *.lua
```

## Maintenance

- Add plugin specs under `lua/plugins/`.
- Keep external tools on `PATH` before starting Neovim.
- Update plugins through `:Lazy`.
- Update Tree-sitter parsers through `:TSUpdate`.
- Keep `lazy-lock.json` committed to preserve reproducible plugin versions.

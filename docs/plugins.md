# Plugin Inventory and Key Mappings

## Plugin Manager

| Plugin | Purpose | Loading |
| --- | --- | --- |
| `folke/lazy.nvim` | Plugin installation, lazy loading, updates, and lockfile management | Bootstrapped by `init.lua` |

- Plugin specifications live in `lua/plugins/`.
- Locked revisions live in `lazy-lock.json`.
- Inspect, install, update, or clean plugins with `:Lazy`.

## Editing and Interface

| Plugin | Purpose | Loading |
| --- | --- | --- |
| `numToStr/Comment.nvim` | Line and visual-region commenting with `gc` motions | `VeryLazy` |
| `folke/todo-comments.nvim` | Highlights TODO, FIXME, NOTE, and related comment keywords | `VeryLazy` |
| `lukas-reineke/indent-blankline.nvim` | Indentation guides | Buffer read or creation |
| `tpope/vim-sleuth` | Detects indentation settings from file contents | Buffer read or creation |
| `tpope/vim-surround` | Adds, changes, and removes paired surroundings | `VeryLazy` |
| `echasnovski/mini.nvim` | `mini.ai`, `mini.surround`, and `mini.statusline` | Startup |
| `folke/which-key.nvim` | Displays available key sequences | `VeryLazy` |
| `folke/zen-mode.nvim` | Distraction-free editing | `:ZenMode` |
| `projekt0n/github-nvim-theme` (`github-theme`) | GitHub dark high-contrast colorscheme | Startup, priority 1000 |
| `andweeb/presence.nvim` | Discord rich presence | `VeryLazy` |

## Files, Search, and Projects

| Plugin | Purpose | Loading |
| --- | --- | --- |
| `stevearc/oil.nvim` | Editable filesystem browser replacing NERDTree | Startup |
| `nvim-telescope/telescope.nvim` | File, text, help, diagnostic, buffer, and LSP search | `VimEnter` |
| `ibhagwan/fzf-lua` | Alternate fuzzy-finder command | `:FzfLua` |
| `theprimeagen/harpoon` | Fast navigation among marked files | `VeryLazy` |
| `coffebar/neovim-project` | Project discovery and session restoration | Startup, priority 100 |
| `Shatur/neovim-session-manager` | Session persistence used by `neovim-project` | Dependency |

## Completion, LSP, Formatting, and Syntax

| Plugin | Purpose | Loading |
| --- | --- | --- |
| `hrsh7th/nvim-cmp` | Insert-mode completion menu | `InsertEnter` |
| `hrsh7th/cmp-nvim-lsp` | LSP completion source and LSP capability integration | Buffer read or creation |
| `L3MON4D3/LuaSnip` | Snippet expansion for completion items | `nvim-cmp` dependency |
| `saadparwaiz1/cmp_luasnip` | LuaSnip completion source | `nvim-cmp` dependency |
| `hrsh7th/cmp-path` | Filesystem-path completion source | `nvim-cmp` dependency |
| `j-hui/fidget.nvim` | LSP progress notifications | LSP dependency |
| `stevearc/conform.nvim` | Format-on-save with LSP fallback | Before write or `:ConformInfo` |
| `nvim-treesitter/nvim-treesitter` | Syntax parsing, highlighting, and indentation | Buffer read or creation |

- Configured Tree-sitter parsers:
  - Bash.
  - C.
  - Diff.
  - Go.
  - HTML.
  - Lua and LuaDoc.
  - Markdown and inline Markdown.
  - Query.
  - Vim and Vim help.
- Configured external formatters:
  - Lua: `stylua`.
  - Templ: `templ`.
- All other supported buffers use LSP formatting as the fallback.
- Native LSP support is enabled for Arduino, Bash, C/C++, Go, Java, JavaScript, Lua, Python, and TypeScript.

## Debugging

| Plugin | Purpose | Loading |
| --- | --- | --- |
| `mfussenegger/nvim-dap` | Debug Adapter Protocol client | First debugger key press |
| `rcarriga/nvim-dap-ui` | Debugger panels and controls | DAP dependency |
| `nvim-neotest/nvim-nio` | Async I/O required by DAP UI | DAP UI dependency |
| `leoluz/nvim-dap-go` | Go and test debugging through Delve | DAP dependency |

- The DAP UI opens when a session starts and closes when it terminates or exits.
- Delve must be available as `dlv` on `PATH`.

## Git and GitHub

| Plugin | Purpose | Loading |
| --- | --- | --- |
| `tpope/vim-fugitive` | Git commands and repository operations | Fugitive command |
| `lewis6991/gitsigns.nvim` | Added, changed, and deleted line indicators | Buffer read or creation |
| `tpope/vim-rhubarb` | GitHub URL support for Fugitive `:GBrowse` | `:GBrowse` |
| `github/copilot.vim` | GitHub Copilot completion | Disabled |

- Copilot is retained in the configuration but has `enabled = false`.
- No Copilot runtime or Node.js installation is required while it remains disabled.

## Arduino, Embedded Go, and LaTeX

| Plugin | Purpose | Loading |
| --- | --- | --- |
| `stevearc/vim-arduino` | Arduino buffer commands and workflow | Arduino file type |
| `pcolladosoto/tinygo.nvim` | TinyGo tooling integration | Go file type |
| `lervag/vimtex` | LaTeX editing, compilation, and PDF synchronization | BibTeX, Plain TeX, or TeX file type |

- Arduino targets `arduino:renesas_uno:unor4wifi`.
- TinyGo is optional unless its plugin commands are used.
- VimTeX uses Skim on macOS and Zathura on Ubuntu.
- LaTeX tools and a PDF viewer are required only for LaTeX work.

## Shared Dependencies

| Plugin | Used by |
| --- | --- |
| `nvim-lua/plenary.nvim` | Telescope, TODO Comments, Neovim Project |
| `nvim-telescope/telescope-fzf-native.nvim` | Native Telescope sorting; built with `make` |
| `nvim-telescope/telescope-ui-select.nvim` | Telescope-backed `vim.ui.select` |
| `nvim-tree/nvim-web-devicons` | Telescope icons when Nerd Fonts are enabled |
| `echasnovski/mini.icons` | Oil icons |

## Core Key Mappings

- Leader key: `Space`.

| Mapping | Action |
| --- | --- |
| `<Esc>` | Clear search highlighting |
| `<leader>e` | Show diagnostics for the current location |
| `<leader>q` | Put diagnostics in the location list |
| `<Esc><Esc>` | Exit terminal mode |
| `<C-h/j/k/l>` | Move focus between windows |
| `j`, `k` | Move while keeping the cursor vertically centered |
| `<leader>format` | Re-indent the current paragraph |
| `<leader>ac` | Compile the current Uno R4 WiFi sketch |
| `<leader>au` | Upload the current Uno R4 WiFi sketch |

## File and Project Mappings

| Mapping | Action |
| --- | --- |
| `_` | Open the current directory in floating Oil |
| `-` | Open the parent directory in Oil |
| `<leader>dir` | Open Oil |
| `<leader>n` | Open Oil file explorer |
| `<leader>files` | Open Oil file explorer |
| `<leader>pd` | Discover and select a project |

## Telescope Mappings

| Mapping | Action |
| --- | --- |
| `<leader>sh` | Search help tags |
| `<leader>sk` | Search key mappings |
| `<leader>sf` | Find files |
| `<leader>ss` | Select a Telescope picker |
| `<leader>sw` | Search the word under the cursor |
| `<leader>sg` | Live grep with ripgrep |
| `<leader>sd` | Search diagnostics |
| `<leader>sr` | Resume the previous search |
| `<leader>s.` | Search recently opened files |
| `<leader><leader>` | Search open buffers |
| `<leader>/` | Fuzzy-search the current buffer |
| `<leader>s/` | Live grep open files |
| `<leader>sn` | Search Neovim configuration files |

## LSP Mappings

- These mappings are buffer-local and appear after an LSP client attaches.

| Mapping | Action |
| --- | --- |
| `gd` | Go to definition |
| `gr` | Find references |
| `gI` | Go to implementation |
| `gD` | Go to declaration |
| `K` | Show hover documentation |
| `<leader>D` | Find type definitions |
| `<leader>ds` | Find document symbols |
| `<leader>ws` | Find workspace symbols |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Select a code action |
| `<leader>th` | Toggle inlay hints when supported |

- Clangd commands:
  - `:ClangdSwitchSourceHeader` switches between source and header files.
  - `:ClangdShowSymbolInfo` displays symbol details.

## Completion Mappings

| Mapping | Action |
| --- | --- |
| `<C-n>` | Select next completion item |
| `<C-p>` | Select previous completion item |
| `<Enter>` | Confirm the selected completion item |
| `<C-Space>` | Open completion manually |
| `<C-l>` | Expand a snippet or jump forward |
| `<C-h>` | Jump backward in a snippet |

## Debugger Mappings

| Mapping | Action |
| --- | --- |
| `<F5>` | Start or continue debugging |
| `<F1>` | Step into |
| `<F2>` | Step over |
| `<F3>` | Step out |
| `<F7>` | Toggle the debugger UI |
| `<leader>b` | Toggle a breakpoint |
| `<leader>B` | Set a conditional breakpoint |

## Harpoon Mappings

| Mapping | Action |
| --- | --- |
| `<leader>ha` | Add the current file |
| `<leader>hm` | Toggle the quick menu |
| `<leader>h1` through `<leader>h4` | Open marked file 1 through 4 |
| `<C-s>` | Open the next marked file |
| `<C-a>` | Remove the current file |
| `<C-c>` | Clear all marked files |

## Useful Commands

| Command | Action |
| --- | --- |
| `:Lazy` | Manage plugins |
| `:TSUpdate` | Update Tree-sitter parsers |
| `:ConformInfo` | Inspect formatter availability |
| `:FzfLua` | Open the alternate fuzzy finder |
| `:ZenMode` | Toggle distraction-free editing |
| `:Git` or `:G` | Open Fugitive Git interface |
| `:GBrowse` | Open the current GitHub location |
| `:NeovimProjectDiscover` | Select a configured project |
| `:checkhealth config` | Check required external software |
| `:checkhealth vim.lsp` | Check built-in LSP configuration |

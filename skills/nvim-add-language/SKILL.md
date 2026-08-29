---
name: nvim-add-language
description: Add or update language support in this Neovim configuration, including native LSP setup, cross-platform dependencies, health checks, and documentation. Use when a language server, formatter, debugger, or language runtime is requested.
---

# Add Neovim Language Support

## Preserve These Invariants

- Support Neovim 0.11.5 or newer through `vim.lsp.config()` and `vim.lsp.enable()`.
- Keep language servers and formatters installed at the system or user level and available on `PATH`.
- Do not add Mason.
- Support macOS ARM64, Ubuntu Desktop 24 AMD64, and Omarchy x86_64.
- Preserve every existing language, mapping, completion capability, Arduino integration, and debugging feature unless the user explicitly requests removal.

## Inspect Before Editing

- Read `lua/plugins/lsp.lua`, `lua/config/health.lua`, `check-dependencies.sh`, and `docs/installation.md` completely.
- Inspect related formatter, debugger, file-type, and plugin specifications under `lua/plugins/`.
- Determine whether the language is already covered by an existing server before adding another one.

## Select the Tooling

- Map the requested language to its runtime, language server executable, Neovim server name, file types, project root markers, and optional formatter or debugger.
- Prefer one server when it correctly supports related languages, such as one TypeScript server for JavaScript and TypeScript.
- Verify current installation commands and runtime minimums with official upstream documentation.
- Prefer Homebrew on macOS and native Ubuntu packages when they satisfy the required version.
- Use a pinned, checksum-verified user-local archive under `~/.local` when Ubuntu packages are unavailable or outdated.
- Do not install external software unless the user explicitly authorizes installation.
- Do not add an LSP client plugin when Neovim's built-in client is sufficient.

## Implement the Language Server

- Add the server name to the existing `servers` list in `lua/plugins/lsp.lua`.
- Define its `cmd`, `filetypes`, `root_markers` or `root_dir`, and only settings that provide a clear benefit.
- Keep executables resolved from `PATH`; do not hardcode Homebrew, GVM, or machine-specific paths.
- Give stateful servers, especially JDTLS, a stable and unique cache workspace per project.
- Reuse the shared completion capabilities and `LspAttach` mappings.
- Add file-type detection only when Neovim does not already detect the language correctly.

## Keep Dependencies Reproducible

- Add required runtimes and executables to `check-dependencies.sh` for every supported platform.
- Check minimum runtime versions when the server requires them.
- Print a complete installation command for each missing dependency.
- Add required executables to `lua/config/health.lua`.
- Document the runtime, server, installation commands, file types, root markers, and verification commands in `docs/installation.md`.
- Update `docs/plugins.md` when a formatter, debugger, or plugin changes.

## Validate

- Format Lua with `stylua init.lua lua`.
- Run `bash -n check-dependencies.sh` and `shellcheck` when available.
- Validate `lazy-lock.json` with `jq empty lazy-lock.json`.
- Start Neovim headlessly and assert every configured server exists in `vim.lsp.config` without starting missing executables.
- Run `./check-dependencies.sh` and `:checkhealth config`; report missing software as an expected installation step.
- After executables are installed, open a minimal project for each new language and verify attachment with `:checkhealth vim.lsp` or `:LspInfo`.
- Do not create test files until the user approves tests.

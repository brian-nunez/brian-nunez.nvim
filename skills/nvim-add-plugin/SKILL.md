---
name: nvim-add-plugin
description: Add or update a plugin in this Neovim configuration with appropriate lazy loading, dependencies, mappings, health checks, and documentation. Use when new editor functionality or a specific Neovim plugin is requested.
---

# Add a Neovim Plugin

## Preserve These Invariants

- Keep plugin specifications under `lua/plugins/` and imported through `{ import = 'plugins' }`.
- Keep startup fast through deliberate lazy loading.
- Do not recreate `custom`, `kickstart`, Mason, or NERDTree configuration.
- Preserve existing features, mappings, and plugin behavior unless the user explicitly requests a replacement or removal.
- Support macOS ARM64 and Ubuntu Desktop 24 AMD64 when external software is involved.

## Inspect Before Editing

- Read `init.lua`, the relevant files under `lua/plugins/`, `lazy-lock.json`, `docs/plugins.md`, and `docs/installation.md`.
- Check whether an installed plugin or built-in Neovim feature already provides the requested capability.
- Identify mapping, command, event, file-type, and dependency conflicts before selecting a plugin.
- Verify the plugin's current setup interface and requirements from its official repository or documentation.

## Design the Specification

- Create or update one purpose-oriented file under `lua/plugins/`.
- Use `keys` for mapping-triggered plugins, `cmd` for command-triggered plugins, `ft` for language-specific plugins, and narrow `event` values for buffer workflows.
- Use startup loading only when the feature must exist before normal lazy-loading events.
- Declare supporting plugins through `dependencies` and keep their configuration nested when they are not independently useful.
- Prefer `opts` and `main` when they express the configuration clearly; use `config` for mappings, listeners, or multi-module setup.
- Give every user-facing mapping a useful `desc`.
- Avoid machine-specific paths, unnecessary defaults, speculative options, and duplicate plugins.

## Handle External Requirements

- Keep external executables system-managed and available on `PATH`; do not add Mason.
- Do not install external software unless the user explicitly authorizes installation.
- Add required executables and platform-specific installation commands to `check-dependencies.sh`.
- Add required executables to `lua/config/health.lua`.
- Classify feature-specific tools as optional when the rest of the configuration works without them.

## Keep Documentation and Locking Accurate

- Document the plugin, purpose, load trigger, dependencies, mappings, commands, and external software in `docs/plugins.md`.
- Update `docs/installation.md` when software requirements change.
- Do not invent or manually guess plugin revisions in `lazy-lock.json`.
- Allow Lazy to create or update lock entries only when plugin installation is authorized; otherwise report that the next normal Neovim startup will install the plugin.

## Validate

- Format Lua with `stylua init.lua lua`.
- Parse each changed Lua file with a clean headless Neovim process.
- Validate `lazy-lock.json` with `jq empty lazy-lock.json`.
- Run `bash -n check-dependencies.sh` and `shellcheck` when the dependency checker changes.
- Start the full configuration headlessly when all referenced plugins are already installed.
- Run `./check-dependencies.sh` and `:checkhealth config` when external tools change.
- Confirm that documentation names every active plugin and dependency.
- Do not create test files until the user approves tests.

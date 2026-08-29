# Installation and External Software

## Supported Platforms

| Platform | Architecture | Configuration path |
| --- | --- | --- |
| macOS | Apple Silicon ARM64 | `~/.config/nvim` |
| Ubuntu Desktop 24.04 | AMD64/x86_64 | `~/.config/nvim` |
| Omarchy | x86_64 | `~/.config/nvim` |

## Automated Verification

- Run the read-only dependency checker:

```bash
cd ~/.config/nvim
./check-dependencies.sh
```

- The checker:
  - Detects the supported operating system and architecture.
  - Verifies required executables and minimum Neovim version.
  - Verifies the Arduino CLI configuration and Uno R4 platform core.
  - Verifies Linux serial-port permissions.
  - Reports optional tools used by feature-specific plugins.
  - Prints an installation command for every missing item.
  - Does not install or modify software.

## Required Software

| Software | Used by | Requirement |
| --- | --- | --- |
| Neovim 0.11.5+ | Entire configuration | Required |
| Git | `lazy.nvim`, Fugitive, Rhubarb, project root detection | Required |
| Make | LuaSnip regex module, Telescope FZF native extension | Required |
| C compiler | Tree-sitter parsers and native plugin builds | Required |
| Unzip | Tool and plugin archives | Required |
| ripgrep (`rg`) | Telescope live grep | Required |
| Go | Go tooling and Go-installed language servers | Required |
| Python 3 | Python projects and the JDTLS launcher | Required |
| Node.js 20+ and npm | Pyright, TypeScript/JavaScript, and Bash language servers | Required |
| Java 21+ JDK | Java projects and JDTLS | Required |
| `clangd` | C, C++, and Arduino LSP | Required |
| `gopls` | Go LSP | Required |
| `pyright-langserver` | Python LSP | Required |
| `typescript-language-server` and `tsc` | JavaScript and TypeScript LSP | Required |
| `bash-language-server` | Bash LSP | Required |
| `jdtls` | Java LSP | Required |
| `lua-language-server` | Lua LSP | Required |
| StyLua (`stylua`) | Lua formatting through Conform | Required |
| Arduino CLI | Uno R4 WiFi compile, upload, and LSP integration | Required |
| Arduino language server | Arduino LSP | Required |
| Arduino Renesas Uno core | Uno R4 WiFi compilation and upload | Required |
| Delve (`dlv`) | Go debugging through `nvim-dap-go` | Required |

## macOS ARM64

- Install Apple command-line tools:

```bash
xcode-select --install
```

- Install Homebrew from [brew.sh](https://brew.sh) when `brew` is unavailable.
- Install required Homebrew packages:

```bash
brew install neovim ripgrep go node python lua-language-server stylua arduino-cli jdtls
```

- Install a Java 21 or newer JDK when `java -version` reports an older runtime:

```bash
brew install openjdk@21
printf '\nexport PATH="%s/bin:$PATH"\n' "$(brew --prefix openjdk@21)" >> "$HOME/.zprofile"
```

- Install npm-based language servers:

```bash
npm install -g pyright typescript typescript-language-server bash-language-server
```

- Apple command-line tools normally provide `git`, `make`, `cc`, `unzip`, and `/usr/bin/clangd`.
- Install LLVM only when the Apple-provided `clangd` is unavailable or a newer release is needed:

```bash
brew install llvm
printf '\nexport PATH="%s/bin:$PATH"\n' "$(brew --prefix llvm)" >> "$HOME/.zprofile"
```

- Install Go-based tools:

```bash
go install golang.org/x/tools/gopls@latest
go install github.com/arduino/arduino-language-server@0.7.7
go install github.com/go-delve/delve/cmd/dlv@latest
```

- Ensure the Go binary directory is on `PATH`:

```bash
printf '\nexport PATH="%s/bin:$PATH"\n' "$(go env GOPATH)" >> "$HOME/.zprofile"
```

## Ubuntu Desktop 24.04 AMD64

- Install system packages:

```bash
sudo apt-get update
sudo apt-get install -y bash clangd curl gcc git golang-go make openjdk-21-jdk python3 ripgrep unzip
```

- Install Node.js 22 and npm through Snap so Bash Language Server's Node.js 20 minimum is satisfied:

```bash
sudo snap install node --classic --channel=22
```

- Install npm-based language servers:

```bash
npm install -g pyright typescript typescript-language-server bash-language-server
```

- Ubuntu 24.04 may not provide a sufficiently recent Neovim package.
- Use the exact Neovim installation command printed by `./check-dependencies.sh` when `nvim` is missing or older than 0.11.5.
- Use the exact Lua language server and StyLua commands printed by the checker; they install pinned x86_64 releases under `~/.local`.
- Use the exact JDTLS command printed by the checker; it verifies the Eclipse archive checksum and installs the pinned release under `~/.local`.
- Install the Arduino CLI:

```bash
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR="$HOME/.local/bin" sh -s 1.5.1
```

- Install Go-based tools:

```bash
go install golang.org/x/tools/gopls@latest
go install github.com/arduino/arduino-language-server@0.7.7
go install github.com/go-delve/delve/cmd/dlv@latest
```

- Add local and Go binaries to `PATH`:

```bash
printf '\nexport PATH="$HOME/.local/bin:%s/bin:$PATH"\n' "$(go env GOPATH)" >> "$HOME/.bashrc"
```

- Grant Arduino serial-port access, then log out and back in:

```bash
sudo usermod -aG dialout "$USER"
```

## Omarchy x86_64

- Omarchy is Arch-based and uses `pacman`.
- Perform a full system upgrade while installing required repository packages:

```bash
sudo pacman -Syu --needed \
  arduino-cli arduino-language-server bash bash-language-server clang curl \
  delve gcc git go gopls jdk21-openjdk lua-language-server make neovim \
  nodejs npm pyright python ripgrep stylua typescript \
  typescript-language-server unzip
```

- Select Java 21 when another installed JDK is the current default:

```bash
sudo archlinux-java set java-21-openjdk
```

- JDTLS is not currently available from the official Arch package repository.
- Run `./check-dependencies.sh` and use its checksum-verified JDTLS installation command.
- Add local and Go binaries to `PATH`:

```bash
printf '\nexport PATH="$HOME/.local/bin:%s/bin:$PATH"\n' "$(go env GOPATH)" >> "$HOME/.bashrc"
```

- Grant Arduino serial-port access, then log out and back in:

```bash
sudo usermod -aG uucp "$USER"
```

- Omarchy may report `ID=omarchy` or inherit `ID=arch` from its Arch base.
- The checker recognizes either form when Omarchy installation directories are present.

## Arduino Uno R4 WiFi

- Create the Arduino CLI configuration:

```bash
arduino-cli config init
```

- Install the Uno R4 platform core:

```bash
arduino-cli core update-index
arduino-cli core install arduino:renesas_uno
```

- The configured fully qualified board name is:

```text
arduino:renesas_uno:unor4wifi
```

- Compile the current sketch with `<leader>ac`.
- Upload with `<leader>au`.
- Set `ARDUINO_PORT` when automatic port detection is insufficient:

```bash
export ARDUINO_PORT=/dev/cu.usbmodem1101
```

## Optional Feature Software

| Software | Feature | macOS ARM64 | Ubuntu 24.04 AMD64 | Omarchy x86_64 |
| --- | --- | --- | --- | --- |
| Nerd Font | Plugin and status-line icons | Install a font from [Nerd Fonts](https://www.nerdfonts.com/) | Install a font from [Nerd Fonts](https://www.nerdfonts.com/) | Use an installed Omarchy Nerd Font |
| TinyGo | `tinygo.nvim` embedded Go commands | `brew install tinygo` | Follow [TinyGo Linux installation](https://tinygo.org/getting-started/install/linux/) | `sudo pacman -Syu --needed tinygo` |
| `latexmk` | VimTeX compilation | `brew install --cask mactex-no-gui` | `sudo apt-get install -y latexmk texlive` | `sudo pacman -Syu --needed texlive-binextra texlive-latexextra` |
| PDF viewer | VimTeX preview and synchronization | `brew install --cask skim` | `sudo apt-get install -y zathura` | `sudo pacman -Syu --needed zathura zathura-pdf-mupdf` |
| Wayland clipboard | System clipboard | Built into macOS | `sudo apt-get install -y wl-clipboard` | `sudo pacman -Syu --needed wl-clipboard` |
| `templ` | Formatting `.templ` files through Conform | `go install github.com/a-h/templ/cmd/templ@latest` | Same command | Same command |
| Discord desktop | Rich presence through `presence.nvim` | Install Discord when desired | Install Discord when desired | Use the Omarchy application installer when desired |

## Language Servers

| Neovim server name | Executable | File types | Root markers |
| --- | --- | --- | --- |
| `arduino_language_server` | `arduino-language-server` | Arduino `.ino`, `.pde` | Sketch file directory |
| `bashls` | `bash-language-server` | Bash and POSIX shell | Git root |
| `clangd` | `clangd` | C, C++, Objective-C, CUDA, Proto | Clang config, compile database, or Git root |
| `gopls` | `gopls` | Go, Go modules, Go workspaces, Go templates | `go.work`, `go.mod`, or Git root |
| `jdtls` | `jdtls` | Java | Gradle, Maven, or Git root |
| `lua_ls` | `lua-language-server` | Lua | Lua config files or Git root |
| `pyright` | `pyright-langserver` | Python | Pyright, Python project, dependency, or Git files |
| `ts_ls` | `typescript-language-server` | JavaScript, JSX, TypeScript, TSX | TypeScript, JavaScript, npm, or Git files |

- LSPs are configured with `vim.lsp.config()` and enabled with `vim.lsp.enable()`.
- JDTLS receives a unique cache workspace for each Java project.
- Mason is intentionally not installed.
- Diagnose LSP state with:

```vim
:checkhealth vim.lsp
:LspInfo
```

## Health and Troubleshooting

- Verify configuration dependencies:

```vim
:checkhealth config
```

- Verify shell resolution before opening Neovim:

```bash
command -v nvim rg go python3 node npm java javac clangd gopls pyright-langserver typescript-language-server tsc bash-language-server jdtls lua-language-server stylua arduino-cli arduino-language-server dlv
```

- Restart the terminal after changing shell startup files.
- On Ubuntu, log out and back in after adding the user to `dialout`.
- On Omarchy, log out and back in after adding the user to `uucp`.
- On macOS, place Homebrew and Go paths in `~/.zprofile` so GUI-launched and login-shell Neovim sessions resolve the same tools.

## Upstream Installation References

- [Pyright installation](https://github.com/microsoft/pyright/blob/main/docs/installation.md)
- [TypeScript Language Server installation](https://github.com/typescript-language-server/typescript-language-server)
- [Bash Language Server installation](https://github.com/bash-lsp/bash-language-server)
- [Eclipse JDTLS requirements and installation](https://github.com/eclipse-jdtls/eclipse.jdt.ls)
- [Omarchy](https://github.com/basecamp/omarchy)
- [Arch Linux packages](https://archlinux.org/packages/)

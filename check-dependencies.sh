#!/usr/bin/env bash

set -u
set -o pipefail

readonly MINIMUM_NVIM_VERSION='0.11.5'
readonly MINIMUM_NODE_VERSION='20.0.0'
readonly MINIMUM_JAVA_VERSION='21'
readonly ARDUINO_CLI_VERSION='1.5.1'
readonly ARDUINO_LS_VERSION='0.7.7'
readonly JDTLS_VERSION='1.60.0'
readonly JDTLS_ARCHIVE='jdt-language-server-1.60.0-202606262232.tar.gz'
readonly JDTLS_SHA256='e94c303d8198f977930803582738771fd18c52c5492878410bf222b1aa81ef1d'
readonly LUA_LS_VERSION='3.18.2'
readonly STYLUA_VERSION='2.5.2'
readonly ARDUINO_CORE='arduino:renesas_uno'

required_missing=0
optional_missing=0

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  readonly GREEN=$'\033[32m'
  readonly YELLOW=$'\033[33m'
  readonly RED=$'\033[31m'
  readonly BOLD=$'\033[1m'
  readonly RESET=$'\033[0m'
else
  readonly GREEN=''
  readonly YELLOW=''
  readonly RED=''
  readonly BOLD=''
  readonly RESET=''
fi

print_header() {
  printf '\n%s%s%s\n' "$BOLD" "$1" "$RESET"
}

print_install() {
  printf '  %sInstall:%s %s\n' "$YELLOW" "$RESET" "$1"
}

check_required() {
  local executable=$1
  local label=$2
  local install_command=$3
  local resolved_path

  resolved_path=$(command -v "$executable" 2>/dev/null || true)
  if [[ -n "$resolved_path" ]]; then
    printf '%s[ok]%s %-28s %s\n' "$GREEN" "$RESET" "$label" "$resolved_path"
    return 0
  fi

  printf '%s[missing]%s %s is required.\n' "$RED" "$RESET" "$label"
  print_install "$install_command"
  required_missing=$((required_missing + 1))
  return 1
}

check_optional() {
  local executable=$1
  local label=$2
  local install_command=$3
  local resolved_path

  resolved_path=$(command -v "$executable" 2>/dev/null || true)
  if [[ -n "$resolved_path" ]]; then
    printf '%s[ok]%s %-28s %s\n' "$GREEN" "$RESET" "$label" "$resolved_path"
    return 0
  fi

  printf '%s[optional]%s %s is not installed.\n' "$YELLOW" "$RESET" "$label"
  print_install "$install_command"
  optional_missing=$((optional_missing + 1))
  return 0
}

check_optional_macos_app() {
  local app_name=$1
  local label=$2
  local install_command=$3
  local system_path="/Applications/$app_name.app"
  local user_path="$HOME/Applications/$app_name.app"

  if [[ -d "$system_path" ]]; then
    printf '%s[ok]%s %-28s %s\n' "$GREEN" "$RESET" "$label" "$system_path"
    return
  fi

  if [[ -d "$user_path" ]]; then
    printf '%s[ok]%s %-28s %s\n' "$GREEN" "$RESET" "$label" "$user_path"
    return
  fi

  printf '%s[optional]%s %s is not installed.\n' "$YELLOW" "$RESET" "$label"
  print_install "$install_command"
  optional_missing=$((optional_missing + 1))
}

version_at_least() {
  local actual=$1
  local required=$2
  local actual_major actual_minor actual_patch
  local required_major required_minor required_patch

  IFS=. read -r actual_major actual_minor actual_patch <<< "$actual"
  IFS=. read -r required_major required_minor required_patch <<< "$required"

  actual_patch=${actual_patch%%[^0-9]*}
  required_patch=${required_patch%%[^0-9]*}
  actual_patch=${actual_patch:-0}
  required_patch=${required_patch:-0}

  if (( actual_major != required_major )); then
    (( actual_major > required_major ))
  elif (( actual_minor != required_minor )); then
    (( actual_minor > required_minor ))
  else
    (( actual_patch >= required_patch ))
  fi
}

check_neovim() {
  local install_command=$1
  local resolved_path version

  resolved_path=$(command -v nvim 2>/dev/null || true)
  if [[ -z "$resolved_path" ]]; then
    printf '%s[missing]%s Neovim %s or newer is required.\n' "$RED" "$RESET" "$MINIMUM_NVIM_VERSION"
    print_install "$install_command"
    required_missing=$((required_missing + 1))
    return
  fi

  version=$(nvim --version | awk 'NR == 1 { sub(/^v/, "", $2); print $2 }')
  if version_at_least "$version" "$MINIMUM_NVIM_VERSION"; then
    printf '%s[ok]%s %-28s %s (%s)\n' "$GREEN" "$RESET" 'Neovim' "$resolved_path" "$version"
    return
  fi

  printf '%s[outdated]%s Neovim %s is installed; %s or newer is required.\n' "$RED" "$RESET" "$version" "$MINIMUM_NVIM_VERSION"
  print_install "$install_command"
  required_missing=$((required_missing + 1))
}

check_node() {
  local install_command=$1
  local resolved_path version

  resolved_path=$(command -v node 2>/dev/null || true)
  if [[ -z "$resolved_path" ]]; then
    printf '%s[missing]%s Node.js %s or newer is required.\n' "$RED" "$RESET" "$MINIMUM_NODE_VERSION"
    print_install "$install_command"
    required_missing=$((required_missing + 1))
    return
  fi

  version=$(node --version 2>/dev/null)
  version=${version#v}
  if version_at_least "$version" "$MINIMUM_NODE_VERSION"; then
    printf '%s[ok]%s %-28s %s (%s)\n' "$GREEN" "$RESET" 'Node.js' "$resolved_path" "$version"
    return
  fi

  printf '%s[outdated]%s Node.js %s is installed; %s or newer is required.\n' "$RED" "$RESET" "$version" "$MINIMUM_NODE_VERSION"
  print_install "$install_command"
  required_missing=$((required_missing + 1))
}

check_java() {
  local install_command=$1
  local resolved_path version major

  resolved_path=$(command -v java 2>/dev/null || true)
  if [[ -z "$resolved_path" ]]; then
    printf '%s[missing]%s Java %s or newer is required.\n' "$RED" "$RESET" "$MINIMUM_JAVA_VERSION"
    print_install "$install_command"
    required_missing=$((required_missing + 1))
    return
  fi

  version=$(java -version 2>&1 | awk -F'"' 'NR == 1 { print $2 }')
  major=${version%%.*}
  if [[ "$major" == '1' ]]; then
    major=${version#*.}
    major=${major%%.*}
  fi

  if [[ "$major" =~ ^[0-9]+$ ]] && (( major >= MINIMUM_JAVA_VERSION )); then
    printf '%s[ok]%s %-28s %s (%s)\n' "$GREEN" "$RESET" 'Java runtime' "$resolved_path" "$version"
    return
  fi

  printf '%s[outdated]%s Java %s is installed; Java %s or newer is required.\n' "$RED" "$RESET" "${version:-unknown}" "$MINIMUM_JAVA_VERSION"
  print_install "$install_command"
  required_missing=$((required_missing + 1))
}

is_omarchy() {
  [[ "${ID:-}" == 'omarchy' ]] || {
    [[ "${ID:-}" == 'arch' ]] &&
      [[ -d /usr/share/omarchy || -d "$HOME/.local/share/omarchy" || -d "$HOME/.config/omarchy" ]]
  }
}

detect_platform() {
  local kernel architecture

  kernel=$(uname -s)
  architecture=$(uname -m)

  case "$kernel:$architecture" in
    Darwin:arm64)
      platform='macos-arm64'
      platform_name='macOS ARM64'
      ;;
    Linux:x86_64)
      if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
      fi
      if is_omarchy; then
        platform='omarchy-x86_64'
        platform_name='Omarchy x86_64'
      elif [[ "${ID:-}" == 'ubuntu' && "${VERSION_ID:-}" == 24.* ]]; then
        platform='ubuntu24-amd64'
        platform_name="${PRETTY_NAME:-Ubuntu 24} AMD64"
      else
        printf '%s[unsupported]%s Supported Linux platforms are Ubuntu Desktop 24 AMD64 and Omarchy x86_64; detected %s %s.\n' "$RED" "$RESET" "${PRETTY_NAME:-Linux}" "$architecture"
        exit 2
      fi
      ;;
    *)
      printf '%s[unsupported]%s Supported platforms are macOS ARM64, Ubuntu Desktop 24 AMD64, and Omarchy x86_64; detected %s %s.\n' "$RED" "$RESET" "$kernel" "$architecture"
      exit 2
      ;;
  esac
}

check_path_directory() {
  local directory=$1
  local shell_file=$2

  case ":$PATH:" in
    *":$directory:"*) ;;
    *)
      printf '%s[warning]%s %s is not on PATH.\n' "$YELLOW" "$RESET" "$directory"
      print_install "printf '\\nexport PATH=\"$directory:\$PATH\"\\n' >> \"$shell_file\""
      ;;
  esac
}

check_arduino() {
  local config_file=$1

  if ! command -v arduino-cli >/dev/null 2>&1; then
    return
  fi

  if [[ -f "$config_file" ]]; then
    printf '%s[ok]%s %-28s %s\n' "$GREEN" "$RESET" 'Arduino CLI configuration' "$config_file"
  else
    printf '%s[missing]%s Arduino CLI configuration is required at %s.\n' "$RED" "$RESET" "$config_file"
    print_install 'arduino-cli config init'
    required_missing=$((required_missing + 1))
  fi

  if arduino-cli core list 2>/dev/null | awk -v core="$ARDUINO_CORE" '$1 == core { found = 1 } END { exit !found }'; then
    printf '%s[ok]%s %-28s %s\n' "$GREEN" "$RESET" 'Arduino Uno R4 core' "$ARDUINO_CORE"
  else
    printf '%s[missing]%s The Arduino Uno R4 core is required.\n' "$RED" "$RESET"
    print_install "arduino-cli core update-index && arduino-cli core install $ARDUINO_CORE"
    required_missing=$((required_missing + 1))
  fi
}

check_linux_serial_group() {
  local group=$1
  local install_command=$2

  if id -nG | tr ' ' '\n' | grep -qx "$group"; then
    printf '%s[ok]%s %-28s %s\n' "$GREEN" "$RESET" 'Arduino serial permissions' "$group"
    return
  fi

  printf '%s[missing]%s Membership in the %s group is required for Arduino uploads.\n' "$RED" "$RESET" "$group"
  print_install "$install_command"
  required_missing=$((required_missing + 1))
}

check_macos() {
  local go_bin

  print_header 'Core tools'
  check_required brew 'Homebrew' 'Install Homebrew from https://brew.sh' || true
  check_neovim 'brew install neovim'
  check_required git 'Git' 'xcode-select --install' || true
  check_required make 'Make' 'xcode-select --install' || true
  check_required cc 'C compiler' 'xcode-select --install' || true
  check_required unzip 'Unzip' 'xcode-select --install' || true
  check_required rg 'ripgrep' 'brew install ripgrep' || true
  check_required go 'Go' 'brew install go' || true
  check_required python3 'Python 3' 'brew install python' || true
  check_required bash 'Bash' 'brew install bash' || true
  check_node 'brew install node'
  check_required npm 'npm' 'brew install node' || true
  check_java 'brew install openjdk@21 && printf '\''\nexport PATH="%s/bin:$PATH"\n'\'' "$(brew --prefix openjdk@21)" >> "$HOME/.zprofile"'
  check_required javac 'Java compiler' 'brew install openjdk@21' || true

  if command -v go >/dev/null 2>&1; then
    go_bin=$(go env GOBIN 2>/dev/null || true)
    if [[ -z "$go_bin" ]]; then
      go_bin="$(go env GOPATH)/bin"
    fi
    check_path_directory "$go_bin" "$HOME/.zprofile"
  fi

  print_header 'Language servers and formatter'
  check_required clangd 'clangd' 'brew install llvm && printf '\''\nexport PATH="%s/bin:$PATH"\n'\'' "$(brew --prefix llvm)" >> "$HOME/.zprofile"' || true
  check_required gopls 'gopls' 'go install golang.org/x/tools/gopls@latest' || true
  check_required lua-language-server 'lua-language-server' 'brew install lua-language-server' || true
  check_required stylua 'StyLua' 'brew install stylua' || true
  check_required arduino-cli 'Arduino CLI' 'brew install arduino-cli' || true
  check_required arduino-language-server 'Arduino language server' "go install github.com/arduino/arduino-language-server@$ARDUINO_LS_VERSION" || true
  check_required dlv 'Delve debugger' 'go install github.com/go-delve/delve/cmd/dlv@latest' || true
  check_required pyright-langserver 'Pyright language server' 'npm install -g pyright' || true
  check_required typescript-language-server 'TypeScript/JavaScript server' 'npm install -g typescript-language-server typescript' || true
  check_required tsc 'TypeScript compiler' 'npm install -g typescript' || true
  check_required bash-language-server 'Bash language server' 'npm install -g bash-language-server' || true
  check_required jdtls 'Java language server' 'brew install jdtls' || true

  check_arduino "$HOME/Library/Arduino15/arduino-cli.yaml"

  print_header 'Optional plugin tools'
  check_optional tinygo 'TinyGo' 'brew install tinygo'
  check_optional templ 'templ formatter' 'go install github.com/a-h/templ/cmd/templ@latest'
  check_optional latexmk 'LaTeX compiler' 'brew install --cask mactex-no-gui'
  check_optional_macos_app 'Skim' 'Skim PDF viewer' 'brew install --cask skim'
}

check_ubuntu() {
  local go_bin jdtls_install luals_install nvim_install stylua_install

  nvim_install='archive="$(mktemp)" && mkdir -p "$HOME/.local/opt" "$HOME/.local/bin" && curl -fL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz -o "$archive" && tar -xzf "$archive" -C "$HOME/.local/opt" && ln -sfn "$HOME/.local/opt/nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin/nvim" && rm -f "$archive"'
  luals_install="archive=\"\$(mktemp)\" && mkdir -p \"\$HOME/.local/opt/lua-language-server\" \"\$HOME/.local/bin\" && curl -fL https://github.com/LuaLS/lua-language-server/releases/download/$LUA_LS_VERSION/lua-language-server-$LUA_LS_VERSION-linux-x64.tar.gz -o \"\$archive\" && tar -xzf \"\$archive\" -C \"\$HOME/.local/opt/lua-language-server\" && printf '#!/bin/sh\\nexec \"%s/bin/lua-language-server\" \"\$@\"\\n' \"\$HOME/.local/opt/lua-language-server\" > \"\$HOME/.local/bin/lua-language-server\" && chmod 0755 \"\$HOME/.local/bin/lua-language-server\" && rm -f \"\$archive\""
  stylua_install="archive=\"\$(mktemp)\" && temp_dir=\"\$(mktemp -d)\" && mkdir -p \"\$HOME/.local/bin\" && curl -fL https://github.com/JohnnyMorganz/StyLua/releases/download/v$STYLUA_VERSION/stylua-linux-x86_64.zip -o \"\$archive\" && unzip -q \"\$archive\" -d \"\$temp_dir\" && install -m 0755 \"\$temp_dir/stylua\" \"\$HOME/.local/bin/stylua\" && rm -f \"\$archive\" && rm -rf \"\$temp_dir\""
  jdtls_install="archive=\"\$(mktemp)\" && temp_dir=\"\$(mktemp -d)\" && install_dir=\"\$HOME/.local/opt/jdtls-$JDTLS_VERSION\" && mkdir -p \"\$HOME/.local/opt\" \"\$HOME/.local/bin\" && curl -fL https://download.eclipse.org/jdtls/milestones/$JDTLS_VERSION/$JDTLS_ARCHIVE -o \"\$archive\" && printf '$JDTLS_SHA256  %s\\n' \"\$archive\" | sha256sum -c - && tar -xzf \"\$archive\" -C \"\$temp_dir\" && rm -rf \"\$install_dir\" && mv \"\$temp_dir\" \"\$install_dir\" && ln -sfn \"\$install_dir/bin/jdtls\" \"\$HOME/.local/bin/jdtls\" && rm -f \"\$archive\""

  print_header 'Core tools'
  check_neovim "$nvim_install"
  check_required git 'Git' 'sudo apt-get update && sudo apt-get install -y git' || true
  check_required make 'Make' 'sudo apt-get update && sudo apt-get install -y make' || true
  check_required cc 'C compiler' 'sudo apt-get update && sudo apt-get install -y gcc' || true
  check_required unzip 'Unzip' 'sudo apt-get update && sudo apt-get install -y unzip' || true
  check_required curl 'curl' 'sudo apt-get update && sudo apt-get install -y curl' || true
  check_required rg 'ripgrep' 'sudo apt-get update && sudo apt-get install -y ripgrep' || true
  check_required go 'Go' 'sudo apt-get update && sudo apt-get install -y golang-go' || true
  check_required python3 'Python 3' 'sudo apt-get update && sudo apt-get install -y python3' || true
  check_required bash 'Bash' 'sudo apt-get update && sudo apt-get install -y bash' || true
  check_node 'sudo snap install node --classic --channel=22'
  check_required npm 'npm' 'sudo snap install node --classic --channel=22' || true
  check_java 'sudo apt-get update && sudo apt-get install -y openjdk-21-jdk'
  check_required javac 'Java compiler' 'sudo apt-get update && sudo apt-get install -y openjdk-21-jdk' || true
  check_path_directory "$HOME/.local/bin" "$HOME/.bashrc"

  if command -v go >/dev/null 2>&1; then
    go_bin=$(go env GOBIN 2>/dev/null || true)
    if [[ -z "$go_bin" ]]; then
      go_bin="$(go env GOPATH)/bin"
    fi
    check_path_directory "$go_bin" "$HOME/.bashrc"
  fi

  print_header 'Language servers and formatter'
  check_required clangd 'clangd' 'sudo apt-get update && sudo apt-get install -y clangd' || true
  check_required gopls 'gopls' 'go install golang.org/x/tools/gopls@latest' || true
  check_required lua-language-server 'lua-language-server' "$luals_install" || true
  check_required stylua 'StyLua' "$stylua_install" || true
  check_required arduino-cli 'Arduino CLI' "curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=\"\$HOME/.local/bin\" sh -s $ARDUINO_CLI_VERSION" || true
  check_required arduino-language-server 'Arduino language server' "go install github.com/arduino/arduino-language-server@$ARDUINO_LS_VERSION" || true
  check_required dlv 'Delve debugger' 'go install github.com/go-delve/delve/cmd/dlv@latest' || true
  check_required pyright-langserver 'Pyright language server' 'npm install -g pyright' || true
  check_required typescript-language-server 'TypeScript/JavaScript server' 'npm install -g typescript-language-server typescript' || true
  check_required tsc 'TypeScript compiler' 'npm install -g typescript' || true
  check_required bash-language-server 'Bash language server' 'npm install -g bash-language-server' || true
  check_required jdtls 'Java language server' "$jdtls_install" || true

  check_arduino "$HOME/.arduino15/arduino-cli.yaml"
  check_linux_serial_group 'dialout' 'sudo usermod -aG dialout "$USER" && printf "Log out and back in to apply the new group.\\n"'

  print_header 'Optional plugin tools'
  check_optional wl-copy 'Wayland clipboard' 'sudo apt-get update && sudo apt-get install -y wl-clipboard'
  check_optional tinygo 'TinyGo' 'See https://tinygo.org/getting-started/install/linux/'
  check_optional templ 'templ formatter' 'go install github.com/a-h/templ/cmd/templ@latest'
  check_optional latexmk 'LaTeX compiler' 'sudo apt-get update && sudo apt-get install -y latexmk texlive'
  check_optional zathura 'Zathura PDF viewer' 'sudo apt-get update && sudo apt-get install -y zathura'
}

check_omarchy() {
  local go_bin jdtls_install

  jdtls_install="archive=\"\$(mktemp)\" && temp_dir=\"\$(mktemp -d)\" && install_dir=\"\$HOME/.local/opt/jdtls-$JDTLS_VERSION\" && mkdir -p \"\$HOME/.local/opt\" \"\$HOME/.local/bin\" && curl -fL https://download.eclipse.org/jdtls/milestones/$JDTLS_VERSION/$JDTLS_ARCHIVE -o \"\$archive\" && printf '$JDTLS_SHA256  %s\\n' \"\$archive\" | sha256sum -c - && tar -xzf \"\$archive\" -C \"\$temp_dir\" && rm -rf \"\$install_dir\" && mv \"\$temp_dir\" \"\$install_dir\" && ln -sfn \"\$install_dir/bin/jdtls\" \"\$HOME/.local/bin/jdtls\" && rm -f \"\$archive\""

  print_header 'Core tools'
  check_required pacman 'pacman' 'Omarchy requires pacman; repair the base system before continuing' || true
  check_neovim 'sudo pacman -Syu --needed neovim'
  check_required git 'Git' 'sudo pacman -Syu --needed git' || true
  check_required make 'Make' 'sudo pacman -Syu --needed make' || true
  check_required cc 'C compiler' 'sudo pacman -Syu --needed gcc' || true
  check_required unzip 'Unzip' 'sudo pacman -Syu --needed unzip' || true
  check_required curl 'curl' 'sudo pacman -Syu --needed curl' || true
  check_required rg 'ripgrep' 'sudo pacman -Syu --needed ripgrep' || true
  check_required go 'Go' 'sudo pacman -Syu --needed go' || true
  check_required python3 'Python 3' 'sudo pacman -Syu --needed python' || true
  check_required bash 'Bash' 'sudo pacman -Syu --needed bash' || true
  check_node 'sudo pacman -Syu --needed nodejs npm'
  check_required npm 'npm' 'sudo pacman -Syu --needed npm' || true
  check_java 'sudo pacman -Syu --needed jdk21-openjdk && sudo archlinux-java set java-21-openjdk'
  check_required javac 'Java compiler' 'sudo pacman -Syu --needed jdk21-openjdk' || true
  check_path_directory "$HOME/.local/bin" "$HOME/.bashrc"

  if command -v go >/dev/null 2>&1; then
    go_bin=$(go env GOBIN 2>/dev/null || true)
    if [[ -z "$go_bin" ]]; then
      go_bin="$(go env GOPATH)/bin"
    fi
    check_path_directory "$go_bin" "$HOME/.bashrc"
  fi

  print_header 'Language servers and formatter'
  check_required clangd 'clangd' 'sudo pacman -Syu --needed clang' || true
  check_required gopls 'gopls' 'sudo pacman -Syu --needed gopls' || true
  check_required lua-language-server 'lua-language-server' 'sudo pacman -Syu --needed lua-language-server' || true
  check_required stylua 'StyLua' 'sudo pacman -Syu --needed stylua' || true
  check_required arduino-cli 'Arduino CLI' 'sudo pacman -Syu --needed arduino-cli' || true
  check_required arduino-language-server 'Arduino language server' 'sudo pacman -Syu --needed arduino-language-server' || true
  check_required dlv 'Delve debugger' 'sudo pacman -Syu --needed delve' || true
  check_required pyright-langserver 'Pyright language server' 'sudo pacman -Syu --needed pyright' || true
  check_required typescript-language-server 'TypeScript/JavaScript server' 'sudo pacman -Syu --needed typescript-language-server' || true
  check_required tsc 'TypeScript compiler' 'sudo pacman -Syu --needed typescript' || true
  check_required bash-language-server 'Bash language server' 'sudo pacman -Syu --needed bash-language-server' || true
  check_required jdtls 'Java language server' "$jdtls_install" || true

  check_arduino "$HOME/.arduino15/arduino-cli.yaml"
  check_linux_serial_group 'uucp' 'sudo usermod -aG uucp "$USER" && printf "Log out and back in to apply the new group.\\n"'

  print_header 'Optional plugin tools'
  check_optional wl-copy 'Wayland clipboard' 'sudo pacman -Syu --needed wl-clipboard'
  check_optional tinygo 'TinyGo' 'sudo pacman -Syu --needed tinygo'
  check_optional templ 'templ formatter' 'go install github.com/a-h/templ/cmd/templ@latest'
  check_optional latexmk 'LaTeX compiler' 'sudo pacman -Syu --needed texlive-binextra texlive-latexextra'
  check_optional zathura 'Zathura PDF viewer' 'sudo pacman -Syu --needed zathura zathura-pdf-mupdf'
}

detect_platform
printf '%sNeovim dependency check%s\n' "$BOLD" "$RESET"
printf 'Platform: %s\n' "$platform_name"

case "$platform" in
  macos-arm64) check_macos ;;
  ubuntu24-amd64) check_ubuntu ;;
  omarchy-x86_64) check_omarchy ;;
esac

print_header 'Summary'
if (( required_missing == 0 )); then
  printf '%sAll required dependencies are installed.%s\n' "$GREEN" "$RESET"
else
  printf '%s%d required dependency check(s) failed.%s\n' "$RED" "$required_missing" "$RESET"
fi

if (( optional_missing > 0 )); then
  printf '%d optional plugin tool(s) are not installed.\n' "$optional_missing"
fi

exit "$required_missing"

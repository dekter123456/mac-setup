#!/bin/bash

# ============================================================
#   Mac Setup Script — One script to set up everything
#   Run: bash mac-setup.sh
# ============================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log()     { echo -e "${GREEN}[✔]${NC} $1"; }
info()    { echo -e "${BLUE}[→]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✘]${NC} $1"; }
section() { echo -e "\n${BLUE}══════════════════════════════════════${NC}"; echo -e "${BLUE}  $1${NC}"; echo -e "${BLUE}══════════════════════════════════════${NC}"; }

install_formula() {
  local pkg=$1
  if brew list "$pkg" &>/dev/null; then
    info "Upgrading $pkg to latest..."
    if brew upgrade "$pkg" 2>/dev/null; then
      log "$pkg upgraded"
    else
      log "$pkg already at latest version"
    fi
  else
    info "Installing $pkg..."
    if brew install "$pkg"; then
      log "$pkg installed"
    else
      error "$pkg failed to install"
    fi
  fi
}

install_cask() {
  local app=$1
  local label=${2:-$1}
  if brew list --cask "$app" &>/dev/null; then
    info "Upgrading $label to latest..."
    if brew upgrade --cask "$app" 2>/dev/null; then
      log "$label upgraded"
    else
      log "$label already at latest version"
    fi
  else
    info "Installing $label..."
    if brew install --cask "$app"; then
      log "$label installed"
    else
      error "$label failed to install"
    fi
  fi
}

# ── Welcome ───────────────────────────────────────────────────
clear
echo -e "${BLUE}"
echo "  ╔═══════════════════════════════════════╗"
echo "  ║       Mac Setup — New Machine         ║"
echo "  ║   Installs all apps & dev tools       ║"
echo "  ╚═══════════════════════════════════════╝"
echo -e "${NC}"
echo "This script will install:"
echo "  Apps   → VS Code, Claude, Chrome, Line, Figma, Notion, Spotify, Fork, iTerm2, Postman, DBeaver, Docker"
echo "  Langs  → Java (latest), Node (latest), Go (latest), Python (latest)"
echo "  CLI    → Git, AWS CLI, Kubectl"
echo ""
read -p "Press ENTER to start, or Ctrl+C to cancel..."

# ── Xcode Command Line Tools ──────────────────────────────────
section "Step 1 — Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools (a popup may appear)..."
  xcode-select --install
  echo ""
  warn "If a popup appeared, click 'Install' then wait for it to finish."
  read -p "Press ENTER once Xcode CLT installation is complete..."
else
  log "Xcode CLT already installed"
fi

# ── Homebrew ──────────────────────────────────────────────────
section "Step 2 — Homebrew (Package Manager)"
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for Apple Silicon
  if [[ $(uname -m) == "arm64" ]]; then
    echo '' >> ~/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  log "Homebrew installed"
else
  log "Homebrew already installed"
fi
info "Updating Homebrew formulae..."
brew update

# ── CLI Tools & Languages ─────────────────────────────────────
section "Step 3 — CLI Tools & Languages"

# Git
install_formula "git"

# Node (latest)
install_formula "node"

# Go (latest)
install_formula "go"

# Python (latest)
install_formula "python"

# Java (latest via Temurin — most popular OpenJDK distro)
install_cask "temurin" "Java (Temurin OpenJDK)"

# AWS CLI
install_formula "awscli"

# Kubectl
install_formula "kubectl"

# ── Desktop Apps ──────────────────────────────────────────────
section "Step 4 — Desktop Apps"

install_cask "visual-studio-code"  "VS Code"
install_cask "claude"              "Claude"
install_cask "google-chrome"       "Chrome"
install_cask "discord"             "Discord"
install_cask "figma"               "Figma"
install_cask "notion"              "Notion"
install_cask "spotify"             "Spotify"
install_cask "iterm2"              "iTerm2"
install_cask "postman"             "Postman"
install_cask "fork"                "Fork (Git GUI)"
install_cask "dbeaver-community"   "DBeaver"
install_cask "docker"              "Docker Desktop"

# ── VS Code Extensions ────────────────────────────────────────
section "Step 5 — VS Code Extensions"

install_vscode_ext() {
  local ext=$1
  local label=$2
  if code --list-extensions 2>/dev/null | grep -qi "^${ext}$"; then
    log "$label already installed"
  else
    info "Installing $label..."
    if code --install-extension "$ext" --force &>/dev/null; then
      log "$label installed"
    else
      error "$label failed to install"
    fi
  fi
}

if ! command -v code &>/dev/null; then
  warn "VS Code 'code' command not found. Open VS Code → Cmd+Shift+P → 'Shell Command: Install code in PATH', then re-run this script."
else
  # ── AI Assistants ──
  install_vscode_ext "saoudrizwan.claude-dev"              "Cline (Claude AI Coding Agent)"
  install_vscode_ext "GitHub.copilot"                      "GitHub Copilot"
  install_vscode_ext "GitHub.copilot-chat"                 "GitHub Copilot Chat"

  # ── Languages ──
  install_vscode_ext "golang.go"                           "Go"
  install_vscode_ext "ms-python.python"                    "Python"
  install_vscode_ext "ms-python.vscode-pylance"            "Pylance (Python type checking)"
  install_vscode_ext "ms-python.black-formatter"           "Black (Python formatter)"
  install_vscode_ext "vscjava.vscode-java-pack"            "Java Extension Pack"
  install_vscode_ext "dbaeumer.vscode-eslint"              "ESLint (JavaScript/TypeScript)"
  install_vscode_ext "esbenp.prettier-vscode"              "Prettier (code formatter)"

  # ── React / JavaScript / TypeScript ──
  install_vscode_ext "dsznajder.es7-react-js-snippets"     "ES7+ React/Redux Snippets"
  install_vscode_ext "ms-vscode.vscode-typescript-next"    "TypeScript Nightly (latest TS features)"
  install_vscode_ext "bradlc.vscode-tailwindcss"           "Tailwind CSS IntelliSense"
  install_vscode_ext "styled-components.vscode-styled-components" "Styled Components"
  install_vscode_ext "wix.vscode-import-cost"              "Import Cost (shows bundle size)"
  install_vscode_ext "Zignd.html-css-class-completion"     "CSS Class IntelliSense"
  install_vscode_ext "formulahendry.auto-close-tag"        "Auto Close Tag"

  # ── DevOps & Cloud ──
  install_vscode_ext "ms-azuretools.vscode-docker"         "Docker"
  install_vscode_ext "amazonwebservices.aws-toolkit-vscode" "AWS Toolkit"
  install_vscode_ext "ms-kubernetes-tools.vscode-kubernetes-tools" "Kubernetes"

  # ── Git ──
  install_vscode_ext "eamodio.gitlens"                     "GitLens (Git supercharged)"

  # ── Productivity ──
  install_vscode_ext "usernamehw.errorlens"                "Error Lens (inline errors)"
  install_vscode_ext "christian-kohler.path-intellisense"  "Path IntelliSense"
  install_vscode_ext "formulahendry.auto-rename-tag"       "Auto Rename Tag (HTML/JSX)"
  install_vscode_ext "oderwat.indent-rainbow"              "Indent Rainbow"
  install_vscode_ext "pkief.material-icon-theme"           "Material Icon Theme"
  install_vscode_ext "streetsidesoftware.code-spell-checker" "Code Spell Checker"

  log "VS Code extensions done"
fi

# ── Git Configuration ─────────────────────────────────────────
section "Step 6 — Git Configuration"
CURRENT_NAME=$(git config --global user.name 2>/dev/null || echo "")
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [[ -n "$CURRENT_NAME" && -n "$CURRENT_EMAIL" ]]; then
  log "Git already configured: $CURRENT_NAME <$CURRENT_EMAIL>"
  read -p "Reconfigure? (y/n): " RECONFIG
  if [[ "$RECONFIG" != "y" ]]; then
    info "Skipping Git configuration"
  else
    CURRENT_NAME=""
  fi
fi

if [[ -z "$CURRENT_NAME" ]]; then
  read -p "Your full name (for Git commits): " GIT_NAME
  read -p "Your email (for Git commits): " GIT_EMAIL
  git config --global user.name "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"
  git config --global init.defaultBranch main
  git config --global pull.rebase false
  git config --global core.autocrlf input
  log "Git configured"
fi

# ── SSH Key ───────────────────────────────────────────────────
section "Step 7 — SSH Key"
if [ ! -f ~/.ssh/id_ed25519 ]; then
  read -p "Generate SSH key for GitHub/GitLab? (y/n): " GEN_SSH
  if [[ "$GEN_SSH" == "y" ]]; then
    read -p "Email for SSH key: " SSH_EMAIL
    mkdir -p ~/.ssh
    ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f ~/.ssh/id_ed25519 -N ""
    eval "$(ssh-agent -s)"
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519 2>/dev/null || ssh-add ~/.ssh/id_ed25519
    log "SSH key generated"
    echo ""
    warn "Add this public key to GitHub → Settings → SSH Keys:"
    echo "────────────────────────────────────────────────────"
    cat ~/.ssh/id_ed25519.pub
    echo "────────────────────────────────────────────────────"
    echo ""
    # Copy to clipboard
    cat ~/.ssh/id_ed25519.pub | pbcopy
    log "Public key copied to clipboard!"
  fi
else
  log "SSH key already exists at ~/.ssh/id_ed25519"
fi

# ── macOS Settings ────────────────────────────────────────────
section "Step 8 — macOS Tweaks"
info "Applying sensible macOS defaults..."

# Finder
defaults write com.apple.finder AppleShowAllFiles YES
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # List view
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Keyboard
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 48

# Screenshots — save to ~/Desktop/Screenshots
mkdir -p ~/Desktop/Screenshots
defaults write com.apple.screencapture location ~/Desktop/Screenshots

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

killall Finder Dock 2>/dev/null || true
log "macOS settings applied"

# ── Java PATH Setup ───────────────────────────────────────────
section "Step 9 — Java PATH Setup"
JAVA_HOME_LINE='export JAVA_HOME=$(/usr/libexec/java_home)'
if ! grep -q "JAVA_HOME" ~/.zshrc 2>/dev/null; then
  echo "" >> ~/.zshrc
  echo "# Java" >> ~/.zshrc
  echo "$JAVA_HOME_LINE" >> ~/.zshrc
  log "JAVA_HOME added to ~/.zshrc"
else
  log "JAVA_HOME already set in ~/.zshrc"
fi

# ── Verify Installations ──────────────────────────────────────
section "Verifying Installations"
echo ""
printf "%-20s %s\n" "Tool" "Version"
echo "────────────────────────────────────"
printf "%-20s %s\n" "Git"     "$(git --version 2>/dev/null | awk '{print $3}' || echo 'not found')"
printf "%-20s %s\n" "Node"    "$(node --version 2>/dev/null || echo 'not found')"
printf "%-20s %s\n" "Go"      "$(go version 2>/dev/null | awk '{print $3}' || echo 'not found')"
printf "%-20s %s\n" "Python"  "$(python3 --version 2>/dev/null | awk '{print $2}' || echo 'not found')"
printf "%-20s %s\n" "Java"    "$(java --version 2>/dev/null | head -1 | awk '{print $2}' || echo 'not found')"
printf "%-20s %s\n" "AWS CLI" "$(aws --version 2>/dev/null | awk '{print $1}' || echo 'not found')"
printf "%-20s %s\n" "Kubectl" "$(kubectl version --client --short 2>/dev/null | awk '{print $3}' || echo 'not found')"
echo ""

# ── Done ──────────────────────────────────────────────────────
section "Setup Complete!"
echo ""
log "Everything installed! Restart your Mac to apply all changes."
echo ""
echo -e "  ${GREEN}Next steps:${NC}"
echo "  1. Restart your Mac"
echo "  2. Open Docker Desktop and complete setup"
echo "  3. Run 'gh auth login' to connect GitHub CLI (if needed)"
echo "  4. Add your SSH key to GitHub/GitLab (key was copied to clipboard)"
echo ""

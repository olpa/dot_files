# Visual Studio Code Setup

This directory contains the configuration files and extensions list for replicating the VS Code setup on other machines.

## Files

- `settings.json` - User settings
- `keybindings.json` - Custom key bindings
- `extensions.txt` - List of installed extensions

## Setup Instructions

### 1. Install Visual Studio Code

Download and install VS Code from [https://code.visualstudio.com/](https://code.visualstudio.com/)

### 2. Copy Configuration Files

Copy the configuration files to the VS Code User directory:

**Linux:**
```bash
cp settings.json ~/.config/Code/User/
cp keybindings.json ~/.config/Code/User/
```

**macOS:**
```bash
cp settings.json ~/Library/Application\ Support/Code/User/
cp keybindings.json ~/Library/Application\ Support/Code/User/
```

**Windows:**
```powershell
copy settings.json %APPDATA%\Code\User\
copy keybindings.json %APPDATA%\Code\User\
```

### 3. Install Extensions

Install all extensions from the list:

```bash
cat extensions.txt | xargs -L 1 code --install-extension
```

Or install them one by one:
```bash
code --install-extension dart-code.dart-code
code --install-extension dart-code.flutter
code --install-extension github.copilot
code --install-extension github.copilot-chat
code --install-extension hbenl.vscode-mocha-test-adapter
code --install-extension hbenl.vscode-test-explorer
code --install-extension ms-azuretools.vscode-containers
code --install-extension ms-python.black-formatter
code --install-extension ms-python.debugpy
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-python.vscode-python-envs
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-vscode.test-adapter-converter
code --install-extension orta.vscode-jest
code --install-extension rust-lang.rust-analyzer
code --install-extension vscodevim.vim
```

### 4. Restart VS Code

After copying the configuration files and installing extensions, restart VS Code for all changes to take effect.

## Key Features

### Custom Keybindings
- `Ctrl+Shift+H` - Previous editor tab
- `Ctrl+Shift+L` - Next editor tab

### Vim Mode
- `jj` in insert mode - Exit to normal mode (mapped to `<Esc>`)

### Language-Specific Settings
- Dart: Format on save and type, 80-character ruler

## Maintenance

To update the extensions list after installing new extensions:

```bash
code --list-extensions > extensions.txt
```

To backup current settings:

```bash
# Linux
cp ~/.config/Code/User/settings.json .
cp ~/.config/Code/User/keybindings.json .

# macOS
cp ~/Library/Application\ Support/Code/User/settings.json .
cp ~/Library/Application\ Support/Code/User/keybindings.json .

# Windows
copy %APPDATA%\Code\User\settings.json .
copy %APPDATA%\Code\User\keybindings.json .
```

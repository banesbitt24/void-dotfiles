# My Neovim Configuration

Personal Neovim configuration with Nord theme and support for Go, Terraform, Docker, and shell scripting.

## Features

- 🎨 Nord color scheme
- 🚀 Lazy.nvim plugin manager
- 🤖 AI integration (GitHub Copilot)
- 📝 LSP support for multiple languages
- 🔍 Telescope fuzzy finder
- 🌳 Treesitter syntax highlighting
- 🐹 Go development tools
- 🏗️ Terraform/Terragrunt support
- 🐳 Docker integration
- 📦 Shell script support

## Requirements

- Neovim >= 0.9.0
- Git
- Node.js (for LSP servers)
- Ripgrep
- fd
- Go (for Go development)
- Terraform (for Terraform development)

## Installation

### Quick Install (Recommended)

Use the provided installation script:

```bash
curl -fsSL https://raw.githubusercontent.com/banesbit24/nvim-config/main/install.sh | bash
```

### Manual Installation

1. **Backup existing configuration:**
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Clone this repository:**
   ```bash
   git clone git@github.com/banesbitt24/nvim-config.git ~/.config/nvim
   ```

3. **Install dependencies:**
   - **macOS (Homebrew):**
     ```bash
     brew install neovim git node ripgrep fd fzf luarocks
     ```

   - **Ubuntu/Debian:**
     ```bash
     sudo apt update
     sudo apt install neovim git nodejs npm ripgrep fd-find fzf luarocks
     ```

   - **Arch Linux:**
     ```bash
     sudo pacman -S neovim git nodejs npm ripgrep fd fzf luarocks
     ```

4. **Install language tools:**
   ```bash
   # Go tools
   go install golang.org/x/tools/gopls@latest
   go install github.com/go-delve/delve/cmd/dlv@latest

   # Node packages
   npm install -g neovim

   # Python packages
   pip3 install --user pynvim
   ```

5. **Open Neovim and install plugins:**
   ```bash
   nvim
   ```
   Lazy.nvim will automatically install all plugins on first launch.

## Configuration Structure

```
~/.config/nvim/
├── init.lua                 # Main configuration entry point
├── lua/
│   ├── config/
│   │   ├── autocmds.lua    # Auto commands
│   │   ├── keymaps.lua     # Key mappings
│   │   └── options.lua     # Neovim options
│   └── plugins/
│       ├── ai.lua          # AI integration (Copilot/Codeium)
│       ├── colorscheme.lua # Nord theme configuration
│       ├── completion.lua  # Completion setup
│       ├── lsp.lua         # LSP configuration
│       ├── tools.lua       # Development tools
│       └── treesitter.lua  # Syntax highlighting
├── plugin/                 # Plugin-specific configurations
└── lazy-lock.json         # Plugin version lock file
```

## Key Bindings

### Leader Key
The leader key is set to `<Space>`.

### General
| Key | Action |
|-----|--------|
| `<Space>ff` | Find files |
| `<Space>fg` | Live grep |
| `<Space>fb` | Find buffers |
| `<Space>fh` | Find help |
| `<Space>fr` | Find recent files |
| `<Space>e` | Toggle file explorer |
| `<Space>q` | Quit |
| `<Space>w` | Save |
| `<Space>x` | Close buffer |

### LSP
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Go to references |
| `gi` | Go to implementation |
| `K` | Show hover documentation |
| `<Space>ca` | Code actions |
| `<Space>rn` | Rename symbol |
| `<Space>f` | Format code |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<Space>d` | Show diagnostics |

### Git
| Key | Action |
|-----|--------|
| `<Space>gg` | Open LazyGit |
| `<Space>gb` | Git blame |
| `<Space>gd` | Git diff |
| `<Space>gs` | Git status |

### AI (Copilot)

#### Insert Mode (Code Suggestions)
| Key | Action |
|-----|--------|
| `<C-J>` | Accept full suggestion |
| `<C-L>` | Accept next word |
| `<C-N>` | Next suggestion |
| `<C-P>` | Previous suggestion |
| `<C-D>` | Dismiss suggestion |

#### Normal Mode (CoPilot Management)
| Key | Action |
|-----|--------|
| `<Space>ai` | Toggle CoPilot on/off |
| `<Space>ap` | Open CoPilot panel |
| `<Space>as` | Check CoPilot status |

#### CoPilot Chat
| Key | Action |
|-----|--------|
| `<Space>cc` | Open CoPilot Chat |
| `<Space>cq` | Toggle CoPilot Chat |

#### Code Analysis (Visual Mode)
| Key | Action |
|-----|--------|
| `<Space>ce` | Explain selected code |
| `<Space>cr` | Review selected code |
| `<Space>cf` | Fix selected code |
| `<Space>co` | Optimize selected code |
| `<Space>cd` | Generate docs for selected code |
| `<Space>ct` | Generate tests for selected code |

### Window Management
| Key | Action |
|-----|--------|
| `<C-h>` | Move to left window |
| `<C-j>` | Move to bottom window |
| `<C-k>` | Move to top window |
| `<C-l>` | Move to right window |
| `<C-Up>` | Resize window up |
| `<C-Down>` | Resize window down |
| `<C-Left>` | Resize window left |
| `<C-Right>` | Resize window right |

## Language Support

### Go
- LSP: `gopls`
- Debugging: `delve`
- Auto-formatting on save
- Import management
- Code generation

### Terraform
- LSP: `terraform-ls`
- Syntax highlighting
- Auto-formatting
- Validation

### Docker
- Dockerfile syntax highlighting
- Docker Compose support
- Container management integration

### Shell Scripts
- Bash/Zsh syntax highlighting
- ShellCheck integration
- Auto-formatting

## Plugins

### Core
- **lazy.nvim** - Plugin manager
- **nord.nvim** - Color scheme
- **telescope.nvim** - Fuzzy finder
- **neo-tree.nvim** - File explorer
- **treesitter** - Syntax highlighting

### LSP & Completion
- **nvim-lspconfig** - LSP configuration
- **mason.nvim** - LSP server management
- **nvim-cmp** - Completion engine
- **copilot.vim** - AI code completion

### Git
- **gitsigns.nvim** - Git decorations
- **lazygit.nvim** - Git interface
- **diffview.nvim** - Git diff viewer

### UI
- **lualine.nvim** - Status line
- **bufferline.nvim** - Buffer line
- **indent-blankline.nvim** - Indent guides
- **which-key.nvim** - Key binding hints

## Customization

### Changing Theme
To use a different theme, edit `lua/plugins/colorscheme.lua`:

```lua
return {
  "your-theme/nvim",
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("your-theme")
  end,
}
```

### Adding Languages
1. Add LSP server to `lua/plugins/lsp.lua`
2. Add treesitter parser to `lua/plugins/treesitter.lua`
3. Configure any additional tools in `lua/plugins/tools.lua`

### Custom Keybindings
Add your keybindings to `lua/config/keymaps.lua`:

```lua
vim.keymap.set("n", "<leader>your_key", "<cmd>YourCommand<cr>", { desc = "Your description" })
```

## Troubleshooting

### Common Issues

1. **Plugins not loading:**
   ```bash
   nvim --headless "+Lazy! sync" +qa
   ```

2. **LSP not working:**
   ```bash
   :Mason
   # Install required LSP servers
   ```

3. **Treesitter errors:**
   ```bash
   :TSUpdate
   ```

4. **Health check:**
   ```bash
   :checkhealth
   ```

### Getting Help
- Run `:checkhealth` in Neovim
- Check plugin documentation: `:help plugin-name`
- View all keymaps: `:help keymaps`
- Open issues on GitHub

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Acknowledgments

- [Nord theme](https://github.com/arcticicestudio/nord) for the beautiful color scheme
- [LazyVim](https://github.com/LazyVim/LazyVim) for inspiration
- The Neovim community for excellent plugins and support

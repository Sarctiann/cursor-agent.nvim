# 🤖 cursor-agent.nvim

A Neovim plugin that seamlessly integrates [Cursor CLI](https://cursor.com) into
your Neovim workflow, providing an interactive terminal interface for AI-assisted
coding directly within your editor.

> **Note**: This plugin is a wrapper/integration tool for the Cursor CLI.
> You need to have Cursor CLI installed locally on your system for this plugin to work.

## ✨ Features

- 🚀 **Quick Access**: Open Cursor Agent terminal with simple keymaps
- 📁 **Smart Context**: Automatically attach current file or project root
- 🔄 **Multiple Modes**: Work in current directory, project root, or custom paths
- 📋 **Buffer Management**: Easily attach single or multiple open buffers
- ⚡ **Interactive Terminal**: Full terminal integration with custom keymaps
- 🎯 **Session Management**: List and manage your Cursor sessions

## 📋 Requirements

- Neovim >= 0.9.0
- [Cursor CLI](https://cursor.com) installed and available in your `$PATH`
- [snacks.nvim](https://github.com/folke/snacks.nvim) (for terminal and notifications)
- NOTE: This plugin depends on [Snacks.nvim](https://github.com/folke/snacks.nvim)
  for terminal management and notifications.

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
--- @module 'cursor-agent'
{
  "Sarctiann/cursor-agent.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  --- @type Cursor-Agent.Config
  opts = {
    -- Configure your options here
  },
}
```

### For local development

```lua
--- @module 'cursor-agent'
{
  dir = "~/.config/nvim/lua/custom_plugins/cursor-agent.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  --- @type Cursor-Agent.Config
  opts = {
    -- Configure your options here
  },
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "Sarctiann/cursor-agent.nvim",
  requires = { "folke/snacks.nvim" },
  config = function()
    require("cursor-agent").setup({
      -- Configure your options here
    })
  end
}
```

## ⚙️ Configuration

### Default Configuration

```lua
-- These are the default values; you can use `setup({})` to use defaults
require("cursor-agent").setup({
  use_default_mappings = true,
  show_help_on_open = true,
  new_lines_amount = 2,
  window_width = 64,
  open_mode = "normal",
  cursor_window_keys = {
    terminal_mode = {
      normal_mode = { "<M-q>" },
      insert_file_path = { "<C-p>" },
      insert_all_buffers = { "<C-p><C-p>" },
      new_lines = { "<CR><CR>" },
      submit = { "<C-s>" },
      enter = { "<CR>" },
      help = { "<M-?>", "??", "\\\\" },
      toggle_width = { "<C-f>" },
    },
    normal_mode = {
      hide = { "<Esc>" },
      toggle_width = { "<C-f>" },
    },
  },
})
```

### Configuration Options

| Option                 | Type      | Default    | Description                                                          |
| ---------------------- | --------- | ---------- | -------------------------------------------------------------------- |
| `use_default_mappings` | `boolean` | `true`     | Whether to use default key mappings                                  |
| `show_help_on_open`    | `boolean` | `true`     | Show help screen when terminal opens                                 |
| `new_lines_amount`     | `number`  | `2`        | Number of new lines to insert after command submission               |
| `window_width`         | `number`  | `64`       | Default width for the terminal window                                |
| `open_mode`            | `string`  | `"normal"` | Mode to open Cursor Agent: `"normal"`, `"plan"`, or `"auto-run"`     |
| `cursor_window_keys`   | `table`   | See below  | Key mappings for the Cursor Agent window (all values must be arrays) |

#### `open_mode` Values

- `"normal"` - Opens Cursor Agent in normal interactive mode (default)
- `"plan"` - Opens Cursor Agent in plan mode (`--plan` flag)
- `"auto-run"` - Opens Cursor Agent in auto-run mode (`--auto-run` flag)

### `cursor_window_keys` Structure

The `cursor_window_keys` option allows you to customize all key mappings for the Cursor Agent terminal window.
**All values must be arrays**, even if you only want to configure one key combination. This allows you to set
multiple key combinations for the same action.

#### Terminal Mode Keys

| Key                  | Default                     | Description                         |
| -------------------- | --------------------------- | ----------------------------------- |
| `normal_mode`        | `{ "<M-q>" }`               | Enter normal mode                   |
| `insert_file_path`   | `{ "<C-p>" }`               | Insert current file path            |
| `insert_all_buffers` | `{ "<C-p><C-p>" }`          | Insert all open buffer paths        |
| `new_lines`          | `{ "<CR><CR>" }`            | Insert new lines                    |
| `submit`             | `{ "<C-s>" }`               | Submit command/message              |
| `enter`              | `{ "<CR>" }`                | Enter key                           |
| `help`               | `{ "<M-?>", "??", "\\\\" }` | Show help (multiple keys supported) |
| `toggle_width`       | `{ "<C-f>" }`               | Toggle window width                 |

#### Normal Mode Keys

| Key            | Default       | Description         |
| -------------- | ------------- | ------------------- |
| `hide`         | `{ "<Esc>" }` | Hide terminal       |
| `toggle_width` | `{ "<C-f>" }` | Toggle window width |

#### Example: Custom Key Configuration

```lua
require("cursor-agent").setup({
  cursor_window_keys = {
    terminal_mode = {
      submit = { "<C-s>", "<C-Enter>" },  -- Multiple keys for submit
      help = { "??", "F1" },              -- Custom help keys
      toggle_width = { "<C-f>", "<C-w>" }, -- Multiple toggle options
    },
    normal_mode = {
      hide = { "<Esc>", "q" },            -- Multiple hide options
    },
  },
})
```

## 🎮 Usage

### Caveats

- **⚠️ The main commands are `:CursorAgent open_cwd`, `:CursorAgent open_root`, and `:CursorAgent session_list`.
  Each of these will open its own terminal (`win` and `buf`) or toggle to it if it's already open** This is handled by [Snacks.nvim](https://github.com/folke/snacks.nvim)'s `terminal()`.
- If you submit a prompt. A `cursor-agent` session will be created. If you want to continue the conversation,
  you need to use the `:CursorAgent session_list` command to see the list of sessions and then open the session you want to continue.
  (As we just said, this will open/toggle its own terminal).
- For convenience, the default "Enter" key (`<CR>`) is remapped to the "Tab" key (`<Tab>`)
  You can change this to whatever you want by changing the `cursor_window_keys.terminal_mode.enter` keymap.

### Commands

The plugin provides a single command with multiple sub-commands:

```vim
:CursorAgent [subcommand]
```

**Available sub-commands:**

- `:CursorAgent` or `:CursorAgent open_cwd` - Open in current file's directory
- `:CursorAgent open_root` - Open in project root (git root)
- `:CursorAgent session_list` - List all Cursor sessions
- `:CursorAgent [custom args]` - Open with custom cursor-agent arguments

### Default Keymaps

When `use_default_mappings = true`:

| Keymap       | Mode   | Description                                   |
| ------------ | ------ | --------------------------------------------- |
| `<leader>aJ` | Normal | Open Cursor Agent in current file's directory |
| `<leader>aj` | Normal | Open Cursor Agent in project root             |
| `<leader>al` | Normal | Show Cursor Agent sessions                    |

### Terminal Keymaps

Once the Cursor Agent terminal is open, you have access to special keymaps:

#### Terminal Mode

| Keymap                  | Description                           |
| ----------------------- | ------------------------------------- |
| `<C-s>` or `<CR><CR>`   | Submit command/message                |
| `<M-q>` or `<Esc><Esc>` | Enter normal mode                     |
| `<C-p>`                 | Attach current file path              |
| `<C-p><C-p>`            | Attach all open buffer paths          |
| `<C-f>`                 | Toggle window width (expand/collapse) |
| `<M-?>` or `??` or `\\` | Show help                             |
| `<C-c>`                 | Clear/Stop/Close                      |
| `<C-d>`                 | Close terminal                        |
| `<C-r>`                 | Review changes                        |
| `<CR>`                  | New line                              |

#### Normal Mode (in terminal)

| Keymap                                   | Description                           |
| ---------------------------------------- | ------------------------------------- |
| `q` or `<Esc>`                           | Hide terminal                         |
| `<C-f>`                                  | Toggle window width (expand/collapse) |
| All other normal mode keys work as usual |                                       |

### Cursor Agent Commands

Within the Cursor Agent terminal, you can use these commands:

- `quit` or `exit` - Close Cursor Agent (press `<CR>` after)
- `/` - Show command list
- `@` - Show file list to attach
- `!` - Run command in shell

## 🚀 Quick Start

1. Install the plugin using your preferred package manager
2. Make sure Cursor CLI is installed: `cursor-agent --version`
3. Open Neovim and press `<leader>aj` to open Cursor Agent
4. Type your coding question or request
5. Press `<C-s>` or `<CR><CR>` to submit
6. Use `<C-p>` to quickly attach files to the conversation

## 💡 Tips

- **Attach Multiple Files**: Use `<C-p><C-p>` to quickly attach all your open buffers
- **Quick Submit**: Double-tap `<CR>` or use `<C-s>` to submit without leaving insert mode
- **Context Switching**: Use `:CursorAgent open_cwd` vs `:CursorAgent open_root`
  depending on whether you want file-level or project-level context
- **Help Anytime**: Press `??` in terminal mode to see all available keymaps

## 🏗️ Project Structure

```bash
cursor-agent.nvim/
└── lua/
    └── cursor-agent/
        ├── init.lua          # Main entry point and setup
        ├── config.lua        # Configuration management
        ├── terminal.lua      # Terminal singleton management
        ├── commands.lua      # Command implementations
        ├── buffers.lua       # Buffer path management
        ├── keymaps.lua       # Terminal keymaps
        ├── autocmds.lua      # Autocommands
        └── help.lua          # Help system
```

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## 📄 License

MIT License - see [LICENSE](./LICENSE) file for details

## 🙏 Acknowledgments

- [Cursor](https://cursor.com) - For the amazing AI coding assistant
- [snacks.nvim](https://github.com/folke/snacks.nvim) - For terminal and notification utilities
- The Neovim community for inspiration and support

---

Made with ❤️ for the Neovim community

--- Keymaps module for terminal interactions
local terminal = require("cursor-agent.terminal")
local buffers = require("cursor-agent.buffers")
local help = require("cursor-agent.help")
local config = require("cursor-agent.config")

local M = {}

--- Helper function to set multiple keymaps for the same action
--- @param mode string|string[] The vim mode (e.g., "t", "n", "i", "v")
--- @param keys string[] Array of key combinations
--- @param callback function|string The function to call | or command to execute
--- @param opts table Options for vim.keymap.set
local function set_keymaps(mode, keys, callback, opts)
	for _, key in ipairs(keys) do
		vim.keymap.set(mode, key, callback, opts)
	end
end

--- Setup keymaps for the Cursor-Agent terminal
function M.setup_terminal_keymaps()
	local opts = { buffer = 0, silent = true, noremap = true }
	local keys = config.options.cursor_window_keys

	-- NOTE: Prevent default Enter key behavior
	vim.keymap.set("t", "<CR>", "", opts)
	-- NOTE: Map arrow keys
	vim.keymap.set("t", "<M-h>", "<Left>", opts)
	vim.keymap.set("t", "<M-j>", "<Down>", opts)
	vim.keymap.set("t", "<M-k>", "<Up>", opts)
	vim.keymap.set("t", "<M-l>", "<Right>", opts)

	-- Normal mode keymaps
	set_keymaps("t", keys.terminal_mode.normal_mode, [[<C-\><C-n>5(]], opts)

	-- Insert current file path
	set_keymaps("t", keys.terminal_mode.insert_file_path, function()
		if terminal.current_file then
			terminal.insert_text("@" .. terminal.current_file .. " ")
		end
	end, opts)

	-- Insert all open buffer paths
	set_keymaps("t", keys.terminal_mode.insert_all_buffers, function()
		local paths = buffers.get_open_buffers_paths(terminal.working_dir)
		for _, path in ipairs(paths) do
			terminal.insert_text("@" .. path .. "\n")
		end
	end, opts)

	-- New lines
	set_keymaps("t", keys.terminal_mode.new_lines, function()
		local new_lines = string.rep("\n", config.options.new_lines_amount)
		terminal.insert_text(new_lines)
	end, opts)

	-- Submit commands
	set_keymaps({ "n", "t" }, keys.terminal_mode.submit, function()
		vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Enter>", true, false, true), "n")
	end, opts)

	-- Enter key
	set_keymaps("t", keys.terminal_mode.enter, function()
		vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Enter>", true, false, true), "n")
	end, opts)

	-- Help keymaps
	set_keymaps("t", keys.terminal_mode.help, help.show_help, opts)

	-- Escape to hide (normal mode)
	set_keymaps("n", keys.normal_mode.hide, function()
		vim.cmd("q")
	end, opts)

	-- Toggle window width for modes i, t, n, v
	local toggle_opts = { buffer = 0, silent = true }
	set_keymaps("i", keys.terminal_mode.toggle_width, terminal.toggle_width, toggle_opts)
	set_keymaps("t", keys.terminal_mode.toggle_width, terminal.toggle_width, toggle_opts)
	set_keymaps("n", keys.normal_mode.toggle_width, terminal.toggle_width, toggle_opts)
	set_keymaps("v", keys.normal_mode.toggle_width, terminal.toggle_width, toggle_opts)
end

return M

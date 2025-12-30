--- Keymaps module for terminal interactions
local terminal = require("cursor-agent.terminal")
local buffers = require("cursor-agent.buffers")
local help = require("cursor-agent.help")
local config = require("cursor-agent.config")

local M = {}

--- Setup keymaps for the Cursor-Agent terminal
function M.setup_terminal_keymaps()
	local opts = { buffer = 0, silent = true }

	-- Normal mode keymaps
	vim.keymap.set("t", "<M-q>", [[<C-\><C-n>5(]], opts)

	-- Insert current file path
	vim.keymap.set("t", "<C-p>", function()
		if terminal.current_file then
			terminal.insert_text("@" .. terminal.current_file .. " ")
		end
	end, opts)

	-- Insert all open buffer paths
	vim.keymap.set("t", "<C-p><C-p>", function()
		local paths = buffers.get_open_buffers_paths(terminal.working_dir)
		for _, path in ipairs(paths) do
			terminal.insert_text("@" .. path .. "\n")
		end
	end, opts)

	-- Submit commands
	vim.keymap.set("t", "<CR><CR>", function()
		local new_lines = string.rep("\n", config.options.new_lines_amount)
		terminal.insert_text(new_lines)
	end, opts)

	vim.keymap.set("t", "<C-s>", function()
		vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Enter>", true, false, true), "n")
	end, opts)

	-- Enter key
	vim.keymap.set("t", "<CR>", function()
		vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Enter>", true, false, true), "n")
	end, opts)

	-- Help keymaps
	vim.keymap.set("t", "<M-?>", help.show_help, opts)
	vim.keymap.set("t", "??", help.show_help, opts)
	vim.keymap.set("t", "\\\\", help.show_help, opts)

	-- Escape to hide
	vim.keymap.set("n", "<Esc>", function()
		vim.cmd("q")
	end, opts)

	-- Toggle window width (Ctrl+f) for modes i, t, n, v
	local toggle_opts = { buffer = 0, silent = true }
	vim.keymap.set("i", "<C-f>", terminal.toggle_width, toggle_opts)
	vim.keymap.set("t", "<C-f>", terminal.toggle_width, toggle_opts)
	vim.keymap.set("n", "<C-f>", terminal.toggle_width, toggle_opts)
	vim.keymap.set("v", "<C-f>", terminal.toggle_width, toggle_opts)
end

return M

--- Commands module for opening Cursor-Agent in different modes
local terminal = require("cursor-agent.terminal")
local config = require("cursor-agent.config")

local M = {}

--- Get the argument string for the configured open mode
--- @return string Argument string for cursor-agent (empty string for "normal")
local function get_open_mode_arg()
	local mode = config.options.open_mode or "normal"
	if mode == "plan" then
		return "--plan"
	elseif mode == "auto-run" then
		return "--auto-run"
	else
		return "" -- "normal" mode, no argument needed
	end
end

--- Open Cursor-Agent in the current file's directory
function M.open_cwd()
	terminal.working_dir = vim.fn.expand("%:p:h")

	if terminal.working_dir == "" then
		terminal.working_dir = vim.fn.getcwd()
	end
	local mode_arg = get_open_mode_arg()
	terminal.open_terminal(mode_arg ~= "" and mode_arg or nil)
end

--- Open Cursor-Agent in the project root (git root)
function M.open_git_root()
	terminal.current_file = vim.fn.expand("%:p")
	local current_dir = vim.fn.expand("%:p:h")

	terminal.working_dir = vim.fs.find({ ".git" }, {
		path = terminal.current_file,
		upward = true,
	})[1]

	if terminal.working_dir then
		terminal.working_dir = vim.fn.fnamemodify(terminal.working_dir, ":h")
	else
		terminal.working_dir = current_dir ~= "" and current_dir or vim.fn.getcwd()
	end
	local mode_arg = get_open_mode_arg()
	terminal.open_terminal(mode_arg ~= "" and mode_arg or nil)
end

--- Show Cursor-Agent sessions
function M.show_sessions()
	terminal.current_file = vim.fn.expand("%:p")
	local current_dir = vim.fn.expand("%:p:h")

	terminal.working_dir = vim.fs.find({ ".git" }, {
		path = terminal.current_file,
		upward = true,
	})[1]

	if terminal.working_dir then
		terminal.working_dir = vim.fn.fnamemodify(terminal.working_dir, ":h")
	else
		terminal.working_dir = current_dir ~= "" and current_dir or vim.fn.getcwd()
	end
	local custom_cmd = "ls"
	terminal.open_terminal(custom_cmd)
end

--- Open Cursor-Agent with custom arguments
--- @param args string Custom arguments for cursor-agent
--- @param keep_open boolean|nil Whether to keep the terminal open
function M.open_custom(args, keep_open)
	terminal.open_terminal(args, keep_open)
end

return M

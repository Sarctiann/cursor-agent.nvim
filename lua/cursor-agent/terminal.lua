--- Terminal management module
local config = require("cursor-agent.config")
local M = {}

-- Singleton terminal for Cursor-Agent
M.cursor_agent_term = nil
M.term_buf = nil
M.working_dir = nil
M.current_file = nil
M.is_expanded = false -- Track if terminal is expanded to full width

--- Insert text into the terminal
--- @param text string The text to insert
function M.insert_text(text)
	if M.term_buf then
		local job_id = vim.b.terminal_job_id or vim.api.nvim_buf_get_var(M.term_buf, "terminal_job_id")

		if job_id and vim.fn.jobwait({ job_id }, 10)[1] == -1 then
			vim.fn.chansend(job_id, text)
		end
	end
end

--- Attach current file to the terminal when cursor_agent is ready
--- @param file_path string The file path to attach
--- @param tries number|nil Number of tries so far
function M.attach_file_when_ready(file_path, tries)
	vim.defer_fn(function()
		tries = tries or 0
		local max_tries = 12

		if tries >= max_tries or not M.term_buf then
			return
		end

		if not vim.api.nvim_buf_is_valid(M.term_buf) then
			return
		end

		local buf_lines = vim.api.nvim_buf_get_lines(M.term_buf, 0, 5, false)
		-- Check if any of the first 5 lines matches " Cursor Agent"
		local found = false
		for i = 1, #buf_lines do
			if buf_lines[i] and buf_lines[i]:match(" Cursor Agent") then
				found = true
				break
			end
		end
		if found then
			M.insert_text("@" .. file_path .. "\n\n")
			return
		end

		-- Recursively retry after 300ms
		M.attach_file_when_ready(file_path, tries + 1)
	end, 300)
end

--- Open or toggle the Cursor-Agent terminal
--- @param args string|nil Command line arguments for cursor-agent
--- @param keep_open boolean|nil Whether to keep the terminal open after execution
function M.open_terminal(args, keep_open)
	if M.cursor_agent_term and M.cursor_agent_term.toggle then
		M.cursor_agent_term:toggle()
	else
		local cmd = args and " " .. args or ""
		local current_file_abs = vim.fn.expand("%:p")

		local base_dir = M.working_dir or vim.fn.getcwd()
		M.current_file = vim.fn.expand("%")
		if base_dir and base_dir ~= "" then
			M.current_file = vim.fs.relpath(base_dir, current_file_abs) or vim.fn.fnamemodify(current_file_abs, ":.")
		end

		M.cursor_agent_term = Snacks.terminal("cursor-agent" .. cmd, {
			interactive = true,
			cwd = base_dir,
			win = {
				title = " Cursor-Agent " .. (args and " ( " .. args .. " ) " or ""),
				position = keep_open and "float" or "right",
				min_width = keep_open and nil or config.options.window_width,
				border = "rounded",
				on_close = function()
					M.cursor_agent_term = nil
					M.is_expanded = false
				end,
				resize = true,
			},
			auto_close = not keep_open,
			start_insert = not keep_open,
			auto_insert = not keep_open,
		})

		if M.cursor_agent_term.buf ~= M.term_buf then
			M.attach_file_when_ready(M.current_file)
		end
		M.term_buf = M.cursor_agent_term.buf
		M.is_expanded = false -- Reset expansion state when opening new terminal
	end
end

--- Toggle terminal window width between default and maximum
function M.toggle_width()
	if not M.cursor_agent_term or not M.term_buf then
		return
	end

	-- Get the terminal window
	local term_win = nil
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == M.term_buf then
			term_win = win
			break
		end
	end

	if not term_win or not vim.api.nvim_win_is_valid(term_win) then
		return
	end

	local window_width = config.options.window_width
	local columns = vim.o.columns

	-- Calculate maximum width (accounting for borders and margins)
	-- Assuming 2 columns for border (1 on each side)
	local max_width = columns - 2

	if M.is_expanded then
		-- Return to default width
		vim.api.nvim_win_set_width(term_win, window_width)
		M.is_expanded = false
	else
		-- Expand to maximum width
		vim.api.nvim_win_set_width(term_win, max_width)
		M.is_expanded = true
	end
end

return M

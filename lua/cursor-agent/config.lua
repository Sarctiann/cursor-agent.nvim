--- @class Cursor-Agent.Config
--- @field use_default_mappings boolean|nil # Whether to use default key mappings (default: true)
--- @field show_help_on_open boolean|nil # Whether to show help notification when opening the terminal (default: true)
--- @field new_lines_amount number|nil # Number of new lines to insert after command submission (default: 2)
--- @field window_width number|nil # Default width for the terminal window (default: 64)

local M = {}

--- Default configuration
M.defaults = {
	use_default_mappings = true,
	show_help_on_open = true,
	new_lines_amount = 2,
	window_width = 64,
}

--- Current configuration
M.options = {}

--- @param config Cursor-Agent.Config
function M.setup(config)
	M.options = vim.tbl_deep_extend("force", M.defaults, config or {})
	return M.options
end

return M

local config = require("statusline.config")

--- Section for Git information
---
--- Shows Git summary from |MiniGit| (should be set up; recommended). To tweak
--- formatting of what data is shown, modify buffer-local summary string directly
--- as described in |MiniGit-examples|.
---
--- If 'mini.git' is not set up, section falls back on 'lewis6991/gitsigns' data
--- or showing empty string.
---
--- Empty string is returned if window width is lower than `args.trunc_width`.
---
---@param args __statusline_args Use `args.icon` to supply your own icon.
---
---@return __statusline_section
local function create_component(args)
	local H = require("statusline.helper")
	if NeoVimStatusline.is_truncated(args.trunc_width) then
		return ""
	end

	local summary = vim.b.minigit_summary_string or vim.b.gitsigns_head
	if summary == nil then
		return ""
	end

	local use_icons = H.use_icons or config.use_icons
	local icon = args.icon or (use_icons and "" or "Git")
	return icon .. " " .. (summary == "" and "-" or summary)
end

return create_component

local H = require("statusline.helper")
local config = require("statusline.config")

return function(args)
	if H.is_truncated(args.trunc_width) then
		return ""
	end

	local summary = vim.b.neovimdiff_summary_string or vim.b.gitsigns_status
	if summary == nil then
		return ""
	end

	local use_icons = H.use_icons or config.use_icons
	local icon = args.icon or (use_icons and "" or "Diff")
	return icon .. " " .. (summary == "" and "-" or summary)
end

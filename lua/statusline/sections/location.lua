local H = require("statusline.helper")

--- Section for location inside buffer
---
--- Show location inside buffer in the form:
--- - Normal: `'<cursor line>|<total lines>│<cursor column>|<total columns>'`
--- - Short: `'<cursor line>│<cursor column>'`
---
--- Short output is returned if window width is lower than `args.trunc_width`.
---
---@param args __statusline_args
---
---@return __statusline_section

local function create_component(args)
	if args.format then
		return args.format
	end

	if H.is_truncated(args.trunc_width) then
		return "%l│%2v"
	end

	-- Use `virtcol()` to correctly handle multi-byte characters
	return '%l|%L│%2v|%-2{virtcol("$") - 1}'
	-- return "Ln: %l, Col: %2v, Spaces: " .. string.format("%d", vim.bo.tabstop)
end

return create_component

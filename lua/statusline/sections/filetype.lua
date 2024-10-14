local H = require("statusline.helper")

--- Section for file type
---
--- Short output contains only buffer's 'filetype' and is returned if window
--- width is lower than `args.trunc_width` or buffer is not normal.
---
--- Nothing is shown if there is no 'filetype' set (treated as temporary buffer).
---
--- If `config.use_icons` is true and icon provider is present (see
--- "Dependencies" section in |mini.statusline|), shows icon near the filetype.
---
---@param args __statusline_args
---
---@return __statusline_section
return function(args)
	local filetype = vim.bo.filetype

	-- Don't show anything if there is no filetype
	if filetype == "" then
		return ""
	end

	if args.uppercase then
		filetype = string.sub(filetype, 1, 1):upper() .. string.sub(filetype, 2, #filetype)
	end

	-- Add filetype icon
	if args.use_icon then
		H.ensure_get_icon()
		if H.get_icon ~= nil then
			filetype = H.get_icon(filetype) .. " " .. filetype
		end
	end

	return filetype
end

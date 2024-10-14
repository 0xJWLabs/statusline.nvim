--- Section for file encoding
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
	local encoding = vim.bo.fileencoding or vim.bo.encoding

	if args.uppercase then
		encoding = string.upper(encoding)
	end

	return string.format("%s", encoding)
end

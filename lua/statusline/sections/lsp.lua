local H = require("statusline.helper")
local config = require("statusline.config")

--- Section for attached LSP servers
---
--- Shows number of LSP servers (each as separate "+" character) attached to
--- current buffer or nothing if none is attached.
--- Nothing is shown if window width is lower than `args.trunc_width`.
---
---@param args __statusline_args Use `args.icon` to supply your own icon.
---
---@return __statusline_section
local function create_component(args)
	if H.is_truncated(args.trunc_width) then
		return ""
	end

	local attached = H.get_attached_lsp()
	if attached == "" then
		return ""
	end

	local use_icons = H.use_icons or config.use_icons
	local icon = args.icon or (use_icons and "󰰎" or "LSP")
	return icon .. " " .. attached
end

return create_component

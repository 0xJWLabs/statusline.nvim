vim.g.os = vim.uv.os_uname().sysname
vim.g.is_mac = vim.g.os == "Darwin"
vim.g.is_linux = vim.g.os == "Linux"
vim.g.is_windows = vim.g.os:find("Windows") and true or false
vim.g.is_wsl = vim.g.is_linux and vim.uv.os_uname().release:lower():find("microsoft") and true or false
vim.g.wsl_distro = vim.g.is_wsl and vim.env.WSL_DISTRO_NAME or ""

local M = {}

function M.is_wsl()
	local is_wsl = vim.uv.os_uname().sysname == "Linux" and vim.uv.os_uname().release:lower():find("microsoft") and true
		or false
	return is_wsl
end

function M.get_wsl_distro()
	local is_wsl = M.is_wsl()
	return is_wsl and vim.env.WSL_DISTRO_NAME or nil
end

function M.stl_escape(str)
	if type(str) ~= "string" then
		return str
	end
	return str:gsub("%%", "%%%%")
end

function M.set_default_highlight(name, data)
	data.default = true
	vim.api.nvim_set_hl(0, name, data)
end

-- Function to create a new highlight group if it doesn't exist
-- Uses provided default colors for the new group
--- @param name string Highlight name
--- @param defaults table Highlight defaults
function M.create_highlight_group(name, defaults)
	-- Check if the group exists using the new Lua API
  if vim.fn.hlexists(name) == 0 then
    vim.api.nvim_set_hl(0, name, defaults)
  end
end

-- Note for now only works for termguicolors scope can be bg or fg or any other
-- attr parameter like bold/italic/reverse
---@param color_group string hl_group name
---@param scope       string? bg | fg | sp
---@return table|string|nil returns #rrggbb formatted color when scope is specified
function M.extract_highlight_colors(color_group, scope)
	-- Check if the highlight group exists
	if vim.fn.hlexists(color_group) == 0 then
		return nil
	end

	-- Get the highlight details
  --- @diagnostic disable-next-line:deprecated
	local color = vim.api.nvim_get_hl_by_name(color_group, true)

	-- Format colors if they exist
	if color.background ~= nil then
		color.bg = string.format("#%06x", color.background)
		color.background = nil
	end
	if color.foreground ~= nil then
		color.fg = string.format("#%06x", color.foreground)
		color.foreground = nil
	end
	if color.special ~= nil then
		color.sp = string.format("#%06x", color.special)
		color.special = nil
	end

	-- If scope is provided, return the corresponding value
	if scope then
		return color[scope]
	end

	-- Return the full color table
	return color
end

--- retrieves color value from highlight group name in syntax_list
--- first present highlight is returned
---@param scope string|table
---@param syntaxlist table
--- @param default string 
---@return string
function M.extract_color_from_hllist(scope, syntaxlist, default)
	-- Ensure the scope is a table
  --- @cast scope table
	scope = type(scope) == "string" and { scope } or scope

	-- Iterate over the list of syntax groups
	for _, highlight_name in ipairs(syntaxlist) do
		if vim.fn.hlexists(highlight_name) ~= 0 then
			local color = M.extract_highlight_colors(highlight_name)
			for _, sc in ipairs(scope) do
				if color.reverse then
					-- If reverse is set, switch foreground and background
					if sc == "bg" then
						sc = "fg"
					else
						sc = "bg"
					end
				end
				if color[sc] then
					return color[sc]
				end
			end
		end
	end

	return default
end

return M

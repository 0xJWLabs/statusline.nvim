local H = require("statusline.helper")
local utils = require("statusline.utils")
local config = require("statusline.config")

local default_options = {
  trunc_width = 100,
  colored = true,
  use_icon = true
}

local cached_colors = nil

local function apply_default_colors()
  if cached_colors then
    return cached_colors
  end
	local default_diagnostics_color = {
		error = {
			fg = utils.extract_color_from_hllist(
				{ "fg", "sp" },
				{ "DiagnosticError", "LspDiagnosticsDefaultError", "DiffDelete" },
				"#e32636"
			),
		},
		warn = {
			fg = utils.extract_color_from_hllist(
				{ "fg", "sp" },
				{ "DiagnosticWarn", "LspDiagnosticsDefaultWarning", "DiffText" },
				"#ffa500"
			),
		},
		info = {
			fg = utils.extract_color_from_hllist(
				{ "fg", "sp" },
				{ "DiagnosticInfo", "LspDiagnosticsDefaultInformation", "Normal" },
				"#ffffff"
			),
		},
		hint = {
			fg = utils.extract_color_from_hllist(
				{ "fg", "sp" },
				{ "DiagnosticHint", "LspDiagnosticsDefaultHint", "DiffChange" },
				"#273faf"
			),
		},
	}

  cached_colors = default_diagnostics_color
	return default_diagnostics_color
end

local function init_component(args)
	local colors = apply_default_colors()
	if args.colors then
		for colorName, colorValue in pairs(args.colors) do
			if colors[colorName:lower()] ~= nil then
				colors[colorName:lower()] = colorValue
			end
		end
	end

	for colorName, colorValue in pairs(colors) do
		local new_highlight_group = "NeoVimStatuslineDiagnostic" .. string.upper(colorName)
		utils.create_highlight_group(new_highlight_group, colorValue)
	end
end

--- Section for Neovim's builtin diagnostics
---
--- Shows nothing if diagnostics is disabled, no diagnostic is set, or for short
--- output. Otherwise uses |vim.diagnostic.get()| to compute and show number of
--- errors ('E'), warnings ('W'), information ('I'), and hints ('H').
---
--- Short output is returned if window width is lower than `args.trunc_width`.
---
---@param args __statusline_args Use `args.icon` to supply your own icon.
---   Use `args.signs` to use custom signs per severity level name. For example: >lua
---
---     { ERROR = '!', WARN = '?', INFO = '@', HINT = '*' }
--- <
---@return __statusline_section
local function create_component(args)
  args = vim.tbl_deep_extend('force', default_options, args or {})
	if H.is_truncated(args.trunc_width) or H.diagnostic_is_disabled() then
		return ""
	end

	init_component(args)

	-- Construct string parts
	local count = H.diagnostic_get_count()
	--- @diagnostic disable-next-line:unused-local
	local severity, t, signs = vim.diagnostic.severity, {}, args.signs or {}
	local use_icons = H.use_icons or config.use_icons
	for _, level in ipairs(H.diagnostic_levels) do
		local n = count[severity[level.name]] or 0
		-- Add level info only if diagnostic is present
		if n > 0 then
      local sign = (args.use_icon and use_icons) and level.sign_icon .. ' ' or level.sign
      local diagnostic_str = args.colored
        and ("%#" .. "NeoVimStatuslineDiagnostic" .. level.name .. "# " .. sign .. n)
        or (sign .. " " .. n)
      table.insert(t, diagnostic_str)
		end
	end

	return #t > 0 and table.concat(t, " ") or ""
end

return create_component

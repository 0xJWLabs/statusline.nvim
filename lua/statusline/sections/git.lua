local config = require("statusline.config")
local H = require("statusline.helper")
local utils = require("statusline.utils")

local default_options = {
  icon = "",
  color = '#A6E3A1',
  trunc_width = 100,
  summary = false,
  colored = false,
}

local function clean_git_status(git_status)
    -- This pattern removes any text within parentheses, including the parentheses themselves
     return git_status:gsub("%s*%([^()]*%)", ""):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1") -- Clean extra spaces
end

local function init_component(args)
  local new_highlight_group = "NeoVimStatuslineGit"
  utils.create_highlight_group(new_highlight_group, { fg = args.color })
end

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
  args = vim.tbl_deep_extend("force", default_options, args or {})
  init_component(args)
	if NeoVimStatusline.is_truncated(args.trunc_width) then
		return ""
	end

	local summary = vim.b.neovimgit_summary_string or vim.b.gitsigns_head
	if summary == nil then
		return ""
	end

	local use_icons = H.use_icons or config.use_icons
  local icon = use_icons and args.icon or "Git"
  summary = summary == "" and "-" or args.summary and summary or clean_git_status(summary)
	return args.colored and string.format('%%#%s#%s', 'NeoVimStatuslineGit', icon .. " " .. summary) or icon .. " " .. summary
end

return create_component

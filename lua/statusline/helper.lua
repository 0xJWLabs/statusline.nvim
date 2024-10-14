local utils = require("statusline.utils")
local config = require("statusline.config")

local H = {}
H.default_config = nil

-- Showed diagnostic levels
H.diagnostic_levels = {
	{ name = "ERROR", sign = "E", sign_icon = "" },
	{ name = "WARN", sign = "W", sign_icon = "" },
	{ name = "INFO", sign = "I", sign_icon = "" },
	{ name = "HINT", sign = "H", sign_icon = "" },
}

-- String representation of attached LSP clients per buffer id
H.attached_lsp = {}

-- Helper functionality =======================================================
-- Settings -------------------------------------------------------------------
function H.apply_config()
	-- Set settings to ensure statusline is displayed properly
	if config.set_vim_settings and (vim.o.laststatus == 0 or vim.o.laststatus == 1) then
		vim.o.laststatus = 2
	end

	-- Ensure proper 'statusline' values (to not rely on autocommands trigger)
	H.ensure_content()

	-- Set global value to reduce flickering when first time entering buffer, as
	-- it is used by default before content is ensured on next loop
	vim.o.statusline = "%{%v:lua.NeoVimStatusline.active()%}"
end

function H.create_autocommands()
	local gr = vim.api.nvim_create_augroup("NeoVimStatusline", {})

	local au = function(event, pattern, callback, desc)
		vim.api.nvim_create_autocmd(event, { group = gr, pattern = pattern, callback = callback, desc = desc })
	end

	au({ "WinEnter", "BufWinEnter" }, "*", H.ensure_content, "Ensure statusline content")

	-- Use `schedule_wrap()` because at `LspDetach` server is still present
	local track_lsp = vim.schedule_wrap(function(data)
		H.attached_lsp[data.buf] = H.compute_attached_lsp(data.buf)
		vim.cmd("redrawstatus")
	end)
	au({ "LspAttach", "LspDetach" }, "*", track_lsp, "Track LSP clients")

	au("ColorScheme", "*", H.create_default_hl, "Ensure colors")
end

--stylua: ignore
function H.create_default_hl()
  local set_default_hl = utils.set_default_highlight

  set_default_hl('NeoVimStatuslineModeNormal',  { link = 'Cursor' })
  set_default_hl('NeoVimStatuslineModeInsert',  { link = 'DiffChange' })
  set_default_hl('NeoVimStatuslineModeVisual',  { link = 'DiffAdd' })
  set_default_hl('NeoVimStatuslineModeReplace', { link = 'DiffDelete' })
  set_default_hl('NeoVimStatuslineModeCommand', { link = 'DiffText' })
  set_default_hl('NeoVimStatuslineModeOther',   { link = 'IncSearch' })

  set_default_hl('NeoVimStatuslineDevinfo',  { link = 'StatusLine' })
  set_default_hl('NeoVimStatuslineFilename', { link = 'StatusLineNC' })
  set_default_hl('NeoVimStatuslineFileinfo', { link = 'StatusLine' })
  set_default_hl('NeoVimStatuslineInactive', { link = 'StatusLineNC' })
  set_default_hl('NeoVimStatuslineActive', { link = 'StatusLine' })
end

function H.is_disabled()
	return vim.g.neovimstatusline_disable == true or vim.b.neovimstatusline_disable == true
end

-- Content --------------------------------------------------------------------
H.ensure_content = vim.schedule_wrap(function()
	-- NOTE: Use `schedule_wrap()` to properly work inside autocommands because
	-- they might temporarily change current window
	local cur_win_id, is_global_stl = vim.api.nvim_get_current_win(), vim.o.laststatus == 3
	for _, win_id in ipairs(vim.api.nvim_list_wins()) do
		vim.wo[win_id].statusline = (win_id == cur_win_id or is_global_stl) and "%{%v:lua.NeoVimStatusline.active()%}"
			or "%{%v:lua.NeoVimStatusline.inactive()%}"
	end
end)

-- Mode -----------------------------------------------------------------------
-- Custom `^V` and `^S` symbols to make this file appropriate for copy-paste
-- (otherwise those symbols are not displayed).
local CTRL_S = vim.api.nvim_replace_termcodes("<C-S>", true, true, true)
local CTRL_V = vim.api.nvim_replace_termcodes("<C-V>", true, true, true)

-- stylua: ignore start
H.modes = setmetatable({
  ['n']    = { long = 'Normal',   short = 'N',   hl = 'NeoVimStatuslineModeNormal' },
  ['v']    = { long = 'Visual',   short = 'V',   hl = 'NeoVimStatuslineModeVisual' },
  ['V']    = { long = 'V-Line',   short = 'V-L', hl = 'NeoVimStatuslineModeVisual' },
  [CTRL_V] = { long = 'V-Block',  short = 'V-B', hl = 'NeoVimStatuslineModeVisual' },
  ['s']    = { long = 'Select',   short = 'S',   hl = 'NeoVimStatuslineModeVisual' },
  ['S']    = { long = 'S-Line',   short = 'S-L', hl = 'NeoVimStatuslineModeVisual' },
  [CTRL_S] = { long = 'S-Block',  short = 'S-B', hl = 'NeoVimStatuslineModeVisual' },
  ['i']    = { long = 'Insert',   short = 'I',   hl = 'NeoVimStatuslineModeInsert' },
  ['R']    = { long = 'Replace',  short = 'R',   hl = 'NeoVimStatuslineModeReplace' },
  ['c']    = { long = 'Command',  short = 'C',   hl = 'NeoVimStatuslineModeCommand' },
  ['r']    = { long = 'Prompt',   short = 'P',   hl = 'NeoVimStatuslineModeOther' },
  ['!']    = { long = 'Shell',    short = 'Sh',  hl = 'NeoVimStatuslineModeOther' },
  ['t']    = { long = 'Terminal', short = 'T',   hl = 'NeoVimStatuslineModeOther' },
}, {
  -- By default return 'Unknown' but this shouldn't be needed
  __index = function()
    return   { long = 'Unknown',  short = 'U',   hl = '%#NeoVimStatuslineModeOther#' }
  end,
})
-- stylua: ignore end

-- Default content ------------------------------------------------------------
--stylua: ignore
function H.default_content_active()
  H.use_icons = config.use_icons
  local mode, mode_hl = require("statusline.sections.mode")({ trunc_width = 120 })
  local git           = require("statusline.sections.git")({ trunc_width = 40 })
  local diff          = require("statusline.sections.diff")({ trunc_width = 75 })
  local diagnostics   = require("statusline.sections.diagnostics")({ trunc_width = 75 })
  local lsp           = require("statusline.sections.lsp")({ trunc_width = 75 })
  local filename      = require("statusline.sections.filename")({ path = 0 })
  local fileinfo      = require("statusline.sections.fileinfo")({ trunc_width = 120, use_icon = true })
  local location      = require("statusline.sections.location")({ trunc_width = 75 })
  local search        = require("statusline.sections.searchcount")({ trunc_width = 75 })
  H.use_icons = nil

  -- Usage of `NeoVimStatusline.combine_groups()` ensures highlighting and
  -- correct padding with spaces between groups (accounts for 'missing'
  -- sections, etc.)
  return H.combine_groups({
    { hl = mode_hl,                  strings = { mode } },
    { hl = 'NeoVimStatuslineDevinfo',  strings = { git, diff, diagnostics, lsp } },
    '%<', -- Mark general truncate point
    { hl = 'NeoVimStatuslineFilename', strings = { filename } },
    '%=', -- End left alignment
    { hl = 'NeoVimStatuslineFileinfo', strings = { fileinfo } },
    { hl = mode_hl,                  strings = { search, location } },
  })
end

function H.default_content_inactive()
	return "%#NeoVimStatuslineInactive#%F%="
end

-- LSP ------------------------------------------------------------------------
function H.get_attached_lsp()
	return H.attached_lsp[vim.api.nvim_get_current_buf()] or ""
end

--- @param buf_id number
function H.compute_attached_lsp(buf_id)
	return string.rep("+", vim.tbl_count(H.get_buf_lsp_clients(buf_id)))
end

--- @param buf_id number
function H.get_buf_lsp_clients(buf_id)
	if vim.lsp.get_clients ~= nil then
		return vim.lsp.get_clients({ bufnr = buf_id })
	end

	--- @diagnostic disable-next-line:deprecated
	return vim.lsp.buf_get_clients(buf_id)
end

-- Diagnostics ----------------------------------------------------------------
function H.diagnostic_get_count()
	local count
	if vim.diagnostic.count ~= nil then
		count = vim.diagnostic.count(0)
		return count
	end

	-- fallback
	local diagnostics = vim.diagnostic.get(0)
	count = { 0, 0, 0, 0 }
	for _, diagnostic in ipairs(diagnostics) do
		count[diagnostic.severity] = count[diagnostic.severity] + 1
	end
	return count
end

function H.diagnostic_is_disabled()
	if vim.fn.has("nvim-0.10") == 1 or vim.fn.has("nvim-0.11") == 1 then
		return not vim.diagnostic.is_enabled({ bufnr = 0 })
	elseif vim.fn.has("nvim-0.9") == 1 then
		--- @diagnostic disable-next-line:deprecated
		return vim.diagnostic.is_disabled(0)
	end

	return false
end

-- Utilities ------------------------------------------------------------------
function H.get_filesize()
	local size = vim.fn.getfsize(vim.fn.getreg("%"))
	if size < 1024 then
		return string.format("%dB", size)
	elseif size < 1048576 then
		return string.format("%.2fKiB", size / 1024)
	else
		return string.format("%.2fMiB", size / 1048576)
	end
end

function H.ensure_get_icon()
	if not (H.use_icons or config.use_icons) then
		-- Show no icon
		H.get_icon = nil
	elseif H.get_icon ~= nil then
		-- Cache only once
		return
	--- @diagnostic disable-next-line:undefined-field
	elseif _G.MiniIcons ~= nil then
		-- Prefer 'mini.icons'
		H.get_icon = function(filetype)
			--- @diagnostic disable-next-line:undefined-field
			return (_G.MiniIcons.get("filetype", filetype))
		end
	else
		-- Try falling back to 'nvim-web-devicons'
		local has_devicons, devicons = pcall(require, "nvim-web-devicons")
		if not has_devicons then
			return
		end
		H.get_icon = function()
			return (devicons.get_icon(vim.fn.expand("%:t"), nil, { default = true }))
		end
	end
end

function H.set_disable_filetypes()
	local f = function(args)
		vim.b[args.buf].neovimstatusline_disable = true
	end
	if config.disable_filetype ~= nil and #config.disable_filetype > 0 then
		vim.api.nvim_create_autocmd("Filetype", { pattern = config.disable_filetype, callback = f })
	end

	vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
		callback = function()
			local bufname = vim.api.nvim_buf_get_name(0)
			local bufnr = vim.api.nvim_get_current_buf()
			if bufname == "" then
				vim.b[bufnr].neovimstatusline_disable = true
			end
		end,
	})
end

--- Decide whether to truncate
---
--- This basically computes window width and compares it to `trunc_width`: if
--- window is smaller then truncate; otherwise don't. Don't truncate by
--- default.
---
--- Use this to manually decide if section needs truncation or not.
---
---@param trunc_width number|nil Truncation width. If `nil`, output is `false`.
---
---@return boolean Whether to truncate.
function H.is_truncated(trunc_width)
	-- Use -1 to default to 'not truncated'
	local cur_width = vim.o.laststatus == 3 and vim.o.columns or vim.api.nvim_win_get_width(0)
	return cur_width < (trunc_width or -1)
end

-- Module functionality =======================================================
--- Compute content for active window
function H.active()
	if H.is_disabled() then
		return ""
	end

	return (config.content.active or H.default_content_active)()
end

--- Compute content for inactive window
function H.inactive()
	if H.is_disabled() then
		return ""
	end

	return (config.content.inactive or H.default_content_inactive)()
end

--- Combine groups of sections
---
--- Each group can be either a string or a table with fields `hl` (group's
--- highlight group) and `strings` (strings representing sections).
---
--- General idea of this function is as follows;
--- - String group is used as is (useful for special strings like `%<` or `%=`).
--- - Each table group has own highlighting in `hl` field (if missing, the
---   previous one is used) and string parts in `strings` field. Non-empty
---   strings from `strings` are separated by one space. Non-empty groups are
---   separated by two spaces (one for each highlighting).
---
---@param groups table Array of groups.
---
---@return string String suitable for 'statusline'.
function H.combine_groups(groups)
	local parts = vim.tbl_map(function(s)
		if type(s) == "string" then
      if s == "separator" then
        s = "%="
      end
			return s
		end
		if type(s) ~= "table" then
			return ""
		end

		local string_arr = vim.tbl_filter(function(x)
			return type(x) == "string" and x ~= ""
		end, s.strings or {})
		local str = table.concat(string_arr, " ")

		-- Use previous highlight group
		if s.hl == nil then
			return " " .. str .. " "
		end

		-- Allow using this highlight group later
		if str:len() == 0 then
			return "%#" .. s.hl .. "#"
		end

		if not s.hl then
			return string.format("%s ", str)
		end

		return string.format("%%#%s# %s ", s.hl, str)
	end, groups)

	return table.concat(parts, "")
end

return H

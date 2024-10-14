---@alias __statusline_args table Section arguments.
---@alias __statusline_section string Section string.

-- Module definition ==========================================================
local NeoVimStatusline = {}
local config = require("statusline.config")

local H = require("statusline.helper")

--- Module setup
---
---@param opts NeoVimStatuslineOptions? Module config table. See |NeoVimStatusline.config|.
---
---@usage >lua
---   require('statusline').setup() -- use default config
---   -- OR
---   require('statusline').setup({}) -- replace {} with your config table
--- <
function NeoVimStatusline.setup(opts)
  _G.NeoVimStatusline = NeoVimStatusline
  config.merge(opts)
  H.apply_config()
  H.create_autocommands()

  -- - Disable built-in statusline in Quickfix window
	vim.g.qf_disable_statusline = 1

	-- Create default highlighting
	H.create_default_hl()
	H.set_disable_filetypes()
end

-- Module functionality =======================================================
--- Compute content for active window
NeoVimStatusline.active = H.active

--- Compute content for inactive window
NeoVimStatusline.inactive = H.inactive

NeoVimStatusline.combine_groups = H.combine_groups
NeoVimStatusline.is_truncated = H.is_truncated
-- Sections ===================================================================
NeoVimStatusline.section_mode = require("statusline.sections.mode")
NeoVimStatusline.section_wsl = require("statusline.sections.wsl")
NeoVimStatusline.section_git = require("statusline.sections.git")

NeoVimStatusline.section_diff = require("statusline.sections.diff")
NeoVimStatusline.section_diagnostics = require("statusline.sections.diagnostics")
NeoVimStatusline.section_lsp = require("statusline.sections.lsp")

NeoVimStatusline.section_filename = require("statusline.sections.filename")
NeoVimStatusline.section_fileencoding = require("statusline.sections.fileencoding")
NeoVimStatusline.section_fileformat = require("statusline.sections.fileformat")
NeoVimStatusline.section_fileinfo = require("statusline.sections.fileinfo")
NeoVimStatusline.section_filesize = require("statusline.sections.filesize")
NeoVimStatusline.section_filetype = require("statusline.sections.filetype")
NeoVimStatusline.section_location = require("statusline.sections.location")
NeoVimStatusline.section_eol = require("statusline.sections.eol")

NeoVimStatusline.section_searchcount = require("statusline.sections.searchcount")

return NeoVimStatusline

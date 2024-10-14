-- Sections ===================================================================
-- Functions should return output text without whitespace on sides.
-- Return empty string to omit section.

--- Section for Vim |mode()|
---
--- Short output is returned if window width is lower than `args.trunc_width`.
---
---@param args __statusline_args
---
---@return ... Section string and mode's highlight group.
local function create_component(args)
	local H = require("statusline.helper")
	local mode_info = H.modes[vim.fn.mode()]

  local mode = H.is_truncated(args.trunc_width) and mode_info.short or mode_info.long

  if args.vim then
    mode = '-- ' .. string.upper(mode) .. ' --'
  end
	return mode, mode_info.hl
end

return create_component

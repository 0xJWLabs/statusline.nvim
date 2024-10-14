--- Section for current search count
---
--- Show the current status of |searchcount()|. Empty output is returned if
--- window width is lower than `args.trunc_width`, search highlighting is not
--- on (see |v:hlsearch|), or if number of search result is 0.
---
--- `args.options` is forwarded to |searchcount()|. By default it recomputes
--- data on every call which can be computationally expensive (although still
--- usually on 0.1 ms order of magnitude). To prevent this, supply
--- `args.options = { recompute = false }`.
---
---@param args __statusline_args
---
---@return __statusline_section
local function create_component(args)
	local H = require("statusline.helper")
	if vim.v.hlsearch == 0 or H.is_truncated(args.trunc_width) then
		return ""
	end
	-- `searchcount()` can return errors because it is evaluated very often in
	-- statusline. For example, when typing `/` followed by `\(`, it gives E54.
	local ok, s_count = pcall(vim.fn.searchcount, (args or {}).options or { recompute = true })
	if not ok or s_count.current == nil or s_count.total == 0 then
		return ""
	end

	if s_count.incomplete == 1 then
		return "?/?"
	end

	local too_many = ">" .. s_count.maxcount
	local current = s_count.current > s_count.maxcount and too_many or s_count.current
	local total = s_count.total > s_count.maxcount and too_many or s_count.total
	return current .. "/" .. total
end

return create_component

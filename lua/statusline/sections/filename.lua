local utils = require("statusline.utils")

local default_options = {
	symbols = {
		modified = "[+]",
		readonly = "[-]",
		unnamed = "[No Name]",
		newfile = "[New]",
	},
	file_status = true,
	newfile_status = false,
	path = 0,
	trunc_width = 40,
}

local function is_new_file()
	local filename = vim.fn.expand("%")
	return filename ~= "" and vim.bo.buftype == "" and vim.fn.filereadable(filename) == 0
end

---shortens path by turning apple/orange -> a/orange
---@param path string
---@param sep string path separator
---@param max_len integer maximum length of the full filename string
---@return string
local function shorten_path(path, sep, max_len)
	local len = #path
	if len <= max_len then
		return path
	end

	local segments = vim.split(path, sep)
	for idx = 1, #segments - 1 do
		if len <= max_len then
			break
		end

		local segment = segments[idx]
		local shortened = segment:sub(1, vim.startswith(segment, ".") and 2 or 1)
		segments[idx] = shortened
		len = len - (#segment - #shortened)
	end

	return table.concat(segments, sep)
end

local function filename_and_parent(path, sep)
	local segments = vim.split(path, sep)
	if #segments == 0 then
		return path
	elseif #segments == 1 then
		return segments[#segments]
	else
		return table.concat({ segments[#segments - 1], segments[#segments] }, sep)
	end
end

local function create_component(args)
	local H = require("statusline.helper")
	args = vim.tbl_deep_extend("force", default_options, args or {})
	local path_separator = package.config:sub(1, 1)
	local data
	if args.path == 1 then
		-- relative path
		data = vim.fn.expand("%:~:.")
	elseif args.path == 2 then
		-- absolute path
		data = vim.fn.expand("%:p")
	elseif args.path == 3 then
		-- absolute path, with tilde
		data = vim.fn.expand("%:p:~")
	elseif args.path == 4 then
		-- filename and immediate parent
		data = filename_and_parent(vim.fn.expand("%:p:~"), path_separator)
	else
		-- just filename
		data = vim.fn.expand("%:t")
	end

	if data == "" then
		data = args.symbols.unnamed
	end

	if H.is_truncated(args.trunc_width) then
		local windwidth = args.globalstatus and vim.go.columns or vim.fn.winwidth(0)
		local estimated_space_available = windwidth - args.trunc_width

		data = shorten_path(data, path_separator, estimated_space_available)
	end

	data = utils.stl_escape(data)

	local symbols = {}
	if args.file_status then
		if vim.bo.modified then
			table.insert(symbols, args.symbols.modified)
		end
		if vim.bo.modifiable == false or vim.bo.readonly == true then
			table.insert(symbols, args.symbols.readonly)
		end
	end

	if args.newfile_status and is_new_file() then
		table.insert(symbols, args.symbols.newfile)
	end

	return data .. (#symbols > 0 and " " .. table.concat(symbols, "") or "")
end

return create_component

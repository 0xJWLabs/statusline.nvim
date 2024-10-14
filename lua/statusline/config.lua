local M = {}

--- @type NeoVimStatuslineConfigurations
local config = {
	content = {
    --- @diagnostic disable-next-line
		active = nil,
    --- @diagnostic disable-next-line
		inactive = nil,
	},
	use_icons = false,
	set_vim_settings = true,
	disable_filetype = {},
}

function M.merge(conf)
  vim.validate({ conf = { conf, "table", true } })
  config = vim.tbl_deep_extend('force', config, conf or {})
  vim.validate({
		content = { config.content, "table" },
		set_vim_settings = { config.set_vim_settings, "boolean" },
		use_icons = { config.use_icons, "boolean" },
		disable_filetype = { config.disable_filetype, "table" },
	})

	vim.validate({
		["content.active"] = { config.content.active, "function", true },
		["content.inactive"] = { config.content.inactive, "function", true },
	})
end

function M.get()
  return config
end

return setmetatable(M, {
  __index = function(_, key)
    return config[key]
  end
})

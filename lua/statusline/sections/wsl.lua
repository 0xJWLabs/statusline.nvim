--- Section for WSL
---
---@return ... Section string and mode's highlight group.
return function()
	local utils = require("statusline.utils")
	local wsl_distro = utils.get_wsl_distro()
	local text = wsl_distro and "WSL: " .. wsl_distro or "›‹"
	return text, "NeoVimStatuslineWsl"
end

--- @class NeoVimStatuslineContent
--- Content of statusline as functions which return statusline string. See
--- `:h statusline` and code of default contents (used instead of `nil`).
--- @field active function The function to define the active statusline content.
--- @field inactive function The function to define the inactive statusline content.

--- @class NeoVimStatuslineContentOptional
--- @field active function? Optional function to define the active statusline content.
--- @field inactive function? Optional function to define the inactive statusline content.

--- @class NeoVimStatuslineOptions
--- @field content NeoVimStatuslineContentOptional? Optional statusline content definitions.
--- @field use_icons boolean? Optional flag to enable or disable icons in the statusline.
--- @field set_vim_settings boolean? Optional flag to set Vim's settings for the statusline (e.g., always shown).
--- @field disable_filetype string[]? Optional array of filetypes for which the statusline is disabled.

--- @class NeoVimStatuslineConfigurations
--- @field content NeoVimStatuslineContent Mandatory statusline content definitions.
--- @field use_icons boolean Flag to enable or disable icons in the statusline.
--- @field set_vim_settings boolean Flag to set Vim's settings for the statusline (e.g., always shown).
--- @field disable_filetype string[] Array of filetypes for which the statusline is disabled.

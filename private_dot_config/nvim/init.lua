if vim.g.vscode then
    vim.g.clipboard = vim.g.vscode_clipboard
else
    -- bootstrap lazy.nvim, LazyVim and your plugins
    require("config.lazy")
end

vim.opt.clipboard:append("unnamedplus")

-- no spell check for Chinese
-- vim.cmd([[
--   syntax match noSpellCJK /[\u4e00-\u9fff]\+/
--   highlight default link noSpellCJK Normal
-- ]])
vim.opt.spell = false

vim.opt.termguicolors = true

-- texts that exceed window width will show in the next line
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true -- keep indent when changing line
vim.opt.textwidth = 0

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.opt.clipboard:append("unnamedplus")

-- no spell check for Chinese
-- vim.cmd([[
--   syntax match noSpellCJK /[\u4e00-\u9fff]\+/
--   highlight default link noSpellCJK Normal
-- ]])
vim.opt.spell = false

vim.opt.termguicolors = true

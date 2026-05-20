-- A completion plugin for neovim
--
-- For configuration:
-- https://main.cmp.saghen.dev/installation
return {
    "saghen/blink.cmp",
    dependencies = {
        -- a necessary dependency
        "saghen/blink.lib",
    },
    build = function()
        -- build the fuzzy matcher, wait up to 60 seconds
        -- you can use `gb` in `:Lazy` to rebuild the plugin as needed
        require("blink.cmp").build():wait(60000)
    end,

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        -- 'super-tab' for mappings similar to vscode (tab to accept)
        keymap = { preset = "super-tab" },

        -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
        -- You may use a lua implementation instead by using `implementation = "lua"`
        fuzzy = { implementation = "rust" },
    },
}

-- Some note for lazyvim plugin system
--
-- The table above is analyzed by lazyvim as a "plugin spec",
-- Some fileds:
--  1. plugin name
--  2. dependencies: a table of all dependency plugins' names
--  2. opts: the parameter table for `require("xxx").setup()``
--
-- So the table is equivalent to:
-- require("saghen/blink.cmp").setup(opts)
--
-- Most neovim plugins follow the convention that a `opts` parameter is allowed
-- If you wonder what can be provided in `opts`, go to its documentation page.

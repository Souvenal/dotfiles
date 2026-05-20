-- nvim-lspconfig doesn't haave a `setup()` interface,
-- each server be separately setup like:
--   `require('lspconfig').clangd.setup({...})`
--
-- Luckily, lazyvim did the wrapping part with `PluginLspOpts`
return {
    {
        "neovim/nvim-lspconfig",
        ---@module "nvim-lspconfig"
        ---@type PluginLspOpts
        opts = {
            servers = {
                -- use local clangd
                clangd = {
                    mason = false,
                    cmd = { "clangd" },
                },
                -- pyright will be automatically installed with mason and loaded with lspconfig
                pyright = {},
            },
        },
    },
}

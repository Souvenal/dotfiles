return {
    -- add pyright to lspconfig
    {
        "neovim/nvim-lspconfig",
        ---@class PluginLspOpts
        opts = {
            ---@type lspconfig.options
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

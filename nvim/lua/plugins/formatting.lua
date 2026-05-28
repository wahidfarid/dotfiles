return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
      markdown = { "prettier" },
      handlebars = { "prettier" },
    },
    formatters = {
      prettier = {
        env = {
          PATH = vim.fn.expand("~/.local/share/mise/installs/node/18.20.8/bin") .. ":" .. vim.env.PATH,
        },
      },
    },
    format_on_save = {
      timeout_ms = 2000,
      lsp_fallback = true,
    },
  },
}

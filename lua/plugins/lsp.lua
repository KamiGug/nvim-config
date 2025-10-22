return {
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    opts = {},
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- 1️⃣ Add/override formatters by filetype
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        svelte = { "eslint_d" },
        typescript = { "eslint_d" },
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        html = { "prettier" },
        css = { "prettier" },
      })

      -- 2️⃣ Add/override formatter settings
      opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
        eslint_d = {
          condition = require("conform.util").root_file({
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.cjs",
            ".eslintrc.mjs",
            ".eslintrc.json",
            "eslint.config.js",
            "eslint.config.mjs",
            "eslint.config.cjs",
          }),
          cwd = require("conform.util").root_file({ "package.json" }),
        },
      })
    end,
  },
}

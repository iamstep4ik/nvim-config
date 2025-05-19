return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- Autocompletion with LSP
      { "antosha417/nvim-lsp-file-operations", config = true }, -- LSP file operations
      { "folke/neodev.nvim", opts = {} }, -- Lua development setup
    },
    config = function()
      -- Import the necessary plugins
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local keymap = vim.keymap -- for conciseness

      -- Create autocommand for LSP setup
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }

          -- Set key mappings for LSP features
          opts.desc = "Show LSP references"
          keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

          opts.desc = "Go to declaration"
          keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

          opts.desc = "Show LSP definitions"
          keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

          opts.desc = "Show LSP implementations"
          keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

          opts.desc = "Show LSP type definitions"
          keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

          opts.desc = "See available code actions"
          keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

          opts.desc = "Smart rename"
          keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

          opts.desc = "Show buffer diagnostics"
          keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

          opts.desc = "Show line diagnostics"
          keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

          opts.desc = "Go to previous diagnostic"
          keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

          opts.desc = "Go to next diagnostic"
          keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

          opts.desc = "Show documentation for what is under cursor"
          keymap.set("n", "K", vim.lsp.buf.hover, opts)

          opts.desc = "Restart LSP"
          keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
        end,
      })

      -- Capabilities for autocompletion (via cmp-nvim-lsp)
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Configure Diagnostic signs (gutter icons)
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- Configure mason-lspconfig
      mason_lspconfig.setup({
        ensure_installed = {
          "lua_ls", -- Lua LSP
          "pyright", -- Python LSP
          "html", -- HTML LSP
          "gopls", -- Go LSP
          "clangd", -- C/C++ LSP
        },
        automatic_installation = true, -- Automatically install missing servers
      })

      -- Configure individual LSP servers
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            completion = { callSnippet = "Replace" },
          },
        },
      })

      lspconfig.pyright.setup({
        capabilities = capabilities,
      })

      lspconfig.gopls.setup({
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = { unusedparams = true, shadow = true },
            staticcheck = true,
          },
        },
      })

      lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = { "clangd", "--background-index" },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        single_file_support = true,
        root_dir = lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
      })
    end,
  },
}

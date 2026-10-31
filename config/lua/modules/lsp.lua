local util = require("modules.util")
local nmap = util.nmap
local gh = util.gh

-- [[ LSP Configuration ]]
--  This function gets run when an LSP attaches to a particular buffer.
--    That is to say, every time a new file is opened that is associated
--    with an lsp e.g. opening `main.rs` is associated with `rust_analyzer`
--    this function will be executed to configure the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
  callback = function(event)
    local lsp = vim.lsp.buf

    nmap("gr", lsp.rename, "[G]oto [R]ename")
    nmap("ghh", lsp.hover, "[G]oto [H]over Documentation")
    nmap("gD", lsp.declaration, "[G]oto [D]eclaration")
    nmap("<leader>wa", lsp.add_workspace_folder, "[W]orkspace [A]dd Folder")
    nmap("<leader>wr", lsp.remove_workspace_folder, "[W]orkspace [R]emove Folder")
    nmap("<leader>wl", function()
      print(vim.inspect(lsp.list_workspace_folders()))
    end, "[W]orkspace [L]ist Folders")

    -- The two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests
    --   See `:help CursorHold` for information about when this is executed
    -- When you move your cursor, the highlights will be cleared
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method("textDocument/documentHighlight", event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({
            group = "kickstart-lsp-highlight",
            buffer = event2.buf,
          })
        end,
      })
    end

    -- The following code creates a keymap to toggle inlay hints
    if client and client:supports_method("textDocument/inlayHint", event.buf) then
      nmap("<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, "[T]oggle Inlay [H]ints")
    end
  end,
})

-- Diagnostic Config
--  See `:help vim.diagnostic.Opts`
vim.diagnostic.config({
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  },
  virtual_text = {
    source = "if_many",
    spacing = 2,
    format = function(diagnostic)
      return diagnostic.message
    end,
  },
})

-- Enable the following language servers
---@type table<string, vim.lsp.Config>
local servers = {
  ts_ls = {
    filetypes = {
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
  },
  eslint = {
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
    format = { enable = true },
  },
  html = { filetypes = { "html", "twig", "hbs" } },
  jsonls = { filetypes = { "json", "jsonc" } },
  vimls = { filetypes = { "vim" } },

  stylua = {}, -- Used to format Lua code

  -- Special Lua Config, as recommended by neovim help docs
  lua_ls = {
    on_init = function(client)
      -- Disable formatting (formatting is done by stylua)
      client.server_capabilities.documentFormattingProvider = false

      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if
          path ~= vim.fn.stdpath("config")
          and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
        then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend("force", (client.config.settings.Lua or {}) --[[@as table]], {
        runtime = {
          version = "LuaJIT",
          path = { "lua/?.lua", "lua/?/init.lua" },
        },
        workspace = {
          checkThirdParty = false,
          -- NOTE: this is a lot slower and will cause issues
          -- when working on your own configuration.
          --   See https://github.com/neovim/nvim-lspconfig/issues/3189
          library = vim.list_extend(vim.api.nvim_get_runtime_file("", true), {
            "${3rd}/luv/library",
            "${3rd}/busted/library",
          }),
        },
      })
    end,
    ---@type lspconfig.settings.lua_ls
    settings = {
      Lua = {
        -- Disable formatting (formatting is done by stylua)
        format = { enable = false },
      },
    },
  },
}

vim.pack.add({
  gh("neovim/nvim-lspconfig"),
  gh("mason-org/mason.nvim"),
  gh("mason-org/mason-lspconfig.nvim"),
  gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
})

-- Automatically install LSPs and related tools to stdpath for Neovim
require("mason").setup({})

-- Ensure the servers and tools above are installed
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  -- You can add other tools here that you want Mason to install
})

require("mason-tool-installer").setup({
  ensure_installed = ensure_installed,
})

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

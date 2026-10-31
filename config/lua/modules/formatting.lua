local M = {}
local util = require("modules.util")

function M.setup()
  local nmap = util.nmap
  local gh = util.gh

  vim.pack.add({ gh("prettier/vim-prettier") })

  vim.api.nvim_create_user_command("PrettierOrFormat", function()
    if vim.bo.filetype == "lua" then
      vim.cmd("silent !stylua " .. vim.fn.expand("%"))
      return
    end
    vim.cmd("silent! Prettier")
    if vim.v.shell_error ~= 0 then
      vim.lsp.buf.format()
    end
  end, {})

  nmap("<leader>f", ":PrettierOrFormat<CR>", "[F]ormat buffer")
end

return M

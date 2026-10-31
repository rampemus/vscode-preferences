local M = {}
local util = require("modules.util")

function M.setup()
  local nmap = util.nmap
  local tmap = util.tmap
  local gh = util.gh
  local map_terminal_edit = util.map_terminal_edit

  if not vim.g.started_by_firenvim then
    vim.pack.add({ gh("akinsho/nvim-toggleterm.lua") })

    require("toggleterm").setup({
      open_mapping = [[<C-w><C-t>]],
      auto_scroll = false,
      start_in_insert = false,
    })

    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*toggleterm#*",
      callback = function(args)
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"

        tmap("<Esc>", [[<C-\><C-n>]], "Exit terminal mode", args.buf)
        map_terminal_edit(args.buf, "\1")

        nmap("git", "igit", "Start git command", args.buf)

        nmap(":write", function()
          vim.cmd((vim.b.toggle_number + 1) .. "ToggleTerm")
        end, "Split terminal", args.buf)

        local function term_exec(cmd)
          vim.cmd(
            vim.b.toggle_number
              .. "TermExec cmd='"
              .. cmd
              .. " "
              .. vim.fn.expand("<cWORD>")
              .. "' go_back=0"
          )
        end

        nmap("gc", function()
          term_exec("git checkout")
        end, "Go checkout branch under cursor", args.buf)
        nmap("gd", function()
          term_exec("trash")
        end, "Go delete", args.buf)
      end,
    })
  end
end

return M

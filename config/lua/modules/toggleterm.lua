local util = require("modules.util")
local nmap = util.nmap
local tmap = util.tmap
local gh = util.gh
local map_terminal_edit = util.map_terminal_edit

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

    -- Catch :w/:write on - covers Ghostty cmd+s, which sends ":write\n"
    for _, key in ipairs({ "<CR>", "<NL>" }) do
      vim.keymap.set("c", key, function()
        local line = vim.fn.getcmdline()
        if vim.fn.getcmdtype() ~= ":" or (line ~= "w" and line ~= "write") then
          return "<CR>"
        end
        vim.schedule(function()
          vim.cmd((vim.b.toggle_number + 1) .. "ToggleTerm")
        end)
        return "<C-c>"
      end, { expr = true, desc = "Split terminal on :write", buffer = args.buf })
    end

    local function term_exec(cmd)
      vim.cmd(vim.b.toggle_number .. "TermExec cmd='" .. cmd .. " " .. vim.fn.expand("<cWORD>") .. "' go_back=0")
    end

    nmap("gc", function()
      term_exec("git checkout")
    end, "Go checkout branch under cursor", args.buf)
    nmap("gd", function()
      term_exec("trash")
    end, "Go delete", args.buf)
  end,
})

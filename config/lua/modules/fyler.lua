local util = require("modules.util")
local center = util.center
local gh = util.gh
local center_windows_with_buffer = util.center_windows_with_buffer

vim.pack.add({
  gh("A7Lavinraj/fyler.nvim"),
  gh("nvim-tree/nvim-web-devicons"),
})

local function get_abs_path(instance)
  local state = require("fyler.state")

  -- Fyler prefixes line with a numeric id (e.g. "00023 init.lua")
  -- that maps back to the fs entry in fyler.state's store
  -- grab the raw line under the cursor to extract that id.
  local buf_line = vim.api.nvim_buf_call(instance.buf_id, function()
    return vim.api.nvim_get_current_line()
  end)
  local id = buf_line:match("(%d+)")
  if not id then
    return
  end

  -- Look up file/dir entry (with its absolute path) for this id.
  local node_data = state.store[tonumber(id, 10)]
  if not node_data then
    return
  end

  return node_data.path
end

local function get_rel_path(instance)
  local abs_path = get_abs_path(instance)
  if not abs_path then
    return
  end
  return require("fyler.lib.path").to_rel(instance.opts.root_path, abs_path)
end

require("fyler").setup({
  integrations = {
    icon = "nvim_web_devicons",
    window_picker = function()
      local windows = vim.fn.getwininfo()
      for _, win in ipairs(windows) do
        local buf = win.bufnr
        if vim.fn.UtilFiletype(buf) then
          return win.winid
        end
      end
      return nil
    end,
  },
  kind = "split_left_most",
  kind_presets = {
    split_left_most = {
      width = center(vim.o.columns),
      win_opts = {
        cursorline = true,
        number = false,
        relativenumber = false,
      },
    },
  },
  auto_confirm_simple_mutation = true,
  use_as_default_explorer = true,
  follow_current_file = true,
  extensions = {
    watcher = { enabled = true },
  },
  ui = {
    hidden_items = {
      always_hidden = { ".DS_Store" },
    },
  },
  mappings = {
    n = {
      ["q"] = { disabled = true },
      ["<C-T>"] = { disabled = true },
      ["."] = { disabled = true },
      ["g."] = { disabled = true },
      ["<C-v>"] = { disabled = true },
      ["<C-x>"] = { action = "open", args = { split = "split" } },
      ["<C-.>"] = { action = "toggle_ui", args = { "hidden_items" } },
      ["<S-CR>"] = { action = "select", args = { pick = true } },
      ["-"] = { action = "shrink", args = { parent = true } },
      ["<BS>"] = { action = "visit", args = { parent = true } },
      ["<D-c>"] = {
        action = function(instance)
          local relative_path = get_rel_path(instance)
          if not relative_path then
            return
          end
          vim.fn.setreg("+", relative_path)
          vim.g.clipboard_status = relative_path
        end,
      },
      ["<C-o>"] = {
        action = function(instance)
          local abs_path = get_abs_path(instance)
          if not abs_path then
            return
          end
          vim.fn.jobstart({ "open", abs_path }, { detach = true })
        end,
      },
    },
  },
})

vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    center_windows_with_buffer("fyler_finder")
    ---@diagnostic disable-next-line: assign-type-mismatch
    require("fyler.config").DATA.kind_presets.split_left_most.width = center(vim.o.columns)
    vim.cmd("wincmd =")
  end,
})

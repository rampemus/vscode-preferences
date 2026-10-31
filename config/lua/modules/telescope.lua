local util = require("modules.util")
local nmap = util.nmap
local gh = util.gh

---@type (string|vim.pack.Spec)[]
local telescope_plugins = {
  gh("nvim-lua/plenary.nvim"),
  gh("nvim-telescope/telescope.nvim"),
  gh("nvim-telescope/telescope-ui-select.nvim"),
}
if vim.fn.executable("make") == 1 then
  table.insert(telescope_plugins, gh("nvim-telescope/telescope-fzf-native.nvim"))
end
vim.pack.add(telescope_plugins)

local function filenameFirst(_, path)
  local tail = vim.fs.basename(path)
  local parent = vim.fs.dirname(path)
  if parent == "." then
    return tail
  end
  local project_root = vim.fn.getcwd()
  local user_root = vim.fn.expand("~")
  parent = parent:gsub("^" .. vim.pesc(project_root), ".")
  parent = parent:gsub("^" .. vim.pesc(user_root), "~")
  if parent == "." then
    return tail
  end
  return string.format("%s\t\t%s", tail, parent)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "TelescopeResults",
  callback = function(ctx)
    vim.api.nvim_buf_call(ctx.buf, function()
      vim.fn.matchadd("TelescopeParent", "\t\t.*$")
      vim.api.nvim_set_hl(0, "TelescopeParent", { link = "Comment" })
    end)
  end,
})

require("telescope").setup({
  defaults = {
    file_ignore_patterns = { ".git/" },
    mappings = {
      i = {
        ["<esc>"] = require("telescope.actions").close,
        ["<C-p>"] = require("telescope.actions").cycle_history_prev,
        ["<C-n>"] = require("telescope.actions").cycle_history_next,
      },
    },
    sorting_strategy = "ascending",
    layout_config = { prompt_position = "top" },
    path_display = filenameFirst,
  },
  extensions = {
    ["ui-select"] = { require("telescope.themes").get_cursor() },
  },
  pickers = {
    git_status = {
      attach_mappings = function()
        require("telescope.actions").select_default:enhance({
          post = function()
            local current_file = vim.fn.expand("%")
            local diff = vim.fn.system("git diff -- " .. current_file)
            local firstLineChanged = string.match(diff, "@@ %-(%d+)")
            if firstLineChanged then
              vim.cmd("normal! " .. firstLineChanged .. "G3jzt")
            end
          end,
        })
        return true
      end,
    },
    find_files = {
      on_input_filter_cb = function(prompt)
        -- Order matters: ":L" before plain ":"
        local patterns = {
          "^(.-):L(%d*)",
          "^(.-)%((%d*)",
          "^(.-) on line (%d*)",
          "^(.-):(%d*)",
        }
        for _, pattern in ipairs(patterns) do
          local file, lnum = string.match(prompt, pattern)
          if file then
            vim.g.telescope_find_files_line = tonumber(lnum)
            return { prompt = file }
          end
        end
        vim.g.telescope_find_files_line = nil
      end,
      attach_mappings = function()
        require("telescope.actions").select_default:enhance({
          post = function()
            if vim.g.telescope_find_files_line then
              vim.api.nvim_win_set_cursor(0, { vim.g.telescope_find_files_line, 0 })
              vim.g.telescope_find_files_line = nil
            end
          end,
        })
        return true
      end,
    },
    oldfiles = {
      attach_mappings = function()
        require("telescope.actions").select_default:enhance({
          post = function()
            vim.cmd("silent! normal! `.")
            if vim.fn.line(".") == 1 then
              vim.cmd('silent! normal! `"')
            end
          end,
        })
        return true
      end,
    },
  },
})

pcall(require("telescope").load_extension, "fzf")
pcall(require("telescope").load_extension, "ui-select")

-- Telescope LSP keymaps on attach
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
  callback = function(event)
    local buf = event.buf
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })
    vim.keymap.set("n", "gad", builtin.lsp_references, { buffer = buf, desc = "[G]oto References" })
    vim.keymap.set("n", "gI", builtin.lsp_implementations, { buffer = buf, desc = "[G]oto [I]mplementation" })
    vim.keymap.set("n", "<leader>D", builtin.lsp_type_definitions, { buffer = buf, desc = "Type [D]efinition" })
    vim.keymap.set("n", "gs", builtin.lsp_document_symbols, { buffer = buf, desc = "[D]ocument [S]ymbols" })
    vim.keymap.set(
      "n",
      "gas",
      builtin.lsp_dynamic_workspace_symbols,
      { buffer = buf, desc = "[A]ll workspace [S]ymbols" }
    )
  end,
})

-- Telescope keymaps
local builtin = require("telescope.builtin")
nmap("<leader>o", builtin.oldfiles, "[o] Find recently opened files")
nmap("<leader><space>", builtin.builtin, "[ ] Find existing buffers")
nmap("<leader>ö", function()
  builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
    winblend = 10,
    previewer = false,
  }))
end, "[ö] Fuzzily search in current buffer")
nmap("<leader>sr", builtin.resume, "[S]earch [R]esume")

-- User commands
local function gitStatus()
  if vim.bo.filetype == "fyler_finder" then
    vim.cmd("BufferLineCycleNext")
  end
  local changed = vim.fn.systemlist("git diff --name-only")
  local staged = vim.fn.systemlist("git diff --cached --name-only")
  if #changed == 0 and #staged == 0 then
    builtin.git_commits()
  else
    builtin.git_status()
  end
end
vim.api.nvim_create_user_command("GitStatus", gitStatus, {})

vim.api.nvim_create_user_command("TelescopeGrep", function()
  if vim.bo.filetype == "fyler_finder" then
    vim.cmd("BufferLineCycleNext")
  end
  builtin.live_grep({
    additional_args = { "--fixed-strings", "--hidden" },
  })
end, {})

vim.api.nvim_create_user_command("TelescopeFindFiles", function()
  if vim.bo.filetype == "fyler_finder" then
    vim.cmd("BufferLineCycleNext")
  end
  builtin.find_files({ sort_mtime = true, hidden = true })
end, {})

vim.api.nvim_create_user_command("CodeActionFixAll", function()
  vim.lsp.buf.code_action({
    filter = function(action)
      local title = action.title or (action.command and action.command.title)
      return title ~= nil and string.find(title, "Fix all auto") ~= nil
    end,
    apply = true,
  })
end, {})

nmap("<leader>l", ":CodeActionFixAll<CR>", "[L]int buffer")

vim.api.nvim_create_user_command("CodeActionOpen", function()
  vim.lsp.buf.code_action({ layout = "cursor" })
end, {})

local function find_git_root()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir = current_file == "" and vim.fn.getcwd() or vim.fn.fnamemodify(current_file, ":h")
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not a git repository. Searching on current working directory")
    return vim.fn.getcwd()
  end
  return git_root
end

vim.api.nvim_create_user_command("LiveGrepGitRoot", function()
  if vim.bo.filetype == "fyler_finder" then
    vim.cmd("BufferLineCycleNext")
  end
  local git_root = find_git_root()
  if git_root then
    builtin.live_grep({ search_dirs = { git_root } })
  end
end, {})

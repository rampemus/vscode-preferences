local util = require("modules.util")
local gh = util.gh
local SPINNER_FRAMES = util.SPINNER_FRAMES

vim.pack.add({ gh("nvim-lualine/lualine.nvim") })

if not vim.g.started_by_firenvim then
  local spinners = SPINNER_FRAMES

  local function split(str, char)
    local comma_index = string.find(str, char)
    if comma_index then
      return string.sub(str, 1, comma_index - 1)
    else
      return str
    end
  end

  local function lsp_progress()
    local status = vim.lsp.status():gsub("%%", "%%%%")
    if status ~= "" then
      vim.g.lsp_progress_status = status
      vim.g.lsp_progress_spinner = (vim.g.lsp_progress_spinner or 0) % #spinners + 1
      return spinners[vim.g.lsp_progress_spinner or 1] .. " " .. split(vim.g.lsp_progress_status, ",")
    end
    if vim.g.lsp_progress_spinner and vim.g.lsp_progress_spinner > 1 then
      vim.g.lsp_progress_spinner = (vim.g.lsp_progress_spinner or 0) % #spinners + 1
      return spinners[vim.g.lsp_progress_spinner or 1] .. " " .. split(vim.g.lsp_progress_status, ",")
    end
    return ""
  end

  local function selection()
    local mode = vim.fn.mode()
    if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
      return ""
    end

    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end

    if mode == "v" and start_line == end_line then
      local start_col = vim.fn.col("v")
      local end_col = vim.fn.col(".")
      if start_col > end_col then
        start_col, end_col = end_col, start_col
      end
      local chars = end_col - start_col + 1
      return chars .. (chars == 1 and " char" or " chars")
    end

    local count = end_line - start_line + 1
    return count .. " lines"
  end

  local function qf()
    local qf_list = vim.fn.getqflist()
    local qf_name = vim.fn.get(vim.fn.getqflist({ title = 1 }), "title")
    qf_name = qf_name:gsub(" %(%)", "")
    if #qf_list > 0 then
      local qf_index = vim.fn.get(vim.fn.getqflist({ idx = 0 }), "idx", 0)
      return qf_name .. " " .. qf_index .. "/" .. #qf_list
    end
    return ""
  end

  local function record()
    return vim.fn.reg_recording()
  end

  local function claude_running()
    local label = vim.fn.executable("claude") == 1 and "CLAUDE" or "COPILOT"
    local yes = vim.g.claude_yes and " -y" or ""
    return vim.g.claude_running and label .. yes or ""
  end

  -- Green while Claude is running idle, red while it is generating a
  -- response (toggled by _G.ClaudeSetGenerating via Claude Code hooks).
  local function claude_color()
    return vim.g.claude_generating and { bg = "#f65866" } or { bg = "#98c379" }
  end

  local function copilot()
    local clients = vim.lsp.get_clients({ bufnr = 0, name = "copilot" })
    if #clients == 0 then
      return ""
    end
    local bufnr = vim.api.nvim_get_current_buf()
    for _, client in ipairs(clients) do
      for _, request in pairs(client.requests) do
        if
          request.type == "pending"
          and request.bufnr == bufnr
          and request.method == "textDocument/inlineCompletion"
        then
          vim.g.copilot_spinner = (vim.g.copilot_spinner or 0) % #spinners + 1
          return spinners[vim.g.copilot_spinner]
        end
      end
    end
    return vim.lsp.inline_completion.is_enabled({ bufnr = 0 }) and "" or ""
  end

  local function clipboard()
    local message = vim.g.clipboard_status
    if message ~= "" then
      vim.defer_fn(function()
        if vim.g.clipboard_status == message then
          vim.g.clipboard_status = ""
        end
      end, 2000)
      return "  " .. vim.g.clipboard_status
    end
    return ""
  end

  require("lualine").setup({
    options = {
      icons_enabled = true,
      theme = "onedark",
      component_separators = { left = " ", right = " " },
      section_separators = { left = " ", right = " " },
      always_divide_middle = true,
      globalstatus = true,
      refresh = {
        statusline = 100,
      },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff" },
      lualine_c = { "diagnostics", clipboard, qf, lsp_progress },
      lualine_x = { selection, "location", "encoding", "fileformat" },
      lualine_y = { "filetype", copilot },
      lualine_z = {
        { record, color = { bg = "#f65866" } },
        { claude_running, color = claude_color },
      },
    },
  })
end

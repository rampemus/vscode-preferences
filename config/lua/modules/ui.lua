local M = {}
local util = require("modules.util")

function M.setup()
  local nmap = util.nmap
  local vmap = util.vmap
  local gh = util.gh

  -- [[ Installing and Configuring Plugins ]]

  -- vim-fanfingtastic: extend f/t motions across lines
  vim.pack.add({ gh("dahu/vim-fanfingtastic") })

  -- vim-yankstack: yank history with cycle paste
  vim.g.yankstack_map_keys = 0
  vim.pack.add({ gh("maxbrunsfeld/vim-yankstack") })
  vim.fn["yankstack#setup"]()
  nmap(
    "<C-p>",
    "<Plug>yankstack_substitute_older_paste",
    "Substitute older paste"
  )
  nmap(
    "<C-n>",
    "<Plug>yankstack_substitute_newer_paste",
    "Substitute newer paste"
  )
  vim.keymap.set(
    "n",
    "Y",
    "y$",
    { silent = true, remap = true, desc = "Yank to end of line" }
  )

  -- A more advanced configuration example that passes options to gitsigns
  if not vim.g.started_by_firenvim then
    vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
    require("gitsigns").setup({
      signs = {
        add = { text = "▎" }, ---@diagnostic disable-line: missing-fields
        change = { text = "▎" }, ---@diagnostic disable-line: missing-fields
        delete = { text = "▁" }, ---@diagnostic disable-line: missing-fields
        ---@diagnostic disable-next-line: missing-fields
        topdelete = { text = "▔" },
        ---@diagnostic disable-next-line: missing-fields
        changedelete = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        -- visual mode
        vmap("ghs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage git hunk")
        vmap("ghu", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset git hunk")
        -- normal mode
        nmap("ghs", gs.stage_hunk, "git stage hunk")
        nmap("ghS", gs.stage_buffer, "git stage buffer")
        nmap("ghu", gs.reset_hunk, "git reset hunk")
        nmap("ghU", gs.reset_buffer_index, "git reset buffer index")
        nmap("ghn", gs.next_hunk, "next git hunk")
        nmap("ghp", gs.prev_hunk, "prev git hunk")
        nmap("ghb", function()
          gs.blame_line({ full = false })
        end, "git blame line")
        nmap("<leader>gd", function()
          require("bufferline").move_to(-1)
          local changed = vim.fn.systemlist("git diff --name-only")
          local staged = vim.fn.systemlist("git diff --cached --name-only")
          local offset = #changed == 0 and #staged == 0 and 1 or 0
          gs.diffthis("HEAD~" .. vim.v.count + offset)
          vim.defer_fn(function()
            require("bufferline").move_to(-1)
          end, 200)
        end, "git diff current file against first/nth commit")
        nmap(
          "<leader>gb",
          gs.toggle_current_line_blame,
          "Toggle git blame line"
        )

        vim.keymap.set(
          { "o", "x" },
          "ih",
          ":<C-U>Gitsigns select_hunk<CR>",
          { desc = "Select git hunk", buffer = bufnr }
        )
      end,
    })

    -- diffview.nvim: split diff view for all changed files
    vim.pack.add({ gh("sindrets/diffview.nvim") })
    local actions = require("diffview.actions")
    -- Append total line stats to file panel section titles, e.g. "Changes (3) +12 -4"
    local render_panel = require("diffview.scene.views.diff.render")
    package.loaded["diffview.scene.views.diff.render"] = function(panel)
      render_panel(panel)
      for _, kind in ipairs({ "conflicting", "working", "staged" }) do
        local comp = panel.components[kind].title.comp
        local line = comp.lines[1]
        local additions, deletions, has_stats = 0, 0, false
        for _, file in ipairs(panel.files[kind]) do
          if file.stats and file.stats.additions then
            has_stats = true
            additions = additions + file.stats.additions
            deletions = deletions + file.stats.deletions
          end
        end
        if line and has_stats then
          local ins, del = " +" .. additions, " -" .. deletions
          comp:add_hl("DiffviewFilePanelInsertions", 0, #line, #line + #ins)
          comp:add_hl(
            "DiffviewFilePanelDeletions",
            0,
            #line + #ins,
            #line + #ins + #del
          )
          comp.lines[1] = line .. ins .. del
        end
      end
    end
    require("diffview").setup({
      hooks = {
        diff_buf_win_enter = function(_, winid)
          vim.wo[winid].winbar = " "
        end,
        view_enter = function()
          require("bufferline.config").options.auto_toggle_bufferline = false
          vim.o.showtabline = 0
        end,
        view_leave = function()
          require("bufferline.config").options.auto_toggle_bufferline = true
          vim.o.showtabline = 2
        end,
      },
      keymaps = {
        view = {
          {
            "n",
            "-",
            actions.focus_files,
            { desc = "Bring focus to the file panel" },
          },
          -- override tab to move indent to right as >>
          {
            "n",
            "<tab>",
            function()
              vim.cmd("normal! >>")
            end,
            { desc = "Indent right" },
          },
          {
            "n",
            "<s-tab>",
            function()
              vim.cmd("normal! <<")
            end,
            { desc = "Indent left" },
          },
        },
        file_panel = {
          {
            "n",
            "<tab>",
            actions.toggle_stage_entry,
            { desc = "Stage / unstage the selected entry" },
          },
          {
            "n",
            "<cr>",
            function()
              actions.select_entry()
              vim.api.nvim_set_current_win(vim.fn.win_getid(vim.fn.winnr("$")))
              if vim.fn.line(".") == 1 then
                require("gitsigns").nav_hunk("first")
              end
            end,
            { desc = "Open the diff for the selected entry" },
          },
          {
            "n",
            "<D-c>",
            function()
              local view = require("diffview.lib").get_current_view() --[[@as DiffView?]]
              local item = view and view:infer_cur_file(true)
              if not item then
                return
              end
              vim.fn.setreg("+", item.path)
              vim.g.clipboard_status = item.path
            end,
            { desc = "Copy relative path of the selected entry" },
          },
          -- Disable h and l actions
          {
            "n",
            "h",
            false,
          },
          {
            "n",
            "l",
            false,
          },
        },
      },
    })
    nmap("<leader>gad", function()
      vim.cmd(
        vim.v.count and "DiffviewOpen HEAD~" .. vim.v.count or "DiffviewOpen"
      )
    end, "git diff against first/nth commit")
    nmap("<leader>gab", function()
      local function exists(r)
        vim.fn.system("git rev-parse --verify --quiet " .. r)
        return vim.v.shell_error == 0
      end
      -- Use staging if exists
      local ref = exists("origin/staging") and "origin/staging"
        or vim.fn.systemlist(
          "git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null"
        )[1]
      if not ref or ref == "" then
        ref = exists("main") and "main" or "master"
      end
      local base = vim.fn.systemlist("git merge-base HEAD " .. ref)[1]
      vim.cmd("DiffviewOpen " .. (vim.v.shell_error == 0 and base or ref))
    end, "git diff against default branch")

    -- blame.nvim: git blame overlay (disabled in firenvim)
    vim.pack.add({ gh("FabijanZulj/blame.nvim") })
    require("blame").setup({
      date_format = "%d.%m.%Y %H:%M",
      mappings = {
        commit_info = "ghh",
        show_commit = "o",
        close = {},
        stack_push = {},
        stack_pop = {},
        basic = true,
        extra = true,
      },
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "BlameViewOpened",
      callback = function(event)
        if event.data == "window" then
          require("barbecue.ui").toggle(false)
        end
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "BlameViewClosed",
      callback = function(event)
        if event.data == "window" then
          require("barbecue.ui").toggle(true)
        end
      end,
    })

    -- Useful plugin to show you pending keybinds.
    vim.pack.add({ gh("folke/which-key.nvim") })
    require("which-key").setup({
      -- Delay between pressing a key and opening which-key (milliseconds)
      delay = 400,
      icons = { mappings = vim.g.have_nerd_font },
      -- Document existing key chains
      spec = {
        { "<leader>s", group = "[S]earch", mode = { "n", "v" } },
        { "<leader>t", group = "[T]oggle" },
        -- Enable gitsigns recommended keymaps first
        { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
        { "gr", group = "LSP Actions", mode = { "n" } },
      },
    })
  end

  -- [[ Colorscheme ]]
  vim.pack.add({ gh("navarasu/onedark.nvim") })
  require("onedark").setup({
    highlights = {
      -- Guides
      ["FylerIndentMarker"] = { fg = "#383a42" },
      ["CursorLine"] = { bg = "#2e323c" },
      ["IblIndent"] = { fg = "#34373e" },
      -- Red comments
      ["@comment"] = { fg = "#a14646", fmt = "italic" },
      ["@comment.documentation"] = { fg = "#a14646", fmt = "italic" },
      ["@lsp.type.comment"] = { fg = "#a14646", fmt = "italic" },
      ["confComment"] = { fg = "#a14646", fmt = "italic" },
      ["cssComment"] = { fg = "#a14646", fmt = "italic" },
      ["dockerfileComment"] = { fg = "#a14646", fmt = "italic" },
      ["htmlComment"] = { fg = "#a14646", fmt = "italic" },
      ["jsonComment"] = { fg = "#a14646", fmt = "italic" },
      ["sqlComment"] = { fg = "#a14646", fmt = "italic" },
      ["shComment"] = { fg = "#a14646", fmt = "italic" },
      ["xmlComment"] = { fg = "#a14646", fmt = "italic" },
      ["xmlCommentPart"] = { fg = "#a14646", fmt = "italic" },
      ["yamlComment"] = { fg = "#a14646", fmt = "italic" },
      ["zshComment"] = { fg = "#a14646", fmt = "italic" },
      -- Highlight search hls
      ["Search"] = { bg = "#404255", fg = "none" },
      ["IncSearch"] = { bg = "#404255", fg = "none" },
      ["CurSearch"] = { bg = "#404255", fg = "none" },
      ["Substitute"] = { bg = "#404255", fg = "none" },
    },
  })
  vim.cmd.colorscheme("onedark")

  -- Highlight todo, notes, etc in comments
  vim.pack.add({ gh("folke/todo-comments.nvim") })
  require("todo-comments").setup({ signs = false })

  -- Add/delete/replace surroundings (brackets, quotes, etc.)
  vim.pack.add({ gh("tpope/vim-surround") })

  -- barbecue.nvim: winbar breadcrumbs (disabled in firenvim)
  if not vim.g.started_by_firenvim then
    vim.pack.add({
      gh("utilyre/barbecue.nvim"),
      gh("SmiteshP/nvim-navic"),
    })
    require("barbecue").setup({
      exclude_filetypes = { "fyler", "fyler_finder", "toggleterm", "" },
      theme = {
        normal = { bg = "#282c34" },
      },
    })
  end
end

return M

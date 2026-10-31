# Plan: split `config/init.lua` into Lua modules

## Goal

Split the 2393-line `config/init.lua` into small modules. Each `do ... end`
block (SECTION 1–16) moves to its own file. Shared helpers move to `util.lua`.
Every module uses the `M = {}` pattern. All `.sh` scripts follow the new layout.

## Nvim docs reference

- `:help lua-guide-modules` — `require()` loads `lua/<name>.lua` or
  `lua/<name>/init.lua` from any `runtimepath` dir (`~/.config/nvim/lua/`).
- `:help lua-require` / `:help package.loaded` — module is cached after first
  `require`; returned table is the module value.
- `:help vim.loader` — already enabled in SECTION 1; caches compiled modules.
- Convention: `local M = {}` ... `return M`. Expose `M.setup()` per module.
- Namespace modules to avoid clashes with plugin names, e.g. `modules.*`
  (`require("modules.lsp")`). Do not name a file like a plugin (`lsp`, `lualine`).

## Target layout

```
config/
  init.lua                  -- entry: leaders, sources .vim files, requires modules
  lua/modules/
    util.lua                -- shared helpers
    options.lua             -- SECTION 1
    keymaps.lua             -- SECTION 2
    pack.lua                -- SECTION 3  plugin manager intro, build hooks
    ui.lua                  -- SECTION 4
    telescope.lua           -- SECTION 5
    lsp.lua                 -- SECTION 6
    formatting.lua          -- SECTION 7
    completion.lua          -- SECTION 8
    treesitter.lua          -- SECTION 9
    fyler.lua               -- SECTION 10
    toggleterm.lua          -- SECTION 11
    bufferline.lua          -- SECTION 12
    lualine.lua             -- SECTION 13
    visuals.lua             -- SECTION 14
    firenvim.lua            -- SECTION 15
    copilot.lua             -- SECTION 16
```

## `util.lua` contents (from top of init.lua, lines 1–257)

- `nmap`, `tmap`, `vmap` keymap helpers
- `center(columns)`
- `gh(repo)`
- `SPINNER_FRAMES`
- `center_windows_with_buffer(filetype)`
- terminal edit helpers (`edit_line` and the terminal normal-mode mappings
  block, ~lines 30–237), exposed as functions the sections call
- Any other top-level `local` used by 2+ sections (check with grep before moving)

Pattern:

```lua
local M = {}

function M.nmap(l, r, desc, buffer) ... end
function M.gh(repo) return "https://github.com/" .. repo end

return M
```

## Module pattern

```lua
local M = {}
local util = require("modules.util")

function M.setup()
  -- body of former do-block, with `local nmap = util.nmap` etc. at top
end

return M
```

`init.lua` calls `require("modules.<name>").setup()` in the original section
order. Order matters: options → keymaps → pack → plugins → lsp → ui.

## Steps

1. Baseline: run `nvim --headless +qa` with current `init.lua`; note errors/warnings.
2. Create `config/lua/modules/util.lua`. Move shared locals. Export via `M`.
3. For each section 1–16, create its module with `M.setup()`. Replace the
   `do`/`end` with the function body. Add `local x = util.x` aliases for used helpers.
4. Fix cross-section dependencies (locals defined in one `do` and used later;
   `vim.g.started_by_firenvim` guards stay in the module).
5. Reduce `init.lua` to: diagnostic header, leaders, `vim.cmd("source ...")`
   lines, firenvim branch, then ordered `require(...).setup()` calls.
6. Update `stylua.toml` usage if paths matter; run `stylua config/` if available.
7. Update shell scripts (below).
8. Update `README.md` (structure + `init.lua` mentions) and
   `.github/copilot-instructions.md` repo-structure section.
9. Verify (below).

## Shell script updates

Destination: `~/.config/nvim/lua/modules/*.lua`.

### `nvimsync.sh`
- `--init` block: `mkdir -p ~/.config/nvim/lua/modules`.
- Replace single `cp ./config/init.lua` with:
  `cp ./config/init.lua ~/.config/nvim/init.lua` (entry stays)
  plus `rm -rf ~/.config/nvim/lua && mkdir -p ~/.config/nvim/lua/modules && cp ./config/lua/modules/*.lua ~/.config/nvim/lua/modules/`
  (rm first so deleted modules do not linger).
- Keep ordering: Plug phase deploys `init.vim` and removes `init.lua`; lua
  modules deploy only in the final lazy/vim.pack phase. Plug phase must not see
  the `lua/` dir requiring plugins — check vscode-neovim ignores it (init.vim
  never requires `modules.*`).

### `nvimupdate.sh`
- Final step also copies `./config/lua/modules/*.lua` to `~/.config/nvim/lua/modules/`.
- `nvim --headless "+packupdate" +qa` must run after modules exist.
- Lock file copy-back unchanged.

### `nvimremove.sh`
- Add `rm -rf ~/.config/nvim/lua`.
- Also remove stale duplicate `firenvim.vim` line and `lua.vim` (does not exist) — only if touching that block.

### `nvimfispell.sh`, `nvimfispelladd.sh`
- Check for `init.lua` / path references; update only if they reference moved code.

## Verification

- `nvim --headless +qa` → no errors (compare with baseline).
- `nvim --headless "+lua print(vim.inspect(vim.tbl_keys(package.loaded)):find('util'))" +qa`
- `:checkhealth vim.lsp`, open a `.ts` file: LSP attach, telescope, fyler, lualine, copilot load.
- `NVIM_APPNAME` test: run `./nvimsync.sh` into a scratch dir first if possible.
- Firenvim path: `nvim --cmd "let g:started_by_firenvim=1" --headless +qa`.
- `./nvimremove.sh` then `./nvimsync.sh --init` on clean state works.

## Risks

- Locals shared across `do` blocks (e.g. `center`, `gh`, `nmap`) — missed alias gives nil errors.
- `vim.pack.add` order and `PackChanged` build hooks in pack module must register before plugins load.
- vscode-neovim Plug phase: `lua/` dir on runtimepath is harmless but confirm.
- `vim.loader.enable()` must stay first, in `options.lua` or at top of `init.lua`.

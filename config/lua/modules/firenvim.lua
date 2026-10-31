local util = require("modules.util")
local gh = util.gh

-- glacambre/firenvim: loads normally when started by firenvim,
-- otherwise just installed in the background for browser extension use.
vim.pack.add({ gh("glacambre/firenvim") })

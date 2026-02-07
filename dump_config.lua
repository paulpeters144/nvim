local config = require("codecompanion.config")
local f = io.open("codecompanion_config_dump.txt", "w")
if f then
  f:write(vim.inspect(config))
  f:close()
end

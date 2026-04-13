-- require("opim").setup()
local timer = (vim.uv or vim.loop).new_timer()
timer:start(
  500,
  0,
  vim.schedule_wrap(function()
    local opim = require("opim")
    if not opim.did_setup then
      opim.setup()
    end
  end)
)

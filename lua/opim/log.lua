---@class Opim.Log
local M = {}

local enabled = false
local log_path = nil ---@type string?

--- Initialise the logger. Called once from setup().
--- When debug = true, all subsequent M.debug() calls write to opim.log in the cwd.
---@param debug boolean
function M.init(debug)
  enabled = debug
  if not enabled then return end
  log_path = vim.fn.getcwd() .. "/opim.log"
  local file = io.open(log_path, "a")
  if not file then
    vim.notify("opim: could not open " .. log_path .. " for debug logging", vim.log.levels.WARN)
    enabled = false
    return
  end
  file:write(("\n[%s] ── opim.nvim debug session started ──\n"):format(os.date("%Y-%m-%d %H:%M:%S")))
  file:close()
end

--- Write a debug line to opim.log. No-op when debug = false.
---@param msg string
function M.debug(msg)
  if not enabled or not log_path then return end
  local file = io.open(log_path, "a")
  if not file then return end
  file:write(("[%s] %s\n"):format(os.date("%H:%M:%S"), msg))
  file:close()
end

return M

---@class Opim
---@field is_setup boolean
---@field is_error boolean
---@field config Opim.Config
local M = {}

local defaults = require("opim.config").defaults
local utils = require("opim.utils")
local log = require("opim.log")

M.is_setup = false
M.is_error = false

---@param opts? Opim.Opts
function M.setup(opts)
  if not utils.has_treesitter() then
    M.is_error = true
    return vim.notify(
      "TreeSitter is not available in this Neovim build. Opim requires TreeSitter to function.",
      vim.log.levels.ERROR,
      { title = "Opim" }
    )
  end
  M.is_setup = true
  M.config = vim.tbl_deep_extend("force", {}, defaults, opts or {}) --[[@as Opim.Config]]
  log.init(M.config.debug)
  log.debug("setup() called")
  log.debug("config: " .. vim.inspect(M.config))
  require("opim.keymap").setup(M.config)
end

return M

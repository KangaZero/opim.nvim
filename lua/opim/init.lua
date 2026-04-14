---@class Opim
---@field is_setup boolean
---@field is_error boolean
---@field config Opim.Config
local M = {}

---@type Opim.ConfigModule
local config = require("opim.config")
---@type Opim.Utils
local utils = require("opim.utils")
---@type Opim.Log
local log = require("opim.log")
---@type Opim.Keymaps
local keymaps = require("opim.keymaps")

M.is_setup = false
M.is_error = false

---@param opts? Opim.Config
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
  M.config = vim.tbl_deep_extend("force", {}, config.defaults, opts or {}) --[[@as Opim.Config]]
  log.init(M.config.debug)
  log.debug("setup() called")
  log.debug("config: " .. vim.inspect(M.config))
  keymaps.map_keymaps(M.config)
end

return M

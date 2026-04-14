---@class Opim.Keymap
local M = {}

---@type Opim.Log
local log = require("opim.log")
---@type Opim.Config
local config = require("opim.config")
local keys = config.keys

--- Set up all keymaps from the resolved config.
---@param config Opim.Config
function M.map_keymaps(config)
  local yank_operator = require("opim.yank-operations")
  local delete_operator = require("opim.delete-operations")
  local visual_operator = require("opim.visual-operations")
  local change_operator = require("opim.change-operations")

  local base_opts = { noremap = true, silent = true }

  ---@param mode string|string[]
  ---@param key string|false
  ---@param fn function
  ---@param desc string
  local function map(mode, key, fn, desc)
    if not key or key == "" then
      log.debug(("keymap: skipped %s (disabled)"):format(desc))
      return
    end
    log.debug(("keymap: %s %q → %s"):format(mode, key, desc))
    log.debug(("operator: %s"):format(vim.v.operator))
    --SPECIAL: RMB THAT LUA INDEX STARTS AT 1
    local first_letter_of_key = key:sub(1, 1)
    local non_visual_operator_keys = { "y", "d", "c" }

    vim.keymap.set(mode, key, fn, vim.tbl_extend("force", base_opts, { nowait = true, desc = "Opim: " .. desc }))
  end

  -- Normal mode — operations share the same key name as their function name,
  -- so we iterate a list and index into each module directly.

  for _, name in ipairs({
    "yank_at_parent",
    "yank_at_function",
    "yank_at_declaration",
    "yank_at_loop",
    "yank_at_condition",
    "yank_in_parent",
    "yank_in_function",
    "yank_in_declaration",
    "yank_in_loop",
    "yank_in_condition",
  }) do
    map({ "n" }, n[name], yank_operator[name], name:sub(1, 1):upper() .. name:sub(2):gsub("_", " "))
  end

  for _, name in ipairs({
    "delete_at_parent",
    "delete_at_function",
    "delete_at_declaration",
    "delete_at_loop",
    "delete_at_condition",
    "delete_in_parent",
    "delete_in_function",
    "delete_in_declaration",
    "delete_in_loop",
    "delete_in_condition",
  }) do
    map({ "n" }, n[name], delete_operator[name], name:sub(1, 1):upper() .. name:sub(2):gsub("_", " "))
  end

  for _, name in ipairs({
    "visual_at_parent",
    "visual_at_function",
    "visual_at_declaration",
    "visual_at_loop",
    "visual_at_condition",
    "visual_in_parent",
    "visual_in_function",
    "visual_in_declaration",
    "visual_in_loop",
    "visual_in_condition",
  }) do
    map({ "x", "v" }, n[name], visual_operator[name], name:sub(1, 1):upper() .. name:sub(2):gsub("_", " "))
  end

  for _, name in ipairs({
    "change_at_parent",
    "change_at_function",
    "change_at_declaration",
    "change_at_loop",
    "change_at_condition",
    "change_in_parent",
    "change_in_function",
    "change_in_declaration",
    "change_in_loop",
    "change_in_condition",
  }) do
    map({ "n" }, n[name], change_operator[name], name:sub(1, 1):upper() .. name:sub(2):gsub("_", " "))
  end

  -- navigate, traverse, insert, visual expand/shrink — wired once those modules exist
  _ = i
  _ = v
end

return M

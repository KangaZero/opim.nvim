---@class Opim.Keymaps
local M = {}

---@type Opim.Log
local log = require("opim.log")
---@type Opim.ConfigModule

--- Set up all keymaps from the resolved config.
---@param finalized_config Opim.Config
function M.map_keymaps(finalized_config)
  ---@type Opim.YankOperations
  local yank_operator = require("opim.yank-operations")
  ---@type Opim.DeleteOperations
  local delete_operator = require("opim.delete-operations")
  ---@type Opim.VisualOperations
  local visual_operator = require("opim.visual-operations")
  ---@type Opim.ChangeOperations
  local change_operator = require("opim.change-operations")

  local base_opts = { noremap = true, silent = true }

  ---@param key_name Opim.AllKeys
  ---@param operator_function function
  local function map_operators_to_vim_keymap(key_name, operator_function)
    if not finalized_config.keys[key_name] then
      log.debug(("keymap: does not exist %s"):format(key_name))
      return
    end

    if not finalized_config.keys[key_name].enabled then
      log.debug(("keymap: disabled %s"):format(key_name))
      return
    end
    local key = finalized_config.keys[key_name]
    local modes = type(key.modes) == "table" and key.modes or { key.modes }
    log.debug(
      ("keymap: key: %s, operator: %s, modes: [%s], keymap: %s"):format(
        key_name,
        key.operator,
        table.concat(modes --[[@as string[] ]], ", "),
        key.keymap
      )
    )

    local last_word_of_key_name = key_name:match("([^_]+)$")

    -- Visual mode operators
    if key.operator == nil and vim.deep_equal(modes, { "v", "x" }) or vim.deep_equal(modes, { "v" }) then
      log.debug(("keymap: setting visual key %s"):format(debug.getinfo(operator_function, "nS")))
      vim.keymap.set(modes, key.keymap, operator_function, { nowait = true, desc = "Opim: " .. last_word_of_key_name })
    end

    --SPECIAL: RMB THAT LUA INDEX STARTS AT 1
    -- local first_letter_of_key = key_name:sub(1, 1)
    -- local non_visual_operator_keys = { "y", "d", "c" }

    -- vim.keymap.set(mode, key_name, fn, vim.tbl_extend("force", base_opts, { nowait = true, desc = "Opim: " .. desc }))
  end

  function get_operator_fn_to_execute(key, name)
    local last_operator_executed = vim.v.operator
    local fn_name = key[name]
    if last_operator_executed == "y" then
      return yank_operator[fn_name]
    elseif last_operator_executed == "d" then
      return delete_operator[fn_name]
    elseif last_operator_executed == "c" then
      return change_operator[fn_name]
    else
      return nil
    end
  end

  for _, visual_key_name in ipairs({
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
    -- "expand_selection",
    -- "shrink_selection",
  }) do
    map_operators_to_vim_keymap(visual_key_name --[[@as Opim.AllKeys]], visual_operator[visual_key_name])
  end

  -- Normal mode — operations share the same key name as their function name,
  -- so we iterate a list and index into each module directly.
  --
  -- for _, name in ipairs({
  --   "yank_at_parent",
  --   "yank_at_function",
  --   "yank_at_declaration",
  --   "yank_at_loop",
  --   "yank_at_condition",
  --   "yank_in_parent",
  --   "yank_in_function",
  --   "yank_in_declaration",
  --   "yank_in_loop",
  --   "yank_in_condition",
  -- }) do
  --   map({ "n" }, keys[name], yank_operator[name], name:sub(1, 1):upper() .. name:sub(2):gsub("_", " "))
  -- end
  --
  -- for _, name in ipairs({
  --   "delete_at_parent",
  --   "delete_at_function",
  --   "delete_at_declaration",
  --   "delete_at_loop",
  --   "delete_at_condition",
  --   "delete_in_parent",
  --   "delete_in_function",
  --   "delete_in_declaration",
  --   "delete_in_loop",
  --   "delete_in_condition",
  -- }) do
  --   map({ "n" }, keys[name], delete_operator[name], name:sub(1, 1):upper() .. name:sub(2):gsub("_", " "))
  -- end
  --
  -- for _, name in ipairs({
  --   "change_at_parent",
  --   "change_at_function",
  --   "change_at_declaration",
  --   "change_at_loop",
  --   "change_at_condition",
  --   "change_in_parent",
  --   "change_in_function",
  --   "change_in_declaration",
  --   "change_in_loop",
  --   "change_in_condition",
  -- }) do
  --   map({ "n" }, keys[name], change_operator[name], name:sub(1, 1):upper() .. name:sub(2):gsub("_", " "))
  -- end

  -- navigate, traverse, insert, visual expand/shrink — wired once those modules exist
  -- _ = i
  -- _ = v
end

return M

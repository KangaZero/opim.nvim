---@class Opim.VisualOperations
local M = {}

local utils = require("opim.utils")

--- Enter visual line mode covering `node`'s range.
---@type Opim.NodeAction
local function select(node, _bufnr)
  local start_row, start_column, end_row, end_column = node:range()
  vim.api.nvim_win_set_cursor(0, { start_row + 1, start_column })
  -- vim.cmd("normal! v")
  vim.api.nvim_win_set_cursor(0, { end_row + 1, end_column - 1 })
  -- local count = end_row - start_row
  -- -- "v" enters visual line mode; extend by count lines if the node spans more than one
  -- local keys = count > 0 and ("v" .. count .. "j") or "v"
  -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "nx", false)
end

function M.visual_at_function()
  utils.execute_scope("functions", false, select)
end
function M.visual_in_function()
  utils.execute_scope("functions", true, select)
end
function M.visual_at_declaration()
  utils.execute_scope("declarations", false, select)
end
function M.visual_in_declaration()
  utils.execute_scope("declarations", true, select)
end
function M.visual_at_loop()
  utils.execute_scope("loops", false, select)
end
function M.visual_in_loop()
  utils.execute_scope("loops", true, select)
end
function M.visual_at_condition()
  utils.execute_scope("conditions", false, select)
end
function M.visual_in_condition()
  utils.execute_scope("conditions", true, select)
end
function M.visual_at_parent()
  utils.execute_parent(false, select)
end
function M.visual_in_parent()
  utils.execute_parent(true, select)
end

return M

---@class Opim.YankOperations
local M = {}

local utils = require("opim.utils")
local config = require("opim.config")
local opim = require("opim")

--- Yank `node` into the default register (linewise) and update `[`/`]` marks.
---@type Opim.NodeAction
local function yank(node, bufnr)
  local start_row, start_column, end_row, end_column = node:range()
  local text_to_yank = vim.treesitter.get_node_text(node, bufnr)

  vim.api.nvim_win_set_cursor(0, { start_row + 1, start_column })
  vim.cmd("normal! v")
  vim.api.nvim_win_set_cursor(0, { end_row + 1, end_column - 1 })
  vim.cmd("normal! y")

  local is_yank_register = opim.config.yank_register.enabled
  if is_yank_register then
    vim.fn.setreg(tostring(opim.config.yank_register.register), text_to_yank)
  end
  -- vim.api.nvim_buf_set_mark(bufnr, "[", start_row + 1, 0, {})
  -- vim.api.nvim_buf_set_mark(bufnr, "]", end_row + 1, 0, {})
  -- vim.api.nvim_exec_autocmds("TextYankPost", {
  --   modeline = false,
  --   data = {
  --     operator = "y",
  --     regname = '"',
  --     regtype = "l",
  --     visual = false,
  --   },
  -- })
  vim.notify(("opim: yanked %d lines"):format(end_row - start_row + 1), vim.log.levels.INFO)
end

function M.yank_at_function()
  utils.execute_scope("functions", false, yank)
end
function M.yank_in_function()
  utils.execute_scope("functions", true, yank)
end
function M.yank_at_declaration()
  utils.execute_scope("declarations", false, yank)
end
function M.yank_in_declaration()
  utils.execute_scope("declarations", true, yank)
end
function M.yank_at_loop()
  utils.execute_scope("loops", false, yank)
end
function M.yank_in_loop()
  utils.execute_scope("loops", true, yank)
end
function M.yank_at_condition()
  utils.execute_scope("conditions", false, yank)
end
function M.yank_in_condition()
  utils.execute_scope("conditions", true, yank)
end
function M.yank_at_parent()
  utils.execute_parent(false, yank)
end
function M.yank_in_parent()
  utils.execute_parent(true, yank)
end

return M

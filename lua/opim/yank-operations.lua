---@class Opim.YankOperations
local M = {}

local utils = require("opim.utils")

--- Yank `node` into the default register (linewise) and update `[`/`]` marks.
---@type Opim.NodeAction
local function yank(node, bufnr)
  local start_row, _, end_row, _ = node:range()
  local text = vim.treesitter.get_node_text(node, bufnr)
  vim.fn.setreg('"', text, "l")
  vim.api.nvim_buf_set_mark(bufnr, "[", start_row + 1, 0, {})
  vim.api.nvim_buf_set_mark(bufnr, "]", end_row + 1, 0, {})
  vim.api.nvim_exec_autocmds("TextYankPost", {
    modeline = false,
    data = {
      operator = "y",
      regname = '"',
      regtype = "l",
      visual = false,
    },
  })
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

---@class Opim.ChangeOperations
local M = {}

local utils = require("opim.utils")

--- Replace `node`'s lines with a single empty line, save old text to the default register,
--- position the cursor there, and enter insert mode.
---@type Opim.NodeAction
local function change(node, bufnr)
  local start_row, _, end_row, _ = node:range()
  local text = vim.treesitter.get_node_text(node, bufnr)
  vim.fn.setreg('"', text, "l")
  vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, { "" })
  vim.api.nvim_win_set_cursor(0, { start_row + 1, 0 })
  vim.cmd("startinsert")
end

function M.change_at_function()    utils.execute_scope("functions",    false, change) end
function M.change_in_function()    utils.execute_scope("functions",    true,  change) end
function M.change_at_declaration() utils.execute_scope("declarations", false, change) end
function M.change_in_declaration() utils.execute_scope("declarations", true,  change) end
function M.change_at_loop()        utils.execute_scope("loops",        false, change) end
function M.change_in_loop()        utils.execute_scope("loops",        true,  change) end
function M.change_at_condition()   utils.execute_scope("conditions",   false, change) end
function M.change_in_condition()   utils.execute_scope("conditions",   true,  change) end
function M.change_at_parent()      utils.execute_parent(false,               change) end
function M.change_in_parent()      utils.execute_parent(true,                change) end

return M

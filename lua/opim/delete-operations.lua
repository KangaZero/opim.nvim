---@class Opim.DeleteOperations
local M = {}

local utils = require("opim.utils")

--- Delete `node`'s lines from the buffer, saving text to the default register.
---@type Opim.NodeAction
local function delete(node, bufnr)
  local start_row, _, end_row, _ = node:range()
  local text = vim.treesitter.get_node_text(node, bufnr)
  vim.fn.setreg('"', text, "l")
  vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, {})
  vim.notify(("opim: deleted %d lines"):format(end_row - start_row + 1), vim.log.levels.INFO)
end

function M.delete_at_function()    utils.execute_scope("functions",    false, delete) end
function M.delete_in_function()    utils.execute_scope("functions",    true,  delete) end
function M.delete_at_declaration() utils.execute_scope("declarations", false, delete) end
function M.delete_in_declaration() utils.execute_scope("declarations", true,  delete) end
function M.delete_at_loop()        utils.execute_scope("loops",        false, delete) end
function M.delete_in_loop()        utils.execute_scope("loops",        true,  delete) end
function M.delete_at_condition()   utils.execute_scope("conditions",   false, delete) end
function M.delete_in_condition()   utils.execute_scope("conditions",   true,  delete) end
function M.delete_at_parent()      utils.execute_parent(false,               delete) end
function M.delete_in_parent()      utils.execute_parent(true,                delete) end

return M

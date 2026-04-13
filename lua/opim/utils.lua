---@class Opim.Util
local M = {}

local config = require("opim.config")
local log = require("opim.log")

--- Returns true if the current buffer's filetype has a configured scope entry.
--- Checks the merged user config so user-added languages are included.
---@return boolean
function M.is_valid_file_type()
  local ft = vim.bo.filetype
  local opim = require("opim")
  local scopes = (opim.is_setup and opim.config.scopes) or config.defaults.scopes
  return scopes[ft] ~= nil
end

--- Returns true if the TreeSitter module is available in this Neovim build.
--- Guards against very old Neovim versions where vim.treesitter may not exist.
---@return boolean
function M.has_treesitter()
  return type(vim.treesitter) == "table"
    and type(vim.treesitter.language) == "table"
    and type(vim.treesitter.language.get_lang) == "function"
end

--- Returns the TreeSitter language name for the current buffer's filetype.
--- Handles filetype→language mismatches (e.g. "typescriptreact" → "tsx").
--- Returns nil if the filetype has no known TreeSitter language.
---@return string?
function M.ts_lang()
  return vim.treesitter.language.get_lang(vim.bo.filetype)
end

--- Returns true if a TreeSitter parser is installed for the current buffer's filetype.
--- Uses language.inspect — a pure capability check with no side effects.
---@return boolean
function M.has_ts_parser()
  local lang = M.ts_lang()
  if not lang then
    return false
  end
  local ok = pcall(vim.treesitter.language.inspect, lang)
  return ok
end

-- Tree-sitter utilities -------------------------------------------------------

--- Build a hash-set from an array for O(1) membership testing.
---@param types string[]
---@return table<string, true>
function M.to_set(types)
  local set = {} ---@type table<string, true>
  for _, t in ipairs(types) do
    set[t] = true
  end
  return set
end

--- Walk up the syntax tree from `node`, returning the first node whose type is in `type_set`.
---@param node TSNode
---@param type_set table<string, true>
---@return TSNode?
function M.find_ancestor(node, type_set)
  local current = node ---@type TSNode?
  while current do
    if type_set[current:type()] then
      return current
    end
    current = current:parent()
  end
  return nil
end

--- Find the first named child of `node` whose type is in `type_set`.
--- Used to locate the body block inside a function/loop/condition node for "in" operations.
---@param node TSNode
---@param type_set table<string, true>
---@return TSNode?
function M.find_body_child(node, type_set)
  for child in node:iter_children() do
    if child:named() and type_set[child:type()] then
      return child
    end
  end
  return nil
end

--- Returns the scope category for the current buffer's filetype, falling back to "default".
--- Uses the merged user config (respecting user-added scopes), with a warning if the
--- matched language is not one of the built-in defaults.
---@return Opim.ScopeCategory
function M.current_scope_category()
  local ft = M.ts_lang() or vim.bo.filetype
  -- require("opim") inside the function body is safe — by call time both modules are cached
  local opim = require("opim")
  local scopes = (opim.is_setup and opim.config.scopes) or config.defaults.scopes

  local cat = scopes[ft]
  if cat then
    if not config.defaults.scopes[ft] then
      log.debug("current_scope_category: custom scope for " .. ft)
      if opim.config.show_warnings then
        vim.notify("opim: using custom scope configuration for filetype '" .. ft .. "'", vim.log.levels.WARN)
      end
    else
      log.debug("current_scope_category: built-in scope for " .. ft)
    end
    return cat
  end

  log.debug("current_scope_category: no scope for " .. ft .. ", falling back to default")
  return scopes.default
end

--- Verify treesitter is available and a parser exists for the current buffer.
--- Emits a warning and returns false if not.
---@return boolean
function M.ts_guard()
  if not M.has_treesitter() then
    vim.notify("opim: treesitter is not available", vim.log.levels.WARN)
    return false
  end
  if not M.has_ts_parser() then
    vim.notify("opim: no treesitter parser for " .. vim.bo.filetype, vim.log.levels.WARN)
    return false
  end
  return true
end

--- Singular display names for each scope category key, used in notifications.
---@type table<Opim.ScopeCategoryKey, string>
local category_singular = {
  functions = "function",
  classes = "class",
  declarations = "declaration",
  blocks = "block",
  loops = "loop",
  conditions = "condition",
}

-- Scope execution -------------------------------------------------------------

--- Find the nearest enclosing scope matching `category_key` and run `action` on it.
--- `inner = false` → whole node ("at"), `inner = true` → body block child ("in").
---@param category_key Opim.ScopeCategoryKey
---@param inner boolean
---@param action Opim.NodeAction
function M.execute_scope(category_key, inner, action)
  if not M.ts_guard() then
    return
  end

  local node = vim.treesitter.get_node()
  if not node then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local cat = M.current_scope_category()
  local types = cat[category_key]

  log.debug(
    ("execute_scope: ft=%s category=%s inner=%s cursor_node=%s"):format(
      vim.bo.filetype,
      category_key,
      tostring(inner),
      node:type()
    )
  )

  if not types or #types == 0 then
    log.debug("execute_scope: no types configured for " .. category_key)
    vim.notify("opim: no " .. category_key .. " configured for " .. vim.bo.filetype, vim.log.levels.WARN)
    return
  end

  local scope_node = M.find_ancestor(node, M.to_set(types))
  if not scope_node then
    log.debug("execute_scope: no enclosing " .. category_key .. " found")
    vim.notify(
      "opim: no enclosing " .. (category_singular[category_key] or category_key) .. " found",
      vim.log.levels.INFO
    )
    return
  end

  local sr, sc, er, ec = scope_node:range()
  log.debug(("execute_scope: found %s at %d:%d-%d:%d"):format(scope_node:type(), sr + 1, sc, er + 1, ec))

  if inner and #cat.blocks > 0 then
    local body = M.find_body_child(scope_node, M.to_set(cat.blocks))
    if body then
      local bsr, bsc, ber, bec = body:range()
      log.debug(("execute_scope: inner body %s at %d:%d-%d:%d"):format(body:type(), bsr + 1, bsc, ber + 1, bec))
    else
      log.debug("execute_scope: no body child found, using scope node")
    end
    action(body or scope_node, bufnr)
  else
    action(scope_node, bufnr)
  end
end

function test()
  local function prettify_sexpr(str)
    local result = {}
    local indent = 0
    local i = 1

    while i <= #str do
      local ch = str:sub(i, i)
      if ch == "(" then
        table.insert(result, string.rep("  ", indent) .. "(")
        indent = indent + 1
      elseif ch == ")" then
        indent = indent - 1
        table.insert(result, string.rep("  ", indent) .. ")")
      elseif ch == " " then
        table.insert(result, "\n")
      else
        -- accumulate word
        local word = ""
        while i <= #str and str:sub(i, i) ~= " " and str:sub(i, i) ~= "(" and str:sub(i, i) ~= ")" do
          word = word .. str:sub(i, i)
          i = i + 1
        end
        table.insert(result, string.rep("  ", indent) .. word)
        i = i - 1
      end
      i = i + 1
    end

    return table.concat(result, "\n")
  end

  --
  -- -- dump to scratch buffer
  -- vim.cmd("enew")
  -- vim.bo.buftype = "nofile"
  -- vim.bo.filetype = "scheme"  -- scheme syntax highlighting looks great on sexprs
  -- vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(pretty, "\n"))
  local tree = vim.treesitter.get_parser():parse(true)[1]
  local root = tree:root()
  local pretty = prettify_sexpr(root:sexpr())
  -- print(root:sexpr())
  local f = io.open("./tree.txt", "w")
  if f then
    f:write(pretty)
    f:close()
  end
end

--- Find the nearest enclosing scope of ANY configured category and run `action` on it.
---@param inner boolean
---@param action Opim.NodeAction
function M.execute_parent(inner, action)
  if not M.ts_guard() then
    return
  end

  local node = vim.treesitter.get_node()
  if not node then
    return vim.notify("opim: no syntax node under cursor", vim.log.levels.INFO)
  end

  local parent_node = node:parent()
  if not parent_node then
    return vim.notify("opim: no parent node under cursor", vim.log.levels.INFO)
  end

  local start_row, start_col, end_row, end_col = parent_node:range(false)
  local bufnr = vim.api.nvim_get_current_buf()

  action(parent_node, bufnr)
  --
  -- local cat = M.current_scope_category()
  --
  -- log.debug(("execute_parent: ft=%s inner=%s cursor_node=%s"):format(vim.bo.filetype, tostring(inner), node:type()))
  --
  -- local all_types = {} ---@type string[]
  -- for _, types in pairs(cat) do
  --   for _, t in ipairs(types) do
  --     table.insert(all_types, t)
  --   end
  -- end
  --
  -- local scope_node = M.find_ancestor(node, M.to_set(all_types))
  -- if not scope_node then
  --   log.debug("execute_parent: no enclosing scope found")
  --   vim.notify("opim: no enclosing scope found", vim.log.levels.INFO)
  --   return
  -- end
  --
  -- local sr, sc, er, ec = scope_node:range()
  -- log.debug(("execute_parent: found %s at %d:%d-%d:%d"):format(scope_node:type(), sr + 1, sc, er + 1, ec))
  --
  -- if inner and #cat.blocks > 0 then
  --   local body = M.find_body_child(scope_node, M.to_set(cat.blocks))
  --   action(body or scope_node, bufnr)
  -- else
  --   action(scope_node, bufnr)
  -- end
end

return M

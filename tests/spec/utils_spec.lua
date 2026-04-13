local utils = require("opim.utils")

-- Helper: create a scratch Lua buffer and parse it with treesitter.
---@param lines string[]
---@return integer bufnr
local function lua_buf(lines)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].filetype = "lua"
  vim.api.nvim_set_current_buf(bufnr)
  vim.treesitter.get_parser(bufnr, "lua"):parse()
  return bufnr
end

-- Parse bufnr and return the root TSNode.
---@param bufnr integer
---@return TSNode
local function parse_root(bufnr)
  return vim.treesitter.get_parser(bufnr, "lua"):parse()[1]:root()
end

local function del_buf(bufnr)
  vim.api.nvim_buf_delete(bufnr, { force = true })
end

-- ── to_set ────────────────────────────────────────────────────────────────────

describe("utils.to_set", function()
  it("converts an array into a hash-set", function()
    local set = utils.to_set({ "a", "b", "c" })
    assert.is_true(set["a"])
    assert.is_true(set["b"])
    assert.is_true(set["c"])
    assert.is_nil(set["d"])
  end)

  it("returns an empty table for an empty array", function()
    assert.are.same({}, utils.to_set({}))
  end)

  it("handles duplicate values without error", function()
    local set = utils.to_set({ "x", "x", "y" })
    assert.is_true(set["x"])
    assert.is_true(set["y"])
  end)
end)

-- ── has_treesitter ────────────────────────────────────────────────────────────

describe("utils.has_treesitter", function()
  it("returns true in a standard Neovim build", function()
    assert.is_true(utils.has_treesitter())
  end)
end)

-- ── ts_lang ───────────────────────────────────────────────────────────────────

describe("utils.ts_lang", function()
  it("returns 'lua' for a lua buffer", function()
    local bufnr = lua_buf({ "" })
    assert.are.equal("lua", utils.ts_lang())
    del_buf(bufnr)
  end)
end)

-- ── has_ts_parser ─────────────────────────────────────────────────────────────

describe("utils.has_ts_parser", function()
  it("returns true for a lua buffer", function()
    local bufnr = lua_buf({ "" })
    assert.is_true(utils.has_ts_parser())
    del_buf(bufnr)
  end)

  it("returns false for an unknown filetype", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.bo[bufnr].filetype = "opim_unknown_ft_xyz"
    assert.is_false(utils.has_ts_parser())
    del_buf(bufnr)
  end)
end)

-- ── is_valid_file_type ────────────────────────────────────────────────────────

describe("utils.is_valid_file_type", function()
  before_each(function()
    require("opim").setup({ debug = false })
  end)

  it("returns true for a built-in filetype", function()
    local bufnr = lua_buf({ "" })
    assert.is_true(utils.is_valid_file_type())
    del_buf(bufnr)
  end)

  it("returns false for an unconfigured filetype", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.bo[bufnr].filetype = "opim_unknown_ft_xyz"
    assert.is_false(utils.is_valid_file_type())
    del_buf(bufnr)
  end)
end)

-- ── find_ancestor ─────────────────────────────────────────────────────────────

describe("utils.find_ancestor", function()
  it("finds the nearest enclosing function node", function()
    local bufnr = lua_buf({
      "local function foo()",
      "  local x = 1",
      "end",
    })
    -- root → local_function → (named child) "foo" identifier
    -- find_ancestor on "foo" walks up and finds local_function
    local root = parse_root(bufnr)
    local fn_node = root:named_child(0)
    assert.are.equal("function_declaration", fn_node:type())
    local inner = fn_node:named_child(0)  -- identifier "foo"
    assert.is_not_nil(inner)

    local ancestor = utils.find_ancestor(inner, utils.to_set({ "function_definition", "function_declaration" }))
    assert.is_not_nil(ancestor)
    assert.are.equal("function_declaration", ancestor:type())

    del_buf(bufnr)
  end)

  it("returns nil when no ancestor matches the type set", function()
    local bufnr = lua_buf({ "local x = 1" })
    local root = parse_root(bufnr)
    local node = root:named_child(0)
    assert.is_not_nil(node)

    local ancestor = utils.find_ancestor(node, utils.to_set({ "nonexistent_node_type" }))
    assert.is_nil(ancestor)

    del_buf(bufnr)
  end)

  it("matches the cursor node itself if it is the right type", function()
    local bufnr = lua_buf({
      "local function foo()",
      "  return 1",
      "end",
    })
    local root = parse_root(bufnr)
    local fn_node = root:named_child(0)
    assert.are.equal("function_declaration", fn_node:type())

    -- calling find_ancestor on the function_declaration node itself should return it immediately
    local result = utils.find_ancestor(fn_node, utils.to_set({ "function_declaration" }))
    assert.are.equal(fn_node, result)

    del_buf(bufnr)
  end)
end)

-- ── find_body_child ───────────────────────────────────────────────────────────

describe("utils.find_body_child", function()
  it("finds the block child of a function node", function()
    local bufnr = lua_buf({
      "local function foo()",
      "  return 1",
      "end",
    })
    local root = parse_root(bufnr)
    local fn_node = root:named_child(0)
    assert.are.equal("function_declaration", fn_node:type())

    local body = utils.find_body_child(fn_node, utils.to_set({ "block" }))
    assert.is_not_nil(body)
    assert.are.equal("block", body:type())

    del_buf(bufnr)
  end)

  it("returns nil when no matching child exists", function()
    local bufnr = lua_buf({ "local x = 1" })
    local root = parse_root(bufnr)
    local node = root:named_child(0)
    assert.is_not_nil(node)

    local result = utils.find_body_child(node, utils.to_set({ "nonexistent_type" }))
    assert.is_nil(result)

    del_buf(bufnr)
  end)
end)

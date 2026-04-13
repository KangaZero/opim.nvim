local yank_ops = require("opim.yank-operations")
require("opim").setup({ debug = false })

-- Helper: create a scratch Lua buffer parsed by treesitter, cursor at (row, col).
---@param lines string[]
---@param row integer 1-indexed
---@param col integer 0-indexed
---@return integer bufnr
local function lua_buf(lines, row, col)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].filetype = "lua"
  vim.api.nvim_set_current_buf(bufnr)
  vim.treesitter.get_parser(bufnr, "lua"):parse()
  vim.api.nvim_win_set_cursor(0, { row, col })
  return bufnr
end

local function del_buf(bufnr)
  vim.api.nvim_buf_delete(bufnr, { force = true })
end

describe("yank operations", function()
  before_each(function()
    vim.fn.setreg('"', "")
  end)

  -- ── yank_at_function ────────────────────────────────────────────────────────

  describe("yank_at_function", function()
    it("yanks the full function including signature and end", function()
      local bufnr = lua_buf({
        "local function foo()",
        "  return 1",
        "end",
      }, 2, 2)

      yank_ops.yank_at_function()

      local reg = vim.fn.getreg('"')
      assert.truthy(reg:find("local function foo", 1, true))
      assert.truthy(reg:find("return 1", 1, true))
      assert.truthy(reg:find("end", 1, true))

      del_buf(bufnr)
    end)

    it("leaves the register unchanged when no function is found", function()
      local bufnr = lua_buf({ "local x = 1" }, 1, 0)
      vim.fn.setreg('"', "sentinel")

      yank_ops.yank_at_function()

      assert.are.equal("sentinel", vim.fn.getreg('"'))
      del_buf(bufnr)
    end)

    it("works when cursor is on the function keyword line", function()
      local bufnr = lua_buf({
        "local function bar()",
        "  local y = 2",
        "end",
      }, 1, 0)

      yank_ops.yank_at_function()

      local reg = vim.fn.getreg('"')
      assert.truthy(reg:find("bar", 1, true))
      del_buf(bufnr)
    end)

    it("finds the innermost function when nested", function()
      local bufnr = lua_buf({
        "local function outer()",
        "  local function inner()",
        "    return 42",
        "  end",
        "end",
      }, 3, 4)

      yank_ops.yank_at_function()

      local reg = vim.fn.getreg('"')
      assert.truthy(reg:find("inner", 1, true))
      assert.falsy(reg:find("outer", 1, true))
      del_buf(bufnr)
    end)
  end)

  -- ── yank_in_function ────────────────────────────────────────────────────────

  describe("yank_in_function", function()
    it("yanks the function body without the signature line", function()
      local bufnr = lua_buf({
        "local function foo()",
        "  return 1",
        "end",
      }, 2, 2)

      yank_ops.yank_in_function()

      local reg = vim.fn.getreg('"')
      assert.truthy(reg:find("return 1", 1, true))
      del_buf(bufnr)
    end)
  end)

  -- ── yank_at_loop ─────────────────────────────────────────────────────────────

  describe("yank_at_loop", function()
    it("yanks the full for loop", function()
      local bufnr = lua_buf({
        "for i = 1, 10 do",
        "  print(i)",
        "end",
      }, 2, 2)

      yank_ops.yank_at_loop()

      local reg = vim.fn.getreg('"')
      assert.truthy(reg:find("for i = 1, 10 do", 1, true))
      assert.truthy(reg:find("print(i)", 1, true))
      del_buf(bufnr)
    end)

    it("leaves the register unchanged when no loop is found", function()
      local bufnr = lua_buf({ "local x = 1" }, 1, 0)
      vim.fn.setreg('"', "sentinel")

      yank_ops.yank_at_loop()

      assert.are.equal("sentinel", vim.fn.getreg('"'))
      del_buf(bufnr)
    end)
  end)

  -- ── yank_at_condition ────────────────────────────────────────────────────────

  describe("yank_at_condition", function()
    it("yanks the full if statement", function()
      local bufnr = lua_buf({
        "if x > 0 then",
        "  print('positive')",
        "end",
      }, 2, 2)

      yank_ops.yank_at_condition()

      local reg = vim.fn.getreg('"')
      assert.truthy(reg:find("if x > 0 then", 1, true))
      assert.truthy(reg:find("positive", 1, true))
      del_buf(bufnr)
    end)
  end)

  -- ── yank_at_declaration ──────────────────────────────────────────────────────

  describe("yank_at_declaration", function()
    it("yanks a local variable declaration", function()
      local bufnr = lua_buf({
        "local x = 42",
      }, 1, 6)

      yank_ops.yank_at_declaration()

      local reg = vim.fn.getreg('"')
      assert.truthy(reg:find("local x = 42", 1, true))
      del_buf(bufnr)
    end)
  end)

  -- ── yank_at_parent ───────────────────────────────────────────────────────────

  describe("yank_at_parent", function()
    it("yanks the nearest enclosing scope of any kind", function()
      local bufnr = lua_buf({
        "local function foo()",
        "  for i = 1, 3 do",
        "    print(i)",
        "  end",
        "end",
      }, 2, 2)  -- cursor on the "for" line → nearest scope is the for_statement

      yank_ops.yank_at_parent()

      local reg = vim.fn.getreg('"')
      assert.truthy(reg:find("for i = 1, 3 do", 1, true))
      del_buf(bufnr)
    end)
  end)
end)

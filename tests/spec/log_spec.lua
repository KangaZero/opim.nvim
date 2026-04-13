describe("opim.log", function()
  local log
  local tmp_dir

  before_each(function()
    -- Reset the module so enabled/log_path state is cleared between tests
    package.loaded["opim.log"] = nil
    log = require("opim.log")
    tmp_dir = vim.fn.tempname()
    vim.fn.mkdir(tmp_dir, "p")
  end)

  after_each(function()
    vim.fn.delete(tmp_dir, "rf")
  end)

  it("debug() is a no-op before init() is called", function()
    assert.has_no.errors(function()
      log.debug("should not error")
    end)
  end)

  it("debug() is a no-op when debug = false", function()
    log.init(false)
    assert.has_no.errors(function()
      log.debug("should not error")
    end)
  end)

  it("init() with debug = true creates opim.log in the cwd", function()
    -- Temporarily redirect getcwd to our temp dir
    local orig = vim.fn.getcwd
    vim.fn.getcwd = function() return tmp_dir end

    log.init(true)

    vim.fn.getcwd = orig

    assert.is_truthy(vim.fn.filereadable(tmp_dir .. "/opim.log") == 1, "opim.log should exist")
  end)

  it("debug() writes a line to opim.log when debug = true", function()
    local orig = vim.fn.getcwd
    vim.fn.getcwd = function() return tmp_dir end

    log.init(true)
    log.debug("hello from test")

    vim.fn.getcwd = orig

    local lines = vim.fn.readfile(tmp_dir .. "/opim.log")
    local found = false
    for _, line in ipairs(lines) do
      if line:find("hello from test", 1, true) then
        found = true
        break
      end
    end
    assert.is_true(found, "log file should contain the debug message")
  end)

  it("debug() lines include a timestamp prefix", function()
    local orig = vim.fn.getcwd
    vim.fn.getcwd = function() return tmp_dir end

    log.init(true)
    log.debug("timestamped message")

    vim.fn.getcwd = orig

    local lines = vim.fn.readfile(tmp_dir .. "/opim.log")
    local has_timestamp = false
    for _, line in ipairs(lines) do
      -- Expect format: [HH:MM:SS] message
      if line:match("^%[%d%d:%d%d:%d%d%]") then
        has_timestamp = true
        break
      end
    end
    assert.is_true(has_timestamp, "log lines should have a [HH:MM:SS] prefix")
  end)
end)

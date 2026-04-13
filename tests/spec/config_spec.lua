local config = require("opim.config")

describe("opim.config", function()
  it("exposes a version string", function()
    assert.is_string(config.version)
    assert.is_truthy(config.version:match("^%d+%.%d+%.%d+$"), "version should follow semver")
  end)

  it("exposes a defaults table", function()
    assert.is_table(config.defaults)
  end)

  describe("defaults.scopes", function()
    local expected_langs = { "lua", "python", "javascript", "typescript", "tsx", "rust", "go", "c", "cpp", "default" }
    local expected_fields = { "functions", "classes", "declarations", "blocks", "loops", "conditions" }

    it("contains all built-in languages", function()
      for _, lang in ipairs(expected_langs) do
        assert.is_table(config.defaults.scopes[lang], "missing scope for '" .. lang .. "'")
      end
    end)

    it("each language has all required category fields", function()
      for lang, cat in pairs(config.defaults.scopes) do
        for _, field in ipairs(expected_fields) do
          assert.is_table(cat[field], lang .. "." .. field .. " should be a table")
        end
      end
    end)

    it("all node type values are non-empty strings", function()
      for lang, cat in pairs(config.defaults.scopes) do
        for field, types in pairs(cat) do
          for _, t in ipairs(types) do
            assert.is_string(t, lang .. "." .. field .. " contains a non-string value")
            assert.is_truthy(#t > 0, lang .. "." .. field .. " contains an empty string")
          end
        end
      end
    end)
  end)

  describe("defaults.keys", function()
    it("has normal, insert, and visual sub-tables", function()
      assert.is_table(config.defaults.keys.normal)
      assert.is_table(config.defaults.keys.insert)
      assert.is_table(config.defaults.keys.visual)
    end)

    it("all normal key values are non-empty strings", function()
      for name, key in pairs(config.defaults.keys.normal) do
        assert.is_string(key, "keys.normal." .. name .. " should be a string")
        assert.is_truthy(#key > 0, "keys.normal." .. name .. " should not be empty")
      end
    end)
  end)
end)

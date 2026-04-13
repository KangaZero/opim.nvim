-- examples/lazy.lua
-- Copy one of the blocks below into your lazy.nvim plugin spec.

-- ─── Minimal ────────────────────────────────────────────────────────────────
-- Zero configuration. The plugin auto-initialises 500ms after Neovim starts.
{
  "KangaZero/opim.nvim",
}

-- ─── With options ───────────────────────────────────────────────────────────
-- All fields are optional — anything you omit keeps its default value.
-- vim.tbl_deep_extend merges your opts into the defaults, so you only need
-- to specify what you want to change.
{
  "KangaZero/opim.nvim",
  config = function()
    require("opim").setup({

      -- Silence notifications when a keymap you set conflicts with an existing one.
      show_warnings = false,

      -- Override individual keymaps.
      -- Only the keys listed here change; every other key keeps its default.
      -- Pass false to disable a keymap entirely.
      keys = {
        normal = {
          yank_at_function = "yF",   -- remap: default is "yaf"
          yank_in_function = "yf",   -- remap: default is "yif"
          delete_at_parent = false,  -- disable entirely
        },
      },

      -- Add or fully replace scope node-type lists per language.
      -- Again, only the languages you list are affected; others keep their defaults.
      scopes = {

        -- Override an existing language — add a new function node type for Lua.
        lua = {
          functions = { "function_definition", "function_declaration", "local_function", "method" },
          classes = {},
          declarations = { "local_variable_declaration", "variable_declaration" },
          blocks = { "block", "do_statement" },
          loops = { "for_statement", "while_statement", "repeat_statement" },
          conditions = { "if_statement", "elseif_clause", "else_clause" },
        },

        -- Add a language that isn't built in.
        -- The key must be the TreeSitter language name (what vim.treesitter.language.get_lang()
        -- returns for the filetype), NOT the filetype name itself.
        -- e.g. filetype "typescriptreact" → ts lang "tsx"  (already built in)
        --      filetype "gleam"           → ts lang "gleam" (example below)
        gleam = {
          functions = { "function" },
          classes = { "custom_type" },
          declarations = { "let_declaration" },
          blocks = { "block" },
          loops = {},
          conditions = { "case", "use" },
        },

      },

    })
  end,
}

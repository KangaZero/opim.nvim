---@class Opim.ConfigModule
---@field version string
---@field defaults Opim.Config
local M = {}

M.version = "0.0.1" -- x-release-please-version

---@type Opim.Config
M.defaults = {
  scopes = {
    lua = {
      functions = { "function_definition", "function_declaration", "local_function" },
      classes = {},
      declarations = { "local_variable_declaration", "variable_declaration" },
      blocks = { "block", "do_statement" },
      loops = { "for_statement", "while_statement", "repeat_statement" },
      conditions = { "if_statement", "elseif_clause", "else_clause" },
    },
    python = {
      functions = { "function_definition", "async_function_definition" },
      classes = { "class_definition" },
      declarations = { "assignment", "augmented_assignment" },
      blocks = { "block" },
      loops = { "for_statement", "while_statement" },
      conditions = { "if_statement", "elif_clause", "else_clause" },
    },
    javascript = {
      functions = { "function_declaration", "function_expression", "arrow_function", "method_definition" },
      classes = { "class_declaration", "class_expression" },
      declarations = { "lexical_declaration", "variable_declaration" },
      blocks = { "statement_block" },
      loops = { "for_statement", "for_in_statement", "while_statement", "do_statement" },
      conditions = { "if_statement", "else_clause", "ternary_expression" },
    },
    typescript = {
      functions = { "function_declaration", "function_expression", "arrow_function", "method_definition" },
      classes = { "class_declaration", "class_expression" },
      declarations = {
        "lexical_declaration",
        "variable_declaration",
        "type_alias_declaration",
        "interface_declaration",
      },
      blocks = { "statement_block" },
      loops = { "for_statement", "for_in_statement", "while_statement", "do_statement" },
      conditions = { "if_statement", "else_clause", "ternary_expression" },
    },
    rust = {
      functions = { "function_item", "closure_expression" },
      classes = { "impl_item", "trait_item", "struct_item", "enum_item" },
      declarations = { "let_declaration", "const_item", "static_item", "type_item" },
      blocks = { "block" },
      loops = { "for_expression", "while_expression", "loop_expression" },
      conditions = { "if_expression", "else_clause", "match_expression", "match_arm" },
    },
    go = {
      functions = { "function_declaration", "method_declaration", "func_literal" },
      classes = { "type_declaration" },
      declarations = { "var_declaration", "const_declaration", "short_var_declaration" },
      blocks = { "block" },
      loops = { "for_statement" },
      conditions = { "if_statement", "else_clause", "expression_switch_statement" },
    },
    c = {
      functions = { "function_definition" },
      classes = { "struct_specifier", "enum_specifier", "union_specifier" },
      declarations = { "declaration" },
      blocks = { "compound_statement" },
      loops = { "for_statement", "while_statement", "do_statement" },
      conditions = { "if_statement", "else_clause", "switch_statement" },
    },
    cpp = {
      functions = { "function_definition", "lambda_expression" },
      classes = { "class_specifier", "struct_specifier", "enum_specifier" },
      declarations = { "declaration", "type_alias_declaration" },
      blocks = { "compound_statement" },
      loops = { "for_statement", "for_range_loop", "while_statement", "do_statement" },
      conditions = { "if_statement", "else_clause", "switch_statement" },
    },
    --- typescriptreact files — vim.treesitter.language.get_lang("typescriptreact") returns "tsx"
    tsx = {
      functions = { "function_declaration", "function_expression", "arrow_function", "method_definition" },
      classes = { "class_declaration", "class_expression" },
      declarations = {
        "lexical_declaration",
        "variable_declaration",
        "type_alias_declaration",
        "interface_declaration",
      },
      blocks = { "statement_block" },
      loops = { "for_statement", "for_in_statement", "while_statement", "do_statement" },
      conditions = { "if_statement", "else_clause", "ternary_expression" },
    },
    --- Fallback used when the current filetype has no explicit entry.
    default = {
      functions = { "function_definition", "lambda_expression" },
      classes = { "class_specifier", "struct_specifier", "enum_specifier" },
      declarations = { "declaration", "type_alias_declaration" },
      blocks = { "block", "compound_statement" },
      loops = { "for_statement", "for_range_loop", "while_statement", "do_statement" },
      conditions = { "if_statement", "else_clause", "switch_statement" },
    },
  },
  show_warnings = true,
  show_errors = true,
  ---@type Opim.Keys
  keys = {
    ---@type Opim.NormalKeys
    normal = {
      -- yank
      yank_at_parent = "yaP",
      yank_at_function = "yaf",
      yank_at_declaration = "yad",
      -- yank_at_block       = "yab",
      yank_at_loop = "yal",
      yank_at_condition = "yac",
      yank_in_parent = "yiP",
      yank_in_function = "yif",
      yank_in_declaration = "yid",
      -- yank_in_block       = "yib",
      yank_in_loop = "yil",
      yank_in_condition = "yic",

      -- delete
      delete_at_parent = "daP",
      delete_at_function = "daf",
      delete_at_declaration = "dad",
      -- delete_at_block       = "dab",
      delete_at_loop = "dal",
      delete_at_condition = "dac",
      delete_in_parent = "diP",
      delete_in_function = "dif",
      delete_in_declaration = "did",
      -- delete_in_block       = "dib",
      delete_in_loop = "dil",
      delete_in_condition = "dic",

      -- visual select
      visual_at_parent = "vaP",
      visual_at_function = "vaf",
      visual_at_declaration = "vad",
      -- visual_at_block       = "vab",
      visual_at_loop = "val",
      visual_at_condition = "vac",
      visual_in_parent = "viP",
      visual_in_function = "vif",
      visual_in_declaration = "vid",
      -- visual_in_block       = "vib",
      visual_in_loop = "vil",
      visual_in_condition = "vic",

      -- change
      change_at_parent = "caP",
      change_at_function = "caf",
      change_at_declaration = "cad",
      -- change_at_block       = "cab",
      change_at_loop = "cal",
      change_at_condition = "cac",
      change_in_parent = "ciP",
      change_in_function = "cif",
      change_in_declaration = "cid",
      -- change_in_block       = "cib",
      change_in_loop = "cil",
      change_in_condition = "cic",

      --TODO: implement the below
      -- navigate (all support [count] prefix)
      next_function = "mf", -- [count]mf → nth next function
      prev_function = "mF", -- [count]mF → nth prev function
      next_class = "mc", -- [count]mc → nth next class
      prev_class = "mC", -- [count]mC → nth prev class
      next_declaration = "md", -- [count]md → nth next declaration
      prev_declaration = "mD", -- [count]mD → nth prev declaration
      next_block = "mb", -- [count]mb → nth next block
      prev_block = "mB", -- [count]mB → nth prev block
      next_loop = "ml", -- [count]ml → nth next loop
      prev_loop = "mL", -- [count]mL → nth prev loop
      next_condition = "mi", -- [count]mi → nth next condition
      prev_condition = "mI", -- [count]mI → nth prev condition

      -- node tree traversal (all support [count] prefix)
      goto_parent = "gsp", -- go up to parent scope
      goto_child = "gsc", -- go down to first child scope
      next_sibling_scope = "gsn", -- [count]gsn → nth next sibling scope
      prev_sibling_scope = "gsN", -- [count]gsN → nth prev sibling scope
    },
    ---@type Opim.InsertKeys
    insert = {
      jump_scope_start = "<C-a>",
      jump_scope_end = "<C-e>",
    },
    ---@type Opim.VisualKeys
    visual = {
      expand_selection = "a", -- expand to next scope up
      shrink_selection = "i", -- shrink to next scope in
    },
  },
  debug = false, -- write debug output to opim.log in the current directory
}

return M

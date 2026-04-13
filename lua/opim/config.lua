---@class Opim.Config: Opim.Opts
local M = {}

M.version = "0.0.1" -- x-release-please-version

---@class opim.Opts
local defaults = {
  ---@type Opim.Config.scope_types
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
    default = {
      functions = { "function_definition", "lambda_expression" },
      classes = { "class_specifier", "struct_specifier", "enum_specifier" },
      declarations = { "declaration", "type_alias_declaration" },
      blocks = { "block", "compound_statement" },
      loops = { "for_statement", "for_range_loop", "while_statement", "do_statement" },
      conditions = { "if_statement", "else_clause", "switch_statement" },
    },
  },
  -- show a warning when issues were detected with your mappings
  show_warnings = true,
  show_errors = true,
  keys = {
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
    insert = {
      jump_scope_start = "<C-a>",
      jump_scope_end = "<C-e>",
    },
    visual = {
      expand_selection = "a", -- expand to next scope up
      shrink_selection = "i", -- shrink to next scope in
    },
  },
  debug = false, -- enable opim.log in the current directory
}
--
-- M.loaded = false
--
-- ---@type wk.Keymap[]
-- M.mappings = {}
--
-- ---@type wk.Opts
-- M.options = nil
--
-- ---@type {opt:string, msg:string}[]
-- M.issues = {}
--
-- function M.validate()
--   local deprecated = {
--     ["operators"] = "see `opts.defer`",
--     ["key_labels"] = "see `opts.replace`",
--     "motions",
--     ["popup_mappings"] = "see `opts.keys`",
--     ["window"] = "see `opts.win`",
--     ["ignore_missing"] = "see `opts.filter`",
--     "hidden",
--     ["triggers_nowait"] = "see `opts.delay`",
--     ["triggers_blacklist"] = "see `opts.triggers`",
--     ["disable.trigger"] = "see `opts.triggers`",
--     ["modes"] = "see `opts.triggers`",
--   }
--   for k, v in pairs(deprecated) do
--     local opt = type(k) == "number" and v or k
--     local msg = "option is deprecated." .. (type(k) == "number" and "" or " " .. v)
--     local parts = vim.split(opt, ".", { plain = true })
--     if vim.tbl_get(M.options, unpack(parts)) ~= nil then
--       table.insert(M.issues, { opt = opt, msg = msg })
--     end
--   end
--   if type(M.options.triggers) ~= "table" then
--     table.insert(M.issues, { opt = "triggers", msg = "triggers must be a table" })
--   end
-- end
--
-- ---@param opts? wk.Opts
-- function M.setup(opts)
--   if vim.fn.has("nvim-0.9.4") == 0 then
--     return vim.notify("which-key.nvim requires Neovim >= 0.9.4", vim.log.levels.ERROR)
--   end
--   M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
--
--   local function load()
--     if M.loaded then
--       return
--     end
--     local Util = require("which-key.util")
--
--     if M.options.preset then
--       local Presets = require("which-key.presets")
--       M.options = vim.tbl_deep_extend("force", {}, defaults, Presets[M.options.preset] or {}, opts or {})
--     end
--
--     M.validate()
--     if #M.issues > 0 then
--       Util.warn({
--         "There are issues with your config.",
--         "Use `:checkhealth which-key` to find out more.",
--       }, { once = true })
--     end
--
--     for k, v in pairs(M.options.keys) do
--       M.options.keys[k] = Util.norm(v)
--     end
--
--     if M.options.debug then
--       Util.debug("\n\nDebug Started for v" .. M.version)
--       if package.loaded.lazy then
--         local Git = require("lazy.manage.git")
--         local plugin = require("lazy.core.config").plugins["which-key.nvim"]
--         Util.debug(vim.inspect(Git.info(plugin.dir)))
--       end
--     end
--
--     local wk = require("which-key")
--
--     -- replace by the real add function
--     wk.add = M.add
--
--     if type(M.options.triggers) ~= "table" then
--       ---@diagnostic disable-next-line: inject-field
--       M.options.triggers = defaults.triggers
--     end
--
--     M.triggers = {
--       mappings = require("which-key.mappings").parse(M.options.triggers),
--       modes = {},
--     }
--     ---@param m wk.Mapping
--     M.triggers.mappings = vim.tbl_filter(function(m)
--       if m.lhs == "<auto>" then
--         M.triggers.modes[m.mode] = true
--         return false
--       end
--       return true
--     end, M.triggers.mappings)
--
--     -- load presets first so that they can be overriden by the user
--     require("which-key.plugins").setup()
--
--     -- process mappings queue
--     for _, todo in ipairs(wk._queue) do
--       M.add(todo.spec, todo.opts)
--     end
--     wk._queue = {}
--
--     -- finally, add the mapppings from the config
--     M.add(M.options.spec)
--
--     -- setup colors and start which-key
--     require("which-key.colors").setup()
--     require("which-key.state").setup()
--
--     M.loaded = true
--   end
--   local _load = vim.schedule_wrap(load)
--
--   if vim.v.vim_did_enter == 1 then
--     _load()
--   else
--     vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = _load })
--   end
--
--   vim.api.nvim_create_user_command("WhichKey", function(cmd)
--     load()
--     local mode, keys = cmd.args:match("^([nixsotc]?)%s*(.*)$")
--     if not mode then
--       return require("which-key.util").error("Usage: WhichKey [mode] [keys]")
--     end
--     if mode == "" then
--       mode = "n"
--     end
--     require("which-key").show({ mode = mode, keys = keys })
--   end, {
--     nargs = "*",
--   })
-- end
--
-- ---@param opts? wk.Parse
-- ---@param mappings wk.Spec
-- function M.add(mappings, opts)
--   opts = opts or {}
--   opts.create = opts.create ~= false
--   local Mappings = require("which-key.mappings")
--   for _, km in ipairs(Mappings.parse(mappings, opts)) do
--     table.insert(M.mappings, km)
--     km.idx = #M.mappings
--   end
--   if M.loaded then
--     require("which-key.buf").clear()
--   end
-- end
--
-- return setmetatable(M, {
--   __index = function(_, k)
--     if rawget(M, "options") == nil then
--       M.setup()
--     end
--     local opts = rawget(M, "options")
--     return k == "options" and opts or opts[k]
--   end,
-- })

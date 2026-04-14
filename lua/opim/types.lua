---@meta

--# selene: allow(unused_variable)

---INFO: visual "v" is not an operator
---
---@alias Opim.Operators
---| 'y'
---| 'c'
---| 'd'

---INFO: more modes exist but these are the only ones relevant for keymap configuration
---see :h modes
---
---@alias Opim.Modes
---| 'n'
---| 'i'
---| 'v'
---| 'x'
---| 'o'

---@alias Opim.FunctionNodeType
---| "function_definition"   -- lua, python, c, cpp
---| "function_declaration"  -- javascript, typescript, go
---| "function_expression"   -- javascript, typescript
---| "local_function"        -- lua
---| "async_function_definition" -- python
---| "arrow_function"        -- javascript, typescript
---| "method_definition"     -- javascript, typescript
---| "method_declaration"    -- go
---| "func_literal"          -- go
---| "function_item"         -- rust
---| "closure_expression"    -- rust
---| "lambda_expression"     -- cpp

---@alias Opim.ClassNodeType
---| "class_definition"   -- python
---| "class_declaration"  -- javascript, typescript
---| "class_expression"   -- javascript, typescript
---| "class_specifier"    -- cpp
---| "struct_item"        -- rust
---| "struct_specifier"   -- c, cpp
---| "enum_item"          -- rust
---| "enum_specifier"     -- c, cpp
---| "union_specifier"    -- c
---| "impl_item"          -- rust
---| "trait_item"         -- rust
---| "type_declaration"   -- go

---@alias Opim.DeclarationNodeType
---| "local_variable_declaration" -- lua
---| "variable_declaration"       -- lua, javascript
---| "lexical_declaration"        -- javascript, typescript
---| "type_alias_declaration"     -- typescript, cpp
---| "interface_declaration"      -- typescript
---| "assignment"                 -- python
---| "augmented_assignment"       -- python
---| "let_declaration"            -- rust
---| "const_item"                 -- rust
---| "static_item"                -- rust
---| "type_item"                  -- rust
---| "var_declaration"            -- go
---| "const_declaration"          -- go
---| "short_var_declaration"      -- go
---| "declaration"                -- c, cpp

---@alias Opim.BlockNodeType
---| "block"              -- lua, python, rust, go
---| "do_statement"       -- lua
---| "statement_block"    -- javascript, typescript
---| "compound_statement" -- c, cpp

---@alias Opim.LoopNodeType
---| "for_statement"    -- lua, python, javascript, typescript, go, c, cpp
---| "while_statement"  -- lua, python, javascript, typescript, c, cpp
---| "repeat_statement" -- lua
---| "for_in_statement" -- javascript, typescript
---| "do_statement"     -- javascript, typescript, c, cpp
---| "for_range_loop"   -- cpp
---| "for_expression"   -- rust
---| "while_expression" -- rust
---| "loop_expression"  -- rust

---@alias Opim.ConditionNodeType
---| "if_statement"              -- lua, python, javascript, typescript, go, c, cpp
---| "elseif_clause"             -- lua
---| "else_clause"               -- lua, python, javascript, typescript, rust, go, c, cpp
---| "elif_clause"               -- python
---| "ternary_expression"        -- javascript, typescript
---| "if_expression"             -- rust
---| "match_expression"          -- rust
---| "match_arm"                 -- rust
---| "expression_switch_statement" -- go
---| "switch_statement"          -- c, cpp

--- The valid keys of Opim.ScopeCategory — used to index into a language's scope config.
---@alias Opim.ScopeCategoryKey "functions"|"classes"|"declarations"|"blocks"|"loops"|"conditions"

--- A function that performs an operation on a resolved scope node.
---@alias Opim.NodeAction fun(node: TSNode, bufnr: integer): nil

--- One language's TreeSitter node type names, bucketed by scope kind.
---@class Opim.ScopeCategory
---@field functions Opim.FunctionNodeType[] node types that represent function definitions
---@field classes Opim.ClassNodeType[] node types that represent class/struct/trait definitions
---@field declarations Opim.DeclarationNodeType[] node types that represent variable/type declarations
---@field blocks Opim.BlockNodeType[] node types that represent code blocks
---@field loops Opim.LoopNodeType[] node types that represent loop statements
---@field conditions Opim.ConditionNodeType[] node types that represent conditional statements

--- TreeSitter language names used as keys in Opim.Scopes.
--- These are the values returned by vim.treesitter.language.get_lang(), NOT filetype names.
--- e.g. filetype "typescriptreact" → ts lang "tsx", filetype "javascriptreact" → ts lang "javascript"
---@alias LanugageFileType
---| "lua"
---| "python"
---| "javascript"
---| "typescript"
---| "tsx"
---| "rust"
---| "go"
---| "c"
---| "cpp"
---| "default"
--- Maps a filetype name (e.g. "lua", "python") to its scope categories.
--- The special key "default" is used as a fallback for unknown filetypes.
---@alias Opim.Scopes table<LanugageFileType, Opim.ScopeCategory>

--- Normal-mode keybinding strings for every scope operation.
---@alias Opim.YankKeys
---| "yank_at_parent"
---| "yank_at_function"
---| "yank_at_declaration"
---| "yank_at_loop"
---| "yank_at_condition"
---| "yank_in_parent"
---| "yank_in_function"
---| "yank_in_declaration"
---| "yank_in_loop"
---| "yank_in_condition"

---@alias Opim.DeleteKeys
---| "delete_at_parent"
---| "delete_at_function"
---| "delete_at_declaration"
---| "delete_at_loop"
---| "delete_at_condition"
---| "delete_in_parent"
---| "delete_in_function"
---| "delete_in_declaration"
---| "delete_in_loop"
---| "delete_in_condition"

---@alias Opim.ChangeKeys
---| "change_at_parent"
---| "change_at_function"
---| "change_at_declaration"
---| "change_at_loop"
---| "change_at_condition"
---| "change_in_parent"
---| "change_in_function"
---| "change_in_declaration"
---| "change_in_loop"
---| "change_in_condition"

---@alias Opim.NavigateKeys
---| "next_function"
---| "prev_function"
---| "next_class"
---| "prev_class"
---| "next_declaration"
---| "prev_declaration"
---| "next_block"
---| "prev_block"
---| "next_loop"
---| "prev_loop"
---| "next_condition"
---| "prev_condition"
---| "goto_parent"
---| "goto_child"
---| "next_sibling_scope"
---| "prev_sibling_scope"

---@alias Opim.InsertKeys
---| "jump_scope_start"
---| "jump_scope_end"

---@alias Opim.VisualKeys
---| "expand_selection"
---| "shrink_selection"
---| "visual_at_parent"
---| "visual_at_function"
---| "visual_at_declaration"
---| "visual_at_loop"
---| "visual_at_condition"
---| "visual_in_parent"
---| "visual_in_function"
---| "visual_in_declaration"
---| "visual_in_loop"
---| "visual_in_condition"

---@class Opim.KeysOpts
---@field enabled boolean -- whether this keymap is enabled at all
---@field modes Opim.Modes | Opim.Modes[] --
---@field operator Opim.Operators | nil -- nil is for "visual" as it is not an operator
---@field keymap string -- NOTE: if 'operator' is nil, the whole keymap will be used, else the part after the operator (e.g. "y" in "yaf") will be used as the keymap

---@alias Opim.Keys table<Opim.YankKeys | Opim.DeleteKeys | Opim.ChangeKeys | Opim.NavigateKeys, Opim.KeysOpts>

--- Partial user overrides for normal-mode keys.
--- Pass `false` to disable a keymap entirely, a string to remap it, or omit to keep the default.
---@class Opim.YankRegister
---@field enabled? boolean whether to perform yank operations at all
---@field name? string the register to use for yank operations (e.g. '"', '+',

--- The resolved, fully-populated plugin configuration (no optional fields).
---@class Opim.Config
---@field scopes Opim.Scopes TreeSitter node type names keyed by filetype
---@field show_warnings boolean emit a warning when keymap conflicts are detected
---@field show_errors boolean emit an error on setup failures
---@field keys Opim.Keys mode-specific keybinding definitions
---@field debug boolean write debug output to opim.log in the cwd
---@field yank_register? Opim.YankRegister write debug output to opim.log in the cwd

--- User-supplied setup options. Every field is optional — omitted fields fall back to plugin defaults.
---@class Opim.Opts
---@field scopes? Opim.Scopes override or extend the per-filetype scope node types
---@field show_warnings? boolean
---@field show_errors? boolean
---@field keys? Opim.PartialKeys pass false for any key to disable it, a string to remap it
---@field debug? boolean

--- A thin wrapper around a TreeSitter node that carries pre-extracted metadata.
---@class Opim.Node
---@field node TSNode the underlying TreeSitter node
---@field type string TreeSitter node type string (e.g. "function_definition")
---@field range integer[] four-element tuple: { start_row, start_col, end_row, end_col }

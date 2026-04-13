-- Minimal Neovim config used when running the test suite headlessly.
-- Adds plenary and the plugin itself to the runtimepath.
--
-- PLENARY_PATH env var overrides the default location.
-- Default: /tmp/plenary.nvim (downloaded by `make test` if missing)

local plenary_path = os.getenv("PLENARY_PATH") or "/tmp/plenary.nvim"

vim.opt.runtimepath:prepend(plenary_path)
vim.opt.runtimepath:prepend(vim.fn.getcwd())

-- Silence startup noise in headless output
vim.opt.swapfile = false
vim.opt.backup = false

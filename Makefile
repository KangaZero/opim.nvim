PLENARY_PATH ?= /tmp/plenary.nvim

.PHONY: test

$(PLENARY_PATH):
	@echo "Fetching plenary.nvim..."
	git clone --depth 1 https://github.com/nvim-lua/plenary.nvim $(PLENARY_PATH)

test: $(PLENARY_PATH)
	@echo "Running opim.nvim tests..."
	PLENARY_PATH=$(PLENARY_PATH) nvim --headless \
		-u tests/minimal_init.lua \
		-c "lua require('plenary.test_harness').test_directory('tests/spec', {minimal_init = 'tests/minimal_init.lua'})"

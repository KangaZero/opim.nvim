# neomouse — developer commands.
#
# Run `make help` for the full list. `make all` is the catch-all that runs
# lint + test + release build (same checks as CI).

.PHONY: help build release run run-release test lint fmt check all clean
.DEFAULT_GOAL := help

# Swift Testing (`import Testing`) needs Testing.framework + lib_TestingInterop
# resolved at runtime. Under Command Line Tools they live at these paths;
# under full Xcode the toolchain finds them itself and the flags are no-ops.
DEV_DIR    := $(shell xcode-select -p)
TEST_FLAGS := \
	-Xswiftc -F -Xswiftc $(DEV_DIR)/Library/Developer/Frameworks \
	-Xlinker -rpath -Xlinker $(DEV_DIR)/Library/Developer/Frameworks \
	-Xlinker -rpath -Xlinker $(DEV_DIR)/Library/Developer/usr/lib

help:  ## Show this help and exit
	@awk 'BEGIN { FS = ":.*## "; printf "Usage:\n  make <target>\n\nTargets:\n" } \
	     /^[a-zA-Z_-]+:.*?## / { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' \
	     $(MAKEFILE_LIST)

build:  ## Build the debug binary (.build/debug/neomouse)
	swift build

release:  ## Build the release binary (.build/release/neomouse)
	swift build -c release

run:  ## Build and run the debug binary
	swift run

run-release:  ## Build and run the release binary
	swift run -c release

test:  ## Run the test suite (with Testing.framework rpath flags)
	swift test $(TEST_FLAGS)

lint:  ## Check Swift formatting / style
	swift format lint --strict --recursive Sources Tests

fmt:  ## Auto-format Swift sources in place
	swift format -i --recursive Sources Tests

check: lint test  ## Lint + test (matches the pre-commit hook and CI)

all: lint test release  ## Catch-all: lint + test + release build

clean:  ## Remove SwiftPM build artifacts
	swift package clean
	rm -rf .build

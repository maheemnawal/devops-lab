SRC_DIR := src
OUT_DIR := out
SOURCES := $(wildcard $(SRC_DIR)/*.txt)
OUTPUTS := $(patsubst $(SRC_DIR)/%.txt,$(OUT_DIR)/%.txt,$(SOURCES))

.PHONY: all check build test clean ci help

all: test ## Build and test everything

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(OUT_DIR)/%.txt: $(SRC_DIR)/%.txt | $(OUT_DIR)
	@echo "BUILD $< -> $@"
	@tr '[:lower:]' '[:upper:]' < $< > $@

check: ## Check that source files exist
	@if [ ! -d "$(SRC_DIR)" ]; then \
		echo "ERROR: source directory $(SRC_DIR) is missing"; \
		exit 1; \
	fi
	@if [ -z "$(SOURCES)" ]; then \
		echo "ERROR: no .txt files found in $(SRC_DIR)"; \
		exit 1; \
	fi
	@echo "CHECK: found $(words $(SOURCES)) source files"

build: $(OUTPUTS) ## Build all outputs

test: build ## Test all outputs
	@if grep -l '[a-z]' $(OUTPUTS) >/dev/null 2>&1; then \
		echo "TEST FAILED: lowercase characters remain"; \
		exit 1; \
	fi
	@echo "TEST PASSED"

clean: ## Remove the output directory
	rm -rf $(OUT_DIR)

ci: clean check test ## Run clean, check, build and test

help: ## Show available targets
	@grep -E '^[a-zA-Z0-9_-]+:.*##' Makefile | \
	awk 'BEGIN {FS = ":.*## "}; {printf "  %-10s %s\n", $$1, $$2}'

count: build ## report source files and built words
	@ls -1 $(SRC_DIR)/*.txt | wc -l
	@wc -w $(OUTPUTS) | tail -1


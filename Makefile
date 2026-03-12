.PHONY: prep_data validate_data help

.DEFAULT_GOAL := help

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

all: prep_data validate_data ## Prepare and validate test data files
	@echo "All tasks completed successfully."

prep_data: ## Prepare test data files
	@echo "Preparing test data files in ${TEST_DATA_DIR}..."
	@./prep_test_data.sh

validate_data: ## Validate the prepared test data files
	@echo "Validating test data files in ${TEST_DATA_DIR}..."
	@./validate_test_data.sh
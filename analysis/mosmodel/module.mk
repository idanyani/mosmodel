MODULE_NAME := analysis/mosmodel
SUBMODULES := train test
SUBMODULES := $(addprefix $(MODULE_NAME)/,$(SUBMODULES))

MOSMODEL_TEMPLATE_MAKEFILE := $(MODULE_NAME)/template.mk

#************* scripts *************
VALIDATE_MODELS := $(ROOT_DIR)/$(MODULE_NAME)/validateModels.py
PLOT_MAX_ERRORS := $(ROOT_DIR)/$(MODULE_NAME)/plotMaxErrors.py
COLLECT_POLYNOMIAL_COEFFICIENTS := $(ROOT_DIR)/$(MODULE_NAME)/collectPolynomialCoefficients.py

#************* consts *************
MAX_ERRORS_PLOT_TITLE := "Max Errors"
TRAIN_ERRORS_FILE := $(MODULE_NAME)/train_errors.csv
TEST_ERRORS_FILE := $(MODULE_NAME)/test_errors.csv
POLY_FILE = $(MODULE_NAME)/poly3.csv

POLY_COEFFICIENTS := $(MODULE_NAME)/poly_coefficients.csv
MAX_ERRORS_PLOTS := $(MODULE_NAME)/linear_models_max_errors.pdf $(MODULE_NAME)/polynomial_models_max_errors.pdf

MOSMODEL_TRAIN_MEAN_CSV_FILE := $(MODULE_NAME)/train/mean.csv
MOSMODEL_TEST_MEAN_CSV_FILE := $(MODULE_NAME)/test/mean.csv

$(MODULE_NAME): $(MAX_ERRORS_PLOTS) $(TRAIN_ERRORS_FILE) $(TEST_ERRORS_FILE) $(TEST_AVG_ERRORS)

$(MAX_ERRORS_PLOTS): $(TEST_ERRORS_FILE)
	$(PLOT_MAX_ERRORS) --errors=$(TEST_ERRORS_FILE) --plot_title=$(MAX_ERRORS_PLOT_TITLE) --output=$(@D)

$(POLY_COEFFICIENTS):
	$(COLLECT_POLYNOMIAL_COEFFICIENTS) --output=$@

$(TRAIN_ERRORS_FILE): $(MOSMODEL_TRAIN_MEAN_CSV_FILE) $(LINEAR_MODELS_COEFFS)
	mkdir -p $(dir $@)
	$(VALIDATE_MODELS) --train_dataset=$(MOSMODEL_TRAIN_MEAN_CSV_FILE) --test_dataset=$(MOSMODEL_TRAIN_MEAN_CSV_FILE) --output=$@ \
		--coeffs_file=$(LINEAR_MODELS_COEFFS) --poly=/dev/null

$(TEST_ERRORS_FILE): $(MOSMODEL_TEST_MEAN_CSV_FILE) $(MOSMODEL_TRAIN_MEAN_CSV_FILE) $(LINEAR_MODELS_COEFFS)
	mkdir -p $(dir $@)
	$(VALIDATE_MODELS) --train_dataset=$(MOSMODEL_TRAIN_MEAN_CSV_FILE) --test_dataset=$(MOSMODEL_TEST_MEAN_CSV_FILE) --output=$@ \
		--coeffs_file=$(LINEAR_MODELS_COEFFS) --poly=$(POLY_FILE)

$(MODULE_NAME)/clean:
	cd $(dir $@)
	rm -f *.pdf
	rm -f *.csv

include $(ROOT_DIR)/common.mk


EXPERIMENTS_ROOT := $(MODULE_NAME:analysis%=experiments%)
$(MODULE_NAME)/%: EXPERIMENTS_ROOT := $(EXPERIMENTS_ROOT)

ANALYSIS_DIRS := $(MODULE_NAME)
NORMALIZED_SCATTER_FILE := $(ANALYSIS_DIRS)/normalized_scatter.csv
SCATTER_FILE := $(ANALYSIS_DIRS)/scatter.csv
MEDIAN_SCATTER_FILE := $(ANALYSIS_DIRS)/median_scatter.csv
ALL_REPEATS_SCATTER_FILE := $(ANALYSIS_DIRS)/all_repeats_scatter.csv
NORMALIZED_SCATTER_CHART := $(ANALYSIS_DIRS)/normalized_scatter.pdf
SCATTER_CHART := $(ANALYSIS_DIRS)/scatter.pdf
MEDIAN_SCATTER_CHART := $(ANALYSIS_DIRS)/median_scatter.pdf
ALL_REPEATS_CHART := $(ANALYSIS_DIRS)/all_repeats.pdf
POLY_CHART := $(ANALYSIS_DIRS)/poly.pdf

ALL_CHARTS := $(SCATTER_CHART) $(MEDIAN_SCATTER_CHART) $(ALL_REPEATS_CHART) $(POLY_CHART)
ALL_CSVS := $(NORMALIZED_SCATTER_FILE) $(SCATTER_FILE) $(MEDIAN_SCATTER_FILE) $(ALL_REPEATS_SCATTER_FILE)

$(MODULE_NAME)%: ALL_CSVS := $(ALL_CSVS) 
$(MODULE_NAME)%: ALL_CHARTS := $(ALL_CHARTS)
$(MODULE_NAME): $(ALL_CSVS) $(ALL_CHARTS)

$(POLY_CHART): $(SCATTER_FILE)
	$(POLY_PLOT) --metric='CPI' \
		--input_file=$< --output_file=$@ > $(dir $@)/poly.csv

$(NORMALIZED_SCATTER_CHART): $(NORMALIZED_SCATTER_FILE)
	gnuplot -e "input_file='$<'" -e "output_file='$@'" $(SCATTER_PLOT)

$(SCATTER_CHART): $(SCATTER_FILE)
	gnuplot -e "input_file='$<'" -e "output_file='$@'" $(SCATTER_PLOT)

$(MEDIAN_SCATTER_CHART): $(MEDIAN_SCATTER_FILE)
	gnuplot -e "input_file='$<'" -e "output_file='$@'" $(SCATTER_PLOT)

$(ALL_REPEATS_CHART): $(ALL_REPEATS_SCATTER_FILE)
	if [[ $(NUM_OF_REPEATS) != 1 ]]; then
	gnuplot -e "input_file='$<'" -e "output_file='$@'" $(SCATTER_PLOT)
	fi

$(NORMALIZED_SCATTER_FILE): analysis/%/normalized_scatter.csv: results/%/mean.csv
	mkdir -p $(dir $@)
	$(ARRANGE_DATA_TO_PLOT) --normalize='by-y' --mean_file=$< --output=$@

$(MEDIAN_SCATTER_FILE): analysis/%/median_scatter.csv: results/%/median.csv
	mkdir -p $(dir $@)
	$(ARRANGE_DATA_TO_PLOT) --mean_file=$< --output=$@

$(SCATTER_FILE): analysis/%/scatter.csv: results/%/mean.csv
	mkdir -p $(dir $@)
	$(ARRANGE_DATA_TO_PLOT) --mean_file=$< --output=$@

$(ALL_REPEATS_SCATTER_FILE): analysis/%/all_repeats_scatter.csv: results/%/all_repeats.csv
	mkdir -p $(dir $@)
	$(ARRANGE_DATA_TO_PLOT) --mean_file=$< --output=$@

$(MODULE_NAME)/clean:
	rm -f $(ALL_CHARTS) $(ALL_CSVS)

include $(ROOT_DIR)/common.mk


MODULE_NAME := experiments/memory_footprint
LAYOUTS := layout4kb

EXTRA_ARGS_FOR_MOSALLOC := --analyze
NUM_OF_REPEATS := 1

include $(EXPERIMENTS_TEMPLATE)

CREATE_MEMORY_FOOTPRINT_LAYOUTS_SCRIPT := $(MODULE_NAME)/createLayouts.py
$(LAYOUTS_FILE):
	ram_size_kb=$(shell grep MemTotal /proc/meminfo | cut -d ':' -f 2 | sed 's, ,,g' | sed 's,kB,,g')
	$(CREATE_MEMORY_FOOTPRINT_LAYOUTS_SCRIPT) --mem_max_size_kb=$$ram_size_kb --mmap_pool_limit=$(MMAP_POOL_LIMIT) --output=$@

# undefine LAYOUTS to allow next makefiles to use the defaults LAYOUTS
undefine EXTRA_ARGS_FOR_MOSALLOC
undefine LAYOUTS
undefine NUM_OF_REPEATS

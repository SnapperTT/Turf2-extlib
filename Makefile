include deps.mk
include tests.mk
include ctags.mk

help:
	@echo "Make targets: TARGET_OS= $(LISTED_TARGETS)"

list:
	@echo "Make targets: TARGET_OS= $(LISTED_TARGETS)"

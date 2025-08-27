# MIT License
#
# Copyright (c) 2025 Florent Werbrouck
#

# =========================================================
# PROJECT NAME
# =========================================================
PROJECT_NAME ?= TE0950_basic
XSA_TCL ?= $(PROJECT_NAME).tcl

# =========================================================
# DEVICE SELECTION
# =========================================================
DEVICE_NAME ?= xcve2302-sfva784-1LP-e-S

# =========================================================
#  BOARD PART SELECTION (Production)
# =========================================================
BOARD_VENDOR:=trenz.biz
BOARD_LABEL:=te0950_23_1lse
BOARD_VER:=1.2

# =========================================================
# BUILD PRODUCTS
# ========================================================
BUILD_DIR := build

.PHONY: clean all
##############
# Build Flow #
##############
all:
	vivado -mode batch -source $(XSA_TCL) -tclargs $(PROJECT_NAME) $(DEVICE_NAME) $(BOARD_VENDOR) $(BOARD_LABEL) $(BOARD_VER) $(BUILD_DIR)
	
clean:
	rm -rf $(BUILD_DIR)
	rm -rf .Xil vivado* .crash*
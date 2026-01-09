# MIT License
#
# Copyright (c) 2025 - 2026 Florent Werbrouck
#

# =========================================================
# PROJECT NAME
# =========================================================
PROJECT_NAME ?= TE0950_basic
PROJECT_VERSION ?= 2025_2_0
VITIS_PLATFORM ?= $(PROJECT_NAME)_$(PROJECT_VERSION)
XSA_FILE ?= $(PROJECT_NAME).xsa

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
# SOURCE DIRECTORIES
# =========================================================
SRC_DIR := src

# =========================================================
#  WORKSPACE DIRECTORY
# ========================================================
WORKSPACE_DIR := workspace

# =========================================================
# WORKSPACE CREATION SCRIPT
# =========================================================
WORKSPACE_PY  := $(SRC_DIR)/TE950_basic.tcl


##############
# Build Flow #
##############
all:
	mkdir workspace
	vitis -s TE0950_basic.py ${VITIS_PLATFORM} ${XSA_FILE}
	
clean:
	rm -rf $(BUILD_DIR)
	rm -rf .Xil $(WORKSPACE_DIR)
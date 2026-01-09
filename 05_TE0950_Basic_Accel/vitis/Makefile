#
# Copyright (C) 2025, Florent Werbrouck. All rights reserved.
# SPDX-License-Identifier: MIT
#

# =========================================================
# PROJECT NAME
# =========================================================
PROJECT_NAME 		?= TE0950_basic_accel
PROJECT_VERSION 	?= 2025_2_1_0
VITIS_PLATFORM 		?= $(PROJECT_NAME)_$(PROJECT_VERSION)
XSA_FILE 			?= $(PROJECT_NAME).xsa
WORKSPACE_DIR		?= workspace

# =========================================================
# DEVICE SELECTION
# =========================================================
DEVICE_NAME ?= xcve2302-sfva784-1LP-e-S

##############
# Build Flow #
##############
all:
	vitis -s vitis_basic_accel.py ${VITIS_PLATFORM} $(WORKSPACE_DIR) ${XSA_FILE} ${DEVICE_NAME}
	
clean:
	rm -rf $(BUILD_DIR)
	rm -rf .Xil $(WORKSPACE_DIR) _ide

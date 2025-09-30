#
# Copyright (C) 2025, Florent Werbrouck. All rights reserved.
# SPDX-License-Identifier: MIT
#

## ===================================================================================
## Create Platform Vivado Project
## This script takes in 6 arguments:
## PROJECT_NAME
## DEVICE_NAME (e.g. xcve2302-sfva784-1LP-e-S)
## BOARD_VENDOR
## BOARD_LABEL
## BOARD_VER
## BUILD_DIR
## ===================================================================================
namespace eval _tcl {
  proc get_script_folder {} {
    set script_path [file normalize [info script]]
    set script_folder [file dirname $script_path]
    return $script_folder
  }
}

set PROJECT_NAME [lindex $argv 0]
set DEVICE_NAME [lindex $argv 1]
set BOARD_VENDOR [lindex $argv 2]
set BOARD_LABEL [lindex $argv 3]
set BOARD_VER [lindex $argv 4]
set BUILD_DIR [lindex $argv 5]

set PFM_REV 1
set PFM_UPDATE 0
set MAJOR_VERSION [ lindex [split [version -short] "."] 0 ]
set MINOR_VERSION [ lindex [split [version -short] "."] 1 ]
set BOARD_VENDOR_SHORT [lindex [split $BOARD_VENDOR "."] 0]
set BOARD_LABEL_SHORT [lindex [split $BOARD_LABEL "_"] 0]
set PLATFORM_NAME ${BOARD_VENDOR_SHORT}_${BOARD_LABEL_SHORT}_base_${MAJOR_VERSION}_${MINOR_VERSION}_${PFM_REV}_${PFM_UPDATE}
set PFM_VER ${PFM_REV}.${PFM_UPDATE}

# Create Project
create_project ${PROJECT_NAME} ${BUILD_DIR}/${PROJECT_NAME} -part ${DEVICE_NAME}

# set board part 
set_property BOARD_PART ${BOARD_VENDOR}:${BOARD_LABEL}:part0:${BOARD_VER} [current_project]

# Create Block Design
create_bd_design ${PROJECT_NAME}_bd

# Open the custom Configurable Example Design for third party boards
instantiate_example_design -template xflorentw:design:ext_platform_board:1.0 -design ${PROJECT_NAME}_bd -options { Include_AIE.VALUE true Include_DDR.VALUE true}

set_property preferred_sim_model "tlm" [current_project]
update_compile_order -fileset sources_1

# Validate the Block Design
validate_bd_design

# Generate the block design
generate_target all [get_files  ${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.srcs/sources_1/bd/${PROJECT_NAME}_bd/${PROJECT_NAME}_bd.bd]

# Set output type to hw_export
set_property platform.default_output_type           "sd_card" [current_project]

# Help by explicitly categorizing intended platform (embedded)
set_property platform.design_intent.server_managed  "false"   [current_project]
set_property platform.design_intent.external_host   "false"   [current_project]
set_property platform.design_intent.embedded        "true"    [current_project]
set_property platform.design_intent.datacenter      "false"   [current_project]
set_property platform.extensible                    "true"    [current_project]

# Set Platform properties
set_property platform.version $PFM_VER [current_project]
set_property platform.name $PLATFORM_NAME [current_project]
set_property platform.board_id $BOARD_LABEL_SHORT [current_project]
set_property platform.vendor $BOARD_VENDOR [current_project]
set_property pfm_name $BOARD_VENDOR:$BOARD_LABEL_SHORT:$PLATFORM_NAME:$PFM_VER [get_files ${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.srcs/sources_1/bd/${PROJECT_NAME}_bd/${PROJECT_NAME}_bd.bd]
set_property platform.uses_pr {false} [current_project]

save_bd_design

write_hw_platform -force -file ${BUILD_DIR}/${PROJECT_NAME}.xsa
# MIT License
#
# Copyright (c) 2025 Florent Werbrouck
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

# Create Project
create_project ${PROJECT_NAME} ${BUILD_DIR}/${PROJECT_NAME} -part ${DEVICE_NAME}

# set board part 
set_property BOARD_PART ${BOARD_VENDOR}:${BOARD_LABEL}:part0:${BOARD_VER} [current_project]

# Create Block Design
create_bd_design ${PROJECT_NAME}_bd

#Add CIPS
create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips:3.4 versal_cips_0

# Run Block Automation
apply_bd_automation -rule xilinx.com:bd_rule:cips -config { board_preset {Yes} boot_config {Custom} configure_noc {Add new AXI NoC} debug_config {JTAG} design_flow {Full System} mc_type {None} num_mc_ddr {None} num_mc_lpddr {None} pl_clocks {None} pl_resets {None}}  [get_bd_cells versal_cips_0]

# Generate BD output product and BD wrapper
save_bd_design

generate_target all [get_files  ${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.srcs/sources_1/bd/${PROJECT_NAME}_bd/${PROJECT_NAME}_bd.bd]

export_ip_user_files -of_objects [get_files ${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.srcs/sources_1/bd/${PROJECT_NAME}_bd/${PROJECT_NAME}_bd.bd] -no_script -sync -force -quiet

create_ip_run [get_files -of_objects [get_fileset sources_1] ${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.srcs/sources_1/bd/${PROJECT_NAME}_bd/${PROJECT_NAME}_bd.bd]

export_simulation -lib_map_path [list {modelsim=${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.cache/compile_simlib/modelsim} {questa=${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.cache/compile_simlib/questa} {xcelium=${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.cache/compile_simlib/xcelium} {vcs=${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.cache/compile_simlib/vcs} {riviera=${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.cache/compile_simlib/riviera}] -of_objects [get_files ${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.srcs/sources_1/bd/${PROJECT_NAME}_bd/${PROJECT_NAME}_bd.bd] -directory ${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.ip_user_files/sim_scripts -ip_user_files_dir ${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.ip_user_files -ipstatic_source_dir ${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.ip_user_files/ipstatic -use_ip_compiled_libs -force -quiet

make_wrapper -files [get_files ${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.srcs/sources_1/bd/${PROJECT_NAME}_bd/${PROJECT_NAME}_bd.bd] -top
add_files -norecurse ${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.gen/sources_1/bd/${PROJECT_NAME}_bd/hdl/${PROJECT_NAME}_bd_wrapper.v

# Run Synthesis, Implementation and Generate the device image
launch_runs synth_1
wait_on_run synth_1
launch_runs impl_1
wait_on_run impl_1
launch_runs impl_1 -to_step write_device_image
wait_on_run impl_1

# Export XSA
write_hw_platform -fixed -include_bit -force -file ${BUILD_DIR}/${PROJECT_NAME}.xsa
#
# Copyright (C) 2025, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: X11
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

#Add AXI NoC
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 axi_noc_0

# Run Block Automation
apply_bd_automation -rule xilinx.com:bd_rule:axi_noc -config { hbm_density {None} hbm_internal_clk {0} hbm_nmu {None} mc_type {DDR} noc_clk {None} num_axi_bram {None} num_axi_tg {None} num_aximm_ext {None} num_mc_ddr {1} num_mc_lpddr {None} pl2noc_apm {0} pl2noc_cips {1}}  [get_bd_cells axi_noc_0]

# Enable PS to NoC interfaces
set_property CONFIG.PS_PMC_CONFIG { \
  DDR_MEMORY_MODE {Connectivity to DDR via NOC} \
  DEBUG_MODE {JTAG} \
  DESIGN_MODE {1} \
  PMC_BANK_0_IO_STANDARD {LVCMOS1.8} \
  PMC_BANK_1_IO_STANDARD {LVCMOS1.8} \
  PMC_CRP_HSM0_REF_CTRL_FREQMHZ {33.333333} \
  PMC_CRP_HSM1_REF_CTRL_FREQMHZ {133.333333} \
  PMC_I2CPMC_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 34 .. 35}}} \
  PMC_MIO27 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
  PMC_MIO37 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
  PMC_MIO51 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
  PMC_OSPI_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 0 .. 11}} {MODE Single}} \
  PMC_QSPI_FBCLK {{ENABLE 1} {IO {PMC_MIO 6}}} \
  PMC_QSPI_PERIPHERAL_DATA_MODE {x1} \
  PMC_QSPI_PERIPHERAL_ENABLE {0} \
  PMC_QSPI_PERIPHERAL_MODE {Single} \
  PMC_REF_CLK_FREQMHZ {33.333333} \
  PMC_SD0 {{CD_ENABLE 0} {CD_IO {PMC_MIO 24}} {POW_ENABLE 0} {POW_IO {PMC_MIO 17}} {RESET_ENABLE 1} {RESET_IO {PMC_MIO 49}} {WP_ENABLE 0} {WP_IO {PMC_MIO 25}}} \
  PMC_SD0_DATA_TRANSFER_MODE {8Bit} \
  PMC_SD0_PERIPHERAL {{CLK_100_SDR_OTAP_DLY 0x00} {CLK_200_SDR_OTAP_DLY 0x2} {CLK_50_DDR_ITAP_DLY 0x1E} {CLK_50_DDR_OTAP_DLY 0x5} {CLK_50_SDR_ITAP_DLY 0x2C} {CLK_50_SDR_OTAP_DLY 0x5} {ENABLE 1} {IO {PMC_MIO 37 .. 49}}} \
  PMC_SD0_SLOT_TYPE {eMMC} \
  PMC_SD1 {{CD_ENABLE 1} {CD_IO {PMC_MIO 28}} {POW_ENABLE 0} {POW_IO {PMC_MIO 12}} {RESET_ENABLE 0} {RESET_IO {PMC_MIO 12}} {WP_ENABLE 0} {WP_IO {PMC_MIO 1}}} \
  PMC_SD1_DATA_TRANSFER_MODE {4Bit} \
  PMC_SD1_PERIPHERAL {{CLK_100_SDR_OTAP_DLY 0x00} {CLK_200_SDR_OTAP_DLY 0x00} {CLK_50_DDR_ITAP_DLY 0x00} {CLK_50_DDR_OTAP_DLY 0x00} {CLK_50_SDR_ITAP_DLY 0x2C} {CLK_50_SDR_OTAP_DLY 0x4} {ENABLE 1} {IO {PMC_MIO 26 .. 36}}} \
  PMC_SD1_SLOT_TYPE {SD 2.0} \
  PMC_USE_PMC_NOC_AXI0 {1} \
  PS_BANK_2_IO_STANDARD {LVCMOS1.8} \
  PS_BANK_3_IO_STANDARD {LVCMOS3.3} \
  PS_BOARD_INTERFACE {ps_pmc_fixed_io} \
  PS_ENET0_MDIO {{ENABLE 1} {IO {PS_MIO 24 .. 25}}} \
  PS_ENET0_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 0 .. 11}}} \
  PS_GEN_IPI0_ENABLE {1} \
  PS_GEN_IPI1_ENABLE {1} \
  PS_GEN_IPI2_ENABLE {1} \
  PS_GEN_IPI3_ENABLE {1} \
  PS_GEN_IPI4_ENABLE {1} \
  PS_GEN_IPI5_ENABLE {1} \
  PS_GEN_IPI6_ENABLE {1} \
  PS_HSDP_EGRESS_TRAFFIC {JTAG} \
  PS_HSDP_INGRESS_TRAFFIC {JTAG} \
  PS_HSDP_MODE {NONE} \
  PS_I2C1_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 16 .. 17}}} \
  PS_I2CSYSMON_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 18 .. 19}}} \
  PS_MIO22 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
  PS_MIO23 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
  PS_NUM_FABRIC_RESETS {0} \
  PS_UART1_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 12 .. 13}}} \
  PS_USB3_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 13 .. 25}}} \
  PS_USE_FPD_AXI_NOC0 {1} \
  PS_USE_FPD_AXI_NOC1 {1} \
  PS_USE_FPD_CCI_NOC {1} \
  PS_USE_FPD_CCI_NOC0 {1} \
  PS_USE_NOC_LPD_AXI0 {1} \
  PS_USE_PMCPL_CLK0 {0} \
  PS_USE_PMCPL_CLK1 {0} \
  PS_USE_PMCPL_CLK2 {0} \
  PS_USE_PMCPL_CLK3 {0} \
  SMON_ALARMS {Set_Alarms_On} \
  SMON_ENABLE_TEMP_AVERAGING {0} \
  SMON_INTERFACE_TO_USE {I2C} \
  SMON_TEMP_AVERAGING_SAMPLES {0} \
  SMON_VAUX_CH0 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 1} {IO_N LPD_MIO21_502} {IO_P LPD_MIO20_502} {MODE {1 V unipolar}} {NAME VAUX_CH0} {SUPPLY_NUM 0}} \
  SMON_VAUX_CH1 {{ALARM_ENABLE 0} {ALARM_LOWER 0} {ALARM_UPPER 1} {AVERAGE_EN 0} {ENABLE 1} {IO_N LPD_MIO15_502} {IO_P LPD_MIO14_502} {MODE {1 V unipolar}} {NAME VAUX_CH1} {SUPPLY_NUM 1}} \
} [get_bd_cells versal_cips_0]

# Add to Slave AXI interfaces to the NoC
set_property -dict [list \
  CONFIG.NUM_CLKS {8} \
  CONFIG.NUM_SI {8} \
] [get_bd_cells axi_noc_0]

# Set the Slave interfaces Non-Coherent and connect them to the memory controller ports
set_property -dict [list CONFIG.CATEGORY {ps_nci} CONFIG.CONNECTIONS {MC_2 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}}] [get_bd_intf_pins /axi_noc_0/S06_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_nci} CONFIG.CONNECTIONS {MC_3 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}}] [get_bd_intf_pins /axi_noc_0/S07_AXI]

# Connect the CIPS AXI Interfaces to the NoC
connect_bd_intf_net [get_bd_intf_pins versal_cips_0/FPD_AXI_NOC_0] [get_bd_intf_pins axi_noc_0/S06_AXI]
connect_bd_intf_net [get_bd_intf_pins versal_cips_0/FPD_AXI_NOC_1] [get_bd_intf_pins axi_noc_0/S07_AXI]
connect_bd_net [get_bd_pins versal_cips_0/fpd_axi_noc_axi0_clk] [get_bd_pins axi_noc_0/aclk6]
connect_bd_net [get_bd_pins versal_cips_0/fpd_axi_noc_axi1_clk] [get_bd_pins axi_noc_0/aclk7]

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
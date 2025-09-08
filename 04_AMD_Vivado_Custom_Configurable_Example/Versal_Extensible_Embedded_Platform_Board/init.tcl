# ########################################################################
# Copyright (c) 2025 Florent Werbrouck
# SPDX-License-Identifier: MIT
#########################################################################

set currentFile [file normalize [info script]]
set currentDir [file dirname $currentFile]

proc createDesign {design_name options} {

	variable currentDir
	set_property target_language Verilog [current_project]
	source "$currentDir/run.tcl"
}

# *******************User defined proc (filter Trenz TE0950 Board )****************************

proc getSupportedParts {} {
	
	set V_board_unique [get_board_parts -filter {(BOARD_NAME =~"*vck190*" && VENDOR_NAME=="xilinx.com")||(BOARD_NAME =~"*vek280*" && VENDOR_NAME=="xilinx.com")||(BOARD_NAME =~"te0950*" && VENDOR_NAME=="trenz.biz")} -latest_file_version]
	return ""
}

proc getSupportedBoards {} {
	set V_board_unique [get_board_parts -filter {(BOARD_NAME =~"*vck190*" && VENDOR_NAME=="xilinx.com")||(BOARD_NAME =~"*vek280*" && VENDOR_NAME=="xilinx.com")||(BOARD_NAME =~"te0950*" && VENDOR_NAME=="trenz.biz")} -latest_file_version]
	return $V_board_unique
}

proc addOptions {DESIGNOBJ PROJECT_PARAM.PART} {
    lappend x [dict create name "Include_LPDDR" type "bool" value "true" enabled false]
	lappend x [dict create name "Include_DDR" type "bool" value "true" enabled false]
	lappend x [dict create name "Include_AIE" type "bool" value "false" enabled true]
    lappend x [dict create name "Clock_Options" type "string" value "clk_out1 156.250000 0 true" enabled true]
    lappend x [dict create name "IRQS" type "string" value "15" value_list {"15 15_AXI_Masters_and_Interrupts,_Single_Interrupt_Controller" "32 32_AXI_Masters_and_Interrupts,_Single_Interrupt_Controller"} enabled true]
    return $x
}

proc addGUILayout {DESIGNOBJ PROJECT_PARAM.PART} {

    set designObj $DESIGNOBJ
    set page [ced::add_page -name "Page1" -display_name "Versal_ext_platform Configuration" -designObject $designObj -layout vertical]

    set clocks [ced::add_group -name "Clocks" -display_name "Clocks"  -parent $page -visible true -designObject $designObj ]
    ced::add_custom_widget -name widget_Clocks -hierParam Clock_Options -class_name PlatformClocksWidget -parent $clocks $designObj
    set text "Note : The requested clock frequencies are not verified until the design is generated. Clocking wizard restrictions will be applied.
	User should check the 'Messages' window once the design is created to ensure that the selected clock frequencies are derived."
    ced::add_text -designObject $designObj -name Note -tclproc $text  -parent $clocks

    ced::add_param -name IRQS -display_name "AXI Masters and Interrupts" -parent $page -designObject $designObj -widget radioGroup
	
	set aie [ced::add_group -name "AIE Block" -display_name "AIE Block"  -parent $page -visible true -designObject $designObj]
	ced::add_param -name Include_AIE -display_name "AIE" -parent $aie -designObject $designObj -widget checkbox
	
	
}

validater { Clock_Options.VALUE } { Clock_Options.ERRMSG } {
    set clk_options ${Clock_Options.VALUE}
    set clk_ports {}
    set clk_freqs {}
    set clk_ids {}
    set clk_defaults {}

    set i 0
    foreach { port freq id is_default } $clk_options {
        lappend clk_ports $port
        lappend clk_freqs $freq
        lappend clk_ids $id
        lappend clk_defaults $is_default
        incr i
    }

    # check for well-formed port names
    foreach { port } [ lsort -unique $clk_ports ] {
        set result [regexp -nocase -- {^[a-z0-9_]+$} $port]
        if { !$result } {
            puts "The clock port name must be alphanumeric: $port"
        }
    }

    # check for repeated clock ports
    foreach { port } [ lsort -unique $clk_ports ] {
        set count [llength [lsearch -all $clk_ports $port]]
        if { $count > 1 } {
            puts "The clock port name is not unique: $port"
			set Clock_Options.ERRMSG "Found multiple clock ports with same port name. Please set unique name for each clock port."
        }
    }

    # check for repeated clock ids
    foreach { id } [ lsort -unique $clk_ids ] {
        set count [llength [lsearch -all $clk_ids $id]]
        if { $count > 1 } {
            puts "Clock ID is not unique: $id"
			set Clock_Options.ERRMSG "Found multiple clock ports with same clock ID. Please set unique clock ID for each clock port."
        }
    }

    # check for repeated clock frequencies
    # UI enforces formatting (100 vs 100.000) so we can use direct string compare
    foreach { freq } [ lsort -unique $clk_freqs ] {
        set count [llength [lsearch -all $clk_freqs $freq]]
        if { $count > 1 } {
            puts "Clock frequency used more than once: $freq"
        }
    }

    # check for min/max freqs. per clocking wizard 6.0 docs PG065, this is 10-1066 MHz
    foreach { freq } $clk_freqs {
        if { [expr $freq < 10 || $freq > 1066] } {
            puts "Clock frequency $freq out of range. It must be between 10-1066 MHz."
        }
    }

    # check for exactly one default clock
    if {[ lsearch $clk_defaults true ] == -1} {
        puts "No default clock is selected."
    } elseif {[llength [lsearch -all $clk_defaults true]] > 1} {
        puts "Multiple default clocks are selected. There can be only one default clock."
    }
}

gui_updater {PROJECT_PARAM.PART} {Include_AIE.VISIBLE Include_AIE.ENABLEMENT Include_AIE.VALUE} {
	set gui_flag 0
	set V_Part [debug::dump_part_properties [get_parts ${PROJECT_PARAM.PART}]]
	
	foreach get_aie_prop $V_Part {
		
		if {([regexp "AIE_ENGINE" [lindex $get_aie_prop 1 ]] == 1) && ([lindex $get_aie_prop 3 ] != 0) } {
			set Include_AIE.ENABLEMENT true
			set Include_AIE.VALUE true
			set gui_flag 1
		} elseif {$gui_flag == 0} {
			set Include_AIE.ENABLEMENT false
			set Include_AIE.VALUE false
			set gui_flag 0
		}
	}
}
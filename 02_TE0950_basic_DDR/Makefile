#
# Copyright (C) 2025, Florent Werbrouck. All rights reserved.
# SPDX-License-Identifier: MIT
#

##############
# Build Flow #
##############
.PHONY: clean help all vivado vitis

help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make vivado"
	$(ECHO) "      Builds the Vivado project"
	$(ECHO) ""
	$(ECHO) "  make vitis"
	$(ECHO) "      Builds the Vitis workspace"
	$(ECHO) "      * Depends on vivado_platform rule to be completed"
	$(ECHO) ""
	$(ECHO) "  make all"
	$(ECHO) "      Generate the full project
	$(ECHO) ""
	$(ECHO) "  make clean"
	$(ECHO) "      Command to remove all the generated files."
	
vivado:
	$(MAKE) all -C vivado

vitis:
	$(MAKE) all -C vitis
	
all: vivado vitis
	
clean:
	$(MAKE) clean -C vivado
	$(MAKE) clean -C vitis


#
# Copyright (C) 2025, Florent Werbrouck. All rights reserved.
# SPDX-License-Identifier: MIT
#

################################################################################
# Variables needed for AMD tools version checking, PLEASE DO NOT MODIFY #
################################################################################

##############
# Build Flow #
##############
.PHONY: clean help all vivado vitis

help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make vivado"
	$(ECHO) "      Builds the Vivado project"
	$(ECHO) ""
	$(ECHO) "  make petalinux"
	$(ECHO) "      Builds the petalinux project"
	$(ECHO) "      * Depends on vivado rule to be completed"
	$(ECHO) ""
	$(ECHO) "  make all"
	$(ECHO) "      Generate the full project
	$(ECHO) ""
	$(ECHO) "  make clean"
	$(ECHO) "      Command to remove all the generated files."
	
vivado:
	$(MAKE) all -C vivado

petalinux:
	$(MAKE) all -C os/petalinux
	
all: vivado petalinux
	
clean:
	$(MAKE) clean -C vivado
	$(MAKE) clean -C os/petalinux


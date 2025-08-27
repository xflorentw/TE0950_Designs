# MIT License
#
# Copyright (c) 2025 Florent Werbrouck
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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


#
# Copyright (C) 2025, Florent Werbrouck. All rights reserved.
# SPDX-License-Identifier: MIT
#

# =========================================================
# PROJECT NAME
# =========================================================
VIVADO_PROJECT_NAME 		?= TE0950_basic_DDR
PETALINUX_PROJECT_NAME 		?= TE0950_basic_petalinux
XSA_FILE 					?= $(VIVADO_PROJECT_NAME).xsa

# =========================================================
# PROJECT SETTINGS
# =========================================================
LINUX_TMP_DIR              ?= /tmp/${USER}/${PETALINUX_PROJECT_NAME}/petalinux
CFG                        := ./src/config
DTSI_FILES				   := \"file:\/\/system-user.dtsi file:\/\/TE0950.dtsi\"

# =========================================================
# SOURCE DIRECTORIES
# =========================================================
SRC_DIR 				   := src
CURR_DIR                   := $(shell pwd)
PROJ_DIR                   := ${CURR_DIR}/${PETALINUX_PROJECT_NAME}
FILE_MAIN_CFG              := ${PROJ_DIR}/project-spec/configs/config
XSA_DIR                    := ${CURR_DIR}/../../vivado/build
SRC_DIR_DEVICE_TREE        := ./src/recipes-bsp/device-tree/files
DEST_DIR_DEVICE_TREE       := ${PROJ_DIR}/project-spec/meta-user/recipes-bsp/device-tree/files


##############
# Build Flow #
##############
all: create update_config update_device_tree build_proj package sd_card

create:
	petalinux-create project --template versal --name $(PETALINUX_PROJECT_NAME) --tmpdir ${LINUX_TMP_DIR}

update_config:
	cd $(PETALINUX_PROJECT_NAME) && petalinux-config --get-hw-description=${XSA_DIR} --silentconfig
	${CFG} --file ${FILE_MAIN_CFG}  --set-str CONFIG_SUBSYSTEM_RFS_FORMATS "tar.gz ext4"
	${CFG} --file ${FILE_MAIN_CFG}   --keep-case --disable CONFIG_SUBSYSTEM_ROOTFS_INITRAMFS
	${CFG} --file ${FILE_MAIN_CFG}   --keep-case --enable CONFIG_SUBSYSTEM_ROOTFS_EXT4
	${CFG} --file ${FILE_MAIN_CFG}  --set-str CONFIG_SUBSYSTEM_SDROOT_DEV "/dev/mmcblk1p2"
	${CFG} --file ${FILE_MAIN_CFG}   --keep-case --disable CONFIG_SUBSYSTEM_BOOTARGS_AUTO
	${CFG} --file ${FILE_MAIN_CFG}  --set-str  CONFIG_SUBSYSTEM_USER_CMDLINE "console=ttyAMA0 earlycon=pl011,mmio32,0xFF010000,115200n8 clk_ignore_unused root=/dev/mmcblk1p2 rw rootwait cma=512M"
	cd $(PETALINUX_PROJECT_NAME) && petalinux-config  --silentconfig
	
update_device_tree:
	cp -r ${SRC_DIR_DEVICE_TREE}/* ${DEST_DIR_DEVICE_TREE}/
	sed -i 's/SRC_URI:append.*/SRC_URI:append = $(DTSI_FILES)/' $(DEST_DIR_DEVICE_TREE)/../device-tree.bbappend
	sed -i '2i /include/ "TE0950.dtsi"' $(DEST_DIR_DEVICE_TREE)/system-user.dtsi
	
build_proj:
	cd $(PETALINUX_PROJECT_NAME) && petalinux-build

package:
	cd $(PETALINUX_PROJECT_NAME) && petalinux-package boot --u-boot

sd_card:
	cd $(PETALINUX_PROJECT_NAME) && petalinux-package wic

clean:
	rm -rf $(PETALINUX_PROJECT_NAME) ${LINUX_TMP_DIR}
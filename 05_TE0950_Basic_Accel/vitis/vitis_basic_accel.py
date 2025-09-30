#
# Copyright (C) 2025, Florent Werbrouck. All rights reserved.
# SPDX-License-Identifier: MIT
#

import vitis
import sys
import os

cmd_args=len(sys.argv)
args=str(sys.argv)

platform_name=sys.argv[1]
workspace=sys.argv[2]
xsa=sys.argv[3]
part=sys.argv[4]

app_path= os.getcwd()

hls_src_loc = "../../src/hls/"
sysroot_path = app_path+"/../os/petalinux/sysroot/sysroots/cortexa72-cortexa53-amd-linux"

client = vitis.create_client()
client.set_workspace(path=workspace)

print ("\n-----------------------------------------------------")
print ("Creating Custom Platorm with Linux and AIE-ML domains\n")
advanced_options = client.create_advanced_options_dict(dt_overlay="0")
platform = client.create_platform_component(name = platform_name,hw_design = "../vivado/build/"+xsa,os = "linux",cpu = "psv_cortexa72",domain_name = "linux_psv_cortexa72",generate_dtb = False,advanced_options = advanced_options)
platform = client.get_component(name=platform_name)

domain = platform.get_domain(name="linux_psv_cortexa72")

status = domain.set_bif(path="./src/platform/linux.bif")
status = domain.set_boot_dir(path="../os/petalinux/TE0950_basic_accel_petalinux/images/linux")
status = domain.set_dtb(path="../os/petalinux/TE0950_basic_accel_petalinux/images/linux/system.dtb")

domain = platform.add_domain(cpu = "ai_engine",os = "aie_runtime",name = "aie-ml",display_name = "aie-ml",generate_dtb = False)

status = platform.build()

# Get platform from install repository
platform_xpfm = client.find_platform_in_repos(platform_name)

print ("\n-----------------------------------------------------")
print ("Creating AIE-ML component from Simple template\n")
comp = client.create_aie_component(name="aie_component_simple", platform = platform_xpfm, template = "installed_aie_examples/simple")
comp = client.get_component(name="aie_component_simple")
comp.build(target="hw")

print ("\n-----------------------------------------------------")
print ("Creating MM2S and S2MM HLS kernels\n")
comp = client.create_hls_component(name = "mm2s",cfg_file = ["mm2s_config.cfg"],template = "empty_hls_component")

comp = client.get_component(name="mm2s")
hls_comp_cfg = client.get_config_file(comp.component_location+'/mm2s_config.cfg')
hls_comp_cfg.set_value(key='part', value=part)
hls_comp_cfg.set_value(section='hls', key='flow_target', value='vitis')
hls_comp_cfg.set_value(section='hls', key='package.output.format', value='xo')
hls_comp_cfg.set_value(section='hls', key='package.output.syn', value='true')
hls_comp_cfg.set_values(section='hls', key='syn.file', values=[hls_src_loc+'mm2s.cpp'])
hls_comp_cfg.set_value(section='hls', key='syn.top', value='mm2s')
comp.run(operation="SYNTHESIS")
comp.run(operation="PACKAGE")

comp = client.create_hls_component(name = "s2mm",cfg_file = ["s2mm_config.cfg"],template = "empty_hls_component")
comp = client.get_component(name="s2mm")
hls_comp_cfg = client.get_config_file(comp.component_location+'/s2mm_config.cfg')
hls_comp_cfg.set_value(key='part', value=part)
hls_comp_cfg.set_value(section='hls', key='flow_target', value='vitis')
hls_comp_cfg.set_value(section='hls', key='package.output.format', value='xo')
hls_comp_cfg.set_value(section='hls', key='package.output.syn', value='true')
hls_comp_cfg.set_values(section='hls', key='syn.file', values=[hls_src_loc+'s2mm.cpp'])
hls_comp_cfg.set_value(section='hls', key='syn.top', value='s2mm')
comp.run(operation="SYNTHESIS")
comp.run(operation="PACKAGE")

print ("\n-----------------------------------------------------")
print ("Creating Host Application Component\n")
comp = client.create_app_component(name="host_app",platform = platform_xpfm,domain = "linux_psv_cortexa72")
comp = client.get_component("host_app")
status = comp.set_sysroot(sysroot=sysroot_path)
status = comp.import_files(from_loc="./src/", files=["sw/"])
comp.append_app_config(key = 'USER_INCLUDE_DIRECTORIES', values = [sysroot_path+'/usr/include/xrt'])
comp.append_app_config(key = 'USER_INCLUDE_DIRECTORIES', values = [sysroot_path+'/usr/include/'])
comp.append_app_config(key = 'USER_LINK_LIBRARIES', values = ['xrt_coreutil'])
comp.set_app_config(key = 'USER_CMAKE_CXX_STANDARD', values = "17")
status = platform.build()
comp.build(target="hw")

print ("\n-----------------------------------------------------")
print ("Creating System Project and Running v++ Link\n")

#
#   Create System Project
#
proj = client.create_sys_project(name="basic_accel_system_project", platform=platform_xpfm, template="empty_accelerated_application")
proj = client.get_sys_project(name="basic_accel_system_project")
status = proj.add_container(name="binary_container_1")
proj = proj.add_component(name="aie_component_simple", container_name=['binary_container_1'])
proj = proj.add_component(name="mm2s", container_name="binary_container_1")
proj = proj.add_component(name="s2mm", container_name="binary_container_1")
proj = proj.add_component(name="host_app")

#
#   Edit linker configuration
#
cfg = client.get_config_file(proj.project_location+'/hw_link/binary_container_1-link.cfg')
cfg.add_values(section='connectivity', key='sc', values=['mm2s_1.s:ai_engine_0.mygraph_in'])
cfg.add_values(section='connectivity', key='sc', values=['ai_engine_0.mygraph_out:s2mm_1.s'])

#
#   Edit Packager configuration
#
kernel_image_path = app_path+"/../os/petalinux/TE0950_basic_accel_petalinux/images/linux/Image"
rootfs_path = app_path+"/../os/petalinux/TE0950_basic_accel_petalinux/images/linux/rootfs.ext4"

cfg = client.get_config_file(proj.project_location+'/package/package.cfg')
cfg.set_value(section='package', key='kernel_image', value=kernel_image_path)
cfg.set_value(section='package', key='rootfs', value=rootfs_path)
cfg.set_value(section='package', key='defer_aie_run', value='true')
cfg.set_value(section='package', key='boot_mode', value='sd')

#   Build the full system and Package
proj.build(target = "hw")

vitis.dispose()
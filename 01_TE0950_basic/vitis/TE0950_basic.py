# MIT License
#
# Copyright (c) 2025 Florent Werbrouck
#

import vitis
import sys
import os

cmd_args=len(sys.argv)
args=str(sys.argv)

platform_name=sys.argv[1]
xsa=sys.argv[2]

client = vitis.create_client()
client.set_workspace(path="./workspace")

platform = client.create_platform_component(name = platform_name,hw_design = "../vivado/build/"+xsa, cpu="psv_cortexa72_0", os="standalone")
status = platform.build()

platform_path = "./workspace/"+platform_name+"/export/"+platform_name+"/"+platform_name+".xpfm"

app_comp = client.create_app_component(name="Hello_TE0950_app",platform = platform_path  ,domain = "standalone_psv_cortexa72_0")
status = app_comp.import_files(from_loc="./src", files=["helloworld_TE0950.c","lscript.ld","platform.c","platform.h"], dest_dir_in_cmp = "src")

app_comp.build()
# AMD Vivado™ Custom Configurable Example
This folder contains an example design which can be opened configured from AMD Vivado™ (open Example Design menu).
The example is based on the Versal Extensible Platform which is available in Vivado but it enables Third Party boards (only tested with Trenz TE0950)

To enable this example in Vivado, users need to add the following line to the ~/.Xilinx/Vivado/Vivado_init.tcl file:
```
set_param ced.repoPaths [list "<path_to_downloaded_repo>"]
```

For more information about this example, check out the following [Hackster.io article](https://www.hackster.io/florent-werbrouck/05-create-your-custom-configurable-example-design-in-vivado-5472f1):
https://www.hackster.io/florent-werbrouck/05-create-your-custom-configurable-example-design-in-vivado-5472f1

<p class="sphinxhide" align="center"><sub>Copyright © 2025 Florent Werbrouck</sub></p>

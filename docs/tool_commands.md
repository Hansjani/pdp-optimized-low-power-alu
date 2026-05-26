# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Hans Jani

# Tool Commands Used in This Project

This document summarizes the main Icarus Verilog, Yosys, and OpenROAD commands used by the project scripts.

## Icarus Verilog Simulation

Main script:

```bash
bash scripts/sim/run_gate_sim.sh baseline
bash scripts/sim/run_gate_sim.sh op_iso
```

Commands used:

```bash
iverilog -g2005 $DEFINE -o simv $RTL_FILES $TB_FILE
vvp simv +VCD_OUTPUT=$WAVE_FILE
```

Command descriptions:

| Command | Description |
| --- | --- |
| `iverilog` | Compiles the Verilog RTL and testbench into a simulation executable. |
| `-g2005` | Enables Verilog-2005 language support. |
| `$DEFINE` | Passes compile-time macros such as `-DBASELINE` or `-DOP_ISO` so `tb/alu_tb.v` selects the correct DUT. |
| `-o simv` | Writes the compiled simulation executable as `simv`. |
| `$RTL_FILES` | Contains common RTL plus the selected top-level design RTL. |
| `$TB_FILE` | Points to the unified testbench, `tb/alu_tb.v`. |
| `vvp simv` | Runs the compiled simulation executable. |
| `+VCD_OUTPUT=$WAVE_FILE` | Passes the waveform output path to the testbench through a plusarg. |

Generated outputs:

- `simv`
- `waves/baseline/alu_tb.vcd`
- `waves/operand_isolation/alu_tb.vcd`

These generated files are ignored by Git.

## Yosys Synthesis

Main script:

```bash
bash scripts/synth/synth_module.sh baseline alu_base_bit_sliced
bash scripts/synth/synth_module.sh operand_isolation alu_op_iso
```

Yosys command form:

```bash
yosys -p "
read_verilog $RTL_FILES
hierarchy -check -top $TOP_MODULE
proc
opt
flatten
write_verilog -noattr -norename $NETLIST_DIR/${TOP_MODULE}_sim.v
techmap
opt
dfflibmap -liberty $SKY_LIB
abc -liberty $SKY_LIB
clean
opt
delete t:\$scopeinfo
write_verilog -noattr -norename $NETLIST_DIR/${TOP_MODULE}_synth.v
stat
stat -liberty $SKY_LIB
"
```

Command descriptions:

| Command | Description |
| --- | --- |
| `yosys -p "..."` | Runs the listed Yosys synthesis commands from the shell. |
| `read_verilog $RTL_FILES` | Loads the selected RTL files into Yosys. |
| `hierarchy -check -top $TOP_MODULE` | Sets the top module and checks that required modules are available. |
| `proc` | Converts behavioral processes such as `always` blocks into lower-level netlist structures. |
| `opt` | Performs generic logic cleanup and optimization. |
| `flatten` | Flattens module hierarchy for a cleaner simulation netlist. |
| `write_verilog -noattr -norename ..._sim.v` | Writes an intermediate clean Verilog netlist for simulation. |
| `techmap` | Maps remaining generic RTL cells into lower-level technology-independent primitives before library mapping. |
| `dfflibmap -liberty $SKY_LIB` | Maps flip-flops to cells from the SKY130 liberty file. |
| `abc -liberty $SKY_LIB` | Performs technology mapping and logic optimization using the SKY130 standard-cell library. |
| `clean` | Removes unused wires, cells, and temporary objects. |
| `delete t:\$scopeinfo` | Removes Yosys scope-info debug/helper cells so OpenROAD does not see unsupported cells. |
| `write_verilog -noattr -norename ..._synth.v` | Writes the synthesized Verilog netlist. |
| `stat` | Prints generic design statistics. |
| `stat -liberty $SKY_LIB` | Prints area statistics using the SKY130 liberty file. |

Important environment variable:

```bash
export PDK_ROOT=/path/to/pdks
```

The script derives the SKY130 liberty file from:

```bash
$PDK_ROOT/sky130/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
```

Generated outputs:

- `netlist/<design_type>/`
- `reports/synthesis/<design_type>/`

These generated outputs are ignored by Git.

## OpenROAD Physical Design

Main flow:

```bash
source scripts/pd/export_variables.sh baseline
openroad scripts/pd/00_physical_design.tcl

source scripts/pd/export_variables.sh operand_isolation
openroad scripts/pd/00_physical_design.tcl
```

The top-level OpenROAD Tcl script sources the flow stages:

```tcl
source "$script_dir/01_setup.tcl"
source "$script_dir/02_floorplan.tcl"
source "$script_dir/03_pdn.tcl"
source "$script_dir/04_placement.tcl"
source "$script_dir/05_cts.tcl"
source "$script_dir/06_route.tcl"
source "$script_dir/07_report.tcl"
```

Setup commands:

| Command | Description |
| --- | --- |
| `read_lef $techlef` | Reads the SKY130 technology LEF. |
| `read_lef $stdlef` | Reads the SKY130 standard-cell LEF. |
| `read_liberty $libfile` | Reads timing and power data for the standard-cell library. |
| `read_verilog $::env(NETLIST)` | Loads the synthesized gate-level netlist. |
| `link_design $design_name` | Links the loaded netlist using the selected top module. |
| `read_sdc $::env(SDC)` | Loads timing constraints from `constraints/constraints.sdc`. |
| `read_vcd -scope ...` | Reads switching activity for power analysis when a VCD is available. |
| `report_activity_annotation` | Reports how much switching activity was applied to the design. |
| `report_design_area` | Reports design area. |
| `report_cell_usage` | Reports standard-cell usage. |
| `set_units` | Sets timing, capacitance, resistance, voltage, and current units. |

Floorplanning commands:

| Command | Description |
| --- | --- |
| `initialize_floorplan` | Creates the die/core floorplan using utilization, aspect ratio, spacing, and site settings. |
| `make_tracks` | Defines routing tracks for local interconnect and metal layers. |
| `place_pins` | Places IO pins on the selected routing layers. |
| `tapcell` | Inserts tap and endcap cells required by the SKY130 standard-cell flow. |

Power delivery commands:

| Command | Description |
| --- | --- |
| `add_global_connection` | Connects standard-cell power and ground pins to global power nets. |
| `global_connect` | Applies the global power/ground connections. |
| `define_pdn_grid` | Defines the core power-grid structure. |
| `add_pdn_ring` | Adds VDD/VSS power rings around the core. |
| `add_pdn_stripe` | Adds power stripes across the core. |
| `add_pdn_connect` | Connects PDN layers together. |
| `pdngen` | Generates the power-distribution network. |

Placement, CTS, and routing commands:

| Command | Description |
| --- | --- |
| `global_placement -routability_driven` | Performs global placement while considering routing congestion. |
| `set_placement_padding` | Adds cell spacing to improve routability. |
| `detailed_placement` | Legalizes placed cells to valid rows/sites. |
| `set_wire_rc` | Sets resistance/capacitance estimates for signal and clock wires before CTS. |
| `clock_tree_synthesis` | Builds the clock tree using SKY130 clock buffer cells. |
| `set_routing_layers` | Defines allowed routing layers for signal and clock nets. |
| `set_global_routing_layer_adjustment` | Adjusts routing capacity per layer to reduce congestion. |
| `global_route` | Performs coarse routing. |
| `detailed_route` | Performs final detailed routing. |
| `estimate_parasitics -global_routing` | Estimates parasitics from the routed design for timing/power analysis. |

Report generation commands:

| Command | Description |
| --- | --- |
| `file dirname [file normalize [info script]]` | Finds the report script location so report paths do not depend on the launch directory. |
| `file join $project_root reports` | Builds the project report directory path. |
| `file mkdir $reports_root/...` | Creates the report output directories for area, power, timing, and summary reports. |
| `current_design` | Gets the linked design name so reports are named consistently. |
| `clock format [clock seconds]` | Records a generation timestamp in each report header. |
| `open`, `puts`, `close` | Creates formatted report files and writes headers, section titles, and observation notes. |
| `tee -append -file ... { report_design_area }` | Appends post-route design area data to the area and summary reports. |
| `tee -append -file ... { report_cell_usage }` | Appends standard-cell usage data to the area report. |
| `tee -append -file ... { report_power }` | Appends power analysis data to the power and summary reports. |
| `tee -append -file ... { report_checks -path_delay max ... }` | Appends max-delay timing paths to the timing report. |
| `tee -append -file ... { report_checks -path_delay min ... }` | Appends min-delay timing paths to the timing report. |
| `report_worst_slack`, `report_wns`, `report_tns` | Appends timing summary metrics to the timing and summary reports. |
| `report_check_types` | Appends electrical and timing check status to the timing report. |

Generated report files:

- `reports/area/<design_name>_area.rpt`
- `reports/power/<design_name>_power.rpt`
- `reports/timing/<design_name>_timing.rpt`
- `reports/summary/<design_name>_summary.rpt`

Generated outputs are written under `results/` and `reports/`, which are ignored by Git.

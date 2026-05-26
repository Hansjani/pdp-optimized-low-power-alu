# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Hans Jani

# ============================================================
# 0. Environment Check
# ============================================================

if {![info exists ::env(PDK_ROOT)]} {
    puts "ERROR: PDK_ROOT not set"
    return -code error
}

if {![info exists ::env(NETLIST)]} {
    puts "ERROR: NETLIST not set"
    return -code error
}

if {![info exists ::env(DESIGN_NAME)]} {
    puts "ERROR: DESIGN_NAME not set"
    return -code error
}

if {![info exists ::env(SDC)]} {
    puts "ERROR: SDC not set"
    return -code error
}

set pdk_path "$::env(PDK_ROOT)/sky130/share/pdk/sky130A"
set design_name $::env(DESIGN_NAME)

puts "Using PDK: $pdk_path"
puts "Design: $design_name"
puts "Netlist: $::env(NETLIST)"
puts "SDC: $::env(SDC)"

# ============================================================
# 1. Libraries
# ============================================================

set techlef "$pdk_path/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef"
set stdlef  "$pdk_path/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"
set libfile "$pdk_path/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

read_lef $techlef
read_lef $stdlef
read_liberty $libfile

# ============================================================
# 2. Read Design
# ============================================================

read_verilog $::env(NETLIST)
link_design $design_name
read_sdc $::env(SDC)

# ============================================================
# 2.1 Read Switching Activity (VCD)
# ============================================================

if {[info exists ::env(RTL_VCD)]} {
    puts "Reading RTL VCD: $::env(RTL_VCD)"
    read_vcd -scope alu_tb $::env(RTL_VCD)

} elseif {[info exists ::env(VCD)]} {
    puts "Reading Gate VCD: $::env(VCD)"
    read_vcd -scope alu_tb/dut $::env(VCD)

} else {
    puts "WARNING: No VCD provided"
}

report_activity_annotation

# ============================================================
# 3. Basic Sanity Checks
# ============================================================

puts "----- DESIGN AREA -----"
report_design_area

puts "----- CELL USAGE -----"
report_cell_usage

# ============================================================
# 4. Units
# ============================================================

set_units -time ns -capacitance pF -resistance ohm -voltage V -current mA
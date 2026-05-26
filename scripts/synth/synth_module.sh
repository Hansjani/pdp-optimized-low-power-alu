#!/bin/bash

# ============================================================
# Generic SKY130 Synthesis Script
# ============================================================

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# ============================================================
# Inputs
# ============================================================

DESIGN_TYPE=$1
TOP_MODULE=$2

if [ -z "$DESIGN_TYPE" ] || [ -z "$TOP_MODULE" ]; then
    echo "Usage: ./synth_module.sh <design_type> <top_module>"
    echo "Example:"
    echo "./synth_module.sh baseline alu_base_bit_sliced"
    exit 1
fi

# ============================================================
# Paths
# ============================================================

RTL_DIR="$PROJECT_ROOT/rtl"

NETLIST_DIR="$PROJECT_ROOT/netlist/$DESIGN_TYPE"
REPORT_DIR="$PROJECT_ROOT/reports/synthesis/$DESIGN_TYPE"

mkdir -p "$NETLIST_DIR"
mkdir -p "$REPORT_DIR"

# ============================================================
# SKY130 Liberty
# ============================================================

SKY_LIB="$PDK_ROOT/sky130/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

# ============================================================
# Banner
# ============================================================

echo "================================="
echo "Design Type : $DESIGN_TYPE"
echo "Top Module  : $TOP_MODULE"
echo "================================="

# ============================================================
# RTL Selection
# ============================================================

if [ "$DESIGN_TYPE" == "baseline" ]; then

    RTL_FILES="$RTL_DIR/baseline/alu_base_bit_sliced.v $RTL_DIR/common/*.v"

elif [ "$DESIGN_TYPE" == "operand_isolation" ]; then

    RTL_FILES="$RTL_DIR/optimized/alu_op_iso.v $RTL_DIR/common/*.v"

else
    echo "ERROR: Unknown design type!"
    exit 1
fi

# ============================================================
# Run Yosys
# ============================================================

yosys -p "

# ========================================================
# 1. Read RTL
# ========================================================

read_verilog $RTL_FILES

hierarchy -check -top $TOP_MODULE

# ========================================================
# 2. RTL Elaboration
# ========================================================

proc
opt
flatten

# ========================================================
# 3. Write Clean Simulation Netlist
# ========================================================

write_verilog -noattr -norename \
    $NETLIST_DIR/${TOP_MODULE}_sim.v

# ========================================================
# 4. Technology Mapping
# ========================================================

techmap
opt

# ========================================================
# 5. Flip-Flop Mapping
# ========================================================

dfflibmap -liberty $SKY_LIB

# ========================================================
# 6. Standard Cell Mapping
# ========================================================

abc -liberty $SKY_LIB

# ========================================================
# 7. Cleanup
# ========================================================

clean
opt

# Remove debug/helper cells
delete t:\$scopeinfo

# ========================================================
# 8. Write Synthesized Netlist
# ========================================================

write_verilog -noattr -norename \
    $NETLIST_DIR/${TOP_MODULE}_synth.v

# ========================================================
# 9. Reports
# ========================================================

stat

stat -liberty $SKY_LIB

" | tee "$REPORT_DIR/${TOP_MODULE}_synthesis_report.txt"

YOSYS_STATUS=${PIPESTATUS[0]}

if [ $YOSYS_STATUS -ne 0 ]; then
    echo "================================="
    echo "SYNTHESIS FAILED"
    echo "================================="
    exit 1
fi

# ============================================================
# Done
# ============================================================

echo
echo "================================="
echo "Synthesis Completed Successfully"
echo "================================="

echo "Simulation Netlist:"
echo "$NETLIST_DIR/${TOP_MODULE}_sim.v"

echo
echo "Synthesized Netlist:"
echo "$NETLIST_DIR/${TOP_MODULE}_synth.v"

echo
echo "Report:"
echo "$REPORT_DIR/${TOP_MODULE}_synthesis_report.txt"

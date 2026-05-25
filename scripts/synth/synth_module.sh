#!/bin/bash

# ===============================
# Generic synthesis script
# ===============================

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Inputs
DESIGN_TYPE=$1     # baseline / operand_isolation
TOP_MODULE=$2      # alu_base_bit_sliced / alu_op_iso

if [ -z "$DESIGN_TYPE" ] || [ -z "$TOP_MODULE" ]; then
    echo "Usage: ./synth_module.sh <design_type> <top_module>"
    echo "Example: ./synth_module.sh baseline alu_base_bit_sliced"
    exit 1
fi

# -------------------------------
# Paths
# -------------------------------

RTL_DIR="$PROJECT_ROOT/rtl"
NETLIST_DIR="$PROJECT_ROOT/netlist/$DESIGN_TYPE"
REPORT_DIR="$PROJECT_ROOT/reports/synthesis/$DESIGN_TYPE"

mkdir -p $NETLIST_DIR
mkdir -p $REPORT_DIR

# Liberty
SKY_LIB="$PDK_ROOT/sky130/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

echo "================================="
echo "Design Type : $DESIGN_TYPE"
echo "Top Module  : $TOP_MODULE"
echo "================================="

# -------------------------------
# Select RTL based on type
# -------------------------------

if [ "$DESIGN_TYPE" == "baseline" ]; then
    RTL_FILES="$RTL_DIR/baseline/alu_base_bit_sliced.v $RTL_DIR/common/*.v"

elif [ "$DESIGN_TYPE" == "operand_isolation" ]; then
    RTL_FILES="$RTL_DIR/optimized/alu_op_iso.v $RTL_DIR/common/*.v"

else
    echo "Unknown design type!"
    exit 1
fi

# -------------------------------
# Run Yosys
# -------------------------------

yosys -p "

read_verilog $RTL_FILES

hierarchy -check -top $TOP_MODULE

# ============================
# 1. Simulation netlist (clean)
# ============================

proc
opt
flatten

write_verilog -noattr -norename $NETLIST_DIR/${TOP_MODULE}_sim.v

# ============================
# 2. Physical netlist (mapped)
# ============================

dfflibmap -liberty $SKY_LIB
abc -liberty $SKY_LIB

clean
opt

write_verilog -noattr -norename $NETLIST_DIR/${TOP_MODULE}_synth.v

stat
stat -liberty $SKY_LIB

" | tee $REPORT_DIR/${TOP_MODULE}_synthesis_report.txt

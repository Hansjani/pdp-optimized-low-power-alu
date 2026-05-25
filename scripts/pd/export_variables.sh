#!/bin/bash

# ===============================
# Argument Check
# ===============================
if [ -z "$1" ]; then
    echo "Usage: source env.sh <baseline | operand_isolation>"
    return 1 2>/dev/null || exit 1
fi

export DESIGN_TYPE=$1

# ===============================
# PDK
# ===============================
: "${PDK_ROOT:?Set PDK_ROOT to the directory containing sky130/ before sourcing this file.}"

# ===============================
# Project Root (auto-detect)
# ===============================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ===============================
# Design Selection
# ===============================

if [ "$DESIGN_TYPE" == "baseline" ]; then
    export DESIGN_NAME=alu_base_bit_sliced
    export NETLIST=$PROJECT_ROOT/netlist/baseline/alu_base_bit_sliced_synth.v

elif [ "$DESIGN_TYPE" == "operand_isolation" ]; then
    export DESIGN_NAME=alu_op_iso   # ⚠️ change this to actual module name
    export NETLIST=$PROJECT_ROOT/netlist/operand_isolation/alu_op_iso_synth.v

else
    echo "ERROR: Unknown DESIGN_TYPE ($DESIGN_TYPE)"
    return 1 2>/dev/null || exit 1
fi

# ===============================
# VCD (Switching Activity)
# ===============================

if [ "$DESIGN_TYPE" == "baseline" ]; then
    export VCD=$PROJECT_ROOT/waves/gate/baseline.vcd
    export RTL_VCD=$PROJECT_ROOT/waves/rtl/baseline.vcd

elif [ "$DESIGN_TYPE" == "operand_isolation" ]; then
    export VCD=$PROJECT_ROOT/waves/gate/op_iso.vcd
    export RTL_VCD=$PROJECT_ROOT/waves/rtl/op_iso.vcd
fi

# ===============================
# Constraints
# ===============================
export SDC=$PROJECT_ROOT/constraints/constraints.sdc

# ===============================
# Output Directories
# ===============================
export RESULTS_DIR=$PROJECT_ROOT/results/$DESIGN_TYPE
export REPORTS_DIR=$PROJECT_ROOT/reports/$DESIGN_TYPE

mkdir -p $RESULTS_DIR
mkdir -p $REPORTS_DIR

# ===============================
# Debug Info (VERY IMPORTANT)
# ===============================
echo "====================================="
echo "PD RUN CONFIG"
echo "-------------------------------------"
echo "Design Type : $DESIGN_TYPE"
echo "Design Name : $DESIGN_NAME"
echo "Netlist     : $NETLIST"
echo "SDC         : $SDC"
echo "Results Dir : $RESULTS_DIR"
echo "Reports Dir : $REPORTS_DIR"
echo "VCD         : $VCD"
echo "RTL VCD     : $RTL_VCD"
echo "====================================="

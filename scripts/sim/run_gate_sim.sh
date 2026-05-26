#!/bin/bash

# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Hans Jani

# ============================================
# SCRIPT SETUP
# ============================================

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/../.."

cd $PROJECT_ROOT || exit

# ============================================
# CONFIGURATION
# ============================================

MODE=$1   # baseline / op_iso

if [ -z "$MODE" ]; then
    echo "❌ Usage: ./run_gate_sim.sh <mode>"
    echo "Supported modes: baseline | op_iso"
    exit 1
fi

echo "Running MODE: $MODE"

# ============================================
# PATHS
# ============================================

RTL_DIR="rtl"
TB_FILE="tb/alu_tb.v"

RTL_COMMON="$RTL_DIR/common"
RTL_TOP="$RTL_DIR/top"
RTL_WRAPPERS="$RTL_DIR/wrappers"

collect_verilog() {
    if [ -d "$1" ]; then
        find "$1" -name '*.v'
    fi
}

RTL_FILES=""
RTL_FILES+=" $(collect_verilog "$RTL_COMMON")"
RTL_FILES+=" $(collect_verilog "$RTL_TOP")"
RTL_FILES+=" $(collect_verilog "$RTL_WRAPPERS")"

# ============================================
# MODE SELECTION
# ============================================

case $MODE in
    baseline)
        DEFINE="-DBASELINE"
        RTL_FILES+=" $RTL_DIR/baseline/alu_base_bit_sliced.v"
        WAVE_FILE="waves/baseline/alu_tb.vcd"
        ;;

    op_iso)
        DEFINE="-DOP_ISO"
        RTL_FILES+=" $RTL_DIR/optimized/alu_op_iso.v"
        WAVE_FILE="waves/operand_isolation/alu_tb.vcd"
        ;;

    *)
        echo "❌ Invalid MODE: $MODE"
        echo "Supported modes: baseline | op_iso"
        exit 1
        ;;
esac

# ============================================
# CLEAN PREVIOUS RUN
# ============================================

rm -f simv
rm -f "$WAVE_FILE"

# ============================================
# COMPILATION
# ============================================

echo "⚙️ Compiling..."

iverilog -g2005 $DEFINE -o simv \
    $RTL_FILES \
    $TB_FILE

if [ $? -ne 0 ]; then
    echo "❌ Compilation Failed"
    exit 1
fi

echo "✅ Compilation Successful"

# ============================================
# SIMULATION
# ============================================

echo "🚀 Running simulation..."

vvp simv +VCD_OUTPUT=$WAVE_FILE

if [ $? -ne 0 ]; then
    echo "❌ Simulation Failed"
    exit 1
fi

echo "✅ Simulation Completed"

# ============================================
# OPTIONAL: OPEN WAVEFORM
# ============================================

# if [ -f "$WAVE_FILE" ]; then
#     echo "📊 Opening waveform..."
#     gtkwave "$WAVE_FILE" &
# else
#     echo "⚠️ Waveform not found"
# fi

echo "🎉 DONE ($MODE)"

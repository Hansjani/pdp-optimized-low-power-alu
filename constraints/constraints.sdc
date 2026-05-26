# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Hans Jani

# ============================================================
# 1. Clock definition
# ============================================================

create_clock -name clk -period 25 [get_ports clk]

# ============================================================
# 2. Input delays (relative to clock)
# ============================================================

set_input_delay 1 -clock clk [all_inputs]

# Avoid applying to clock itself
set_input_delay 0.5 -clock clk [get_ports clk]

# ============================================================
# 3. Output delays
# ============================================================

set_output_delay 1 -clock clk [all_outputs]

# ============================================================
# 4. Driving strength (optional but useful)
# ============================================================

set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 [all_inputs]

# ============================================================
# 5. Load capacitance (optional)
# ============================================================

set_load 0.1 [all_outputs]
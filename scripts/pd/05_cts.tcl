# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Hans Jani

# ============================================================
# 1. Clock Tree Synthesis
# ============================================================

# IMPORTANT: Set wire RC before CTS
set_wire_rc -signal -layer met2
set_wire_rc -clock  -layer met3

clock_tree_synthesis \
    -buf_list {sky130_fd_sc_hd__clkbuf_1 sky130_fd_sc_hd__clkbuf_2 sky130_fd_sc_hd__clkbuf_4} \
    -root_buf sky130_fd_sc_hd__clkbuf_4 \
    -sink_clustering_enable

# Re-legalize after CTS
detailed_placement

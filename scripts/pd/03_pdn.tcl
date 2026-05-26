# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Hans Jani

# ============================================================
# 1. Power Connections
# ============================================================

add_global_connection -net VDD -inst_pattern .* -pin_pattern VPWR -power
add_global_connection -net VSS -inst_pattern .* -pin_pattern VGND -ground
add_global_connection -net VDD -inst_pattern .* -pin_pattern VDD -power
add_global_connection -net VSS -inst_pattern .* -pin_pattern VSS -ground

add_global_connection -net VDD -inst_pattern .* -pin_pattern VPB -power
add_global_connection -net VSS -inst_pattern .* -pin_pattern VNB -ground

global_connect

# ============================================================
# 2. PDN Grid
# ============================================================

define_pdn_grid -name core_grid -voltage_domains {CORE}

# ============================================================
# 3. Rings
# ============================================================

add_pdn_ring -grid core_grid \
    -layers {met4 met5} \
    -widths {1.6 1.6} \
    -spacings {1.6 1.6} \
    -core_offsets {4 4 4 4} \
    -nets {VDD VSS}

# ============================================================
# 4. Stripes (main grid)
# ============================================================

add_pdn_stripe -grid core_grid \
    -layer met4 \
    -width 1.6 \
    -pitch 25 \
    -nets {VDD VSS}

# ============================================================
# 5. Connections
# ============================================================

add_pdn_connect -grid core_grid -layers {met4 met5}

# ============================================================
# 6. Generate
# ============================================================

pdngen
# ============================================================
# 1. Floorplan
# ============================================================

initialize_floorplan \
    -utilization 50 \
    -aspect_ratio 1 \
    -core_space 12 \
    -site unithd

# ============================================================
# 1.1 and 1.2 not in OpenROAD flow, 
# but useful for manual floorplanning in synopsis design compiler
# ============================================================

# ============================================================
# 1.1 Create Regions (AFTER design is loaded)
# ============================================================

# create_region ARITH_REGION -rect {20 20 60 200}
# create_region LOGIC_REGION -rect {80 20 140 100}
# create_region SHIFT_REGION -rect {80 110 140 200}

# # ============================================================
# # 1.2 Add Cells to Regions (hierarchy-based)
# # ============================================================

# # Use hierarchical search to be safe
# set arith_cells [get_cells -hier *arithu*]
# set logic_cells [get_cells -hier *logicu*]
# set shift_cells [get_cells -hier *shiftu*]

# add_to_region ARITH_REGION $arith_cells
# add_to_region LOGIC_REGION $logic_cells
# add_to_region SHIFT_REGION $shift_cells

# ============================================================
# 2. Tracks
# ============================================================

make_tracks li1  -x_offset 0.23 -x_pitch 0.46 -y_offset 0.23 -y_pitch 0.46
make_tracks met1 -x_offset 0.17 -x_pitch 0.34 -y_offset 0.17 -y_pitch 0.34
make_tracks met2 -x_offset 0.23 -x_pitch 0.46 -y_offset 0.23 -y_pitch 0.46
make_tracks met3 -x_offset 0.34 -x_pitch 0.68 -y_offset 0.34 -y_pitch 0.68
make_tracks met4 -x_offset 0.46 -x_pitch 0.92 -y_offset 0.46 -y_pitch 0.92
make_tracks met5 -x_offset 1.70 -x_pitch 3.40 -y_offset 1.70 -y_pitch 3.40

# ============================================================
# 3. IO Pins
# ============================================================

place_pins \
    -hor_layers {met3} \
    -ver_layers {met2} \
    -min_distance 2.5 \
    -corner_avoidance 13.7

# ============================================================
# 4. Tapcells
# ============================================================

tapcell \
    -distance 14 \
    -tapcell_master sky130_fd_sc_hd__tapvpwrvgnd_1 \
    -endcap_master sky130_fd_sc_hd__decap_3
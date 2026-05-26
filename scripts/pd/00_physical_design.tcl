# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Hans Jani

set script_dir [file dirname [file normalize [info script]]]

source "$script_dir/01_setup.tcl"
source "$script_dir/02_floorplan.tcl"
source "$script_dir/03_pdn.tcl"
source "$script_dir/04_placement.tcl"
source "$script_dir/05_cts.tcl"
source "$script_dir/06_route.tcl"
source "$script_dir/07_report.tcl"

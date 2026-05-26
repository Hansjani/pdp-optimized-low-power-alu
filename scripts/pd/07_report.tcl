# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Hans Jani

# ============================================================
# ASIC REPORT GENERATION SCRIPT
# ============================================================
# Description:
# Generates formatted Area, Power, Timing, and Summary
# reports for OpenROAD/OpenSTA ASIC implementation flow.
#
# Compatible With:
# - OpenROAD
# - OpenSTA
# - SKY130
#
# Recommended Location:
# project/scripts/pd/07_report.tcl
#
# Output Directory:
# project/reports/
# ============================================================

# ============================================================
# CREATE REPORT DIRECTORIES
# ============================================================

set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize [file join $script_dir ../..]]
set reports_root [file join $project_root reports]

file mkdir $reports_root
file mkdir [file join $reports_root area]
file mkdir [file join $reports_root power]
file mkdir [file join $reports_root timing]
file mkdir [file join $reports_root summary]


# ============================================================
# CURRENT DESIGN
# ============================================================

set design_name [current_design]


# ============================================================
# TIMESTAMP
# ============================================================

set timestamp [clock format [clock seconds]]


# ============================================================
# HELPER PROCEDURE
# ============================================================

proc write_section_header {fp title} {

    puts $fp "\n============================================================"
    puts $fp $title
    puts $fp "============================================================\n"
}


# ============================================================
# 1. AREA REPORT
# ============================================================

set area_report [file join $reports_root area ${design_name}_area.rpt]

# ------------------------------------------------------------
# HEADER
# ------------------------------------------------------------

set fp [open $area_report "w"]

puts $fp "============================================================"
puts $fp "                     AREA REPORT"
puts $fp "============================================================"
puts $fp ""
puts $fp "Design Name    : $design_name"
puts $fp "Technology     : SKY130"
puts $fp "Flow Stage     : Post Route"
puts $fp "Generated On   : $timestamp"

close $fp


# ------------------------------------------------------------
# DESIGN AREA
# ------------------------------------------------------------

set fp [open $area_report "a"]

write_section_header $fp "1. DESIGN AREA"

close $fp

tee -append -file $area_report {
    report_design_area
}


# ------------------------------------------------------------
# CELL USAGE
# ------------------------------------------------------------

set fp [open $area_report "a"]

write_section_header $fp "2. CELL USAGE"

close $fp

tee -append -file $area_report {
    report_cell_usage
}


# ------------------------------------------------------------
# OBSERVATIONS
# ------------------------------------------------------------

set fp [open $area_report "a"]

write_section_header $fp "3. OBSERVATIONS"

puts $fp "- Review utilization for congestion risk"
puts $fp "- Compare area across ALU architectures"
puts $fp "- Analyze combinational vs sequential area contribution"

close $fp

puts "Generated : $area_report"



# ============================================================
# 2. POWER REPORT
# ============================================================

set power_report [file join $reports_root power ${design_name}_power.rpt]

# ------------------------------------------------------------
# HEADER
# ------------------------------------------------------------

set fp [open $power_report "w"]

puts $fp "============================================================"
puts $fp "                     POWER REPORT"
puts $fp "============================================================"
puts $fp ""
puts $fp "Design Name    : $design_name"
puts $fp "Technology     : SKY130"
puts $fp "Flow Stage     : Post Route"
puts $fp "Generated On   : $timestamp"

close $fp


# ------------------------------------------------------------
# POWER ANALYSIS
# ------------------------------------------------------------

set fp [open $power_report "a"]

write_section_header $fp "1. POWER ANALYSIS"

close $fp

tee -append -file $power_report {
    report_power
}


# ------------------------------------------------------------
# OBSERVATIONS
# ------------------------------------------------------------

set fp [open $power_report "a"]

write_section_header $fp "2. OBSERVATIONS"

puts $fp "- Compare switching activity across architectures"
puts $fp "- Analyze leakage and dynamic power"
puts $fp "- Operand isolation and clock gating reduce switching power"

close $fp

puts "Generated : $power_report"



# ============================================================
# 3. TIMING REPORT
# ============================================================

set timing_report [file join $reports_root timing ${design_name}_timing.rpt]

# ------------------------------------------------------------
# HEADER
# ------------------------------------------------------------

set fp [open $timing_report "w"]

puts $fp "============================================================"
puts $fp "                    TIMING REPORT"
puts $fp "============================================================"
puts $fp ""
puts $fp "Design Name    : $design_name"
puts $fp "Technology     : SKY130"
puts $fp "Flow Stage     : Post Route"
puts $fp "Generated On   : $timestamp"

close $fp


# ------------------------------------------------------------
# MAX DELAY PATH
# ------------------------------------------------------------

set fp [open $timing_report "a"]

write_section_header $fp "1. MAX DELAY PATH"

close $fp

tee -append -file $timing_report {

    report_checks \
        -path_delay max \
        -fields {slew cap input_pins fanout} \
        -digits 4
}


# ------------------------------------------------------------
# MIN DELAY PATH
# ------------------------------------------------------------

set fp [open $timing_report "a"]

write_section_header $fp "2. MIN DELAY PATH"

close $fp

tee -append -file $timing_report {

    report_checks \
        -path_delay min \
        -fields {slew cap input_pins fanout} \
        -digits 4
}


# ------------------------------------------------------------
# TIMING SUMMARY
# ------------------------------------------------------------

set fp [open $timing_report "a"]

write_section_header $fp "3. TIMING SUMMARY"

close $fp

tee -append -file $timing_report {

    report_worst_slack
    report_wns
    report_tns
}


# ------------------------------------------------------------
# ELECTRICAL CHECKS
# ------------------------------------------------------------

set fp [open $timing_report "a"]

write_section_header $fp "4. ELECTRICAL CHECKS"

close $fp

tee -append -file $timing_report {

    report_check_types
}


# ------------------------------------------------------------
# OBSERVATIONS
# ------------------------------------------------------------

set fp [open $timing_report "a"]

write_section_header $fp "5. OBSERVATIONS"

puts $fp "- Review critical path depth"
puts $fp "- Analyze setup and hold timing margins"
puts $fp "- Check slew and capacitance violations"
puts $fp "- Ripple carry chains typically dominate ALU timing"

close $fp

puts "Generated : $timing_report"



# ============================================================
# 4. SUMMARY REPORT
# ============================================================

set summary_report [file join $reports_root summary ${design_name}_summary.rpt]

# ------------------------------------------------------------
# HEADER
# ------------------------------------------------------------

set fp [open $summary_report "w"]

puts $fp "============================================================"
puts $fp "                ASIC FLOW SUMMARY REPORT"
puts $fp "============================================================"
puts $fp ""
puts $fp "Design Name    : $design_name"
puts $fp "Technology     : SKY130"
puts $fp "Flow Stage     : Post Route"
puts $fp "Generated On   : $timestamp"

close $fp


# ------------------------------------------------------------
# IMPLEMENTATION SUMMARY
# ------------------------------------------------------------

set fp [open $summary_report "a"]

write_section_header $fp "1. IMPLEMENTATION SUMMARY"

close $fp

# ------------------------------------------------------------
# IMPLEMENTATION SUMMARY DATA
# ------------------------------------------------------------

tee -append -file $summary_report {
    report_design_area
}

tee -append -file $summary_report {
    report_worst_slack
}

tee -append -file $summary_report {
    report_wns
}

tee -append -file $summary_report {
    report_tns
}

tee -append -file $summary_report {
    report_power
}

puts "Generated : $summary_report"



# ============================================================
# FLOW COMPLETE
# ============================================================

puts "\n============================================================"
puts "All reports generated successfully."
puts "============================================================"

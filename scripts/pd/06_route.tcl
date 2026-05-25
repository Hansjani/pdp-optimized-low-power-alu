# ============================================================
# 10. Routing (26Q1 Correct)
# ============================================================

set_routing_layers -signal met1-met5 -clock met2-met5

set_global_routing_layer_adjustment met1 0.9
set_global_routing_layer_adjustment met2 0.7
set_global_routing_layer_adjustment met3 0.45
set_global_routing_layer_adjustment met4 0.2

global_route
detailed_route

estimate_parasitics -global_routing 
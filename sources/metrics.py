Summary = {
    "flow__errors__count": "Flow errors",
    "flow__warnings__count": "Flow warnings",
    "synthesis__check_error__count": "Synthesis errors",
    "design__lint_error__count": "Lint errors",
    "design__lint_warning__count": "Lint warnings",
    "design__inferred_latch__count": "Inferred latches",
    "design__instance_unmapped__count": "Unmapped instances",

    "timing__setup__ws": "Worst setup slack",
    "timing__hold__ws": "Worst hold slack",
    "timing__setup_vio__count": "Setup violations",
    "timing__hold_vio__count": "Hold violations",

    "design__instance__count": "Instance count",
    "design__instance__area": "Instance area",
    "design__die__area": "Die area",
    "design__core__area": "Core area",
    "design__instance__utilization": "Core utilization",

    "route__wirelength": "Total routed wire length",
    "route__vias": "Via count",
    "route__drc_errors": "Routing DRC errors",
    "route__antenna_violation__count": "Antenna violations",
    "design__max_slew_violation__count": "Maximum slew violations",
    "design__max_fanout_violation__count": "Maximum fanout violations",
    "design__max_cap_violation__count": "Maximum capacitance violations",

    "power__total": "Total power",
    "design_powergrid__drop__worst__net:VPWR": "Worst VPWR drop",
    "design_powergrid__drop__worst__net:VGND": "Worst VGND rise",

    "klayout__drc_error__count": "KLayout DRC errors",
    "design__lvs_error__count": "LVS errors"
}

Warnings = [
    "design__lint_error__count",
    "design__lint_warning__count",
    "design__lint_timing_construct__count",
    "design__inferred_latch__count",
    "design__instance_unmapped__count",
    "flow__errors__count",
    "flow__warnings__count",
    "design__power_grid_violation__count",
    "antenna__violating__nets",
    "route__drc_errors",
    "design__disconnected_pin__count",
    "design__critical_disconnected_pin__count",
    "design__xor_difference__count",
    "magic__drc_error__count",
    "magic__illegal_overlap__count",
    "klayout__drc_error__count",
    "design__lvs_error__count",
    "synthesis__check_error__count"

]

Timing = [
    "clock__skew__worst_hold",
    "clock__skew__worst_setup",
    "timing__hold__ws",
    "timing__setup__ws",
    "timing__hold__tns",
    "timing__setup__tns",
    "timing__hold__wns",
    "timing__setup__wns",
    "timing__hold_vio__count",
    "timing__hold_r2r__ws",
    "timing__hold_r2r_vio__count",
    "timing__setup_vio__count",
    "timing__setup_r2r__ws",
    "timing__setup_r2r_vio__count"
]

Area_Utilization = [
    "design__instance__count",
    "design__instance__area",
    "design__io",
    "design__die__area",
    "design__core__area",
    "design__instance__count__stdcell",
    "design__instance__area__stdcell",
    "design__instance__count__macros",
    "design__instance__area__macros",
    "design__instance__utilization",
    "design__instance__count__class:inverter",
    "design__instance__count__class:sequential_cell",
    "design__instance__count__class:multi_input_combinational_cell",
    "design__instance__count__class:timing_repair_buffer",
    "design__instance__count__hold_buffer",
    "design__instance__count__class:clock_buffer"
]

Routing = [
    "design__max_slew_violation__count",
    "design__max_fanout_violation__count",
    "design__max_cap_violation__count",
    "route__antenna_violation__count",
    "route__net",
    "route__drc_errors",
    "route__wirelength",
    "route__vias",
    "route__wirelength__max"
]

Power = [
    "power__internal__total",
    "power__switching__total",
    "power__leakage__total",
    "power__total",
    "design__power_grid_violation__count__net:VGND",
    "design__power_grid_violation__count__net:VPWR",
    "design_powergrid__voltage__worst__net:VPWR",
    "design_powergrid__drop__worst__net:VPWR",
    "design_powergrid__voltage__worst__net:VGND",
    "design_powergrid__drop__worst__net:VGND",
    "design_powergrid__drop__worst"
]

metric_categories = {
    "Warnings": Warnings,
    "Timing": Timing,
    "Area and Utilization": Area_Utilization,
    "Routing": Routing,
    "Power": Power
}
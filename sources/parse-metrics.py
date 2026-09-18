import csv
from pathlib import Path
from datetime import datetime

# csv_path = r"D:\School\SDP\asic-projects\RUN_2026-09-17_13-16-36\metrics.csv"
csv_path = input("Metrics Path: ").strip("\"'").replace("\\", "/")

input_path = Path(csv_path)
timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
output_path = input_path.parent / f"parsed-metrics-{timestamp}.csv"

export_choice = input("\nExport results to CSV?\n").strip().lower()



General = [
    "design__lint_error__count",
    "design__lint_warning__count",
    "design__inferred_latch__count",
    "design__instance_unmapped__count",
    "flow__errors__count",
    "design__power_grid_violation__count",
    "antenna__violating__nets",
    "route__drc_errors",
    "design__disconnected_pin__count",
    "design__xor_difference__count",
    "magic__drc_error__count",
    "klayout__drc_error__count",
    "design__lvs_error__count"
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
    "floorplan__design__io"
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
    "design_powergrid__drop__worst__net:VGND"
]

metric_categories = {
    "General": General,
    "Timing": Timing,
    "Area and Utilization": Area_Utilization,
    "Routing": Routing,
    "Power": Power
}

metrics = {}

with open(csv_path, "r", newline="", encoding="utf-8") as csv_file:
    reader = csv.DictReader(csv_file)


    for row in reader:
        metric_name = row["Metric"].strip()
        metric_value = row["Value"].strip()

        metrics[metric_name] = metric_value

if export_choice in ["y", "yes"]:
    with open(output_path, "w", newline="", encoding="utf-8") as output_file:
        writer = csv.writer(output_file)

        writer.writerow(["Category", "Metric", "Value"])

        for category_name, category_metrics in metric_categories.items():
            for metric_name in category_metrics:
                metric_value = metrics.get(metric_name, "N/A")

                writer.writerow([
                    category_name,
                    metric_name,
                    metric_value
                ])

    print(f"Results exported to: {output_path}") 
else:
    for category_name, category_metrics in metric_categories.items():
        print(f"\n{category_name}")
        print("-" * len(category_name))

        for metric_name in category_metrics:
            metric_value = metrics.get(metric_name, "N/A")
            print(f"{metric_name}: {metric_value}")
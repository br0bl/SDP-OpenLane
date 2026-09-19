import csv
from metrics import metric_categories
from metrics import Summary
from pathlib import Path
from datetime import datetime

print("-" * 64) 

def yes_no(prompt):
    while True:
        choice = input(prompt).strip().lower()
        if choice in ["y", "n"]:
            return choice
        print("Error: enter y or n")

multiple_choice = yes_no("\nParse multiple runs? (y/n)\n> ")

if multiple_choice == "y":
    runs_path = Path(
        input("\nRuns directory: ").strip("\"'").replace("\\", "/")
    )
    csv_paths = sorted(runs_path.rglob("metrics*.csv"))
    output_directory = runs_path
else:
    csv_path = Path(
    r"D:\School\SDP\asic-projects\pm32-example\RUN_2026-09-17_19-08-09\metrics (10ms t_clk).csv"
    # input("Metrics Path: ").strip("\"'").replace("\\", "/")
)
    csv_paths = [csv_path]
    output_directory = csv_path.parent

timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
output_path = output_directory / f"parsed-metrics-{timestamp}.csv"

if multiple_choice != "y":
    detail_choice = yes_no("\nSummarize report? (y/n)\n> ")

export_choice = yes_no("\nExport results to CSV? (y/n)\n> ")

all_runs = {}

for csv_path in csv_paths:
    metric_values = {}

    with open(csv_path, "r", newline="", encoding="utf-8") as csv_file:
        reader = csv.DictReader(csv_file)

        for row in reader:
            metric_name = row["Metric"].strip()
            metric_value = row["Value"].strip()
            metric_values[metric_name] = metric_value

        run_name = csv_path.parent.name
        all_runs[run_name] = metric_values

if export_choice == "y":
    with open(output_path, "w", newline="", encoding="utf-8") as output_file:
        writer = csv.writer(output_file)

        if multiple_choice == "y":
            run_names = list(all_runs.keys())

            writer.writerow(["Metric", *run_names])

            for metric_full, metric_name in Summary.items():
                output_row = [metric_name]

                for run_name in run_names:
                    metric_value = all_runs[run_name].get(metric_full, "N/A")
                    output_row.append(metric_value)

                writer.writerow(output_row)
        else:
            if detail_choice == "y":
                writer.writerow(["Metric", "Value"])

                for metric_full, metric_name in Summary.items():
                    metric_value = metric_values.get(metric_full, "N/A")

                    writer.writerow([
                        metric_name,
                        metric_value
                    ])
                
            else:
                writer.writerow(["Category", "Metric", "Value"])

                for category_name, category_metrics in metric_categories.items():
                    for metric_name in category_metrics:
                        metric_value = metric_values.get(metric_name, "N/A")

                        writer.writerow([
                            category_name,
                            metric_name,
                            metric_value
                        ])

    print(f"Results exported to: {output_path}") 

else:
    if multiple_choice == "y":
        for run_name, run_metrics in all_runs.items():
            print(f"\n{run_name}")
            print("-" * 64)

            for metric_full, metric_name in Summary.items():
                metric_value = run_metrics.get(metric_full, "N/A")
                print(f"{metric_name}: {metric_value}")

    else:
        if detail_choice == "y":
            print("-" * 64)
            for metric_full, metric_name in Summary.items():
                metric_value = metric_values.get(metric_full, "N/A")
                print(f"{metric_name}: {metric_value}")     

            print("-" * 64)    
        else:
            for category_name, category_metrics in metric_categories.items():
                print(f"\n{category_name}")
                print("-" * 64)

                for metric_name in category_metrics:
                    metric_value = metric_values.get(metric_name, "N/A")
                    print(f"{metric_name}: {metric_value}")

            print("-" * 64)
import csv
from metrics import metric_categories
from metrics import Summary
from pathlib import Path
from datetime import datetime

def yes_no(prompt):
    while True:
        choice = input(prompt).strip().lower()
        if choice in ["y", "n"]:
            return choice
        print("Error: enter y or n")

def select_csv_paths():
    multiple_runs_choice = yes_no("Parse multiple runs? (y/n)\n> ")

    if multiple_runs_choice == "y":
        runs_path = Path(input("Runs directory: ").strip(" \t\r\n\"'"))
        csv_paths = sorted(runs_path.rglob("metrics*.csv"))
        output_directory = runs_path.parent
    else:
        csv_path = Path(input("Metrics Path: ").strip(" \t\r\n\"'"))
        csv_paths = [csv_path]
        output_directory = csv_path.parent

    if not csv_paths:
        raise FileNotFoundError("No metrics CSV files found.")
    
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    output_path = output_directory / f"parsed-metrics-{timestamp}.csv"

    return csv_paths, output_path

def read_metrics(csv_paths):
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

    return all_runs

def export_summary(output_path, all_runs):
    with open(output_path, "w", newline="", encoding="utf-8") as output_file:
        writer = csv.writer(output_file)

        run_names = list(all_runs.keys())
        writer.writerow(["Metric", *run_names])

        for metric_full, metric_name in Summary.items():
            output_row = [metric_name]

            for run_name in run_names:
                metric_value = all_runs[run_name].get(metric_full, "N/A")
                output_row.append(metric_value)

            writer.writerow(output_row)

    print(f"Results exported to: {output_path}")                     

def export_detailed(output_path, all_runs):
    with open(output_path, "w", newline="", encoding="utf-8") as output_file:
        writer = csv.writer(output_file)

        run_names = list(all_runs.keys())
        writer.writerow(["Category", "Metric", *run_names])

        for category_name, category_metrics in metric_categories.items():
            for metric_name in category_metrics:
                output_row = [category_name, metric_name]

                for run_name in run_names:
                    metric_value = all_runs[run_name].get(metric_name, "N/A")
                    output_row.append(metric_value)

                writer.writerow(output_row)

    print(f"Results exported to: {output_path}") 

def print_summary(all_runs):
    for run_name, metric_values in all_runs.items():
        print(f"\n{run_name}")
        print("-" * 64)

        for metric_full, metric_name in Summary.items():
            metric_value = metric_values.get(metric_full, "N/A")
            print(f"{metric_name}: {metric_value}")

        print("-" * 64)    

def print_detailed(all_runs):
    for run_name, metric_values in all_runs.items():
        print(f"\n{run_name}")
        print("-" * 64)     

        for category_name, category_metrics in metric_categories.items():
            print(f"\n{category_name}")

            for metric_name in category_metrics:
                metric_value = metric_values.get(metric_name, "N/A")
                print(f"{metric_name}: {metric_value}")

        print("-" * 64)

    print("-" * 64)

def main():
    print("-" * 64)
    csv_paths, output_path = select_csv_paths()
    all_runs = read_metrics(csv_paths)

    export_choice = yes_no("Export results to CSV? (y/n)\n> ")
    summary_choice = yes_no("Summarize report? (y/n)\n> ")

    if export_choice == "y":
        if summary_choice == "y":
            export_summary(output_path, all_runs)
        else:
            export_detailed(output_path, all_runs)
    else:
        if summary_choice == "y":
            print_summary(all_runs)
        else:
            print_detailed(all_runs)
    return

if __name__ == "__main__":
    main()
from datetime import datetime
from openlane.flows import Flow, FlowError
from config_ui import get_sweep_config


SWEEP_ID = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
Classic = Flow.factory.get("Classic")


def format_value(value):
    return f"{value:.6f}".rstrip("0").rstrip(".").replace(".", "p")


def safe_variable_name(variable):
    return "".join(
        character.lower() if character.isalnum() else "_"
        for character in variable
    ).strip("_")


def run_period(config_path, variable, period):
    variable_tag = safe_variable_name(variable)
    value_tag = format_value(period)
    run_tag = f"{SWEEP_ID}_{variable_tag}_{value_tag}"

    print(f"\nRunning {variable}={period:g}")

    flow = Classic(
        str(config_path),
        config_override_strings=[f"{variable}={period:g}"],
    )

    try:
        final_state = flow.start(tag=run_tag)
    except FlowError as error:
        print(f"Failed: {run_tag}")
        print(error)
        return False

    setup_violations = final_state.metrics.get(
        "timing__setup_vio__count"
    )

    if setup_violations is None:
        raise RuntimeError(
            f"{run_tag} did not produce timing__setup_vio__count."
        )

    if setup_violations == 0:
        print(f"Passed: {run_tag}")
        return True

    print(f"Failed timing: {setup_violations} setup violation(s)")
    return False


def main():
    config = get_sweep_config()

    if config is None:
        raise SystemExit("Sweep cancelled.")

    print("Checking upper boundary...")

    if not run_period(
        config.config_path,
        config.variable,
        config.upper_bound,
    ):
        raise RuntimeError(
            f"The upper boundary of {config.upper_bound:g} failed. "
            "Increase UPPER_BOUND before searching."
        )

    print("\nChecking lower boundary...")

    if run_period(
        config.config_path,
        config.variable,
        config.lower_bound,
    ):
        print(
            f"\n{config.variable}={config.lower_bound:g} passes. "
            "The boundary is at or below the configured lower bound."
        )
        return

    failing_value = config.lower_bound
    passing_value = config.upper_bound

    while passing_value - failing_value > config.search_resolution:
        test_value = (failing_value + passing_value) / 2

        if run_period(config.config_path, config.variable, test_value):
            passing_value = test_value
        else:
            failing_value = test_value

    print("\nSearch complete.")
    print(f"Highest known failing value: {failing_value:g}")
    print(f"Lowest known passing value: {passing_value:g}")
    print(
        "Boundary located within "
        f"{passing_value - failing_value:g}"
    )

if __name__ == "__main__":
    main()

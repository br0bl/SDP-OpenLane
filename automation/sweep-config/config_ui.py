import curses
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class SweepConfig:
    config_path: Path
    variable: str
    lower_bound: float
    upper_bound: float
    search_resolution: float


FIELDS = [
    "CONFIG_PATH",
    # "VARIABLE",
    "LOWER_BOUND",
    "UPPER_BOUND",
    "SEARCH_RESOLUTION",
]

DEFAULTS = {
    "CONFIG_PATH": "./sources/config.json",
    "VARIABLE": "CLOCK_PERIOD",
    "LOWER_BOUND": "10",
    "UPPER_BOUND": "100",
    "SEARCH_RESOLUTION": "0.5",
}


def _parse_config(values):
    if not values["CONFIG_PATH"].strip():
        raise ValueError("CONFIG_PATH cannot be empty.")

    if not values["VARIABLE"].strip():
        raise ValueError("VARIABLE cannot be empty.")

    try:
        lower_bound = float(values["LOWER_BOUND"])
        upper_bound = float(values["UPPER_BOUND"])
        search_resolution = float(values["SEARCH_RESOLUTION"])
    except ValueError as error:
        raise ValueError("Bounds and resolution must be numbers.") from error

    if upper_bound <= lower_bound:
        raise ValueError("UPPER_BOUND must be greater than LOWER_BOUND.")

    if search_resolution <= 0:
        raise ValueError("SEARCH_RESOLUTION must be greater than zero.")

    return SweepConfig(
        config_path=Path(values["CONFIG_PATH"]).expanduser().resolve(),
        variable="CLOCK_PERIOD",                       
        lower_bound=lower_bound,
        upper_bound=upper_bound,
        search_resolution=search_resolution,
    )


def _configuration_screen(screen):
    values = DEFAULTS.copy()
    selected = 0
    error_message = ""

    curses.curs_set(0)
    curses.noecho()
    screen.keypad(True)

    while True:
        screen.clear()
        screen.border()

        screen.addstr(1, 3, "config-sweep-config")
        screen.addstr(2, 3, "-" * 50)

        screen.addstr(                                      # WIP: Non variable variable :O
            4,
            3,
            f"{'VARIABLE':<20} = CLOCK_PERIOD",
            curses.A_DIM,
        )

        for index, field in enumerate(FIELDS):
            row = index + 5                                 # change to 4 to include variable
            line = f"{field:<20} = {values[field]}"
            style = curses.A_REVERSE if index == selected else curses.A_NORMAL
            screen.addnstr(row, 3, line, 70, style)

        instruction_row = len(FIELDS) + 6
        screen.addstr(
            instruction_row,
            3,
            "Up/Down: select   Enter: edit   S: start   Q: quit",
        )

        if error_message:
            screen.addnstr(
                instruction_row + 2,
                3,
                f"Error: {error_message}",
                70,
                curses.A_BOLD,
            )

        screen.refresh()
        key = screen.getch()

        if key in (curses.KEY_UP, ord("k")):
            selected = (selected - 1) % len(FIELDS)

        elif key in (curses.KEY_DOWN, ord("j"), 9):
            selected = (selected + 1) % len(FIELDS)

        elif key in (curses.KEY_ENTER, 10, 13):
            field = FIELDS[selected]
            row = selected + 5                              # change to 5 to include variable
            prompt = f"{field:<20} = "

            screen.move(row, 3)
            screen.clrtoeol()
            screen.addstr(row, 3, prompt)

            curses.echo()
            curses.curs_set(1)
            new_value = screen.getstr(
                row,
                3 + len(prompt),
                200,
            ).decode().strip()
            curses.noecho()
            curses.curs_set(0)

            if new_value:
                values[field] = new_value
                error_message = ""

        elif key in (ord("s"), ord("S")):
            try:
                return _parse_config(values)
            except ValueError as error:
                error_message = str(error)

        elif key in (ord("q"), ord("Q")):
            return None


def get_sweep_config():
    return curses.wrapper(_configuration_screen)


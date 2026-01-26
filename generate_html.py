import sys
import json
from jinja2 import Environment, FileSystemLoader

def main():
    try:
        # Read from stdin if available, otherwise check if a file path is provided as argument
        if not sys.stdin.isatty():
             data = json.load(sys.stdin)
        else:
             # Fallback for testing or empty run
             data = {}
    except json.JSONDecodeError:
        print("Error: Invalid JSON input", file=sys.stderr)
        sys.exit(1)

    # Define groups and their matching patterns
    groups = {
        "Rancher": ["RANCHER"],
        "Longhorn": ["LONGHORN"],
        "NeuVector": ["NEUVECTOR"],
        "Elemental": ["ELEMENTAL"],
        "K3s": ["K3S"],
        "RKE2": ["RKE2"],
        "Turtles": ["TURTLES"],
        "SLE Micro": ["SLMICRO"],
        "Components": [] # Fallback
    }

    grouped_data = {key: {} for key in groups}

    for key, value in data.items():
        matched = False
        for group_name, prefixes in groups.items():
            if group_name == "Components":
                continue
            for prefix in prefixes:
                if key.startswith(prefix):
                    grouped_data[group_name][key] = value
                    matched = True
                    break
            if matched:
                break

        if not matched:
            grouped_data["Components"][key] = value

    # Order groups: explicitly defined order
    group_order = ["Rancher", "SLE Micro", "K3s", "RKE2", "Longhorn", "NeuVector", "Elemental", "Turtles", "Components"]

    # Initialize Jinja2 environment
    env = Environment(loader=FileSystemLoader('.'))
    template = env.get_template('template.html')

    # Render template
    html_output = template.render(grouped_data=grouped_data, group_order=group_order)

    print(html_output)

if __name__ == "__main__":
    main()

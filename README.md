# SUSE Edge Latest Versions

This project generates a report of the latest versions for various SUSE Edge components. It fetches data from multiple sources (GitHub releases, Helm charts, etc.) and presents it in a user-friendly HTML table.

## Overview

The system consists of two main parts:
1.  **Data Collection**: A Bash script (`suse-edge-latest-versions.sh`) that queries various APIs and registries to retrieve version information.
2.  **Report Generation**: A Python script (`generate_html.py`) that takes the JSON output from the data collection step and renders a styled HTML report using a Jinja2 template.

## Prerequisites

To run the scripts locally, you need the following tools installed:

*   **Bash**: For running the data collection script.
*   **Python 3**: For generating the HTML report.
*   **jq**: For parsing JSON data in the bash script.
*   **curl**: For making HTTP requests.
*   **helm**: For checking Helm chart versions.
*   **yq**: For parsing YAML files.
*   **crane**: For inspecting OCI registries.

## Python Dependencies

The Python script requires the `jinja2` library. You can install it using pip:

```bash
pip install jinja2
```

## Usage

To generate the report, verify you have all prerequisites installed and run the main generation script:

```bash
./generate-html-table.sh
```

This will produce two files:
*   `output.json`: The raw data in JSON format.
*   `output.html`: The generated HTML report.

## GitHub Actions

This repository includes a GitHub Action workflow (`.github/workflows/generate-html-table.yml`) that automatically runs the scripts on a schedule and publishes the results to GitHub Pages.

#!/usr/bin/env bash
set -euo pipefail

output_file="output.html"

# Example JSON output
json_output=$(./suse-edge-latest-versions.sh)

# Convert JSON to an HTML table
html_output="<table border='1' style='border-collapse: collapse;'>"
html_output+="<thead><tr><th>Variable Name</th><th>Value</th></tr></thead>"
html_output+="<tbody>"

# Parse JSON and append table rows
while read -r row; do
  html_output+="$row"
done < <(echo "$json_output" | jq -r '
  to_entries[] | 
  "<tr><td>\(.key)</td><td>\(.value | gsub("\n"; "<br>"))</td></tr>"
')

html_output+="</tbody></table>"

# Save the HTML output
echo "$html_output" > "$output_file"
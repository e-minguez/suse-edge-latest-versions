#!/usr/bin/env bash
set -euo pipefail

output_file="output.html"

# Generate JSON
echo "Generating JSON..."
./suse-edge-latest-versions.sh > output.json

# Convert JSON to HTML using Python script
echo "Generating HTML..."
python3 generate_html.py < output.json > "$output_file"

echo "Done. Saved to $output_file"

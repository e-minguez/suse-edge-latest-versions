#!/usr/bin/env bash
set -euo pipefail

# Get a list of all variables before defining any local ones
initial_vars=$(compgen -v)

RKE2_GITHUB_RELEASE_LATEST=$(curl --silent "https://api.github.com/repos/rancher/rke2/releases/latest" | jq -r .tag_name)
K3S_GITHUB_RELEASE_LATEST=$(curl --silent "https://api.github.com/repos/k3s-io/k3s/releases/latest" | jq -r .tag_name)

RANCHER_PRIME_HELM_REPO_YAML=$(curl -s https://charts.rancher.com/server-charts/prime/index.yaml)

RANCHER_GITHUB_RELEASE_LATEST=$(curl --silent "https://api.github.com/repos/rancher/rancher/releases/latest" | jq -r .tag_name)

RANCHER_PRIME_HELM_REPO_LATEST=$(echo "${RANCHER_PRIME_HELM_REPO_YAML}" | yq '.entries.rancher[0].appVersion')
KUBE_VERSION_REQUIRED_RANCHER_PRIME=$(echo "${RANCHER_PRIME_HELM_REPO_YAML}" | yq '.entries.rancher[0].kubeVersion')
RANCHER_PRIME_IMAGES=$(curl -s https://prime.ribs.rancher.io/rancher/"${RANCHER_PRIME_HELM_REPO_LATEST}"/rancher-images.txt)

RANCHER_CHARTS_INDEX=$(curl -s http://charts.rancher.io/index.yaml)

# LONGHORN
LONGHORN_GITHUB_RELEASE_LATEST=$(curl --silent "https://api.github.com/repos/longhorn/longhorn/releases/latest" | jq -r .tag_name)
LONGHORN_HELM_REPO_YAML=$(curl -s https://charts.longhorn.io/index.yaml)
LONGHORN_HELM_REPO_LATEST=$(echo "${LONGHORN_HELM_REPO_YAML}" | yq '.entries.longhorn[0].appVersion')
KUBE_VERSION_REQUIRED_LONGHORN=$(echo "${LONGHORN_HELM_REPO_YAML}" | yq '.entries.longhorn[0].kubeVersion')
LONGHORN_GITHUB_RELEASE_LATEST_IMAGES=$(curl -L -s https://github.com/longhorn/longhorn/releases/download/"${LONGHORN_HELM_REPO_LATEST}"/longhorn-images.txt)
LONGHORN_GITHUB_RELEASE_LATEST_IMAGES=$(helm template http://charts.rancher.io/$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.longhorn[0].urls[0]') | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)
# LONGHORN FROM RANCHER VIEW
LONGHORN_RANCHER_REPO_APPVERSION_LATEST=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.longhorn[0].appVersion')
LONGHORN_RANCHER_REPO_CHARTVERSION_LATEST=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.longhorn[0].version')

# NMCONFIGURATOR
NM_GITHUB_RELEASE_LATEST=$(curl --silent "https://api.github.com/repos/suse-edge/nm-configurator/releases/latest" | jq -r .tag_name)

# NEUVECTOR
NEUVECTOR_GITHUB_RELEASE_LATEST=$(curl --silent "https://api.github.com/repos/neuvector/neuvector/releases/latest" | jq -r .tag_name)
NEUVECTOR_HELM_REPO_YAML=$(curl -s https://neuvector.github.io/neuvector-helm/index.yaml)
NEUVECTOR_HELM_REPO_LATEST=$(echo "${NEUVECTOR_HELM_REPO_YAML}" | yq '.entries.core[0].appVersion')
# https://open-docs.neuvector.com/deploying/airgap
NEUVECTOR_IMAGES=$(helm template http://charts.rancher.io/$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.neuvector[0].urls[0]') | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)
# NEUVECTOR FROM RANCHER VIEW
NEUVECTOR_RANCHER_REPO_APPVERSION_LATEST=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.neuvector[0].appVersion')
NEUVECTOR_RANCHER_REPO_CHARTVERSION_LATEST=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.neuvector[0].version')

# RANCHER TURTLES
TURTLES_CHARTS_INDEX=$(curl -s https://rancher.github.io/turtles/index.yaml)
TURTLES_GITHUB_RELEASE_LATEST=$(curl --silent "https://api.github.com/repos/rancher/turtles/releases/latest" | jq -r .tag_name)
TURTLES_IMAGES=$(helm template $(echo "${TURTLES_CHARTS_INDEX}" | yq '.entries.rancher-turtles[0].urls[0]') | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)

# ELEMENTAL
ELEMENTAL_GITHUB_RELEASE_LATEST=$(curl --silent "https://api.github.com/repos/rancher/elemental/releases/latest" | jq -r .tag_name)
ELEMENTAL_HELM_IMAGE_LATEST=$(crane ls registry.suse.com/rancher/elemental-operator-chart -O | grep -v latest | tail -n1)
ELEMENTAL_CRD_HELM_IMAGE_LATEST=$(crane ls registry.suse.com/rancher/elemental-operator-crds-chart -O | grep -v latest | tail -n1)
ELEMENTAL_IMAGES=$(helm template http://charts.rancher.io/$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.elemental[0].urls[0]') | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)
# ELEMENTAL FROM RANCHER VIEW
ELEMENTAL_RANCHER_REPO_APPVERSION_LATEST=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.elemental[0].appVersion')
ELEMENTAL_RANCHER_REPO_CHARTVERSION_LATEST=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.elemental[0].version')
ELEMENTAL_CRD_IMAGES=$(helm template http://charts.rancher.io/$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.elemental-crd[0].urls[0]') | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)

SLMICRO_LATEST=$(curl -s https://www.suse.com/download/sle-micro/ | sed -n 's/.*<span class="sort_button" data-target="version_.-.">\([^<]*\)<.*/\1/p' | head -n1)

# Those are not needed
unset TURTLES_CHARTS_INDEX
unset RANCHER_CHARTS_INDEX
unset NEUVECTOR_HELM_REPO_YAML
unset RANCHER_PRIME_HELM_REPO_YAML
unset LONGHORN_HELM_REPO_YAML

# Get a list of all variables after defining local ones
end_vars=$(compgen -v)

# Find the difference to get the locally defined variables, excluding helper variables
local_vars=$(comm -23 <(echo "$end_vars" | sort) <(echo "$initial_vars" | sort) | grep -Ev '^(initial_vars|end_vars|local_vars)$')

# Create JSON output
json_output="{"
for var in $local_vars; do
  value=$(printf '%s' "${!var}" | jq -Rs .) # JSON encode the value
  json_output+=$(printf '"%s": %s,' "$var" "$value")
done

# Remove the trailing comma and close the JSON object
json_output=${json_output%,}
json_output+="}"

# Print the JSON object to stdout
echo "$json_output"
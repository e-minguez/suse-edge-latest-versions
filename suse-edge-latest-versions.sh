#!/usr/bin/env bash
set -euo pipefail

# Get a list of all variables before defining any local ones
initial_vars=$(compgen -v)

RKE2=$(curl --silent "https://api.github.com/repos/rancher/rke2/releases/latest" | jq -r .tag_name)
K3S=$(curl --silent "https://api.github.com/repos/k3s-io/k3s/releases/latest" | jq -r .tag_name)
# NMCONFIGURATOR
NM=$(curl --silent "https://api.github.com/repos/suse-edge/nm-configurator/releases/latest" | jq -r .tag_name)
TURTLES=$(curl --silent "https://api.github.com/repos/rancher/turtles/releases/latest" | jq -r .tag_name)
ELEMENTAL=$(curl --silent "https://api.github.com/repos/rancher/elemental/releases/latest" | jq -r .tag_name)

# RANCHER
RANCHER=$(curl --silent "https://api.github.com/repos/rancher/rancher/releases/latest" | jq -r .tag_name)

# RANCHER PRIME
RANCHER_PRIME_HELM_REPO_YAML=$(curl -s https://charts.rancher.com/server-charts/prime/index.yaml)
RANCHER_PRIME_APP=$(echo "${RANCHER_PRIME_HELM_REPO_YAML}" | yq '.entries.rancher[0].appVersion')
RANCHER_PRIME_CHART=$(echo "${RANCHER_PRIME_HELM_REPO_YAML}" | yq '.entries.rancher[0].version')
RANCHER_PRIME_KUBE_REQUIRED=$(echo "${RANCHER_PRIME_HELM_REPO_YAML}" | yq '.entries.rancher[0].kubeVersion')
#RANCHER_PRIME_IMAGES=$(curl -s https://prime.ribs.rancher.io/rancher/"${RANCHER}"/rancher-images.txt)

# RANCHER STABLE
RANCHER_STABLE_HELM_REPO_YAML=$(curl -s https://releases.rancher.com/server-charts/stable/index.yaml)
RANCHER_STABLE_APP=$(echo "${RANCHER_STABLE_HELM_REPO_YAML}" | yq '.entries.rancher[0].appVersion')
RANCHER_STABLE_CHART=$(echo "${RANCHER_STABLE_HELM_REPO_YAML}" | yq '.entries.rancher[0].version')
RANCHER_STABLE_KUBE_REQUIRED=$(echo "${RANCHER_STABLE_HELM_REPO_YAML}" | yq '.entries.rancher[0].kubeVersion')

# RANCHER ALPHA
RANCHER_ALPHA_HELM_REPO_YAML=$(curl -s https://releases.rancher.com/server-charts/alpha/index.yaml)
RANCHER_ALPHA_APP=$(echo "${RANCHER_ALPHA_HELM_REPO_YAML}" | yq '.entries.rancher[0].appVersion')
RANCHER_ALPHA_CHART=$(echo "${RANCHER_ALPHA_HELM_REPO_YAML}" | yq '.entries.rancher[0].version')
RANCHER_ALPHA_KUBE_REQUIRED=$(echo "${RANCHER_ALPHA_HELM_REPO_YAML}" | yq '.entries.rancher[0].kubeVersion')

# Other components
RANCHER_CHARTS_INDEX=$(curl -s http://charts.rancher.io/index.yaml)

# LONGHORN UPSTREAM
LONGHORN=$(curl --silent "https://api.github.com/repos/longhorn/longhorn/releases/latest" | jq -r .tag_name)

LONGHORN_HELM_REPO_YAML=$(curl -s https://charts.longhorn.io/index.yaml)
LONGHORN_UPSTREAM_APP=$(echo "${LONGHORN_HELM_REPO_YAML}" | yq '.entries.longhorn[0].appVersion')
LONGHORN_UPSTREAM_CHART=$(echo "${LONGHORN_HELM_REPO_YAML}" | yq '.entries.longhorn[0].version')
LONGHORN_UPSTREAM_KUBE_REQUIRED=$(echo "${LONGHORN_HELM_REPO_YAML}" | yq '.entries.longhorn[0].kubeVersion')
#LONGHORN_UPSTREAM_IMAGES=$(curl -L -s https://github.com/longhorn/longhorn/releases/download/"${LONGHORN_HELM_REPO_LATEST}"/longhorn-images.txt)

# LONGHORN-RANCHER VIEW
LONGHORN_RANCHER_APP=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.longhorn[0].appVersion')
LONGHORN_RANCHER_CHART=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.longhorn[0].version')
LONGHORN_RANCHER_KUBE_REQUIRED=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.longhorn[0].kubeVersion')
LONGHORN_CRD_RANCHER_APP=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.longhorn-crd[0].appVersion')
LONGHORN_CRD_RANCHER_CHART=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.longhorn-crd[0].version')
#LONGHORN_GITHUB_RELEASE_LATEST_IMAGES=$(helm template http://charts.rancher.io/$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.longhorn[0].urls[0]') | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)

# LONGHORN_CHART=${LONGHORN_RANCHER_REPO_CHARTVERSION_LATEST}
# LONGHORNCRD_CHART=${LONGHORN_CRD_RANCHER_REPO_CHARTVERSION_LATEST}

# NEUVECTOR
NEUVECTOR=$(curl --silent "https://api.github.com/repos/neuvector/neuvector/releases/latest" | jq -r .tag_name)

# NEUVECTOR UPSTREAM
NEUVECTOR_HELM_REPO_YAML=$(curl -s https://neuvector.github.io/neuvector-helm/index.yaml)
NEUVECTOR_UPSTREAM_APP=$(echo "${NEUVECTOR_HELM_REPO_YAML}" | yq '.entries.core[0].appVersion')
NEUVECTOR_UPSTREAM_CHART=$(echo "${NEUVECTOR_HELM_REPO_YAML}" | yq '.entries.core[0].version')
NEUVECTOR_UPSTREAM_KUBE_REQUIRED=$(echo "${NEUVECTOR_HELM_REPO_YAML}" | yq '.entries.core[0].kubeVersion')

# NEUVECTOR FROM RANCHER VIEW
NEUVECTOR_RANCHER_APP=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.neuvector[0].appVersion')
NEUVECTOR_RANCHER_CHART=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.neuvector[0].version')
NEUVECTOR_RANCHER_KUBE_REQUIRED=$(echo "${NEUVECTOR_HELM_REPO_YAML}" | yq '.entries.neuvector[0].kubeVersion')
NEUVECTORCRD_RANCHER_APP=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.neuvector-crd[0].appVersion')
NEUVECTORCRD_RANCHER_CHART=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.neuvector-crd[0].version')

# https://open-docs.neuvector.com/deploying/airgap
#NEUVECTOR_IMAGES=$(helm template http://charts.rancher.io/$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.neuvector[0].urls[0]') | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)

#NEUVECTOR_CHART=${NEUVECTOR_RANCHER_REPO_CHARTVERSION_LATEST}
#NEUVECTORCRD_CHART=${NEUVECTORCRD_RANCHER_REPO_CHARTVERSION_LATEST}

# RANCHER TURTLES
TURTLES_CHARTS_INDEX=$(curl -s https://rancher.github.io/turtles/index.yaml)
TURTLES_UPSTREAM_APP=$(echo "${TURTLES_CHARTS_INDEX}" | yq '.entries.rancher-turtles[0].appVersion')
TURTLES_UPSTREAM_CHART=$(echo "${TURTLES_CHARTS_INDEX}" | yq '.entries.rancher-turtles[0].version')

# TURTLES_IMAGES=$(helm template $(echo "${TURTLES_CHARTS_INDEX}" | yq '.entries.rancher-turtles[0].urls[0]') | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)

ELEMENTAL_UPSTREAM_CHART=$(crane ls registry.suse.com/rancher/elemental-operator-chart -O | grep -v latest | tail -n1)
ELEMENTALCRD_UPSTREAM_CHART=$(crane ls registry.suse.com/rancher/elemental-operator-crds-chart -O | grep -v latest | tail -n1)

# ELEMENTAL FROM RANCHER
ELEMENTAL_RANCHER_APP=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.elemental[0].appVersion')
ELEMENTAL_RANCHER_CHART=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.elemental[0].version')
ELEMENTALCRD_RANCHER_APP=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.elemental-crd[0].appVersion')
ELEMENTALCRD_RANCHER_CHART=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.elemental-crd[0].version')

#ELEMENTAL_IMAGES=$(helm template http://charts.rancher.io/$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.elemental[0].urls[0]') | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)
#ELEMENTAL_CRD_IMAGES=$(helm template http://charts.rancher.io/$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.elemental-crd[0].urls[0]') | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)

SLMICRO_LATEST=$(curl -s https://www.suse.com/download/sle-micro/ | sed -n 's/.*<span class="sort_button" data-target="version_.-.">\([^<]*\)<.*/\1/p' | head -n1)

# Those are not needed
unset TURTLES_CHARTS_INDEX
unset RANCHER_CHARTS_INDEX
unset RANCHER_ALPHA_HELM_REPO_YAML
unset RANCHER_STABLE_HELM_REPO_YAML
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
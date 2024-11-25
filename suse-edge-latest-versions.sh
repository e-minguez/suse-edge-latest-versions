#!/usr/bin/env bash
set -euo pipefail

# Get a list of all variables before defining any local ones
initial_vars=$(compgen -v)

# TODO(eminguez): This is very fragile, find another/better way
SLMICRO=$(curl -s https://www.suse.com/download/sle-micro/ | sed -n 's/.*<span class="sort_button" data-target="version_.-.">\([^<]*\)<.*/\1/p' | head -n1)

# General github releases
RKE2=$(curl --silent "https://api.github.com/repos/rancher/rke2/releases/latest" | jq -r .tag_name)
K3S=$(curl --silent "https://api.github.com/repos/k3s-io/k3s/releases/latest" | jq -r .tag_name)
NM_CONFIGURATOR=$(curl --silent "https://api.github.com/repos/suse-edge/nm-configurator/releases/latest" | jq -r .tag_name)
TURTLES=$(curl --silent "https://api.github.com/repos/rancher/turtles/releases/latest" | jq -r .tag_name)
ELEMENTAL=$(curl --silent "https://api.github.com/repos/rancher/elemental/releases/latest" | jq -r .tag_name)
NEUVECTOR=$(curl --silent "https://api.github.com/repos/neuvector/neuvector/releases/latest" | jq -r .tag_name)
RANCHER=$(curl --silent "https://api.github.com/repos/rancher/rancher/releases/latest" | jq -r .tag_name)
LONGHORN=$(curl --silent "https://api.github.com/repos/longhorn/longhorn/releases/latest" | jq -r .tag_name)

# Rancher prime
RANCHER_PRIME_INDEX=$(curl -s https://charts.rancher.com/server-charts/prime/index.yaml)
RANCHER_PRIME_APP=$(echo "${RANCHER_PRIME_INDEX}" | yq '.entries.rancher[0].appVersion')
RANCHER_PRIME_CHART=$(echo "${RANCHER_PRIME_INDEX}" | yq '.entries.rancher[0].version')
RANCHER_PRIME_KUBE_REQUIRED=$(echo "${RANCHER_PRIME_INDEX}" | yq '.entries.rancher[0].kubeVersion')
RANCHER_PRIME_IMAGES=$(curl -s https://prime.ribs.rancher.io/rancher/"${RANCHER}"/rancher-images.txt)

# Rancher stable
RANCHER_STABLE_INDEX=$(curl -s https://releases.rancher.com/server-charts/stable/index.yaml)
RANCHER_STABLE_APP=$(echo "${RANCHER_STABLE_INDEX}" | yq '.entries.rancher[0].appVersion')
RANCHER_STABLE_CHART=$(echo "${RANCHER_STABLE_INDEX}" | yq '.entries.rancher[0].version')
RANCHER_STABLE_KUBE_REQUIRED=$(echo "${RANCHER_STABLE_INDEX}" | yq '.entries.rancher[0].kubeVersion')
RANCHER_STABLE_IMAGES=$(curl -s https://github.com/rancher/rancher/releases/download/"${RANCHER_STABLE_APP}"/rancher-images.txt)

# Rancher latest
RANCHER_LATEST_INDEX=$(curl -s https://releases.rancher.com/server-charts/latest/index.yaml)
RANCHER_LATEST_APP=$(echo "${RANCHER_LATEST_INDEX}" | yq '.entries.rancher[0].appVersion')
RANCHER_LATEST_CHART=$(echo "${RANCHER_LATEST_INDEX}" | yq '.entries.rancher[0].version')
RANCHER_LATEST_KUBE_REQUIRED=$(echo "${RANCHER_LATEST_INDEX}" | yq '.entries.rancher[0].kubeVersion')
RANCHER_LATEST_IMAGES=$(curl -s https://github.com/rancher/rancher/releases/download/"${RANCHER_LATEST_APP}"/rancher-images.txt)

# Rancher alpha
RANCHER_ALPHA_INDEX=$(curl -s https://releases.rancher.com/server-charts/alpha/index.yaml)
RANCHER_ALPHA_APP=$(echo "${RANCHER_ALPHA_INDEX}" | yq '.entries.rancher[0].appVersion')
RANCHER_ALPHA_CHART=$(echo "${RANCHER_ALPHA_INDEX}" | yq '.entries.rancher[0].version')
RANCHER_ALPHA_KUBE_REQUIRED=$(echo "${RANCHER_ALPHA_INDEX}" | yq '.entries.rancher[0].kubeVersion')
RANCHER_ALPHA_IMAGES=""
#RANCHER_ALPHA_IMAGES=$(curl -s https://github.com/rancher/rancher/releases/download/"${RANCHER_ALPHA_APP}"/rancher-images.txt)

# Rancher charts
RANCHER_CHARTS_INDEX=$(curl -s http://charts.rancher.io/index.yaml)

# Longhorn upstream
LONGHORN_CHARTS_INDEX=$(curl -s https://charts.longhorn.io/index.yaml)
LONGHORN_UPSTREAM_APP=$(echo "${LONGHORN_CHARTS_INDEX}" | yq '.entries.longhorn[0].appVersion')
LONGHORN_UPSTREAM_CHART=$(echo "${LONGHORN_CHARTS_INDEX}" | yq '.entries.longhorn[0].version')
LONGHORN_UPSTREAM_KUBE_REQUIRED=$(echo "${LONGHORN_CHARTS_INDEX}" | yq '.entries.longhorn[0].kubeVersion')
LONGHORN_UPSTREAM_IMAGES=$(curl -L -s https://github.com/longhorn/longhorn/releases/download/"${LONGHORN_UPSTREAM_APP}"/longhorn-images.txt)

# Longhorn-rancher
LONGHORN_RANCHER_APP=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.longhorn[0].appVersion')
LONGHORN_RANCHER_CHART=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.longhorn[0].version')
LONGHORN_RANCHER_KUBE_REQUIRED=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.longhorn[0].kubeVersion')
LONGHORN_CRD_RANCHER_APP=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.longhorn-crd[0].appVersion')
LONGHORN_CRD_RANCHER_CHART=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.longhorn-crd[0].version')
LONGHORN_RANCHER_IMAGES=$(helm template http://charts.rancher.io/$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.longhorn[0].urls[0]') | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)

# Neuvector upstream
NEUVECTOR_CHARTS_INDEX=$(curl -s https://neuvector.github.io/neuvector-helm/index.yaml)
NEUVECTOR_UPSTREAM_APP=$(echo "${NEUVECTOR_CHARTS_INDEX}" | yq '.entries.core[0].appVersion')
NEUVECTOR_UPSTREAM_CHART=$(echo "${NEUVECTOR_CHARTS_INDEX}" | yq '.entries.core[0].version')
NEUVECTOR_UPSTREAM_KUBE_REQUIRED=$(echo "${NEUVECTOR_CHARTS_INDEX}" | yq '.entries.core[0].kubeVersion')
# https://open-docs.neuvector.com/deploying/airgap
NEUVECTOR_UPSTREAM_IMAGES=$(helm template $(echo "${NEUVECTOR_CHARTS_INDEX}" | yq '.entries.core[0].urls[0]') | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)

# Neuvector-rancher
NEUVECTOR_RANCHER_APP=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.neuvector[0].appVersion')
NEUVECTOR_RANCHER_CHART=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.neuvector[0].version')
NEUVECTOR_RANCHER_KUBE_REQUIRED=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.neuvector[0].kubeVersion')
NEUVECTORCRD_RANCHER_APP=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.neuvector-crd[0].appVersion')
NEUVECTORCRD_RANCHER_CHART=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.neuvector-crd[0].version')
NEUVECTOR_RANCHER_IMAGES=$(helm template http://charts.rancher.io/$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.neuvector[0].urls[0]') | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)

# Rancher turtles
TURTLES_CHARTS_INDEX=$(curl -s https://rancher.github.io/turtles/index.yaml)
TURTLES_UPSTREAM_APP=$(echo "${TURTLES_CHARTS_INDEX}" | yq '.entries.rancher-turtles[0].appVersion')
TURTLES_UPSTREAM_CHART=$(echo "${TURTLES_CHARTS_INDEX}" | yq '.entries.rancher-turtles[0].version')
TURLTES_UPSTREAM_KUBE_REQUIRED=$(echo "${TURTLES_CHARTS_INDEX}" | yq '.entries.rancher-turtles[0].kubeVersion')
TURTLES_UPSTREAM_IMAGES=$(helm template $(echo "${TURTLES_CHARTS_INDEX}" | yq '.entries.rancher-turtles[0].urls[0]') | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)

# Elemental upstream using OCI
ELEMENTAL_UPSTREAM_CHART=$(crane ls registry.suse.com/rancher/elemental-operator-chart -O | grep -v latest | tail -n1)
ELEMENTALCRD_UPSTREAM_CHART=$(crane ls registry.suse.com/rancher/elemental-operator-crds-chart -O | grep -v latest | tail -n1)
ELEMENTAL_UPSTREAM_IMAGES=$(helm template elemental-operator oci://registry.suse.com/rancher/elemental-operator-chart --version="${ELEMENTAL_UPSTREAM_CHART}" | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)
ELEMENTALCRD_UPSTREAM_IMAGES=$(helm template elemental-operator-crds oci://registry.suse.com/rancher/elemental-operator-crds-chart --version="${ELEMENTALCRD_UPSTREAM_CHART}" | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)

# Elemental-rancher
ELEMENTAL_RANCHER_APP=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.elemental[0].appVersion')
ELEMENTAL_RANCHER_CHART=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.elemental[0].version')
ELEMENTALCRD_RANCHER_APP=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.elemental-crd[0].appVersion')
ELEMENTALCRD_RANCHER_CHART=$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.elemental-crd[0].version')
ELEMENTAL_RANCHER_IMAGES=$(helm template http://charts.rancher.io/$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.elemental[0].urls[0]') | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)
ELEMENTALCRD_RANCHER_IMAGES=$(helm template http://charts.rancher.io/$(echo "${RANCHER_CHARTS_INDEX}" | yq '.entries.elemental-crd[0].urls[0]') | awk '$1 ~ /image:/ {print $2}' | sed -e 's/\"//g' | sort | uniq)

# K3S versions
K3S_DETAILS=$(curl -s https://eduardominguez.es/k3s-versions/k3s.json)
for details in $(echo "${K3S_DETAILS}" | jq -r '.["k3s-versions"][] | "\(.name)@\(.version)"'); do
  k3sname=$(echo "${details}" | cut -d"@" -f1 | tr -dc '[:alnum:]'| tr '[:lower:]' '[:upper:]')
  k3sversion=$(echo "${details}" | cut -d"@" -f2)
  declare K3S_$k3sname=${k3sversion}
done
unset k3sname
unset k3sversion
unset details

# RKE2 versions
RKE2_DETAILS=$(curl -s https://eduardominguez.es/rke2-versions/rke2.json)
for details in $(echo "${RKE2_DETAILS}" | jq -r '.["rke2-versions"][] | "\(.name)@\(.version)"'); do
  rke2name=$(echo "${details}" | cut -d"@" -f1 | tr -dc '[:alnum:]'| tr '[:lower:]' '[:upper:]')
  rke2version=$(echo "${details}" | cut -d"@" -f2)
  declare RKE2_$rke2name=${rke2version}
done
unset rke2name
unset rke2version
unset details

# Those are not needed
unset RANCHER_PRIME_INDEX
unset RANCHER_STABLE_INDEX
unset RANCHER_LATEST_INDEX
unset RANCHER_ALPHA_INDEX
unset RANCHER_CHARTS_INDEX
unset LONGHORN_CHARTS_INDEX
unset NEUVECTOR_CHARTS_INDEX
unset TURTLES_CHARTS_INDEX
unset K3S_DETAILS
unset RKE2_DETAILS

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
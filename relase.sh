#!/usr/bin/env bash
set -euo pipefail
components=(web api scheduler notifier ai)
COMPOSE_FILE="docker-compose/docker-compose.yml"
VALUES_FILE="charts/reacheraven/values.yaml"
CHART_FILE="charts/reacheraven/Chart.yaml"

if sed --version >/dev/null 2>&1; then
  sed_i() { sed -E -i "$@"; }
else
  sed_i() { sed -E -i '' "$@"; }
fi

for comp in "${components[@]}"; do
  repo="reacheraven/reacheraven-${comp}"
  latest_tag=$(curl -s "https://registry.hub.docker.com/v2/repositories/${repo}/tags?page_size=100" | jq -r '.results[].name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)
  [ -z "$latest_tag" ] && exit 1
  echo "${comp}: ${latest_tag}"
  sed_i "s|(image:[[:space:]]*${repo}:)v[0-9]+\.[0-9]+\.[0-9]+|\\1${latest_tag}|g" "$COMPOSE_FILE"
  yq -i ".reacheraven.${comp}.tag = \"${latest_tag}\"" "$VALUES_FILE"
done

current_chart_version=$(yq '.version' "$CHART_FILE" | tr -d '"')
IFS='.' read -r cvMajor cvMinor cvPatch <<<"$current_chart_version"
new_chart_version="${cvMajor}.${cvMinor}.$((cvPatch+1))"

current_app_version=$(yq '.appVersion' "$CHART_FILE" | tr -d '"')
IFS='.' read -r avMajor avMinor avPatch <<<"$current_app_version"
new_app_version="${avMajor}.${avMinor}.$((avPatch+1))"

yq -i ".version = \"${new_chart_version}\" | .appVersion = \"${new_app_version}\"" "$CHART_FILE"
echo "Chart.yaml -> version=${new_chart_version}, appVersion=${new_app_version}"

#!/bin/sh

set -ex

# Fetch helm dependencies. Currently there is no way to build helm chart dependencies recursively
# (https://github.com/helm/helm/issues/2247), so until that issue is fixed we are fetching them here
rm charts/humio-core/charts/*.tgz
helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
helm repo update
pushd charts/humio-core && helm dep up; popd

# Remove any existing indexes
find . -iname index.yaml | grep -v docs | xargs rm

# Move existing releases to the charts directory so they can be re-indexed with proper URLs
find docs/ -name '*.tgz' -maxdepth 1 -exec mv {} ./ \;

helm package .
helm repo index . && mv index.yaml docs/

# Move all the charts to the docs so they can be served by github pages
find . -name '*.tgz' -mindepth 1 -maxdepth 1 -exec mv {} docs/ \;
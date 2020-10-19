#!/usr/bin/env bash

set -euo pipefail

mkdir -p target

for source in $(find src/ -name '*.md')
do
  target_dir="target/$(dirname ${source#src/})"
  target_file="$(basename ${source} .md).html"
  echo "Transforming ${source} to ${target_dir}/${target_file}"
  mkdir -p "${target_dir}"
  pandoc "${source}" -s --template src/template.html > "${target_dir}/${target_file}"
done

cp -f src/styles.css target/styles.css
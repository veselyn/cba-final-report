#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"

mkdir -p build

latexmk -xelatex main
mv main.pdf build/Final-Project-Report.pdf

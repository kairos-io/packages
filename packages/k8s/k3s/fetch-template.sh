#!/bin/bash

set -e

if [[ -z $TAG ]]; then
  echo "TAG should be set"
  exit 1
fi

cleanup() {
  echo "Cleaning up..."
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

TMPDIR=$(mktemp -d)
cd $TMPDIR
echo $TMPDIR

git clone --depth 1 --branch $TAG https://github.com/k3s-io/k3s.git
cd $TMPDIR/k3s

cat << EOF > main.go
package main

import (
	"fmt"

	"github.com/k3s-io/k3s/pkg/agent/templates"
)

func main() {
	fmt.Printf(templates.ContainerdConfigTemplate)
}
EOF

go run . > $SCRIPT_DIR/config.toml.tmpl

sed -i '/runc.options/a\
  NoPivotRoot = true
' $SCRIPT_DIR/config.toml.tmpl

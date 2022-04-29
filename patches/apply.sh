#!/usr/bin/env bash

patch_all() {
  local scriptpath="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

  patch() {
    set -e
    local plug=$1;shift
    pushd ~/.vim/plugged/$plug
    git checkout .
    git apply $scriptpath/$plug.patch
    popd
  }

  pushd "$(dirname "$0")"
  for f in *.patch; do
    patch ${f%.*}
  done
  popd
}

patch_all

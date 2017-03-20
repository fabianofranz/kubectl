#!/bin/bash

# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

# Usage:
# KUBERNETES_SRC_ROOT=$GOPATH/src/k8s.io/kubernetes \
#	  KUBECTL_SRC_ROOT=$GOPATH/src/k8s.io/kubectl \
#   FROM_PKG=k8s.io/kubernetes \
#   TO_PKG=github.com/fabianofranz/kubectl \
#   ./migrate.sh

if [[ -z ${KUBERNETES_SRC_ROOT:-} ]]; then
	echo "Please export KUBERNETES_SRC_ROOT (Kubernetes source dir)"
  exit 1
fi

if [[ -z ${KUBECTL_SRC_ROOT:-} ]]; then
	echo "Please export KUBECTL_SRC_ROOT (kubectl source dir)"
  exit 1
fi

if [[ -z ${FROM_PKG:-} ]]; then
	echo "Please export FROM_PKG (original package)"
  exit 1
fi

if [[ -z ${TO_PKG:-} ]]; then
	echo "Please export TO_PKG (destination package)"
  exit 1
fi

KUBERNETES_SRC="$(cd "${KUBERNETES_SRC_ROOT}"; pwd)"
KUBECTL_SRC="$(cd "${KUBECTL_SRC_ROOT}"; pwd)"

function copy() {
	echo "Copying $1..."
	mkdir -p "$(dirname "${KUBECTL_SRC}/$1")"
	cp -r "${KUBERNETES_SRC}/$1"* "${KUBECTL_SRC}/$1"
}

function repackage() {
	echo "Repackaging $1..."
	grep -Rl "$FROM_PKG/$1" . | grep "\.go" | xargs sed -i "s|\"$FROM_PKG/$1|\"$TO_PKG/$1|g"
}

copy "cmd/kubectl"
repackage "cmd/kubectl"

echo "done"

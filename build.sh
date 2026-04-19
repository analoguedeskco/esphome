#!/usr/bin/env bash
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
#
# Build the IDX-1 ESPHome firmware using the official Docker image.
# Output: .esphome/build/idx1/.pioenvs/idx1/firmware.bin
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure secrets.yaml exists
if [ ! -f "$SCRIPT_DIR/secrets.yaml" ]; then
  echo "Error: esphome/secrets.yaml not found."
  echo "Copy esphome/secrets.example.yaml to esphome/secrets.yaml and fill in your credentials."
  exit 1
fi

echo "Building ESPHome firmware with Docker..."
# Build — .esphome artifacts stay in a named Docker volume (Linux fs) for fast incremental rebuilds.
docker run --rm \
  -v "$SCRIPT_DIR:/config" \
  -v "esphome-cache:/cache" \
  -v "esphome-build:/config/.esphome" \
  ghcr.io/esphome/esphome \
  compile idx1.yaml

mkdir -p "$SCRIPT_DIR/output"

# Extract binary from the named volume via a minimal container
docker run --rm \
  -v "esphome-build:/build" \
  -v "$SCRIPT_DIR/output:/output" \
  alpine \
  cp /build/build/idx1/.pioenvs/idx1/firmware.bin /output/firmware.bin

SIZE=$(wc -c < "$SCRIPT_DIR/output/firmware.bin")
echo ""
echo "Build complete!"
echo "Binary : $SCRIPT_DIR/output/firmware.bin"
echo "Size   : $((SIZE / 1024)) KB"
echo ""
echo "Flash via the IDX-1 web UI:"
echo "  Advanced → Flash ESPHome → select esphome/output/firmware.bin"

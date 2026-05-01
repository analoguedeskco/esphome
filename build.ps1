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
# Build the IDX-2 ESPHome firmware using the official Docker image.
# Output: .esphome/build/idx2/.pioenvs/idx2/firmware.bin
#
# Usage: .\build.ps1
# Requires Docker Desktop to be running.

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Ensure secrets.yaml exists
if (-not (Test-Path "$ScriptDir\secrets.yaml")) {
    Write-Error "esphome\secrets.yaml not found. Copy secrets.example.yaml to secrets.yaml and fill in your credentials."
    exit 1
}

Write-Host "Building ESPHome firmware with Docker..." -ForegroundColor Cyan

# Build — both volumes stay on the Linux fs inside Docker for fast incremental rebuilds.
# esphome-build : generated PlatformIO project + compiled objects (.esphome/)
# esphome-cache : PlatformIO global packages/toolchain (/cache)
docker run --rm `
    -v "${ScriptDir}:/config" `
    -v "esphome-build:/config/.esphome" `
    -v "esphome-cache:/cache" `
    ghcr.io/esphome/esphome `
    compile idx2.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed."
    exit 1
}

# Extract binary from the named volume via a minimal container
$OutputDir = "$ScriptDir\output"
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

docker run --rm `
    -v "esphome-build:/build" `
    -v "${OutputDir}:/output" `
    alpine `
    cp /build/build/idx2/.pioenvs/idx2/firmware.bin /output/firmware.bin

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to extract firmware binary."
    exit 1
}

$Size = [math]::Round((Get-Item "$OutputDir\firmware.bin").Length / 1KB, 0)
Write-Host ""
Write-Host "Build complete!" -ForegroundColor Green
Write-Host "Binary : $OutputDir\firmware.bin"
Write-Host "Size   : $Size KB"
Write-Host ""
Write-Host "Flash via the IDX-2 web UI:"
Write-Host "  Advanced -> Flash ESPHome -> select esphome\output\firmware.bin"

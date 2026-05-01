# IDX-2 ESPHome Firmware

This repository contains the ESPHome firmware configuration for the Analogue Desk Co. `IDX-2` hardware project.

> Learn more here: https://analoguedesk.co/products/idx-2

The `IDX-2` is an open-architecture physical display device that maps digital data into a motor-driven gauge with RGB ambience.

> This repo is linked from the official `IDX-2` user manual. See https://docs.analoguedesk.co

## Repository contents

- `idx2.yaml` — ESPHome project definition
- `esphome_extras.h` — additional ESPHome C++ helpers and task logic
- `SwitecX25.h` / `SwitecX25.cpp` — stepper motor driver code
- `secrets.example.yaml` — example Wi-Fi and OTA secrets file
- `build.sh` / `build.ps1` — Docker-based build scripts
- `LICENSE` — Apache License 2.0 for this repository
- `NOTICE` — third-party BSD-2 license attribution for `SwitecX25` files

## Quick start

1. Copy `secrets.example.yaml` to `secrets.yaml` and fill in your credentials.
2. Ensure Docker Desktop is running.
3. From the repo root:
   - On Windows PowerShell: `.uild.ps1`
   - On macOS/Linux: `./build.sh`
4. The firmware binary will be written to `output/firmware.bin`.
5. Flash the binary using the IDX-2 web UI or your normal ESPHome/OTA workflow.

## Secrets and credentials

Do not commit `secrets.yaml` to source control.
Use `secrets.example.yaml` as the template for:

- `wifi_ssid`
- `wifi_password`
- `api_encryption_key`
- `ota_password`

## Hardware and network notes

- USB-C 5V power input
-- If operating the 6 LED version (IDX-2), operate LEDs at max 70% brightness with 0.5A supply. 
- Requires 2.4 GHz WPA2 Wi-Fi (not 5 GHz-only)

## License

This repository is licensed under the Apache License 2.0.

Third-party code included in this repo is licensed separately:

- `SwitecX25.cpp` — BSD 2-Clause License
- `SwitecX25.h` — BSD 2-Clause License

See `LICENSE` and `NOTICE` for details.

## Notes

- The firmware uses `ESPHome` with the Arduino framework on the ESP32-C3.
- `SwitecX25` drives the gauge stepper motor and is included as third-party source.


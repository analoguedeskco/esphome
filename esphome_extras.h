/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "esp_ota_ops.h"
#include "esp_partition.h"
#include "SwitecX25.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

// Pointer — initialised in on_boot once the Arduino GPIO framework is ready.
// Using a static global object would call pinMode() before setup(), which
// leaves the pins unconfigured and causes the motor to shudder but not move.
static SwitecX25* gauge = nullptr;

// Matches the custom IDX-1 firmware acceleration profile (motor.cpp)
static unsigned short slowAccelTable[][2] = {
  {  25, 12000},
  {  50,  6000},
  { 100,  4000},
  { 150,  3200},
  { 500,  2400},
};

// Dedicated FreeRTOS task — calls gauge->update() every 1ms independent of
// the ESPHome main loop, so WiFi/API activity cannot cause stepping jitter.
static void gauge_task(void*) {
  while (true) {
    if (gauge) gauge->update();
    vTaskDelay(1);
  }
}

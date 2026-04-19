# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "krpc",
#     "matplotlib",
# ]
# ///

import marimo as mo
import krpc
import time

# Connect to KSP
conn = krpc.connect(name='mission_control', address='127.0.0.1', rpc_port=50000)
space_center = conn.space_center
vessel = space_center.active_vessel

# UI State
update_interval = mo.ui.slider(0.1, 2.0, value=0.5, label="Update interval (s)")
throttle_slider = mo.ui.slider(0, 1, value=vessel.control.throttle, label="Throttle")
stage_button = mo.ui.button("STAGE", kind="danger")
sas_toggle = mo.ui.checkbox("SAS", value=vessel.control.sas)

# Apply controls
vessel.control.throttle = throttle_slider.value
vessel.control.sas = sas_toggle.value
if stage_button.value:
    vessel.control.activate_next_stage()

# Telemetry
def get_telemetry():
    flight = vessel.flight(vessel.orbit.body.reference_frame)
    orbit = vessel.orbit
    return {
        "altitude": flight.mean_altitude,
        "velocity": flight.velocity,
        "apoapsis": orbit.apoapsis_altitude,
        "periapsis": orbit.periapsis_altitude,
        "period": orbit.period,
        "fuel": vessel.resources.amount("LiquidFuel"),
        "stage": vessel.control.current_stage,
    }

telem = get_telemetry()

mo.md(f"""
# 🚀 Mission Control — {vessel.name}

## Status
| Metric | Value |
|--------|-------|
| Altitude | {telem['altitude']:.0f} m |
| Velocity | {abs(telem['velocity'][1]):.1f} m/s (vertical) |
| Apoapsis | {telem['apoapsis']:.0f} m |
| Periapsis | {telem['periapsis']:.0f} m |
| Period | {telem['period']:.1f} s |
| Stage | {telem['stage']} |
| Fuel | {telem['fuel']:.1f} |

## Controls
{mo.hstack([throttle_slider, sas_toggle, stage_button])}

## Settings
{update_interval}
""")

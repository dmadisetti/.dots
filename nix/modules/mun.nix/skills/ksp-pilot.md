---
title: KSP Vessel Pilot
description: Control KSP vessels via kRPC Python API — telemetry, flight control, and staging
tags: [ksp, krpc, control, flight]
tools: [bash, read, write]
created: 2026-03-26
author: mun.nix
confidence: medium
---

# KSP Vessel Pilot

Control Kerbal Space Program vessels programmatically through the kRPC gRPC API using the Python `krpc` library.

## Connection

```python
import krpc
conn = krpc.connect(name='cowboy', address='127.0.0.1', rpc_port=50000)
vessel = conn.space_center.active_vessel
```

Always wrap in try/except — kRPC may not be ready if KSP is still loading.

## Reading Telemetry

### Flight Data
```python
flight = vessel.flight(vessel.orbit.body.reference_frame)
print(f"Altitude: {flight.mean_altitude:.0f} m")
print(f"Speed: {flight.speed:.1f} m/s")
print(f"Heading: {flight.heading:.1f} deg")
print(f"Pitch: {flight.pitch:.1f} deg")

# Surface-relative
surface = vessel.flight(vessel.orbit.body.reference_frame)
print(f"Vertical speed: {surface.vertical_speed:.1f} m/s")
print(f"Horizontal speed: {surface.horizontal_speed:.1f} m/s")
```

### Orbital Parameters
```python
orbit = vessel.orbit
print(f"Apoapsis: {orbit.apoapsis_altitude:.0f} m")
print(f"Periapsis: {orbit.periapsis_altitude:.0f} m")
print(f"Eccentricity: {orbit.eccentricity:.4f}")
print(f"Inclination: {orbit.inclination * 180/3.14159:.2f} deg")
print(f"Period: {orbit.period:.0f} s")
print(f"Time to Ap: {orbit.time_to_apoapsis:.0f} s")
print(f"Time to Pe: {orbit.time_to_periapsis:.0f} s")
```

### Resources (Fuel)
```python
resources = vessel.resources
print(f"LiquidFuel: {resources.amount('LiquidFuel'):.1f}")
print(f"Oxidizer: {resources.amount('Oxidizer'):.1f}")
print(f"ElectricCharge: {resources.amount('ElectricCharge'):.1f}")
print(f"MonoPropellant: {resources.amount('MonoPropellant'):.1f}")

# Current stage only
stage_resources = vessel.resources_in_decouple_stage(vessel.control.current_stage)
```

## Streaming Telemetry (Efficient)

For continuous data, use kRPC streams instead of polling:

```python
altitude = conn.add_stream(getattr, vessel.flight(), 'mean_altitude')
apoapsis = conn.add_stream(getattr, vessel.orbit, 'apoapsis_altitude')

# Read without RPC overhead
print(altitude(), apoapsis())

# Clean up
altitude.remove()
apoapsis.remove()
```

## Flight Control

### Throttle & Staging
```python
vessel.control.throttle = 1.0          # Full throttle (0.0 to 1.0)
vessel.control.activate_next_stage()   # Stage
vessel.control.sas = True              # Enable SAS
vessel.control.rcs = True              # Enable RCS
```

### SAS Modes
```python
vessel.control.sas_mode = conn.space_center.SASMode.prograde
# Options: stability_assist, maneuver, prograde, retrograde,
#          normal, anti_normal, radial, anti_radial, target, anti_target
```

### Autopilot (for precise control)
```python
ap = vessel.auto_pilot
ap.reference_frame = vessel.surface_reference_frame
ap.engage()
ap.target_pitch_and_heading(90, 90)  # pitch=90 (up), heading=90 (east)
ap.wait()                             # Block until oriented

# Disengage when done
ap.disengage()
```

### Raw Axis Control
```python
vessel.control.pitch = 1.0    # -1.0 to 1.0
vessel.control.yaw = 0.0
vessel.control.roll = 0.0
```

## Common Flight Patterns

### Launch & Gravity Turn
```python
# Pre-launch
vessel.control.sas = True
vessel.control.throttle = 1.0
vessel.control.activate_next_stage()  # Ignition

# Gravity turn at ~10km
import time
while vessel.flight().mean_altitude < 10000:
    time.sleep(0.5)

ap = vessel.auto_pilot
ap.engage()
ap.target_pitch_and_heading(45, 90)

# Coast to apoapsis ~80km
while vessel.orbit.apoapsis_altitude < 80000:
    time.sleep(1)

vessel.control.throttle = 0.0
```

### Circularization Burn
```python
import math

mu = vessel.orbit.body.gravitational_parameter
r = vessel.orbit.apoapsis
v_circular = math.sqrt(mu / r)
v_apoapsis = math.sqrt(mu * (2/r - 1/vessel.orbit.semi_major_axis))
delta_v = v_circular - v_apoapsis

# Create maneuver node
ut = conn.space_center.ut + vessel.orbit.time_to_apoapsis
node = vessel.control.add_node(ut, prograde=delta_v)

# Execute (see mission-plan skill for burn execution)
```

## Safety Checks

Before any maneuver:
1. Read current orbital parameters
2. Check fuel levels — abort if insufficient
3. Quicksave: `conn.space_center.quicksave()`
4. Verify SAS/autopilot is engaged before burning
5. Monitor altitude during ascent — abort if negative vertical speed near surface

## Quicksave/Quickload
```python
conn.space_center.quicksave()
conn.space_center.quickload()
```

## Verification

After a maneuver, always verify:
- `vessel.orbit.apoapsis_altitude` and `periapsis_altitude` match expectations
- `vessel.situation` is the expected state (pre_launch, flying, orbiting, etc.)
- Fuel remaining is sufficient for return

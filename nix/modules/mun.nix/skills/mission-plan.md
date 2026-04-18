---
title: KSP Mission Planner
description: Plan orbital maneuvers, transfer windows, and mission profiles for KSP via kRPC
tags: [ksp, orbital-mechanics, planning, krpc]
tools: [bash, read]
created: 2026-03-26
author: mun.nix
confidence: medium
---

# KSP Mission Planner

Plan and execute orbital maneuvers in Kerbal Space Program using kRPC. This skill covers the math and API calls for common mission profiles.

## Key Constants (KSP / Kerbin System)

| Body   | Radius (m) | GM (m^3/s^2)     | SOI (m)       |
|--------|-----------|-------------------|---------------|
| Kerbin | 600,000   | 3.5316e12         | 84,159,286    |
| Mun    | 200,000   | 6.5138e10         | 2,429,559     |
| Minmus | 60,000    | 1.7658e9          | 2,247,428     |
| Kerbol | 2.616e8   | 1.1723e18         | inf           |

- Kerbin sea-level g: 9.81 m/s^2
- Standard low Kerbin orbit (LKO): 80,000 m altitude
- Mun orbit altitude: 12,000,000 m (from Kerbin center)
- Minmus orbit altitude: 47,000,000 m (from Kerbin center)

## Maneuver Node API

```python
import krpc, math
conn = krpc.connect(name='cowboy')
vessel = conn.space_center.active_vessel

# Create a node: add_node(ut, prograde, normal, radial)
ut = conn.space_center.ut + vessel.orbit.time_to_apoapsis
node = vessel.control.add_node(ut, prograde=100.0, normal=0.0, radial=0.0)

# Read node properties
print(f"Delta-v: {node.delta_v:.1f} m/s")
print(f"Burn time (approx): {node.delta_v / (vessel.available_thrust / vessel.mass):.1f} s")
print(f"UT: {node.ut:.0f}")

# Remove a node
node.remove()
```

## Hohmann Transfer

To move from circular orbit r1 to circular orbit r2:

```python
def hohmann_delta_v(mu, r1, r2):
    """Returns (dv1, dv2) for a Hohmann transfer."""
    a_transfer = (r1 + r2) / 2
    v1 = math.sqrt(mu / r1)
    v_transfer_1 = math.sqrt(mu * (2/r1 - 1/a_transfer))
    dv1 = v_transfer_1 - v1

    v2 = math.sqrt(mu / r2)
    v_transfer_2 = math.sqrt(mu * (2/r2 - 1/a_transfer))
    dv2 = v2 - v_transfer_2

    return dv1, dv2
```

## Common Mission Profiles

### Kerbin Orbit (80km LKO)
- From launchpad: ~3,400 m/s total delta-v
- Gravity turn starts ~10km, pitch to 45 deg heading 90 (east)
- Coast to 80km apoapsis, circularize

### Mun Transfer (from 80km LKO)
```python
mu = vessel.orbit.body.gravitational_parameter
r_lko = 600000 + 80000       # Kerbin radius + altitude
r_mun = 12000000              # Mun orbit radius from Kerbin center
dv1, dv2 = hohmann_delta_v(mu, r_lko, r_mun)
# dv1 ~ 860 m/s (trans-Munar injection)
# dv2 varies (Mun capture)
```

**Phase angle:** The Mun must be ~60 degrees ahead of your position at burn time.

### Minmus Transfer (from 80km LKO)
- Transfer delta-v: ~930 m/s
- Minmus has a 6-degree inclined orbit — add a normal component or do a plane change
- Phase angle: ~85 degrees

### Return from Mun
- From 20km Mun orbit: ~310 m/s retrograde to drop periapsis into Kerbin atmosphere
- Aim for Kerbin periapsis 30-40km for aerobraking

## Executing a Burn

```python
def execute_node(conn, node, tolerance=0.1):
    """Execute a maneuver node. Burns prograde until remaining dv < tolerance."""
    vessel = conn.space_center.active_vessel

    # Point at maneuver
    vessel.control.sas = True
    vessel.control.sas_mode = conn.space_center.SASMode.maneuver
    import time
    time.sleep(5)  # Wait for orientation

    # Estimate burn time (Tsiolkovsky)
    F = vessel.available_thrust
    Isp = vessel.specific_impulse * 9.81
    m0 = vessel.mass
    dv = node.delta_v
    burn_time = m0 * (1 - math.exp(-dv / Isp)) / (F / Isp)

    # Warp to burn start (half burn time before node)
    burn_ut = node.ut - burn_time / 2
    conn.space_center.warp_to(burn_ut - 5)
    time.sleep(5)

    # Burn
    remaining = conn.add_stream(getattr, node, 'remaining_delta_v')
    vessel.control.throttle = 1.0

    while remaining() > dv * 0.05:
        time.sleep(0.1)

    # Fine-tune at low throttle
    vessel.control.throttle = 0.05
    while remaining() > tolerance:
        time.sleep(0.05)

    vessel.control.throttle = 0.0
    node.remove()
    remaining.remove()
```

## Time Warp

```python
# Warp to a specific universal time
conn.space_center.warp_to(conn.space_center.ut + 300)  # 5 minutes ahead

# Or warp to node
node_ut = vessel.control.nodes[0].ut
conn.space_center.warp_to(node_ut - 60)  # 1 minute before node
```

## Phase Angle Calculation

To find when to burn for an interplanetary (or inter-moon) transfer:

```python
def phase_angle(conn, target_body):
    """Current phase angle between vessel and target body."""
    vessel = conn.space_center.active_vessel
    ref = vessel.orbit.body.reference_frame

    v_pos = vessel.position(ref)
    t_pos = target_body.position(ref)

    # Angle between position vectors in the orbital plane
    dot = v_pos[0]*t_pos[0] + v_pos[2]*t_pos[2]
    cross = v_pos[0]*t_pos[2] - v_pos[2]*t_pos[0]
    angle = math.atan2(cross, dot) * 180 / math.pi

    return angle % 360
```

## Delta-V Budget Reference

| Maneuver | Delta-v (m/s) |
|----------|--------------|
| Kerbin surface to LKO (80km) | ~3,400 |
| LKO to Mun transfer | ~860 |
| Mun orbit insertion (20km) | ~310 |
| Mun surface to orbit | ~580 |
| LKO to Minmus transfer | ~930 |
| Minmus orbit insertion | ~160 |
| LKO to Kerbin escape | ~950 |

## Verification

After creating a maneuver node:
1. Check `node.orbit.apoapsis_altitude` — does the transfer orbit reach the target?
2. Check `node.orbit.next_orbit` — does it enter the target SOI?
3. Verify delta-v budget: `sum(n.delta_v for n in vessel.control.nodes)` vs available
4. Check fuel: `vessel.resources.amount('LiquidFuel')` sufficient for all nodes

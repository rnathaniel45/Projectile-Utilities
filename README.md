# Projectile-Utilities

Functions inside Utilities.lua:

```
origin (projectile starting position): Vector3
g (gravity): number, speed (projectile speed): number
jump (initial projectile "jump" along velocity): number
target (target position): Vector3
tvel (target velocity): Vector3
angle (projectile vertical firing angle): number 
ishigh (find high arc): bool
t (projectile flight time): number
yend (desired ending y value for flight time calculation): number

solveTimeSpeed(origin, g, speed, jump, target, tvel, ishigh): number - Finds the flight time given projectile speed
solveTimeAngle(origin, g, target, tvel, angle): number - Finds the flight time given projectile angle

timeToVelocity(origin, g, jump, target, tvel, angle, t): number - Finds projectile speed given projectile angle and flight time
timeToTrajectory(origin, g, speed, jump, target, tvel, t): Vector3 - Finds projectile trajectory (aim unit vector) given flight time and speed

solveTrajectorySpeed(origin, g, speed, jump, target, tvel, ishigh): Vector3 - Finds projectile trajectory for cases where speed is known
solveTrajectoryAngle(origin, g, jump, target, tvel, angle): Vector3 - Finds projectile trajectory for cases where angle is known

solveFlightTime(origin, g, speed, jump, aim, yend): number - Finds flight time given the ending y value to calculate time at
```

Derivation of prediction math for case where speed is known:

![image](https://github.com/rnathaniel45/Projectile-Utilities/assets/70607607/bd67b37e-24c8-4c61-a46f-b47ebe1ab5fa)
![image](https://github.com/rnathaniel45/Projectile-Utilities/assets/70607607/f594c979-3875-4e1c-9759-7f0727705243)

Attribution:
Quartic solving functions ported by me from: https://www.realtimerendering.com/resources/GraphicsGems/gems/Roots3And4.c
Math loosely based on this blog: https://www.forrestthewoods.com/blog/solving_ballistic_trajectories/

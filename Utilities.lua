local Vector2 = require "Vector2"
local Vector3 = require "Vector3"

local Utilities = {}

--//NUMBER CONSTANTS
local zero = 1e-9

local onethird = 1 / 3
local twotwsevs = 2 / 27

local thirdpi = math.pi / 3
--END\\

local function isZero(num)
	return num < zero and num > -zero
end

local function cubicRoot(num)
	return (num > 0 and math.pow(num, onethird)) or (num < 0 and -math.pow(-num, onethird)) or 0
end

local function solveQuadric(c0, c1, c2, reftable)
	local p, q, D

	p = c1 / (2 * c0)
	q = c2 / c0

	D = p * p - q

	if isZero(D) then
		reftable[1] = -p
		return 1
	elseif D < 0 then
		return 0
	else
		local sqr = math.sqrt(D)

		reftable[1] = sqr - p
		reftable[2] = -sqr - p

		return 2
	end
end

local function solveCubic(c0, c1, c2, c3, reftable)
	local num, sub, A, B, C, sqA, p, q, cbp, D

	A = c1 / c0
	B = c2 / c0
	C = c3 / c0

	sqA = A * A
	p = onethird * (-onethird * sqA + B)
	q = .5 * (twotwsevs * A * sqA - onethird * A * B + C)

	cbp = p * p * p
	D = q * q + cbp

	sub = onethird * A

	if isZero(D) then
		if isZero(q) then
			reftable[1] = 0 - sub
			num = 1
		else
			local u = cubicRoot(-q)

			reftable[1] = 2 * u - sub
			reftable[2] = -u - sub

			num = 2
		end
	elseif D < 0 then
		local phi = onethird * math.acos(-q / math.sqrt(-cbp))
		local t = 2 * math.sqrt(-p)

		reftable[1] = t * math.cos(phi) - sub
		reftable[2] = -t * math.cos(phi + thirdpi) - sub
		reftable[3] = -t * math.cos(phi - thirdpi) - sub

		num = 3
	else
		local sqrD = math.sqrt(D)

		reftable[1] = cubicRoot(sqrD - q) - cubicRoot(sqrD + q) - sub
		num = 1
	end

	return num
end

local function solveQuartic(c0, c1, c2, c3, c4, reftable)
	local num, z, u, v, sub, A, B, C, D, sqA, p, q, r

	A = c1 / c0
	B = c2 / c0
	C = c3 / c0
	D = c4 / c0

	sqA = A * A
	p = -.375 * sqA + B
	q = .125 * sqA * A - .5 * A * B + C
	r = -.01171875 * sqA * sqA + .0625 * sqA * B - .25 * A * C + D

	sub = .25 * A

	if isZero(r) then
		num = solveCubic(1, 0, p, q, reftable)
	else
		local holder = {}
		local h, j, k

		solveCubic(1, -.5 * p, -r, .5 * r * p - .125 * q * q, reftable)
		z = reftable[1]

		u = z * z - r
		v = 2 * z - p

		u = (isZero(u) and 0) or (u > 0 and math.sqrt(u)) or nil
		v = (isZero(v) and 0) or (v > 0 and math.sqrt(v)) or nil

		if u == nil or v == nil then return 0 end

		h = 1
		j = q < 0 and -v or v
		k = z - u

		num = solveQuadric(h, j, k, reftable)

		j = -j
		k = z + u

		if num == 0 then
			num = num + solveQuadric(h, j, k, reftable)
		elseif num == 1 then
			num = num + solveQuadric(h, j, k, holder)

			reftable[2] = holder[1]
			reftable[3] = holder[2]
		elseif num == 2 then
			num = num + solveQuadric(h, j, k, holder)

			reftable[3] = holder[1]
			reftable[4] = holder[2]
		end
	end

	if num > 0 then reftable[1] = reftable[1] - sub end
	if num > 1 then reftable[2] = reftable[2] - sub end
	if num > 2 then reftable[3] = reftable[3] - sub end
	if num > 3 then reftable[4] = reftable[4] - sub end

	return num
end

local function solveTimeSpeed(origin, g, speed, jump, target, tvel, ishigh)
	local diff = target - origin
	local roots = {}

	local c0 = g * g * .25
	local c1 = -tvel.Y * g
	local c2 = tvel:Dot(tvel) - g * diff.Y - speed * speed
	local c3 = 2 * (tvel:Dot(diff) - speed * jump)
	local c4 = diff:Dot(diff) - jump * jump

	local num = solveQuartic(c0, c1, c2, c3, c4, roots)

	if num > 0 then
		local low, high = math.huge, math.huge

		for i, t in ipairs(roots) do
			if t > 0 then
				if t < low then
					high = low
					low = t
				elseif t < high then
					high = t
				end
			end
		end

		return (ishigh and high ~= math.huge and high) or (low ~= math.huge and low)
	end
end

local function solveTimeAngle(origin, g, target, tvel, angle)
	local diff = target - origin
	local roots = {}
	
	local hdiff = Vector2.new(diff.X, diff.Z)
	local hvel = Vector2.new(tvel.X, tvel.Z)
	
	local ay = math.sin(math.rad(angle))
	local factor = 1 - 1 / (ay * ay)
	
	local tvy = tvel.Y
	local dy = diff.Y

	local c0 = .25 * factor * g * g
	local c1 = -factor * tvy * g
	local c2 = hvel:Dot(hvel) + factor * (tvy * tvy - g * dy)
	local c3 = 2 * (hvel:Dot(hdiff) + factor * tvy * dy)
	local c4 = hdiff:Dot(hdiff) + factor * dy * dy

	local num = solveQuartic(c0, c1, c2, c3, c4, roots)
	
	if num > 0 then
		for i, t in ipairs(roots) do
			if t > 0 then
				return t
			end
		end
	end
	
	return false
end

local function timeToVelocity(origin, g, jump, target, tvel, angle, t)
	return ((target.Y - origin.Y + tvel.Y * t - .5 * g * t * t) / math.sin(math.rad(angle)) - jump) / t
end

local function timeToTrajectory(origin, g, speed, jump, target, tvel, t)
	return (target - origin + tvel * t - Vector3.new(0, .5 * g * t * t, 0)) / (speed * t + jump)
end

local function solveTrajectorySpeed(origin, g, speed, jump, target, tvel, ishigh)
	local t = solveTimeSpeed(origin, g, speed, jump, target, tvel, ishigh)
	return t and timeToTrajectory(origin, g, speed, jump, target, tvel, t)
end

local function solveTrajectoryAngle(origin, g, jump, target, tvel, angle)
	local t = solveTimeAngle(origin, g, target, tvel, angle)
	return t and timeToTrajectory(origin, g, timeToVelocity(origin, g, jump, target, tvel, angle, t), jump, target, tvel, t)
end

local function solveFlightTime(origin, g, speed, jump, aim, yend)
	local roots = {}
	local ay = aim.Y
	
	local num = solveQuadric(.5 * g, ay * speed, origin.Y + ay * jump - yend, roots)
	
	if num > 0 then
		local sol = math.max(unpack(roots))
		return sol >= 0 and sol
	end
	
	return false
end

Utilities.solveTimeSpeed = solveTimeSpeed
Utilities.solveTimeAngle = solveTimeAngle

Utilities.timeToVelocity = timeToVelocity
Utilities.timeToTrajectory = timeToTrajectory

Utilities.solveTrajectorySpeed = solveTrajectorySpeed
Utilities.solveTrajectoryAngle = solveTrajectoryAngle

Utilities.solveFlightTime = solveFlightTime

return Utilities
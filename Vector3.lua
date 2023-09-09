local Vector3 = {}

function Vector3.new(x, y, z)
    return setmetatable({
        X = x or 0,
        Y = y or 0,
        Z = z or 0
    }, Vector3)
end

function Vector3:__index(indice)
    if indice == "Magnitude" then
        return math.sqrt(self.X ^ 2 + self.Y ^ 2 + self.Z ^ 2)
    elseif indice == "Unit" then
        return self / self.Magnitude
    else
        return Vector3[indice]
    end
end

function Vector3:__add(other)
    return Vector3.new(self.X + other.X, self.Y + other.Y, self.Z + other.Z)
end

function Vector3:__sub(other)
    return Vector3.new(self.X - other.X, self.Y - other.Y, self.Z - other.Z)
end

function Vector3:__unm()
    return Vector3.new(-self.X, -self.Y, -self.Z)
end

function Vector3:__mul(other)
    if type(other) == "number" then
        return Vector3.new(self.X * other, self.Y * other, self.Z * other)
    end

    return Vector3.new(self.X * other.X, self.Y * other.Y, self.Z * other.Z)
end

function Vector3:__div(other)
    if type(other) == "number" then
        return Vector3.new(self.X / other, self.Y / other, self.Z / other)
    end

    return Vector3.new(self.X / other.X, self.Y / other.Y, self.Z / other.Z)
end

function Vector3:Dot(other)
    return self.X * other.X + self.Y * other.Y + self.Z * other.Z
end

function Vector3:__tostring()
    return self.X .. " " .. self.Y .. " " .. self.Z
end

return Vector3
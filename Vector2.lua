local Vector2 = {}

function Vector2.new(x, y)
    return setmetatable({
        X = x or 0,
        Y = y or 0
    }, Vector2)
end

function Vector2:__index(indice)
    if indice == "Magnitude" then
        return math.sqrt(self.X ^ 2 + self.Y ^ 2)
    elseif indice == "Unit" then
        return self / self.Magnitude
    else
        return Vector2[indice]
    end
end

function Vector2:__add(other)
    return Vector2.new(self.X + other.X, self.Y + other.Y)
end

function Vector2:__sub(other)
    return Vector2.new(self.X - other.X, self.Y - other.Y)
end

function Vector2:__unm()
    return Vector2.new(-self.X, -self.Y)
end

function Vector2:__mul(other)
    if type(other) == "number" then
        return Vector2.new(self.X * other, self.Y * other)
    end

    return Vector2.new(self.X * other.X, self.Y * other.Y)
end

function Vector2:__div(other)
    if type(other) == "number" then
        return Vector2.new(self.X / other, self.Y / other)
    end

    return Vector2.new(self.X / other.X, self.Y / other.Y)
end

function Vector2:Dot(other)
    return self.X * other.X + self.Y * other.Y
end

function Vector2:__tostring()
    return self.X .. " " .. self.Y
end

return Vector2
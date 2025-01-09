local Projectile = {}
Projectile.__index = Projectile

-- Constructeur pour créer un nouveau projectile
function Projectile.new(x, y, direction)
    local self = setmetatable({}, Projectile)
    self.x = x
    self.y = y
    self.speed = 1500
    self.direction = direction
    self.ttl = 0.8 -- Time To Live
    return self
end

-- Mise à jour de l'état du projectile
function Projectile:update(dt)
    self.x = self.x + self.speed * dt * math.cos(self.direction)
    self.y = self.y + self.speed * dt * math.sin(self.direction)
    self.ttl = self.ttl - dt
end

-- Dessin du projectile
function Projectile:draw()
    love.graphics.circle("fill", self.x, self.y, 5)
end

-- Vérifie si le projectile est encore actif
function Projectile:isAlive()
    return self.ttl > 0
end

return Projectile

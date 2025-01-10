local GlobalState = require("game.state")

local Bullet = {}
Bullet.__index = Bullet

function Bullet.new(x, y, direction)
    local self = setmetatable({}, Bullet)
    
    self.TTL = 1
    self.speed = 1500
    self.currentTTL = 0
    self.direction = direction
    self.x = x
    self.y = y
    self.image = love.graphics.newImage("sprites/bullet.png")
    print(self.direction)

    return self
end

-- Draw the gun
function Bullet:draw()
    love.graphics.draw(self.image, self.x, self.y, self.direction + math.pi/2, 4, 4, 0, 0)
end

function Bullet:update(dt)
    self.currentTTL = self.currentTTL + dt
    if self.currentTTL >= self.TTL then
        -- Remove the bullet
        GlobalState:removeEntity(self)
    end

    -- Move the bullet
    self.x = self.x + math.cos(self.direction) * self.speed * dt
    self.y = self.y + math.sin(self.direction) * self.speed * dt
    
end

return Bullet

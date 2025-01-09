local StationaryEnemy = {}
StationaryEnemy.__index = StationaryEnemy

function StationaryEnemy.new(x, y)
    local self = setmetatable({}, StationaryEnemy)
    self.x = x
    self.y = y
    self.image = love.graphics.newImage("sprites/stationary_enemy.png") -- Ajoutez une image pour l'ennemi
    self.health = 100
    return self
end

function StationaryEnemy:update(dt, player)
    -- Aucun mouvement pour cet ennemi
end

function StationaryEnemy:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, 1, 1, self.image:getWidth() / 4, self.image:getHeight() / 4)
end

function StationaryEnemy:isAlive()
    return self.health > 0
end

function StationaryEnemy:takeDamage(damage)
    self.health = self.health - damage
    print("Stationary enemy took " .. damage .. " damage. Health: " .. self.health)
end

return StationaryEnemy

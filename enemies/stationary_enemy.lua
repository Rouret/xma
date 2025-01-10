local StationaryEnemy = {}
StationaryEnemy.__index = StationaryEnemy

function StationaryEnemy.new(x, y, world)
    local self = setmetatable({}, StationaryEnemy)
    self.x = x
    self.y = y
    self.health = 100
    self.radius = 50
    -- Créer un Body pour l'ennemi
    self.body = love.physics.newBody(world, self.x, self.y, "static") -- Corps statique
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData(self) -- Identifier ce corps comme cet ennemi
    return self
end

function StationaryEnemy:update(dt, player)
    -- Aucun mouvement pour cet ennemi
end

function StationaryEnemy:draw()
    love.graphics.setColor(1, 0, 0) -- Set color to red
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(1, 1, 1) -- Reset color to white
end

function StationaryEnemy:isAlive()
    return self.health > 0
end

function StationaryEnemy:takeDamage(damage)
    self.health = self.health - damage
end

return StationaryEnemy

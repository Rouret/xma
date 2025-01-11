local StationaryEnemy = {}
StationaryEnemy.__index = StationaryEnemy

function StationaryEnemy.new(x, y, world)
    local self = setmetatable({}, StationaryEnemy)
    self.x = x
    self.y = y
    self.name = "stationary_enemy"
    self.health = 100
    self.maxHealth = 100
    self.radius = 50
    self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData(self) 

    return self
end

function StationaryEnemy:update(dt, world)
    -- Aucun mouvement pour cet ennemi
end

function StationaryEnemy:draw()
    love.graphics.setColor(1, 0, 0) -- Set color to red
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(1, 1, 1) -- Reset color to white

    -- Dessiner la barre de vie
    local healthBarWidth = 100
    local healthBarHeight = 10
    local healthBarX = self.x - healthBarWidth / 2
    local healthBarY = self.y - self.radius - healthBarHeight
    love.graphics.setColor(1, 0, 0) -- Set color to red
    love.graphics.rectangle("fill", healthBarX, healthBarY, healthBarWidth, healthBarHeight)
    love.graphics.setColor(0, 1, 0) -- Set color to green
    love.graphics.rectangle("fill", healthBarX, healthBarY, healthBarWidth * (self.health / self.maxHealth), healthBarHeight)
    love.graphics.setColor(1, 1, 1) -- Reset color to white
end

function StationaryEnemy:isAlive()
    return self.health > 0
end

function StationaryEnemy:takeDamage(damage)
    self.health = self.health - damage
    if self.health <= 0 then
        self:destroy()
    end
end

function StationaryEnemy:destroy()
    self.fixture:destroy()
    GlobalState:removeEntity(self)
end

return StationaryEnemy

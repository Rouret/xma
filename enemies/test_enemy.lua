local State = require("player.state")
local Enemy = require("engine.enemy")
local Camera = require("engine.camera")
local TestEnemy = Enemy:extend()
TestEnemy.__index = TestEnemy

function TestEnemy:init(params)
    params = params or {}
    params.shape = love.physics.newCircleShape(params.radius or 50)
    params.bodyType = "dynamic"
    Enemy.init(self, params)

    self.fixture:setUserData(self)
    self.fixture:setSensor(true)
    self.body:setBullet(true)

    return self
end

function TestEnemy:update(dt, world)
    -- Calculer la direction vers le joueur
    local dx = State.x - self.body:getX()
    local dy = State.y - self.body:getY()
    local distance = math.sqrt(dx ^ 2 + dy ^ 2)

    if distance > 0 then
        local velocityX = (dx / distance) * self.speed
        local velocityY = (dy / distance) * self.speed
        self.body:setLinearVelocity(velocityX, velocityY)
    else
        self.body:setLinearVelocity(0, 0) -- Arrêter si déjà au centre
    end

    -- Synchroniser self.x et self.y pour les dessins
    self.x, self.y = self.body:getPosition()
end

function TestEnemy:draw()
    local camX, camY = Camera.i.x, Camera.i.y
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local drawX = self.x - camX + screenWidth / 2
    local drawY = self.y - camY + screenHeight / 2

    love.graphics.setColor(1, 0, 0) -- Set color to red
    love.graphics.circle("fill", drawX, drawY, self.radius)
    love.graphics.setColor(1, 1, 1) -- Reset color to white

    -- Dessiner la barre de vie
    local healthBarWidth = 100
    local healthBarHeight = 10
    local healthBarX = drawX - healthBarWidth / 2
    local healthBarY = drawY - self.radius - healthBarHeight
    love.graphics.setColor(1, 0, 0) -- Set color to red
    love.graphics.rectangle("fill", healthBarX, healthBarY, healthBarWidth, healthBarHeight)
    love.graphics.setColor(0, 1, 0) -- Set color to green
    love.graphics.rectangle(
        "fill",
        healthBarX,
        healthBarY,
        healthBarWidth * (self.health / self.maxHealth),
        healthBarHeight
    )
    love.graphics.setColor(1, 1, 1) -- Reset color to white
end

function TestEnemy:takeDamage(damage)
    damage = damage or 0
    self.health = self.health - damage
    if self.health <= 0 then
        self:destroy()
    end
end

function TestEnemy:destroy()
    State.gainExperience(100)
    self.fixture:destroy()
    GlobalState:removeEntity(self)
end

function TestEnemy:onCollision(entity)
    if entity.name ~= "player" then
        return
    end

    State.takeDamage(self.damage)
end

function TestEnemy:die()
    State.gainExperience(self.exp)
    self:destroy()
end

return TestEnemy

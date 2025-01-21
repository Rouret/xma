local Object = require("engine.object")
local GlobalState = require("game.state")
local FireZone = Object:extend()
local World = require("game.world")

function FireZone:new(params)
    params = params or {}

    if not params.x and not params.y then
        error("x and y parameters are required")
    end

    self.x = params.x or 0
    self.y = params.y or 0
    self.radius = params.radius or 100
    self.TTL = params.TTL or 1
    self.currentTTL = 0
    self.body = love.physics.newBody(World.world, self.x, self.y, "dynamic")
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.fixture:setUserData(self)
    self.fixture:setSensor(true)
    self.body:setBullet(true)

    return self
end

function FireZone:update(dt)
    self.currentTTL = self.currentTTL + dt
    if self.currentTTL >= self.TTL then
        return self:destroy()
    end
    self.radius = self.radius + 100 * dt
end

function FireZone:destroy()
    self.body:destroy()
    GlobalState:removeEntity(self)
end

function FireZone:draw()
    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(1, 1, 1, 1)
end

return FireZone

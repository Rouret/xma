local Object = require("engine.object")
local GlobalState = require("game.state")
local FireZone = Object:extend()
local World = require("game.world")

FireZone = Object:extend()
FireZone.__index = FireZone

function FireZone:new(params)
    local self = setmetatable({}, FireZone)
    params = params or {}

    if not params.x and not params.y then
        error("x and y parameters are required")
    end
    self.name = "FireZone"
    self.hasCollided = false
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

    self.particles =
        love.graphics.newParticleSystem(love.graphics.newImage("sprites/weapons/fireStaff/fire_particule.png"), 100)

    self.particles:setParticleLifetime(0.5, 1)
    self.particles:setSizeVariation(1)
    self.particles:setEmissionRate(10)
    self.particles:setLinearAcceleration(-40, -40, 40, 40)
    self.particles:setSpread(math.pi * 2)

    self.particles:setPosition(self.x, self.y)
    -- all the particles are emitted in différent zone on the radius
    self.particles:setEmissionArea("uniform", self.radius - 10, self.radius - 10)

    return self
end

function FireZone:update(dt)
    if self.body:isDestroyed() then
        return
    end
    self.particles:update(dt)
    self.currentTTL = self.currentTTL + dt
    if self.currentTTL >= self.TTL then
        return self:destroy()
    end
end

function FireZone:destroy()
    self.particles:stop()
    self.body:destroy()
    GlobalState:removeEntity(self)
end

function FireZone:draw()
    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.particles, 0, 0)
end

return FireZone

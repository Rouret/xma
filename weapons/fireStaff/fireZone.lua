local Object = require("engine.object")
local GlobalState = require("game.state")
local FireZone = Object:extend()
local World = require("game.world")

FireZone = Object:extend()
FireZone.__index = FireZone

-- distortion of the image
local shader =
    love.graphics.newShader(
    [[
    extern number time;
    extern number distortion;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
    {
        vec2 pos = vec2(texture_coords.x + sin(texture_coords.y * 10.0 + time) * distortion, texture_coords.y);
        return Texel(texture, pos) * color;
    }
]]
)

function FireZone:new(params)
    local self = setmetatable({}, FireZone)
    params = params or {}

    if not params.x and not params.y then
        error("x and y parameters are required")
    end

    self.name = "FireZone"
    self.type = "zone"
    self.from = "player"

    self.x = params.x or 0
    self.y = params.y or 0
    self.radius = params.radius or 100
    self.TTL = params.TTL or 1

    -- Size
    self.width = self.radius * 2
    self.height = self.radius * 2

    -- Damage
    self.damage = params.damage or 2
    self.currentDamageTick = 0
    self.damageTick = 0.2
    self.currentTTL = 0

    -- Image
    self.image = love.graphics.newImage("sprites/weapons/fireStaff/skill3_zone.png")

    -- Physics
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

    self.onContactWith = {}

    return self
end

function FireZone:update(dt)
    if self.body:isDestroyed() then
        return
    end

    self.currentDamageTick = self.currentDamageTick + dt

    if (self.currentDamageTick >= self.damageTick) then
        self.currentDamageTick = 0
        for i = #self.onContactWith, 1, -1 do
            local other = self.onContactWith[i]
            other:takeDamage(10)
            if not other:isAlive() then
                table.remove(self.onContactWith, i)
            end
        end
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
    love.graphics.setShader(shader)
    shader:send("time", love.timer.getTime())
    shader:send("distortion", 0.02)
    love.graphics.draw(self.image, self.x, self.y, 0, 1, 1, self.radius, self.radius)
    love.graphics.setShader()
    love.graphics.draw(self.particles, 0, 0)
end

function FireZone:onCollision(other)
    if other.name == "player" then
        return
    end

    if other.type and other.type == "bullet" then
        return
    end

    if other.takeDamage then
        other:takeDamage(10)
        if (other:isAlive()) then
            table.insert(self.onContactWith, other)
        end
    end
end

function FireZone:onEndCollision(other)
    for i = #self.onContactWith, 1, -1 do
        if self.onContactWith[i] == other then
            table.remove(self.onContactWith, i)
        end
    end
end

return FireZone

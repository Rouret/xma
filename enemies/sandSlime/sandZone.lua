local Object = require("engine.object")
local GlobalState = require("game.state")
local World = require("game.world")
local State = require("player.state")
local Effect = require("engine.effect")
local love = require("love")

---@class SandZone : Object
local SandZone = Object:extend()

function SandZone:new(params)
    params = params or {}

    if not params.x and not params.y then
        error("x and y parameters are required")
    end

    self.name = "SandZone"
    self.type = "zone"
    self.from = "player"

    self.x = params.x or 0
    self.y = params.y or 0

    -- Radius
    self.radius = 150 / 2

    -- Radius start with "startRadius" and grow to "maxRadius" in "raddiusTimeGrow" seconds
    self.maxRadius = 150 / 2
    self.startRadius = 50
    self.raddiusTimeGrow = 0.5 --second

    self.TTL = 5
    self.currentTTL = 0

    -- Size
    self.width = self.radius * 2
    self.height = self.radius * 2

    -- Image
    self.image = love.graphics.newImage("sprites/enemies/sand_slime/sand_zone.png")

    -- Physics
    self.body = love.physics.newBody(World.world, self.x, self.y, "dynamic")
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.fixture:setUserData(self)
    self.fixture:setSensor(true)
    self.body:setBullet(true)
    self.onContactWith = {}

    return self
end

function SandZone:update(dt)
    if self.body:isDestroyed() then
        return
    end

    if self.currentTTL < self.raddiusTimeGrow then
        local radiusGrowth = (self.maxRadius - self.startRadius) * (self.currentTTL / self.raddiusTimeGrow)
        self.radius = self.startRadius + radiusGrowth
        self.shape:setRadius(self.radius)
        self.width = self.radius * 2
        self.height = self.radius * 2
    else
        self.radius = self.maxRadius
        self.shape:setRadius(self.radius)
        self.width = self.radius * 2
        self.height = self.radius * 2
    end

    self.currentTTL = self.currentTTL + dt
    if self.currentTTL >= self.TTL then
        return self:destroy()
    end
end

function SandZone:destroy()
    self.body:destroy()
    GlobalState:removeEntity(self)
end

function SandZone:draw()
    love.graphics.draw(
        self.image,
        self.x,
        self.y,
        0,
        self.radius / (self.image:getWidth() / 2),
        self.radius / (self.image:getHeight() / 2),
        self.image:getWidth() / 2,
        self.image:getHeight() / 2
    )
end

function SandZone:onCollision(entity)
    if entity.name ~= "player" then
        return
    end

    if entity:hasEffect("sand_slow") then
        return
    end

    State.addEffect(
        Effect:new(
            {
                name = "sand_slow",
                duration = 2,
                UIName = "slowness",
                applyFunc = function(entity, effect)
                    effect.memo = entity.speed
                    entity.speed = entity.speed * 0.6
                end,
                removeFunc = function(entity, effect)
                    entity.speed = effect.memo
                end,
                actionFunc = function(entity, effect)
                    -- Nothing to do
                end
            }
        )
    )
end

function SandZone:onEndCollision(other)
end

return SandZone

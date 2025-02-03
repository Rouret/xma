local Object = require("engine.object")
local GlobalState = require("game.state")

local SandZone = Object:extend()
local World = require("game.world")
local State = require("player.state")

SandZone = Object:extend()
SandZone.__index = SandZone

function SandZone:new(params)
    local self = setmetatable({}, SandZone)
    params = params or {}

    if not params.x and not params.y then
        error("x and y parameters are required")
    end

    self.name = "SandZone"
    self.type = "zone"
    self.from = "player"

    self.x = params.x or 0
    self.y = params.y or 0
    self.radius = 150 / 2
    self.TTL = 10
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

    self.playerSpeedMemo = 0
    self.onContactWith = {}

    return self
end

function SandZone:update(dt)
    if self.body:isDestroyed() then
        return
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
    love.graphics.draw(self.image, self.x, self.y, 0, 1, 1, self.radius, self.radius)
end

function SandZone:onCollision(entity)
    if entity.name ~= "player" then
        return
    end

    self.playerSpeedMemo = State.speed

    State.speed = State.speed * 0.2
end

function SandZone:onEndCollision(other)
    State.speed = self.playerSpeedMemo
end

return SandZone

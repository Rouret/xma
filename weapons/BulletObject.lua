local GlobalState = require("game.state")
local World = require("game.world")
local State = require("player.state")
local Object = require("engine.object")

BulletObject = Object:extend()
BulletObject.__index = BulletObject

function BulletObject:new(params)
    local instance = setmetatable({}, self)
    instance:init(params)
    return instance
end

function BulletObject:init(params)
    params = params or {}

    if not params.imagePath then
        error("Sprite parameter is required")
    end

    if not params.name then
        error("Name parameter is required")
    end

    if not params.x or not params.y then
        error("Position parameters are required")
    end

    -- Events
    self.beforeDestroyEvent = params.beforeDestroy or self.emptyFunction()

    --General
    self.name = "BulletObject_" .. params.name

    -- TTL
    self.TTL = params.TTL or 1
    self.speed = params.speed or 1500
    self.currentTTL = 0

    -- Damage
    self.damage = params.damage or 10

    -- Transform
    self.direction = params.direction or State.getAngleToMouse()
    self.x = params.x
    self.y = params.y

    -- Sprite
    self.imageRatio = params.imageRatio or 1
    self.image = love.graphics.newImage(params.imagePath)
    local imageWidth, imageHeight = self.image:getDimensions()

    -- Body
    self.body = love.physics.newBody(World.world, self.x, self.y, "dynamic")
    self.shape = love.physics.newRectangleShape(imageWidth, imageHeight)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.fixture:setUserData(self)
    self.fixture:setSensor(true)
    self.body:setBullet(true)

    return self
end

-- Event

function BulletObject:beforeDestroy()
    if self.beforeDestroyEvent == nil then
        return
    end
    self.beforeDestroyEvent(self)
end

function BulletObject:ajusteRotation()
    return self.direction
end

-- Draw the gun
function BulletObject:draw()
    love.graphics.draw(self.image, self.x, self.y, self:ajusteRotation(), self.imageRatio, self.imageRatio, 0, 0)
end

function BulletObject:update(dt)
    -- Incrémenter le TTL
    self.currentTTL = self.currentTTL + dt
    if self.currentTTL >= self.TTL then
        self:destroy()
        return
    end

    -- Déplacer le body physique
    local dx = math.cos(self.direction) * self.speed * dt
    local dy = math.sin(self.direction) * self.speed * dt
    self.body:setPosition(self.body:getX() + dx, self.body:getY() + dy)

    -- Synchroniser les coordonnées logiques avec celles du body
    self.x, self.y = self.body:getPosition()
end

function BulletObject:takeDamage(damage)
end

function BulletObject:onCollision(entity)
    if entity.name == "player" then
        return
    end

    if string.match(entity.name, "BulletObject") then
        return
    end

    if entity.name == "wall" then
        self:destroy()
        return
    end

    entity:takeDamage(State.calcDamage(self.damage))
    self:destroy()
end

function BulletObject:destroy()
    self:beforeDestroy()
    self.body:destroy()
    GlobalState:removeEntity(self)
end

return BulletObject

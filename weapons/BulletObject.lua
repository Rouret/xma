local GlobalState = require("game.state")
local World = require("game.world")
local State = require("player.state")
local Object = require("engine.object")
local love = require("love")

---@class BulletObject : Object
BulletObject = Object:extend()
BulletObject.__index = BulletObject

function BulletObject:new(params)
    self:init(params)
    return self
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

    if not params.from then
        error("from parameter is required")
    end

    -- Events
    self.beforeDestroyEvent = params.beforeDestroy or self:nop()
    self.afterUpdateEvent = params.afterUpdate or self:nop()
    self.afterDrawEvent = params.afterDraw or self:nop()

    --General
    self.name = "BulletObject_" .. params.name
    self.type = "bullet"
    self.from = params.from

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

    -- Size
    self.width = imageWidth * self.imageRatio
    self.height = imageHeight * self.imageRatio

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

function BulletObject:afterUpdate(dt)
    if self.afterUpdateEvent == nil then
        return
    end
    self.afterUpdateEvent(self, dt)
end

function BulletObject:afterDraw()
    if self.afterDrawEvent == nil then
        return
    end
    self.afterDrawEvent(self)
end

function BulletObject:ajusteRotation()
    return self.direction
end

-- Draw the gun
function BulletObject:draw()
    love.graphics.draw(self.image, self.x, self.y, self:ajusteRotation(), self.imageRatio, self.imageRatio, 0, 0)
    self:afterDraw()
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

    self:afterUpdate(dt)
end

function BulletObject:takeDamage(damage)
end

function BulletObject:onCollision(entity)
    if entity.name == "player" then
        return
    end

    if entity.type and entity.type == "bullet" then
        return
    end

    if entity.type and entity.type == "zone" then
        return
    end

    if entity.type and entity.type == "wall" then
        self:destroy()
        return
    end

    entity:takeDamage(self.damage)
    self:destroy()
end

function BulletObject:isAlive()
    return self.currentTTL < self.TTL
end

function BulletObject:destroy()
    print("Destroying bullet")
    self:beforeDestroy()
    self.body:destroy()
    GlobalState:removeEntity(self)
end

return BulletObject

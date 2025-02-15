local World = require("game.world")
local Entity = require("engine.entity")
local DrawUtils = require("utils.draw")
local Config = require("config")
local love = require("love")

---@class Beacon : Entity
local Beacon = Entity:extend()

function Beacon:init(params)
    params = params or {}

    if not params.x or not params.y then
        error("Position parameters are required")
    end

    -- General
    self.name = "beacon"
    self.type = "wall"
    self.maxHealth = 1000
    self.health = 1000

    -- Transform
    self.x = params.x
    self.y = params.y

    -- Sprite
    self.image = love.graphics.newImage("sprites/items/beacon/beacon.png")
    local imageWidth, imageHeight = self.image:getDimensions()

    -- Size
    self.width = imageWidth
    self.height = imageHeight

    -- Body
    self.body = love.physics.newBody(World.world, self.x, self.y, "dynamic")
    self.shape = love.physics.newRectangleShape(imageWidth, imageHeight)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.fixture:setUserData(self)
    self.fixture:setSensor(false)
    self.body:setBullet(true)

    return self
end

function Beacon:update(dt)
    self.body:setPosition(self.x, self.y)
end

function Beacon:takeDamage(damage)
    self.health = self.health - damage
    if self.health <= 0 then
        if not Config.DEV_MODE then
            self:destroy()
        end
    end
end

function Beacon:draw()
    love.graphics.draw(self.image, self.x - self.width / 2, self.y - self.height / 2)
    DrawUtils.lifeBar(
        self.x - self.width / 2,
        self.y - self.height / 2 - 10,
        self.width,
        5,
        self.health,
        self.maxHealth
    )
end

function Beacon:destroy()
    self.body:destroy()
    -- end of the game close
    love.event.quit()
end

function Beacon:onCollision(entity)
    if entity.name == "Player" then
        return
    end

    -- Do not destroy zones
    if entity.type and entity.type == "zone" then
        return
    end
    -- Destroy player bullets
    if entity.type and entity.type == "bullet" and entity.from == "player" then
        entity:destroy()
    end

    return
end

return Beacon

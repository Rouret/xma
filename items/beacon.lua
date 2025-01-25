local World = require("game.world")
local Entity = require("engine.entity")
local Camera = require("engine.camera")

Beacon = Entity:extend()
Beacon.__index = Beacon

function Beacon:new(params)
    local instance = setmetatable({}, self)
    instance:init(params)
    return instance
end

function Beacon:init(params)
    params = params or {}

    if not params.x or not params.y then
        error("Position parameters are required")
    end

    -- Events

    -- General
    self.name = "Beacon"
    self.hasCollided = false

    -- Transform
    self.x = params.x
    self.y = params.y

    print("Beacon created at " .. self.x .. ", " .. self.y)

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

function Beacon:draw()
    love.graphics.draw(self.image, self.x - self.width / 2, self.y - self.height / 2)
end

function Beacon:destroy()
    self.body:destroy()
end

function Beacon:onCollision(entity)
    -- DETECT COLLISION
    if entity.name == "Player" then
        return
    end

    if entity.destroy then
        entity:destroy()
    end
end

return Beacon

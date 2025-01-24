local GlobalState = require("game.state")
local World = require("game.world")
local Object = require("engine.object")

Entity = Object:extend()
Entity.__index = Entity

function Entity:new(params)
    local instance = setmetatable({}, self)
    instance:init(params)
    return instance
end

function Entity:init(params)
    params = params or {}

    -- Mandatory parameters
    if not params.shape or not params.bodyType then
        error("Shape parameter is required")
    end

    -- Basic properties
    self.name = params.name or "Unnamed Entity"
    self.x = params.x or 0
    self.y = params.y or 0

    -- Size
    self.width = params.width or 0
    self.height = params.height or 0

    -- Physics
    self.body = love.physics.newBody(World.world, self.x, self.y, params.bodyType)
    self.shape = params.shape
    self.fixture = love.physics.newFixture(self.body, self.shape)

    return self
end

function Entity:onCollision(entity)
    error("onCollision method not implemented")
end

function Entity:update(dt, world)
    error("update method not implemented")
end

function Entity:draw()
    error("draw method not implemented")
end

function Entity:destroy()
    self.body:destroy()
    GlobalState:removeEntity(self)
end

return Entity

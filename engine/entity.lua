local GlobalState = require("game.state")
local World = require("game.world")

Entity = {}
Entity.__index = Entity

function Entity:init(params)
    params = params or {}
    local self = setmetatable({}, Entity)

    -- Mandatory parameters
    if not params.shape or not params.bodyType then
        error("Shape parameter is required")
    end

    -- Basic properties
    self.name = params.name or "Unnamed Entity"
    self.x = params.x or 0
    self.y = params.y or 0

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

function Entity:extend()
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end
    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)
    return cls
end

return Entity

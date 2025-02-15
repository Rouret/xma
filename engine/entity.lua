local GlobalState = require("game.state")
local World = require("game.world")
local Object = require("engine.object")
local love = require("love")

---@class Entity : Object
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
    self.type = "entity"
    self.x = params.x or 0
    self.y = params.y or 0

    -- Size
    self.width = params.width or 0
    self.height = params.height or 0

    -- Physics
    self.body = love.physics.newBody(World.world, self.x, self.y, params.bodyType)
    self.shape = params.shape
    self.fixture = love.physics.newFixture(self.body, self.shape)

    -- Collision
    self.noCollisionWith = params.noCollisionWith or {}

    -- Effects
    self.effects = {}

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

function Entity:isAlive()
    error("draw method not implemented")
end

function Entity:addEffect(effect)
    local existingEffect = nil
    for _, e in ipairs(self.effects) do
        if e.name == effect.name then
            existingEffect = e
            break
        end
    end

    if existingEffect then
        existingEffect.duration = math.max(existingEffect.duration, effect.duration)
    else
        table.insert(self.effects, effect)
        effect:apply(self)
    end
end

function Entity:updateEffects(dt)
    for i = #self.effects, 1, -1 do
        local effect = self.effects[i]
        if not effect:update(dt, self) then
            table.remove(self.effects, i)
        end
    end
end

function Entity:hasEffect(effectName)
    for _, effect in ipairs(self.effects) do
        if effect.name == effectName then
            return true
        end
    end
    return false
end

function Entity:destroy()
    if not self.body:isDestroyed() then
        self.body:destroy()
    end
    GlobalState:removeEntity(self)
end

return Entity

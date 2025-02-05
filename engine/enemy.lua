local Entity = require("engine.entity")

local Enemy = Entity:extend()
Enemy.__index = Enemy

function Enemy:new(params)
    local instance = setmetatable({}, self)
    instance:init(params)
    return instance
end

function Enemy:init(params)
    params = params or {}

    if not params.shape or not params.bodyType then
        error("Shape parameter is required")
    end
    if params.haveDeathAnimation and not params.deathAnimation then
        error("Death animation is required")
    end

    -- Appelle Entity.init avec les paramètres modifiés
    Entity.init(self, params)

    -- Propriétés de base
    self.name = params.name or "Unnamed Enemy"
    self.health = params.health or 100
    self.maxHealth = params.maxHealth or 100
    self.speed = params.speed or 200
    self.damage = params.damage or 10
    self.exp = params.exp or 10

    -- Animation de mort
    self.deathAnimation = params.deathAnimation or nil
    self.deathTick = 0
end

function Enemy:takeDamage(damage)
    self.health = self.health - damage
    if self.health <= 0 then
        self:die()
    end
end

function Enemy:update(dt)
    if self.deathAnimation and self.health <= 0 then
        self.deathTick = self.deathTick + dt
        if self.deathTick >= self.deathAnimation.totalDuration then
            self:realDie()
        else
            self.deathAnimation:update(dt)
        end
    else
        self:u(dt) -- Méthode à implémenter par les sous-classes
    end
end

function Enemy:u(dt)
    error("Enemy: u(update) method not implemented")
end

function Enemy:d()
    error("Enemy: d(draw) method not implemented")
end

function Enemy:drawDeathAnimation()
    error("Enemy: d(draw) method not implemented")
end

function Enemy:draw()
    if self.deathAnimation and self.health <= 0 then
        self:drawDeathAnimation()
    else
        self:d()
    end
end

function Enemy:die()
    self:beforeDie()
    if self.deathAnimation then
        self.body:destroy()
    else
        self:realDie()
    end
end

function Enemy:realDie()
    self:beforeRealDie()
    self:destroy()
end

function Enemy:beforeDie()
    -- Override this method
end

function Enemy:beforeRealDie()
    -- Override this method
end

function Enemy:isAlive()
    return self.health > 0
end

return Enemy

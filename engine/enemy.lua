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

    -- Appelle Entity.init avec les paramètres modifiés
    Entity.init(self, params)

    -- Propriétés de base
    self.name = params.name or "Unnamed Enemy"
    self.health = params.health or 100
    self.maxHealth = params.maxHealth or 100
    self.speed = params.speed or 200
    self.damage = params.damage or 10
    self.exp = params.exp or 10
    self.status = "moving" --by default all enemies are moving

    self.zindex = 10

    -- Animation de mort

    -- Bool pour simplifier les écritures conditionnelles
    self.haveDeathAnimation = params.deathDuration or false
    self.deathDuration = params.deathDuration or 0
    self.deathTick = 0

    return self
end

function Enemy:takeDamage(damage)
    self.health = self.health - damage
    if self.health <= 0 then
        self:die()
    end
end

function Enemy:update(dt)
    if self:isInDeathAnimation() then
        self.deathTick = self.deathTick + dt
        if self.deathTick >= self.deathDuration then
            self:realDie()
        else
            self:updateDeathAnimation(dt)
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
    error("Enemy: drawDeathAnimation method not implemented")
end

function Enemy:updateDeathAnimation(dt)
    error("Enemy: updateDeathAnimation method not implemented")
end

function Enemy:draw()
    if self:isInDeathAnimation() then
        self:drawDeathAnimation()
    else
        self:d()
    end
end

function Enemy:die()
    self:beforeDie()
    if self.haveDeathAnimation then
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

function Enemy:isInDeathAnimation()
    return not self:isAlive() and self.haveDeathAnimation
end

return Enemy

local Entity = require("engine.entity")

local Enemy = Entity:extend()

function Enemy:init(params)
    params = params or {}
    if not params.shape or not params.bodyType then
        error("Shape parameter is required")
    end
    params.name = params.name or "Unnamed Enemy"
    params.x = params.x or 0
    params.y = params.y or 0
    params.shape = params.shape
    params.bodyType = params.bodyType

    -- Appelle Entity.init avec les paramètres modifiés
    Entity.init(self, params)
    self.hasCollided = true
    -- Ajoute des propriétés spécifiques à Enemy
    self.health = params.health or 100
    self.speed = params.speed or 200
    self.maxHealth = params.maxHealth or 100
    self.radius = params.radius or 50
    self.damage = params.damage or 10
    self.exp = params.exp or 10

    return self
end

function Enemy:takeDamage(damage)
    self.health = self.health - damage
    if self.health <= 0 then
        self:die()
    end
end

function Enemy:isAlive()
    return self.health > 0
end

return Enemy

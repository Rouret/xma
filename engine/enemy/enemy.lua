local Entity = require("engine.entity")
local StateMachine = require("engine.stateMachine")
local GlobalState = require("game.state")
local State = require("player.state")
local Map = require("engine.map.map")

---@class Enemy : Entity
local Enemy = Entity:extend()
Enemy.__index = Enemy

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
    self.target = params.target or "player"
    self.enemiesType = params.enemiesType or "B"
    self.type = "enemy"

    -- Wave multiplier
    self.health = self.health * (params.healthMultiplier or 1)
    self.speed = self.speed * (params.speedMultiplier or 1)
    self.damage = self.damage * (params.damageMultiplier or 1)

    -- Gestion de la mort
    self.haveDeathAnimation = params.deathDuration or false
    self.deathDuration = params.deathDuration or 0
    self.deathTick = 0

    -- Ajout de la State Machine
    self.stateMachine = StateMachine:new({})

    self.stateMachine:change("moving")
end

function Enemy:getTargetPosition()
    if self.target == "player" then
        return State.x, State.y
    end

    if self.target == "beacon" then
        return Map.beacon.x, Map.beacon.y
    end
end

function Enemy:moveToTarget()
    local targetX, targetY = self:getTargetPosition()

    -- Déplacement vers le joueur
    local dx = targetX - self.body:getX()
    local dy = targetY - self.body:getY()
    local distance = math.sqrt(dx ^ 2 + dy ^ 2)

    if distance > 0 then
        local velocityX = (dx / distance) * self.speed
        local velocityY = (dy / distance) * self.speed
        self.body:setLinearVelocity(velocityX, velocityY)
    else
        self.body:setLinearVelocity(0, 0)
    end

    self.x, self.y = self.body:getPosition()
end

function Enemy:takeDamage(damage)
    self.health = self.health - damage

    if self.health <= 0 then
        self:die()
    end
end

function Enemy:update(dt)
    self.stateMachine:update(dt)
end

function Enemy:draw()
    self.stateMachine:draw()
end

function Enemy:die()
    self.stateMachine:change("dead")
end

function Enemy:destroy()
    if self.body and not self.body:isDestroyed() then
        self.body:destroy()
    end
    GlobalState:removeEntity(self)
end

return Enemy

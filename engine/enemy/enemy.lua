local Entity = require("engine.entity")
local StateMachine = require("engine.stateMachine")
local GlobalState = require("game.state")

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
    self.type = "enemie"

    -- Gestion de la mort
    self.haveDeathAnimation = params.deathDuration or false
    self.deathDuration = params.deathDuration or 0
    self.deathTick = 0

    -- Ajout de la State Machine
    self.stateMachine =
        StateMachine:new(
        {
            idle = {
                enter = function()
                    self.body:setLinearVelocity(0, 0)
                end,
                update = function(_, dt)
                end,
                draw = function()
                end
            },
            moving = {
                enter = function()
                end,
                update = function(_, dt)
                    self:u(dt)
                end,
                draw = function()
                    self:d()
                end
            },
            dead = {
                enter = function()
                    self.body:setLinearVelocity(0, 0)
                    if self.haveDeathAnimation then
                        self.deathTick = 0
                    else
                        self:destroy()
                    end
                end,
                update = function(_, dt)
                    if self.haveDeathAnimation then
                        self.deathTick = self.deathTick + dt
                        if self.deathTick >= self.deathDuration then
                            self:destroy()
                        else
                            self:updateDeathAnimation(dt)
                        end
                    end
                end,
                draw = function()
                    if self.haveDeathAnimation then
                        self:drawDeathAnimation()
                    end
                end
            }
        }
    )

    self.stateMachine:change("moving")
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

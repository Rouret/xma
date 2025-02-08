local Enemy = require("engine.enemy.enemy")
local anim8 = require("engine.anim8")
local IceBullet = require("enemies.iceSlime.icebullet")
local State = require("player.state")
local GlobalState = require("game.state")

local IceSlime = Enemy:extend()
IceSlime.__index = IceSlime

function IceSlime:init(params)
    params = params or {}
    params.name = "IceSlime"
    params.shape = love.physics.newRectangleShape(45, 45)
    params.bodyType = "dynamic"
    params.speed = 100
    params.health = 1
    params.maxHealth = 1

    -- Chargement des sprites
    self.movementSpriteSheet = love.graphics.newImage("sprites/enemies/ice_slime/ice_slime_move.png")
    self.attackSpriteSheet = love.graphics.newImage("sprites/enemies/ice_slime/ice_slime_attacking.png")

    -- Création des animations
    local movementgAnimationGrid =
        anim8.newGrid(45, 45, self.movementSpriteSheet:getWidth(), self.movementSpriteSheet:getHeight())
    self.movementAnimation = anim8.newAnimation(movementgAnimationGrid("1-4", 1), 0.15)

    local attackAnimationGrid =
        anim8.newGrid(45, 45, self.attackSpriteSheet:getWidth(), self.attackSpriteSheet:getHeight())
    self.attackAnimation = anim8.newAnimation(attackAnimationGrid("1-4", 1), 0.5 / 4)

    Enemy.init(self, params)

    -- Configuration physique
    self.fixture:setUserData(self)
    self.fixture:setSensor(true)
    self.body:setBullet(true)

    -- Stats de combat
    self.range = 350
    self.cooldown = 1
    self.castTime = 0.5
    self.damage = 1

    -- Ajout des états spécifiques à IceSlime
    self.stateMachine.states["moving"] = {
        enter = function()
        end,
        update = function(_, dt)
            local dx = State.x - self.body:getX()
            local dy = State.y - self.body:getY()
            local distance = math.sqrt(dx ^ 2 + dy ^ 2)

            if distance < self.range then
                self.stateMachine:change("attacking")
                return
            end

            local velocityX = (dx / distance) * self.speed
            local velocityY = (dy / distance) * self.speed
            self.body:setLinearVelocity(velocityX, velocityY)
            self.movementAnimation:update(dt)

            self.x, self.y = self.body:getPosition()
        end,
        draw = function()
            self.movementAnimation:draw(self.movementSpriteSheet, self.x, self.y, 0, 1, 1, 22.5, 22.5)
        end
    }

    self.stateMachine.states["attacking"] = {
        enter = function()
            self.castTimer = 0
            self.body:setLinearVelocity(0, 0)
        end,
        update = function(_, dt)
            self.castTimer = self.castTimer + dt
            if self.castTimer >= self.castTime then
                self.castTimer = 0
                local dx = State.x - self.body:getX()
                local dy = State.y - self.body:getY()
                GlobalState:addEntity(
                    IceBullet:new(
                        {
                            damage = self.damage,
                            x = self.x,
                            y = self.y,
                            speed = 900,
                            TTL = 0.75,
                            from = "ice_slime",
                            direction = math.atan2(dy, dx)
                        }
                    )
                )
                self.stateMachine:change("moving")
            end
            self.attackAnimation:update(dt)
        end,
        draw = function()
            self.attackAnimation:draw(self.attackSpriteSheet, self.x, self.y, 0, 1, 1, 22.5, 22.5)
        end
    }

    self.stateMachine:change("moving")
end

function IceSlime:onCollision(entity)
    if entity.name == "player" then
        entity:takeDamage(self.damage)
    end
end

return IceSlime

local Enemy = require("engine.enemy.enemy")
local anim8 = require("engine.anim8")
local State = require("player.state")
local World = require("game.world")
local SandZone = require("enemies.sandSlime.sandZone")
local GlobalState = require("game.state")

local SandSlime = Enemy:extend()
SandSlime.__index = SandSlime

function SandSlime:init(params)
    params = params or {}
    params.name = "SandSlime"
    params.shape = love.physics.newRectangleShape(45, 45)
    params.bodyType = "dynamic"
    params.speed = 100
    params.health = 1
    params.maxHealth = 1

    -- Chargement des sprites
    self.image = love.graphics.newImage("sprites/enemies/sand_slime/sand_slime.png")
    self.deathImage = love.graphics.newImage("sprites/enemies/sand_slime/sand_slime_death.png")

    -- Création des animations
    local movementAnimationGrid = anim8.newGrid(45, 45, self.image:getWidth(), self.image:getHeight())
    self.movementAnimation = anim8.newAnimation(movementAnimationGrid("1-5", 1), 0.15)

    local deathAnimationGrid = anim8.newGrid(60, 45, self.deathImage:getWidth(), self.deathImage:getHeight())
    self.deathAnimation = anim8.newAnimation(deathAnimationGrid("1-6", 1), 0.08)

    params.deathDuration = self.deathAnimation.totalDuration

    Enemy.init(self, params)

    -- Configuration physique
    self.fixture:setUserData(self)
    self.fixture:setSensor(true)
    self.body:setBullet(true)

    -- Ajout des états spécifiques à SandSlime
    self.stateMachine.states["moving"] = {
        enter = function()
        end,
        update = function(_, dt)
            self.movementAnimation:update(dt)

            -- Déplacement vers le joueur
            local dx = State.x - self.body:getX()
            local dy = State.y - self.body:getY()
            local distance = math.sqrt(dx ^ 2 + dy ^ 2)

            if distance > 0 then
                local velocityX = (dx / distance) * self.speed
                local velocityY = (dy / distance) * self.speed
                self.body:setLinearVelocity(velocityX, velocityY)
            else
                self.body:setLinearVelocity(0, 0)
            end

            -- Synchronisation position
            self.x, self.y = self.body:getPosition()
        end,
        draw = function()
            self.movementAnimation:draw(self.image, self.x, self.y, 0, 1, 1, 22.5, 22.5)
        end
    }

    self.stateMachine.states["dead"] = {
        enter = function()
            -- Arrêter tout mouvement
            self.body:setLinearVelocity(0, 0)

            -- Ajouter la zone de sable après un délai
            table.insert(
                World.delayCallbacks,
                function()
                    GlobalState:addEntity(
                        SandZone:new(
                            {
                                x = self.x,
                                y = self.y
                            }
                        )
                    )
                end
            )

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
                    self.deathAnimation:update(dt)
                end
            end
        end,
        draw = function()
            self.deathAnimation:draw(self.deathImage, self.x, self.y, 0, 1, 1, 30, 22.5)
        end
    }

    self.stateMachine:change("moving")
end

function SandSlime:onCollision(entity)
    if entity.name == "player" then
        entity.takeDamage(self.damage)
    end
end

return SandSlime

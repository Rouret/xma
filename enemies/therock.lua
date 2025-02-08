local Enemy = require("engine.enemy.enemy")
local anim8 = require("engine.anim8")
local State = require("player.state")
local World = require("game.world")

local TheRock = Enemy:extend()
TheRock.__index = TheRock

function TheRock:init(params)
    params = params or {}
    params.name = "TheRock"
    params.radius = 32
    params.shape = love.physics.newCircleShape(params.radius)
    params.bodyType = "dynamic"
    params.width = params.radius * 2
    params.height = params.radius * 2
    params.health = 1
    params.maxHealth = 1
    params.deathDuration = 1 -- Durée de l'animation de mort

    Enemy.init(self, params)

    -- Chargement du sprite et animation
    self.image = love.graphics.newImage("sprites/enemies/therock/therock.png")
    local grid = anim8.newGrid(64, 64, self.image:getWidth(), self.image:getHeight())
    self.animation = anim8.newAnimation(grid("1-9", 1), 0.07)

    -- Configuration physique
    self.fixture:setUserData(self)
    self.fixture:setSensor(true)
    self.body:setBullet(true)

    -- Particules de mort
    self.particles =
        love.graphics.newParticleSystem(love.graphics.newImage("sprites/enemies/therock/particle.png"), 100)
    self.particles:setParticleLifetime(0.175, 0.35)
    self.particles:setSizeVariation(1)
    self.particles:setLinearAcceleration(-50, -50, 50, 50)
    self.particles:setSpeed(500, 700)
    self.particles:setSpread(math.pi * 2)
    self.particles:setEmissionArea("uniform", 10, 10)
    self.particles:setSizes(2, 1, 0.25)

    -- Ajout des états spécifiques à TheRock
    self.stateMachine.states["moving"] = {
        enter = function()
        end,
        update = function(_, dt)
            self.animation:update(dt)

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

            self.x, self.y = self.body:getPosition()
        end,
        draw = function()
            local dx = State.x - self.x
            local dy = State.y - self.y
            local angle = math.atan2(dy, dx)

            -- Determine the direction to flip the animation
            local scaleX = (self.x > State.x) and -1 or 1

            self.animation:draw(self.image, self.x, self.y, angle, scaleX, 1, 32, 32)
        end
    }

    self.stateMachine.states["dead"] = {
        enter = function()
            self.body:setLinearVelocity(0, 0)
            self.particles:emit(20)
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
                    self.particles:update(dt)
                end
            end
        end,
        draw = function()
            love.graphics.draw(self.particles, self.x, self.y)
        end
    }

    self.stateMachine:change("moving")
end

function TheRock:onCollision(entity)
    if entity.name == "player" then
        self:die()
    end
end

return TheRock

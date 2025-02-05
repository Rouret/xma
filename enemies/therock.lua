local State = require("player.state")
local Enemy = require("engine.enemy")
local anim8 = require("engine.anim8")
local TheRock = Enemy:extend()
TheRock.__index = TheRock

function TheRock:init(params)
    params = params or {}
    params.radius = 32
    params.shape = love.physics.newCircleShape(params.radius)
    params.bodyType = "dynamic"
    params.width = params.radius * 2
    params.height = params.radius * 2
    Enemy.init(self, params)

    self.image = love.graphics.newImage("sprites/enemies/therock/therock.png")
    -- c'est du 64x64 avec 3 frame sur le meme ligne
    local g = anim8.newGrid(64, 64, self.image:getWidth(), self.image:getHeight())
    self.animation = anim8.newAnimation(g("1-9", 1), 0.07)

    self.fixture:setUserData(self)
    self.fixture:setSensor(true)
    self.body:setBullet(true)

    -- death
    self.deathTTL = 0.35
    self.deathCurrent = 0

    -- particules of rock
    self.particles =
        love.graphics.newParticleSystem(love.graphics.newImage("sprites/enemies/therock/particle.png"), 100)
    self.particles:setParticleLifetime(self.deathTTL / 2, self.deathTTL)
    self.particles:setSizeVariation(1)
    self.particles:setLinearAcceleration(-50, -50, 50, 50)
    self.particles:setSpeed(500, 700)
    self.particles:setSpread(math.pi * 2)
    self.particles:setEmissionArea("uniform", 10, 10)
    self.particles:setSizes(2, 1, 0.25)

    self.hasCollided = false

    return self
end

function TheRock:u(dt)
    self.animation:update(dt)

    -- Calculer la direction vers le joueur
    local dx = State.x - self.body:getX()
    local dy = State.y - self.body:getY()
    local distance = math.sqrt(dx ^ 2 + dy ^ 2)

    if distance > 0 then
        local velocityX = (dx / distance) * self.speed
        local velocityY = (dy / distance) * self.speed
        self.body:setLinearVelocity(velocityX, velocityY)
    else
        self.body:setLinearVelocity(0, 0) -- Arrêter si déjà au centre
    end

    -- Synchroniser self.x et self.y pour les dessins
    self.x, self.y = self.body:getPosition()
    self.particles:update(dt)
    if self.hasCollided then
        self.deathCurrent = self.deathCurrent + dt
        if self.deathCurrent >= self.deathTTL then
            self:die()
        end
    end
end

function TheRock:d()
    local dx = State.x - self.x
    local dy = State.y - self.y
    local angle = math.atan2(dy, dx)

    -- Determine the direction to flip the animation
    local scaleX = 1
    if self.x > State.x then
        scaleX = -1
    end

    -- Draw particles
    if not self.hasCollided then
        self.animation:draw(self.image, self.x, self.y, angle, scaleX, 1, 32, 32)
        return
    end

    self.particles:setPosition(self.x, self.y)
    love.graphics.draw(self.particles, self.x, self.y)
end

function TheRock:onCollision(entity)
    if self.hasCollided then
        return
    end

    if entity.name ~= "player" then
        return
    end

    self.hasCollided = true
    self.particles:emit(20)
end

return TheRock

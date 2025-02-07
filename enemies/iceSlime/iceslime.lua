local State = require("player.state")
local Enemy = require("engine.enemy")
local anim8 = require("engine.anim8")

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

    -- Chargement des images
    self.image = love.graphics.newImage("sprites/enemies/ice_slime/ice_slime_move.png")

    -- Création des animations
    local movementgAnimationGrid = anim8.newGrid(45, 45, self.image:getWidth(), self.image:getHeight())
    self.movementAnimation = anim8.newAnimation(movementgAnimationGrid("1-4", 1), 0.15)

    -- Initialisation de l'ennemi avec les paramètres
    Enemy.init(self, params)

    -- Configuration physique
    self.fixture:setUserData(self)
    self.fixture:setSensor(true)
    self.body:setBullet(true)

    return self
end

function IceSlime:u(dt)
    self.movementAnimation:update(dt)

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
end

function IceSlime:d()
    self.movementAnimation:draw(self.image, self.x, self.y, 0, 1, 1, 22.5, 22.5)
end

function IceSlime:onCollision(entity)
    if entity.name ~= "player" then
        return
    end

    entity.takeDamage(self.damage)
end

return IceSlime

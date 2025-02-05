local State = require("player.state")
local Enemy = require("engine.enemy")
local anim8 = require("engine.anim8")
local World = require("game.world")
local SandZone = require("enemies.sandSlime.sandZone")

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

    -- Chargement des images
    self.image = love.graphics.newImage("sprites/enemies/sand_slime/sand_slime.png")
    self.deathImage = love.graphics.newImage("sprites/enemies/sand_slime/sand_slime_death.png")

    -- Création des animations
    local grid = anim8.newGrid(45, 45, self.image:getWidth(), self.image:getHeight())
    self.animation = anim8.newAnimation(grid("1-5", 1), 0.15)

    local deathGrid = anim8.newGrid(60, 45, self.deathImage:getWidth(), self.deathImage:getHeight())
    params.deathAnimation = anim8.newAnimation(deathGrid("1-6", 1), 0.08)

    -- Initialisation de l'ennemi avec les paramètres
    Enemy.init(self, params)

    -- Configuration physique
    self.fixture:setUserData(self)
    self.fixture:setSensor(true)
    self.body:setBullet(true)

    return self
end

function SandSlime:u(dt)
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
end

function SandSlime:beforeDie()
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
end

function SandSlime:d()
    self.animation:draw(self.image, self.x, self.y, 0, 1, 1, 22.5, 22.5)
end

function SandSlime:drawDeathAnimation()
    self.deathAnimation:draw(self.deathImage, self.x, self.y, 0, 1, 1, 30, 22.5)
end

function SandSlime:onCollision(entity)
    if entity.name ~= "player" then
        return
    end

    entity.takeDamage(self.damage)
end

return SandSlime

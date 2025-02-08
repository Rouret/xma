local State = require("player.state")
local Enemy = require("engine.enemy")
local anim8 = require("engine.anim8")
local IceBullet = require("enemies.iceSlime.icebullet")
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

    -- Chargement des images
    self.movementSpriteSheet = love.graphics.newImage("sprites/enemies/ice_slime/ice_slime_move.png")
    self.attackSpriteSheet = love.graphics.newImage("sprites/enemies/ice_slime/ice_slime_attacking.png")

    -- Création des animations
    local movementgAnimationGrid =
        anim8.newGrid(45, 45, self.movementSpriteSheet:getWidth(), self.movementSpriteSheet:getHeight())
    self.movementAnimation = anim8.newAnimation(movementgAnimationGrid("1-4", 1), 0.15)

    local attackAnimationGrid =
        anim8.newGrid(45, 45, self.attackSpriteSheet:getWidth(), self.attackSpriteSheet:getHeight())
    self.attackAnimation = anim8.newAnimation(attackAnimationGrid("1-4", 1), 0.5 / 4)

    -- Initialisation de l'ennemi avec les paramètres
    Enemy.init(self, params)

    -- Attack
    self.range = 350
    -- CD
    self.cooldown = 1
    self.cooldownTimer = 0
    -- Cast time
    self.castTime = 0.5
    self.castTimer = 0
    -- Damage
    self.damage = 1

    -- Configuration physique
    self.fixture:setUserData(self)
    self.fixture:setSensor(true)
    self.body:setBullet(true)

    return self
end

function IceSlime:u(dt)
    -- Calculer la direction vers le joueur
    local dx = State.x - self.body:getX()
    local dy = State.y - self.body:getY()
    local distance = math.sqrt(dx ^ 2 + dy ^ 2)

    if self.status == "attacking" then
        self.attackAnimation:update(dt)
        self.castTimer = self.castTimer + dt
        if self.castTimer >= self.castTime then
            self.castTimer = 0
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
            self.status = "moving"
        end
        return
    end

    if distance > self.range then
        self.status = "moving"
        self.movementAnimation:update(dt)
        local velocityX = (dx / distance) * self.speed
        local velocityY = (dy / distance) * self.speed
        self.body:setLinearVelocity(velocityX, velocityY)
    else
        self.body:setLinearVelocity(0, 0)
        self.status = "attacking"
    end

    -- Synchroniser self.x et self.y pour les dessins
    self.x, self.y = self.body:getPosition()
end

function IceSlime:d()
    if self.status == "moving" then
        print("moving draw")
        self.movementAnimation:draw(self.movementSpriteSheet, self.x, self.y, 0, 1, 1, 22.5, 22.5)
    end

    if self.status == "attacking" then
        print("attacking draw")
        self.attackAnimation:draw(self.attackSpriteSheet, self.x, self.y, 0, 1, 1, 22.5, 22.5)
    end
end

function IceSlime:onCollision(entity)
    if entity.name ~= "player" then
        return
    end

    entity.takeDamage(self.damage)
end

return IceSlime

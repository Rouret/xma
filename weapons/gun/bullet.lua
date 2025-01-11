local GlobalState = require("game.state")
local World = require("game.world")

local Bullet = {}
Bullet.__index = Bullet

function Bullet.new(params)
    local self = setmetatable({}, Bullet)
    self.name = "bullet"
    self.TTL = 1
    self.speed = 1500
    self.currentTTL = 0
    self.damage = params.damage
    self.direction = params.direction
    self.x = params.x
    self.y = params.y
    self.body = love.physics.newBody(World.world, self.x, self.y, "dynamic") -- Corps statique
    self.shape = love.physics.newRectangleShape(8, 8) -- Forme rectangulaire
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.image = love.graphics.newImage("sprites/bullet.png")

    self.fixture:setUserData(self)
    self.fixture:setSensor(true)

    return self
end

-- Draw the gun
function Bullet:draw()
    love.graphics.draw(self.image, self.x, self.y, self.direction + math.pi/2, 4, 4, 0, 0)
end

function Bullet:update(dt)
    -- Incrémenter le TTL
    self.currentTTL = self.currentTTL + dt
    if self.currentTTL >= self.TTL then
        -- Supprimer la balle
        GlobalState:removeEntity(self)
        self.body:destroy()
        return
    end

    -- Déplacer le body physique
    local dx = math.cos(self.direction) * self.speed * dt
    local dy = math.sin(self.direction) * self.speed * dt
    self.body:setPosition(self.body:getX() + dx, self.body:getY() + dy)

    -- Synchroniser les coordonnées logiques avec celles du body
    self.x, self.y = self.body:getPosition()
end

function Bullet:takeDamage(damage)
    -- Les balles ne peuvent pas prendre de dégâts
    self:destroy()
end

function Bullet:onCollision(entity)
    -- TODO fix fire position
    if entity.name == "player" or entity.name == "bullet" then
        return
    end

    entity:takeDamage(self.damage)
    self:destroy()
end


function Bullet:destroy()
    GlobalState:removeEntity(self)
    self.body:destroy()
end

return Bullet

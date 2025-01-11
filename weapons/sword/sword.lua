local Skills = require("skills")
local GlobalState = require("game.state")
local Bullet = require("weapons.gun.bullet")
local State = require("player.state")
local Timer = require("timer")
local World = require("game.world")

local Sword = {}
Sword.__index = Sword

function Sword.new()
    local self = setmetatable({}, Sword)
    self.name = "Sword"
    self.skills = {
        Skills.new({
            name = "Front hit",
            cooldown = 0.5,
            damage = 10,
            effect = function()
                
            end
        }),
        Skills.new({
            name = "Slash",
            cooldown = 0.5,
            damage = 10,
            effect = function()
             
            end
        }),
        Skills.new({
            name = "Spin",
            cooldown = 0.5,
            damage = 10,
            effect = function()
             
            end
        }),
    }
    self.image = love.graphics.newImage("sprites/weapons/sword/sword.png")
    local imageWidth, imageHeight = self.image:getDimensions()

    self.originX = imageWidth / 2
    self.originY = imageHeight
    
    self.body = love.physics.newBody(World.world, self.x, self.y, "dynamic") -- Corps dynamique
    self.shape = love.physics.newRectangleShape(imageWidth, imageHeight) -- Forme rectangulaire de la taille de l'image
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData(self)
    self.fixture:setSensor(true)
    self.body:setBullet(true)

    return self
end


-- Draw the Sword
function Sword:draw()
    -- Check if weapon is in hand or back
    if State.isWeaponEquipped(self.name) then
        self:drawInHand(State.x, State.y)
    else
        self:drawInBack()
    end
  
end

-- Draw Sword in hand 
function Sword:drawInHand(x,y)
    local rotation = State.getAngleToMouse() + math.pi / 2;  
    love.graphics.draw(self.image, x + 10, y + 10, rotation, 2, 2, 0,0)
end

-- Draw Sword in the back
function Sword:drawInBack()
  
end
return Sword

local Skills = require("skills")
local GlobalState = require("game.state")
local Bullet = require("weapons.gun.bullet")
local State = require("player.state")

local Gun = {}
Gun.__index = Gun

function Gun.new()
    local self = setmetatable({}, Gun)
    self.name = "Gun"
    self.skills = {
        Skills.new("Shoot", 0.5, function()
            print("Gun: Shoot")
            GlobalState:addEntity(Bullet.new(State.x, State.y, State.getAngleToMouse()))
        end),
        Skills.new("Reload", 2, function()
            print("Gun: Reload")
        end),
        Skills.new("Aim Boost", 1, function()
            print("Gun: Aim Boost")
        end),
    }
    self.image = love.graphics.newImage("sprites/gun.png")
    return self
end

-- Draw the gun
function Gun:draw()
    -- Check if weapon is in hand or back
    if State.isWeaponEquipped(self.name) then
        self:drawInHand(State.x, State.y, State.getAngleForGun())
    else
        self:drawInBack()
    end
  
end

-- Draw gun in hand 
function Gun:drawInHand(x,y,rotation)
    love.graphics.draw(self.image, x, y, rotation, 1, 1, 0, 0)
end

-- Draw gun in the back
function Gun:drawInBack()
  
end

return Gun

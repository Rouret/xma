local Skills = require("skills")
local State = require("player.state")
local Sword = {}
Sword.__index = Sword

function Sword.new()
    local self = setmetatable({}, Sword)
    self.name = "Sword"
    self.skills = {
        Skills.new({
            name = "Slash",
            cooldown = 0.5,
            damage = 10,
            effect = function()
             
            end
        }),
        Skills.new({
            name = "Slash 2",
            cooldown = 0.5,
            damage = 10,
            effect = function()
             
            end
        }),
        Skills.new({
            name = "Slash 3",
            cooldown = 0.5,
            damage = 10,
            effect = function()
             
            end
        }),
    }
    return self
end


-- Draw the Sword
function Sword:draw()
    -- Check if weapon is in hand or back
    if State.isWeaponEquipped(self.name) then
        self:drawInHand()
    else
        self:drawInBack()
    end
  
end

-- Draw Sword in hand 
function Sword:drawInHand()
  
end

-- Draw Sword in the back
function Sword:drawInBack()
  
end
return Sword

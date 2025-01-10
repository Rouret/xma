local Skills = require("skills")
local State = require("player.state")
local Sword = {}
Sword.__index = Sword

function Sword.new()
    local self = setmetatable({}, Sword)
    self.name = "Sword"
    self.skills = {
        Skills.new("Slash", 0.3, function()

        end),
        Skills.new("Block", 2, function()
     
        end),
        Skills.new("Dash Strike", 1, function(player)
           
        
        end),
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

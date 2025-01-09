local Skills = require("skills")
local State = require("player.state")
local Sword = {}
Sword.__index = Sword

function Sword.new()
    local self = setmetatable({}, Sword)
    self.name = "Sword"
    self.skills = {
        Skills.new("Slash", 0.3, function()
            print("Sword: Slash")
        end),
        Skills.new("Block", 2, function()
            print("Sword: Block")
        end),
        Skills.new("Dash Strike", 1, function(player)
            player.x = player.x + 200 * math.cos(player.getAngleToMouse())
            player.y = player.y + 200 * math.sin(player.getAngleToMouse())
            print("Sword: Dash Strike")
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

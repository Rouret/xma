local Skills = require("skills")

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

return Sword

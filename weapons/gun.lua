local Skills = require("skills")

local Gun = {}
Gun.__index = Gun

function Gun.new()
    local self = setmetatable({}, Gun)
    self.name = "Gun"
    self.skills = {
        Skills.new("Shoot", 0.5, function(x, y, direction, addProjectileCallback)
            print("Gun: Shoot")
        end),
        Skills.new("Reload", 2, function()
            print("Gun: Reload")
        end),
        Skills.new("Aim Boost", 1, function()
            print("Gun: Aim Boost")
        end),
    }
    return self
end

return Gun

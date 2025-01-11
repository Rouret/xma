local State = require("player.state")
local UI = {}


function UI.load()
end


function UI.update()
end


function UI.draw()
    -- Draw rectangle 120x120px for the skills of the weapon at the center bottom of the screen
    local weapon = State.weapons[State.currentWeaponIndex]
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local rectWidth, rectHeight = 120, 120
    local x = (screenWidth - (#weapon.skills * rectWidth)) / 2
    local y = screenHeight - rectHeight
    for i, skill in ipairs(weapon.skills) do
        local rectX = x + (i - 1) * rectWidth
        love.graphics.rectangle("line", rectX, y, rectWidth, rectHeight)
        love.graphics.printf(skill.name, rectX, y + rectHeight / 4, rectWidth, "center")
        
        if skill.remainingCooldownInSeconds > 0 then
            love.graphics.printf("CD: " .. UI.formatTime(skill.remainingCooldownInSeconds), rectX, y + rectHeight / 2, rectWidth, "center")
        end
    end

end

function UI.formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return string.format("%02d:%02d", minutes, remainingSeconds)
end

return UI

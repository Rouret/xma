local State = require("player.state")
local UI = {}

local cooldownOverlay = love.graphics.newImage("sprites/weapons/on_cd_skill.png")

function UI.load()
end


function UI.update()
end


function UI.draw()
    -- Draw rectangle 120x120px for the skills of the weapon at the center bottom of the screen
    local weapon = State.weapons[State.currentWeaponIndex]
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local rectWidth, rectHeight = 120, 120
    local gap = 16
    local totalWidth = (#weapon.skills * rectWidth) + ((#weapon.skills - 1) * gap)
    local x = (screenWidth - totalWidth) / 2
    local y = screenHeight - rectHeight
    for i, skill in ipairs(weapon.skills) do
        local calcX = x + (i - 1) * (rectWidth + gap)
        love.graphics.draw(skill.image, calcX, y)
        if skill.remainingCooldownInSeconds > 0 then
            love.graphics.draw(cooldownOverlay, calcX, y)
            local cooldownText = UI.formatTime(skill.remainingCooldownInSeconds)
            local font = love.graphics.newFont(36) 
            love.graphics.setFont(font)
            local textWidth = font:getWidth(cooldownText)
            local textHeight = font:getHeight(cooldownText)
            love.graphics.print(cooldownText, calcX + (rectWidth - textWidth) / 2, y + (rectHeight - textHeight) / 2)
        end
    end
end

function UI.formatTime(seconds)
    local remainingSeconds = seconds % 60
    return string.format("%d", remainingSeconds)
end

return UI

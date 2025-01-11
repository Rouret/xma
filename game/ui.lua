local State = require("player.state")
local UI = {}

local cooldownOverlay = love.graphics.newImage("sprites/weapons/on_cd_skill.png")

function UI.load()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    UI.screenWidth = screenWidth
    UI.screenHeight = screenHeight

    UI.skills = {}
    UI.skills.gap = 16
    UI.skills.size = 120

    UI.font = love.graphics.newFont(36) 

    return UI
end


function UI.update()
end


function UI:draw()
    UI.drawSkills()
end


function UI.drawSkills()
    local weapon = State.weapons[State.currentWeaponIndex]
    local totalWidth = (#weapon.skills * UI.skills.size) + ((#weapon.skills - 1) * UI.skills.gap)
    local x = (UI.screenWidth - totalWidth) / 2
    local y = UI.screenHeight - UI.skills.size
    for i, skill in ipairs(weapon.skills) do
        local calcX = x + (i - 1) * (UI.skills.size + UI.skills.gap)
        love.graphics.draw(skill.image, calcX, y)
        if skill.remainingCooldownInSeconds > 0 then
            love.graphics.draw(cooldownOverlay, calcX, y)
            local cooldownText = UI.formatTime(skill.remainingCooldownInSeconds)
            love.graphics.setFont(UI.font)
            local textWidth = UI.font:getWidth(cooldownText)
            local textHeight = UI.font:getHeight(cooldownText)
        
            love.graphics.print(cooldownText, calcX + (UI.skills.size - textWidth) / 2, y + (UI.skills.size - textHeight) / 2)
        end
    end
end

function UI.formatTime(seconds)
    local remainingSeconds = seconds % 60
    return string.format("%d", remainingSeconds)
end

return UI

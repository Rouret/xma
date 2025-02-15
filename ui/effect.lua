local State = require("player.state")
local love = require("love")

local UIEffect = {}
local paddingY = 5 -- Espace entre chaque effet
local y = 20

function UIEffect.drawEffectIcon(effect, x, y, UI)
    if effect.UIIcon then
        local image = effect.UIIcon
        local imgHeight = image:getHeight()

        -- Dessiner l'icône
        love.graphics.draw(image, x, y)

        -- Dessiner le temps restant
        local text = UI.formatTime(effect.remainingTime)
        local textWidth = UI.font.big:getWidth(text)
        local textHeight = UI.font.big:getHeight()

        love.graphics.print(text, x - textWidth - 5, y + (imgHeight - textHeight) / 2)

        -- Décaler vers le bas pour l'effet suivant
        y = y + imgHeight + paddingY
    end
end

function UIEffect.draw(UI)
    local x = UI.screenWidth - 100

    if #State.effects == 0 then
        return
    end

    love.graphics.setFont(UI.font.big)
    love.graphics.setColor(1, 1, 1)

    for _, effect in ipairs(State.effects) do
        UIEffect.drawEffectIcon(effect, x, y, UI)
    end
end

return UIEffect

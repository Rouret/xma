local State = require("player.state")
local Draw = {}

function Draw.draw()
    -- Dessiner le joueur
    love.graphics.circle("fill", State.x, State.y, 10)

    -- Dessiner la barre de santé
    Draw.drawHealthBar()
end

function Draw.drawHealthBar()
    local barWidth = 50
    local barHeight = 5
    local x = State.x - barWidth / 2
    local y = State.y - 20

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", x, y, barWidth, barHeight)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", x, y, barWidth * (State.health / State.maxHealth), barHeight)
    love.graphics.setColor(1, 1, 1)
end

function Draw.drawWeaponInfo(weapons, currentWeaponIndex)
    -- Afficher les informations de l'arme active
    local weapon = weapons[currentWeaponIndex]
    love.graphics.print("Weapon: " .. weapon.name .. " (E to switch)", 10, 10)

    -- Afficher les cooldowns des compétences
    for i, skill in ipairs(weapon.skills) do
        local remaining = math.max(0, skill.cooldown - (love.timer.getTime() - skill.lastUsed))
        love.graphics.print(skill.name .. ": " .. string.format("%.1f", remaining) .. "s", 10, 30 + i * 20)
    end
end


return Draw
